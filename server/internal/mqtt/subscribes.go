package mqtt

import (
	"encoding/json"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/rs/zerolog/log"
)

func (m *MQTTClient) SetupSubsribes(subsribes ...func(*MQTTClient)) {
	for _, sub := range subsribes {
		go sub(m)
	}
}

func SuscribeWindSpeed(m *MQTTClient) {
	m.Subscribe(TopicWindSpeed, QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		go func() {
			w := Wind{}
			err := json.Unmarshal(msg.Payload(), &w)
			if err != nil {
				log.Error().
					Str("payload:", string(msg.Payload())).
					Str("error:", err.Error()).
					Msg("[mqtt.callback.WindSpeed] Json unmarshal error")
				return
			}

			m.windMu.RLock()
			windChan, ok := m.windRequests[w.RequestId]
			m.windMu.RUnlock()
			if !ok {
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.WindSpeed] Channel already deleted for this request_id")
				return
			}

			select {
			case windChan <- w:
			default:
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.WindSpeed] Received response, but channel not empty. Possible duplicate request")
			}
		}()
	})
}

func SuscribeTemperature(m *MQTTClient) {
	m.Subscribe(TopicTemperature, QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		go func() {
			t := Temperature{}
			err := json.Unmarshal(msg.Payload(), &t)
			if err != nil {
				log.Error().
					Str("payload:", string(msg.Payload())).
					Str("error:", err.Error()).
					Msg("[mqtt.callback.Temperature] Json unmarshal error")
				return
			}

			m.windMu.RLock()
			tempChan, ok := m.tempRequests[t.RequestId]
			m.windMu.RUnlock()
			if !ok {
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.Temperature] Channel already deleted for this request_id")
				return
			}

			select {
			case tempChan <- t:
			default:
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.Temperature] Received response, but channel not empty. Possible duplicate request")
			}

		}()
	})
}

func SuscribeHumidity(m *MQTTClient) {
	m.Subscribe(TopicHumidity, QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
		go func() {
			h := Humidity{}
			err := json.Unmarshal(msg.Payload(), &h)
			if err != nil {
				log.Error().
					Str("payload:", string(msg.Payload())).
					Str("error:", err.Error()).
					Msg("[mqtt.callback.Humidity] Json unmarshal error")
				return
			}

			m.humidityMu.RLock()
			humidityChan, ok := m.humidityRequests[h.RequestId]
			m.humidityMu.RUnlock()
			if !ok {
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.Humidity] Channel already deleted for this request_id")
				return
			}

			select {
			case humidityChan <- h:
			default:
				log.Warn().
					Str("payload", string(msg.Payload())).
					Msg("[mqtt.callback.Humidity] Received response, but channel not empty. Possible duplicate request")
			}

		}()
	})
}
