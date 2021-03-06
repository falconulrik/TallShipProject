//Sail controls and misc particles effects
//© 2014 Falcon Ulrik

//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version. 

//   This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or visit
//    http://opensource.org/licenses

// with acknowledgments to Becky Mouillez and her BWind scripts.

//Derivation:
//Tako 2.3 by Kanker Greenacre
//Permitted use:
// - personal use in your own boats
// - use in boats you wish to sell or give away in Second Life
// - modification to your needs

//NOT permitted:
// - repackaging and reselling this script
// - use on platforms other than Second Life


//version settings
string boatName="FSail test ship";   // Rename this according to your needs...
string versionNumber=" v 0.3";  // Release reference


///////////////////////////////////////////////////////////////////////
// GLOBAL BOAT SETTINGS /////////////////////////////////////////////
//////
////////////////////////////////////////////////////////////////////


integer debug = FALSE;//set TRUE for debug chat

float hoverOffset = -0.35;

integer prims;//total prims in ship, used to define skipper link number for rotating view
animate(string anim)

{
	integer perm =llGetPermissions();
	if (perm & PERMISSION_TRIGGER_ANIMATION)
	{
		list anims = llGetAnimationList(llGetPermissionsKey());        // get list of animations
		integer len = llGetListLength(anims);
		integer i;
		for (i = 0; i < len; ++i) llStopAnimation(llList2Key(anims, i));
		llStartAnimation(anim);
	}
}

//Variables for crew sit posiions
key gunner;
key lookout;

//misc control variables and constants
integer locked;//flag to lock controls while rudder is turning
integer col=FALSE;//flag for land and object collision damage on/off
integer shout;//flag to turn shouted damage reports on/off
integer combat=FALSE;//flag to turn combat mode on/off
string idStr;
integer listener;
integer CHANNEL=9;
integer chan=-9999;//comm channel set by HUD
integer pingchannel = 56678798;
integer damage=1;


//Anchor textures and functions
integer moored;
anchorUp()
{
	llMessageLinked(LINK_THIS,0,"anchorUp",NULL_KEY);
	moored=FALSE;
}

anchorDown()
{
	llMessageLinked(LINK_THIS,0,"anchorDown",NULL_KEY);
	moored = TRUE;
}

integer health;//the initial total health or the number of hits the ship can withstand before death.
float healthTweak=1;


//script module flags
integer CONTROLS_MODULE=1;
integer SAIL_MODULE=2;

//environment
vector wind;
float windAngle;
float absWindAngle;
float seaLevel;
float depth;

//reused math variables
vector eulerRot;
vector currEuler;
rotation quatRot;
rotation currRot;

//boat variables
float zRotAngle;
vector fwdVec;
vector upVec;
vector leftVec;
float compass;

//heeling variables
float heelAngle;
float heelTorque;
float heelAdd;
float heelFactor=1.0;    //Multiplier - set according to values of CS, TP, SS etc
float heelSlowingFactor=0.7;

//linear motion variables
float currSpeed;
vector groundSpeed=ZERO_VECTOR;
float spdFactor=0.0;
float leeway;

//angular motion variables
float rotSpeed;
float rotDelta;
vector eulerTurnLeft;
vector eulerTurnRight;
rotation quatTurnLeft=ZERO_ROTATION;
rotation quatTurnRight=ZERO_ROTATION;

//sail variables
integer sailingAngle;
integer mizzenSailingAngle;
integer squareSailingAngle;//this is 90-braceAngle. braceAngle is the actual angle of the square sails,
// squareSailingAngle is used to put square sail calculations in phase with fore and aft sails
//as they rotate inversely and 90 degrees out of phase.
integer currBoomAngle=0;
integer currMizzenAngle=0;
integer currSquareAngle=0;
integer currStayAngle =0;
integer squareDelta;
integer mizzenDelta;
integer stayDelta;
integer delta;
integer incr;
float optBoomAngle;
float squareTrimFactor;
float stayTrimFactor;
float trimFactor;
float jibFactor = 0.25;//Adjusts power for fore-and-aft sails
float courseFactor = 0.22;//Adjusts power for course and so on for other sails
float topFactor = 0.2;
float topgallantFactor = 0.18;
float royalFactor = 0.15;
float sailFactor; //sum of active sail factors
integer aback=1;//flag for when square sails are aback - -1 is aback



//performance constants - Standard defaults

float timerFreq=1.0;              //timer frequency, seconds (original paramer 1.5; check this if gets laggy)
integer sheetAngle=35;
integer mizzenSheetAngle=35;          //initial sheet angle setting
integer braceAngle = 55;    //initial main brace setting - braceAngle is the actual angle of the square sails
float maxWindSpeed=14.0; //used for heeling calculation (better leave this unchanged)

//miscellaneous settings

key owner;                  //boat owner
key captain;                 //avatar sitting at the helm
integer lock=FALSE;
integer ownerVersion=TRUE;


integer SAIL=FALSE;
integer CS=FALSE;
integer TP=FALSE;
integer TG=FALSE;
integer RY=FALSE;
integer SS=FALSE;
integer MZ=FALSE;


integer permSet=FALSE;
integer HUD_ON=TRUE;
string dataString;
vector hudColour;
//integer numTouches=0;
integer sailing=TRUE;
//float mpsToKts=1.944; //Metres per Second to Knots conversion
float convert=1.9438445;
string units=" Kts.";
integer showKnots=TRUE; //Yes we show speed in Knots...
float time;
float offset;
float theta;
string helpString;
string visualAid;
string currentString;



//general sailing parameters
float ironsAngle=50;             //this is as close as the boat can sail to the wind
float slowingFactor=0.04;      //speed drops by this factor every timerFreq seconds if sailing into the wind
float leewayTweak=0.4;    //scales leeway (0=no leeway) 0.6 in Phoenix
//float rotTweak=0.8;
float rotTweak=3.0;          //scales boat turning rate
float speedTweak;//set in calcspeed()

