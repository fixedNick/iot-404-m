package mqtt

import (
	"context"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type QoS byte

const (
	QoS_LOW  QoS = 0
	QoS_MID  QoS = 1
	QoS_HIGH QoS = 2
)

type MQTTClient struct {
	host     string
	port     int
	clientID string
	client   mqtt.Client
	creds    *MQTTCredentials

	windRequests     map[uint64]chan Wind
	tempRequests     map[uint64]chan Temperature
	humidityRequests map[uint64]chan Humidity

	windMu     sync.RWMutex
	tempMu     sync.RWMutex
	humidityMu sync.RWMutex

	rid atomic.Uint64
}

func (m *MQTTClient) UniqueRequestID() uint64 {
	return m.rid.Add(1)
}
func (m *MQTTClient) GetWind(ctx context.Context) (Wind, error) {
	requestId := m.UniqueRequestID()

	m.windMu.Lock()
	windCh := make(chan Wind, 1)
	m.windRequests[requestId] = windCh
	m.windMu.Unlock()

	defer func(reqId uint64) {
		m.windMu.Lock()
		delete(m.windRequests, reqId)
		m.windMu.Unlock()
	}(requestId)

	NewRequest("GET", "wind", requestId).Publish(m, TopicControl, QoS_HIGH, false)

	select {
	case <-ctx.Done():
		return Wind{}, ctx.Err()
	case w := <-windCh:
		return w, nil
	}
}
func (m *MQTTClient) GetTemperature(ctx context.Context) (Temperature, error) {
	requestId := m.UniqueRequestID()

	m.tempMu.Lock()
	tempCh := make(chan Temperature, 1)
	m.tempRequests[requestId] = tempCh
	m.tempMu.Unlock()

	defer func(reqId uint64) {
		m.tempMu.Lock()
		delete(m.tempRequests, reqId)
		m.tempMu.Unlock()
	}(requestId)

	NewRequest("GET", SensorTemperature, requestId).Publish(m, TopicControl, QoS_HIGH, false)

	select {
	case <-ctx.Done():
		return Temperature{}, ctx.Err()
	case t := <-tempCh:
		return t, nil
	}
}
func (m *MQTTClient) GetHumidity(ctx context.Context) (Humidity, error) {
	requestId := m.UniqueRequestID()

	m.humidityMu.Lock()
	humidityChan := make(chan Humidity, 1)
	m.humidityRequests[requestId] = humidityChan
	m.humidityMu.Unlock()

	defer func(reqId uint64) {
		m.humidityMu.Lock()
		delete(m.humidityRequests, reqId)
		m.humidityMu.Unlock()
	}(requestId)

	NewRequest("GET", SensorHumidity, requestId).Publish(m, TopicControl, QoS_HIGH, false)

	select {
	case <-ctx.Done():
		return Humidity{}, ctx.Err()
	case h := <-humidityChan:
		return h, nil
	}
}

type MQTTCredentials struct {
	Username string
	Pwd      string
}

func NewMQTTClient(host string, port int, cid string, creds *MQTTCredentials) *MQTTClient {
	c := &MQTTClient{
		host:     host,
		port:     port,
		clientID: cid,
		creds:    creds,

		windRequests:     make(map[uint64]chan Wind),
		tempRequests:     make(map[uint64]chan Temperature),
		humidityRequests: make(map[uint64]chan Humidity),

		rid: atomic.Uint64{},

		windMu:     sync.RWMutex{},
		tempMu:     sync.RWMutex{},
		humidityMu: sync.RWMutex{},
	}

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

	return c
}

func (c *MQTTClient) Close() {
	c.client.Disconnect(250)
}

func (c *MQTTClient) onConnect(client mqtt.Client) {
	fmt.Println("Successfully connected to broker!")
	c.Publish("server/status", QoS_HIGH, true, fmt.Sprintf("%s: Connected", time.Now().Format(time.RFC3339)))
}

func (c *MQTTClient) onConnectionLost(client mqtt.Client, err error) {
	fmt.Println("Connection lost...")
}

func (c *MQTTClient) Publish(topic string, qos QoS, retained bool, payload any) {
	t := c.client.Publish(topic, byte(qos), retained, payload)
	t.Wait()
	if t.Error() != nil {
		fmt.Printf("Publish error: %v\n", t.Error())
		return
	}
	fmt.Printf("Publish OK in topic: %s <= [%s]\n", topic, payload)
}

func (c *MQTTClient) Subscribe(topic Topic, qos QoS, f func(client mqtt.Client, msg mqtt.Message)) {
	token := c.client.Subscribe(string(topic), byte(qos), f)
	token.Wait()
	if token.Error() != nil {
		fmt.Printf("Subscribe error: %v\n", token.Error())
		return
	}
	fmt.Printf("Subscribed on topic: %s\n", topic)
}
