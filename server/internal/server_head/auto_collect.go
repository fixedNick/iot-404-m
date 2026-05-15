package serverhead

import (
	"context"
	"fmt"
	"server/internal/domain/sensors"
	"time"

	"github.com/rs/zerolog/log"
)

// TODO:
// In every autoCollect method replace channels on context Cancel() funcs to thread safe

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
	s.mu.Lock()
	s.autoWindRunning = true
	s.stopAutoWind = make(chan struct{})
	s.mu.Unlock()

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * 1000 * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

	endCtx, endCancel := context.WithDeadline(context.Background(), time.Now().Add(endTime))
	defer endCancel()

	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			wind, err := s.GetWindSpeed(ctx, false)
			cancel()
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectWind.GetWindSpeed").AnErr("error", err)
				continue
			}
			err = s.storage.SaveWind(context.Background(), wind)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectWind.SaveWind").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollectWind").Float32("Speed", wind.Speed).Float32("Voltage", wind.Voltage).Msg("Auto Collect - Wind collected")
		case <-endCtx.Done():
			s.mu.Lock()
			close(s.stopAutoWind)
			s.autoWindRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectWind").Msg("Wind Collection stopped by Deadline")
			return
		case <-s.stopAutoWind:
			s.mu.Lock()
			s.autoWindRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectWind").Msg("Wind Collection stopped by stop signal")
			return
		}
	}
}
func (s *ServerHead) autoCollecTemperature(duration, period int) {
	s.mu.Lock()
	s.autoTempRunning = true
	s.stopAutoTemp = make(chan struct{})
	s.mu.Unlock()

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * 1000 * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

	endCtx, endCancel := context.WithDeadline(context.Background(), time.Now().Add(endTime))
	defer endCancel()

	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			temp, err := s.GetTemperature(ctx, false)
			cancel()
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectTemp.GetTemperature").AnErr("error", err)
				continue
			}
			err = s.storage.SaveTemperature(context.Background(), temp)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectTemp.SaveTemp").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollectTemp").Float32("Temperature", temp.Temperature).Msg("Auto Collect - Temp collected")
		case <-endCtx.Done():
			s.mu.Lock()
			close(s.stopAutoTemp)
			s.autoTempRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectTemp").Msg("Temp Collection stopped by Deadline")
			return
		case <-s.stopAutoTemp:
			s.mu.Lock()
			s.autoTempRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectTemp").Msg("Temp Collection stopped by stop signal")
			return
		}
	}
}
func (s *ServerHead) autoCollectHumidity(duration, period int) {
	s.mu.Lock()
	s.autoHumidityRunning = true
	s.stopAutoHumidity = make(chan struct{})
	s.mu.Unlock()

	var endTime time.Duration
	if duration == 0 {
		// 60.000 hours, endless
		endTime = time.Hour * time.Duration(60000)
	} else {
		endTime = time.Duration(duration) * 1000 * time.Millisecond
	}

	tick := time.NewTicker(time.Duration(period) * time.Millisecond)
	defer tick.Stop()

	endCtx, endCancel := context.WithDeadline(context.Background(), time.Now().Add(endTime))
	defer endCancel()

	for {
		select {
		case <-tick.C:
			ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
			humidity, err := s.GetHumidity(ctx, false)
			cancel()
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectHumidity.GetHumidity").AnErr("error", err)
				continue
			}
			err = s.storage.SaveHumidity(context.Background(), humidity)
			if err != nil {
				log.Error().Str("in", "ServerHead.autoCollectHumidity.SaveHumidity").AnErr("error", err)
			}
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Float32("Humidity", humidity.Humidity).Msg("Auto Collect - Humidity collected")
		case <-endCtx.Done():
			s.mu.Lock()
			close(s.stopAutoHumidity)
			s.autoHumidityRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Msg("Humidity Collection stopped by Deadline")
			return
		case <-s.stopAutoHumidity:
			s.mu.Lock()
			s.autoHumidityRunning = false
			s.mu.Unlock()
			log.Info().Str("in", "ServerHead.autoCollectHumidity").Msg("Humidity Collection stopped by stop signal")
			return
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
