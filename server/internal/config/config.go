package cfg

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	GRPC       GRPCConfig       `yaml:"Local"`
	MySQL      MySQLConfig      `yaml:"MySQL"`
	MQTT       MQTTConfig       `yaml:"MQTT"`
	Repository RepositoryCofnig `yaml:"Repository"`
}

type GRPCConfig struct {
	Port int `yaml:"Port"`
	// request - response timeout in milliseconds
	Timeout uint `yaml:"Timeout"`
}
type RepositoryCofnig struct {
	CacheSize uint `yaml:"CacheLimit"`
}

type MQTTConfig struct {
	Host string `yaml:"Host"`
	Port int    `yaml:"Port"`
}

type MySQLConfig struct {
	Host     string `yaml:"Host"`
	Port     int    `yaml:"Port"`
	User     string `yaml:"User"`
	Password string `yaml:"Password"`
	Database string `yaml:"Database"`
}

func (m MySQLConfig) DSN() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", m.User, m.Password, m.Host, m.Port, m.Database)
}

func MustLoadConfig() *Config {
	cfg := Config{}

	var err error
	// grpc

	if cfg.GRPC.Port, err = strconv.Atoi(os.Getenv("GRPC_PORT")); err != nil {
		panic(fmt.Sprintf("Failed to parse env GRPC_PORT: %v", err))
	}

	timeout, err := strconv.ParseUint(os.Getenv("GRPC_TIMEOUT"), 10, 32)
	if err != nil {
		panic(fmt.Sprintf("Failed to parse env GRPC_TIMEOUT: %v", err))
	}

	cfg.GRPC.Timeout = uint(timeout)

	// sql

	cfg.MySQL.Database = os.Getenv("MYSQL_DATABASE")
	if cfg.MySQL.Database == "" {
		panic("Required env MYSQL_DATABASE is not set")
	}

	cfg.MySQL.Host = os.Getenv("MYSQL_HOST")
	if cfg.MySQL.Host == "" {
		panic("Required env MYSQL_HOST is not set")
	}

	cfg.MySQL.User = os.Getenv("MYSQL_USER")
	if cfg.MySQL.User == "" {
		panic("Required env MYSQL_USER is not set")
	}

	cfg.MySQL.Password = os.Getenv("MYSQL_ROOT_PASSWORD")
	if cfg.MySQL.Password == "" {
		panic("Required env MYSQL_PASSWORD is not set")
	}

	// mqtt

	cfg.MQTT.Host = os.Getenv("MQTT_HOST")
	if cfg.MQTT.Host == "" {
		panic("Required env MQTT_HOST is not set")
	}

	cfg.MQTT.Port, err = strconv.Atoi(os.Getenv("MQTT_PORT"))
	if err != nil || cfg.MQTT.Port == 0 {
		panic(fmt.Sprintf("Failed to parse env MQTT_PORT: %v", err))
	}

	// cache

	cs, err := strconv.Atoi(os.Getenv("CACHE_SIZE"))
	if err != nil {
		panic(fmt.Sprintf("Failed to parse env CACHE_SIZE: %v", err))
	}

	if cs <= 0 {
		panic("Required env CACHE_SIZE is not set. Must be greater than 0")
	}

	cfg.Repository.CacheSize = uint(cs)

	return &cfg
}