//Wind parameters
vector tmpwind;
float initWind =90;//Wind direction on startup
float windDir;
integer windSpdSet;

// ------------------------- END GLOBAL BOAT SETTINGS ---

//primary parameters
//FU mod to ensure these are identical with later settings in script
float windSpeed=15.0;
float maxSpeed=5;
float heelTweak=0.35;//0.5 i Phoenix

float appwindSpeed;
float appwindAngle;



// --------------------------- END DEFAULT PRESET DECLARATION ---

///////////////////////////////////////////////////
// GLOBAL BOAT EQUATIONS AND FUNCTIONS ///////
////////////////////////////////////////////////

//GENERAL BOAT STARTUP - reset stuff - this resets the script to defaults...
//you may call this function as needed...

startup() {
	llMessageLinked(LINK_SET,0,"Reset",NULL_KEY);
	owner=llGetOwner();
	llUnSit(owner);
	llOwnerSay("\nPlease don't board until ready...");
	llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Z | STATUS_ROTATE_Y,TRUE);
	llSetStatus(STATUS_PHYSICS,FALSE);
	llSetStatus(STATUS_PHANTOM,FALSE);
	llSetStatus(STATUS_BLOCK_GRAB_OBJECT,TRUE);
	llSetTimerEvent(0);
	CHANNEL =(integer) llGetObjectDesc();
	llSetSitText("Board");
	setInitialPosition();
	setVehicleParams();
	llSetObjectName(boatName + versionNumber);
	llSay(chan, "HUD" + "|" + "" + "|" + "");
	lowerSail();
	currSpeed=0;
	windSpeed=15/convert;
	windDir=initWind*DEG_TO_RAD;
	listener = llListen(CHANNEL,"",owner,""); //listen to boat owner only...
	getLinkNums();
	//llMessageLinked(LINK_SET,debug,"debug",NULL_KEY);
	llSetLinkPrimitiveParamsFast(HUD1,[PRIM_TEXT,"", hudColour, 1.0]);
	llSetLinkPrimitiveParamsFast(HUD2,[PRIM_TEXT,"", hudColour, 1.0]);
	llSleep(2.0);
	anchorDown();
}

//wind algorithm parameters
float angRate=10;
float avgAng;
float avgSpd=5;
float halfArc=0.2;
float spdRng=3;
integer raceWindOn=TRUE;

integer sl2rl(integer realAngle) {
	integer lslAngle= (realAngle-90)*-1;
	while(lslAngle>=360) lslAngle-=360;
	while(lslAngle<0) lslAngle+=360;
	return lslAngle;
}

integer sternway()
{
	vector spd = llGetVel();
	rotation rot = llGetRot();
	spd = spd/rot;
	if(spd.x<0)return TRUE;
	else return FALSE;
}

//prevailing wind algorithm - SPD combat setting
calcWindDir() {//only used in spd combat mode
	avgAng=-67.5*DEG_TO_RAD;
	time=llGetTimeOfDay();
	theta=time/14400*TWO_PI*angRate;
	offset=llSin(theta)*llSin(theta*2)*llSin(theta*9)*llCos(theta*4);
	//llOwnerSay("Wind dir offset = "+ (string)offset);
	windDir=avgAng+halfArc*offset;
}

calcWindSpd() {//only used in spd combat mode
	offset=llSin(theta)*llSin(theta*4)+llSin(theta*13)/3;
	//llOwnerSay("Wind speed offset = "+ (string)offset);
	windSpeed=avgSpd+spdRng*offset;
	if (windSpeed<0) windSpeed=0;
	appwindSpeed=windSpeed;
}

//wind algorithms, non-SPD
//calculate wind relative to boat
calcWindAngle() {
	currRot=llGetRot();
	currEuler=llRot2Euler(currRot);
	zRotAngle=currEuler.z;//boat heading
	leftVec=llRot2Left(currRot);
	windAngle=windDir-zRotAngle;
	while (windAngle>PI) windAngle-=TWO_PI;//bw -PI and PI
	while (windAngle<-PI) windAngle+=TWO_PI;//bw -PI and PI
	if(combat)
	{
		appwindAngle=windAngle;
	}
}

calcAppWindAngle()
{
	float spd=llVecMag(llGetVel());
	appwindSpeed = llSqrt(llPow((llSin(windAngle)*windSpeed),2.0)+llPow((spd+llCos(windAngle)*windSpeed),2.0));
	appwindAngle = llAtan2(llSin(windAngle)*windSpeed, spd +llCos(windAngle)*windSpeed);
}

//calculate heel angle based on wind and sail settings
calcHeelAngle()
{
	integer offset;
	heelAngle=llAsin(leftVec.z);
	sailFactor = (jibFactor*SS + courseFactor*CS+ topFactor*TP+topgallantFactor*TG +royalFactor*RY);
	if (SAIL)
	{
		if (llFabs(appwindAngle+sailingAngle)>10)
		{
			if (appwindAngle<0)offset = -1;
			else offset = 1;
			if(SAIL)heelTorque=sailFactor*(llSin(appwindAngle)+llCos(appwindAngle)+offset)*llCos(heelAngle)*PI_BY_TWO*(windSpeed/maxWindSpeed)*llCos(squareSailingAngle*DEG_TO_RAD)*heelTweak*heelFactor;
		}
		else heelTorque=0;
	}

	else heelTorque=0;
	heelAdd=heelTorque-heelAngle;
	eulerRot=<heelAdd,0,0>;
	quatRot=llEuler2Rot(eulerRot);
	//if(llFabs(heelAngle)*RAD_TO_DEG>15)
	//{
	//   heelSlowingFactor = 1/(heelAngle*RAD_TO_DEG-20);
	//}
}

