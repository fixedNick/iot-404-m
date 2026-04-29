package grpc

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net"
	cfg "server/internal/config"
	serverhead "server/internal/server_head"
	pb "server/pb"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type GRPCServer struct {
	port    int
	server  *grpc.Server
	shead   *serverhead.ServerHead
	timeout time.Duration
	pb.UnimplementedESP8266ServiceServer
}

func NewGRPCServer(cfg *cfg.Config, shead *serverhead.ServerHead) *GRPCServer {
	return &GRPCServer{
		port:    cfg.GRPC.Port,
		timeout: time.Duration(cfg.GRPC.Timeout) * time.Millisecond,
		shead:   shead,
	}
}

func (gs *GRPCServer) Run() {
	startSyncChan := make(chan struct{})
	go gs.run(startSyncChan)
	<-startSyncChan
	fmt.Println("GRPC Server ready for connections")
}

func (gs *GRPCServer) run(startSyncChan chan struct{}) {
	s := grpc.NewServer()
	gs.server = s
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", gs.port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	pb.RegisterESP8266ServiceServer(s, gs)

	close(startSyncChan)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func (gs *GRPCServer) Stop() {
	gs.server.GracefulStop()
}
func (gs *GRPCServer) WindSpeed(ctx context.Context, req *pb.WindSpeedRequest) (*pb.WindSpeedResponse, error) {
	ctx, cancel := context.WithTimeout(ctx, gs.timeout)
	defer cancel()
	wind, err := gs.shead.GetWindSpeed(ctx, true)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, status.Error(codes.DeadlineExceeded, "Timeout reached")
		}
		return nil, status.Error(codes.Unknown, fmt.Sprintf("Error: %v", err))
	}
	return &pb.WindSpeedResponse{
		Voltage: wind.Voltage,
		Speed:   wind.Speed,
		Time:    wind.Time,
	}, nil
}

func (gs *GRPCServer) Temperature(ctx context.Context, req *pb.TemperatureRequest) (*pb.TemperatureResponse, error) {
	ctx, cancel := context.WithTimeout(ctx, gs.timeout)
	defer cancel()
	temp, err := gs.shead.GetTemperature(ctx, true)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, status.Error(codes.DeadlineExceeded, "Timeout reached")
		}
		return nil, status.Error(codes.Unknown, fmt.Sprintf("Error: %v", err))
	}
	return &pb.TemperatureResponse{
		Temperature: temp.Temperature,
		Time:        temp.Time,
	}, nil
}
func (gs *GRPCServer) Humidity(ctx context.Context, req *pb.HumidityRequest) (*pb.HumidityResponse, error) {
	ctx, cancel := context.WithTimeout(ctx, gs.timeout)
	defer cancel()
	humidity, err := gs.shead.GetHumidity(ctx, true)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, status.Error(codes.DeadlineExceeded, "Timeout reached")
		}
		return nil, status.Error(codes.Unknown, fmt.Sprintf("Error: %v", err))
	}
	return &pb.HumidityResponse{
		Humidity: humidity.Humidity,
		Time:     humidity.Time,
	}, nil
}
func (gs *GRPCServer) AutoCollect(ctx context.Context, req *pb.AutoCollectRequest) (*pb.AutoCollectResponse, error) {
	err := gs.shead.StartAutoCollect(ctx, req.Sensor, int(req.Duration), int(req.Period))
	if err != nil {
		return nil, status.Error(codes.Unavailable, fmt.Sprintf("Error: %v", err))
	}
	return &pb.AutoCollectResponse{Success: true}, nil
}
func (gs *GRPCServer) StopAutoCollect(ctx context.Context, req *pb.StopAutoCollectRequest) (*pb.StopAutoCollectResponse, error) {
	err := gs.shead.StopAutoCollect(req.Sensor)
	if err != nil {
		return nil, status.Error(codes.Unavailable, fmt.Sprintf("Error: %v", err))
	}
	return &pb.StopAutoCollectResponse{Success: true}, nil
}
