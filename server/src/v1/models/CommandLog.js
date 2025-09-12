import mongoose from "mongoose";

const CommandLogSchema = new mongoose.Schema(
  {
    node_id: { type: Number, required: true, index: true },
    command: { type: String, enum: ["ON", "OFF"], required: true },
    topic: { type: String, required: true },
    by: { type: String, default: "api" }, // who issued the command
    status: { type: String, enum: ["sent", "failed"], default: "sent" },
    error: { type: String, default: "" }
  },
  { timestamps: { createdAt: "createdAt", updatedAt: false } }
);

export default mongoose.model("CommandLog", CommandLogSchema);
