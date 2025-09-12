import mongoose from "mongoose";

const SensorReadingSchema = new mongoose.Schema(
  {
    node_id: { type: Number, required: true, index: true },
    temperature: { type: Number, required: false },
    humidity: { type: Number, required: false },
    ldr: { type: Number, required: false },
    soil: { type: Number, required: false },
    // raw payload if you want to keep it
    raw: { type: Object }
  },
  { timestamps: { createdAt: "createdAt", updatedAt: false } }
);

SensorReadingSchema.index({ node_id: 1, createdAt: -1 });

export default mongoose.model("SensorReading", SensorReadingSchema);
