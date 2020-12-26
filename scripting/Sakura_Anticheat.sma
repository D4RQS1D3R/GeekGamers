#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>

#define PLUGIN "Sakura's Anticheat"
#define VERSION "1.1"
#define AUTHOR "Ilham Sakura"

#define CharsMax(%1) sizeof %1 - 1

#define MAX_FLASHBUG_ZONES 20

#define ADVERTISING_TIME 240.0

#define FM_HITGROUP_HEAD (1 << 1)
#define FM_TEAM_OFFSET 114

#define ADMIN_IGNORE_FLAG ADMIN_BAN

enum _:Enum_Settings {
	
	PLUGIN_STATUS = 0,
	PLUGIN_LOG_ACTIONS,
	PLUGIN_ADVERTISING,
	
	PUNISH_TYPE,
	BAN_TYPE,
	BAN_TIME,
	IGNORE_ADMINS,
	
	SPEEDHACK_SECURE,
	
	CHECK_RAPIDFIRE,
	CHECK_SPINHACK,
	CHECK_SPEEDHACK,
	CHECK_SHAKE,
	CHECK_LOWRECOIL,
	CHECK_AIMBOT,
	CHECK_BHOP,
	
	CHECK_MOVEKEYS,
	CHECK_DOUBLEATTACK,
	
	CHECK_FLASHBUG,
	
	CHECK_WALLHACK,
	WALLHACK_MAX_DETECTS,
	
	CHECK_FASTNAME,
	CHECK_NAME,
	CHECK_NAME_SYMBOLS,
	CNS_SHOW_REASON,
	CHECK_IPS
};

enum _:Cheats {
	
	RAPIDFIRE = 0,
	SPINHACK,
	SPEEDHACK,
	SHAKE,
	RECOIL,
	AIMBOT
};

new const gSettings_Name[][] = {
	
	"Plugin_Status",
	"Plugin_Log_Actions",
	"Plugin_Advertising",
	"Punish_Type",
	"Punish_Ban_Type",
	"Punish_Bantime",
	"Ignore_Admins",
	"Speedhack_Secure",
	"Check_Rapidfire",
	"Check_Spinhack",
	"Check_Speedhack",
	"Check_Shake",
	"Check_Lowrecoil",
	"Check_Aimbot",
	"Check_Bhop",
	"Check_Movekeys",
	"Check_Doubleattack",
	"Check_Flashbug",
	"Check_Wallhack",
	"Wallhack_Max_Detects",
	"Check_Name_Fastchange",
	"Check_Name",
	"Check_Name_Symbols",
	"CNS_Show_Reason",
	"Check_IPs"
};

new const gWarningSounds[][] = {
	
	"Sakura_Anticheat/spray.wav",
	"Sakura_Anticheat/warning.wav"
};

new const gOldCheats[][] = {
	
	"EcstaticCheat",
	"TeKilla",
	"MicCheat",
	"AlphaCheat",
	"PimP",
	"LCD",
	"Chapman",
	"_PRJVDC"
};

new const gGunsEvents[][] = {
	
	"events/awp.sc",
	"events/g3sg1.sc",
	"events/ak47.sc",
	"events/scout.sc",
	"events/m249.sc",
	"events/m4a1.sc",
	"events/sg552.sc",
	"events/aug.sc",
	"events/sg550.sc",
	"events/m3.sc",
	"events/xm1014.sc",
	"events/usp.sc",
	"events/mac10.sc",
	"events/ump45.sc",
	"events/fiveseven.sc",
	"events/p90.sc",
	"events/deagle.sc",
	"events/p228.sc",
	"events/glock18.sc",
	"events/mp5n.sc",
	"events/tmp.sc",
	"events/elite_left.sc",
	"events/elite_right.sc",
	"events/galil.sc",
	"events/famas.sc"
};
new gGunsEventsId[sizeof gGunsEvents];

new gSettings[Enum_Settings] = {0, ...};
new gMapName[32];

new FlashVectors[MAX_FLASHBUG_ZONES][4];
new FlashZones;

new bool:IsDetected[33];
new Detections[33][Cheats];

new Float:fOldAimAngles[33][3];
new Float:fLastAngles[33][3];
new Float:fTotalAngle[33];

new Float:fRecoilLastAngles[33][3];

new Float:fLastOrigin[33][3];

new Float:fAimOrigin[33][3];

new WallKills[33];

new BhopScript[32];
new NamesChangesNum[33];
new RestrictedSymbols[32];

