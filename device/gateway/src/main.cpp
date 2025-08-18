#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <nRF24L01.h>
#include <RF24.h>
#include "config.h"
#include <ArduinoJson.h> // Thêm thư viện ArduinoJson
#include <SPI.h>

// RF
RF24 radio(4, 5); // CE, CSN
uint8_t nodeAddresses[][6] = {"1NODE", "2NODE", "3NODE", "4NODE", "5NODE"};
uint8_t gatewayAddress[6] = "GATWY";

WiFiClientSecure espClient;
PubSubClient client(espClient);

// Root CA (unchanged)
static const char *root_ca PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";

void setup_wifi()
{
  delay(10);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

// Function to send pump command to a node instantly
void sendCommand(uint8_t nodeId, const char *cmd)
{
  radio.stopListening(nodeAddresses[nodeId - 1]);
  bool ok = radio.write(cmd, strlen(cmd) + 1); // include '\0'
  Serial.println(ok ? "Transmission successful!" : "Transmission failed!");
  radio.startListening();
}

void callback(char *topic, byte *payload, unsigned int length)
{
  String t = topic;
  String cmd = String((char *)payload).substring(0, length);

  // Extract node ID from topic
  // smartgarden/area1/node/2/pump → nodeId = 2
  int start = t.indexOf("node/") + 5;
  int end = t.indexOf("/", start);
  int nodeId = t.substring(start, end).toInt();
  if (nodeId <= 0 || nodeId > 5)
  {
    Serial.printf("Invalid node ID: %d\n", nodeId);
    return;
  }
  else
  {
    Serial.printf("MQTT Command for Node %d: %s\n", nodeId, cmd.c_str());
    sendCommand(nodeId, cmd.c_str()); // Your RF24 send function
  }
}

void reconnect()
{
  while (!client.connected())
  {
    Serial.print("Attempting MQTT connection...");
    String clientId = DEVICE_ID + '-' + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str(), MQTT_USERNAME, MQTT_PASSWORD))
    {
      Serial.println("connected");
      client.subscribe(MQTT_TOPIC_PUMP);
      Serial.print("Subscribed to topics: ");
      Serial.println(MQTT_TOPIC_PUMP);
    }
    else
    {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup()
{
  Serial.begin(115200);
  while (!Serial)
    delay(1);
  Serial.println("Starting device...");

  setup_wifi();
  espClient.setCACert(root_ca);
  client.setServer(MQTT_SERVER, MQTT_PORT);
  client.setCallback(callback);
  reconnect();

  // Khởi tạo RF
  radio.begin();
  radio.setPALevel(RF24_PA_LOW);
  // radio.setDataRate(RF24_250KBPS);

  // Listen for data from any node
  for (uint8_t i = 0; i < 5; i++)
  {
    radio.openReadingPipe(i + 1, nodeAddresses[i]);
  }
  radio.startListening();
}

struct SensorData
{
  uint8_t node_id;
  float temperature;
  float humidity;
  uint16_t ldr;
  uint16_t soil;
};
SensorData sensor;
// int counter = 0; // for debugging

void loop()
{
  if (!client.connected())
  {
    reconnect();
  }
  client.loop();

  if (radio.available())
  {
    radio.read(&sensor, sizeof(sensor));
    // radio.read(&counter, sizeof(int));
    // Serial.print("Received packet number: ");
    // Serial.println(counter);
    Serial.print("Node ");
    Serial.print(sensor.node_id);
    Serial.print(": Temp=");
    Serial.print(sensor.temperature);
    Serial.print("C, Humidity=");
    Serial.print(sensor.humidity);
    Serial.print("%, LDR=");
    Serial.print(sensor.ldr);
    Serial.print(", Soil=");
    Serial.println(sensor.soil);

    // Publish sensor data to MQTT
    StaticJsonDocument<200> doc;
    doc["node_id"] = sensor.node_id;
    doc["temperature"] = sensor.temperature;
    doc["humidity"] = sensor.humidity;
    doc["ldr"] = sensor.ldr;
    doc["soil"] = sensor.soil;
    char jsonBuffer[256];
    serializeJson(doc, jsonBuffer);
    String topic = MQTT_TOPIC_DATA;
    topic.replace("+", String(sensor.node_id)); // Replace + with actual node ID
    if (client.publish(topic.c_str(), jsonBuffer))
    {
      Serial.print("Published to ");
      Serial.print(topic);
      Serial.print(": ");
      Serial.println(jsonBuffer);
    }
    else
    {
      Serial.println("Failed to publish data");
    }
  }
}