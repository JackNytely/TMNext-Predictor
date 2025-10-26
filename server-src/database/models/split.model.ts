// External Imports
import { Schema, model } from 'mongoose';

// Internal Imports
import { type TMNextSplit } from '../../types/types';

// Setup the Schema for the TMNext Split
const SplitSchema = new Schema<TMNextSplit>(
	{
		playerId: { type: Schema.Types.ObjectId, ref: 'Player', required: true, index: true },
		mapId: { type: Schema.Types.ObjectId, ref: 'Map', required: true, index: true },
		checkpointTimes: { type: [Number], required: true },
		totalTime: { type: Number, required: true },
		runDate: { type: Date, default: Date.now },
	},
	{ timestamps: true },
);

// Compound index for faster queries on player and map
SplitSchema.index({ playerId: 1, mapId: 1, totalTime: 1 });

// Export the Model for the TMNext Split
export const SplitModel = model<TMNextSplit>('Split', SplitSchema);
