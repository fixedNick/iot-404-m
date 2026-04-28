package mqtt

import (
	"encoding/json"
	"fmt"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func (m *MQTTClient) SetupSubsribes(subsribes ...func(*MQTTClient)) {
	go func() {
		for _, sub := range subsribes {
			go sub(m)
		}
	}()
}

func SuscribeWindSpeed(m *MQTTClient) {
	m.Subscribe("sensors/data/wind", QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		w := Wind{}
		json.Unmarshal(msg.Payload(), &w)
		fmt.Printf("Callback: sensors/data/wind. Recv: %v.\n", w)
		m.wind <- w
	})
}

func SuscribeTemperature(m *MQTTClient) {
	m.Subscribe("sensors/data/temperature", QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		t := Temperature{}
		json.Unmarshal(msg.Payload(), &t)
		fmt.Printf("Callback: sensors/data/wind. Recv: %v.\n", t)
		m.temp <- t
	})
}

func SuscribeHumidity(m *MQTTClient) {
	m.Subscribe("sensors/data/humidity", QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		h := Humidity{}
		json.Unmarshal(msg.Payload(), &h)
		fmt.Printf("Callback: sensors/data/wind. Recv: %v.\n", h)
		m.humidity <- h
	})
}
