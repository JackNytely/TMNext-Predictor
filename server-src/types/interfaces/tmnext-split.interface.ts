// External Imports
import { ObjectId } from 'mongoose';

// Internal Imports
import { type TimestampedDocument } from '../types';

/**
 * Interface for the TMNext Split
 */
export interface TMNextSplit extends TimestampedDocument {
	/**
	 * The ID of the Player
	 */
	playerId: ObjectId;

	/**
	 * The ID of the Map
	 */
	mapId: ObjectId;

	/**
	 * The cumulative checkpoint times in milliseconds
	 */
	checkpointTimes: number[];

	/**
	 * The final finish time in milliseconds
	 */
	totalTime: number;

	/**
	 * The date of the run
	 */
	runDate: Date;
}
