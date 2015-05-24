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
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


integer debug = FALSE;

key stoppedSound = "90633cd8-a8d5-2ecf-a798-e88426d0773e";
key movingSound = "c303f8c1-ecab-aeb4-6bf0-6c13d4033c89";
key bellSound = "65685ebe-5d4a-9447-28fc-7d496aaacf04";
float stoppedVol = 0.5;
float movingVol = 0.7;

list sails;

integer squareDelta;
integer braceAngle;
integer mizzenDelta;
integer stayDelta;
//variables for linked prims/agents
integer BELL;
integer GUNNER;
integer SIT1;
integer SIT2;
integer SIT3;
integer SIT4;
integer BOWWAKE;
integer STERNWAKE;
integer PENNANT;//this to signal combat mode
integer WHEEL;
integer STAY1;
integer STAY2;
integer STAY3;
integer STAY4;
integer STAY5;
integer STAY6;
integer STAY7;
integer STAY8;
integer STAY9;
integer ROYAL1;
integer ROYAL2;
integer ROYAL3;
integer TOPGALLANT1;
integer TOPGALLANT2;
integer TOPGALLANT3;
integer TOPSAIL1;
integer TOPSAIL2;
integer TOPSAIL3;
integer COURSE1;
integer COURSE2;
integer COURSE3;
integer MIZZEN;
//variables for damage
integer SMOKE1;
integer SMOKE2;
integer SMOKE3;
integer FIRE1;
integer FIRE2;
integer FIRE3;
//wake variables
integer WAKES;//starboard bow wake
integer WAKEP;//port bow wake
integer WAKER;//rudder wake
//Routine to set variables to link numbers
getLinkNums() {
	integer i;
	integer linkcount=llGetNumberOfPrims();
	for (i=1;i<=linkcount;i++) {
		string str=llGetLinkName(i);
		if (llToLower(str)=="gunner") GUNNER=i;
		if (llToLower(str)=="bell") BELL=i;
		if (llToLower(str)=="sit1") SIT1 = i;
		if (llToLower(str)=="sit2") SIT2 = i;
		if (llToLower(str)=="sit3") SIT3 = i;
		if (llToLower(str)=="sit4") SIT4 = i;
		if (llToLower(str)=="bowwake") BOWWAKE = i;
		if (llToLower(str)=="sternwake") STERNWAKE = i;
		if (llToLower(str)=="pennant") PENNANT = i;
		if (llToLower(str)=="wheel") WHEEL = i;
		if (llToLower(str)=="stay1") STAY1=i;
		if (llToLower(str)=="stay2") STAY2=i;
		if (llToLower(str)=="stay3") STAY3=i;
		if (llToLower(str)=="stay4")STAY4=i;
		if (llToLower(str)=="stay5")STAY5=i;
		if (llToLower(str)=="stay6")STAY6=i;
		if (llToLower(str)=="stay7")STAY7=i;
		if (llToLower(str)=="stay8")STAY8=i;
		if (llToLower(str)=="stay9")STAY9=i;
		if (llToLower(str)=="mizzen")MIZZEN=i;
		if (llToLower(str)=="topgallant1")TOPGALLANT1=i;
		if (llToLower(str)=="topgallant2")TOPGALLANT2=i;
		if (llToLower(str)=="topgallant3")TOPGALLANT3=i;
		if (llToLower(str)=="topsail1")TOPSAIL1=i;
		if (llToLower(str)=="topsail2")TOPSAIL2=i;
		if (llToLower(str)=="topsail3")TOPSAIL3=i;
		if (llToLower(str)=="royal1")ROYAL1=i;
		if (llToLower(str)=="royal2")ROYAL2=i;
		if (llToLower(str)=="royal3")ROYAL3=i;
		if (llToLower(str)=="course1")COURSE1=i;
		if (llToLower(str)=="course2")COURSE2=i;
		//if (llToLower(str)1=="course3")COURSE3=i;

		if (llToLower(str)=="smoke1")SMOKE1=i;
		if (llToLower(str)=="gunner")SMOKE2=i;
		if (llToLower(str)=="smoke3")SMOKE3=i;
		if (llToLower(str)=="fire1")FIRE1=i;
		if (llToLower(str)=="fire2")FIRE2=i;
		if (llToLower(str)=="fire3")FIRE3=i;

		if(llToLower(str)=="wakegeneratorstarboard")WAKES=i;
		if(llToLower(str)=="wakegeneratorport")WAKEP=i;
		if(llToLower(str)=="rudderwake")WAKER=i;

	}
	//llOwnerSay(llDumpList2String(sails," "));
}

//Sail variables
integer SAIL;
integer SS;
integer MZ;
integer CS;
integer TP;
integer TG;
integer RY;

//ANCHOR VARIABLES AND FUNCTIONS
//Anchor textures and functions
key anchor = "eea0c233-b562-3a2d-309b-4b40c02ca6c5";
integer anchored;
anchorUp()
{
	integer i;
	integer num = llGetNumberOfPrims();
	for (i=1;i<= num;i++)
	{
		if (llGetLinkName(i)== "anchordown")llSetLinkAlpha(i, 0.0, ALL_SIDES);
		if (llGetLinkName(i)== "anchorup")llSetLinkAlpha(i, 1.0, ALL_SIDES);
		if (llGetLinkName(i)== "anchor")
		{
			llSetLinkAlpha(i, 1.0, ALL_SIDES);
			llSetLinkTexture(i, anchor,1);
		}
	}
	anchored = FALSE;
}