//calculate angle of sail (or boom) based on sheet setting and the wind

//Separate functions for fore-and-aft and square sails
//Mizzen function used for staysails and rotation adjusted in sail module

calcMizzenDelta() {

	//if (sheetAngle<=0) sheetAngle=5; //never let the actual sheetangle be less than 5°
	if (sheetAngle<10) sheetAngle=10; //never let the actual sheetangle be less than 10°
	if (sheetAngle>=79) sheetAngle=79; //never let the actual sheetangle be more than 79°
	if(mizzenSheetAngle>=37) mizzenSheetAngle=37;
	if(mizzenSheetAngle<10) mizzenSheetAngle=10;

	sailingAngle=sheetAngle;
	mizzenSailingAngle = mizzenSheetAngle;


	if (sailingAngle>llFabs(windAngle*RAD_TO_DEG)) sailingAngle=llRound(llFabs(windAngle*RAD_TO_DEG));
	if (windAngle<0) sailingAngle*=-1;
	stayDelta=sailingAngle-currStayAngle;
	currStayAngle=sailingAngle;
	llMessageLinked(LINK_SET,stayDelta,"stay",NULL_KEY);

	if (windAngle<0) mizzenSailingAngle*=-1;
	mizzenDelta = mizzenSailingAngle-currMizzenAngle;
	currMizzenAngle = mizzenSailingAngle;
	llMessageLinked(LINK_SET,mizzenDelta,"mizzen",NULL_KEY);
}

//Modified function for square sails, setting an absolute angle (squareSailingAngle)
//rather than sending additive or subtractive values (squareDelta)
//Controls section of script modified also to give values that are the inverse of the fore-and-aft ones,
//and to allow more accurate behaviour of square sails - yards are braced at an angle, not sheeted in against the wind pressure
calcSquareDelta() {
	//if (sheetAngle<=0) sheetAngle=5; //never let the actual sheetangle be less than 5°
	if (braceAngle>55) braceAngle=55; //never let the brace angle be more than 45°
	if (braceAngle<0) braceAngle=0;
	//if (sheetAngle>=79) sheetAngle=79; //never let the actual sheetangle be more than 79°
	currSquareAngle=braceAngle;
	squareSailingAngle = 90-currSquareAngle;//this to put the squaresailing angle in phase with the sailing angle

	if (windAngle<0) currSquareAngle*=-1;
	llMessageLinked(LINK_SET,currSquareAngle,"brace",NULL_KEY);
}

calcDelta()
{
	calcMizzenDelta();
	calcSquareDelta();
}

calcSpeed()
{
	if(combat)speedTweak=0.7;//limits speed to be compatible with other ships in combat sims
	else speedTweak=0.8;
	//llOwnerSay((string)SAIL);
	groundSpeed=llGetVel();
	absWindAngle=llFabs(appwindAngle);
	float power;
	if (SAIL==3)//value indicating that only fore-and-aft sails are in use
	{
		if (llFabs(absWindAngle*RAD_TO_DEG-llFabs(sailingAngle))<10)trimFactor=0;
		trimFactor = stayTrimFactor;//which is more advantageous than with square sails
		// ie can sail faster closer to wind
		ironsAngle = 35;
	}
	else if(SAIL)//square sails are in use
	{
		ironsAngle=50;
		trimFactor=squareTrimFactor;
		if (llFabs(absWindAngle*RAD_TO_DEG-llFabs(90-squareSailingAngle))<10)trimFactor=0;


		optBoomAngle=0.5*absWindAngle*RAD_TO_DEG;
		stayTrimFactor=(90.-llFabs(optBoomAngle-llFabs(sailingAngle)))/90.;
		squareTrimFactor=(90.-llFabs(optBoomAngle-llFabs(squareSailingAngle)))/55.;
		optBoomAngle=0.5*absWindAngle*RAD_TO_DEG;
		stayTrimFactor=(90.-llFabs(optBoomAngle-llFabs(sailingAngle)))/90.;
		squareTrimFactor=(90.-llFabs(optBoomAngle-llFabs(squareSailingAngle)))/55.;
		//calculate adjusted total asjustment on sails
		sailFactor = (jibFactor*SS + courseFactor*CS+ topFactor*TP+topgallantFactor*TG+royalFactor*RY )*0.18;
		if (llFabs(appwindAngle*RAD_TO_DEG)<ironsAngle)
		{
			//currSpeed*=slowingFactor;
			trimFactor=-0.2;
		}
		//calculste resultant force
		power = llSin((llFabs(windAngle)+1)/1.5)-llCos((llFabs(windAngle)+1)/1.2) - 0.5;
		if(power<0)power=0;
		// abnd speed
		currSpeed=sailFactor*speedTweak*power*appwindSpeed*trimFactor*healthTweak*heelSlowingFactor;
		if (llVecMag(groundSpeed)>6.0)
		{
			currSpeed= currSpeed/(1+(llVecMag(groundSpeed)-6.0)*10);
		}

		else currSpeed*=0.8;
	}
}

//calculate leeway (lateral drift) due to wind
calcLeeway() {
	leeway=SAIL*-llSin(appwindAngle)*llSin(llFabs(heelAngle))*appwindSpeed*leewayTweak/10;//corrected calculation
	//leeway=SAIL*-llSin(windAngle)*llSin(heelAngle)*appwindSpeed*leewayTweak; //original from Tako - when heel goes negative, it cancels out the windangle going negative so leeway always worked in the same direction
}

//calculate turning rate based on current speed
calcTurnRate() {
	spdFactor=llVecMag(groundSpeed)/(maxSpeed);
	rotSpeed=llVecMag(groundSpeed)*(1/(1+llVecMag(groundSpeed)))/maxSpeed*aback*rotTweak;
	if(debug)llOwnerSay((string)currSpeed);
}

