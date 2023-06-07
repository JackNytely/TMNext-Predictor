/*
 * author: JackNytely
 */
[Setting name="Show Timer"]
bool showTimer = true;

[Setting name="Hide Timer when interface is hidden"]
bool hideTimerWithInterface = false;

[Setting name="X position" min=0 max=1]
float XPos = .5;

[Setting name="Y position" min=0 max=1]
float YPos = .91;

[Setting name="Show background"]
bool showBackground = false;

[Setting name="Font size" min=8 max=72]
uint fontSize = 24;

[Setting color name="Font color"]
vec4 fontColor = vec4(1, 1, 1, 1);

uint startTime = 0;
uint lastCP = 0;
uint predictedTime = 0;
bool recordTrack = true;
string predictedTimeString = "00:00:00:000";
string compareCPSplitString;
array<string> cpSplits;
array<string> compareCPSplitArray;

string curFontFace = "";
nvg::Font font;

void Render() {
	if(showTimer && NytelyLib::inGame) {
		string text = predictedTimeString;
		
		nvg::FontSize(fontSize);
		if(Math::IsNaN(font)) {
			nvg::FontFace(font);
		}
		nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
		
		if(showBackground) {
			nvg::FillColor(vec4(0, 0, 0, 0.8));
			//vec2 size = nvg::TextBoxBounds(XPos * Draw::GetWidth() - 100, YPos * Draw::GetHeight(), 200, text);
			//vec2 size = nvg::TextBounds(text);
			vec2 size = nvg::TextBoxBounds(200, text);
			nvg::BeginPath();
			nvg::RoundedRect(XPos * Draw::GetWidth() - size.x * 0.6, YPos * Draw::GetHeight() - size.y * 0.67, size.x * 1.2, size.y * 1.2, 5);
			nvg::Fill();
			nvg::ClosePath();
		}
		
			nvg::FillColor(fontColor);
		
		nvg::TextBox(XPos * Draw::GetWidth() - 100, YPos * Draw::GetHeight(), 200, text);
	}
}

void Update(float dt) {
	if(NytelyLib::NewStart == true) {
		cpSplits = array<string>(NytelyLib::maxCP, "0");
		NytelyLib::curLap = 0;
		NytelyLib::curCP = 0;
		NytelyLib::NewStart = false;
		startTime = Time::Now + 1500;
		predictedTimeString = "00:00:00:000";

		compareCPSplitString = NytelyLib::ReadFromFile(NytelyLib::curMapId, "config\\Predictor\\MapSets\\");

		if(compareCPSplitString != "File not Found") {
			compareCPSplitArray = compareCPSplitString.Split(":");

			predictedTimeString = NytelyLib::GetTimeString(Text::ParseInt(compareCPSplitArray[NytelyLib::maxCP - 1]));
		}

		lastCP = 0;
	}
	
	if(Time::Now - startTime > 0 && NytelyLib::curCP > lastCP) {

		lastCP = NytelyLib::curCP;

		uint raceTime = Time::Now - startTime;

		uint avgTimePerLap = raceTime / 1;

		if(NytelyLib::curCP > 0) {
			avgTimePerLap = raceTime / NytelyLib::curCP;
		}

		if(recordTrack = true) {
			if(NytelyLib::isFinish && NytelyLib::curCP == NytelyLib::maxCP){

			}
			cpSplits[NytelyLib::curCP - 1] = TimeLib::GetRaceTime() + "";
		}

		if(cpSplits[NytelyLib::maxCP - 1] != "0"){
			
			string cpSplitString = string::Join(cpSplits, ":");

			string currentSplitFileString = NytelyLib::ReadFromFile(NytelyLib::curMapId, "config\\Predictor\\MapSets\\");

			if(currentSplitFileString == "File not Found"){

				NytelyLib::WriteToFile(NytelyLib::curMapId, "config\\Predictor\\MapSets\\", cpSplitString);
			}else {

				array<string> currentSplitFileArray = currentSplitFileString.Split(":");
				uint currentSplitFileFinishTime = Text::ParseInt(currentSplitFileArray[NytelyLib::maxCP - 1]);

				if(raceTime < currentSplitFileFinishTime){
					NytelyLib::WriteToFile(NytelyLib::curMapId, "config\\Predictor\\MapSets\\", cpSplitString);
				}
			}
		}

		if(compareCPSplitString != "File not Found") {
			avgTimePerLap = Text::ParseInt(compareCPSplitArray[NytelyLib::maxCP - 1]) / NytelyLib::maxCP;

			predictedTime = (Text::ParseInt(compareCPSplitArray[NytelyLib::maxCP - 1])+(raceTime - Text::ParseInt(compareCPSplitArray[NytelyLib::curCP - 1])));
		}else{
			predictedTime = (avgTimePerLap * ((NytelyLib::maxCP + 1) - NytelyLib::curCP)) + raceTime;
		}

		predictedTimeString = NytelyLib::GetTimeString(predictedTime);
	}

	NytelyLib::Update();
}