anchorDown()
{
	integer i;
	integer num = llGetNumberOfPrims();
	for (i=1;i<= num;i++)
	{
		if (llGetLinkName(i)== "anchordown")llSetLinkAlpha(i, 1.0, ALL_SIDES);
		if (llGetLinkName(i)== "anchorup")llSetLinkAlpha(i, 0.0, ALL_SIDES);
		if (llGetLinkName(i)== "anchor")
		{
			llSetLinkAlpha(i, 0.0, ALL_SIDES);
			//llSetLinkTexture(i, anchor,1);
		}
	}
	anchored = TRUE;
}

//Sound function
loopSounds()
{
	if(llVecMag(llGetVel())<0.7)llLoopSound(stoppedSound,stoppedVol);
	else llLoopSound(movingSound,movingVol);
}

//Sail faces - these are the face numbers in the mesh of each sail, to show and hide
integer yard = 0;
integer mainFurl=1;//visible when sails lowered
integer mainFull = 2;
integer mainBacked = 3;
integer stayFurl=2;//visible when sails lowered
integer stayStbd=3;
integer stayPort=4;
integer mizzenHalyard = 0;
integer mizzenFurl = 3;
integer mizzenStbd = 4;
integer mizzenPort = 5;
integer mizzenBoom = 1;
integer mizzenBlank = 2;

//initial rotations of sails - hard coded to allow full reset to originals if things get messed up
vector initEulMain = <0,0,0>;
vector initEulMizzen = <0,0,0>;
vector initEulStay1=<0, 309.9, 90>;
vector initEulStay2=<0, 326.8, 90>;
vector initEulStay3=<0, 316.6, 90>;
vector initEulStay4=<0, 303.5, 90>;
vector initEulStay5=<0, 321.6, 90>;
vector initEulStay6=<0, 315.6, 90>;
vector initEulStay7=<0, 294.85, 90>;
vector initEulStay8=<0, 314.4, 90>;
vector initEulStay9=<0, 308.9, 90>;

rotation initRotMain;
rotation initRotMizzen;
rotation initRotStay1;
rotation initRotStay2;
rotation initRotStay3;
rotation initRotStay4;
rotation initRotStay5;
rotation initRotStay6;
rotation initRotStay7;
rotation initRotStay8;
rotation initRotStay9;

rot2eulSails()//routine at startup to convert vectors to rotations
{
	initRotMain = llEuler2Rot(DEG_TO_RAD*initEulMain);
	initRotMizzen = llEuler2Rot(DEG_TO_RAD*initEulMizzen);
	initRotStay1= llEuler2Rot(DEG_TO_RAD*initEulStay1);
	initRotStay2= llEuler2Rot(DEG_TO_RAD*initEulStay2);
	initRotStay3= llEuler2Rot(DEG_TO_RAD*initEulStay3);
	initRotStay4= llEuler2Rot(DEG_TO_RAD*initEulStay4);
	initRotStay5= llEuler2Rot(DEG_TO_RAD*initEulStay5);
	initRotStay6= llEuler2Rot(DEG_TO_RAD*initEulStay6);
	initRotStay7= llEuler2Rot(DEG_TO_RAD*initEulStay7);
	initRotStay8= llEuler2Rot(DEG_TO_RAD*initEulStay8);
	initRotStay9= llEuler2Rot(DEG_TO_RAD*initEulStay9);
	//llOwnerSay((string)initRotStay8);
}


// RAISE ROUTINE - raise sail

