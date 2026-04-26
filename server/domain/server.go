package domain

import (
	"context"
	"fmt"
	"log"
	"net"
	pb "server/pb"

	"google.golang.org/grpc"
	"google.golang.org/protobuf/types/known/emptypb"
)

type GRPCServer struct {
	cfg     *Config
	server  *grpc.Server
	storage *Storage
	mqtt    *MQTTClient
	pb.UnimplementedESP8266Server
}

func NewGRPCServer(cfg *Config, storage *Storage, mqtt *MQTTClient) *GRPCServer {
	return &GRPCServer{
		cfg:     cfg,
		storage: storage,
		mqtt:    mqtt,
	}
}

func (gs *GRPCServer) Run() {
	s := grpc.NewServer()
	gs.server = s
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", gs.cfg.Local.Port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	pb.RegisterESP8266Server(s, gs)

	fmt.Println("GRPC Server ready for connections")

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func (gs *GRPCServer) Stop() {
	gs.server.GracefulStop()
}

func (gs *GRPCServer) Windspeed(context.Context, *emptypb.Empty) (*pb.WindSpeedResponse, error) {
	fmt.Println("Received API Call")

	// TODO:
	_json := `{"cmd": "GET", "sensor": "wind"}`
	gs.mqtt.Publish("sensors/control", QoS_HIGH, true, []byte(_json))
	<-gs.mqtt.Sync

	// get last wind speed from db
	v := gs.storage.Last()
	if v == nil {
		log.Println("Asked for WindSpeed(). Data currently empty")
		return &pb.WindSpeedResponse{Status: 1, Message: "ESP8266 middleware error"}, nil
	}

	return &pb.WindSpeedResponse{
		Status: 0,
		Speed:  v.speed,
	}, nil
}
