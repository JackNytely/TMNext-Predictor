// Internal Imports
import { PlayerModel } from '../database/models/player.model';
import type { TMNextPlayer } from '../types/types';

/**
 * Find or create a player
 * @param accountId The account ID of the player
 * @param displayName The display name of the player
 * @returns The player
 */
export async function findOrCreatePlayer(accountId: string, displayName: string): Promise<TMNextPlayer> {
	// Get the Existing Player
	const existingPlayer = await PlayerModel.findOne({ accountId });

	// Check if the Player does not exist and create/retrun the new player
	if (!existingPlayer) return await PlayerModel.create({ accountId, displayName });

	// Check if the Display Name has not changed and return the player if it hasn't
	if (existingPlayer.displayName === displayName) return existingPlayer;

	// Update the display name if it changed
	existingPlayer.displayName = displayName;

	// Save the player
	await existingPlayer.save();

	// Return the player
	return existingPlayer;
}

/**
 * Get a player by their account ID
 * @param accountId The account ID of the player
 * @returns The player
 */
export async function getPlayerById(accountId: string): Promise<TMNextPlayer | null> {
	// Get the player by their account ID
	const player = await PlayerModel.findOne({ accountId });

	// Return the player
	return player;
}