raiseSail()//raises all plain sail so a long list
{
	SS=TRUE;
	MZ=TRUE;
	CS=TRUE;
	TP=TRUE;
	TG=TRUE;
	RY=TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	if(debug)llOwnerSay((string)SAIL);
	llSetLinkAlpha(ROYAL1,1.0,yard);
	llSetLinkAlpha(ROYAL1,1.0,mainFull);
	llSetLinkAlpha(ROYAL1,0.0,mainBacked);
	llSetLinkAlpha(ROYAL1,0.0,mainFurl);
	llSetLinkAlpha(ROYAL2,1.0,yard);
	llSetLinkAlpha(ROYAL2,1.0,mainFull);
	llSetLinkAlpha(ROYAL2,0.0,mainBacked);
	llSetLinkAlpha(ROYAL2,0.0,mainFurl);
	llSetLinkAlpha(ROYAL3,1.0,yard);
	llSetLinkAlpha(ROYAL3,1.0,mainFull);
	llSetLinkAlpha(ROYAL3,0.0,mainBacked);
	llSetLinkAlpha(ROYAL3,0.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT1,1.0,yard);
	llSetLinkAlpha(TOPGALLANT1,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT2,1.0,yard);
	llSetLinkAlpha(TOPGALLANT2,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT3,1.0,yard);
	llSetLinkAlpha(TOPGALLANT3,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainFurl);
	llSetLinkAlpha(TOPSAIL1,1.0,yard);
	llSetLinkAlpha(TOPSAIL1,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL1,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL1,0.0,mainFurl);
	llSetLinkAlpha(TOPSAIL2,1.0,yard);
	llSetLinkAlpha(TOPSAIL2,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL2,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL2,0.0,mainFurl);
	llSetLinkAlpha(TOPSAIL3,1.0,yard);
	llSetLinkAlpha(TOPSAIL3,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL3,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL3,0.0,mainFurl);
	llSetLinkAlpha(COURSE1,1.0,yard);
	llSetLinkAlpha(COURSE1,1.0,mainFull);
	llSetLinkAlpha(COURSE1,0.0,mainBacked);
	llSetLinkAlpha(COURSE1,0.0,mainFurl);
	llSetLinkAlpha(COURSE2,1.0,yard);
	llSetLinkAlpha(COURSE2,1.0,mainFull);
	llSetLinkAlpha(COURSE2,0.0,mainBacked);
	llSetLinkAlpha(COURSE2,0.0,mainFurl);
	//llSetLinkAlpha(COURSE3,1.0,yard);
	//llSetLinkAlpha(COURSE3,1.0,mainFull);
	//llSetLinkAlpha(COURSE3,0.0,mainBacked);
	//llSetLinkAlpha(COURSE3,0.0,mainFurl);
	llSetLinkAlpha(MIZZEN,1.0,mizzenHalyard);
	llSetLinkAlpha(MIZZEN,1.0,mizzenBoom);
	llSetLinkAlpha(MIZZEN,1.0,mizzenPort);
	llSetLinkAlpha(MIZZEN,0.0,mizzenStbd);
	llSetLinkAlpha(MIZZEN,0.0,mizzenFurl);
	llSetLinkAlpha(MIZZEN,0.0,mizzenBlank);

	llSetLinkAlpha(STAY1,1.0,stayPort);
	llSetLinkAlpha(STAY1,0.0,stayStbd);
	llSetLinkAlpha(STAY1,0.0,stayFurl);

	llSetLinkAlpha(STAY2,1.0,stayPort);
	llSetLinkAlpha(STAY2,0.0,stayStbd);
	llSetLinkAlpha(STAY2,0.0,stayFurl);

	llSetLinkAlpha(STAY3,1.0,stayPort);
	llSetLinkAlpha(STAY3,0.0,stayStbd);
	llSetLinkAlpha(STAY3,0.0,stayFurl);

	llSetLinkAlpha(STAY4,1.0,stayPort);
	llSetLinkAlpha(STAY4,0.0,stayStbd);
	llSetLinkAlpha(STAY4,0.0,stayFurl);

	llSetLinkAlpha(STAY5,1.0,stayPort);
	llSetLinkAlpha(STAY5,0.0,stayStbd);
	llSetLinkAlpha(STAY5,0.0,stayFurl);

	llSetLinkAlpha(STAY6,1.0,stayPort);
	llSetLinkAlpha(STAY6,0.0,stayStbd);
	llSetLinkAlpha(STAY6,0.0,stayFurl);

	llSetLinkAlpha(STAY7,1.0,stayPort);
	llSetLinkAlpha(STAY7,0.0,stayStbd);
	llSetLinkAlpha(STAY7,0.0,stayFurl);

	llSetLinkAlpha(STAY8,1.0,stayPort);
	llSetLinkAlpha(STAY8,0.0,stayStbd);
	llSetLinkAlpha(STAY8,0.0,stayFurl);

	llSetLinkAlpha(STAY9,1.0,stayPort);
	llSetLinkAlpha(STAY9,0.0,stayStbd);
	llSetLinkAlpha(STAY9,0.0,stayFurl);
}

raiseCourse() {
	CS=TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(COURSE1,1.0,yard);
	llSetLinkAlpha(COURSE1,1.0,mainFull);
	llSetLinkAlpha(COURSE1,0.0,mainBacked);
	llSetLinkAlpha(COURSE1,0.0,mainFurl);
	llSetLinkAlpha(COURSE2,1.0,yard);
	llSetLinkAlpha(COURSE2,1.0,mainFull);
	llSetLinkAlpha(COURSE2,0.0,mainBacked);
	llSetLinkAlpha(COURSE2,0.0,mainFurl);
}

raiseTopsail() {
	TP =TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	llSetLinkAlpha(TOPSAIL1,1.0,yard);
	llSetLinkAlpha(TOPSAIL1,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL1,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL1,0.0,mainFurl);
	llSetLinkAlpha(TOPSAIL2,1.0,yard);
	llSetLinkAlpha(TOPSAIL2,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL2,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL2,0.0,mainFurl);
	llSetLinkAlpha(TOPSAIL3,1.0,yard);
	llSetLinkAlpha(TOPSAIL3,1.0,mainFull);
	llSetLinkAlpha(TOPSAIL3,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL3,0.0,mainFurl);
}

raiseTopgallant() {
	TG=TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	llSetLinkAlpha(TOPGALLANT1,1.0,yard);
	llSetLinkAlpha(TOPGALLANT1,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT2,1.0,yard);
	llSetLinkAlpha(TOPGALLANT2,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT3,1.0,yard);
	llSetLinkAlpha(TOPGALLANT3,1.0,mainFull);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainFurl);
}

raiseRoyal() {
	RY=TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	llSetLinkAlpha(ROYAL1,1.0,yard);
	llSetLinkAlpha(ROYAL1,1.0,mainFull);
	llSetLinkAlpha(ROYAL1,0.0,mainBacked);
	llSetLinkAlpha(ROYAL1,0.0,mainFurl);
	llSetLinkAlpha(ROYAL2,1.0,yard);
	llSetLinkAlpha(ROYAL2,1.0,mainFull);
	llSetLinkAlpha(ROYAL2,0.0,mainBacked);
	llSetLinkAlpha(ROYAL2,0.0,mainFurl);
	llSetLinkAlpha(ROYAL3,1.0,yard);
	llSetLinkAlpha(ROYAL3,1.0,mainFull);
	llSetLinkAlpha(ROYAL3,0.0,mainBacked);
	llSetLinkAlpha(ROYAL3,0.0,mainFurl);
}

