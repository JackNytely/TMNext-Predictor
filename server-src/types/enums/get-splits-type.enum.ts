/**
 * Enum for the type of splits to get
 */
export enum GetSplitsType {
	/**
	 * Get all splits
	 */
	ALL = 'all',

	/**
	 * Get the global best split
	 */
	GLOBAL_BEST = 'globalBest',

	/**
	 * Get the personal best split
	 */
	PERSONAL_BEST = 'personalBest',
}
