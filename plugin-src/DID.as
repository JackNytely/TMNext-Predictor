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
        c.content = Predictor::GetPredictedTimeString();
        return c;
    }
}

class PredictorDeltaProvider : DID::LaneProvider {
    DID::LaneProviderSettings@ getProviderSetup() {
        DID::LaneProviderSettings settings;
        settings.author = "JackNytely";
        settings.internalName = "Predictor/DeltaTime";
        settings.friendlyName = "Predictor - Delta time";
        return settings;
    }

    DID::LaneConfig@ getLaneConfig(DID::LaneConfig@ &in defaults) {
        DID::LaneConfig c = defaults;
        c.content = Predictor::GetDeltaTimeString();
        return c;
    }
}

class PredictorCheckpointProvider : DID::LaneProvider {
    DID::LaneProviderSettings@ getProviderSetup() {
        DID::LaneProviderSettings settings;
        settings.author = "JackNytely";
        settings.internalName = "Predictor/CheckpointInfo";
        settings.friendlyName = "Predictor - Checkpoint info";
        return settings;
    }

    DID::LaneConfig@ getLaneConfig(DID::LaneConfig@ &in defaults) {
        DID::LaneConfig c = defaults;
        c.content = Predictor::GetCheckpointInfoString();
        return c;
    }
}
#endif
