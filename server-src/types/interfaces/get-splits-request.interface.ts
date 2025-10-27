// Internal Imports
import type { AuthenticatedRequest, GetSplitsType } from '../types';

/**
 * Interface for the Save Split Request
 */
export interface GetSplitsRequest extends AuthenticatedRequest {
	/**
	 * The body of the request
	 */
	body: GetSplitsRequestBody;
}

/**
 * Interface for the Save Split Request Body
 */
interface GetSplitsRequestBody {
	/**
	 * The ID of the map
	 */
	mapId: string;

	/**
	 * The type of splits to get
	 */
	type: GetSplitsType;
}
