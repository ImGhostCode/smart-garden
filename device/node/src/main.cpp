#include <DHT.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <SPI.h>
#include <Wire.h>

#define DHT_PIN PA0
#define LDR_PIN PA1
#define SOIL_PIN PA2
#define RELAY_PIN PA3
#define DHT_TYPE DHT11
uint8_t node_id = 1;

DHT dht(DHT_PIN, DHT_TYPE);
RF24 radio(PB0, PA4);             // CE, CSN
uint8_t nodeAddress[6] = "1NODE"; // unique per node

struct SensorData
{
  uint8_t node_id;   // 1 byte
  float temperature; // 4 bytes
  float humidity;    // 4 bytes
  uint16_t ldr;      // 2 bytes
  uint16_t soil;     // 2 bytes
};

SensorData data;
char command[8]; // "ON" / "OFF"
unsigned long lastSend = 0;
const unsigned long sendInterval = 15000; // send data every 5s
// int counter = 0;                         // for debugging

void setup()
{
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW);
  dht.begin();

  // Khởi tạo SPI và RF
  // SPI.begin();
  radio.begin();
  radio.setPALevel(RF24_PA_LOW);
  // radio.setDataRate(RF24_250KBPS);
  radio.openReadingPipe(1, nodeAddress);
  radio.startListening();
}

void loop()
{
  // 1. Check for commands from gateway
  if (radio.available())
  {
    radio.read(&command, sizeof(command));
    Serial.print("Command: ");
    Serial.println(command);
    if (strcmp(command, "ON") == 0)
    {
      digitalWrite(RELAY_PIN, HIGH);
    }
    else if (strcmp(command, "OFF") == 0)
    {
      digitalWrite(RELAY_PIN, LOW);
    }
  }

  // 2. Periodically send sensor data
  if (millis() - lastSend >= sendInterval)
  {
    lastSend = millis();

    // Gather data
    data.node_id = node_id; // change for each node
    data.temperature = dht.readTemperature();
    data.humidity = dht.readHumidity();
    data.ldr = analogRead(LDR_PIN);
    data.soil = analogRead(SOIL_PIN);

    // Switch to TX mode
    radio.stopListening(nodeAddress);
    bool ok = radio.write(&data, sizeof(SensorData));
    Serial.println(ok ? "Transmission successful!" : "Transmission failed!");

    // Back to RX mode
    radio.startListening();
  }
}