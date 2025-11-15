import { FastifyRequest } from 'fastify';

export interface AuthUserRequestBody {
	openplanetToken: string;
}

export type AuthUserRequest = FastifyRequest<{
	Body: AuthUserRequestBody;
}>;
