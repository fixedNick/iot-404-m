package db

import (
	"context"
	"fmt"
	cfg "server/internal/config"
	dbmodels "server/internal/storage/models"
	"server/internal/storage/repository"

	"github.com/rs/zerolog/log"
)

type SensorStorage struct {
	sqlRepo *repository.MysqlRepository

	windCache        *repository.LocalCache[dbmodels.WindSpeed]
	temperatureCache *repository.LocalCache[dbmodels.Temperature]
	humidityCache    *repository.LocalCache[dbmodels.Humidity]
}

func New(config *cfg.Config) *SensorStorage {

	sql, err := repository.InitDB(config.MySQL.DSN())
	if err != nil {
		log.Error().Str("error", err.Error()).Msg("[StorageSensor.New.InitDB error]")
	}

	sqlRepo := repository.NewMysqlRepository(sql)

	windCache := repository.New[dbmodels.WindSpeed](config.Repository.CacheSize)
	tempCache := repository.New[dbmodels.Temperature](config.Repository.CacheSize)
	humidityCache := repository.New[dbmodels.Humidity](config.Repository.CacheSize)

	// fill cache from database
	if ts, err := sqlRepo.GetTemperature(context.Background(), int(config.Repository.CacheSize)); err == nil {
		for _, t := range ts {
			tempCache.Add(t)
		}
	}
	if hs, err := sqlRepo.GetHumidity(context.Background(), int(config.Repository.CacheSize)); err == nil {
		for _, h := range hs {
			humidityCache.Add(h)
		}
	}
	if ws, err := sqlRepo.GetWindSpeed(context.Background(), int(config.Repository.CacheSize)); err == nil {
		for _, w := range ws {
			windCache.Add(w)
		}
	}

	log.Info().
		Str("cache-size", fmt.Sprintf("Temp: %d | Humidity: %d | Wind: %d", tempCache.Size(), humidityCache.Size(), windCache.Size())).
		Msg("[onload.storage.SensorStorage] LocalCache loaded from database")

	return &SensorStorage{
		sqlRepo:          sqlRepo,
		windCache:        windCache,
		temperatureCache: tempCache,
		humidityCache:    humidityCache,
	}
}

func (s *SensorStorage) Close() {
	s.sqlRepo.Close()
}

func (s *SensorStorage) SaveWind(ctx context.Context, w dbmodels.WindSpeed) error {
	s.windCache.Add(w)
	err := s.sqlRepo.SaveWindSpeed(ctx, w)
	if err != nil {
		return fmt.Errorf("[SQL-ERROR] SensorStorage.SaveWin()->MySQLRepository.SaveWindSpeed(): %v\n", err)
	}
	return nil
}
func (s *SensorStorage) SaveTemperature(ctx context.Context, t dbmodels.Temperature) error {
	s.temperatureCache.Add(t)
	err := s.sqlRepo.SaveTemperature(ctx, t)
	if err != nil {
		return fmt.Errorf("[SQL-ERROR] SensorStorage.SaveTemperature()->MySQLRepository.SaveTemperature(): %v\n", err)
	}
	return nil
}
func (s *SensorStorage) SaveHumidity(ctx context.Context, h dbmodels.Humidity) error {
	s.humidityCache.Add(h)
	err := s.sqlRepo.SaveHumidity(ctx, h)
	if err != nil {
		return fmt.Errorf("[SQL-ERROR] SensorStorage.SaveHumidity()->MySQLRepository.SaveHumidity(): %v\n", err)
	}
	return nil
}

// GetWind returns slice of WindSpeed from cache or sql db
// count <= 0 returns all rows from db
// count > 0 && <= CacheSize returns `count` rows from cache
// >= CacheSize returns all rows from db
func (s *SensorStorage) GetWind(ctx context.Context, count int) ([]dbmodels.WindSpeed, error) {
	if count > 0 && count <= s.windCache.MaxSize() {
		return s.windCache.GetAll(), nil
	}
	return s.sqlRepo.GetWindSpeed(ctx, count)
}

// GetTemperature returns slice of Temperature from cache or sql db
// count <= 0 returns all rows from db
// count > 0 && <= CacheSize returns `count` rows from cache
// >= CacheSize returns all rows from db
func (s *SensorStorage) GetTemperature(ctx context.Context, count int) ([]dbmodels.Temperature, error) {
	if count > 0 && count <= s.temperatureCache.MaxSize() {
		return s.temperatureCache.GetAll(), nil
	}
	return s.sqlRepo.GetTemperature(ctx, count)
}

// GetHumidity returns slice of Humidity from cache or sql db
// count <= 0 returns all rows from db
// count > 0 && <= CacheSize returns `count` rows from cache
// >= CacheSize returns all rows from db
func (s *SensorStorage) GetHumidity(ctx context.Context, count int) ([]dbmodels.Humidity, error) {
	if count > 0 && count <= s.humidityCache.MaxSize() {
		return s.humidityCache.GetAll(), nil
	}
	return s.sqlRepo.GetHumidity(ctx, count)
}

// GetLastWind returns last WindSpeed from cache or sql db
func (s *SensorStorage) GetLastWind(ctx context.Context) (dbmodels.WindSpeed, error) {
	if w, err := s.windCache.GetLast(); err == nil {
		return w, nil
	}

	if ctx.Err() != nil {
		return dbmodels.WindSpeed{}, ctx.Err()
	}

	w, err := s.sqlRepo.GetWindSpeed(ctx, 1)
	if err != nil {
		log.Info().AnErr("error", err).Msg("[SensorStorage.GetLastWind -> SQL]")
		return dbmodels.WindSpeed{}, err
	}
	return w[0], nil
}

// GetLastTemperature returns last Temperature from cache or sql db
func (s *SensorStorage) GetLastTemperature(ctx context.Context) (dbmodels.Temperature, error) {
	if t, err := s.temperatureCache.GetLast(); err == nil {
		return t, nil
	}
	t, err := s.sqlRepo.GetTemperature(ctx, 1)
	if err != nil {
		log.Info().AnErr("error", err).Msg("[SensorStorage.GetLastTemperature -> SQL]")
		return dbmodels.Temperature{}, fmt.Errorf("Database is empty")
	}
	return t[0], nil
}

// GetLastHumidity returns last Humidity from cache or sql db
func (s *SensorStorage) GetLastHumidity(ctx context.Context) (dbmodels.Humidity, error) {
	if h, err := s.humidityCache.GetLast(); err == nil {
		return h, nil
	}
	h, err := s.sqlRepo.GetHumidity(ctx, 1)
	if err != nil {
		log.Info().AnErr("error", err).Msg("[SensorStorage.GetLastHumidity -> SQL]")
		return dbmodels.Humidity{}, fmt.Errorf("Database is empty")
	}
	return h[0], nil
}
