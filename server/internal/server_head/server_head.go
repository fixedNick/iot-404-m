package serverhead

import (
	"context"
	"errors"
	"fmt"
	"server/internal/domain/period"
	"server/internal/domain/sensors"
	"server/internal/mqtt"
	dbmodels "server/internal/storage/models"
	db "server/internal/storage/service"
	"server/pb"
	"sort"
	"sync"
	"time"

	"github.com/rs/zerolog/log"
	"google.golang.org/protobuf/types/known/timestamppb"
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

	mu *sync.RWMutex
}

func New(mqttClient *mqtt.MQTTClient, storage *db.SensorStorage) *ServerHead {
	return &ServerHead{mqtt: mqttClient, storage: storage, mu: &sync.RWMutex{}}
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
	location := time.FixedZone("GMT+3", 3*3600)
	now := time.Now().In(location)
	var from, to time.Time
	todayStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, location)
	if offset > 0 {
		offset = -offset
	}
	switch p {
	case period.Day:
		if offset == 0 {
			from = todayStart
			to = now // Для текущего дня верхняя граница — "сейчас"
		} else {
			from = todayStart.AddDate(0, 0, offset)
			to = from.AddDate(0, 0, 1) // Ровно начало следующего дня (замена 23:59:59)
		}

	case period.Week:
		if offset == 0 {
			from = todayStart.AddDate(0, 0, -6)
			to = now
		} else {
			to = todayStart.AddDate(0, 0, (offset*7)+1)
			from = to.AddDate(0, 0, -7)
		}

	case period.Month:
		if offset == 0 {
			from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, location)
			to = now
		} else {
			from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, location).AddDate(0, offset, 0)
			to = from.AddDate(0, 1, 0) // Начало следующего месяца
		}
	}
	fmt.Println("From:", from, "\nTo:", to)
	log.Info().Str("in", "ServerHead.GetSensorStats").Time("from", from).Time("to", to)

	switch sensor {
	case sensors.WindSpeed:
		ws, err := s.storage.GetWindSpeedForPeriod(ctx, from, to)
		if p == period.Day {
			dp := make([]*pb.DayDataPoint, 0, len(ws))
			for _, w := range ws {
				dp = append(dp, &pb.DayDataPoint{Value: float64(w.Speed), Timestamp: timestamppb.New(time.Unix(w.Time, 0))})
			}
			return &pb.GetSensorStatsResponse{
				DayData: dp,
			}, err
		}
		raw := make([]rawPoint, len(ws))
		for i, w := range ws {
			raw[i] = rawPoint{Time: w.Time, Value: float64(w.Speed)}
		}
		return &pb.GetSensorStatsResponse{
			AggregatedData: aggregateByDay(raw),
		}, nil
	case sensors.Temperature:
		ts, err := s.storage.GetTemperatureForPeriod(ctx, from, to)
		if p == period.Day {
			dp := make([]*pb.DayDataPoint, 0, len(ts))
			for _, t := range ts {
				dp = append(dp, &pb.DayDataPoint{Value: float64(t.Temperature), Timestamp: timestamppb.New(time.Unix(t.Time, 0))})
			}
			return &pb.GetSensorStatsResponse{
				DayData: dp,
			}, err
		}
		raw := make([]rawPoint, len(ts))
		for i, t := range ts {
			raw[i] = rawPoint{Time: t.Time, Value: float64(t.Temperature)}
		}
		return &pb.GetSensorStatsResponse{
			AggregatedData: aggregateByDay(raw),
		}, nil
	case sensors.Humidity:
		hs, err := s.storage.GetHumidityForPeriod(ctx, from, to)
		if p == period.Day {
			dp := make([]*pb.DayDataPoint, 0, len(hs))
			for _, h := range hs {
				dp = append(dp, &pb.DayDataPoint{Value: float64(h.Humidity), Timestamp: timestamppb.New(time.Unix(h.Time, 0))})
			}
			return &pb.GetSensorStatsResponse{
				DayData: dp,
			}, err
		}
		raw := make([]rawPoint, len(hs))
		for i, h := range hs {
			raw[i] = rawPoint{Time: h.Time, Value: float64(h.Humidity)}
		}
		return &pb.GetSensorStatsResponse{
			AggregatedData: aggregateByDay(raw),
		}, nil
	}
	return nil, fmt.Errorf("uncaught error on GetSensorStats")
}

type rawPoint struct {
	Time  int64
	Value float64
}

func aggregateByDay(points []rawPoint) []*pb.AggregatedDataPoint {
	if len(points) == 0 {
		return nil
	}

	// Промежуточная структура для сбора метрик за конкретные сутки
	type dayStats struct {
		midnight time.Time
		min      float64
		max      float64
		sum      float64
		count    int
	}

	// Группируем по строковому ключу "YYYY-MM-DD"
	groups := make(map[string]*dayStats)

	for _, p := range points {
		t := time.Unix(p.Time, 0).Local()

		// Получаем полночь для этих суток
		midnight := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
		dayKey := midnight.Format("2006-01-02")

		stats, exists := groups[dayKey]
		if !exists {
			stats = &dayStats{
				midnight: midnight,
				min:      p.Value,
				max:      p.Value,
			}
			groups[dayKey] = stats
		}

		if p.Value < stats.min {
			stats.min = p.Value
		}
		if p.Value > stats.max {
			stats.max = p.Value
		}
		stats.sum += p.Value
		stats.count++
	}

	// Превращаем карту в упорядоченный или просто плоский слайс Protobuf-структур
	result := make([]*pb.AggregatedDataPoint, 0, len(groups))
	for _, stats := range groups {
		result = append(result, &pb.AggregatedDataPoint{
			Date: timestamppb.New(stats.midnight),
			Min:  stats.min,
			Max:  stats.max,
			Avg:  stats.sum / float64(stats.count),
		})
	}

	sort.Slice(result, func(i, j int) bool {
		return result[i].Date.AsTime().Before(result[j].Date.AsTime())
	})

	return result
}