raiseStaysail() {
	SS=TRUE;
	MZ=TRUE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(MIZZEN,1.0,mizzenHalyard);
	llSetLinkAlpha(MIZZEN,1.0,mizzenBoom);
	llSetLinkAlpha(MIZZEN,1.0,mizzenPort);
	llSetLinkAlpha(MIZZEN,0.0,mizzenStbd);
	llSetLinkAlpha(MIZZEN,0.0,mizzenFurl);
	llSetLinkAlpha(MIZZEN,0.0,mizzenBlank);

	llSetLinkAlpha(STAY1,1.0,stayPort);
	llSetLinkAlpha(STAY1,0.0,stayStbd);
	llSetLinkAlpha(STAY1,0.0,stayFurl);

	llSetLinkAlpha(STAY2,1.0,stayPort);
	llSetLinkAlpha(STAY2,0.0,stayStbd);
	llSetLinkAlpha(STAY2,0.0,stayFurl);

	llSetLinkAlpha(STAY3,1.0,stayPort);
	llSetLinkAlpha(STAY3,0.0,stayStbd);
	llSetLinkAlpha(STAY3,0.0,stayFurl);

	llSetLinkAlpha(STAY4,1.0,stayPort);
	llSetLinkAlpha(STAY4,0.0,stayStbd);
	llSetLinkAlpha(STAY4,0.0,stayFurl);

	llSetLinkAlpha(STAY5,1.0,stayPort);
	llSetLinkAlpha(STAY5,0.0,stayStbd);
	llSetLinkAlpha(STAY5,0.0,stayFurl);

	llSetLinkAlpha(STAY6,1.0,stayPort);
	llSetLinkAlpha(STAY6,0.0,stayStbd);
	llSetLinkAlpha(STAY6,0.0,stayFurl);

	llSetLinkAlpha(STAY7,1.0,stayPort);
	llSetLinkAlpha(STAY7,0.0,stayStbd);
	llSetLinkAlpha(STAY7,0.0,stayFurl);

	llSetLinkAlpha(STAY8,1.0,stayPort);
	llSetLinkAlpha(STAY8,0.0,stayStbd);
	llSetLinkAlpha(STAY8,0.0,stayFurl);

	llSetLinkAlpha(STAY9,1.0,stayPort);
	llSetLinkAlpha(STAY9,0.0,stayStbd);
	llSetLinkAlpha(STAY9,0.0,stayFurl);
}

// LOWER ROUTINE - lower sail but leave physics on
//resets the original rotations of all sails and sets their faces to show furled sails and spars only

lowerSail() {
	stayDelta=0;
	mizzenDelta=0;
	squareDelta=0;
	CS=FALSE;
	TP=FALSE;
	TG=FALSE;
	RY=FALSE;
	SS=FALSE;
	MZ=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	llSetLinkAlpha(ROYAL1,1.0,yard);
	llSetLinkAlpha(ROYAL1,0.0,mainFull);
	llSetLinkAlpha(ROYAL1,0.0,mainBacked);
	llSetLinkAlpha(ROYAL1,1.0,mainFurl);
	llSetLinkAlpha(ROYAL2,1.0,yard);
	llSetLinkAlpha(ROYAL2,0.0,mainFull);
	llSetLinkAlpha(ROYAL2,0.0,mainBacked);
	llSetLinkAlpha(ROYAL2,1.0,mainFurl);
	llSetLinkAlpha(ROYAL3,1.0,yard);
	llSetLinkAlpha(ROYAL3,0.0,mainFull);
	llSetLinkAlpha(ROYAL3,0.0,mainBacked);
	llSetLinkAlpha(ROYAL3,1.0,mainFurl);

	llSetLinkAlpha(TOPGALLANT1,1.0,yard);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT1,1.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT2,1.0,yard);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT2,1.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT3,1.0,yard);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT3,1.0,mainFurl);
	llSetLinkAlpha(TOPSAIL1,1.0,yard);
	llSetLinkAlpha(TOPSAIL1,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL1,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL1,1.0,mainFurl);
	llSetLinkAlpha(TOPSAIL2,1.0,yard);
	llSetLinkAlpha(TOPSAIL2,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL2,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL2,1.0,mainFurl);
	llSetLinkAlpha(TOPSAIL3,1.0,yard);
	llSetLinkAlpha(TOPSAIL3,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL3,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL3,1.0,mainFurl);
	llSetLinkAlpha(COURSE1,1.0,yard);
	llSetLinkAlpha(COURSE1,0.0,mainFull);
	llSetLinkAlpha(COURSE1,0.0,mainBacked);
	llSetLinkAlpha(COURSE1,1.0,mainFurl);
	llSetLinkAlpha(COURSE2,1.0,yard);
	llSetLinkAlpha(COURSE2,0.0,mainFull);
	llSetLinkAlpha(COURSE2,0.0,mainBacked);
	llSetLinkAlpha(COURSE2,1.0,mainFurl);
	//llSetLinkAlpha(COURSE3,1.0,yard);
	//llSetLinkAlpha(COURSE3,0.0,mainFull);
	//llSetLinkAlpha(COURSE3,0.0,mainBacked);
	//llSetLinkAlpha(COURSE3,1.0,mainFurl);
	llSetLinkAlpha(MIZZEN,1.0,mizzenHalyard);
	llSetLinkAlpha(MIZZEN,1.0,mizzenBoom);
	llSetLinkAlpha(MIZZEN,0.0,mizzenPort);
	llSetLinkAlpha(MIZZEN,0.0,mizzenStbd);
	llSetLinkAlpha(MIZZEN,1.0,mizzenFurl);
	llSetLinkAlpha(MIZZEN,0.0,mizzenBlank);

	llSetLinkAlpha(STAY1,0.0,stayPort);
	llSetLinkAlpha(STAY1,0.0,stayStbd);
	llSetLinkAlpha(STAY1,1.0,stayFurl);

	llSetLinkAlpha(STAY2,0.0,stayPort);
	llSetLinkAlpha(STAY2,0.0,stayStbd);
	llSetLinkAlpha(STAY2,1.0,stayFurl);

	llSetLinkAlpha(STAY3,0.0,stayPort);
	llSetLinkAlpha(STAY3,0.0,stayStbd);
	llSetLinkAlpha(STAY3,1.0,stayFurl);

	llSetLinkAlpha(STAY4,0.0,stayPort);
	llSetLinkAlpha(STAY4,0.0,stayStbd);
	llSetLinkAlpha(STAY4,1.0,stayFurl);

	llSetLinkAlpha(STAY5,0.0,stayPort);
	llSetLinkAlpha(STAY5,0.0,stayStbd);
	llSetLinkAlpha(STAY5,1.0,stayFurl);

	llSetLinkAlpha(STAY6,0.0,stayPort);
	llSetLinkAlpha(STAY6,0.0,stayStbd);
	llSetLinkAlpha(STAY6,1.0,stayFurl);

	llSetLinkAlpha(STAY7,0.0,stayPort);
	llSetLinkAlpha(STAY7,0.0,stayStbd);
	llSetLinkAlpha(STAY7,1.0,stayFurl);

	llSetLinkAlpha(STAY8,0.0,stayPort);
	llSetLinkAlpha(STAY8,0.0,stayStbd);
	llSetLinkAlpha(STAY8,1.0,stayFurl);

	llSetLinkAlpha(STAY9,0.0,stayPort);
	llSetLinkAlpha(STAY9,0.0,stayStbd);
	llSetLinkAlpha(STAY9,1.0,stayFurl);

	squareDelta=0;
	braceAngle=0;
	mizzenDelta=0;
	stayDelta=0;
	setDelta();
}

