// Internal Imports
import { type TimestampedDocument } from '../types';

/**
 * Interface for the TMNext Player
 */
export interface TMNextPlayer extends TimestampedDocument {
	/**
	 * The players ID from Openplanet
	 */
	accountId: string; // Openplanet account ID

	/**
	 * The players display name
	 */
	displayName: string;
}
