// Internal Imports
import type { AuthenticatedRequest } from '../types';

/**
 * Interface for the Save Split Request
 */
export interface SaveSplitRequest extends AuthenticatedRequest {
	/**
	 * The body of the request
	 */
	body: SaveSplitRequestBody;
}

/**
 * Interface for the Save Split Request Body
 */
interface SaveSplitRequestBody {
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
