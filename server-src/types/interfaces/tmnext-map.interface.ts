// Internal Imports
import { type TimestampedDocument } from '../types';

/**
 * Interface for the TMNext Map
 */
export interface TMNextMap extends TimestampedDocument {
	/**
	 * The ID of the Map
	 */
	mapId: string;
}
