// External Imports
import mongoose from 'mongoose';

// Setup the Environment Variables
const MONGO_HOST = process.env.MONGO_HOST || 'localhost';
const MONGO_PORT = process.env.MONGO_PORT || '27017';
const MONGO_USERNAME = process.env.MONGO_USERNAME || '';
const MONGO_PASSWORD = process.env.MONGO_PASSWORD || '';
const MONGO_DATABASE = process.env.MONGO_DATABASE || 'predictor';
const MONGO_REPLICA_SET = process.env.MONGO_REPLICA_SET || '';

// Setup the Database Class
class Database {
	/**
	 * Build the Connection String
	 * @returns The Connection String
	 */
	private buildConnectionString(): string {
		// Setup the Connection String
		let connectionString = 'mongodb://';

		// If the username and password are provided, add them to the connection string
		if (MONGO_USERNAME && MONGO_PASSWORD) connectionString += `${MONGO_USERNAME}:${MONGO_PASSWORD}@`;

		// Add the host, port and database to the connection string
		connectionString += `${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}`;

		// Setup the Query Parameters
		const queryParameters: Array<string> = new Array();

		// Add the Replica Set to the Query Parameters
		if (MONGO_REPLICA_SET) queryParameters.push(`replicaSet=${MONGO_REPLICA_SET}`);

		// Add the Direct Connection to the Query Parameters
		queryParameters.push(`directConnection=true`);

		// Add the Query Parameters to the Connection String
		if (queryParameters.length > 0) connectionString += `?${queryParameters.join('&')}`;

		// Return the Connection String
		return connectionString;
	}

	/**
	 * Connect to the Database
	 * @returns void
	 */
	public async connect(): Promise<void> {
		// Build the Connection String
		const connectionString = this.buildConnectionString();

		// Connect to the Database
		await mongoose.connect(connectionString).catch(error => {
			// Log the Error
			console.error('❌ MongoDB connection error:', error);

			// Throw the Error
			throw error;
		});

		// Log the Success
		console.log(`✅ Connected to MongoDB at ${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}`);
	}

	/**
	 * Disconnect from the Database
	 * @returns void
	 */
	public async disconnect(): Promise<void> {
		// Disconnect from the Database
		await mongoose.disconnect().catch(error => {
			// Log the Error
			console.error('❌ Error disconnecting from MongoDB:', error);

			// Throw the Error
			throw error;
		});

		// Log the Success
		console.log('Disconnected from MongoDB');
	}
}

// Export the Database Class
export const database = new Database();
