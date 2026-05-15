package serverhead

import (
	"context"
	"errors"
	"server/internal/domain/period"
	"server/internal/domain/sensors"
	"server/internal/mqtt"
	dbmodels "server/internal/storage/models"
	db "server/internal/storage/service"
	"server/pb"
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

func (s *ServerHead) GetSensorStatus(ctx context.Context, sensor sensors.Sensor) bool {

	log.Info().Str("in", "ServerHead.GetSensorStatus").Str("sensor", sensor.SQLName()).Msg("Getting sensor status")
	switch sensor {
	case sensors.WindSpeed:
		return s.autoWindRunning
	case sensors.Temperature:
		return s.autoTempRunning
	case sensors.Humidity:
		return s.autoHumidityRunning
	}
	return false
}

func (s *ServerHead) GetSensorStats(ctx context.Context, p period.PeriodType, sensor sensors.Sensor, offset int) (*pb.GetSensorStatsResponse, error) {
	panic("Unimplemented")
}
