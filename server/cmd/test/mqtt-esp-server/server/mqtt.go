package mqttespserver

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"os"
	cfg "server/internal/config"
	"server/internal/mqtt"
	"time"

	kmqtt "github.com/eclipse/paho.mqtt.golang"
)

type ESPServer struct {
	c   *mqtt.MQTTClient
	log chan string
	cfg *MockConfig
}

type MockConfig struct {
	MinDelay int // ms
	MaxDelay int // ms
	LogFile  string
}

func New(config *cfg.Config, mockConfig *MockConfig) *ESPServer {

	c := mqtt.NewMQTTClient(config.MQTT.Host, config.MQTT.Port, fmt.Sprintf("go-mock-%d", time.Now().Unix()), nil)
	e := &ESPServer{
		c:   c,
		log: make(chan string, 10),
		cfg: mockConfig,
	}

	// log
	if _, err := os.Stat("./logs/" + mockConfig.LogFile); err == nil {
		os.Remove("./logs/" + mockConfig.LogFile)
	}
	//

	go c.SetupSubsribes(
		func(m *mqtt.MQTTClient) {
			m.Subscribe("sensors/control", mqtt.QoS_HIGH, func(client kmqtt.Client, msg kmqtt.Message) {
				go func() {
					delay := mockConfig.MinDelay + rand.Intn(mockConfig.MaxDelay-mockConfig.MinDelay)
					e.Log(fmt.Sprintf("<=[Delay: %dms] callback sub: sensor/data. Recv msg: %s.\n", delay, string(msg.Payload())))
					time.Sleep(time.Duration(delay) * time.Millisecond)
					cmd := mqtt.Request{}
					err := json.Unmarshal(msg.Payload(), &cmd)
					if err != nil {
						panic(err)
					}

					if cmd.Command != "GET" {
						log.Fatalf("Unknown command, %v", cmd)
					}

					switch cmd.Sensor {
					case "wind":
						w := mqtt.Wind{
							Speed:     rand.Float32()*10 + 10*3,
							Voltage:   rand.Float32()*7 + 5*3,
							RequestId: cmd.RequestID,
						}

						bytes, err := json.Marshal(w)
						if err != nil {
							log.Fatalf("json marshaling error: %v", err)
						}

						e.Log(fmt.Sprintf("=> pub: sensor/data/wind. Data: %s.\n", bytes))
						m.Publish("sensors/data/wind", mqtt.QoS_HIGH, false, bytes)
					case "humidity":
						h := mqtt.Humidity{
							Humidity:  rand.Float32() * 10 * 7,
							RequestId: cmd.RequestID,
						}

						bytes, err := json.Marshal(h)
						if err != nil {
							log.Fatalf("json marshaling error: %v", err)
						}

						e.Log(fmt.Sprintf("=> pub: sensor/data/humidity. Data: %s.\n", bytes))
						m.Publish("sensors/data/humidity", mqtt.QoS_HIGH, false, bytes)
					case "temperature":
						t := mqtt.Temperature{
							Temperature: rand.Float32() * 10 * 4.5,
							RequestId:   cmd.RequestID,
						}

						bytes, err := json.Marshal(t)
						if err != nil {
							log.Fatalf("json marshaling error: %v", err)
						}
						e.Log(fmt.Sprintf("=> pub: sensor/data/temperature. Data: %s.\n", bytes))
						m.Publish("sensors/data/temperature", mqtt.QoS_HIGH, false, bytes)
					}
				}()
			})
		},
	)

	e.Log("Started")
	go e.Logging()
	return e
}
func (e *ESPServer) Log(msg string) {
	select {
	case <-time.After(5 * time.Second):
		panic("Write to file timeout 5s")
	case e.log <- msg:
	}
}

func (e *ESPServer) Stop() {
	e.c.Close()
	close(e.log)
}
func (e *ESPServer) Logging() {
	fd, err := os.OpenFile(
		fmt.Sprintf("./logs/%s", e.cfg.LogFile),
		os.O_APPEND|os.O_CREATE|os.O_WRONLY,
		0644,
	)
	if err != nil {
		panic(err)
	}

	for msg := range e.log {
		fmt.Fprintf(fd, "[%s] %s", time.Now().Format(time.RFC3339), msg)
	}
	defer fd.Close()
}
