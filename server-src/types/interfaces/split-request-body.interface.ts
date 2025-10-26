/**
 * Interface for the split request body
 */
export interface SplitRequestBody {
	/**
	 * The ID of the map
	 */
	mapId: string;

	/**
	 * The checkpoint times
	 */
	checkpointTimes: number[];

	/**
	 * The total time
	 */
	totalTime: number;

	/**
	 * The date of the run
	 */
	runDate?: string;
}