//gets depth of water below boat
calcDepth() {
	depth=llWater(ZERO_VECTOR)-llGround(ZERO_VECTOR);
}

//update heads-up display (in 1st and 3rd person view)
updateHUD(integer on) {
	compass=PI_BY_TWO-zRotAngle;
	while (compass<0) compass+=TWO_PI;
	calcDepth();

	if(!combat)dataString="Apparent Wind Angle:       "  +(string)((integer)(appwindAngle*RAD_TO_DEG))+" deg\n";
	dataString+="Sheet Angle:      " +(string)sheetAngle+" deg\n";
	dataString+="Ground Speed: "+llGetSubString((string)(llVecMag(groundSpeed*convert)),0,3)+units+"\n";
	dataString +="Heading:          "     +(string)((integer)(compass*RAD_TO_DEG))+" deg\n";
	dataString+="Squaresail Angle:         "  +(string)(90-braceAngle)+" deg\n";
	dataString+="Wind Speed:   "  +llGetSubString((string)(windSpeed*convert),0,3)+units+"\n";
	dataString+="Wind Angle:       "  +(string)((integer)(windAngle*RAD_TO_DEG))+" deg\n";
	if(!combat)dataString+="Apparent wind Speed:   "  +llGetSubString((string)(appwindSpeed*convert),0,3)+units+"\n";
	dataString+="Depth:             "       +llGetSubString((string)depth,0,3)+" m\n";
	float efficiency =  llFabs(appwindAngle*RAD_TO_DEG)/(llFabs((float)sheetAngle));
	if(llFabs(appwindAngle*RAD_TO_DEG)<ironsAngle)hudColour = <1.0,0,0>;
	else if(llFabs(appwindAngle*RAD_TO_DEG)<ironsAngle+5)hudColour = <1.0,1.0,0>;
	else if (efficiency >=2.2)hudColour=<0.0,1.0,1.0>;
	else if (efficiency >1.8)hudColour=<0.0,1.0,0.0>;
	else if (efficiency >1.4)hudColour=<1.0,1.0,0.0>;
	else if (efficiency <=1.4)hudColour=<1.0,0.0,0.0>;

	else hudColour =  <1.0,1.0,1.0>;
	if(on)llSetLinkPrimitiveParamsFast(HUD1,[PRIM_TEXT,dataString, hudColour, 1.0]);//sends data to HUD prim
	else llSetLinkPrimitiveParamsFast(HUD1,[PRIM_TEXT,"", hudColour, 1.0]);
	if (on) llSetLinkPrimitiveParamsFast(HUD2,[PRIM_TEXT,dataString, hudColour, 1.0]);
	else llSetLinkPrimitiveParamsFast(HUD2,[PRIM_TEXT,"", hudColour, 1.0]);
	llSay(chan, "HUD" + "|" + dataString + "|" + (string)hudColour);
	llSay(pingchannel, "HUD" + "|" + dataString + "|" + (string)hudColour);

}
//automatically detect link nums for each named part
integer HUD1;
integer HUD2;

integer RUDDER;
integer GUNNER;
integer SKIPPER;
integer LOOKOUT;
integer DECK;

getLinkNums()
{
	integer i;
	for (i=2;i<=prims;i++)
	{
		string str=llGetLinkName(i);
		llSetLinkPrimitiveParamsFast(i,[PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_NONE]);
		//link numbers for other prims that need linked functions are done by individual variables
		if (str=="hud1") HUD1=i;
		if (str=="hud2") HUD2=i;
		if (str=="deck")DECK = i;
		if(str=="gunner")GUNNER = i;
		if(str=="lookout") LOOKOUT = i;
		if (str=="rudder")
		{
			llSetLinkPrimitiveParamsFast(i,[PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_CONVEX]);
		}
		if(str== "solid")llSetLinkPrimitiveParamsFast(i,[PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_CONVEX]);

	}
}

// RASIE ROUTINES - raise sail and enable physics
//sets the original rotations of all sails and sets their faces to show riased sails and spars

raiseSail() {
	CS=4;
	TP=5;
	TG=6;
	RY=7;
	SS = 3;
	SAIL=CS+TP+TG+RY+SS;
	sailing=TRUE;
	//if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
	//permSet=TRUE;
	llSetStatus(STATUS_PHYSICS,TRUE);
	if(moored)anchorUp();
	llMessageLinked(LINK_SET,1001,"raise",NULL_KEY);
	llSetTimerEvent(timerFreq);
}

raiseCourse()
{
	if(!CS)
	{
		CS=4;
		SAIL=CS+TP+TG+RY+SS;
		sailing=TRUE;
		if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
		permSet=TRUE;
		llSetStatus(STATUS_PHYSICS,TRUE);
		if(moored)anchorUp();
		llMessageLinked(LINK_SET,1001,"rcs",NULL_KEY);
		llSetTimerEvent(timerFreq);
	}
}

raiseTopsail()
{
	if(!TP)
	{
		TP=5;
		SAIL=CS+TP+TG+RY+SS;
		sailing=TRUE;
		if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
		permSet=TRUE;
		llSetStatus(STATUS_PHYSICS,TRUE);

		if(moored)anchorUp();
		llMessageLinked(LINK_SET,1001,"rtp",NULL_KEY);
		llSetTimerEvent(timerFreq);
	}
}

raiseTopgallant()
{
	if(!TG)
	{
		TG=6;
		SAIL=CS+TP+TG+RY+SS;
		sailing=TRUE;
		if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
		permSet=TRUE;
		llSetStatus(STATUS_PHYSICS,TRUE);

		if(moored)anchorUp();
		llMessageLinked(LINK_SET,1001,"rtg",NULL_KEY);
		llSetTimerEvent(timerFreq);
	}
}