lowerCourse() {
	CS=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(COURSE1,1.0,yard);
	llSetLinkAlpha(COURSE1,0.0,mainFull);
	llSetLinkAlpha(COURSE1,0.0,mainBacked);
	llSetLinkAlpha(COURSE1,1.0,mainFurl);
	llSetLinkAlpha(COURSE2,1.0,yard);
	llSetLinkAlpha(COURSE2,0.0,mainFull);
	llSetLinkAlpha(COURSE2,0.0,mainBacked);
	llSetLinkAlpha(COURSE2,1.0,mainFurl);
	//llSetLinkAlpha(COURSE3,1.0,yard);
	//llSetLinkAlpha(COURSE3,0.0,mainFull);
	//llSetLinkAlpha(COURSE3,0.0,mainBacked);
	//llSetLinkAlpha(COURSE3,1.0,mainFurl);
}

lowerTopsail() {
	TP=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(TOPSAIL1,1.0,yard);
	llSetLinkAlpha(TOPSAIL1,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL1,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL1,1.0,mainFurl);
	llSetLinkAlpha(TOPSAIL2,1.0,yard);
	llSetLinkAlpha(TOPSAIL2,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL2,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL2,1.0,mainFurl);
	llSetLinkAlpha(TOPSAIL3,1.0,yard);
	llSetLinkAlpha(TOPSAIL3,0.0,mainFull);
	llSetLinkAlpha(TOPSAIL3,0.0,mainBacked);
	llSetLinkAlpha(TOPSAIL3,1.0,mainFurl);
}

lowerTopgallant() {
	TG=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(TOPGALLANT1,1.0,yard);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT1,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT1,1.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT2,1.0,yard);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT2,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT2,1.0,mainFurl);
	llSetLinkAlpha(TOPGALLANT3,1.0,yard);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainFull);
	llSetLinkAlpha(TOPGALLANT3,0.0,mainBacked);
	llSetLinkAlpha(TOPGALLANT3,1.0,mainFurl);
}

lowerRoyal() {
	RY=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;
	llSetLinkAlpha(ROYAL1,1.0,yard);
	llSetLinkAlpha(ROYAL1,0.0,mainFull);
	llSetLinkAlpha(ROYAL1,0.0,mainBacked);
	llSetLinkAlpha(ROYAL1,1.0,mainFurl);
	llSetLinkAlpha(ROYAL2,1.0,yard);
	llSetLinkAlpha(ROYAL2,0.0,mainFull);
	llSetLinkAlpha(ROYAL2,0.0,mainBacked);
	llSetLinkAlpha(ROYAL2,1.0,mainFurl);
	llSetLinkAlpha(ROYAL3,1.0,yard);
	llSetLinkAlpha(ROYAL3,0.0,mainFull);
	llSetLinkAlpha(ROYAL3,0.0,mainBacked);
	llSetLinkAlpha(ROYAL3,1.0,mainFurl);
}

