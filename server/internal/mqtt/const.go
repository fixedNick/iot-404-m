package mqtt

// Topics

type Topic string

const (
	TopicControl     Topic = "sensors/control"
	TopicWindSpeed   Topic = "sensors/data/wind"
	TopicTemperature Topic = "sensors/data/temperature"
	TopicHumidity    Topic = "sensors/data/humidity"
)

// Sensors

type Sensor string

const (
	SensorTemperature Sensor = "temperature"
	SensorWind        Sensor = "wind"
	SensorHumidity    Sensor = "humidity"
)