raiseRoyal()
{
	if(!RY)
	{
		RY=7;
		SAIL=CS+TP+TG+RY+SS;
		sailing=TRUE;
		if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
		permSet=TRUE;
		llSetStatus(STATUS_PHYSICS,TRUE);

		if(moored)anchorUp();
		llMessageLinked(LINK_SET,1001,"rry",NULL_KEY);
		llSetTimerEvent(timerFreq);
	}
}

raiseStaysail()
{
	if(!SS)
	{
		SS=3;
		SAIL=CS+TP+TG+RY+SS;
		sailing=TRUE;
		if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
		permSet=TRUE;
		llSetStatus(STATUS_PHYSICS,TRUE);

		if(moored)anchorUp();
		llMessageLinked(LINK_SET,1001,"rss",NULL_KEY);
		llSetTimerEvent(timerFreq);
	}
}

// LOWER ROUTINE - lower sail but leave physics on
//resets the original rotations of all sails and sets their faces to show furled sails and spars only

lowerSail()

{
	sailingAngle = 0;
	currSquareAngle=0;
	currStayAngle=0;
	currMizzenAngle=0;
	sheetAngle=15;
	mizzenSheetAngle =15;
	braceAngle = 55;
	SAIL=FALSE;
	CS=FALSE;
	TP=FALSE;
	TG=FALSE;
	RY=FALSE;
	SS = FALSE;
	llMessageLinked(LINK_SET,1000,"lower",NULL_KEY);
}

lowerCourse()
{
	CS=FALSE;
	SAIL=CS+TP+TG+RY+SS;
	if(!SAIL)lowerSail();
	else llMessageLinked(LINK_SET,1000,"lcs",NULL_KEY);
}

lowerTopsail()
{
	TP=FALSE;
	SAIL=CS+TP+TG+RY+SS;
	if(!SAIL)lowerSail();
	else llMessageLinked(LINK_SET,1000,"ltp",NULL_KEY);
}

lowerTopgallant()
{
	TG=FALSE;
	SAIL=CS+TP+TG+RY+SS;
	if(!SAIL)lowerSail();
	else llMessageLinked(LINK_SET,1000,"ltg",NULL_KEY);
}
lowerRoyal()
{
	RY=FALSE;
	SAIL=CS+TP+TG+RY+SS;
	if(!SAIL)lowerSail();
	else llMessageLinked(LINK_SET,1000,"lry",NULL_KEY);
}

lowerStaysail()
{
	SS=FALSE;
	SAIL=CS+TP+TG+RY+SS;
	if(!SAIL)lowerSail();
	else llMessageLinked(LINK_SET,1000,"lss",NULL_KEY);
}

// VEHICLE PHYSICS PARAMETERS - set initial vehicle parameters

setVehicleParams() {
	//vehicle flags
	llSetVehicleType         (VEHICLE_TYPE_BOAT);
	llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME,ZERO_ROTATION); // ZERO_ROTATION = <0.0,0.0,0.0,1.0> you may wish to edit this for fun
	llSetVehicleFlags        (VEHICLE_FLAG_NO_DEFLECTION_UP|VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT|VEHICLE_FLAG_LIMIT_MOTOR_UP );
	//linear motion
	llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<300.0,2.0,0.5>);;
	llSetVehicleVectorParam  (VEHICLE_LINEAR_MOTOR_DIRECTION,ZERO_VECTOR);
	llSetVehicleFloatParam   (VEHICLE_LINEAR_MOTOR_TIMESCALE,10.0);
	llSetVehicleFloatParam   (VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE,200);
	llSetVehicleFloatParam   (VEHICLE_LINEAR_DEFLECTION_EFFICIENCY,0.85);
	llSetVehicleFloatParam   (VEHICLE_LINEAR_DEFLECTION_TIMESCALE,1.0);
	//angular motion
	//Original FUSquareSail settings
	//llSetVehicleVectorParam  (VEHICLE_ANGULAR_FRICTION_TIMESCALE,<5,0.1,0.1>);
	llSetVehicleVectorParam  (VEHICLE_ANGULAR_FRICTION_TIMESCALE,<5,0.1,0.1>);
	llSetVehicleVectorParam  (VEHICLE_ANGULAR_MOTOR_DIRECTION,ZERO_VECTOR);
	llSetVehicleFloatParam   (VEHICLE_ANGULAR_MOTOR_TIMESCALE,0.3);
	llSetVehicleFloatParam   (VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE,3);
	llSetVehicleFloatParam   (VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY,1.0);
	llSetVehicleFloatParam   (VEHICLE_ANGULAR_DEFLECTION_TIMESCALE,3.0);
	//default 1.0 -- reduce to have more lateral drift (like 0.3 - 0.5)
	//vertical attractor
	llSetVehicleFloatParam   (VEHICLE_VERTICAL_ATTRACTION_TIMESCALE,3.0);
	llSetVehicleFloatParam   (VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY,0.8);
	//banking
	llSetVehicleFloatParam   (VEHICLE_BANKING_EFFICIENCY,0.0);
	llSetVehicleFloatParam   (VEHICLE_BANKING_MIX,1.0);
	llSetVehicleFloatParam   (VEHICLE_BANKING_TIMESCALE,1.2);
	//vertical control
	llSetVehicleFloatParam   (VEHICLE_HOVER_HEIGHT,seaLevel);
	llSetVehicleFloatParam   (VEHICLE_HOVER_EFFICIENCY,2.0);
	llSetVehicleFloatParam   (VEHICLE_HOVER_TIMESCALE,1.0);
	llSetVehicleFloatParam   (VEHICLE_BUOYANCY,1.0);
}

//REZZING INITIAL POSITION - figure out where to put boat when it is rezzed
// The boat will float at a 20.100 level... Edit and raise/lower the rootprim to set your waterline... DON'T mod THIS !

