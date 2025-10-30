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
        
        /** Queue of split data waiting to be saved */
        private array<SplitData@> pendingSplits;
        
        /** Queue of server URLs for pending saves */
        private array<string> pendingUrls;
        
        /** HTTP request for fetching splits from server */
        private Net::HttpRequest@ fetchRequest = null;
        
        /** Whether a fetch operation is in progress */
        private bool isFetching = false;
        
        /** Most recent fetched splits data */
        private Json::Value lastFetchedData = Json::Value();
        
        /** Whether the last fetch was successful */
        private bool lastFetchSuccess = false;
        
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
            
            // If a save is in progress, queue this one
            if (isSaving) {
                pendingSplits.InsertLast(splitData);
                pendingUrls.InsertLast(serverUrl);
                print("Queued split for saving (currently " + pendingSplits.Length + " in queue)");
                return true; // Return true because we've queued it successfully
            }
            
            // Check if token is set
            if (authToken.Length == 0) {
                lastError = "No authentication token set";
                return false;
            }
            
            // Start the save process
            StartSave(splitData, serverUrl);
            return true;
        }
        
        /**
         * Start a save operation
         * 
         * @param {SplitData@} splitData - The split data to save
         * @param {string} serverUrl - The server URL to send data to
         * @private
         */
        void StartSave(SplitData@ splitData, const string &in serverUrl) {
            // Construct the URL
            string url = serverUrl;
            if (!url.EndsWith("/")) url += "/";
            url += "splits/save";
            
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
            
            // Store the request to check later
            @saveRequest = request;
            isSaving = true;
        }
        
        /**
         * Update method to check on pending saves
         * Should be called regularly (e.g., every frame)
         */
        void Update() {
            // If a save is in progress, check if it's finished
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
                    
                    // If there are pending saves, start the next one
                    if (pendingSplits.Length > 0) {
                        SplitData@ nextSplit = pendingSplits[0];
                        string nextUrl = pendingUrls[0];
                        pendingSplits.RemoveAt(0);
                        pendingUrls.RemoveAt(0);
                        print("Processing next queued split (" + pendingSplits.Length + " remaining)");
                        StartSave(nextSplit, nextUrl);
                    }
                }
            }
        }
        
        /**
         * Update method to check on pending saves and fetches
         * Should be called regularly (e.g., every frame)
         */
        void UpdateAll() {
            Update();
            UpdateFetch();
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
        
        /**
         * Fetch splits from the server
         * 
         * @param {string} mapId - The map ID to fetch splits for
         * @param {string} serverUrl - The server URL
         * @param {string} type - Type of splits to fetch ("personalBest" or "globalBest")
         * @returns {bool} True if fetch was started, false otherwise
         */
        bool FetchSplits(const string &in mapId, const string &in serverUrl, const string &in type) {
            if (mapId.Length == 0) {
                lastError = "Map ID is required";
                return false;
            }
            
            if (serverUrl.Length == 0) {
                lastError = "Server URL is required";
                return false;
            }
            
            if (authToken.Length == 0) {
                lastError = "No authentication token set";
                return false;
            }
            
            if (isFetching) {
                lastError = "A fetch operation is already in progress";
                return false;
            }
            
            // Start the fetch process
            StartFetch(mapId, serverUrl, type);
            return true;
        }
        
        /**
         * Start a fetch operation
         * 
         * @param {string} mapId - The map ID
         * @param {string} serverUrl - The server URL
         * @param {string} type - Type of splits to fetch
         * @private
         */
        void StartFetch(const string &in mapId, const string &in serverUrl, const string &in type) {
            // Construct the URL
            string url = serverUrl;
            if (!url.EndsWith("/")) url += "/";
            url += "splits/get";
            
            // Create JSON body
            string jsonBody = "{";
            jsonBody += "\"mapId\":\"" + mapId + "\",";
            jsonBody += "\"type\":\"" + type + "\"";
            jsonBody += "}";
            
            // Create HTTP request
            @fetchRequest = Net::HttpRequest();
            fetchRequest.Method = Net::HttpMethod::Post;
            fetchRequest.Url = url;
            fetchRequest.Body = jsonBody;
            fetchRequest.Headers.Set("Content-Type", "application/json");
            fetchRequest.Headers.Set("Authorization", "Bearer " + authToken);
            
            // Send the request
            fetchRequest.Start();
            isFetching = true;
            lastFetchSuccess = false;
            lastFetchedData = Json::Value();
        }
        
        /**
         * Get the fetched splits data
         * 
         * @returns {Json::Value} The fetched splits data or empty Json::Value if not available
         */
        Json::Value GetFetchedData() {
            return lastFetchedData;
        }
        
        /**
         * Check if the fetch was successful
         * 
         * @returns {bool} True if the last fetch was successful
         */
        bool GetFetchSuccess() {
            return lastFetchSuccess;
        }
        
        /**
         * Check if a fetch is in progress
         * 
         * @returns {bool} True if a fetch is in progress
         */
        bool IsFetching() {
            return isFetching;
        }
        
        /**
         * Update fetch operation status
         * Should be called regularly in Update()
         */
        void UpdateFetch() {
            if (isFetching && fetchRequest !is null) {
                if (fetchRequest.Finished()) {
                    bool success = fetchRequest.ResponseCode() >= 200 && fetchRequest.ResponseCode() < 300;
                    if (success) {
                        Json::Value responseBody = fetchRequest.Json();
                        lastFetchedData = responseBody;
                        lastFetchSuccess = true;
                        print("Successfully fetched splits from server");
                    } else {
                        string responseBody = fetchRequest.String();
                        lastError = "Server error (" + fetchRequest.ResponseCode() + "): " + responseBody;
                        print("Failed to fetch splits from server: " + lastError);
                        lastFetchedData = Json::Value();
                        lastFetchSuccess = false;
                    }
                    
                    isFetching = false;
                    @fetchRequest = null;
                }
            }
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

