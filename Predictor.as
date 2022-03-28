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
int fontSize = 24;

[Setting color name="Font color"]
vec4 fontColor = vec4(1, 1, 1, 1);

int startTime = 0;
int lastCP = 0;
int predictedTime = 0;
string predictedTimeString = "00:00:00:000";

string curFontFace = "";
Resources::Font@ font;

void Render() {
	if(showTimer && CP::inGame) {
		string text = predictedTimeString;
		
		nvg::FontSize(fontSize);
		if(font !is null) {
			nvg::FontFace(font);
		}
		nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
		
		if(showBackground) {
			nvg::FillColor(vec4(0, 0, 0, 0.8));
			vec2 size = nvg::TextBoxBounds(XPos * Draw::GetWidth() - 100, YPos * Draw::GetHeight(), 200, text);
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

	if(CP::NewStart == true) {
		CP::NewStart = false;
		startTime = Time::get_Now();
		predictedTimeString = "00:00:00:000";

		lastCP = 0;
	}
	
	if((Time::get_Now() - startTime) > 0 && CP::curCP > lastCP) {
		lastCP = CP::curCP;

		int raceTime = Time::get_Now() - startTime;

		int avgTimePerLap = raceTime / 1;

		if(CP::curCP > 0) {
			avgTimePerLap = raceTime / CP::curCP;
		}

		predictedTime = (avgTimePerLap * ((CP::maxCP + 1) - CP::curCP)) + raceTime;

		predictedTimeString = getTimeString(predictedTime);
	}

	CP::Update();
}

string getTimeString(int givenTime) {
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