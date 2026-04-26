package domain

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Local     LocalConfig  `yaml:"Local"`
	EspServer RemoteConfig `yaml:"EspServer"`
}

type LocalConfig struct {
	Port int `yaml:"Port"`
}

type RemoteConfig struct {
	Host string `yaml:"Host"`
	Port int    `yaml:"Port"`
}

func MustLoadConfig(path string) *Config {
	if _, err := os.Stat(path); err != nil {
		panic(err)
	}

	fc, err := os.ReadFile(path)
	if err != nil {
		panic(err)
	}

	cfg := Config{}

	err = yaml.Unmarshal(fc, &cfg)
	if err != nil {
		panic(err)
	}

	return &cfg
}
