package main

import (
	"os"
	"os/signal"
	mqttespserver "server/cmd/test/mqtt-esp-server/server"
	cfg "server/internal/config"
	"syscall"

	"github.com/joho/godotenv"
)

func main() {

	godotenv.Load([]string{"../env/test/.env.go.app", "../env/test/.env.db"}...)
	s := mqttespserver.New(cfg.MustLoadConfig(), &mqttespserver.MockConfig{
		MinDelay: 500,
		MaxDelay: 1500,
		LogFile:  "mqtt-esp-server.log",
	})

	term := make(chan os.Signal, 1)
	signal.Notify(term, os.Interrupt, syscall.SIGTERM)
	<-term

	s.Stop()
}
