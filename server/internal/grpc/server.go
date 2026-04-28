package grpc

import (
	"context"
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
		timeout: time.Duration(cfg.GRPC.Timeout * uint(time.Millisecond)),
		shead:   shead,
	}
}

func (gs *GRPCServer) Run() {
	syncChan := make(chan struct{})
	go gs.run(syncChan)
	<-syncChan
	fmt.Println("GRPC Server ready for connections")
}

func (gs *GRPCServer) run(syncChan chan struct{}) {
	s := grpc.NewServer()
	gs.server = s
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", gs.port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	pb.RegisterESP8266ServiceServer(s, gs)

	close(syncChan)
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
	wind, err := gs.shead.GetWindSpeed(ctx)
	if err != nil {
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
	// todo: pass context cancel into func and canlcel on value returned
	temp, err := gs.shead.GetTemperature(ctx)
	if err != nil {
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
	humidity, err := gs.shead.GetHumidity(ctx)
	if err != nil {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("Error: %v", err))
	}
	return &pb.HumidityResponse{
		Humidity: humidity.Humidity,
		Time:     humidity.Time,
	}, nil
}
func (gs *GRPCServer) AutoCollect(context.Context, *pb.AutoCollectRequest) (*pb.AutoCollectResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method AutoCollect not implemented")
}
func (gs *GRPCServer) StopAutoCollect(context.Context, *pb.StopAutoCollectRequest) (*pb.StopAutoCollectResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method StopAutoCollect not implemented")
}
