package serverhead

import (
	"context"
	"server/internal/mqtt"
	dbmodels "server/internal/storage/models"
	db "server/internal/storage/service"
	"time"
)

type ServerHead struct {
	mqtt    *mqtt.MQTTClient
	storage *db.SensorStorage
}

func New(mqttClient *mqtt.MQTTClient, storage *db.SensorStorage) *ServerHead {
	return &ServerHead{mqtt: mqttClient, storage: storage}
}

func (s *ServerHead) GetWindSpeed(ctx context.Context) (dbmodels.WindSpeed, error) {
	wind, err := s.mqtt.GetWind(ctx)
	if err != nil {
		return dbmodels.WindSpeed{}, err
	}
	dbWind := wind.ToSQLModel(time.Now())
	if err = s.storage.SaveWind(ctx, dbWind); err != nil {
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
	if err = s.storage.SaveTemperature(ctx, dbTemp); err != nil {
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
	if err = s.storage.SaveHumidity(ctx, dbHumidity); err != nil {
		return dbmodels.Humidity{}, err
	}

	return dbHumidity, nil
}
