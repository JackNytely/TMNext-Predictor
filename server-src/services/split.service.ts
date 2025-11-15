// Internal Imports
import { SplitModel } from '../database/models/split.model';
import { findOrCreatePlayer } from './player.service';
import { findOrCreateMap } from './map.service';
import type { PopulatedTMNextSplit, SaveSplitData } from '../types/types';

/**
 * Save a new split
 * @param accountId The account ID of the player
 * @param displayName The display name of the player
 * @param mapId The ID of the map
 * @param splitData The data for the split
 * @returns The new split
 */
export async function saveSplit(
	accountId: string,
	displayName: string,
	mapId: string,
	splitData: SaveSplitData,
): Promise<PopulatedTMNextSplit> {
	// Get or create player and map
	const player = await findOrCreatePlayer(accountId, displayName);
	const map = await findOrCreateMap(mapId);

	// Create the new split
	const split = await SplitModel.create({
		playerId: player._id,
		mapId: map._id,
		checkpointTimes: splitData.checkpointTimes,
		totalTime: splitData.totalTime,
		runDate: splitData.runDate ?? new Date(),
	});

	// Return the new split
	return split as unknown as PopulatedTMNextSplit;
}

/**
 * Get the splits for a player
 * @param accountId The account ID of the player
 * @param mapId The ID of the map
 * @returns The splits for the player
 */
export async function getPlayerSplits(accountId: string, mapId: string): Promise<Array<PopulatedTMNextSplit>> {
	// Find the Map
	const map = await findOrCreateMap(mapId);

	// Find the splits for the player and map
	const splits = await SplitModel.find({ playerId: accountId, mapId: map._id })
		.populate('playerId')
		.populate('mapId')
		.sort({ totalTime: 1 });

	// Return the splits
	return splits as unknown as Array<PopulatedTMNextSplit>;
}

/**
 * Get the best split for a player
 * @param accountId The account ID of the player
 * @param mapId The ID of the map
 * @returns The best split for the player
 */
export async function getPlayerBestSplit(accountId: string, mapId: string): Promise<PopulatedTMNextSplit | null> {
	// Find the Map
	const map = await findOrCreateMap(mapId);

	// Find the splits for the player and map
	const split = await SplitModel.findOne({ playerId: accountId, mapId: map._id })
		.populate('playerId')
		.populate('mapId')
		.sort({ totalTime: 1 });

	// Return the splits
	return split as unknown as PopulatedTMNextSplit;
}

/**
 * Get the global best split for a map
 * @param mapId The ID of the map
 * @returns The global best split for the map
 */
export async function getGlobalBestSplit(mapId: string): Promise<PopulatedTMNextSplit | null> {
	// Find the Map
	const map = await findOrCreateMap(mapId);

	// Find the global best split for the map
	const split = await SplitModel.findOne({ mapId: map._id }).populate('playerId').populate('mapId').sort({ totalTime: 1 });

	// Log the global best split
	console.log('Global Best Split:', split);

	// Return the global best split
	return split as unknown as PopulatedTMNextSplit;
}
