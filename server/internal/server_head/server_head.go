package serverhead

import (
	"context"
	"errors"
	"fmt"
	"server/internal/mqtt"
	dbmodels "server/internal/storage/models"
	db "server/internal/storage/service"
	"time"

	"github.com/rs/zerolog/log"
)

type ServerHead struct {
	mqtt    *mqtt.MQTTClient
	storage *db.SensorStorage

	stopAutoWind     chan struct{}
	stopAutoTemp     chan struct{}
	stopAutoHumidity chan struct{}

	autoTempRunning     bool
	autoHumidityRunning bool
	autoWindRunning     bool
}

func New(mqttClient *mqtt.MQTTClient, storage *db.SensorStorage) *ServerHead {
	return &ServerHead{mqtt: mqttClient, storage: storage}
}

func (s *ServerHead) GetWindSpeed(ctx context.Context, lastOnDeadline bool) (dbmodels.WindSpeed, error) {
	wind, err := s.mqtt.GetWind(ctx)
	if err != nil {
		if lastOnDeadline && errors.Is(err, context.DeadlineExceeded) {
			lastCtx, lastCancel := context.WithTimeout(context.Background(), time.Second*2)
			defer lastCancel()

			log.Warn().Str("in", "ServerHead.GetWindSpeed").Str("message", "Asking for last saved wind speed")
			wind, err := s.storage.GetLastWind(lastCtx)
			if err != nil {
				log.Error().Str("in", "ServerHead.GetWindSpeed").AnErr("error", err)
			} else {
				log.Info().Str("in", "ServerHead.GetWindSpeed").Str("message", "Last wind speed").Float32("Speed", wind.Speed).Float32("Voltage", wind.Voltage).Time("Time", time.Unix(wind.Time, 0))
			}
			return wind, err
		}
		return dbmodels.WindSpeed{}, err
	}
	dbWind := wind.ToSQLModel(time.Now())
	saveCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err = s.storage.SaveWind(saveCtx, dbWind); err != nil {
		return dbmodels.WindSpeed{}, err
	}

	return dbWind, nil
}
func (s *ServerHead) GetTemperature(ctx context.Context, lastOnDeadline bool) (dbmodels.Temperature, error) {
	temp, err := s.mqtt.GetTemperature(ctx)
	if lastOnDeadline && errors.Is(err, context.DeadlineExceeded) {
		lastCtx, lastCancel := context.WithTimeout(context.Background(), time.Second*2)
		defer lastCancel()

		log.Warn().Str("in", "ServerHead.GetTemperature").Str("message", "Asking for last saved temperature")
		temp, err := s.storage.GetLastTemperature(lastCtx)
		if err != nil {
			log.Error().Str("in", "ServerHead.GetTemperature").AnErr("error", err)
		} else {
			log.Info().Str("in", "ServerHead.GetTemperature").Str("message", "Last temperature").Float32("Speed", temp.Temperature).Time("Time", time.Unix(temp.Time, 0))
		}
		return temp, err
	}
	dbTemp := temp.ToSQLModel(time.Now())
	saveCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err = s.storage.SaveTemperature(saveCtx, dbTemp); err != nil {
		return dbmodels.Temperature{}, err
	}

	return dbTemp, nil
}
func (s *ServerHead) GetHumidity(ctx context.Context, lastOnDeadline bool) (dbmodels.Humidity, error) {
	humidity, err := s.mqtt.GetHumidity(ctx)
	if lastOnDeadline && errors.Is(err, context.DeadlineExceeded) {
		lastCtx, lastCancel := context.WithTimeout(context.Background(), time.Second*2)
		defer lastCancel()

		log.Warn().Str("in", "ServerHead.GetHumidity").Str("message", "Asking for last saved humidity")
		humidity, err := s.storage.GetLastHumidity(lastCtx)
		if err != nil {
			log.Error().Str("in", "ServerHead.GetHumidity").AnErr("error", err)
		} else {
			log.Info().Str("in", "ServerHead.GetHumidity").Str("message", "Last humidity").Float32("Speed", humidity.Humidity).Time("Time", time.Unix(humidity.Time, 0))
		}
		return humidity, err
	}
	dbHumidity := humidity.ToSQLModel(time.Now())
	saveCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err = s.storage.SaveHumidity(saveCtx, dbHumidity); err != nil {
		return dbmodels.Humidity{}, err
	}

	return dbHumidity, nil
}
func (s *ServerHead) StartAutoCollect(ctx context.Context, sensor string, duration int, period int) error {
	if duration < 0 || period < 1000 {
		return fmt.Errorf("Invalid parameters. Duration > 0 & Period >= 1000")
	}
	switch sensor {
	case string(mqtt.SensorTemperature):
		if s.autoTempRunning {
			return fmt.Errorf("WindSpeed Auto Collect already running.")
		}
		go s.autoCollecTemperature(duration, period)
	case string(mqtt.SensorHumidity):
		if s.autoHumidityRunning {
			return fmt.Errorf("WindSpeed Auto Collect already running.")
		}
		go s.autoCollectHumidity(duration, period)
	case string(mqtt.SensorWind):
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
		case <-time.After(endTime):
			close(s.stopAutoWind)
			s.autoWindRunning = false
			return
		case <-s.stopAutoWind:
			s.autoWindRunning = false
			return
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
		case <-time.After(endTime):
			close(s.stopAutoTemp)
			s.autoTempRunning = false
			return
		case <-s.stopAutoTemp:
			s.autoTempRunning = false
			return
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
		case <-time.After(endTime):
			close(s.stopAutoHumidity)
			s.autoHumidityRunning = false
			return
		case <-s.stopAutoHumidity:
			s.autoHumidityRunning = false
			return
		}
	}
}

func (s *ServerHead) StopAutoCollect(sensor string) error {
	switch sensor {
	case string(mqtt.SensorTemperature):
		if s.autoTempRunning {
			s.stopAutoTemp <- struct{}{}
			return nil
		}
	case string(mqtt.SensorHumidity):
		if s.autoHumidityRunning {
			s.stopAutoHumidity <- struct{}{}
			return nil
		}
	case string(mqtt.SensorWind):
		if s.autoWindRunning {
			s.stopAutoWind <- struct{}{}
			return nil
		}
	default:
		return fmt.Errorf("Unknown sensor")
	}
	return nil
}
