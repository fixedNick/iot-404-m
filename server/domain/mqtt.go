package domain

import (
	"fmt"
	"os"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

const (
	QoS_LOW  = 0
	QoS_MID  = 1
	QoS_HIGH = 2
)

type MQTTClient struct {
	host     string
	port     int
	clientID string
	client   mqtt.Client
	creds    *MQTTCredentials
	Sync     chan struct{}
}

type MQTTCredentials struct {
	Username string
	Pwd      string
}

func NewMQTTClient(host string, port int, cid string, creds *MQTTCredentials) *MQTTClient {
	return &MQTTClient{
		host:     host,
		port:     port,
		clientID: cid,
		creds:    creds,
		Sync:     make(chan struct{}),
	}
}

func (c *MQTTClient) Run() {
	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("%s:%d", c.host, c.port))
	opts.SetClientID(c.clientID)
	if c.creds != nil {
		opts.SetUsername(c.creds.Username)
		opts.SetPassword(c.creds.Pwd)
	}
	opts.OnConnect = c.onConnect
	opts.OnConnectionLost = c.onConnectionLost

	opts.WillEnabled = true
	opts.WillPayload = []byte("Disconnected")
	opts.WillQos = 1
	opts.WillRetained = true
	opts.WillTopic = "server/status"

	fmt.Printf("mqtt connecting: %s:%d\n", c.host, c.port)
	c.client = mqtt.NewClient(opts)
	if token := c.client.Connect(); token.Wait() && token.Error() != nil {
		fmt.Printf("Connection error: %s\n", token.Error())
		os.Exit(1)
	}
}

func (c *MQTTClient) Disconnect() {
	c.client.Disconnect(250)
}

func (c *MQTTClient) onConnect(client mqtt.Client) {
	fmt.Println("Successfully connected to broker!")
	c.Publish("server/status", QoS_HIGH, true, fmt.Sprintf("%s: Connected", time.Now().Format(time.RFC3339)))
}

func (c *MQTTClient) onConnectionLost(client mqtt.Client, err error) {
	fmt.Println("Connection lost...")
}

func (c *MQTTClient) Publish(topic string, qos byte, retained bool, payload any) {
	t := c.client.Publish(topic, qos, retained, payload)
	t.Wait()
	if t.Error() != nil {
		fmt.Printf("Publish error: %v\n", t.Error())
		return
	}
	fmt.Printf("Publish OK in topic: %s <= [%s]\n", topic, payload)
}

func (c *MQTTClient) Subscribe(topic string, qos byte, f func(client mqtt.Client, msg mqtt.Message)) {
	token := c.client.Subscribe(topic, qos, f)
	token.Wait()
	if token.Error() != nil {
		fmt.Printf("Subscribe error: %v\n", token.Error())
		return
	}
	fmt.Printf("Subscribed on topic: %s\n", topic)
}
