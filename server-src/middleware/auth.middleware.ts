// External Imports
import { FastifyRequest, FastifyReply } from 'fastify';

// Internal Imports
import { AuthenticatedRequest, AuthenticationPayload } from '../types/types';
import { verify } from 'jsonwebtoken';

// Get the Environment Variables
const JWT_SECRET = process.env.JWT_SECRET;

/**
 * Authenticate the request with Openplanet
 * @param request - The Fastify request object
 * @param reply - The Fastify reply object
 * @returns void
 */
export async function authenticateRequest(request: FastifyRequest, reply: FastifyReply): Promise<void> {
	// If the JWT Secret is not configured, return an error
	if (!JWT_SECRET) return reply.code(500).send({ error: 'Server authentication not configured' });

	// Get token from Authorization header
	const authHeader = request.headers['authorization'];

	// If the authorization header is not present, return an error
	if (!authHeader) return reply.code(401).send({ error: 'Missing authorization header' });

	// Get the token from the authorization header
	const token = authHeader.replace('Bearer ', '').trim();

	// If the token is not present, return an error
	if (!token) return reply.code(401).send({ error: 'User not authenticated' });

	// Get the Authentication Payload
	const payload = await verifyToken(token, JWT_SECRET!).catch(error => {
		// Log the Error
		console.error('Error verifying token:', error);

		// Return an error
		return reply.code(401).send({ error: 'Invalid token' });
	});

	// Attach user information to request
	(request as AuthenticatedRequest).userId = payload.accountId;
	(request as AuthenticatedRequest).displayName = payload.displayName;
}

/**
 * Verify the JWT Token
 * @param token - The JWT Token to verify
 * @param secret - The JWT Secret to use
 * @returns The Authentication Payload
 */
export async function verifyToken(token: string, secret: string): Promise<AuthenticationPayload> {
	// Setup the New Promise
	const promise = new Promise<AuthenticationPayload>((resolve, reject) => {
		// Verify the JWT Token
		verify(token, secret, (err, decoded) => {
			// If there is an error, reject the promise
			if (err) return reject(err);

			// If the decoded token is not an object, reject the promise
			if (typeof decoded !== 'object') return reject(new Error('Invalid token'));

			// Resolve the promise with the decoded token
			resolve(decoded as AuthenticationPayload);
		});
	});

	// Return the Promise
	return promise;
}
