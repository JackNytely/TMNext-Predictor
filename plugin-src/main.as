// Plugin Info
const string pluginName = Meta::ExecutingPlugin().Name;
const string menuIconColor = "\\$5fa";
const string menuTitle = menuIconColor + "\\$z " + pluginName;

// Global variables
Predictor::PredictorCore@ predictorCore;

/**
 * Main function (Runs once when the plugin is loaded)
 */
void Main() {
    @predictorCore = Predictor::PredictorCore();
    predictorCore.Initialize();

    RefreshToken();
}

void RefreshToken() {
    // Check if the token is null and refresh it if it is
    if (predictorCore.GetDatabaseAuthToken().Length > 0){
        // Sleep for 1 second before refreshing the token again
        sleep(1000);

        // Refresh the token again
        RefreshToken();

        // End the function
        return;
    }

     // Start the task to get the token from Openplanet
    auto tokenTask = Auth::GetToken();

    // Wait until the task has finished
    while (!tokenTask.Finished()) yield();
    
    // Get the token and set it in the predictor
    string token = tokenTask.Token();
    predictorCore.SetDatabaseAuthToken(token);

    // Wait for 1 second before refreshing the token again
    sleep(1000);

    // Refresh the token again
    RefreshToken();
}

/**
 * Update function (Runs every frame)
 */
void Update(float millisecondsSinceLastFrame) {
    
    
    if (predictorCore !is null) predictorCore.Update(millisecondsSinceLastFrame);  
}

/**
 * Render function for overlay
 */
void Render() {
    if (predictorCore !is null) predictorCore.Render();
}

/**
 * Render interface for settings menu
 */
void RenderInterface() {
    if (predictorCore !is null) predictorCore.RenderInterface();
}

/**
 * Render menu items
 */
void RenderMenu() {
    if (UI::BeginMenu(Icons::Clock + " Predictor")) {
        predictorCore.RenderMenu();
        UI::EndMenu();
    }
}