new Float:fNextAimCheck[33];

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_dictionary("Sakura_Anticheat.txt");
	
	register_forward(FM_Think, "Fwd_Think");
	register_forward(FM_EmitSound, "Fwd_EmitSound");
	register_forward(FM_PlayerPostThink, "Fwd_PlayerPostThink");
	register_forward(FM_PlayerPreThink, "Fwd_PlayerPreThink");
	register_forward(FM_PlaybackEvent, "Fwd_PlaybackEvent");
	register_forward(FM_TraceLine, "Fwd_TraceLine");
	
	register_event("DeathMsg", "EventDeathMsg", "a");
	register_event("HLTV", "EventNewRound", "a", "1=0", "2=0");
	
	formatex(BhopScript, CharsMax(BhopScript), "plop%d%d%d", random(100), random(100), random(100));
	register_clcmd(BhopScript, "cmdDetectBhop");
}

public plugin_precache()
{
	for(new i = 0 ; i < sizeof gWarningSounds ; i++)
		precache_sound(gWarningSounds[i]);
	
	for(new x = 0 ; x < sizeof gGunsEvents ; x++)
		gGunsEventsId[x] = engfunc(EngFunc_PrecacheEvent, 1, gGunsEvents[x]);
}

public plugin_cfg()
{
	static BaseDir[64], Sakura_AnticheatDir[64], File[64];
	get_basedir(BaseDir, CharsMax(BaseDir));
	
	formatex(Sakura_AnticheatDir, CharsMax(Sakura_AnticheatDir), "%s/Sakura_Anticheat", BaseDir);
	formatex(File, CharsMax(File), "%s/Sakura_Anticheat_Settings.cfg", Sakura_AnticheatDir);
	
	if(!dir_exists(Sakura_AnticheatDir))
		mkdir(Sakura_AnticheatDir);
	
	if(!file_exists(File))
	{
		server_print("%L",LANG_SERVER,"PRINT_SRV_ERROR");
		
		return;
	}
	else
		server_print("%L",LANG_PLAYER,"SUCC_LOADED");
	
	static iFile, Buffer[128], Key[32], Status[16];
	iFile = fopen(File, "rt");
	
	while(!feof(iFile))
	{
		fgets(iFile, Buffer, CharsMax(Buffer));
		
		if((Buffer[0] == ';') || (Buffer[0] == '/' && Buffer[1] == '/'))
			continue;
		
		strtok(Buffer, Key, CharsMax(Key), Status, CharsMax(Status), '=', 1);
		
		for(new i = 0 ; i < sizeof gSettings_Name ; i++)
		{
			if(equali(gSettings_Name[i], Key))
			{
				if(equali(Key, "Check_Name_Symbols"))
				{
					trim(Status);
					formatex(RestrictedSymbols, CharsMax(RestrictedSymbols), "%s", Status);
					
					//server_print("[Geek~Gamers] Setting: %s have string %s", gSettings_Name[i], Status);
					server_print("%L",LANG_SERVER,"SETTINGS_STR",gSettings_Name[i], Status);
					
					
					continue;
				}
				gSettings[i] = str_to_num(Status);
				
				//server_print("[Geek~Gamers] Setting: %s is %s", gSettings_Name[i], gSettings[i] ? "Enabled" : "Disabled");
				server_print("%L",LANG_SERVER,"SET_V_2",gSettings_Name[i], gSettings[i] ? "Enabled" : "Disabled");
				
			}
		}
	}
	fclose(iFile);
	
	LoadFlashVectors();
	
	if(!gSettings[PLUGIN_STATUS])
	{
		pause("a");
		return;
	}
	if(gSettings[PLUGIN_ADVERTISING])
		set_task(ADVERTISING_TIME, "cmdAdvertising", random(1337), "", 0, "b", 0);
	if(gSettings[CHECK_RAPIDFIRE])
		set_task(1.0, "CheckRapidFire", random(1337), "", 0, "b", 0);
	if(gSettings[CHECK_SPINHACK])
		set_task(1.0, "CheckSpinTotal", random(1337), "", 0, "b", 0);
	if(gSettings[CHECK_SPEEDHACK])
		set_task(0.5, "CheckSpeedHack", random(1337), "", 0, "b", 0);
	if(gSettings[CHECK_LOWRECOIL])
		set_task(1.0, "ClearRecoil", random(1337), "", 0, "b", 0);
}

public cmdAdvertising()
{
	set_hudmessage(random(256), random(256), random(256), random_float(0.01, 0.55), random_float(0.01, 0.7), 1, 6.0, 6.0, 1.0, 1.0, -1);
	show_hudmessage(0, "This Server is Protected By: ~DarkSiDeRs~");
	//show_hudmessage(0,"This Server is Protected!");
	
}

