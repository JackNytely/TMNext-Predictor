// External Imports
import { FastifyRequest } from 'fastify';

/**
 * Interface for the Auth User Request
 */
export interface AuthUserRequest extends Omit<FastifyRequest, 'body'> {
	/**
	 * The Openplanet Token of the user
	 */
	openplanetToken: string;
}
