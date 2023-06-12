/*
 * author: Phlarx + JackNytely
 */

namespace NytelyLib {
	/**
	 * If true, then this plugin has detected that we are in game, on a map.
	 * If false, none of the other values are valid.
	 */
	bool inGame = false;
	
	/**
	 * If false, then at least one checkpoint tag is a non-standard value.
	 * Only applies to NEXT and MP4.
	 */
	bool strictMode = false;
	
	/**
	 * The ID of the map whose checkpoints have been counted.
	 */
	string curMapId = "";
	
	/**
	 * The number of checkpoints completed in the current lap.
	 */
	uint curCP = 0;
	
	/**
	 * The number of checkpoints detected for the current map.
	 */
	uint maxCP = 1;
	
	/**
	 * Internal values.
	 */
	uint preCPIdx = 0;

	/**
	* Define whether the User has Restarted or Started a New Run on a Map
	*/
	bool NewStart = true;

	/**
	* Define the Time the User Started their Run at
	*/
	int startTime = 0;

	/**
	* Get the Author Time for the Current map
	*/
	int mapAuthorTime = 0;

	/**
	* Get the Lap Count for the Current Map
	*/
	bool isLapRace = false;

	/**
	* Get the Lap Count for the Current Map
	*/
	bool isFinish = false;

	/**
	* Get the Lap Count for the Current Map
	*/
	int maxLap = 0;

	/**
	* Get the Current Lap the User is on
	*/
	int curLap = 0;
	
	/**
	* Update should be called once per tick, within the plugin's Update(dt) function.
	*/

	void Update() {

		/**
		* Intialize the Playground, MedalAPP and Map Objects
		*/
		auto playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
		auto medalApp = cast<CTrackMania>(GetApp());
		
		/**
		* Check if the Player is currently in a Match
		*/
		if(playground is null
			|| playground.Arena is null
			|| playground.Map is null
			|| playground.GameTerminals.Length <= 0
			|| playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing
			|| cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer) is null) {

			/**
			* Indicate the Player is not currently in a Match and breaks the Script
			*/
			inGame = false;
			return;
		}
		
