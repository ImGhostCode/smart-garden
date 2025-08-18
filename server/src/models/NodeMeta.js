import mongoose from "mongoose";

const NodeMetaSchema = new mongoose.Schema(
  {
    node_id: { type: Number, unique: true, required: true },
    name: { type: String, default: "" },
    location: { type: String, default: "" },
    lastSeenAt: { type: Date }
  },
  { timestamps: { createdAt: "createdAt", updatedAt: "updatedAt" } }
);

export default mongoose.model("NodeMeta", NodeMetaSchema);
