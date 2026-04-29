package serverhead

import (
	"context"
	"errors"
	"server/internal/mqtt"
	dbmodels "server/internal/storage/models"
	db "server/internal/storage/service"
	"time"

	"github.com/rs/zerolog/log"
)

type ServerHead struct {
	mqtt    *mqtt.MQTTClient
	storage *db.SensorStorage
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
func (s *ServerHead) GetTemperature(ctx context.Context) (dbmodels.Temperature, error) {
	temp, err := s.mqtt.GetTemperature(ctx)
	if err != nil {
		return dbmodels.Temperature{}, err
	}
	dbTemp := temp.ToSQLModel(time.Now())
	saveCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err = s.storage.SaveTemperature(saveCtx, dbTemp); err != nil {
		return dbmodels.Temperature{}, err
	}

	return dbTemp, nil
}
func (s *ServerHead) GetHumidity(ctx context.Context) (dbmodels.Humidity, error) {
	humidity, err := s.mqtt.GetHumidity(ctx)
	if err != nil {
		return dbmodels.Humidity{}, err
	}
	dbHumidity := humidity.ToSQLModel(time.Now())
	saveCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err = s.storage.SaveHumidity(saveCtx, dbHumidity); err != nil {
		return dbmodels.Humidity{}, err
	}

	return dbHumidity, nil
}
