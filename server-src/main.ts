// External Imports
import Fastify, { FastifyReply, FastifyRequest } from 'fastify';
import cors from '@fastify/cors';

// Internal Imports
import { database } from './database/database';
import { registerSplitRoutes } from './routes/splits.route';

// Setup the Environment Variables
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Setup the Fastify Instance
const fastify = Fastify({ logger: true });

// Register plugins
await fastify.register(cors, {
	origin: true,
	credentials: true,
});

// Connect to database
await database.connect();

// Register routes
await fastify.register(registerSplitRoutes);

// Health check endpoint
fastify.get('/health', async (request: FastifyRequest, reply: FastifyReply) => {
	// Log the Health Check
	return reply.code(200).send({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
await fastify.listen({ port: Number(PORT), host: HOST });

// Log the Server Listening
console.log(`🚀 Server listening on http://${HOST}:${PORT}`);

// Graceful shutdown
process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

/**
 * Graceful Shutdown
 * @param signal The signal that triggered the shutdown
 * @returns void
 */
async function gracefulShutdown(signal: NodeJS.Signals) {
	// Log the Shutdown
	console.log('\n🛑 Shutting down gracefully...');

	// Close the Fastify Instance
	await fastify.close();

	// Disconnect from the Database
	await database.disconnect();

	// Exit the Process
	process.exit(0);
}
