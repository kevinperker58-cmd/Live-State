main();

new const AllowedServers[][] = 
{
	// Allowed servers
    "188.127.241.74:3377",
	"188.127.241.74:3377"
};

#pragma dynamic 6250
#pragma warning disable 239
// #pragma warning disable 214
#pragma warning disable 202
#pragma warning disable 203
#pragma warning disable 213
#pragma warning disable 234
#pragma warning disable 216
#pragma warning disable 219
#pragma warning disable 209
#pragma warning disable 202
#pragma warning disable 201
#pragma warning disable 225
#pragma warning disable 200
#pragma warning disable 211
#pragma warning disable 204
#pragma warning disable 201
#pragma warning disable 208
#pragma warning disable 215
#pragma warning disable 235
#pragma warning disable 217
#pragma warning disable 212
#pragma warning disable 228
#pragma warning disable 205
#include <a_samp>
#include <a_http>

// -- mx.txt
#include <mxINI>

// -- include
#include "../include/a_mysql.inc"
#include "../include/Pawn.CMD.inc" // -- Pawn command system, do not touch
#include "../include/Pawn.RakNet.inc" // -- RakNet info for work with network
#include "../include/streamer.inc"
#include "../include/sscanf2.inc"
#include "../include/foreach.inc"
#include "../include/lib/m_crzones.inc"
#include "../include/lib/m_crp.inc"
#include "../include/lib/m_dialog.inc"
#include "../include/mxdate.inc"
#include "../include/fdialog.inc"
#include "../include/fly.inc"
//#include "../include/packet.inc"
//#include "../include/rpc.inc"
#include "../include/json.inc"

// -- system
#include "../include/system/cp.pwn"
#include "../include/system/cp_race.pwn"
#include "../include/system/pickup.pwn"
#include "../include/system/vehicle.pwn"

#include <voicechat> // -- Do not uncomment this

//#include <pawncmd> // -- Comment
#include <pawnraknet> // -- fix

