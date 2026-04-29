package mqtt

import (
	dbmodels "server/internal/storage/models"
	"time"
)

type Wind struct {
	Voltage   float32 `json:"voltage"`
	Speed     float32 `json:"speed"`
	RequestId uint64  `json:"request_id"`
}

type Humidity struct {
	Humidity  float32 `json:"humidity"`
	RequestId uint64  `json:"request_id"`
}

type Temperature struct {
	Temperature float32 `json:"temperature"`
	RequestId   uint64  `json:"request_id"`
}

func (w Wind) ToSQLModel(t time.Time) dbmodels.WindSpeed {
	return dbmodels.WindSpeed{
		Voltage: w.Voltage,
		Speed:   w.Speed,
		Time:    t.Unix(),
	}
}
func (h Humidity) ToSQLModel(t time.Time) dbmodels.Humidity {
	return dbmodels.Humidity{
		Humidity: h.Humidity,
		Time:     t.Unix(),
	}
}

func (temp Temperature) ToSQLModel(t time.Time) dbmodels.Temperature {
	return dbmodels.Temperature{
		Temperature: temp.Temperature,
		Time:        t.Unix(),
	}
}
