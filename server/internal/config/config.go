package cfg

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	GRPC  GRPCConfig  `yaml:"Local"`
	MySQL MySQLConfig `yaml:"MySQL"`
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

type GRPCConfig struct {
	Port int `yaml:"Port"`
}

func MustLoadConfig(path string) *Config {
	cfg := Config{}

	var err error
	if cfg.GRPC.Port, err = strconv.Atoi(os.Getenv("GRPC_PORT")); err != nil {
		panic(fmt.Sprintf("Failed to parse env GRPC_PORT: %v", err))
	}

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

	return &cfg
}
