package mqtt

import "encoding/json"

type Request struct {
	Command   string `json:"cmd"`
	Sensor    string `json:"sensor"`
	RequestID uint64 `json:"request_id"`
}

func NewRequest(command, sensor Sensor, rid uint64) Request {
	return Request{
		Command:   string(command),
		Sensor:    string(sensor),
		RequestID: rid,
	}
}

func (r Request) Publish(c *MQTTClient, topic Topic, qos QoS, retained bool) {

	bytes, err := json.Marshal(r)
	if err != nil {
		// TODO:
		// Handle error
		panic(err)
	}

	c.Publish(string(topic), qos, retained, bytes)
}