setInitialPosition() {
	vector pos=llGetPos();
	float groundHeight=llGround(ZERO_VECTOR);
	float waterHeight = llWater(ZERO_VECTOR);
	seaLevel=llWater(ZERO_VECTOR)+hoverOffset;
	upright();
	//if over water, set boat height to sealevel + 0.1m; this is the standard default water level
	if (groundHeight <= waterHeight) {
		pos.z = waterHeight + hoverOffset; //fixed by Balduin Aabye (originally 0.12)
		while (llVecDist(llGetPos(),pos)>.001) llSetPos(pos);
	}
}

//BOAT UPRIGHT POSITION - force boat upright

upright() {
	currRot=llGetRot();
	currEuler=llRot2Euler(currRot);
	leftVec=llRot2Left(currRot);
	heelAngle=llAsin(leftVec.z);
	eulerRot=<-heelAngle,0,0>;
	quatRot=llEuler2Rot(eulerRot);
	llRotLookAt(quatRot*currRot,0.2,0.2);
}

//MOORING FUNCTION - what happens when your boat moors...

moor() {
	if(llVecMag(llGetVel())<0.5)
	{
		llMessageLinked(LINK_SET,1001,"anchorDown",NULL_KEY);
		llOwnerSay("Mooring.");
		if (SAIL) lowerSail();
		upright();
		llSetStatus(STATUS_PHYSICS,FALSE);
		llStopLookAt();
		moored = TRUE;
		//currSpeed=0;
	}
	else llOwnerSay("You are moving too fast too moor!");
}

// ------------------------------------- END GLOBAL BOAT EQUATIONS AND FUNCTIONS---


