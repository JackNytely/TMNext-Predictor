// External Imports
import { Schema, model } from 'mongoose';

// Internal Imports
import { type TMNextPlayer } from '../../types/types';

// Setup the Schema for the TMNext Player
const PlayerSchema = new Schema<TMNextPlayer>(
	{
		accountId: { type: String, required: true, unique: true, index: true },
		displayName: { type: String, required: true },
	},
	{ timestamps: true },
);

// Export the Model for the TMNext Player
export const PlayerModel = model<TMNextPlayer>('Player', PlayerSchema);