lowerStaysail() {
	SS=FALSE;
	MZ=FALSE;
	SAIL = CS+TP+TG+RY+MZ+SS;

	llSetLinkAlpha(MIZZEN,1.0,mizzenHalyard);
	llSetLinkAlpha(MIZZEN,1.0,mizzenBoom);
	llSetLinkAlpha(MIZZEN,0.0,mizzenPort);
	llSetLinkAlpha(MIZZEN,0.0,mizzenStbd);
	llSetLinkAlpha(MIZZEN,1.0,mizzenFurl);
	llSetLinkAlpha(MIZZEN,0.0,mizzenBlank);

	llSetLinkAlpha(STAY1,0.0,stayPort);
	llSetLinkAlpha(STAY1,0.0,stayStbd);
	llSetLinkAlpha(STAY1,1.0,stayFurl);

	llSetLinkAlpha(STAY2,0.0,stayPort);
	llSetLinkAlpha(STAY2,0.0,stayStbd);
	llSetLinkAlpha(STAY2,1.0,stayFurl);

	llSetLinkAlpha(STAY3,0.0,stayPort);
	llSetLinkAlpha(STAY3,0.0,stayStbd);
	llSetLinkAlpha(STAY3,1.0,stayFurl);

	llSetLinkAlpha(STAY4,0.0,stayPort);
	llSetLinkAlpha(STAY4,0.0,stayStbd);
	llSetLinkAlpha(STAY4,1.0,stayFurl);

	llSetLinkAlpha(STAY5,0.0,stayPort);
	llSetLinkAlpha(STAY5,0.0,stayStbd);
	llSetLinkAlpha(STAY5,1.0,stayFurl);

	llSetLinkAlpha(STAY6,0.0,stayPort);
	llSetLinkAlpha(STAY6,0.0,stayStbd);
	llSetLinkAlpha(STAY6,1.0,stayFurl);

	llSetLinkAlpha(STAY7,0.0,stayPort);
	llSetLinkAlpha(STAY7,0.0,stayStbd);
	llSetLinkAlpha(STAY7,1.0,stayFurl);

	llSetLinkAlpha(STAY8,0.0,stayPort);
	llSetLinkAlpha(STAY8,0.0,stayStbd);
	llSetLinkAlpha(STAY8,1.0,stayFurl);

	llSetLinkAlpha(STAY9,0.0,stayPort);
	llSetLinkAlpha(STAY9,0.0,stayStbd);
	llSetLinkAlpha(STAY9,1.0,stayFurl);
}

//minus values of delta for fore and aft sails indicate wind from starboard, so set port side visible.
setDelta()
{

	llSetLinkPrimitiveParamsFast(COURSE1,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(COURSE2,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPSAIL1,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPSAIL2,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPSAIL3,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPGALLANT1,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPGALLANT2,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(TOPGALLANT3,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(ROYAL1,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(ROYAL2,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);

	llSetLinkPrimitiveParamsFast(ROYAL3,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,(braceAngle)*DEG_TO_RAD>)*initRotMain]);


	if (MZ)llSetLinkPrimitiveParamsFast(MIZZEN,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,mizzenDelta*DEG_TO_RAD>)*initRotMizzen]);
	else llSetLinkPrimitiveParamsFast(MIZZEN,[PRIM_ROT_LOCAL,initRotMizzen]);

	if(mizzenDelta>0&&MZ)
	{
		llSetLinkAlpha(MIZZEN,0.0,mizzenPort);
		llSetLinkAlpha(MIZZEN,1.0,mizzenStbd);
	}
	else if(mizzenDelta<0&&MZ)
	{
		llSetLinkAlpha(MIZZEN,1.0,mizzenPort);
		llSetLinkAlpha(MIZZEN,0.0,mizzenStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY1,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay1]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY1,0.0,stayPort);
		llSetLinkAlpha(STAY1,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY1,1.0,stayPort);
		llSetLinkAlpha(STAY1,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY2,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay2]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY2,0.0,stayPort);
		llSetLinkAlpha(STAY2,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY2,1.0,stayPort);
		llSetLinkAlpha(STAY2,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY3,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay3]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY3,0.0,stayPort);
		llSetLinkAlpha(STAY3,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY3,1.0,stayPort);
		llSetLinkAlpha(STAY3,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY4,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay4]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY4,0.0,stayPort);
		llSetLinkAlpha(STAY4,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{

		llSetLinkAlpha(STAY4,1.0,stayPort);
		llSetLinkAlpha(STAY4,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY5,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay5]);
	if(stayDelta>0)
	{
		llSetLinkAlpha(STAY5,0.0,stayPort);
		llSetLinkAlpha(STAY5,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{

		llSetLinkAlpha(STAY5,1.0,stayPort);
		llSetLinkAlpha(STAY5,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY6,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay6]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY6,0.0,stayPort);
		llSetLinkAlpha(STAY6,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{

		llSetLinkAlpha(STAY6,1.0,stayPort);
		llSetLinkAlpha(STAY6,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY7,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay7]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY7,0.0,stayPort);
		llSetLinkAlpha(STAY7,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY7,1.0,stayPort);
		llSetLinkAlpha(STAY7,0.0,stayStbd);
	}


	llSetLinkPrimitiveParamsFast(STAY8,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay8]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY8,0.0,stayPort);
		llSetLinkAlpha(STAY8,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY8,1.0,stayPort);
		llSetLinkAlpha(STAY8,0.0,stayStbd);
	}
	llSetLinkPrimitiveParamsFast(STAY9,[PRIM_ROT_LOCAL,llEuler2Rot(<0.0,0.0,stayDelta*DEG_TO_RAD>)*initRotStay9]);
	if(stayDelta>0&&SS)
	{
		llSetLinkAlpha(STAY9,0.0,stayPort);
		llSetLinkAlpha(STAY9,1.0,stayStbd);
	}
	else if(stayDelta<0&&SS)
	{
		llSetLinkAlpha(STAY9,1.0,stayPort);
		llSetLinkAlpha(STAY9,0.0,stayStbd);
	}
}

