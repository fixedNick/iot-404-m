package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	cfg "server/internal/config"
	"server/internal/grpc"
	"server/internal/mqtt"
	serverhead "server/internal/server_head"
	db "server/internal/storage/service"
	"syscall"
	"time"
)

func main() {
	config := cfg.MustLoadConfig()

	mqttClient := mqtt.NewMQTTClient(config.MQTT.Host, config.MQTT.Port, fmt.Sprintf("go-%d", time.Now().Unix()), nil)
	storage := db.New(config)
	serverHead := serverhead.New(mqttClient, storage)

	gs := grpc.NewGRPCServer(config, serverHead)
	mqttClient.SetupSubsribes(
		mqtt.SuscribeHumidity,
		mqtt.SuscribeWindSpeed,
		mqtt.SuscribeTemperature,
	)

	gs.Run()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	gs.Stop()
	mqttClient.Close()
	storage.Close()

	log.Println("Server successfully stopped")
}
