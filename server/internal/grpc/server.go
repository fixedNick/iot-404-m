package grpc

import (
	"context"
	"errors"
	"fmt"
	"net"
	cfg "server/internal/config"
	"server/internal/domain/period"
	"server/internal/domain/sensors"
	serverhead "server/internal/server_head"
	pb "server/pb"
	"time"

	"github.com/rs/zerolog/log"
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
		log.Fatal().AnErr("failed to listen", err)
	}

	pb.RegisterESP8266ServiceServer(s, gs)

	close(startSyncChan)
	if err := s.Serve(lis); err != nil {
		log.Fatal().AnErr("failed to serve", err)
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
	log.Info().Str("in", "GRPC_API.AutoCollect").Str("sensor", req.Sensor).Uint64("period", req.Period).Uint64("duration", req.Duration).Msg("API Start Auto Collect")
	err := gs.shead.StartAutoCollect(ctx, sensors.FromString(req.Sensor), int(req.Duration), int(req.Period))
	if err != nil {
		return nil, status.Error(codes.Unavailable, fmt.Sprintf("Error: %v", err))
	}
	return &pb.AutoCollectResponse{Success: true}, nil
}
func (gs *GRPCServer) StopAutoCollect(ctx context.Context, req *pb.StopAutoCollectRequest) (*pb.StopAutoCollectResponse, error) {
	log.Info().Str("in", "GRPC_API.StopAutoCollect").Str("sensor", req.Sensor).Msg("API Stop Auto Collect")
	err := gs.shead.StopAutoCollect(sensors.FromString(req.Sensor))
	if err != nil {
		return nil, status.Error(codes.Unavailable, fmt.Sprintf("Error: %v", err))
	}
	return &pb.StopAutoCollectResponse{Success: true}, nil
}

func (gs *GRPCServer) GetSensorStatus(ctx context.Context, req *pb.GetSensorStatusRequest) (*pb.GetSensorStatusResponse, error) {
	log.Info().Str("in", "GRPC_API.GetSensorStatus").Str("sensor", req.Sensor).Msg("API Getting sensor status")
	enabled := gs.shead.GetSensorStatus(ctx, sensors.FromString(req.Sensor))
	return &pb.GetSensorStatusResponse{
		Enabled: enabled,
	}, nil
}

func (gs *GRPCServer) GetSensorStats(ctx context.Context, req *pb.GetSensorStatsRequest) (*pb.GetSensorStatsResponse, error) {
	resp, err := gs.shead.GetSensorStats(ctx, period.FromProtobuf(req.Period), sensors.FromProtobuf(req.Sensor), int(req.PeriodOffset))

	// clean resp points for graph

	isPrevZero := false
	prevDayDot := 0.0
	sortedDay := make([]*pb.DayDataPoint, 0)
	if len(resp.DayData) > 0 {
		sortedDay = append(sortedDay, resp.DayData[0])
		if resp.DayData[0].Value == 0 {
			isPrevZero = true
		}
	}

	for _, dd := range resp.DayData {
		// clean bad values
		switch req.Sensor {
		case pb.SensorType_SENSOR_TYPE_HUMIDITY:
			if dd.Value <= 0 || dd.Value > 100 {
				continue
			}
		case pb.SensorType_SENSOR_TYPE_TEMPERATURE:
			// check avg temp for day
			// max delta btw min and avg temp is 12
			avg := 0.0
			for _, dd := range resp.DayData {
				avg += dd.Value
			}
			avg /= float64(len(resp.DayData))
			if (dd.Value > avg+12 || dd.Value < avg-12) && dd.Value == 0 {
				continue
			}
		}
		// clean zero sequences, save only 1 zero
		if dd.Value != 0 {

			if dd.Value == prevDayDot {
				continue
			}

			prevDayDot = dd.Value
			sortedDay = append(sortedDay, dd)
			isPrevZero = false
			continue
		}

		if isPrevZero == false {
			sortedDay = append(sortedDay, dd)
			isPrevZero = true
		}
	}

	sortedAvgData := make([]*pb.AggregatedDataPoint, 0)
	for _, sd := range resp.AggregatedData {
		// clean bad values
		// max delta btw avg & min temp is 12
		switch req.Sensor {
		case pb.SensorType_SENSOR_TYPE_TEMPERATURE:
			if sd.Avg > sd.Min+12 || sd.Avg < sd.Min-12 {
				continue
			}
		case pb.SensorType_SENSOR_TYPE_HUMIDITY:
			if sd.Max <= 0 || sd.Max > 100 {
				continue
			}
			if sd.Min <= 0 || sd.Min > 100 {
				continue
			}
			if sd.Avg <= 0 || sd.Avg > 100 {
				continue
			}
		}
		sortedAvgData = append(sortedAvgData, sd)
	}

	//
	resp.DayData = sortedDay
	resp.AggregatedData = sortedAvgData
	//

	if err != nil {
		fmt.Println("Error", err.Error())
		log.Err(err).Str("in", "GRPCServer.GetSensorStats")
		return nil, err
	}
	return resp, nil
}