public client_connect(id)
{
	for(new i = 0 ; i < sizeof Detections[] ; i++)
	{
		Detections[id][i] = 0;
	}
	
	IsDetected[id] = false;
	WallKills[id] = 0;
	NamesChangesNum[id] = 0;
	
	if(gSettings[CHECK_NAME])
	{
		static Name[32];
		get_user_name(id, Name, CharsMax(Name))
		
		for(new i = 0 ; i < strlen(RestrictedSymbols) ; i++)
		{
			for(new j = 0 ; j < strlen(Name) ; j++)
			{
				if(Name[j] == RestrictedSymbols[i])
				{
					//server_cmd("kick #%d ^"[Geek~Gamers] You have a restricted symbol in name! Change it.^"", get_user_userid(id));
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), LANG_PLAYER,"WRONG_CH");
					
					
					if(gSettings[CNS_SHOW_REASON])
						//client_print(0, print_chat, "[Geek~Gamers] %s was kicked by SDC for having a restricted symbol in name.", Name);
						client_print(0, print_chat, "%L",LANG_PLAYER,"KICK_WR_CH", Name);
						
					
					break;
				}
			}
		}
	}
	if(gSettings[CHECK_IPS])
	{
		static BaseDir[64], File[64];
		get_basedir(BaseDir, sizeof BaseDir - 1);
		
		formatex(File, sizeof File - 1, "%s/Sakura_Anticheat/Sakura_Anticheat_IPs.ini", BaseDir);
		
		if(Exists_IP(id, File))
			//server_cmd("kick #%d ^"[Geek~Gamers] Your IP is restricted.^"", get_user_userid(id));
			server_cmd("kick #%d ^"%L^"",get_user_userid(id), LANG_PLAYER,"WRONG_IP");
		
	}
	return 0;
}

public client_putinserver(id)
{
	static Name[32];
	get_user_name(id, Name, CharsMax(Name));
	
	static Info[3];
	for(new i = 0 ; i < sizeof gOldCheats ; i++)
	{
		get_user_info(id, gOldCheats[i], Info, CharsMax(Info));
		
		if(strlen(Info) > 0)
		{
			client_print(0, print_chat, "[Geek~Gamers] %s is detected having cheats!", Name);
			client_print(0,print_chat,"%L",LANG_PLAYER,"DEC_CON",Name);
			PunishUser(id);
			
			return 1;
		}
	}
	//client_print(0, print_chat, "[Geek~Gamers] %s's Config file (.CFG) has been scaned successfully.", Name);
	client_print(0,print_chat,"%L",LANG_PLAYER,"CFG_SC",Name);
	
	return 0;
}


public LoadFlashVectors()
{
	static BaseDir[64], Sakura_AnticheatDir[64], File[64];
	get_basedir(BaseDir, CharsMax(BaseDir));
	
	get_mapname(gMapName, CharsMax(gMapName));
	
	formatex(Sakura_AnticheatDir, CharsMax(Sakura_AnticheatDir), "%s/Sakura_Anticheat", BaseDir);
	formatex(File, CharsMax(File), "%s/flash_bug/%s.ini", Sakura_AnticheatDir, gMapName);
	
	if(!file_exists(File))
	{
		//server_print("[Geek~Gamers] Couldn't load flash bug vectors for ^"%s^".", gMapName);
		server_print("%L",LANG_SERVER,"LD_VECTORS",gMapName);
		return;
	}
	
	static iFile, Buffer[128], Temp[4][32], LineParams, i;
	iFile = fopen(File, "rt");
	
	while(!feof(iFile))
	{
		fgets(iFile, Buffer, CharsMax(Buffer));
		
		if((Buffer[0] == ';') || (Buffer[0] == '/' && Buffer[1] == '/') || strlen(Buffer) < 2)
			continue;
		
		LineParams = parse(Buffer, Temp[0], sizeof Temp[] - 1, Temp[1], sizeof Temp[] - 1, Temp[2], sizeof Temp[] - 1, Temp[3], sizeof Temp[] - 1);
		
		if(LineParams != 4)
		{
			//server_print("[Geek~Gamers] Error in flash bug file for ^"%s^".", gMapName);
			server_print("%L",LANG_SERVER,"SV_PRINT_VEC",gMapName);
			continue;
		}
		
		FlashVectors[i][0] = str_to_num(Temp[0]);
		FlashVectors[i][1] = str_to_num(Temp[1]);
		FlashVectors[i][2] = str_to_num(Temp[2]);
		FlashVectors[i][3] = str_to_num(Temp[3]);
		
		i++;
	}
	fclose(iFile);
	
	FlashZones = i;
	
	//server_print("[Geek~Gamers] Successfully loaded %d flash bug vectors for ^"%s^".", FlashZones, gMapName);
	server_print("%L",LANG_SERVER,"SUC_VEC_LOAD",FlashZones,gMapName);
}

