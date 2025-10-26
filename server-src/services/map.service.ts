// Internal Imports
import { MapModel } from '../database/models/map.model';
import type { TMNextMap } from '../types/types';

/**
 * Find or create a map
 * @param mapId The ID of the map
 * @returns The map
 */
export async function findOrCreateMap(mapId: string): Promise<TMNextMap> {
	// Get the Existing Map
	const existingMap = await MapModel.findOne({ mapId });

	// Check if the Map does not exist and create/retrun the new map
	if (!existingMap) return await MapModel.create({ mapId });

	// Return the map
	return existingMap;
}

/**
 * Get a map by their ID
 * @param mapId The ID of the map
 * @returns The map
 */
export async function getMapById(mapId: string): Promise<TMNextMap | null> {
	// Get the map by their ID
	const map = await MapModel.findOne({ mapId });

	// Return the map
	return map;
}
