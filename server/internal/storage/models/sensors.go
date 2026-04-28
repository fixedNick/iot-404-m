package dbmodels

type SensorType string

const (
	WindSpeedType   SensorType = "wind_speed"
	TemperatureType SensorType = "temperature"
	HumidityType    SensorType = "humidity"
)

type WindSpeed struct {
	Voltage float32 `json:"voltage"`
	Speed   float32 `json:"speed"`
	Time    int64   `json:"time"`
}

type Temperature struct {
	Temperature float32 `json:"temperature"`
	Time        int64   `json:"time"`
}

type Humidity struct {
	Humidity float32 `json:"humidity"`
	Time     int64   `json:"time"`
}

type LogItem interface {
	WindSpeed | Temperature | Humidity
}