public EventNewRound()
{
	static Players[32], iNum;
	get_players(Players, iNum, "ch");
	
	for(new i = 0 ; i < iNum ; i++)
	{
		if(gSettings[CHECK_SPEEDHACK])
		{
			static Float:fOrigin[3];
			pev(Players[i], pev_origin, fOrigin);
			
			CopyVector(fOrigin, fLastOrigin[Players[i]]);
		}
		if(gSettings[CHECK_WALLHACK])
		{
			WallKills[Players[i]] = 0;
		}
	}
}

public Fwd_Think(Ent)
{
	if(!pev_valid(Ent))
		return FMRES_IGNORED;
	
	if(!gSettings[CHECK_FLASHBUG])
		return FMRES_IGNORED;
	
	static Float:fOrigin[3], iOrigin[3], BugZone[3];
	static Model[32];
	
	pev(Ent, pev_model, Model, CharsMax(Model));
	
	//Flash Bang Place. Detected Flash. Model to Place
	if(!equali(Model, "models/w_flashbang.mdl"))
		return FMRES_IGNORED;
	
	static id;
	id = pev(Ent, pev_owner);
	
	pev(Ent, pev_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	for(new i = 0 ; i < FlashZones ; i++)
	{
		BugZone[0] = FlashVectors[i][0];
		BugZone[1] = FlashVectors[i][1];
		BugZone[2] = FlashVectors[i][2];
		
		if(get_distance(iOrigin, BugZone) <=  FlashVectors[i][3])
		{
			
			//client_print(0, print_chat, "[Geek~Gamers] Removed a flashbang from (%d %d %d).", iOrigin[0], iOrigin[1], iOrigin[2]);
			client_print(0,print_chat,"%L",LANG_PLAYER,"SUCC_RMV_FLB",iOrigin[0], iOrigin[1], iOrigin[2]);
			engfunc(EngFunc_RemoveEntity, Ent);
			
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
			//show_hudmessage(id, "[Geek~Gamers] Ilegal map bug exploit warning!");
			show_hudmessage(id,"%L",LANG_PLAYER,"ILG_MAP_EXPLOIT");
			
			Fm_user_slap(id, 10.0);
			
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public Fwd_PlayerPostThink(id)
{
	if(!is_user_alive(id) || is_user_bot(id))
		return FMRES_IGNORED;
	
	if(gSettings[CHECK_SPINHACK])
		CheckSpinHack_Post(id);
	
	
	if(gSettings[CHECK_SHAKE])
		CheckShake(id);
	
	return FMRES_IGNORED;
}

public Fwd_PlayerPreThink(id)
{
	if(!is_user_alive(id) || is_user_bot(id))
		return FMRES_IGNORED;
	
	if(gSettings[CHECK_MOVEKEYS])
		CheckScriptBlock(id);
	
	if(gSettings[CHECK_BHOP])
	{
		if(!(pev(id, pev_flags) & FL_ONGROUND) && (!(pev(id, pev_button) & IN_JUMP) || pev(id, pev_oldbuttons) & IN_JUMP))
			client_cmd(id, ";alias _special %s", BhopScript);
	}
	
	return FMRES_IGNORED;
}

public cmdDetectBhop(id)
{
	if(!gSettings[CHECK_BHOP])
		return 1;
	
	if(!(pev(id,pev_flags) & FL_ONGROUND) && (!(pev(id, pev_button) & IN_JUMP) || pev(id, pev_oldbuttons) & IN_JUMP))
		return 1;
	
	return 0;
}

public CheckShake(id)
{
	static Float:fAimAngles[3];
	pev(id, pev_angles, fAimAngles);
	
	static Weapon, Trash;
	Weapon = get_user_weapon(id, Trash, Trash);
	
	if(Weapon == CSW_M249)
		return FMRES_IGNORED;
	
	if(((fAimAngles[0] ==  fOldAimAngles[id][0]) && (fAimAngles[1] ==  fOldAimAngles[id][1])) || (pev(id, pev_button) & IN_JUMP))
	{
		Detections[id][SHAKE] -= 10;
		
		if(Detections[id][SHAKE] < 0)
			Detections[id][SHAKE] = 0;
	}
	else
		Detections[id][SHAKE]++;
	
	if(Detections[id][SHAKE] > 350)
	{
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
		//show_hudmessage(id, "[Geek~Gamers] Shake WARNING!");
		show_hudmessage(id,"%L",LANG_PLAYER,"SHAKE_WARN");
		
		client_cmd(id, "spk %s", gWarningSounds[1]);
	}
	if(Detections[id][SHAKE] > 550)
		PunishUser(id);
	
	CopyVector(fAimAngles, fOldAimAngles[id]);
	
	return FMRES_IGNORED;
}

public CheckSpinHack_Post(id)
{
	static Float:fAngles[3];
	pev(id, pev_angles, fAngles);
	
	fTotalAngle[id] += vector_distance(fLastAngles[id], fAngles);
	
	CopyVector(fAngles, fLastAngles[id]);
	
	static Button;
	Button = pev(id, pev_button);
	
	if((Button & IN_LEFT) || (Button & IN_RIGHT))
		Detections[id][SPINHACK] = 0;
}

public Fwd_PlaybackEvent(flags, id, eventindex)
{
	if(!gSettings[CHECK_RAPIDFIRE])
		return FMRES_IGNORED;
	
	for(new i = 0 ; i < sizeof gGunsEvents ; i++)
	{
		if(eventindex == gGunsEventsId[i])
		{
			static Weapon, Trash;
			Weapon = get_user_weapon(id, Trash, Trash);
			
			static Float:fAimAngles[3];
			pev(id, pev_v_angle, fAimAngles);
			
			if(Weapon == CSW_GLOCK18)
				return FMRES_IGNORED;
			
			if(gSettings[CHECK_RAPIDFIRE])
				Detections[id][RAPIDFIRE]++;
			
			if(gSettings[CHECK_LOWRECOIL])
			{
				if((fAimAngles[0] == fRecoilLastAngles[id][0]) && fRecoilLastAngles[id][0] != 0.0)
					Detections[id][RECOIL]++;
				else
					Detections[id][RECOIL]--;
				
				fRecoilLastAngles[id][0] = fAimAngles[0];
				
				if(Detections[id][RECOIL] > 6)
				{
					set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
					//show_hudmessage(id, "[Geek~Gamers] Low-recoil warning!");
					show_hudmessage(id,"%L",LANG_PLAYER,"LOW_RECOIL");
					
					client_cmd(id, "spk %s", gWarningSounds[1]);
				}
				if(Detections[id][RECOIL] > 8)
					PunishUser(id);
			}
		}
	}
	return FMRES_IGNORED;
}

public ClearRecoil()
{
	static Players[32], iNum;
	get_players(Players, iNum, "ach");
	
	for(new i = 0 ; i < iNum ; i++)
	{
		Detections[Players[i]][RECOIL] -= 10;
		
		if(Detections[Players[i]][RECOIL] < 0)
			Detections[Players[i]][RECOIL] = 0;
	}
}

public CheckSpeedHack()
{
	static Players[32], iNum, id;
	get_players(Players, iNum, "ach");
	
	for(new i = 0 ; i < iNum ; i++)
	{
		id = Players[i];
		
		if(cs_get_user_driving(id) >= 0)
			continue;
		
		static Float:fOrigin[3], Float:fOldOrigin[3], Float:fDistance;
		pev(id, pev_origin, fOrigin);
		
		CopyVector(fLastOrigin[id], fOldOrigin);
		
		if(gSettings[SPEEDHACK_SECURE])
		{
			fOrigin[2] = 0.0;
			fOldOrigin[2] = 0.0;
		}
		
		fDistance = get_distance_f(fOrigin, fOldOrigin);
		
		if(Detections[id][SPEEDHACK] >= 3)
			Detections[id][SPEEDHACK]--;
		
		if(Detections[id][SPEEDHACK] < 0)
			Detections[id][SPEEDHACK] = 0;
		
		if(fDistance >= 240.0)
			Detections[id][SPEEDHACK] += 3;
		
		if(Detections[id][SPEEDHACK] >= 6)
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
			show_hudmessage(id, "[Geek~Gamers] Speedhack warning!");
			show_hudmessage(id,"%L",LANG_PLAYER,"SPEED_HACK");
			
			client_cmd(id, "spk %s", gWarningSounds[1]);
		}
		if(Detections[id][SPEEDHACK] >= 8)
			PunishUser(id);
		
		CopyVector(fOrigin, fLastOrigin[id]);
	}
}

public CheckSpinTotal()
{
	static Players[32], iNum, id;
	get_players(Players, iNum, "ach");
	
	for(new i = 0 ; i < iNum ; i++)
	{
		id = Players[i];
		
		if(fTotalAngle[id] >= 1500.0)
		{		
			if(Detections[id][SPINHACK] >= 25 / 3)
			{
				set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
				//show_hudmessage(id, "[Geek~Gamers] Spinhack warning!");
				show_hudmessage(id,"%L",LANG_PLAYER,"SPIN_HACK");
				
				client_cmd(id, "spk %s", gWarningSounds[1]);
			}
			if(Detections[id][SPINHACK] >= 25)
				PunishUser(id);
			
			Detections[id][SPINHACK]++;
		}
		else
			Detections[id][SPINHACK] = 0;
		
		fTotalAngle[id] = 0.0;
	}
}

public CheckRapidFire()
{
	static Players[32], iNum, id;
	get_players(Players, iNum, "ach");
	
	for(new i = 0 ; i < iNum ; i++)
	{
		id = Players[i];
		
		if(Detections[id][RAPIDFIRE] >= 15)
			PunishUser(id);
		
		Detections[id][RAPIDFIRE] = 0;
	}
}

public CheckScriptBlock(id)
{
	static Float:fAimAngles[3];
	pev(id, pev_angles, fAimAngles);
	
	CopyVector(fAimAngles, fAimOrigin[id]);
	
	static Button;
	Button = pev(id, pev_button);
	
	if(Button & IN_LEFT)
	{
		client_cmd(id, "-left");
		
		CopyVector(fAimOrigin[id], fAimAngles);
		
		set_pev(id, pev_angles, fAimAngles);
		set_pev(id, pev_fixangle, 1);
		
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
		//show_hudmessage(id, "[Geek~Gamers] Left and Right keys are disabled!");
		show_hudmessage(id,"%L",LANG_PLAYER,"LF_R_L_KEYS");
	}
	else if(Button & IN_RIGHT)
	{
		client_cmd(id, "-right");
		
		CopyVector(fAimOrigin[id], fAimAngles);
		
		set_pev(id, pev_angles, fAimAngles);
		set_pev(id, pev_fixangle, 1);
		
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
		//show_hudmessage(id, "[Geek~Gamers] Left and Right keys are disabled!");
		show_hudmessage(id,"%L",LANG_PLAYER,"LF_R_L_KEYS");
	}
	
	if(gSettings[CHECK_DOUBLEATTACK])
	{
		if((Button & IN_ATTACK) && (Button & IN_ATTACK2))
		{
			Button = Button & ~IN_ATTACK2;
			set_pev(id, pev_button, Button);
			
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
			//show_hudmessage(id, "[Geek~Gamers] Dual attack is not allowed!");
			show_hudmessage(id,"%L",LANG_PLAYER,"DUAL_ATTACK");
			
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public EventDeathMsg()
{
	if(!gSettings[CHECK_WALLHACK])
		return 1;
	
	static Killer, Victim, Weapon[32];
	read_data(4, Weapon, CharsMax(Weapon));
	
	if(equali(Weapon, "grenade"))
		return 1;
	
	Killer = read_data(1);
	Victim = read_data(2);
	
	static bool:IsVisible;
	IsVisible = fm_is_ent_visible(Killer, Victim, 1);
	
	if(!IsVisible)
		WallKills[Killer]++;
	
	if(WallKills[Killer] >= gSettings[WALLHACK_MAX_DETECTS])
		PunishUser(Killer);
	
	return 0;
}

public client_infochanged(id)
{
	static NewName[32], OldName[32];
	
	get_user_name(id, OldName, CharsMax(OldName));
	get_user_info(id, "name", NewName, CharsMax(NewName));
	
	if(!equali(NewName, OldName))
	{
		if(!gSettings[CHECK_FASTNAME])
			return 1;
		
		NamesChangesNum[id]++;
		
		if(NamesChangesNum[id] >= 4)
			PunishUser(id);
		
		if(!task_exists(id))
			set_task(4.0, "ClearChangesNum", id);
	}
	return 0;
}

public ClearChangesNum(id)
	NamesChangesNum[id] = 0;


public Fwd_TraceLine(Float:StartPos[3], Float:EndPos[3], SkipMonsters, id, Trace)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(!gSettings[CHECK_AIMBOT])
		return FMRES_IGNORED;
	
	static Float:fGameTime;
	fGameTime = get_gametime();
	
	if(fNextAimCheck[id] < fGameTime)
	{
		static iTarget, iHitGroup, Button;
		iTarget = get_tr2(Trace, TR_pHit);
		iHitGroup = (1 << get_tr2(Trace, TR_iHitgroup));
		Button = pev(id, pev_button);
		
		if(!is_user_alive(iTarget))
			return FMRES_IGNORED;
		
		if(get_pdata_int(id, FM_TEAM_OFFSET) != get_pdata_int(iTarget, FM_TEAM_OFFSET))
		{
			if((iHitGroup & FM_HITGROUP_HEAD) && (Button != 0))
				Detections[id][AIMBOT]++;
			else if(!(iHitGroup & FM_HITGROUP_HEAD) || (Button <= 0))
				Detections[id][AIMBOT] = 0;
			
			if(Detections[id][AIMBOT] >= 6)
			{
				set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 1.0, 1.0, 3);
				show_hudmessage(id, "[Geek~Gamers] Aimbot warning!");
				show_hudmessage(id,"%L",LANG_PLAYER,"AIM_BOT");
				
				client_cmd(id, "spk %s", gWarningSounds[1]);
			}
			if(Detections[id][AIMBOT] >= 7)
				PunishUser(id);
			
			fNextAimCheck[id] = fGameTime + 0.5;
		}
	}
	return FMRES_IGNORED;
}

stock CountCheaters()
{
	static BaseDir[64], File[64];
	get_basedir(BaseDir, CharsMax(BaseDir));
	
	formatex(File, CharsMax(File), "%s/Sakura_Anticheat/Sakura_Anticheat_Detects.txt", BaseDir);
	
	if(!file_exists(File))
		write_file(File, ";Sakura Anticheat number of players detected.", -1);
		
	
	static Line, Len, Buffer[16];
	Line = read_file(File, Line, Buffer, CharsMax(Buffer), Len);
	
	static Num;
	Num = str_to_num(Buffer);
	
	Num++;
	
	num_to_str(Num, Buffer, CharsMax(Buffer));
	
	write_file(File, Buffer, 0);
}

stock Fm_user_slap(index, Float:fDamage = 0.0)
{
	static Float:fPunchangle[3];
	pev(index, pev_punchangle, fPunchangle);
	
	fPunchangle[0] += random_float(-8.0, 8.0);
	fPunchangle[1] += random_float(-8.0, 8.0);
	
	set_pev(index, pev_punchangle, fPunchangle);
	
	static Float:fVelocity[3];
	pev(index, pev_velocity, fVelocity);
	
	fVelocity[0] += random_num(0, 1) ? 264.0 : -264.0;
	fVelocity[1] += random_num(0, 1) ? 264.0 : -264.0;
	
	set_pev(index, pev_basevelocity, fVelocity);
	
	fm_fakedamage(index, "worldspawn", fDamage, 1);
	
	return 1;
}

stock PunishUser(index)
{
	if(!is_user_connected(index))
		return;
	
	if(gSettings[IGNORE_ADMINS])
	{
		if(access(index, ADMIN_IGNORE_FLAG))
		{
			WriteToLog(index, 0, "");
			return;
		}
	}
	
	if(!IsDetected[index])
	{
		static Name[32], authid[32], uid;
		get_user_name(index, Name, CharsMax(Name));
		get_user_authid(index,authid,sizeof authid - 1);
		uid = get_user_userid(index);
		
		switch(gSettings[PUNISH_TYPE])
		{
			case 0 :
			{	
				client_cmd(index, "spk %s", gWarningSounds[0]);
				
				set_hudmessage(255, 0, 0, -1.0, 0.85, 0, 6.0, 5.0, 1.0, 1.0, 3);
				show_hudmessage(index, "[Geek~Gamers] You have been detected with cheats!");
				show_hudmessage(index,"%L",LANG_PLAYER,"HACK_DETECT");
				
				client_print(0, print_chat, "[Geek~Gamers] %s was detected with cheats!", Name);
				client_print(0,print_chat,"%L",LANG_PLAYER,"ID_WITH_HACK",Name);
			}
			case 1 :
			{
				client_cmd(index, "spk %s", gWarningSounds[0]);
				server_cmd("kick #%d ^"[Geek~Gamers] You have been detected with cheats!", uid);
				server_cmd("kick #%d ^"%L^"",uid,LANG_PLAYER,"HACK_DETECT");
				
				//client_print(0, print_chat, "[Geek~Gamers] %s was kicked by SDC for having cheats!", Name);
				client_print(0,print_chat,"%L",LANG_PLAYER,"KICK_HAVE_CHEAT",Name);
			}
			case 2 :
			{	    
				switch(gSettings[BAN_TYPE])
				{
					// STEAM ID
					case 0:
					{
						client_cmd(index, "spk %s", gWarningSounds[0])
						
						server_cmd("kick #%d;wait;wait;wait;banid %d ^"%s^";wait;wait;wait;writeid", uid, gSettings[BAN_TIME], authid);
						//client_print(0, print_chat, "[Geek~Gamers] %s was banned for %d min by SDC for having cheats!", Name, gSettings[BAN_TIME]);
						client_print(0,print_chat,"%L",LANG_PLAYER,"BAN_MIN_CHEAT",Name, gSettings[BAN_TIME]);
	
					}
					
					// IP
					case 1:
					{
						static Ip[32];
						get_user_ip(index, Ip, CharsMax(Ip), 1);
						
						client_cmd(index, "spk %s", gWarningSounds[0]);
						server_cmd("kick #%d;wait;wait;wait;addip %d ^"%s^";wait;wait;writeip", uid, gSettings[BAN_TIME], Ip);
						
						//client_print(0, print_chat, "[Geek~Gamers] %s was banned for %d min by SDC for having cheats!", Name, gSettings[BAN_TIME]);
						client_print(0,print_chat,"%L",LANG_PLAYER,"BAN_MIN_CHEAT",Name, gSettings[BAN_TIME]);
					}
					
					// AMX BANS
					case 2:
					{
						client_cmd(index, "spk %s", gWarningSounds[0]);
						server_cmd("amx_ban %d %s",gSettings[BAN_TIME], Name);
						
						//client_print(0, print_chat, "[Geek~Gamers] %s was banned for %d min by SDC for having cheats!", Name, gSettings[BAN_TIME]);
						client_print(0,print_chat,"%L",LANG_PLAYER,"BAN_MIN_CHEAT",Name, gSettings[BAN_TIME]);
					}
				}
			}
		}
		
		CountCheaters();
		WriteToLog(index, gSettings[PUNISH_TYPE], "");
		
		IsDetected[index] = true;
	}
}

stock CopyVector(Float:fVec1[3], Float:fVec2[3])
{
	fVec2[0] = fVec1[0];
	fVec2[1] = fVec1[1];
	fVec2[2] = fVec1[2];
}

stock WriteToLog(id, _:Log_Type, String[])
{
	if(!gSettings[PLUGIN_LOG_ACTIONS])
		return;
	
	static BaseDir[64], LogsDir[64], File[64];
	get_basedir(BaseDir, CharsMax(BaseDir));
	
	formatex(LogsDir, CharsMax(LogsDir), "%s/Sakura_Anticheat/logs", BaseDir);
	formatex(File, CharsMax(File), "%s/Sakura_Anticheat_LOG.Log", LogsDir);
	
	if(!dir_exists(LogsDir))
		mkdir(LogsDir);
	
	if(!file_exists(File))
		write_file(File, ";SDC logs file.", -1);
	
	static Name[32], Ip[32];
	
	if(Log_Type != -1)
	{
		get_user_name(id, Name, CharsMax(Name));
		get_user_ip(id, Ip, CharsMax(Ip), 1);
	}
	
	switch(Log_Type)
	{
		case -1 : { log_to_file(File, "%s", String); }
		case 0 : { log_to_file(File, "%L",LANG_PLAYER,"LOG_F_1", Name, Ip); }
		case 1 : { log_to_file(File, "%L",LANG_PLAYER,"LOG_F_2", Name, Ip); }
		case 2 : { log_to_file(File, "%L",LANG_PLAYER,"LOG_F_3", Name, Ip); }
	}
}

stock bool:Exists_IP(id, const File[])
{
	new iFile = fopen(File, "rt");
	
	if(!iFile)
		write_file(File, "", -1);
	
	new Ip[32]
	get_user_ip(id, Ip, sizeof Ip - 1, 1);
	
	while(!feof(iFile))
	{
		static Buffer[64];
		fgets(iFile, Buffer, sizeof Buffer - 1);
		
		if(Buffer[0] == ';')
			continue;
		
		new nLen = strlen(Ip);
		
		if(equali(Ip, Buffer, nLen))
		{
			fclose(iFile);
			return true;
		}
	}
	fclose(iFile);
	
	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