default {

	state_entry() {
		prims = llGetNumberOfPrims();
		llSitTarget(<-9.94717, -0.01328, 2.87496>, <0.00000, 0.00000, 0.00000, 1.00000>);
		//llSetText("",ZERO_VECTOR,1.0);
		//llMessageLinked(LINK_SET, 1002, "reset", NULL_KEY);
		startup();
	}

	//reset boat
	on_rez(integer param) {
		//llMessageLinked(LINK_SET, 1002, "Reset", NULL_KEY);
		llResetScript();
	}

	//OWNER CHECK AND STATUS
	changed(integer change) {


		if (change & CHANGED_LINK)
		{
			captain=llAvatarOnLinkSitTarget(1);
			gunner = llAvatarOnLinkSitTarget(GUNNER);
			lookout = llAvatarOnLinkSitTarget(LOOKOUT);
			//llSay(0,"GUNNER = "  + llKey2Name(gunner));
			//llSay(0,"LOOKOUT = " + llKey2Name(lookout));
			if(!(llGetAgentInfo(owner) & AGENT_ON_OBJECT))
			{
				llUnSit(gunner);
				llUnSit(lookout);
				llOwnerSay("Resetting, please wait...");
				llSetStatus(STATUS_PHYSICS,FALSE);
				llSleep(1.0);
				if (permSet) llReleaseControls();
				permSet=FALSE;
				llResetScript();
			}
			else {
				if (captain!=owner)
				{
					llSay(0,"Only the owner can operate this boat.");
					llUnSit(captain);
				}
				else if ((llGetAgentInfo(owner) & AGENT_ON_OBJECT))
				{
					//llWhisper(0,"Say raise to start sailing, help for sailing commands...");
					//llWhisper(0,"Wind System defaults to East Wind, 15 Knots...");

					if (llAvatarOnLinkSitTarget(1)==owner) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
					llSetLinkPrimitiveParamsFast(DECK,[PRIM_PHYSICS_SHAPE_TYPE,PRIM_PHYSICS_SHAPE_CONVEX]);

					if(prims+1==llGetNumberOfPrims())
					{
						if(combat)llShout(0,"Captain " + llKey2Name(captain) + " is aboard. COMBAT MODE.\nDamage enabled. Hit Points = " + (string)health);
						else llShout(0,"Captain " + llKey2Name(captain) + " is aboard. CRUISE MODE.\n Damage and guns disabled.");
					}
					//if (llAvatarOnLinkSitTarget(GUNNER)==gunner) llRequestPermissions(gunner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
					//if (llAvatarOnLinkSitTarget(LOOKOUT)==lookout) llRequestPermissions(lookout,PERMISSION_TRIGGER_ANIMATION);

				}
			}
		}
	}


	//BOAT CONTROLS SETUP
	run_time_permissions(integer perms) {
		if (perms & (PERMISSION_TAKE_CONTROLS)) {
			llTakeControls(CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT |
				CONTROL_ROT_LEFT | CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP,TRUE,FALSE);
			permSet=TRUE;

			animate("front");

		}
	}

	// ------------------------ END STATE DEFAULT DECLARATIONS ---

	////////////////////////////////////////////////////////////////////
	// MAIN BOAT LISTENER /////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////


	listen(integer channel, string name, key id, string msg) {
		if (channel==CHANNEL) {

			if (owner==id & llAvatarOnSitTarget()==owner) {
				if (llGetAgentInfo(owner) & AGENT_ON_OBJECT) {
					if (llGetSubString(msg,0,4)=="sheet") {
						incr=(integer)llDeleteSubString(msg,0,4);
						sheetAngle+=incr;
						if (sheetAngle>90) sheetAngle=90;
					}
					//else if (msg=="debug")
					//{
					//    debug = !debug;
					//    if (debug)llOwnerSay("Debug chat on");
					//    else llOwnerSay("Debug chat off");
					//    llMessageLinked (LINK_THIS, 0,"debug",NULL_KEY);
					//}
					//MESSAGE raise - hey we DO want to sail huh?
					else if(llGetSubString(msg,0,6)=="channel")
					{
						CHANNEL=(integer)llGetSubString(msg,7,-1);

						llListenRemove(listener);
						listener = llListen(CHANNEL,"",owner,"");
						llOwnerSay("Listen channel set to " + (string)CHANNEL);
						llSetObjectDesc((string)CHANNEL);

					}
					else if (msg=="raise") {
						raiseSail();


					}

					else if (msg=="rcs")
					{
						raiseCourse();
						sailing=TRUE;
						if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
						permSet=TRUE;
						llSetStatus(STATUS_PHYSICS,TRUE);
						llSetTimerEvent(timerFreq);
					}
					else if (msg=="rtp")
					{
						raiseTopsail();
						sailing=TRUE;
						if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
						permSet=TRUE;
						llSetStatus(STATUS_PHYSICS,TRUE);
						llSetTimerEvent(timerFreq);
					}
					else if (msg=="rtg")
					{

						raiseTopgallant();
						sailing=TRUE;
						if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
						permSet=TRUE;
						llSetStatus(STATUS_PHYSICS,TRUE);
						llSetTimerEvent(timerFreq);
					}
					else if (msg=="rry")
					{
						raiseRoyal();
						sailing=TRUE;
						if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
						permSet=TRUE;
						llSetStatus(STATUS_PHYSICS,TRUE);
						llSetTimerEvent(timerFreq);
					}
					else if (msg=="rss")
					{
						raiseStaysail();
						sailing=TRUE;
						if (!permSet) llRequestPermissions(owner,PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
						permSet=TRUE;
						llSetStatus(STATUS_PHYSICS,TRUE);
						llSetTimerEvent(timerFreq);
					}

					//MESSAGE lower - okay now we want physics ON but no sailing...
					else if (msg=="lower") lowerSail();
					else if (msg == "lcs") lowerCourse();
					else if (msg == "ltp") lowerTopsail();
					else if (msg == "ltg") lowerTopgallant();
					else if (msg == "lry") lowerRoyal();
					else if (msg == "lss") lowerStaysail();

					else if (msg=="moor") {
						moor();

						llSetTimerEvent(0);

						//llResetScript();
					}
					else if (msg=="unsit")llMessageLinked(LINK_SET, 1002, "unsit", NULL_KEY);
					else if(msg=="col")
					{
						col = !col;
						if(col)llShout(0,"Collisions on");
						else llShout(0,"Collisions off");
						llMessageLinked(LINK_SET, col, "col", NULL_KEY);
					}
					else if (msg=="shout")
					{
						shout = !shout;
						if (shout)llOwnerSay("Shout is ON");
						else llOwnerSay("Shout is OFF");
						llMessageLinked(LINK_SET, shout, "shout", NULL_KEY);
					}
					else if (msg=="combat")
					{
						combat = TRUE;
						llShout(0,llKey2Name(llGetOwner()) + " has set COMBAT MODE.\nDamage and guns enabled.");
						llMessageLinked(LINK_SET, combat, "combat", NULL_KEY);
					}
					else if(msg=="cruise")
					{
						combat = FALSE;
						llShout(0,llKey2Name(llGetOwner()) + " has set CRUISE MODE.\nDamage and guns disabled.");
						llMessageLinked(LINK_SET, combat, "combat", NULL_KEY);
					}


					else if (msg=="for")
					{
						llSetLinkPrimitiveParamsFast(prims+1, [PRIM_ROT_LOCAL,<0.00000, 0.00000, 0.00000, 1.00000>]);
						animate("front");
					}
					else if (msg == "prt")
					{
						llSetLinkPrimitiveParamsFast(prims+1, [PRIM_ROT_LOCAL,<0.00000, 0.00000, 0.00000, 1.00000>*llEuler2Rot(<0,0,-PI/4>)]);
						animate("left");
					}
					else if(msg=="stb")
					{
						llSetLinkPrimitiveParamsFast(prims+1, [PRIM_ROT_LOCAL,<0.00000, 0.00000, 0.00000, 1.00000>*llEuler2Rot(<0,0,PI/4>)]);
						animate("right");
					}
					else if (msg=="aft")
					{
						llSetLinkPrimitiveParamsFast(prims+1, [PRIM_ROT_LOCAL,<0.00000, 0.00000, 0.00000, 1.00000>*llEuler2Rot(<0,0,PI>)]);
						animate("back");
					}
					else if (msg=="hud")HUD_ON=!HUD_ON;

					else {
						float tempWind=windSpeed*convert;
						if (msg=="n"&&!combat)windDir=(90*DEG_TO_RAD);
						else if (msg=="ne"&&!combat)windDir=(45*DEG_TO_RAD);
						else if (msg=="e"&&!combat)windDir=(0*DEG_TO_RAD);
						else if (msg=="se"&&!combat)windDir=(315*DEG_TO_RAD);
						else if (msg=="s"&&!combat)windDir=(270*DEG_TO_RAD);
						else if (msg=="sw"&&!combat)windDir=(225*DEG_TO_RAD);
						else if (msg=="w"&&!combat)windDir=(180*DEG_TO_RAD);
						else if (msg=="nw"&&!combat)windDir=(135*DEG_TO_RAD);
						else if (msg=="sse"&&!combat)windDir=(293*DEG_TO_RAD);
						else if (msg=="10"&&!combat)tempWind=10;
						else if (msg=="15"&&!combat)tempWind=15;
						else if (msg=="20"&&!combat)tempWind=20;
						else if (msg=="25"&&!combat)tempWind=25;
						if(tempWind<=5||tempWind>35)
						{
							tempWind=15;
							llOwnerSay("Wind speed setting is out of range (5 - 35 knots). 15 knots applied.");
						}
						integer windRl = sl2rl((integer)(windDir*RAD_TO_DEG));
						llOwnerSay("\nWind direction = " + (string)windRl + " degrees.\nWind speed = " + (string)((integer)(tempWind)) + " knots.") ;
						windSpeed=tempWind/convert;

					}






				}
			}

			//-------------------------------- END MAIN BOAT LISTENER ---

			//llOwnerSay((string)SAIL);

		}
	}



	control(key id, integer held, integer change) {
		//turning controls - LEFT AND RIGHT KEYS

		//START TURN LEFT//


		if (( (change & held & CONTROL_LEFT) || (held & CONTROL_LEFT) || (change & held & CONTROL_ROT_LEFT) || (held & CONTROL_ROT_LEFT) ))
		{
			if (sailing)
			{
				llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<rotSpeed/2.0,0.0,rotSpeed>);
				//start rudder control
				if(!locked) llMessageLinked(LINK_THIS,-1,"moverudder",NULL_KEY);
			}
			else llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<-rotSpeed,0.0,rotSpeed/1.5>); // left key hold - end
		}
		//START TURN RIGHT//

		else if (( (change & held & CONTROL_RIGHT) || (held & CONTROL_RIGHT) || (change & held & CONTROL_ROT_RIGHT) || (held & CONTROL_ROT_RIGHT)) )
		{
			if (sailing)
			{
				llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<-rotSpeed/2.0,0.0,-rotSpeed>);
				if(!locked)llMessageLinked(LINK_THIS,1,"moverudder",NULL_KEY);
			}
			else llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<rotSpeed,0.0,-rotSpeed/1.5>); // right key hold - end
		}

		//END TURN LEFT//

		else if ( (change & ~held & CONTROL_LEFT) || (change & ~held & CONTROL_ROT_LEFT) )
		{
			llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0.0,0.0,0.0>); // left key touched - end
			llMessageLinked(LINK_THIS,1,"centrerudder",NULL_KEY);
		}

		//END TURN RIGHT//

		else if ( (change & ~held & CONTROL_RIGHT) || (change & ~held & CONTROL_ROT_RIGHT) )
		{
			llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0.0,0.0,0.0>); // right key touched - end
			llMessageLinked(LINK_THIS,-1,"centrerudder",NULL_KEY);
		}


		//sail/throttle controls - UP AND DOWN KEYS
		if ( (held & CONTROL_FWD) && (held & CONTROL_UP) )
		{
			if (sailing)
			{
				sheetAngle+=3;
				mizzenSheetAngle+=3;
				braceAngle-=3;
			}
		} // up key hold - end
		else if ( (held & CONTROL_FWD) || (change & held & CONTROL_FWD) )
		{
			if (sailing)
			{
				mizzenSheetAngle+=1;
				sheetAngle+=1;
				braceAngle-=1;
			}
		} // up key touched - .end
		else if ( (held & CONTROL_BACK) && (held & CONTROL_UP) )
		{

			if (sailing)
			{
				mizzenSheetAngle-=3;
				sheetAngle-=3;
				braceAngle+=3;
			}
		} // down key hold - end
		else if ( (held & CONTROL_BACK) || (change & held & CONTROL_BACK) )
		{
			if (sailing)
			{
				mizzenSheetAngle -=1;
				sheetAngle-=1;
				braceAngle+=1;
			}
		}
		else if (change&held&CONTROL_DOWN)
		{
			if(SAIL>3)
			{
				if(llVecMag(llGetVel())<0.5)
				{
					aback = -1;
					llOwnerSay("Square sails aback!");
				}
				else llOwnerSay("Too fast to back the sails, skipper!");
			}
			else llOwnerSay("No square sail set!");
		}
		else if (change&held&CONTROL_UP)
		{
			aback = 1;
			if(SAIL>3)llOwnerSay("Braces up, bear away!");
		}

	}

	// ------------------------------------- END GLOBAL BOAT CONTROLS ---


	///////////////////////////////////////////////////
	// GLOBAL BOAT TIMER /////////////////////////////
	// you don't want to modify these settings //////
	////////////////////////////////////////////////

	//IMPORTANT !!! THIS IS THE ACTUAL BOAT CYCLE INVOKING ALL SAILING ROUTINES
	//WHATEVER YOU DELETE HERE WILL AFFECT ACTUAL ENGINE BEHAVIOUR
	//HERE YOU MAY ADD YOUR OWN PERSONAL FUNCTIONS IF NEEDED AND YOU KNOW WHAT TO DO...


	link_message(integer from,integer to,string msg,key id) {
		if(msg=="chan")
		{
			chan=to;
		}
		else if (msg =="health")health = to;
		else if (msg == "healthTweak")healthTweak = (float)(to/10);
		else if (msg=="lockrudder")locked = to;
		else if (msg=="ready")
		{
			integer windRl = sl2rl((integer)(windDir*RAD_TO_DEG));
			llOwnerSay("\nReady to board\nListening on channel " +(string)CHANNEL + "\nWind direction = " + (string)((integer)windRl) + " degrees.\nWind speed = " + (string)((integer)(windSpeed*convert)) + " knots.");
		}


	}

	timer() {
		if(combat)
		{
			calcWindSpd();
			calcWindDir();
		}
		calcWindAngle();
		if(!combat)calcAppWindAngle();
		if (SAIL) calcDelta();
		calcHeelAngle();
		calcSpeed();
		calcLeeway();
		calcTurnRate();
		if (HUD_ON) updateHUD(1);
		else if (!HUD_ON)updateHUD(0); // update hud on cycle
		//dataString=(string)currSpeed+","+(string)leeway+","+(string)rotSpeed+","+(string)heelTorque;
		llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION,<currSpeed,leeway,0>); // boat linear movement
		llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<heelTorque,0.0,0.0>); // boat angular movement



	}

	// -------------------------------------- END GLOBAL BOAT TIMER ---


}
// ------------------------------------- END PROGRAMME -----------------------------------------------------------------------
