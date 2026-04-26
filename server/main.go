package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"server/domain"
	"syscall"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func main() {
	storage := domain.NewStorage()

	mqttClient := domain.NewMQTTClient("176.109.106.237", 1883, fmt.Sprintf("go-%d", time.Now().Unix()), nil)
	defer mqttClient.Disconnect()

	gs := domain.NewGRPCServer(
		domain.MustLoadConfig("config/cfg.yaml"),
		storage,
		mqttClient,
	)

	go func() {
		mqttClient.Run()
		go mqttClient.Subscribe("sensors/data/wind", domain.QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
			type Wind struct {
				Voltage float64 `json:"voltage"`
				Speed   float64 `json:"speed"`
			}

			w := Wind{}
			json.Unmarshal(msg.Payload(), &w)
			err := storage.Save(domain.NewIndication(w.Voltage, w.Speed, time.Now()))
			if err != nil {
				fmt.Printf("[error] Save err: %v. Received: %v", err, w)
				return
			}
			fmt.Printf("Saved %v.\n-----------------\n", w)
			mqttClient.Sync <- struct{}{}
		})
		go mqttClient.Subscribe("sensors/data/temperature", domain.QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
			msg.Payload()
		})
		go mqttClient.Subscribe("sensors/data/humidity", domain.QoS_HIGH, func(client mqtt.Client, msg mqtt.Message) {
			msg.Payload()
		})
	}()
	go gs.Run()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	close(mqttClient.Sync)

	gs.Stop()
	log.Println("Server successfully stopped")
}
