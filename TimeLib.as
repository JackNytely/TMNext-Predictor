/*
 * author: JackNytely
 */

//Setup the TimeLib NameSpace
namespace TimeLib {

    //Setup the GetRaceTime Function
    int GetRaceTime() {

        //Setup the App
        CGameCtnApp @app = GetApp();

        //Setup the Network
        CGameCtnNetwork @network = app.Network;;

        //Get the Playground from the Network
        CGameManiaAppPlayground @networkPlayground = network.ClientManiaAppPlayground;
    
        //Get the UI Layer from the Playground
        CGameUILayer @UILayer = networkPlayground.UILayers[7];

        //Get the Local Page from the UI Layer
        CGameManialinkPage @LocalPage = UILayer.LocalPage;

        //Get the ClassChildren_Result from the Link Page
        CGameManialinkControl @raceCheckpoint = LocalPage.GetClassChildren_Result[0];

        //Setup the CheckPoint Frame Cast
        CGameManialinkControl @checkpointFrame = cast<CGameManialinkFrame>(raceCheckpoint).Controls[0];

        //Setup the Race Frame Cast
        CGameManialinkControl @raceFrame = cast<CGameManialinkFrame>(checkpointFrame).Controls[0];

        //Setup the Race Time Frame Cast
        CGameManialinkControl @raceTimeFrame = cast<CGameManialinkFrame>(raceFrame).Controls[0];

        //Get the Race Time Label
        CGameManialinkControl @raceTimeLabel = cast<CGameManialinkFrame>(raceTimeFrame).Controls[1];

        //Get the Race Time
        CGameManialinkLabel @raceTime = cast<CGameManialinkLabel>(raceTimeLabel);
        print(raceTime.Value);
    
       //Check if the raceTime has Errored
        if(raceTime is null) {

            //Return with Error
            return -1;
        }else{

            //Return the Race Time
            return TimeStringToUnixTime(raceTime.Value);
        }
    }
}

//Setup a Function to Convert a Time String into a Unix Timestamp
int TimeStringToUnixTime(const string TimeString) {

    //Get the Minutes, Seconds and Milliseconds from the Time String
    int minutes = Text::ParseInt(TimeString.Split(':')[0]) * 60000;
    int seconds = Text::ParseInt(TimeString.Split(':')[1].Split('.')[0]) * 1000;
    int milliseconds = Text::ParseInt(TimeString.Split(':')[1].Split('.')[1]);

    //Combine the Minutes, Seconds and Milliseconds into the required Unix Timestamp
    int UnixTimestamp = minutes + seconds + milliseconds;

    //Return the Unixe Timestamp
    return UnixTimestamp;
}