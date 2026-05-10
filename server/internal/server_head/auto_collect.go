package serverhead

import (
	"context"
	"fmt"
	"server/internal/domain/sensors"
	"time"

	"github.com/rs/zerolog/log"
)

func (s *ServerHead) StartAutoCollect(ctx context.Context, sensor sensors.Sensor, duration int, period int) error {
	if duration < 0 || period < 1000 {
		return fmt.Errorf("Invalid parameters. Duration > 0 & Period >= 1000")
	}
	switch sensor {
	case sensors.Temperature:
		if s.autoTempRunning {
			return fmt.Errorf("Temperature Auto Collect already running.")
		}
		go s.autoCollecTemperature(duration, period)
	case sensors.Humidity:
		if s.autoHumidityRunning {
			return fmt.Errorf("Humidity Auto Collect already running.")
		}
		go s.autoCollectHumidity(duration, period)
	case sensors.WindSpeed:
		if s.autoWindRunning {
			return fmt.Errorf("WindSpeed Auto Collect already running.")
		}
		go s.autoCollectWind(duration, period)
	default:
		return fmt.Errorf("Unknown sensor")
	}
	return nil
}

func (s *ServerHead) autoCollectWind(duration, period int) {
	s.autoWindRunning = true
	s.stopAutoWind = make(chan struct{})

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

out_loop:
	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			wind, err := s.GetWindSpeed(ctx, false)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectWind.GetWindSpeed").AnErr("error", err)
			}
			cancel()
			err = s.storage.SaveWind(context.Background(), wind)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectWind.SaveWind").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollectWind").Float32("Speed", wind.Speed).Float32("Voltage", wind.Voltage).Msg("Auto Collect - Wind collected")
		case <-time.After(endTime):
			close(s.stopAutoWind)
			s.autoWindRunning = false
			log.Info().Str("in", "ServerHead.autoCollectWind").Msg("Wind Collection stopped by Deadline")
			break out_loop
		case <-s.stopAutoWind:
			s.autoWindRunning = false
			log.Info().Str("in", "ServerHead.autoCollectWind").Msg("Wind Collection stopped by stop signal")
			break out_loop
		}
	}
}
func (s *ServerHead) autoCollecTemperature(duration, period int) {
	s.autoTempRunning = true
	s.stopAutoTemp = make(chan struct{})

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

out_loop:
	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			temp, err := s.GetTemperature(ctx, false)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectTemperature.GetTemperature").AnErr("error", err)
			}
			cancel()
			err = s.storage.SaveTemperature(context.Background(), temp)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectTemperature.SaveTemperature").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollecTemperature").Float32("Temperature", temp.Temperature).Msg("Auto Collect - Temperature collected")
		case <-time.After(endTime):
			close(s.stopAutoTemp)
			s.autoTempRunning = false
			log.Info().Str("in", "ServerHead.autoCollecTemperature").Msg("Temperature Collection stopped by Deadline")
			break out_loop
		case <-s.stopAutoTemp:
			s.autoTempRunning = false
			log.Info().Str("in", "ServerHead.autoCollecTemperature").Msg("Temperature Collection stopped by stop signal")
			break out_loop
		}
	}
}
func (s *ServerHead) autoCollectHumidity(duration, period int) {
	s.autoHumidityRunning = true
	s.stopAutoHumidity = make(chan struct{})

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

out_loop:
	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			humidity, err := s.GetHumidity(ctx, false)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectHumidity.GetHumidity").AnErr("error", err)
			}
			cancel()
			err = s.storage.SaveHumidity(context.Background(), humidity)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectHumidity.SaveHumidity").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Float32("Humidity", humidity.Humidity).Msg("Auto Collect - Humidity collected")
		case <-time.After(endTime):
			close(s.stopAutoHumidity)
			s.autoHumidityRunning = false
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Msg("Humidity Collection stopped by Deadline")
			break out_loop
		case <-s.stopAutoHumidity:
			s.autoHumidityRunning = false
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Msg("Humidity Collection stopped by stop signal")
			break out_loop
		}
	}

}

func (s *ServerHead) StopAutoCollect(sensor sensors.Sensor) error {
	log.Info().Str("in", "ServerHead.StopAutoCollect").Str("sensor", string(sensor)).Msg("Stop signal received")
	switch sensor {
	case sensors.Temperature:
		if s.autoTempRunning {
			s.stopAutoTemp <- struct{}{}
			return nil
		}
	case sensors.Humidity:
		if s.autoHumidityRunning {
			s.stopAutoHumidity <- struct{}{}
			return nil
		}
	case sensors.WindSpeed:
		if s.autoWindRunning {
			s.stopAutoWind <- struct{}{}
			return nil
		}
	default:
		return fmt.Errorf("Unknown sensor")
	}
	return nil
}
