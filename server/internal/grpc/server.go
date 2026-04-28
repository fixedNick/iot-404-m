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
	s := grpc.NewServer()
	gs.server = s
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", gs.port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	pb.RegisterESP8266ServiceServer(s, gs)

	fmt.Println("GRPC Server ready for connections")

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func (gs *GRPCServer) Stop() {
	gs.server.GracefulStop()
}
func (gs *GRPCServer) WindSpeed(ctx context.Context, req *pb.WindSpeedRequest) (*pb.WindSpeedResponse, error) {
	fmt.Println("GRPCServer: API.WindSpeed() called")

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

func (gs *GRPCServer) Temperature(context.Context, *pb.TemperatureRequest) (*pb.TemperatureResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method Humidity not implemented")
}
func (gs *GRPCServer) Humidity(context.Context, *pb.HumidityRequest) (*pb.HumidityResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method Humidity not implemented")
}
func (gs *GRPCServer) AutoCollect(context.Context, *pb.AutoCollectRequest) (*pb.AutoCollectResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method AutoCollect not implemented")
}
func (gs *GRPCServer) StopAutoCollect(context.Context, *pb.StopAutoCollectRequest) (*pb.StopAutoCollectResponse, error) {
	return nil, status.Error(codes.Unimplemented, "method StopAutoCollect not implemented")
}