// -- pr
#define FOREACH_I_Bot 0
#define FOREACH_I_Character 0
#define OC_VEHICLE_ID   0
new bool:agmtestActive[MAX_PLAYERS];
#define VEHICLE_START_ENGINE 100
new g_HandshakeOffer[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
#define DIALOG_CAR_SELECT 9877
#define DIALOG_SKINDON_SELECT 9876

new TuningGUITimer[MAX_PLAYERS];

#define DIALOG_NEON 6789

#define DIALOG_TUNING_MAIN 1000
#define DIALOG_TINT 1001
#define DIALOG_VINYL 1002
#define DIALOG_SUSPENSION_BIAS 1003
#define DIALOG_WHEEL_RADIUS 1004
#define DIALOG_CAMBER 1006
#define DIALOG_WHEEL_OFFSET 1007
#define DIALOG_WHEEL_WIDTH 1008
#define DIALOG_STROBOSCOPE 1010
#define DIALOG_HYDRAULICS 1011
#define DIALOG_LAUNCH_CONTROL 1012
#define DIALOG_EXHAUST 1013
#define DIALOG_SIREN_TOGGLE 1015
#define DIALOG_DRIFT 1016
#define DIALOG_NUMBER_PLATE 1017
#define DIALOG_HORN_SOUND 1018
#define DIALOG_CHIP_TUNE 1019
#define DIALOG_HIGHLIGHT 1020

new GZCheckTimerId = -1; // Initialization check timer for GZ zones

#define MAX_RENT_ZONES 100
#define MAX_PARKING_PER_ZONE 5
new FamilyAreaID;

new NumberAreaID;

#define MAX_DPS_POSTS 10

enum e_dps_post
{
    Float:DPS_X,
    Float:DPS_Y,
    Float:DPS_Z,
    DPS_AREA_ID
}
static bool:player_unlock_notif_shown[MAX_PLAYERS];
//////////////////Containers
#define MAX_CONT 12
#define CLR_RED 0xFF0000FF
#define CLR_GREEN 0x00FF00FF
#define CLR_YELLOW 0xFF5252FF
#define CLR_WHITE 0xFFFFFFFF
#define DIALOG_CONT_BET 19996
// Structure for prize information
enum PrizeInfo
{
    PRIZE_REGION,        // Prize region
    PRIZE_ID,            // Prize ID for display
    PRIZE_NAME[64],      // Prize name
    PRIZE_PRICE,         // Prize price
};

// Structure for container information
enum Cont_Info
{
    ContObjectId,
    ContObjectDoorLId,
    ContObjectDoorRId,
    ContObjectOdejdaId,
    ContVehicleId,
    ContVehicleColor,

    ContRegion,
    ItemType,
    Item,
    ContPrice,
    ItemPrice,
    
    bool:Saled,
    SaleTime,

    BetPrice,
    BetedId,
    BetedName[MAX_PLAYER_NAME],
};
new cInfo[MAX_CONT + 1][Cont_Info]; // +1, because arrays are indexed from 1 to MAX_CONT

enum P_Info
{
    BetUseCont,
    BuyUseCont,
}
new pInfo[MAX_PLAYERS][P_Info];
new Text3D:ContsText[MAX_CONT + 1];
new ContsZone[MAX_CONT + 1];
new ContsTimer[MAX_CONT + 1];

new Text:cont_fon;
new Text:cont_take;
new Text:cont_sell;
new Text:cont_close;
new Text:cont_name[MAX_CONT + 1];
new Text:cont_price[MAX_CONT + 1];
new Text:cont_model[MAX_CONT + 1];

enum RegionPrizes {
    REGION_RUSSIA = 1,
    REGION_CHINA,
    REGION_DUBAI,
    REGION_GERMANY
};
new const cSkin_Info[][PrizeInfo] = {
    // Russia
    {REGION_RUSSIA, 152, "Clothes", 236000},
    {REGION_RUSSIA, 240, "Clothes", 90000},
    {REGION_RUSSIA, 182, "Clothes", 175000},
    {REGION_RUSSIA, 85, "Clothes", 36000},
    {REGION_RUSSIA, 7, "Clothes", 45000},
    {REGION_RUSSIA, 91, "Clothes", 38610},
    {REGION_RUSSIA, 56, "Clothes", 105300},
    {REGION_RUSSIA, 122, "Clothes", 1000000},
    {REGION_RUSSIA, 75, "Clothes", 500000},
    {REGION_RUSSIA, 66, "Clothes", 133333},
    {REGION_RUSSIA, 45, "Clothes", 80000},
    {REGION_RUSSIA, 78, "Clothes", 50000},

    // China
    {REGION_DUBAI, 300, "Clothes", 1000000},
    {REGION_DUBAI, 211, "Clothes", 5000000},
    {REGION_DUBAI, 99, "Clothes", 3500000},
    {REGION_DUBAI, 102, "Clothes", 600000},
    {REGION_DUBAI, 125, "Clothes", 1000000},
    {REGION_DUBAI, 101, "Clothes", 3850000}
};
new const cCar_Info[][PrizeInfo] = {
    // Russia
    {REGION_RUSSIA, 404, "VAZ 2107", 50000},
    {REGION_RUSSIA, 555, "ZAZ 968", 20000},
    {REGION_RUSSIA, 401, "VAZ 2101", 42000},
    {REGION_RUSSIA, 401, "Lada Granta", 320000},
    {REGION_RUSSIA, 413, "Gazelle 3221", 1500000},

    // China
    {REGION_CHINA, 461, "Ducati SuperSport S", 1647000},
    {REGION_CHINA, 523, "Yamaha FZ-10", 3905000},
    {REGION_CHINA, 522, "Kawasaki Ninja H2R", 3500000},
    {REGION_CHINA, 526, "Infiniti Q60S", 1700000},
    {REGION_CHINA, 603, "Ford Mustang GT", 1500000},
    {REGION_CHINA, 562, "Nissan Skyline R34", 500000},
    {REGION_CHINA, 502, "Nissan GT-R R35", 7110000},
    {REGION_CHINA, 461, "Ducati SuperSport S", 1647000},
    {REGION_CHINA, 461, "Ducati SuperSport S", 1647000},
    {REGION_CHINA, 445, "Acura TSX", 1035000},
    {REGION_CHINA, 527, "BMW M3 E46", 945000},

    // Dubai
    {REGION_DUBAI, 494, "BMW I8 EDrive", 11850000},
    {REGION_DUBAI, 2549, "Lamborghini Huracan", 14850000},
    {REGION_DUBAI, 2551, "Lamborghini Urus", 13770000},
    {REGION_DUBAI, 400, "BMW X6M F16", 7740000},
    {REGION_DUBAI, 505, "Cadillac Escalade", 6480000},
    {REGION_DUBAI, 475, "Audi Q7", 5400000},
    {REGION_DUBAI, 466, "BMW M5 F90", 8910000},
    {REGION_DUBAI, 502, "Nissan GT-R R35", 7110000},
    {REGION_DUBAI, 604, "Porsche Panamera S", 8100000},
    {REGION_DUBAI, 480, "BMW Z4 M40i", 4410000},
    {REGION_DUBAI, 470, "Gold Car", 30000000},
    {REGION_DUBAI, 500, "Car 69", 30000000},
    {REGION_DUBAI, 596, "BMW M5 F90 (Gold)", 30000000},
    {REGION_DUBAI, 490, "Range Rover SVR", 0},
    {REGION_DUBAI, 429, "Mercedes-Benz GT-R", 12150000},

    // Germany
    {REGION_GERMANY, 461, "Ducati SuperSport S", 1647000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 523, "Yamaha FZ-10", 3905000},
    {REGION_GERMANY, 400, "BMW X6M F16", 7740000},
    {REGION_GERMANY, 402, "Mercedes Benz GT63s", 6320000},
    {REGION_GERMANY, 480, "BMW Z4 M40i", 4410000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 565, "Mercedes-Benz A45 AMG", 2200000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 415, "Lamborghini Aventador S", 10000000}
};
// Structure for region information and pricing
enum RegionInfo
{
    RegionName[15],
    ClothesPrice,
    VehiclePrice,
    ContModelId,
    VorotaModelId,
};
// Region data with price and models and doors
new const g_RegionData[5][RegionInfo] =
{   // {Name, Price skin, Price car, Model, Model door}
    {"", 0, 0},
    {"Russia", 100000, 200000, 934, 933},
    {"China", 900000, 2000000, 954, 953},
    {"Dubai", 4350000, 9000000, 956, 955},
    {"Germany", 900000, 2000000, 958, 957}
};
// North + 128, South - 128
new Float: cContsPos[12][12] =
{   //{X,       Y,         Z,      Angle,     X Door1,Y Door1,Z Door1, A,      X Door2, Y Door2, Z Door2,  A}
    {690.51898,1738.27002,12.73000,0.00000,   685.03,1736.35,10.94,0.0,      685.16,1740.18,10.94,-181.0},
    {690.51898,1731.78003,12.73000,0.00000,   685.02,1729.86,10.94,0.0,      685.13,1733.69,10.94,-180.0},
    {665.81897,1726.96997,12.73000,270.00000, 663.90,1732.45,10.94,-90.0,    667.73,1732.33,10.94,90.0},
    {680.23999,1694.77002,12.73000,270.00000, 678.42,1700.18,10.94957,-89.0, 682.15,1700.08,10.94,89.0},
    {672.75598,1694.77002,12.73000,270.00000, 670.84,1700.21,10.94,-90.0,    674.67,1700.11,10.94,90.0},
    {665.81897,1694.77002,12.73000,270.00000, 663.90,1700.18,10.94,-89.0,    667.72,1700.10,10.94,90.0},
    {655.51898,1676.51001,12.73000,0.00000,   650.07,1674.59,10.94,0.0,      650.17,1678.42,10.94,180.0},
    {655.51898,1669.80005,12.73000,0.00000,   650.07,1667.88,10.94,0.0,      650.16,1671.71,10.94,180.0},
    {655.51898,1663.40002,12.73000,0.00000,   650.05,1661.48,10.94,0.0,      650.20,1665.31,10.94,180.0},
    {631.91901,1709.30005,12.73000,180.00000, 637.38,1711.21,10.94,180.0,    637.34,1707.45,10.94,0.0},
    {631.91901,1702.55005,12.73000,180.00000, 637.39,1704.46,11.04,-180.0,   637.25,1700.63,11.04,0.0},
    {631.91901,1695.93994,12.73000,180.00000, 637.43,1697.85,11.04,181.0,    637.35,1694.02,11.04,0.0}
};
new Float: ContBuyTextPos[12][3] =
{
    {683.51898, 1738.27002, 12.73000},
    {683.51898, 1731.78003, 12.73000},
    {665.81897, 1733.96997, 12.73000},
    {680.23999, 1701.77002, 12.73000},
    {672.75598, 1701.77002, 12.73000},
    {665.81897, 1701.77002, 12.73000},
    {648.51898, 1676.51001, 12.73000},
    {648.51898, 1669.80005, 12.73000},
    {648.51898, 1663.40002, 12.73000},
    {638.91901, 1709.30005, 12.73000},
    {638.91901, 1702.55005, 12.73000},
    {638.91901, 1695.93994, 12.73000}
};
forward TimerSecondUpdateCont(contid, moneystart[]);
forward SpawnNewCont(contid);
forward CorrectTimerMinute();
stock SpawnCont(contid);
stock ResetContInfo(contid);

new ContArea[MAX_CONT + 1]; // Dynamic Areas for containers

stock ConvertMoney(money, string[], length = sizeof string)
{
    format(string, length, "%d", money < 0 ? -money : money);
    for(new i = strlen(string); (i -= 3) > 0;)
    {
        if(string[i] != '\0' && '0' <= string[i] <= '9')
        {
            strins(string, ".", i, length);
        }
        else
        {
            return;
        }
    }
    if(money < 0)
    {
        strins(string, "-", 0, length);
    }
}
// ------------------------------------------------
// This function does not work correctly, we'll rewrite it later anyway
/*stock RusText(string[])
{
	new result[256];
	new len = strlen(string);
	for (new i = 0; i < len; i++)
	{
		switch(string[i])
		{
			case 'а': result[i] = 'a';
			case 'А': result[i] = 'A';
			case 'б': result[i] = 'б';
			case 'Б': result[i] = 'Б';
			case 'в': result[i] = 'в';
			case 'В': result[i] = 'В';
			case 'г': result[i] = 'г';
			case 'Г': result[i] = 'Г';
			case 'д': result[i] = 'д';
			case 'Д': result[i] = 'Д';
			case 'е': result[i] = 'e';
			case 'Е': result[i] = 'E';
			case 'ё': result[i] = 'e';
			case 'Ё': result[i] = 'E';
			case 'ж': result[i] = 'ж';
			case 'Ж': result[i] = 'Ж';
			case 'з': result[i] = 'з';
			case 'З': result[i] = 'З';
			case 'и': result[i] = 'и';
			case 'И': result[i] = 'И';
			case 'й': result[i] = 'й';
			case 'Й': result[i] = 'Й';
			case 'к': result[i] = 'k';
			case 'К': result[i] = 'K';
			case 'л': result[i] = 'л';
			case 'Л': result[i] = 'Л';
			case 'м': result[i] = 'м';
			case 'М': result[i] = 'M';
			case 'н': result[i] = 'н';
			case 'Н': result[i] = 'H';
			case 'о': result[i] = 'o';
			case 'О': result[i] = 'O';
			case 'п': result[i] = 'п';
			case 'П': result[i] = 'П';
			case 'р': result[i] = 'p';
			case 'Р': result[i] = 'P';
			case 'с': result[i] = 'c';
			case 'С': result[i] = 'C';
			case 'т': result[i] = 'т';
			case 'Т': result[i] = 'Т';
			case 'у': result[i] = 'y';
			case 'У': result[i] = 'Y';
			case 'ф': result[i] = 'ф';
			case 'Ф': result[i] = 'Ф';
			case 'х': result[i] = 'x';
			case 'Х': result[i] = 'X';
			case 'ц': result[i] = 'ц';
			case 'Ц': result[i] = 'Ц';
			case 'ч': result[i] = 'ч';
			case 'Ч': result[i] = 'Ч';
			case 'ш': result[i] = 'ш';
			case 'Ш': result[i] = 'Ш';
			case 'щ': result[i] = 'щ';
			case 'Щ': result[i] = 'Щ';
			case 'ъ': result[i] = 'ъ';
			case 'Ъ': result[i] = 'Ъ';
			case 'ы': result[i] = 'ы';
			case 'Ы': result[i] = 'Ы';
			case 'ь': result[i] = 'ь';
			case 'Ь': result[i] = 'Ь';
			case 'э': result[i] = 'э';
			case 'Э': result[i] = 'Э';
			case 'ю': result[i] = 'ю';
			case 'Ю': result[i] = 'Ю';
			case 'я': result[i] = 'я';
			case 'Я': result[i] = 'Я';
			default: result[i] = string[i];
		}
	}
	result[len] = '\0';
	return result;
}*/

new MikhailArea[4]; // Zone 3, Zones 4
new MikhailActor[4];

new HelpArea[4]; // 4 help zones
new HelpActor[4];

new DPSPosts[MAX_DPS_POSTS][e_dps_post];
new TotalDPSPosts = 0;

#define PICKUP_ACTION_FAMILY_BUY 2238
enum e_rent_zone
{
    Float:RENT_PICKUP_X,
    Float:RENT_PICKUP_Y,
    Float:RENT_PICKUP_Z,
    RENT_PARKING_COUNT
}

enum e_parking_data
{
    Float:PARKING_X,
    Float:PARKING_Y,
    Float:PARKING_Z,
    Float:PARKING_A,
    bool:PARKING_BUSY,
    PARKING_VEHICLE
}

new RazdewPravo;
new RazdewGibdd;
new RazdewMvd;
new RazdewFsb;
new RazdewBolka;
new RazdewSmi;
new RazdewVoenka;
new RazdewOpgarz;
new RazdewOpgbat;
new RazdewOpglyt;

new RentZones[MAX_RENT_ZONES][e_rent_zone];
new ParkingSlots[MAX_RENT_ZONES][MAX_PARKING_PER_ZONE][e_parking_data];
new TotalRentZones = 0;

new g_CasinoOffer[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_CasinoBet[MAX_PLAYERS] = {0, ...};
stock bool:IsServerAllowed()
{
    new ip[32], port, full[40];

    GetServerVarAsString("bind", ip, sizeof ip);

    port = GetServerVarAsInt("port");

    format(full, sizeof full, "%s:%d", ip, port);

    for (new i = 0; i < sizeof(AllowedServers); i++)
    {
        if (!strcmp(full, AllowedServers[i], true))
        {
            return true; // Allowed
        }
    }

    return false; // Not allowed
}
new AudioURL[256] = "http://bh-audio-cdn.srv00.com:80/event/spring/menu_screen.mp3"; // Default audio URL
new CCMessage[128] = "{FFCD00}You have been warned by administrator: {FFFFFF}%s"; // Admin warning

new g_TuningType[MAX_PLAYERS]; // 0 - standard, 1 - premium

// Tuning shop exits
#define TUNING_EXIT_1_X 2296.146240
#define TUNING_EXIT_1_Y -2613.668457
#define TUNING_EXIT_1_Z 21.829063
#define TUNING_EXIT_1_A 90.0

#define TUNING_EXIT_2_X 1742.453979
#define TUNING_EXIT_2_Y 2465.383544
#define TUNING_EXIT_2_Z 14.454860
#define TUNING_EXIT_2_A 285.0


new Float:ATM_Positions[][] = {
    // X, Y, Z, Interior, VW
    {1551.044067, 411.322357, 1001.039306, 1, 0} // 24/7 Shop
    //{2376.687011, -2139.306396, 22.129489, 0, 0}, // Downtown Shop
    //{-2326.777587, -29.076337, 27.418167, 0, 0},  // Ganton Shop
    //{-2112.231689, 2169.783691, 58.724487, 0, 0}  // Doherty Shop
};

new ATM_Areas[sizeof(ATM_Positions)];

//Server information
#define SERVER_NAME 	"BET RUSSIA"
#define SERVER_SITE 	"t.me/l4ird"
#define SERVER_MAP_NAME "v16.21.1"
#define SERVER_VERSION	"12.1 (F1)"
#define SERVER_VK       "t.me/l4ird "
#define SERVER_TG       "t.me/crmp_bet"*

//=========================Database Connection=======================================

enum MYSQL_SETTINGS
{
	LAIRD_HOST,
	LAIRD_USERNAME,
    LAIRD_PASSWORD,
	LAIRD_DATABASE
}
new MySQLSettings[MYSQL_SETTINGS][30];

//=========================Server Information=====================================

enum NAME_SERVER
{
	LAIRD_NAME,
	LAIRD_TG,
	LAIRD_VK,
	LAIRD_SITE
}
new NameServer[NAME_SERVER][30];
new const g_Regions[][] = {
    "01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
    "11", "12", "13", "14", "15", "16", "17", "18", "19", "21",
    "22", "23", "24", "25", "26", "27", "28", "29", "30", "31",
    "32", "33", "34", "35", "36", "37", "38", "39", "40", "41",
    "42", "43", "44", "45", "46", "47", "48", "49", "50", "51",
    "52", "53", "54", "55", "56", "57", "58", "59", "60", "61",
    "62", "63", "64", "65", "66", "67", "68", "69", "70", "71",
    "72", "73", "74", "75", "76", "77", "78", "79", "80", "81",
    "82", "83", "84", "85", "86", "87", "88", "89", "90", "91",
    "92", "93", "94", "95", "96", "97", "98", "99", "102", "123",
    "150", "152", "178", "190", "198", "213", "231", "263", "325", "380"
};
// ----------------Administrator Level Names------------------------------------------------------------------------
#define ADM_LVL1_NAME   "Junior Administrator"       // 1 level admin
#define ADM_LVL2_NAME   "Administrator"               // 2 level admin
#define ADM_LVL3_NAME   "Senior Administrator"       // 3 level admin
#define ADM_LVL4_NAME   "Head Administrator"           // 4 level admin
#define ADM_LVL5_NAME   "Senior Head Administrator"   // 5 level admin (Head)
#define ADM_LVL6_NAME   "GM/Lead"// 6 level admin (Game Master)
#define ADM_LVL7_NAME   "Senior Head Administrator"   // 7 level admin
#define ADM_LVL8_NAME   "Project Developer"  // 8 level admin
#define ADM_LVL9_NAME   "Ass. Project Developer" // 9 level admin
#define ADM_LVL10_NAME  "Senior Head Administrator"   // 10 level admin
#define ADM_LVL11_NAME  "Lead Developer" // 11 level admin (Lead developer)
#define ADM_LVL12_NAME  "Project Developer"  // 12 level admin
#define ADM_LVL13_NAME  "Owner" // 13 level admin

new bool:gWhitelist; // laird
new TEST_SERVER = 0;
new bonus_money;
new bonus_donate;
new bonus_lvl;
new vip_type;

new player_gps_zone[MAX_PLAYERS][2];

new stol1;
new stol2;
new stol3;
new stol4;
new stol5;
new stol6;

new ISBONUS;
new zakazdvornik[MAX_PLAYERS];
new mysorarz[MAX_PLAYERS];
new mysorbat[MAX_PLAYERS];
new mysorysh[MAX_PLAYERS];
new mysactor;
new kladactor;
new zona1;
new zona11;
new timersecfer;
new vishka1;
new timerochkov;
new Text:zakaz3_TD[4]; //Task
new Text:zakaz4_TD[4];//Team
new Text:zakaz5_TD[4];//Salary
new Text:zakaz6_TD[4];//Delivery
new Text:zakaz7_TD[4];//Reward
new PlayerText:zakaz3_PTD[MAX_PLAYERS][1]; 
new PlayerText:zakaz4_PTD[MAX_PLAYERS][1]; 
new PlayerText:zakaz5_PTD[MAX_PLAYERS][1]; 
new PlayerText:zakaz6_PTD[MAX_PLAYERS][1]; 
new PlayerText:zakaz7_PTD[MAX_PLAYERS][1]; 
new PlayerText:ygygydodo_PTD[MAX_PLAYERS][4];
new	cblit;
new cblitexit;
new mchsrazdewalka;
new mchsavto;
new mchsexit;
new mchsvhod;
new bool:g_TeleportReady[MAX_PLAYERS];
new bool:create_player_btn[MAX_PLAYERS];
new Text:button_TD[13];

new Text: acss_TD[26];
new PlayerText: acss_coords_PTD[MAX_PLAYERS][1];

// Accessories for players
new PlayerText:button_PTD[MAX_PLAYERS][1];
new player_select_accessory[MAX_PLAYERS];
new Text3D:gEventLabel = Text3D:0;

new player_sale_time_timer[MAX_PLAYERS];
new player_update_promotions_timer[MAX_PLAYERS];


#define MAX_PLAYERS_PROMOTIONS 3

enum player_donate_data
{
	Node:JSON_PROMOTIONS_ARRAY,
	ADDED_PROMOTIONS
};
new g_player_donate_data[MAX_PLAYERS][player_donate_data];
new g_player_added_promotions_data[1000][3][3];

new vorotamo1;
new vorotamo;
new openvorotamo1;
new openvorotamo;

enum ACCESSORY_M_STRCT
{
    ID_ACCESSORY,
    BONE_ACCESSORY,
    NAME_ACCESSORY[32],
    PRICE_ACCESSORY,
    
};
new pl_accessory[MAX_PLAYERS];
new pl_id_accessory[MAX_PLAYERS];
new accessory[116][ACCESSORY_M_STRCT] =
{
    {4196 , 1,"Gold Chains "                       ,15000000 },
    {4197 , 2,"Fashion Watch"                       ,10000000},
    {4198 , 2,"Gangster Coat"                       ,7000000},
    {4199 , 1,"Jacket - Leather Coat"                       ,5000000},
    {4200 , 1,"Luxury Belt "                       ,5000000},
    {4201 , 1,"Sunglasses"                       ,1000000},
    {4203 , 1,"Ring And Jewels "                       ,3000000},
    {4204 , 1,"Gentleman's Vest"                       ,3000000},
    {4205 , 2,"Watch - Rolex"                       ,2500000},
    {4206 , 1,"Gold Ring"                       ,1500000},
    {4207 , 1,"Brace And Pendant"                       ,1000000},
    {4208 , 1,"Diamond Brace "                       ,900000},
    {14574, 1,"Gold Medal"                       ,15000000},
    {14575, 1,"Silver Medal"                       ,15000000},
    {14593, 1,"Crystal Pendant "                       ,15000000},
    {15134, 1,"Gold Medal Exclusive "                       ,12000000},
    {15135, 2,"Fashion Bag "                       ,2000000},
    {15136, 2,"Fashion Bag "                       ,2000000},
    {15137, 2,"Fashion Bag "                       ,2000000},
    {15138, 2,"Fashion Bag "                       ,2000000},
    {15139, 2,"Gold Fashion Bag "                      ,2500000},
    {15140, 2,"Fashion Bag "                       ,2000000},
    {15141, 2,"Fashion Bag "                       ,2000000},
    {15142, 1,"Silver Brace"                       ,2000000},
    {15143, 1,"Expensive Brace "                       ,1500000},
    {15144, 2,"Rich Pearl Brace "                       ,500000},
    {15145, 2,"Pearl Pendant"                       ,500000},
    {15146, 2,"Luxury Chain "                       ,500000},
    {15147, 2,"Luxury Chain "                       ,700000},
    {15149, 1,"Sunglasses"                       ,1000000},
    {15150, 1,"FnaF Mask"                       ,1500000},
    {15151, 2,"Fashion Bag "                       ,3000000},
    {15152, 2,"Rich White Bag "                       ,500000},
    {15153, 2,"Rich Black Chain"                       ,500000},
    {7329 , 2,"Fashion Bandana"                        ,300000},
    {7330 , 2,"Fashion Bandana"                        ,300000},
    {7331 , 2,"Fashion Cap 2"                        ,500000},
    {7332 , 2,"Stylish Cap "                        ,300000},
    {7333 , 2,"Fashion Hat"                        ,300000},
    {7334 , 2,"Fashion Hat"                        ,300000},
    {7336 , 2,"Fashion Hat 2"                        ,300000},
    {7337 , 2,"Fashion Hat 3"                        ,300000},
    {7338 , 2,"Gangster Hat "                        ,300000},
    {7339 , 2,"Cowboy Hat "                        ,300000},
    {7341 , 2,"Hat (NY) "                        ,400000},
    {7342 , 2,"Hat (Desert) "                        ,400000},
    {7343 , 2,"Hat #1 Gang"                        ,300000},
    {7344 , 2,"Hat #2 (StoneIS) "                        ,300000},
    {7345 , 2,"Hat #3 "                        ,300000},
    {7346 , 2,"Hat #4 "                        ,300000},
    {7347 , 2,"Hat #5 "                        ,300000},
    {7348 , 2,"Hat #6 "                        ,300000},
    {7349 , 2,"Hat #7 "                        ,300000},
    {7350 , 2,"Hat #8 (Red)"                        ,300000},
    {18377, 2,"Hat Purple"                       ,7000000},
    {18386, 2,"Hat White "                       ,7000000},
    {18389, 2,"Crown And Jewelry Crown "                       ,300000},
    {18390, 2,"Hat Yellow "                       ,6000000},
    {18391, 2,"Hat Blue "                       ,7000000},
    {18392, 2,"Hat Red Gold"                       ,8000000},
    {18396, 2,"Hat White"                       ,2500000},
    {18397, 2,"Hat Black "                       ,2000000},
    {18399, 2,"Hat"                       ,1000000},
    {18400, 2,"Hat 2"                       ,100000},
    {18401, 2,"Hat Blue "                       ,7000000},
    {18402, 2,"Hat Black "                       ,3000000},
    {18403, 2,"Hat Blue"                       ,3000000},
    {18404, 2,"Hat White "                       ,7000000},
    {18409, 2,"Hat Purple"                       ,7000000},
    {7351 , 2,"Hat"                        ,300000},
    {7352 , 2,"Hat 2"                        ,300000},
    {7353 , 2,"Hat"                        ,300000},
    {7354 , 2,"Hat"                        ,300000},
    {7355 , 2,"Hat #1"                        ,400000},
    {7356 , 2,"Hat #2"                        ,450000},
    {7357 , 2,"Hat #3 (New)"                        ,450000},
    {7358 , 2,"Hat #4"                        ,500000},
    {7359 , 2,"Hat #5"                        ,500000},
    {7360 , 2,"Hat #6"                        ,500000},
    {7362 , 2,"Hat Black"                        ,350000},
    {7364 , 1,"Smoke (Transparent)"                       ,8000000},
    {7367 , 6,"Shine Smoke "                        ,5000000},
    {7368 , 6,"Smoke (2) "                        ,10000000},
    {7369 , 6,"Smoke Face"                        ,12000000},
    {7370 , 2,"Gold Face "                        ,5000000},
    {7371 , 2,"Silver Face "                        ,5000000},
    {7372 , 2,"Face Paint"                        ,3000000},
    {7374 , 2,"Face Paint"                        ,4000000},
    {7375 , 2,"Face Paint"                        ,5000000},
    {7376 , 2,"Face Paint"                        ,5000000},
    {7377 , 1,"Mask "                        ,1000000},
    {7378 , 1,"Mask "                        ,1000000},
    {7379 , 2,"Face Paint #1"                        ,1500000},
    {7380 , 2,"Face Paint #2"                        ,1500000},
    {7381 , 2,"Face Paint #3"                        ,1500000},
    {7382 , 2,"Face Paint"                        ,1500000},
    {7383 , 1,"Paint For Games #1"                        ,500000},
    {7384 , 1,"Paint For Games #2"                        ,500000},
    {7385 , 1,"Paint For Games #3"                        ,500000},
    {7386 , 1,"Paint For Games #4"                        ,500000},
    {7387 , 1,"Paint"                        ,750000},
    {7390 , 1,"Paint #1"                        ,700000},
    {7391 , 1,"Paint #2"                        ,700000},
    {7392 , 1,"Paint #3"                        ,700000},
    {7393 , 1,"Paint #4"                        ,700000},
    {7394 , 1,"Paint #1"                        ,750000},
    {7395 , 1,"Paint #2"                        ,750000},
    {790,   1,"Diamond Bracelet"                        ,4000000},
    {787,   2,"Gold Bandana"                        ,7000000},
    {9824 , 1,"Rich Diamond"                        ,5000000},
    {9825 , 1,"Gold Medal"                        ,3000000},
    {9827 , 1,"Gold Ring "                        ,5000000},
    {9828 , 1,"Diamond Bracelet"                        ,4000000},
    {11919, 2,"Ring On Finger"                       ,6000000},
    {11923, 1,"Gold Chain On Neck"                       ,5000000},
    {14589, 1,"Diamond Ring"                       ,6000000}
};
new helpspawn;

#define MAX_GREEN_ZONES 1

enum E_GREEN_ZONE {
    Float:gzX,
    Float:gzY,
    Float:gzZ,
    Float:gzRadius,
    gzVW // 0 or 1
};

new GreenZones[MAX_GREEN_ZONES][E_GREEN_ZONE] = {
    {-1699.900, -2700.589, 1499.540, 10000.0, 1}
};

// --------------------------------------------------------
new bool:FamText = true;
// --------------------------------------------------------

#define MAX_UCHECK 18
#define UrogMoney  200
#define MAX_USCHECK 2

new player_sell_ownable_car[MAX_PLAYERS];
new ownable_car_sell_status[MAX_PLAYERS];
new player_sell_area;

new tehsentervlad;

// -- vehicle stream
new Iterator:streamed_players_in_veh[MAX_VEHICLES]<MAX_PLAYERS-1>;
new Iterator:vehicle_in_stream[MAX_PLAYERS]<MAX_VEHICLES-1>;
new bool:Povorotnk[3][MAX_VEHICLES];
new Povor[4];
new pickupotd;

#define vNeon1             0
#define vNeon2             1
#define vNeon3             2
#define vTint              3
#define vSuspensionForce   4
#define vSuspensionBias    5
#define vWheelSize         6
#define vWheelAddFront     7
#define vDrift     16
#define vWheelAddRear      8
#define vVinyl             9
#define vHydraulic         10
#define vLaunchMode        11
#define vFuel              12
#define vHorn              13
#define vLightColor        14
#define vWindowsColor      15
#define vDifferential       17

new koika1;
new koika2;
new koika3;
new koika4;
new koika5;
new koika6;
new koika7;
new koika8;
new koika9;
new koika10;
new koika11;
new koika12;
new koika13;
new koika14;
new koika15;
new koika16;
new koika17;
new koika18;
new koika19;
new koika20;
new koika21;
new koika22;
new koika23;
new koika24;
new koika25;
new koika26;
new koika27;
new koika28;
new koika29;
new koika30;
new koika31;
new koika32;
new lift1;
new lift2;

new Float:SvetforsPos[18][4] =
{
//North
	{-366.0, 981.0, 11.14, 0.0},
	{-368.546600,957.560302,11.14, 270.0},
	{-391.058990,961.149108,11.14, 180.0},
	{328.835540,1699.297729,11.14,250.971023},
	{318.586883,1671.872436,11.14,172.068237},
	{345.156921,1663.895263,11.14,267.259231},
	{360.339538,1687.765258,11.14,358.703964},
	{-388.625457,983.269531,11.14, -270.0}, 
//South west docks
    {2249.259033,-2144.601074,20.960937,359.253479},
    {2224.446533,-2140.237060,20.960937,93.107521},
    {2245.327148,-2169.859130,20.960937,275.290405},
//South
    {2454.441406,-2140.342773,20.968269,95.382904},
    {2450.083496,-2165.327880,20.970085,176.587860},
    {2475.265869,-2169.774658,20.976562,266.861999},
    {2479.759277,-2144.504394,20.973707,3.563263}, 
//South east military
    {2732.063476,-2144.249023,20.979000,357.948333},
    {2704.337402,-2139.719238,20.981679,91.915931},
    {2701.037841,-2165.455810,20.976562,185.278167,}
};

new SvetforsColor[sizeof SvetforsPos];
new SvetforsType[18] = {1,2,1,2,1,2,1,2,2,1,1,1,2,1,2,2,1,2}; // Traffic light type (green) 
new Float:gVezd[16][4] = {
{457.414428,994.900451,1001.039978,180},
{460.409393,994.633666,1001.039978,180},
{463.527008,994.476196,1001.039978,180},
{466.723785,994.493286,1001.039978,180},
{479.496978,994.941101,1001.039978,180},
{482.490447,994.761840,1001.039978,180},
{485.538940,994.795043,1001.039978,180},
{488.777587,994.781494,1001.039978,180},
{484.581085,976.139648,1001.039978,0},
{481.391479,976.139526,1001.039978,0},
{478.450775,976.211486,1001.039978,0},
{475.372680,976.791320,1001.039978,0},
{470.754516,976.268493,1001.039978,0},
{467.648162,976.436279,1001.039978,0},
{464.430145,976.352416,1001.039978,0},
{461.381805,976.542419,1001.039978,0}
};

new Float:gViezd[8][3] = {
{1936.1517,-511.5483,11.3228},
{1943.0174,-511.2795,11.3012},
{1949.8996,-511.5617,11.3231},
{1957.0704,-511.5148,11.3201},
{1964.0029,-511.7130,11.3350},
{1971.0075,-511.7753,11.3404},
{1977.7071,-511.5423,11.3221},
{1984.7070,-511.6167,11.3276}
};
new golod[MAX_PLAYERS] = 100;

new Float:urogcheck[MAX_UCHECK][3] = {
    {1218.839355,1186.336303,22.195657},
    {1210.846557,1186.252319,22.238286},
    {1203.372802,1186.267578,22.311395},
    {1203.215698,1191.280029,22.215251},
    {1211.415771,1191.924316,22.124559},
    {1219.193481,1191.427612,22.094377},
    {1211.420532,1207.481811,21.820604},
    {1203.383789,1236.951171,21.298858},
    {1211.013671,1236.726074,21.251373},
    {1218.504882,1236.500122,21.271039},
    {1218.564575,1241.166137,21.227155},
    {1211.262573,1242.359375,21.148031},
    {1203.682861,1242.962646,21.147756},
    {1203.859985,1247.785766,20.981599},
    {1210.098632,1248.272949,21.046739},
    {1201.990600,1259.066528,20.220586},
    {1210.714965,1259.207519,20.337518},
    {1190.945556,1315.731811,18.601379} 
};

new Float:urogscheck[MAX_USCHECK][3] = {
   {1190.945556,1315.731811,18.601379},
   {1190.945556,1315.731811,18.601379} 
};

#include <brnotification> // -- inc

#include <customhud> // - HUD display
#include <customtune> // - Tuning
#include <sampvoice>


AntiDeAMX2();
AntiDeAMX();

#define SERVER            "{FF5252}" // - Server color message
#define SC              "{FF5252}| {ffffff}"
#define USC             "{ff2400}| {ffffff}"

new g_tuning_center_entrance_text[3];
new g_tuning_center_exit_text[3];

// Tuning entrances
new Float:g_TuningEnter[3][4] =
{
    {2313.691406, -2607.333496, 20.944360, 102.975852},
    {2313.824707, -2612.991455, 20.939689, 102.975852},
    {2313.662109, -2619.332763, 20.944149, 102.975852}
};
new Float:g_TuningEnter2[3][4] = {
    {1732.037353, 2452.861328, 14.979245},   // Second shop for second tuning location (Alternative)
    {1732.035766, 2457.393798, 14.979245},
    {1732.037353, 2462.861328, 14.979245}
};
new Float:g_TuningExit[3][4] =
{
    {2296.378417, -2607.449462, 20.943988, 129.837677},
    {2297.913330, -2619.722167, 20.944377, 129.837677},
    {2297.514404, -2613.226074, 20.944082, 129.837677}
};

#define TUNING_WORLD 101
#define TUNING_INTERIOR 1
new SV_GSTREAM:gstream = SV_NULL;
new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };

new razdev;
new razdev1;
new razdev2;
new razdev3;
new razdev4;
new razdev5;
new Text: acs_TD[26];

new PlayerText: acs_coords_PTD[MAX_PLAYERS][1];
new razdev6;
new razdev7;
