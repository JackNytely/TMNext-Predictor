// External Imports
import { Schema, model } from 'mongoose';

// Internal Imports
import { type TMNextMap } from '../../types/types';

// Setup the Schema for the TMNext Map
const MapSchema = new Schema<TMNextMap>({ mapId: { type: String, required: true, unique: true, index: true } }, { timestamps: true });

// Export the Model for the TMNext Map
export const MapModel = model<TMNextMap>('Map', MapSchema);
