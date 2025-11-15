// Internal Imports
import { TMNextMap, TMNextPlayer, TMNextSplit } from '../types';

/**
 * Interface for the TMNext Split
 */
export interface PopulatedTMNextSplit extends Omit<TMNextSplit, 'playerId' | 'mapId'> {
	/**
	 * The ID of the Player
	 */
	playerId: TMNextPlayer;

	/**
	 * The ID of the Map
	 */
	mapId: TMNextMap;

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