fire(integer linkNumber)
{
	llLinkParticleSystem(linkNumber,[PSYS_PART_FLAGS,PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK|PSYS_PART_EMISSIVE_MASK,
		PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,
		PSYS_SRC_TEXTURE,"af8eacf6-44b7-51a8-9045-443f4093d97a",
		PSYS_PART_START_COLOR,<1.,1.,1.>,
		PSYS_PART_END_COLOR,<.6,.0,.0>,
		PSYS_PART_START_ALPHA,1.0,
		PSYS_PART_END_ALPHA,0.0,
		PSYS_PART_START_SCALE,<4,4,4>,
		PSYS_PART_END_SCALE,<2,2,2>,
		PSYS_PART_MAX_AGE,1.7,
		PSYS_SRC_ACCEL,<0,0,2>,

		PSYS_SRC_BURST_RATE,.01,
		PSYS_SRC_ANGLE_BEGIN,0.,
		PSYS_SRC_ANGLE_END,0.,
		PSYS_SRC_BURST_PART_COUNT,1,
		PSYS_SRC_BURST_RADIUS,0.2,
		PSYS_SRC_BURST_SPEED_MIN,0.01,
		PSYS_SRC_BURST_SPEED_MAX,0.05,
		PSYS_SRC_MAX_AGE,0,
		PSYS_SRC_OMEGA,<0.,0.,0.>]);
}

smoke(integer linkNumber)
{
	llLinkParticleSystem(linkNumber,[
		PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_WIND_MASK,
		PSYS_PART_START_COLOR, <.5,.5,.5>,
		PSYS_PART_START_ALPHA, 1.0,
		PSYS_PART_END_COLOR, <0,0,0>,
		PSYS_PART_END_ALPHA, 0.0,
		PSYS_PART_START_SCALE, <1,1,0>,
		PSYS_PART_END_SCALE, <5,5,0>,
		PSYS_PART_MAX_AGE, 10.0,
		PSYS_SRC_ACCEL, <0.0,0.00,.5>,
		PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
		PSYS_SRC_BURST_RATE, 0.1,
		PSYS_SRC_BURST_PART_COUNT, 3,
		PSYS_SRC_BURST_RADIUS, 0.00,
		PSYS_SRC_BURST_SPEED_MIN, 0.00,
		PSYS_SRC_BURST_SPEED_MAX, 0.50,
		PSYS_SRC_MAX_AGE, 0.0,
		PSYS_SRC_TEXTURE, "d1df5743-efa9-8fab-0d2f-8c206931299b",
		PSYS_SRC_OMEGA, <0.00,0.00,0.00>
			]);
}

bowWake(integer linkNum) //bow wakes
{
	if ( llVecMag(llGetVel()) < 1.0 )
	{
		llLinkParticleSystem(linkNum,[] );
		return;
	}
	else llLinkParticleSystem(linkNum,[  PSYS_PART_MAX_AGE,10.0,
		PSYS_PART_FLAGS,PSYS_PART_INTERP_COLOR_MASK| PSYS_PART_INTERP_SCALE_MASK| PSYS_PART_FOLLOW_VELOCITY_MASK,
		PSYS_PART_START_COLOR, <1,1,1>,
		PSYS_PART_END_COLOR, <.5,.6,1>,
		PSYS_PART_START_SCALE,<1.0, 1.0, FALSE>,
		PSYS_PART_END_SCALE,<1.5,1.5, FALSE>,
		PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE,
		PSYS_SRC_BURST_RATE,0.3,
		PSYS_SRC_ACCEL, <0,0,0.0>,
		PSYS_SRC_ANGLE_BEGIN, (float) 0.25*PI,
		PSYS_SRC_ANGLE_END, (float)0*PI,
		PSYS_SRC_BURST_PART_COUNT,60,
		//  PSYS_SRC_BURST_RADIUS,radius,
		PSYS_SRC_BURST_SPEED_MIN,0.1,
		PSYS_SRC_BURST_SPEED_MAX,1.0,
		PSYS_SRC_MAX_AGE, 10.0,
		//PSYS_SRC_TEXTURE, texture,//llGetInventoryName(INVENTORY_TEXTURE, 0),
		PSYS_PART_START_ALPHA, .5,
		PSYS_PART_END_ALPHA, .1
			]);

}

