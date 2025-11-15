/**
 * Interface for the Authentication Payload
 */
export interface AuthenticationPayload {
	/**
	 * The account ID of the user
	 */
	accountId: string;

	/**
	 * The display name of the user
	 */
	displayName: string;

	/**
	 * The token time of the user
	 */
	tokenTime: number;
}
