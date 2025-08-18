import mqtt from "mqtt";
import SensorReading from "../models/SensorReading.js";
import NodeMeta from "../models/NodeMeta.js";
import { getIO } from "../serverApp.js";

let client;

export function initMqtt({
  url,
  port = 8883,
  username,
  password,
  topicData,
  tls = {}
}) {
  const mqttOptions = {
    host: url,
    port: port,
    protocol: 'mqtts',
    // ca: process.env.MQTT_BROKER_CA,
    rejectUnauthorized: true,
    username: username || undefined,
    password: password || undefined,
    // cert: process.env.MQTT_BROKER_CLIENT_CERT,      // Client Certificate
    // key: process.env.MQTT_BROKER_CLIENT_KEY,       //
    ...tls
  };


  client = mqtt.connect(mqttOptions);

  client.on("connect", () => {
    console.log("[MQTT] Connected to", url);
    if (topicData) {
      client.subscribe(topicData, (err) => {
        if (err) console.error("[MQTT] Subscribe error:", err.message);
        else console.log("[MQTT] Subscribed to", topicData);
      });
    }
  });

  client.on("reconnect", () => console.log("[MQTT] Reconnecting..."));
  client.on("error", (err) => console.error("[MQTT] Error:", err.message));

  client.on("message", async (topic, payload) => {
    try {
      const msg = payload.toString();
      const data = JSON.parse(msg);

      // Expect topic: smartgarden/area1/node/{id}/sensors
      const parts = topic.split("/");
      const nodeIndex = parts.indexOf("node");
      const nodeId = nodeIndex >= 0 ? Number(parts[nodeIndex + 1]) : Number(data.node_id);

      console.log("[MQTT] Received topic: ", topic);
      console.log("[MQTT] Received data: ", data);

      const reading = await SensorReading.create({
        node_id: nodeId,
        temperature: data.temperature,
        humidity: data.humidity,
        ldr: data.ldr,
        soil: data.soil,
        raw: data
      });

      // Update lastSeenAt
      await NodeMeta.findOneAndUpdate(
        { node_id: nodeId },
        { node_id: nodeId, lastSeenAt: new Date() },
        { upsert: true, new: true }
      );

      console.log("[MQTT] Saved reading for node", nodeId, reading._id.toString());

      // Emit socket.io event
      const io = getIO();
      io.emit("reading", {
        node_id: nodeId,
        temperature: data.temperature,
        humidity: data.humidity,
        ldr: data.ldr,
        soil: data.soil,
        createdAt: reading.createdAt
      });
    } catch (e) {
      console.error("[MQTT] Invalid payload:", e.message);
    }
  });

  return client;
}

export function publish(topic, message, options = {}) {
  if (!client) throw new Error("MQTT client not initialized");
  return new Promise((resolve, reject) => {
    client.publish(topic, message, options, (err) => {
      if (err) return reject(err);
      resolve();
    });
  });
}