rudderWake(integer linkNum)
{
	float angle1;
	float angle2;
	if ( llVecMag(llGetVel()) < 1.0 )
	{
		llLinkParticleSystem(linkNum, [] );
		return;
	}
	else if ( llVecMag(llGetVel()) < 3.0 )
	{
		angle1 = 0.2*PI;
		angle2 = 0.3*PI;
	}
	else if ( llVecMag(llGetVel()) > 3.0 )
	{
		angle1 = 0.25*PI;
		angle2 = 0.4*PI;
	}
	llLinkParticleSystem(linkNum,[  PSYS_PART_MAX_AGE,10.0,
		PSYS_PART_FLAGS,PSYS_PART_INTERP_COLOR_MASK| PSYS_PART_INTERP_SCALE_MASK,
		PSYS_PART_START_COLOR, <1,1,1>,
		PSYS_PART_END_COLOR, <.5,.6,1>,
		PSYS_PART_START_SCALE,<1.0, 1.0, FALSE>,
		PSYS_PART_END_SCALE,<1.5,1.5, FALSE>,
		PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE,
		PSYS_SRC_BURST_RATE,0.01,
		PSYS_SRC_ACCEL, <0,0,0.0>,
		PSYS_SRC_ANGLE_BEGIN, (float) 0.2*PI,
		PSYS_SRC_ANGLE_END, (float)0.3*PI,
		PSYS_SRC_BURST_PART_COUNT,10,
		//  PSYS_SRC_BURST_RADIUS,radius,
		PSYS_SRC_BURST_SPEED_MIN,0.1,
		PSYS_SRC_BURST_SPEED_MAX,1.0,
		PSYS_SRC_MAX_AGE, 0,
		//PSYS_SRC_TEXTURE, texture,//llGetInventoryName(INVENTORY_TEXTURE, 0),
		PSYS_PART_START_ALPHA, 0.5,
		PSYS_PART_END_ALPHA, 0.1
			]);
}
default
{
	on_rez(integer rez)
	{
		llLinkParticleSystem(SMOKE1,[]);
		llLinkParticleSystem(SMOKE2,[]);
		llLinkParticleSystem(SMOKE3,[]);
		llLinkParticleSystem(FIRE1,[]);
		llLinkParticleSystem(FIRE2,[]);
		llLinkParticleSystem(FIRE3,[]);
		llStopSound();
		llSetTimerEvent(0.5);
		bowWake(WAKES);
		bowWake(WAKEP);
		rudderWake(WAKER);
	}
	state_entry()
	{
		getLinkNums();
		rot2eulSails();
		lowerSail();
		loopSounds();
		llLinkParticleSystem(SMOKE1,[]);
		llLinkParticleSystem(SMOKE2,[]);
		llLinkParticleSystem(SMOKE3,[]);
		llLinkParticleSystem(FIRE1,[]);
		llLinkParticleSystem(FIRE2,[]);
		llLinkParticleSystem(FIRE3,[]);
		llStopSound();
		llSetTimerEvent(0.5);
		bowWake(WAKES);
		bowWake(WAKEP);
		rudderWake(WAKER);
		llMessageLinked(LINK_THIS,0,"ready",NULL_KEY);
	}

	link_message(integer from, integer to, string str, key id)
	{
		//to is delta
		//str = mizzen, square, stay
		//num 1001 and "raise"
		//num 1000 and "lower"
		//
		if (llToLower(str) == "lower")lowerSail();
		else if (llToLower(str) == "lcs")lowerCourse();
		else if (llToLower(str) == "ltp")lowerTopsail();
		else if (llToLower(str) == "ltg")lowerTopgallant();
		else if (llToLower(str) == "lry")lowerRoyal();
		//else if (llToLower(str) == "lmz")lowerMizzen();
		else if (llToLower(str) == "lss")lowerStaysail();

		//else if (llToLower(str) == "loopSounds") loopSounds();
		else if (str == "anchorUp")anchorUp();
		else if (str == "anchorDown")
		{
			anchorDown();
			llLoopSound(stoppedSound,stoppedVol);
		}
		else if (llToLower(str) == "raise") raiseSail();
		else if (llToLower(str) == "rcs")raiseCourse();
		else if (llToLower(str) == "rtp")raiseTopsail();
		else if (llToLower(str) == "rtg")raiseTopgallant();
		else if (llToLower(str) == "rry")raiseRoyal();
		//else if (llToLower(str) == "rmz")raiseMizzen();
		else if (llToLower(str) == "rss")raiseStaysail();
		else if (llToLower(str) == "mizzen")
		{
			mizzenDelta += to;
			setDelta();
		}
		else if (llToLower(str) == "stay")
		{
			stayDelta += to/2;
			setDelta();
		}

		else if (llToLower(str) == "square")
		{
			squareDelta += to;
			//setDelta();
		}
		else if (llToLower(str) =="brace")
		{
			braceAngle = -to;
			setDelta();
		}
		else if (llToLower(str)=="smoke")
		{
			smoke(SMOKE1);
			smoke(SMOKE2);
			smoke(SMOKE3);
		}

		else if(llToLower(str) == "incap")
		{
			llLoopSound("3643f41e-fc7b-d44c-120a-35a9aecb4de7",1.);
			llSleep(.1);
			fire(FIRE1);
			fire(FIRE2);
			fire(FIRE3);
			//llSetTimerEvent(20);
		}
		else if(llToLower(str) == "reset")
		{
			llParticleSystem([]);
			llSleep(2.0);
			llResetScript();
		}
		else if(llToLower(str) == "sinking")
		{
			bowWake(WAKES);
			bowWake(WAKEP);
			rudderWake(WAKER);
			llStopSound();
			state sinking;
		}

	}
	timer()
	{
		bowWake(WAKES);
		bowWake(WAKEP);
		rudderWake(WAKER);
		loopSounds();
	}
	touch_start(integer touched)
	{
		if (llDetectedLinkNumber(0)==BELL)
		{
			llStopSound();
			llPlaySound(bellSound,1.0);
			llSleep(2.0);
			loopSounds();
		}

	}

}
state sinking
{
	on_rez(integer rezzed)
	{
		llResetScript();
	}
	state_entry()
	{
		llSetTimerEvent(5.0);

	}

	timer()
	{
		llSetTimerEvent(0);

		llLinkParticleSystem(SMOKE1,[]);
		llLinkParticleSystem(SMOKE2,[]);
		llLinkParticleSystem(SMOKE3,[]);
		llLinkParticleSystem(FIRE1,[]);
		llLinkParticleSystem(FIRE2,[]);
		llLinkParticleSystem(FIRE3,[]);
		llStopSound();
	}
}
