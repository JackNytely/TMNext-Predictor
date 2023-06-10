#if DEPENDENCY_DID
class PredictorProvider : DID::LaneProvider {
    DID::LaneProviderSettings@ getProviderSetup() {
        DID::LaneProviderSettings settings;
        settings.author = "JackNytely";
        settings.internalName = "Predictor/TimeString";
        settings.friendlyName = "Predictor - Predicted time";
        return settings;
    }

    DID::LaneConfig@ getLaneConfig(DID::LaneConfig@ &in defaults) {
        DID::LaneConfig c = defaults;
        c.content = predictedTimeString;
        return c;
    }
}
#endif
