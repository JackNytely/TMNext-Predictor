import { FastifyRequest } from 'fastify';

export interface AuthenticatedRequest extends Omit<FastifyRequest, 'body'> {
	userId?: string;
	displayName?: string;
	body?: any;
}
