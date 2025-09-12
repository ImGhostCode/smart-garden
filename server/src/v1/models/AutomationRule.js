import mongoose from "mongoose";

const TimeWindowSchema = new mongoose.Schema(
  { start: { type: String, required: true }, end: { type: String, required: true } },
  { _id: false }
);

const RuleSchema = new mongoose.Schema(
  {
    name: { type: String, default: "" },
    node_id: { type: Number, required: true, index: true },
    type: { type: String, enum: ["soil_threshold","humidity_threshold","temperature_threshold"], required: true },
    min: { type: Number },
    max: { type: Number },
    action: { type: String, enum: ["pump_on"], required: true },
    durationSec: { type: Number, default: 20, min: 1, max: 3600 },
    enabled: { type: Boolean, default: true },
    timeWindows: { type: [TimeWindowSchema], default: [] },
    cooldownSec: { type: Number, default: 300 },
    maxDailyRuntimeSec: { type: Number, default: 1800 },
    lastTriggeredAt: { type: Date },
    todayRuntimeSec: { type: Number, default: 0 },
    createdBy: { type: String, default: "system" },
  },
  { timestamps: true }
);

export default mongoose.model("AutomationRule", RuleSchema);
