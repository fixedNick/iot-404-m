package sensors

type Sensor string

const (
	WindSpeed   Sensor = "wind_speed"
	Temperature Sensor = "temperature"
	Humidity    Sensor = "humidity"
)

func (s Sensor) SQLName() string {
	switch s {
	case WindSpeed:
		return "wind_speed"
	case Temperature:
		return "temperature"
	case Humidity:
		return "humidity"
	default:
		panic("Unknown sensor")
	}
}

func FromString(sensor_name string) Sensor {
	switch sensor_name {
	case "wind_speed":
		return WindSpeed
	case "temperature":
		return Temperature
	case "humidity":
		return Humidity
	default:
		panic("Unknown sensor")
	}
}
