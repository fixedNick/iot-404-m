package integration_test

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand/v2"
	"os"
	"os/signal"
	cfg "server/internal/config"
	"server/internal/grpc"
	"server/internal/mqtt"
	serverhead "server/internal/server_head"
	db "server/internal/storage/service"
	"syscall"
	"time"

	vmqtt "github.com/eclipse/paho.mqtt.golang"
)

func RunDependencies(config *cfg.Config) (*mqtt.MQTTClient, *grpc.GRPCServer, *db.SensorStorage) {

	mqttClient := mqtt.NewMQTTClient(config.MQTT.Host, config.MQTT.Port, fmt.Sprintf("go-%d", time.Now().Unix()), nil)
	storage := db.New(config)
	serverHead := serverhead.New(mqttClient, storage)

	gs := grpc.NewGRPCServer(config, serverHead)
	mqttClient.SetupSubsribes(
		mqtt.SuscribeHumidity,
		mqtt.SuscribeTemperature,
		mqtt.SuscribeWindSpeed,
	)

	gs.Run()

	return mqttClient, gs, storage
}

func Test_FullFlow_WindGet() {
	config := cfg.MustLoadConfig()

	mqttClient, gs, storage := RunDependencies(config)

	// Client calls GRPC -> API GRPC -> MQTT Client Publish -> MQTT Client Callback(receive from IoT) -> Save into STORAGE -> GRPC Response

	e := ESPEmulator{}
	e.InitWind(&config.MQTT)

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	gs.Stop()
	mqttClient.Close()
	storage.Close()

	log.Println("Server successfully stopped")
}

type ESPEmulator struct {
	mqttClient *mqtt.MQTTClient
	Published  chan mqtt.Wind
}

func (e *ESPEmulator) InitWind(mqttCfg *cfg.MQTTConfig) {
	e.Published = make(chan mqtt.Wind, 1024)
	e.mqttClient = mqtt.NewMQTTClient(mqttCfg.Host, mqttCfg.Port, fmt.Sprintf("go-test-%d", time.Now().Unix()), nil)

	e.mqttClient.Subscribe("sensors/control", mqtt.QoS_HIGH, func(client vmqtt.Client, msg vmqtt.Message) {

		type c struct {
			Cmd    string `json:"cmd"`
			Sensor string `json:"sensor"`
		}

		cmd := c{}
		err := json.Unmarshal(msg.Payload(), &cmd)
		if err != nil {
			panic(err)
		}
		w := mqtt.Wind{
			Voltage: (rand.Float32() * 10) + 5,
			Speed:   (rand.Float32() * 30) + 8,
		}

		bytes, err := json.Marshal(w)
		if err != nil {
			panic(err)
		}

		e.mqttClient.Publish("sensors/data/wind", mqtt.QoS_HIGH, false, bytes)
		e.Published <- w
	})
}