		/**
		* Intialize the Player and Script Player
		*/
		auto player = cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
		auto scriptPlayer = cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer).ScriptAPI;

		/**
		* Check if the ScriptPlayer Exists
		*/
		if(scriptPlayer is null) {
			inGame = false;
			return;
		}

		/**
		* Check if the Player started a New Run
		*/
		if(NewStart == false && player.StartTime != startTime) {

			/**
			* Set the Required Variables on New Start of a Run
			*/
			isLapRace = playground.Map.TMObjective_IsLapRace;
			isFinish = true;
			maxLap = playground.Map.TMObjective_NbLaps;
			curLap = 0;
			curCP = 0;
			NewStart = true;
			startTime = player.StartTime;
		}

		/**
		* Get the Current Author time for Specified Map
		*/
		mapAuthorTime = playground.Map.TMObjective_AuthorTime;
		
		/**
		* Check if the User wants the Timer Hidden with the Current Interface and Hide the Timer if Interface is Hidden
		*/
		if(hideTimerWithInterface) {
			if(playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
				inGame = false;
				return;
			}
		}
		
		/**
		* Check if the Player is Currently Spectating
		*/
		if(player.CurrentLaunchedRespawnLandmarkIndex == uint(-1)) {
			inGame = false;
			return;
		}
		
		MwFastBuffer<CGameScriptMapLandmark@> landmarks = playground.Arena.MapLandmarks;
		
		if(!inGame && (curMapId != playground.Map.IdName || GetApp().Editor !is null)) {
			// keep the previously-determined CP data, unless in the map editor
			curMapId = playground.Map.IdName;
			preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;
			curCP = 0;
			maxCP = 1;
			curLap = 0;
			isLapRace = false;
			
			maxLap = playground.Map.TMObjective_NbLaps;
			isLapRace = playground.Map.TMObjective_IsLapRace;
			if(isLapRace){
				maxCP = maxLap;
			}

			strictMode = true;
			
			array<int> links = {};
			for(uint i = 0; i < landmarks.Length; i++) {
				if(landmarks[i].Waypoint !is null && !landmarks[i].Waypoint.IsFinish && !landmarks[i].Waypoint.IsMultiLap) {
					// we have a CP, but we don't know if it is Linked or not
					if(landmarks[i].Tag == "Checkpoint") {
						if(isLapRace) {
							maxCP += maxLap;
						} else{
							maxCP++;
						}
					} else if(landmarks[i].Tag == "LinkedCheckpoint") {
						if(links.Find(landmarks[i].Order) < 0) {
							if(isLapRace) {
								maxCP += maxLap;
							} else{
								maxCP++;
							}
							links.InsertLast(landmarks[i].Order);
						}
					} else {
						// this waypoint looks like a CP, acts like a CP, but is not called a CP.
						if(isLapRace) {
							maxCP += maxLap;
						} else{
							maxCP++;
						}
						strictMode = false;
					}
				}
			}
		}
		inGame = true;
		
		/**
		* Check if the Player is at the Start Block to reset the CP Counter
		*/
		if(preCPIdx != player.CurrentLaunchedRespawnLandmarkIndex && landmarks.Length > player.CurrentLaunchedRespawnLandmarkIndex) {
			preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;
			
			if(landmarks[preCPIdx].Waypoint is null || landmarks[preCPIdx].Waypoint.IsFinish || landmarks[preCPIdx].Waypoint.IsMultiLap) {
				
				if(landmarks[preCPIdx].Waypoint !is null && landmarks[preCPIdx].Waypoint.IsFinish){
					isFinish = true;
				}else{	
					isFinish = false;
				}

				// if null, it's a start block. if the other flags, it's either a multilap or a finish.
				// in all such cases, we reset the completed cp count to zero.

				if(isLapRace) {
					curCP++;
				}else{
					if(isFinish){
						curCP++;
					}else{
						curCP = 0;
					}
				}
			} else {
				curCP++;
			}
		}
	}

	void WriteToFile(const string &in fileName, const string &in folderPath, const string &in fileContents){
		string filePath = folderPath + fileName + ".nyte";

		// Create the Config Folder for the Plugin
		IO::CreateFolder(IO::FromDataFolder(folderPath), true);

		// build a file path relative to the OpenplanetNext folder
		auto fileDataFolderPath = IO::FromDataFolder(filePath);
	
		// call the file constructor with that path
		IO::File file(fileDataFolderPath);
	
		// open the file for writing
		file.Open(IO::FileMode::Write);
	
		// write the data you want
		file.Write(fileContents);
	
		// close the file (which also finalizes any writes)
		file.Close();
	}

	string ReadFromFile(const string &in fileName, const string &in folderPath){
		string filePath = folderPath + fileName + ".nyte";

		// Create the Config Folder for the Plugin
		//IO::CreateFolder(IO::FromDataFolder(folderPath), true);

		if(IO::FileExists(IO::FromDataFolder(filePath))){

			// build a file path relative to the OpenplanetNext folder
			auto fileDataFolderPath = IO::FromDataFolder(filePath);
	
			// call the file constructor with that path
			IO::File file(fileDataFolderPath);
	
			// open the file for writing
			file.Open(IO::FileMode::Read);

			// write the data you want
			string fileContents = file.ReadLine();
	
			// close the file (which also finalizes any writes)
			file.Close();
			return fileContents;
		}else{
			return "File not Found";
		}
	}

	string GetTimeString(int givenTime) {
		int msTimeAbsolute = 0;
		int secTimeAbsolute = 0;
		int minTimeAbsolute = 0;
		int hrTimeAbsolute = 0;

		msTimeAbsolute = int(givenTime);
		secTimeAbsolute = int(Math::Round(givenTime / 1000));
		minTimeAbsolute = int(Math::Round(givenTime / (1000 * 60)));
		hrTimeAbsolute = int(Math::Round(givenTime / (1000 * 60 * 60)));

		int msTimeFinal = msTimeAbsolute - (secTimeAbsolute * 1000);
		int secTimeFinal = secTimeAbsolute - (minTimeAbsolute * 60);
		int minTimeFinal = minTimeAbsolute - (hrTimeAbsolute * 60);
		int hrTimeFinal = hrTimeAbsolute;

		string msTimeString = "" + msTimeFinal;
		string secTimeString = "" + secTimeFinal;
		string minTimeString = "" + minTimeFinal;
		string hrTimeString = "" + hrTimeFinal;

		if(msTimeFinal < 100 && msTimeFinal > 10) {
			msTimeString = "0" + msTimeFinal;
		}

		if(msTimeFinal < 10) {
			msTimeString = "00" + msTimeFinal;
		}

		if(secTimeFinal < 10) {
			secTimeString = "0" + secTimeFinal;
		}

		if(minTimeFinal < 10) {
			minTimeString = "0" + minTimeFinal;
		}

		if(hrTimeFinal < 10) {
			hrTimeString = "0" + hrTimeFinal;
		}

		string resultString = hrTimeString + ":" + minTimeString + ":" + secTimeString + ":" + msTimeString;

		return resultString;
	}
}