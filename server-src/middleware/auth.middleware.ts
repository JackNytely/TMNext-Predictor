// External Imports
import { FastifyRequest, FastifyReply } from 'fastify';

// Internal Imports
import { AuthValidationResponse, AuthenticatedRequest } from '../types/types';

// Get the Openplanet Secret
const OPENPLANET_SECRET = process.env.OPENPLANET_SECRET;

// Get the Openplanet Validation URL
const OPENPLANET_VALIDATION_URL = process.env.OPENPLANET_VALIDATION_URL || 'https://openplanet.dev/api/auth/validate';

/**
 * Authenticate the request with Openplanet
 * @param request - The Fastify request object
 * @param reply - The Fastify reply object
 * @returns void
 */
export async function authenticateRequest(request: FastifyRequest, reply: FastifyReply): Promise<void> {
	// If the Openplanet Secret is not configured, return an error
	if (!OPENPLANET_SECRET) return reply.code(500).send({ error: 'Server authentication not configured' });

	// Get token from Authorization header
	const authHeader = request.headers['authorization'];

	// If the authorization header is not present, return an error
	if (!authHeader) return reply.code(401).send({ error: 'Missing authorization header' });

	// Get the token from the authorization header
	const token = authHeader.replace('Bearer ', '').trim();

	// If the token is not present, return an error
	if (!token) return reply.code(401).send({ error: 'Missing token' });

	// Setup the URL Encoded Form Data
	const urlEncodedData = new URLSearchParams();
	urlEncodedData.append('token', token);
	urlEncodedData.append('secret', OPENPLANET_SECRET);

	// Setup the Request Options
	const requestOptions: RequestInit = {
		method: 'POST',
		headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
		body: urlEncodedData.toString(),
	};

	// Validate token with Openplanet
	const response = await fetch(OPENPLANET_VALIDATION_URL, requestOptions).catch(error => {
		// Log the Error
		console.error('Error validating token:', error);

		// Create the Error Response
		const errorResponse = new Error('Authentication failed');

		// Return the Error Message
		return errorResponse;
	});

	// Check if the Response is an Error
	if (response instanceof Error) return reply.code(500).send({ error: 'Authentication failed' });

	// Parse the Response as JSON
	const data: AuthValidationResponse = await response.json();

	// If there is an error, return an error
	if (data.error) return reply.code(401).send({ error: data.error });

	// If the account ID or display name is not present, return an error
	if (!data.account_id || !data.display_name) return reply.code(401).send({ error: 'Invalid authentication response' });

	// Attach user information to request
	(request as AuthenticatedRequest).userId = data.account_id;
	(request as AuthenticatedRequest).displayName = data.display_name;
}
