import "dotenv/config.js";
import express from "express";
import helmet from "helmet";
import cors from "cors";
import { httpLogger } from "./utils/logger.js";
import { connectDB } from "./services/db.js";
import apiRoutes from "./routes/api.js";
import { initMqtt } from "./services/mqttClient.js";
import { Server as SocketIOServer } from "socket.io";
import http from "http";
import { setIO } from "./serverApp.js";

const app = express();

// Middleware
app.use(helmet());
app.use(cors({ origin: process.env.ORIGIN || "*" }));
app.use(express.json({ limit: "1mb" }));
app.use(httpLogger);

// Routes
app.use("/api", apiRoutes);

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || "Internal Server Error" });
});

// Boot
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

const MQTT_URL = process.env.MQTT_URL;
const MQTT_PORT = process.env.MQTT_PORT || 8883;
const MQTT_TOPIC_DATA = process.env.MQTT_TOPIC_DATA || "smartgarden/area1/node/+/sensors";

async function start() {
  await connectDB(MONGO_URI);
  initMqtt({
    url: MQTT_URL,
    port: MQTT_PORT,
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD,
    topicData: MQTT_TOPIC_DATA
    // For TLS: pass tls: { ca: fs.readFileSync(...), cert: ..., key: ... }
  });

  const server = http.createServer(app);
  const io = new SocketIOServer(server, {
    cors: {
      origin: process.env.ORIGIN || "*"
    }
  });
  setIO(io);

  app.set("io", io);

  io.on("connection", (socket) => {
    console.log("[Socket] client connected:", socket.id);
    socket.on("disconnect", () => console.log("[Socket] client disconnected:", socket.id));
    socket.on("error", (err) => console.error("[Socket] error:", err));
  });

  server.listen(PORT, () => console.log(`[HTTP] Server listening on :${PORT}`));
}

start().catch((e) => {
  console.error("Fatal:", e);
  process.exit(1);
});
