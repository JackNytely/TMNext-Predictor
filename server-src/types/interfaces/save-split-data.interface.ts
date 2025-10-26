/**
 * Interface for the data needed to save a split
 */
export interface SaveSplitData {
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
	runDate?: Date | null;
}
