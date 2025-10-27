/**
 * Database API for Predictor Plugin
 * 
 * This module handles communication with the backend server, including
 * authentication and saving split data.
 * 
 * @namespace Predictor
 */
namespace Predictor {
    
    /**
     * Data structure for split information to send to the server
     * 
     * @class SplitData
     */
    class SplitData {
        /** The ID of the map */
        string mapId;
        
        /** Array of checkpoint times in milliseconds */
        array<uint> checkpointTimes;
        
        /** Total race time in milliseconds */
        uint totalTime;
        
        /** Optional timestamp of when the run was performed */
        string runDate;
        
        /**
         * Constructor for SplitData
         * 
         * @param {string} mapId - The map ID
         * @param {array<uint>@} checkpointTimes - Array of checkpoint times
         * @param {uint} totalTime - Total race time
         * @param {string} runDate - Optional run date timestamp
         */
        SplitData(const string &in mapId, array<uint>@ checkpointTimes, uint totalTime, const string &in runDate = "") {
            this.mapId = mapId;
            this.checkpointTimes = checkpointTimes;
            this.totalTime = totalTime;
            this.runDate = runDate;
        }
        
        /**
         * Convert SplitData to JSON string for HTTP request
         * 
         * @returns {string} JSON representation of the split data
         */
        string ToJson() {
            string json = "{";
            
            // Add mapId
            json += "\"mapId\":\"";
            json += mapId;
            json += "\",";
            
            // Add checkpointTimes array
            json += "\"checkpointTimes\":[";
            for (uint i = 0; i < checkpointTimes.Length; i++) {
                if (i > 0) json += ",";
                json += "" + checkpointTimes[i];
            }
            json += "],";
            
            // Add totalTime
            json += "\"totalTime\":";
            json += "" + totalTime;
            
            // Add runDate if provided
            if (runDate != "") {
                json += ",\"runDate\":\"";
                json += runDate;
                json += "\"";
            }
            
            json += "}";
            return json;
        }
    }
    
    /**
     * Database manager class for handling server communication
     * 
     * Handles authentication with Openplanet and saves split data to the server.
     * 
     * @class DatabaseManager
     */
    class DatabaseManager {
        /** Current authentication token */
        private string authToken = "";
        
        /** Most recent error message */
        private string lastError = "";
        
        /** HTTP request for saving splits */
        private Net::HttpRequest@ saveRequest = null;
        
        /** Whether a save operation is in progress */
        private bool isSaving = false;
        
        /**
         * Set the authentication token
         * 
         * @param {string} token - The authentication token
         */
        void SetAuthToken(const string &in token) {
            authToken = token;
        }
        
        /**
         * Save split data to the server
         * 
         * Authenticates with Openplanet and sends split data to the backend server.
         * 
         * @param {SplitData@} splitData - The split data to save
         * @param {string} serverUrl - The server URL to send data to
         * @returns {bool} True if successful, false otherwise
         */
        bool SaveSplit(SplitData@ splitData, const string &in serverUrl) {
            if (splitData is null) {
                lastError = "Split data is null";
                return false;
            }
            
            // If save is in progress, check if it's finished
            if (isSaving && saveRequest !is null) {
                if (saveRequest.Finished()) {
                    bool success = saveRequest.ResponseCode() >= 200 && saveRequest.ResponseCode() < 300;
                    if (success) {
                        string responseBody = saveRequest.String();
                        print("Successfully saved split to server: " + responseBody);
                    } else {
                        string responseBody = saveRequest.String();
                        lastError = "Server error (" + saveRequest.ResponseCode() + "): " + responseBody;
                        print("Failed to save split to server: " + lastError);
                    }
                    isSaving = false;
                    @saveRequest = null;
                    return success;
                }
                // Still waiting
                return false;
            }
            
            // Check if token is set
            if (authToken.Length == 0) {
                lastError = "No authentication token set";
                return false;
            }
            
            // Construct the URL
            string url = serverUrl;
            if (!url.EndsWith("/")) url += "/";
            url += "splits";
            
            // Convert split data to JSON
            string jsonData = splitData.ToJson();
            
            // Create HTTP request
            Net::HttpRequest@ request = Net::HttpRequest();
            request.Method = Net::HttpMethod::Post;
            request.Url = url;
            request.Body = jsonData;
            request.Headers.Set("Content-Type", "application/json");
            request.Headers.Set("Authorization", "Bearer " + authToken);
            
            // Send the request
            request.Start();
            
            // Don't wait for response - return immediately and check on next call
            // Store the request to check later
            @saveRequest = request;
            isSaving = true;
            
            // Return false for now, actual result will be checked on next call
            return false;
        }
        
        /**
         * Get the most recent error message
         * 
         * @returns {string} The last error message
         */
        string GetLastError() {
            return lastError;
        }
        
        /**
         * Clear the authentication token
         */
        void ClearAuthToken() {
            authToken = "";
        }
    }
    
    /** Global database manager instance */
    DatabaseManager@ databaseManager;
    
    /**
     * Initialize the database manager
     * Must be called before using any database functions
     * 
     * @returns {DatabaseManager@} The database manager instance
     */
    DatabaseManager@ InitializeDatabase() {
        if (databaseManager is null) {
            @databaseManager = DatabaseManager();
        }
        return databaseManager;
    }
    
    /**
     * Get the database manager instance
     * 
     * @returns {DatabaseManager@} The database manager instance
     */
    DatabaseManager@ GetDatabaseManager() {
        if (databaseManager is null) {
            return InitializeDatabase();
        }
        return databaseManager;
    }
}

