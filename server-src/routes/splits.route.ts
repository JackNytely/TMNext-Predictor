// External Imports
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';

// Internal Imports
import { saveSplit } from '../services/split.service';
import { authenticateRequest } from '../middleware/auth.middleware';
import type { AuthenticatedRequest, SplitRequestBody, TMNextSplit } from '../types/types';

/**
 * Register the Split Routes
 * @param fastify The Fastify Instance
 * @returns void
 */
export async function registerSplitRoutes(fastify: FastifyInstance): Promise<void> {
	// Save a new split
	fastify.post('/splits', { preHandler: authenticateRequest }, splitHandler);
}

/**
 * Split Handler
 * @param request The authenticated request
 * @param reply The Fastify reply
 * @returns The response
 */
async function splitHandler(request: AuthenticatedRequest, reply: FastifyReply) {
	// Get the user ID and display name
	const userId = request.userId!;
	const displayName = request.displayName!;

	// Get the body from the request
	const body: SplitRequestBody = request.body;

	// Get the map ID, checkpoint times, total time and run date from the body
	const { mapId, checkpointTimes, totalTime, runDate } = body;

	// Check if the Map ID Is missing
	if (!mapId) return reply.code(400).send({ error: 'mapId is required' });

	// Check if the Checkpoint Times Is missing
	if (!checkpointTimes) return reply.code(400).send({ error: 'checkpointTimes is required' });

	// Check if the Total Time Is missing
	if (!totalTime) return reply.code(400).send({ error: 'totalTime is required' });

	// Check if the Checkpoint Times Is not an array
	if (!Array.isArray(checkpointTimes) || checkpointTimes.length === 0)
		return reply.code(400).send({ error: 'checkpointTimes must be a non-empty array' });

	// Check if the Total Time Is not a number or is not positive
	if (typeof totalTime !== 'number' || totalTime <= 0) return reply.code(400).send({ error: 'totalTime must be a positive number' });

	// Save the split
	const split = await saveSplit(userId, displayName, mapId, {
		checkpointTimes,
		totalTime,
		runDate: runDate ? new Date(runDate) : null,
	}).catch(error => {
		// Log the error
		console.error('Error saving split:', error);

		// Setup the new Error Response
		const errorResponse = new Error('Failed to save split');

		// Return the error response
		return errorResponse;
	});

	// Check if the Split is a type of Error and return the error response
	if (split instanceof Error) return reply.code(500).send({ error: split.message });

	// Setup the Response Data
	const responseData = {
		id: split._id,
		mapId,
		checkpointTimes: split.checkpointTimes,
		totalTime: split.totalTime,
		runDate: split.runDate,
	};

	// Return the response
	return reply.code(201).send({ success: true, data: responseData });
}
