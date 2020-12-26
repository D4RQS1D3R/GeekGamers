/* -------------------------------------------- [ Plugin By ~D4rkSiD3Rs~ ] --------------------------------------------------------

        DDDDDD              4     RRRRRRRR       KK      KK    SSSSSS    II   DDDDDD       3333333    RRRRRRRR        SSSSSS
        DD   DD            44     RRRRRRRRR      KK     KK    SSSSSSSS   II   DD   DD      33333333   RRRRRRRRR      SSSSSSSS
        DD    DD          444     RR      RR     KK    KK     SS         II   DD    DD           33   RR      RR     SS
        DD     DD        4444     RR      RR     KK   KK      SSS        II   DD     DD          33   RR      RR     SSS
		DD      DD      44 44     RR      RR     KKK KK        SSS       II   DD      DD        333   RR      RR      SSS
        DD      DD     44  44     RR     RR      KKKKK          SSS      II   DD      DD    333333    RR     RR        SSS
        DD      DD    44   44     RRRRRRRRR      KKKKK           SSS     II   DD      DD        333   RRRRRRRR          SSS
        DD     DD    4444444444   RR     RR      KK  KK           SSS    II   DD     DD          33   RR    RRR          SSS
        DD    DD    44444444444   RR      RR     KK   KK           SSS   II   DD    DD           33   RR      RR          SSS
        DD   DD            44     RR       RR    KK    KK     SSSSSSSS   II   DD   DD      33333333   RR       RR    SSSSSSSS
        DDDDDD             44     RR        RR   KK     KK     SSSSSS    II   DDDDDD       3333333    RR        RR    SSSSSS

----------------------------------------------- [ Plugin By ~D4rkSiD3Rs~ ] ------------------------------------------------------ */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <fcs>

#pragma compress 1

#define PLUGIN "[GG] Level Menu"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

#define OWNER_LEVEL ADMIN_LEVEL_B

#define VIPWEAPONS_FLAGS "t"
#define VIP_FLAGS "st"
#define SILVERVIP_FLAGS "bceijrstu"
#define GOLDVIP_FLAGS "bcdefijqrstu"

native bool: modstarted(id);
native get_level(id);
native set_user_autobhop(id);
native gg_set_user_electroawp(id);
native SetUserLaserMine(id);
native gg_set_user_suicidebomb(id);
native Respawn(id);
native is_registered(id);
native WhiteListed(const PlayerName[]);

native assassin_mod(id);
native sniper_mod(id);
native avs_mod(id);
native csdm_mod(id);
native ghost_mod(id);

native Become_Sniper(id);
native Become_Assassin(id);
native Become_Ghost(id);

native white_furien(id);
native red_furien(id);
native black_furien(id);

native green_human(id);
native white_human(id);
native black_human(id);

new maxlevel, money_multiplier, hp_multiplier, damage_multiplier;
new vipweapons, vip, silver_vip, gold_vip;
new vipweapons_cost, vip_cost, silver_vip_cost, gold_vip_cost;
new expir_day[33] = 0, expir_month[33] = 0, expir_year[33] = 0;
new playersremaining;
new Nade[33];
//new Nade_Cooldown[33] = 0;
new bool: has_higher_access[33], bool: has_access[33];
new bool: g_HasGodmode[33];
new bool: g_HasSuicideBomb[33];
new bool: have_awp[33];
new bool: WeaponChoosen[33];
new bool: TeamChanged[33];
new bool: CantBecomeSoAoG[33];

new add_money[33];
new add_hp[33];
new add_damage[33];
new random_money[33];
new lmset[33];
new respawned[33];
new tchanged[33];

//new gHudSync;

/************ Unlimited Ammo ************/

// weapons offsets
#define OFFSET_CLIPAMMO        51
#define OFFSET_LINUX_WEAPONS    4
#define fm_cs_set_weapon_ammo(%1,%2)	set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)

// players offsets
#define m_pActiveItem 373

new have_unlimited_ammo[33];

const NOCLIP_WPN_BS	= ((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))

new const g_MaxClipAmmo[] = 
{
    0,
    13,	//CSW_P228
    0,
    10,	//CSW_SCOUT
    0,  //CSW_HEGRENADE
    7,	//CSW_XM1014
    0,	//CSW_C4
    30,	//CSW_MAC10
    30, //CSW_AUG
    0,  //CSW_SMOKEGRENADE
    15,	//CSW_ELITE
    20,	//CSW_FIVESEVEN
    25,	//CSW_UMP45
    30, //CSW_SG550
    35, //CSW_GALIL
    25, //CSW_FAMAS
    12,	//CSW_USP
    20,	//CSW_GLOCK18
    10,	//CSW_AWP
    30,	//CSW_MP5NAVY
    100,//CSW_M249
    8,  //CSW_M3
    30, //CSW_M4A1
    30,	//CSW_TMP
    20, //CSW_G3SG1
    0,  //CSW_FLASHBANG
    7,  //CSW_DEAGLE
    30, //CSW_SG552
    30, //CSW_AK47
    0,  //CSW_KNIFE
    50	//CSW_P90
}

/************ Unlimited Ammo ************/

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /levelmenu", "LevelMenu");
	register_clcmd("say /lvlmenu", "LevelMenu");
	register_clcmd("say levelmenu", "LevelMenu");
	register_clcmd("say lvlmenu", "LevelMenu");
	register_clcmd("levelmenu", "LevelMenu");
	register_clcmd("lvlmenu", "LevelMenu");

	register_event("HLTV", "Round_Start", "a", "1=0", "2=0");
	register_event("CurWeapon", "CurWeapon", "be", "1=1");

	RegisterHam(Ham_Spawn, "player", "ham_SpawnPlayerPost", true);
	RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage");

	maxlevel			= register_cvar("amx_levelmenu_max", "100", OWNER_LEVEL);
	money_multiplier	= register_cvar("amx_levelmenu_moneymultiplier", "20", OWNER_LEVEL);
	hp_multiplier		= register_cvar("amx_levelmenu_hpmultiplier", "2", OWNER_LEVEL);
	damage_multiplier	= register_cvar("amx_levelmenu_damagemultiplier", "2", OWNER_LEVEL);

	vipweapons			= register_cvar("amx_levelmenu_vipweapons", "35", OWNER_LEVEL);
	vip					= register_cvar("amx_levelmenu_vip", "70", OWNER_LEVEL);
	silver_vip			= register_cvar("amx_levelmenu_silver", "100", OWNER_LEVEL);
	gold_vip			= register_cvar("amx_levelmenu_gold", "150", OWNER_LEVEL);

	vipweapons_cost		= register_cvar("amx_levelmenu_vipweapons_cost", "1500", OWNER_LEVEL);
	vip_cost			= register_cvar("amx_levelmenu_vip_cost", "3000", OWNER_LEVEL);
	silver_vip_cost		= register_cvar("amx_levelmenu_silver_cost", "6500", OWNER_LEVEL);
	gold_vip_cost		= register_cvar("amx_levelmenu_gold_cost", "10000", OWNER_LEVEL);

	playersremaining	= register_cvar("amx_players_remaining", "6");

	//gHudSync = CreateHudSyncObj();
}

public plugin_natives()
{
	register_native("get_addmoney", "native_addmoney", 1);
	register_native("get_addhp", "native_addhp", 1);
	register_native("get_adddamage", "native_adddamage", 1);
}

public client_putinserver(id) GetRewards(id);

public client_disconnected(id) remove_task(id);

public Round_Start()
{
	new iPlayers[32], iNum;

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new Players = iPlayers[i];

		random_money[Players] = 0;
		g_HasGodmode[Players] = false;
		TeamChanged[Players] = false;
		g_HasSuicideBomb[Players] = false;

		CantBecomeSoAoG[Players] = false;
		set_task(30.0, "TurnOffBecomeSoAoG", Players);

		if( get_level(Players) >= 135 || get_user_flags(Players) & OWNER_LEVEL )
		{
			if( cs_get_user_team(Players) == CS_TEAM_CT )
			{
				if(assassin_mod(Players) || sniper_mod(Players) || ghost_mod(Players) || csdm_mod(Players))
					continue;

				if(have_unlimited_ammo[Players] >= 4)
					have_unlimited_ammo[Players] = 1;
				else have_unlimited_ammo[Players] ++;
			}
		}
	}
}

public TurnOffBecomeSoAoG(id) CantBecomeSoAoG[id] = true;

public ham_SpawnPlayerPost(id)
{
	if( !is_user_alive(id) )
		return;

	GetRewards(id);

	WeaponChoosen[id] = false;
	have_awp[id] = false;

	if( (white_furien(id) && cs_get_user_team(id) == CS_TEAM_T) || (green_human(id) && cs_get_user_team(id) == CS_TEAM_CT) )
	{
		cs_set_user_money(id, cs_get_user_money(id) + add_money[id]);
	}

	if( (red_furien(id) && cs_get_user_team(id) == CS_TEAM_T) || (white_human(id) && cs_get_user_team(id) == CS_TEAM_CT) )
	{
		set_user_health(id, get_user_health(id) + add_hp[id]);
	}

	if(get_level(id) >= 10 || get_user_flags(id) & ADMIN_IMMUNITY)
	{
		set_user_autobhop(id);
	}
}

public LevelMenu(id)
{
	static name[32]; get_user_name(id, name, charsmax(name) - 1);
	if(WhiteListed(name))
		return PLUGIN_CONTINUE;

	GetRewards(id);

	new temp[101];

	if( (white_furien(id) && cs_get_user_team(id) == CS_TEAM_T) || (green_human(id) && cs_get_user_team(id) == CS_TEAM_CT) )
		formatex( temp, 100, "\d[\yGeek~Gamers\d] \rLevel Menu \w[ \yYour Level: \r%d \w]^n^n\y>> \rMoney : \y+%d \r$", get_level(id), add_money[id] );

	if( (red_furien(id) && cs_get_user_team(id) == CS_TEAM_T) || (white_human(id) && cs_get_user_team(id) == CS_TEAM_CT) )
		formatex( temp, 100, "\d[\yGeek~Gamers\d] \rLevel Menu \w[ \yYour Level: \r%d \w]^n^n\y>> \rHealth : \y+%d \rHP", get_level(id), add_hp[id] );

	if( (black_furien(id) && cs_get_user_team(id) == CS_TEAM_T) || (black_human(id) && cs_get_user_team(id) == CS_TEAM_CT) )
		formatex( temp, 100, "\d[\yGeek~Gamers\d] \rLevel Menu \w[ \yYour Level: \r%d \w]^n^n\y>> \rDamage : \y+%d", get_level(id), add_damage[id] );

	new menu = menu_create(temp, "LevelMenuHandler");

	if( get_level(id) >= 10 )
		menu_additem(menu, "\yAutoBhop \r[LEVEL: 10]", "", 0);
	else menu_additem(menu, "\dAutoBhop \r[LEVEL: 10]", "", 0);

	if( get_level(id) >= 20 )
		menu_additem(menu, "\wMore Weapons Menu \r[LEVEL: 20]", "", 0);
	else menu_additem(menu, "\dMore Weapons Menu \r[LEVEL: 20]", "", 0);

	new temp1[101];
	formatex( temp1, 100, "%sRandom Money 0-2500$ \r[%d/5][Cost: 1000$][LEVEL: 30]", get_level(id) >= 30 ? "\w" : "\d", random_money[id] );
	menu_additem(menu, temp1, "", 0);

	new temp2[101];
	formatex( temp2, 100, "%sV.I.P Weapons/Knives \r[%d Credits/Month][LEVEL: %d]", get_level(id) >= get_pcvar_num(vipweapons) ? "\y" : "\d", get_pcvar_num(vipweapons_cost), get_pcvar_num(vipweapons) );
	menu_additem(menu, temp2, "", 0);

	if( get_level(id) >= 40 )
		menu_additem(menu, "\wNades Menu \r[LEVEL: 40]", "", 0);
	else menu_additem(menu, "\dNades Menu \r[LEVEL: 40]", "", 0);

	if( get_level(id) >= 50 )
		menu_additem(menu, "\wAWP Elven Ranger \r[Cost: 4000$][10 Shots][LEVEL: 50]", "", 0);
	else menu_additem(menu, "\dAWP Elven Ranger \r[Cost: 4000$][10 Shots][LEVEL: 50]", "", 0);

	if( get_level(id) >= 60 )
		menu_additem(menu, "\wGodMode 3sec \r[1/Round][LEVEL: 60]", "", 0);
	else menu_additem(menu, "\dGodMode 3sec \r[1/Round][LEVEL: 60]", "", 0);

	new temp3[101];
	formatex( temp3, 100, "%sV.I.P + Green Chat \r[%d Credits/Month][LEVEL: %d]", get_level(id) >= get_pcvar_num(vip) ? "\y" : "\d", get_pcvar_num(vip_cost), get_pcvar_num(vip) );
	menu_additem(menu, temp3, "", 0);

	new temp4[101];
	formatex( temp4, 100, "%sLaserMine \r[%d/5][1/Round][LEVEL: 80]", get_level(id) >= 80 ? "\w" : "\d", lmset[id] );
	menu_additem(menu, temp4, "", 0);

	new temp5[101];
	formatex( temp5, 100, "%sRespawn \r[%d/10][LEVEL: 90]", get_level(id) >= 90 ? "\w" : "\d", respawned[id] );
	menu_additem(menu, temp5, "", 0);

	new temp6[101];
	formatex( temp6, 100, "%sBecome Furien / Human \r[%d/5][LEVEL: 95]", get_level(id) >= 95 ? "\w" : "\d", tchanged[id] );
	menu_additem(menu, temp6, "", 0);

	new temp7[101];
	formatex( temp7, 100, "%sSilver V.I.P \r[%d Credits/Month][LEVEL: %d]", get_level(id) >= 95 ? "\y" : "\d", get_pcvar_num(silver_vip_cost), get_pcvar_num(silver_vip) );
	menu_additem(menu, temp7, "", 0);

	if( get_level(id) >= 110 )
		menu_additem(menu, "\yBecome Sniper \r[1000 Credits][LEVEL: 110]", "", 0);
	else menu_additem(menu, "\dBecome Sniper \r[1000 Credits][LEVEL: 110]", "", 0);

	if( get_level(id) >= 120 )
		menu_additem(menu, "\wSuicide Bomb \r[Press 'F'][LEVEL: 120]", "", 0);
	else menu_additem(menu, "\dSuicide Bomb \r[Press 'F'][LEVEL: 120]", "", 0);

	if( get_level(id) >= 130 )
		menu_additem(menu, "\yBecome Assassin \r[1500 Credits][LEVEL: 130]", "", 0);
	else menu_additem(menu, "\dBecome Assassin \r[1500 Credits][LEVEL: 130]", "", 0);

	if( get_level(id) >= 135 )
		menu_additem(menu, "\yUnlimited Clip \r[Every 4 Rounds][LEVEL: 135]", "", 0);
	else menu_additem(menu, "\dUnlimited Clip \r[Every 4 Rounds][LEVEL: 135]", "", 0);

	if( get_level(id) >= 140 )
		menu_additem(menu, "\yBecome Ghost \r[2000 Credits][LEVEL: 140]", "", 0);
	else menu_additem(menu, "\dBecome Ghost \r[2000 Credits][LEVEL: 140]", "", 0);

	new temp8[101];
	formatex( temp8, 100, "%sGold V.I.P \r[%d Credits/Month][LEVEL: %d]", get_level(id) >= get_pcvar_num(gold_vip) ? "\y" : "\d", get_pcvar_num(gold_vip_cost), get_pcvar_num(gold_vip) );
	menu_additem(menu, temp8, "", 0);

	menu_additem(menu, "\wMore Ideas Comming Soon..", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public LevelMenuHandler(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	new player_name[32];
	get_user_name(id, player_name, charsmax(player_name));

	switch(item)
	{
		case 0:
		{
			if( get_level(id) >= 10 || get_user_flags(id) & OWNER_LEVEL )
				ChatColor(id, "!g[GG][Level-Menu] !nAutobhop is automatically given to you!t!");
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 10 Needed !t!");
		}
		case 1: MoreWeapons(id);
		case 2:
		{
			if( get_level(id) >= 30 || get_user_flags(id) & OWNER_LEVEL )
			{
				if( random_money[id] < 5 )
				{
					if( cs_get_user_money(id) >= 1000 )
					{
						new money = cs_get_user_money(id) - 1000;
						new reward = random_num(0, 2500);
						cs_set_user_money(id, money + reward);
						ChatColor(id, "!g[GG][Level-Menu] !nYou got !t%d$ !n.", reward);
						random_money[id] ++;
					}
					else ChatColor(id, "!g[GG][Level-Menu] !nYou dont have enough !tmoney!n.");
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 30 Needed !t!");
		}
		case 3:
		{
			if( get_level(id) >= get_pcvar_num(vipweapons) || get_user_flags(id) & OWNER_LEVEL )
			{
				if(is_registered(id))
				{
					BuyVIPWeaponsMenu(id);
				}
				else
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou must !tregister !nyour name first!n.");
					client_cmd(id, "say /reg");
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel %d Needed !t!", get_pcvar_num(vipweapons));
		}
		case 4: NadesMenu(id);
		case 5:
		{
			if( get_level(id) >= 50 || get_user_flags(id) & OWNER_LEVEL )
			{
				if( cs_get_user_team(id) == CS_TEAM_CT )
				{
					if( !have_awp[id] )
					{
						if(assassin_mod(id) || sniper_mod(id) || avs_mod(id) || ghost_mod(id))
						{
							ChatColor(id, "!g[GG][Level-Menu] !nYou can't choose !tAWP Elven Ranger !non the current mod !t!");
						}
						else
						{
							if( cs_get_user_money(id) >= 4000 )
							{
								gg_set_user_electroawp(id);
								have_awp[id] = true;
							}
							else ChatColor(id, "!g[GG][Level-Menu] !nYou dont have enough !tmoney!n.");
						}
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 50 Needed !t!");
		}
		case 6:
		{
			if( get_level(id) >= 60 || get_user_flags(id) & OWNER_LEVEL )
			{
				if(!is_user_alive(id))
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou should be alive to use !gGodmode !t!");
					return PLUGIN_HANDLED;
				}

				if(!g_HasGodmode[id])
				{
					fm_set_user_godmode(id, 1);
					g_HasGodmode[id] = true;
					ChatColor(id, "!g[GG][Level-Menu] !nYour !tGodmode !nis expiring in !t3 seconds!n.");
					set_task(3.0, "removeGodmode", id);
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 60 Needed !t!");
		}
		case 7:
		{
			if( get_level(id) >= get_pcvar_num(vip) || get_user_flags(id) & OWNER_LEVEL )
			{
				if(is_registered(id))
				{
					BuyVIPMenu(id);
				}
				else
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou must !tregister !nyour name first!n.");
					client_cmd(id, "say /reg");
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel %d Needed !t!", get_pcvar_num(vip));
		}
		case 8:
		{
			if( get_level(id) >= 80 || get_user_flags(id) & OWNER_LEVEL )
			{
				if( lmset[id] < 5 )
				{
					if( is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT )
					{
						if(assassin_mod(id) || ghost_mod(id) || csdm_mod(id))
						{
							ChatColor(id, "!g[GG][Level-Menu] !nYou can't choose !tLaserMine !non the current mod !t!");
						}
						else
						{
							SetUserLaserMine(id);
							lmset[id] ++;
						}
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 80 Needed !t!");
		}
		case 9:
		{
			if( get_level(id) >= 90 || get_user_flags(id) & OWNER_LEVEL )
			{
				if( respawned[id] < 10 )
				{
					Respawn(id);

					if(is_user_alive(id))
						respawned[id] ++;
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 90 Needed !t!");
		}
		case 10: 
		{
			if( get_level(id) >= 95 || get_user_flags(id) & OWNER_LEVEL )
			{
				if( tchanged[id] < 5 )
				{
					Transfer(id);
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 95 Needed !t!");
		}
		case 11:
		{
			if( get_level(id) >= get_pcvar_num(silver_vip) || get_user_flags(id) & OWNER_LEVEL )
			{
				if(is_registered(id))
				{
					BuySilverVIPMenu(id);
				}
				else
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou must !tregister !nyour name first!n.");
					client_cmd(id, "say /reg");
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel %d Needed !t!", get_pcvar_num(silver_vip));
		}
		case 12:
		{
			if( get_level(id) >= 110 || get_user_flags(id) & OWNER_LEVEL )
			{
				new TPlayers[32], TNum;
				new CTPlayers[32], CTNum;

				get_players(TPlayers, TNum, "e", "TERRORIST");
				get_players(CTPlayers, CTNum, "e", "CT");

				if(TNum + CTNum < get_pcvar_num(playersremaining))
				{
					ChatColor(id, "!g[GG][Level-Menu] !nThere must be atleast !t%d !nplayers to start a mod !", get_pcvar_num(playersremaining));
					LevelMenu(id);
				}
				else
				{
					if(modstarted(id))
					{
						ChatColor(id, "!g[GG][Level-Menu] !nYou can't became a !tSniper !nin the current mod !");
						LevelMenu(id);
					}
					else
					{
						if(CantBecomeSoAoG[id])
						{
							ChatColor(id, "!g[GG][Level-Menu] !nYou can't became a !tSniper !nafter 30 seconds of the round start !");
							LevelMenu(id);
						}
						else
						{
							new iCredits = fcs_get_user_credits(id) - 1000;
							if( iCredits < 0 )
							{
								ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
								LevelMenu(id);
							}
							else
							{
								Become_Sniper(id);
								fcs_set_user_credits( id, iCredits );

								ChatColor(id, "!g[GG][Level-Menu] !t%s !nBought !gSniper!n.", player_name);

								set_dhudmessage(0, 100, 200, -1.0, 0.25, 2, 0.02, 3.0, 0.01, 0.1);
								show_dhudmessage(0, "-=[SNIPER MOD]=-^n%s Became a Sniper !", player_name);
							}
						}
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 110 Needed !t!");
		}
		case 13:
		{
			if( get_level(id) >= 120 || get_user_flags(id) & OWNER_LEVEL )
			{
				if(g_HasSuicideBomb[id])
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou can only use !tSuicide Bomb !nonce per round !");
					LevelMenu(id);
				}
				else
				{
					if(assassin_mod(id) || sniper_mod(id) || ghost_mod(id) || csdm_mod(id))
					{
						ChatColor(id, "!g[GG][Level-Menu] !nYou can't use !tSuicide Bomb !nin the current mod !");
						LevelMenu(id);
					}
					else
					{
						gg_set_user_suicidebomb(id);
						g_HasSuicideBomb[id] = true;
						ChatColor(id, "!g[GG][Level-Menu] !nYou're now armed with a !tsuicide bomb!n. Use your !gflashlight !t(Press F) !nto activate it.");
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 120 Needed !t!");
		}
		case 14:
		{
			if( get_level(id) >= 130 || get_user_flags(id) & OWNER_LEVEL )
			{
				new TPlayers[32], TNum;
				new CTPlayers[32], CTNum;

				get_players(TPlayers, TNum, "e", "TERRORIST");
				get_players(CTPlayers, CTNum, "e", "CT");

				if(TNum + CTNum < get_pcvar_num(playersremaining))
				{
					ChatColor(id, "!g[GG][Level-Menu] !nThere must be atleast !t%d !nplayers to start a mod !", get_pcvar_num(playersremaining));
					LevelMenu(id);
				}
				else
				{
					if(modstarted(id))
					{
						ChatColor(id, "!g[GG][Level-Menu] !nYou can't became an !tAssassin !nin the current mod !");
						LevelMenu(id);
					}
					else
					{
						if(CantBecomeSoAoG[id])
						{
							ChatColor(id, "!g[GG][Level-Menu] !nYou can't became an !tAssassin !nafter 30 seconds of the round start !");
							LevelMenu(id);
						}
						else
						{
							new iCredits = fcs_get_user_credits(id) - 1500;
							if( iCredits < 0 )
							{
								ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
								LevelMenu(id);
							}
							else
							{
								Become_Assassin(id);
								fcs_set_user_credits( id, iCredits );

								ChatColor(id, "!g[GG][Level-Menu] !t%s !nBought !gAssassin!n.", player_name);

								set_hudmessage(0, 100, 200, -1.0, 0.25, 2, 0.02, 3.0, 0.01, 0.1);
								show_dhudmessage(0, "-=[ASSASSIN MOD]=-^n%s Became an Assassin !", player_name);
							}
						}
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 130 Needed !t!");
		}
		case 15:
		{
			if( get_level(id) >= 135 || get_user_flags(id) & OWNER_LEVEL )
			{
				ChatColor(id, "!g[GG][Level-Menu] !nYou will get !gUnlimited Clip !nautomatically Every 4 Rounds !t!");
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 135 Needed !t!");
		}
		case 16:
		{
			if( get_level(id) >= 140 || get_user_flags(id) & OWNER_LEVEL )
			{
				new TPlayers[32], TNum;
				new CTPlayers[32], CTNum;

				get_players(TPlayers, TNum, "e", "TERRORIST");
				get_players(CTPlayers, CTNum, "e", "CT");

				if(TNum + CTNum < get_pcvar_num(playersremaining))
				{
					ChatColor(id, "!g[GG][Level-Menu] !nThere must be atleast !t%d !nplayers to start a mod !", get_pcvar_num(playersremaining));
					LevelMenu(id);
				}
				else
				{
					if(modstarted(id))
					{
						ChatColor(id, "!g[GG][Level-Menu] !nYou can't became a !tGhost !nin the current mod !");
						LevelMenu(id);
					}
					else
					{
						if(CantBecomeSoAoG[id])
						{
							ChatColor(id, "!g[GG][Level-Menu] !nYou can't became a !tGhost !nafter 30 seconds of the round start !");
							LevelMenu(id);
						}
						else
						{
							new iCredits = fcs_get_user_credits(id) - 2000;
							if( iCredits < 0 )
							{
								ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
								LevelMenu(id);
							}
							else
							{
								Become_Ghost(id);
								fcs_set_user_credits( id, iCredits );

								ChatColor(id, "!g[GG][Level-Menu] !t%s !nBought !gGhost!n.", player_name);

								set_hudmessage(0, 100, 200, -1.0, 0.25, 2, 0.02, 3.0, 0.01, 0.1);
								show_dhudmessage(0, "-=[GHOST MOD]=-^n%s Became a Ghost !", player_name);
							}
						}
					}
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel 140 Needed !t!");
		}
		case 17:
		{
			if( get_level(id) >= get_pcvar_num(gold_vip) || get_user_flags(id) & OWNER_LEVEL )
			{
				if(is_registered(id))
				{
					BuyGoldVIPMenu(id);
				}
				else
				{
					ChatColor(id, "!g[GG][Level-Menu] !nYou must !tregister !nyour name first!n.");
					client_cmd(id, "say /reg");
				}
			}
			else ChatColor(id, "!g[GG][Level-Menu] !nLevel %d Needed !t!", get_pcvar_num(gold_vip));
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public GetRewards(id)
{
	if(get_level(id) < get_pcvar_num(maxlevel))
	{
		add_money[id] = get_pcvar_num(money_multiplier) * get_level(id);
	}
	else
	{
		add_money[id] = get_pcvar_num(money_multiplier) * get_pcvar_num(maxlevel);
	}

	if(get_level(id) < get_pcvar_num(maxlevel))
	{
		if(get_level(id)%2 == 0)
			add_hp[id] = get_level(id) / get_pcvar_num(hp_multiplier);
		else add_hp[id] = (get_level(id) - 1) / get_pcvar_num(hp_multiplier);
	}
	else
	{
		if(get_pcvar_num(maxlevel)%2 == 0)
			add_hp[id] = get_pcvar_num(maxlevel) / get_pcvar_num(hp_multiplier);
		else add_hp[id] = (get_pcvar_num(maxlevel) - 1) / get_pcvar_num(hp_multiplier);
	}

	if(get_level(id) < get_pcvar_num(maxlevel))
	{
		if(get_level(id)%2 == 0)
			add_damage[id] = get_level(id) / get_pcvar_num(damage_multiplier);
		else add_damage[id] = (get_level(id) - 1) / get_pcvar_num(damage_multiplier);
	}
	else
	{
		if(get_pcvar_num(maxlevel)%2 == 0)
			add_damage[id] = get_pcvar_num(maxlevel) / get_pcvar_num(damage_multiplier);
		else add_damage[id] = (get_pcvar_num(maxlevel) - 1) / get_pcvar_num(damage_multiplier);
	}
}

public MoreWeapons(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rMore Weapons Menu:", "MoreWeaponsMenuHandler");

	if( get_level(id) >= 20 || get_user_flags(id) & OWNER_LEVEL )
		menu_additem(menu, "\wSG550 Auto-Sniper", "", 0);
	else menu_additem(menu, "\dSG550 Auto-Sniper", "", 0);

	if( get_level(id) >= 20 || get_user_flags(id) & OWNER_LEVEL )
		menu_additem(menu, "\wG3SG1 Auto-Sniper", "", 0);
	else menu_additem(menu, "\dG3SG1 Auto-Sniper", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public MoreWeaponsMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & OWNER_LEVEL )
			{
				if(cs_get_user_team(id) == CS_TEAM_CT && !WeaponChoosen[id])
				{
					give_item(id, "weapon_sg550");
					cs_set_user_bpammo(id, CSW_SG550, 90);
					WeaponChoosen[id] = true;
				}
			}
		}
		case 1:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & OWNER_LEVEL )
			{
				if(cs_get_user_team(id) == CS_TEAM_CT && !WeaponChoosen[id])
				{
					give_item(id, "weapon_g3sg1");
					cs_set_user_bpammo(id, CSW_G3SG1, 90);
					WeaponChoosen[id] = true;
				}
			}
		}

	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public NadesMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rNades Menu:", "NadesMenuHandler");

	if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
	{
		if( Nade[id] == 1 )
			menu_additem(menu, "\yFireNade \r[Every 20s]", "", 0);
		else menu_additem(menu, "\wFireNade \r[Every 20s]", "", 0);
	}
	else menu_additem(menu, "\dFireNade \r[Every 20s]", "", 0);

	if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
	{
		if( Nade[id] == 2 )
			menu_additem(menu, "\yFlashBang \r[Every 30s]", "", 0);
		else menu_additem(menu, "\wFlashBang \r[Every 30s]", "", 0);
	}
	else menu_additem(menu, "\dFlashBang \r[Every 30s]", "", 0);

	if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
	{
		if( cs_get_user_team(id) == CS_TEAM_CT )
		{
			if( Nade[id] == 3 )
				menu_additem(menu, "\yFrostNade \r[Every 40s]", "", 0);
			else menu_additem(menu, "\wFrostNade \r[Every 40s]", "", 0);
		}
		else menu_additem(menu, "\dFrostNade \r[Every 40s]", "", 0);
	}
	else menu_additem(menu, "\dFrostNade \r[Every 40s]", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public NadesMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
			{
				Nade[id] = 1;
				set_task(20.0, "Give_FireNade", id);
				ChatColor(id, "!g[GG][Level-Menu] !nYou will receive a !tFireNade !nevery !t20 seconds !n!");
			}
		}
		case 1:
		{
			if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
			{
				Nade[id] = 2;
				set_task(30.0, "Give_FlashBang", id);
				ChatColor(id, "!g[GG][Level-Menu] !nYou will receive a !tFlashBang !nevery !t30 seconds !n!");
			}
		}
		case 2:
		{
			if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
			{
				Nade[id] = 3;
				set_task(40.0, "Give_FrostNade", id);
				ChatColor(id, "!g[GG][Level-Menu] !nYou will receive a !tFrostNade !nevery !t40 seconds !n!");
			}
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Give_FireNade(id)
{
	if(Nade[id] == 1)
	{
		if(is_user_alive(id) && !user_has_weapon(id, CSW_HEGRENADE))
		{
			give_item(id, "weapon_hegrenade");
			ChatColor(id, "!g[GG][Level-Menu] !nYou Get a !tFireNade !nEvery !t20 seconds !n!");
		}
		set_task(20.0, "Give_FireNade", id);
	}
}

public Give_FlashBang(id)
{
	if(Nade[id] == 2)
	{
		if(is_user_alive(id) && !user_has_weapon(id, CSW_FLASHBANG))
		{
			give_item(id, "weapon_flashbang");
			ChatColor(id, "!g[GG][Level-Menu] !nYou Get a !tFireNade !nEvery !t30 seconds !n!");
		}
		set_task(30.0, "Give_FlashBang", id);
	}
}

public Give_FrostNade(id)
{
	if(Nade[id] == 3)
	{
		if(is_user_alive(id) && !user_has_weapon(id, CSW_SMOKEGRENADE) && cs_get_user_team(id) == CS_TEAM_CT)
		{
			give_item(id, "weapon_smokegrenade");
			ChatColor(id, "!g[GG][Level-Menu] !nYou Get a !tFireNade !nEvery !t40 seconds !n!");
		}
		set_task(40.0, "Give_FrostNade", id);
	}
}

public CurWeapon(id)
{
	/*
	if( get_level(id) >= 40 || get_user_flags(id) & OWNER_LEVEL )
	{
		if(!Nade_Cooldown[id] && (Nade[id] == 1 || Nade[id] == 2 || Nade[id] == 3))
		{
			if(!user_has_weapon(id, CSW_HEGRENADE) || !user_has_weapon(id, CSW_FLASHBANG) || !user_has_weapon(id, CSW_SMOKEGRENADE))
			{
				Nade_Cooldown[id] = 20;
				set_task(1.0, "CoolDown", id, _, _, "b");
			}
		}
	}
	*/
	if( get_level(id) >= 135 || get_user_flags(id) & OWNER_LEVEL )
	{
		if( cs_get_user_team(id) == CS_TEAM_CT )
		{
			if(assassin_mod(id) || sniper_mod(id) || ghost_mod(id) || csdm_mod(id))
				return;
			/*
			if(gg_has_user_buffawp(id))
				return;
			*/
			static name[32]; get_user_name(id, name, charsmax(name) - 1);
			if(WhiteListed(name))
				return;
				
			if(have_unlimited_ammo[id] >= 4)
			{
				new iWeapon = read_data(2)
				if( !( NOCLIP_WPN_BS & (1<<iWeapon) ) )
				{
					fm_cs_set_weapon_ammo( get_pdata_cbase(id, m_pActiveItem) , g_MaxClipAmmo[ iWeapon ] )
				}
			}
		}
	}
}
/*
public CoolDown(id)
{
	if(!is_user_alive(id) || user_has_weapon(id, CSW_HEGRENADE) || user_has_weapon(id, CSW_FLASHBANG) || user_has_weapon(id, CSW_SMOKEGRENADE) || Nade[id] == 0)
	{
		remove_task(id);
		Nade_Cooldown[id] = 0;
		return PLUGIN_HANDLED;
	}

	if(is_user_alive(id) && Nade_Cooldown[id] > 0)
	{
		Nade_Cooldown[id] --;
	}

	if(Nade_Cooldown[id] <= 0)
	{
		remove_task(id);
		Nade_Cooldown[id] = 0;

		if( Nade[id] == 1 )
			give_item(id, "weapon_hegrenade");

		if( Nade[id] == 2 )
			give_item(id, "weapon_flashbang");

		if( Nade[id] == 3 )
		{
			if( cs_get_user_team(id) == CS_TEAM_CT )
				give_item(id, "weapon_smokegrenade");
		}
	}
	return PLUGIN_HANDLED;
}
*/
public Transfer(id)
{
	if(TeamChanged[id])
		return PLUGIN_HANDLED;

	if( get_user_flags(id) & OWNER_LEVEL )
		TransferMenu(id);
	else
	{
		if( modstarted(id) ) ChatColor(id, "!g[GG][TRANSFER] !nYou can't Open This Menu in The Current !tMod !n!");
		else TransferMenu(id);
	}

	return PLUGIN_HANDLED;
}

public TransferMenu(id)
{
	if( !(get_user_flags(id) & OWNER_LEVEL) && modstarted(id) )
		return PLUGIN_HANDLED;

	new TransferPlayer = menu_create ("\d[\yGeek~Gamers\d] \rBecome \yFurien \w/ \yAnti-Furien:", "HandleTransfer");

	new num, players[32], tempid, szTempID [10], tempname [32], szName [32], textmenu [64];

	get_players (players, num, "c");
	for (new i = 0; i < num; i++)
	{
		tempid = players[ i ];

		get_user_name(tempid, tempname, 31);
		get_user_name(tempid, szName, charsmax(szName));

		num_to_str(tempid, szTempID, 9);

		if( tempid != id )
			continue;

		if(cs_get_user_team(tempid) == CS_TEAM_T)
        		formatex(textmenu, 63, "%s \d- \r[Furien]", szName);
		else
		if(cs_get_user_team(tempid) == CS_TEAM_CT)
    	    		formatex(textmenu, 63, "%s \d- \y[Anti-Furien]", szName);
		else
		if(cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
			formatex(textmenu, 63, "%s \d- [SPECTATOR]", szName);

		menu_additem(TransferPlayer, textmenu, szTempID, 0);
	}

	menu_display (id, TransferPlayer);
	return PLUGIN_HANDLED;
}

public HandleTransfer(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	if( !(get_user_flags(id) & OWNER_LEVEL) && modstarted(id) )
		return PLUGIN_HANDLED;

	new data[6], name[64];
	new access, callback;
	
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback);
	new tempid = str_to_num(data);

	if(cs_get_user_team(tempid) == CS_TEAM_CT || cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
		cs_set_user_team(tempid, CS_TEAM_T);
	else
	if(cs_get_user_team(tempid) == CS_TEAM_T)
		cs_set_user_team(tempid, CS_TEAM_CT);

	if(is_user_alive(tempid))
		spawn_func(tempid);

	tchanged[tempid] ++;
	TeamChanged[id] = true;

	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public spawn_func(id) 
{
	ExecuteHamB(Ham_CS_RoundRespawn, id);

	if(cs_get_user_team(id) == CS_TEAM_CT)
		client_cmd(id, "weapons");
	else if(cs_get_user_team(id) == CS_TEAM_T)
		client_cmd(id, "knife");
}

public removeGodmode(id)
{
	fm_set_user_godmode(id, 0);
	ChatColor(id, "!g[GG][Level-Menu] !nYour !tGodmode !nhas expired.");
}

public Player_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if( iInflictor == iAttacker && is_user_alive( iAttacker ) && is_user_alive( iVictim ) && ((black_furien(iAttacker) && cs_get_user_team(iAttacker) == CS_TEAM_T) || (black_human(iAttacker) && cs_get_user_team(iAttacker) == CS_TEAM_CT)) )
	{
		if(fDamage > 0) SetHamParamFloat(4, fDamage + add_damage[iAttacker]);
	}
}

public BuyVIPWeaponsMenu(id)
{
	new iCredits = fcs_get_user_credits(id) - get_pcvar_num(vipweapons_cost);
	if( iCredits < 0 )
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
		LevelMenu(id);

		return PLUGIN_HANDLED;
	}

	new temp[101];

	formatex( temp, 100, "\wYou will spend\y %d Credits \wto buy \rV.I.P Weapons/Knives \wfor \r1 month\w.^nDo you accept ?", get_pcvar_num(vipweapons_cost) );
	new menu = menu_create(temp, "BuyVIPWeaponsMenuHandler");

	menu_additem(menu, "Yes", "", 0);
	menu_additem(menu, "No", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuyVIPWeaponsMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			BuyVIPWeapons(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public BuyVIPWeapons(id)
{
	CheckPlayerAccess(id, VIPWEAPONS_FLAGS);

	if(has_higher_access[id])
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou already have a !tHigher Access !nin the server.");
		return;
	}

	new name[32];
	get_user_name(id, name, 31);
	
	new configdir[200], holder[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/auto-admins.ini", configdir);
	
	if(file_exists(configdir))
	{
		new exp_day, exp_month, exp_year;
		if(has_access[id])
		{
			exp_day = expir_day[id];
			exp_month = expir_month[id];
			exp_year = expir_year[id];
		}
		else
		{
			new Year[32], Month[32], Day[32];
			get_time("%Y", Year, 31);
			get_time("%m", Month, 31);
			get_time("%d", Day, 31);
			
			exp_day = str_to_num(Day);
			exp_month = str_to_num(Month);
			exp_year = str_to_num(Year);
		}

		if(exp_month+1 > 12)
		{
			exp_month -= 11;
			exp_year ++;
		}
		else exp_month ++;

		new line = 0, linetext[255], linetextlength;
		while((line = read_file(configdir, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, name) || !equali(p_access, VIPWEAPONS_FLAGS) )
				continue;
			
			formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIPWEAPONS_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext, line - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(VIPWEAPONS_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vipweapons_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your access to !tV.I.P Weapons/Knives !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought access to !tV.I.P Weapons/Knives !nfor !g1 MONTH!n.");

			return;
		}

		new line2 = 0, linetext2[255], linetextlength2;
		while((line2 = read_file(configdir, line2, linetext2, 256, linetextlength2)))
		{
			if(linetext2[0] == ';' || (linetext2[0] == '/' && linetext2[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext2, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, "") || !equali(p_access, VIPWEAPONS_FLAGS) )
				continue;

			formatex(linetext2, charsmax(linetext2), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIPWEAPONS_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext2, line2 - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(VIPWEAPONS_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vipweapons_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your access to !tV.I.P Weapons/Knives !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought access to !tV.I.P Weapons/Knives !nfor !g1 MONTH!n.");

			return;
		}

		formatex(holder, charsmax(holder), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIPWEAPONS_FLAGS, exp_day, exp_month, exp_year);
		write_file(configdir, holder, -1);

		remove_user_flags(id, read_flags("z"));
		set_user_flags(id, read_flags(VIPWEAPONS_FLAGS));
		fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vipweapons_cost) );

		if(has_access[id])
			ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your access to !tV.I.P Weapons/Knives !nfor !gANOTHER MONTH!n.");
		else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought access to !tV.I.P Weapons/Knives !nfor !g1 MONTH!n.");
	}
}

public BuyVIPMenu(id)
{
	new iCredits = fcs_get_user_credits(id) - get_pcvar_num(vip_cost);
	if( iCredits < 0 )
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
		LevelMenu(id);

		return PLUGIN_HANDLED;
	}

	new temp[101];

	formatex( temp, 100, "\wYou will spend\y %d Credits \wto buy a \rV.I.P \wfor \r1 month\w.^nDo you accept ?", get_pcvar_num(vip_cost) );
	new menu = menu_create(temp, "BuyVIPMenuHandler");

	menu_additem(menu, "Yes", "", 0);
	menu_additem(menu, "No", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuyVIPMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			BuyVIP(id);
		}

	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public BuyVIP(id)
{
	CheckPlayerAccess(id, VIP_FLAGS);

	if(has_higher_access[id])
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou already have a !tHigher Access !nin the server.");
		return;
	}

	new name[32];
	get_user_name(id, name, 31);
	
	new configdir[200], holder[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/auto-admins.ini", configdir);
	
	if(file_exists(configdir))
	{
		new exp_day, exp_month, exp_year;
		if(has_access[id])
		{
			exp_day = expir_day[id];
			exp_month = expir_month[id];
			exp_year = expir_year[id];
		}
		else
		{
			new Year[32], Month[32], Day[32];
			get_time("%Y", Year, 31);
			get_time("%m", Month, 31);
			get_time("%d", Day, 31);
			
			exp_day = str_to_num(Day);
			exp_month = str_to_num(Month);
			exp_year = str_to_num(Year);
		}

		if(exp_month+1 > 12)
		{
			exp_month -= 11;
			exp_year ++;
		}
		else exp_month ++;

		new line = 0, linetext[255], linetextlength;
		while((line = read_file(configdir, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, name) || !equali(p_access, VIP_FLAGS) )
				continue;
			
			formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext, line - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(VIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tV.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tV.I.P Access !nfor !g1 MONTH!n.");

			return;
		}

		new line2 = 0, linetext2[255], linetextlength2;
		while((line2 = read_file(configdir, line2, linetext2, 256, linetextlength2)))
		{
			if(linetext2[0] == ';' || (linetext2[0] == '/' && linetext2[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext2, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, "") || !equali(p_access, VIP_FLAGS) )
				continue;

			formatex(linetext2, charsmax(linetext2), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext2, line2 - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(VIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tV.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tV.I.P Access !nfor !g1 MONTH!n.");

			return;
		}

		formatex(holder, charsmax(holder), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, VIP_FLAGS, exp_day, exp_month, exp_year);
		write_file(configdir, holder, -1);

		remove_user_flags(id, read_flags("z"));
		set_user_flags(id, read_flags(VIP_FLAGS));
		fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(vip_cost) );

		if(has_access[id])
			ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tV.I.P Access !nfor !gANOTHER MONTH!n.");
		else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tV.I.P Access !nfor !g1 MONTH!n.");
	}
}

public BuySilverVIPMenu(id)
{
	new iCredits = fcs_get_user_credits(id) - get_pcvar_num(silver_vip_cost);
	if( iCredits < 0 )
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
		LevelMenu(id);

		return PLUGIN_HANDLED;
	}

	new temp[101];

	formatex( temp, 100, "\wYou will spend\y %d Credits \wto buy a \rSilver V.I.P \wfor \r1 month\w.^nDo you accept ?", get_pcvar_num(silver_vip_cost) );
	new menu = menu_create(temp, "BuySilverVIPMenuHandler");

	menu_additem(menu, "Yes", "", 0);
	menu_additem(menu, "No", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuySilverVIPMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			BuySilverVIP(id);
		}

	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public BuySilverVIP(id)
{
	CheckPlayerAccess(id, SILVERVIP_FLAGS);

	if(has_higher_access[id])
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou already have a !tHigher Access !nin the server.");
		return;
	}

	new name[32];
	get_user_name(id, name, 31);
	
	new configdir[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/auto-admins.ini", configdir);
	
	if(file_exists(configdir))
	{
		new exp_day, exp_month, exp_year;
		if(has_access[id])
		{
			exp_day = expir_day[id];
			exp_month = expir_month[id];
			exp_year = expir_year[id];
		}
		else
		{
			new Year[32], Month[32], Day[32];
			get_time("%Y", Year, 31);
			get_time("%m", Month, 31);
			get_time("%d", Day, 31);
			
			exp_day = str_to_num(Day);
			exp_month = str_to_num(Month);
			exp_year = str_to_num(Year);
		}

		if(exp_month+1 > 12)
		{
			exp_month -= 11;
			exp_year ++;
		}
		else exp_month ++;

		new line = 0, linetext[255], linetextlength;
		while((line = read_file(configdir, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, name) || !equali(p_access, SILVERVIP_FLAGS) )
				continue;
			
			formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, SILVERVIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext, line - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(SILVERVIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(silver_vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tSilver V.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tSilver V.I.P Access !nfor !g1 MONTH!n.");

			return;
		}

		new line2 = 0, linetext2[255], linetextlength2;
		while((line2 = read_file(configdir, line2, linetext2, 256, linetextlength2)))
		{
			if(linetext2[0] == ';' || (linetext2[0] == '/' && linetext2[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext2, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, "") || !equali(p_access, SILVERVIP_FLAGS) )
				continue;

			formatex(linetext2, charsmax(linetext2), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, SILVERVIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext2, line2 - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(SILVERVIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(silver_vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tSilver V.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tSilver V.I.P Access !nfor !g1 MONTH!n.");

			return;
		}
		
		ChatColor(id, "!g[GG][Level-Menu] !nUnfortunately, the server have reached the maximum !tSilver V.I.P !nadmins!n.");
	}
}

public BuyGoldVIPMenu(id)
{
	new iCredits = fcs_get_user_credits(id) - get_pcvar_num(gold_vip_cost);
	if( iCredits < 0 )
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou don't Have enough !tCredits.");
		LevelMenu(id);

		return PLUGIN_HANDLED;
	}

	new temp[101];

	formatex( temp, 100, "\wYou will spend\y %d Credits \wto buy a \rGold V.I.P \wfor \r1 month\w.^nDo you accept ?", get_pcvar_num(gold_vip_cost) );
	new menu = menu_create(temp, "BuyGoldVIPMenuHandler");

	menu_additem(menu, "Yes", "", 0);
	menu_additem(menu, "No", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuyGoldVIPMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			BuyGoldVIP(id);
		}

	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public BuyGoldVIP(id)
{
	CheckPlayerAccess(id, GOLDVIP_FLAGS);

	if(has_higher_access[id])
	{
		ChatColor(id, "!g[GG][Level-Menu] !nYou already have a !tHigher Access !nin the server.");
		return;
	}

	new name[32];
	get_user_name(id, name, 31);
	
	new configdir[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/auto-admins.ini", configdir);
	
	if(file_exists(configdir))
	{
		new exp_day, exp_month, exp_year;
		if(has_access[id])
		{
			exp_day = expir_day[id];
			exp_month = expir_month[id];
			exp_year = expir_year[id];
		}
		else
		{
			new Year[32], Month[32], Day[32];
			get_time("%Y", Year, 31);
			get_time("%m", Month, 31);
			get_time("%d", Day, 31);
			
			exp_day = str_to_num(Day);
			exp_month = str_to_num(Month);
			exp_year = str_to_num(Year);
		}

		if(exp_month+1 > 12)
		{
			exp_month -= 11;
			exp_year ++;
		}
		else exp_month ++;

		new line = 0, linetext[255], linetextlength;
		while((line = read_file(configdir, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, name) || !equali(p_access, GOLDVIP_FLAGS) )
				continue;
			
			formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, GOLDVIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext, line - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(GOLDVIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(silver_vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tGold V.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tGold V.I.P Access !nfor !g1 MONTH!n.");

			return;
		}

		new line2 = 0, linetext2[255], linetextlength2;
		while((line2 = read_file(configdir, line2, linetext2, 256, linetextlength2)))
		{
			if(linetext2[0] == ';' || (linetext2[0] == '/' && linetext2[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext2, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( !equali(p_login, "") || !equali(p_access, GOLDVIP_FLAGS) )
				continue;

			formatex(linetext2, charsmax(linetext2), "^"%s^" ^"^" ^"%s^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, GOLDVIP_FLAGS, exp_day, exp_month, exp_year);
			write_file(configdir, linetext2, line2 - 1);

			remove_user_flags(id, read_flags("z"));
			set_user_flags(id, read_flags(GOLDVIP_FLAGS));
			fcs_set_user_credits( id, fcs_get_user_credits(id) - get_pcvar_num(silver_vip_cost) );

			if(has_access[id])
				ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully extended your !tGold V.I.P Access !nfor !gANOTHER MONTH!n.");
			else ChatColor(id, "!g[GG][Level-Menu] !nYou have successfully bought !tGold V.I.P Access !nfor !g1 MONTH!n.");

			return;
		}
		
		ChatColor(id, "!g[GG][Level-Menu] !nUnfortunately, the server have reached the maximum !tGold V.I.P !nadmins!n.");
	}
}

public CheckPlayerAccess(id, access[])
{
	has_higher_access[id] = false;
	has_access[id] = false;

	new name[32];
	get_user_name(id, name, 31);
	
	new configdir[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/users.ini", configdir);
	
	if(file_exists(configdir))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				has_higher_access[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;
			
			has_access[id] = true;

			if(equal(p_year, ""))
			{
				new Years[32];
				get_time("%Y", Years, 31);

				p_year = Years;
			}

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	
	new configdir2[200];
	get_configsdir(configdir2, 199);
	format(configdir2, 199, "%s/manager/users.ini", configdir2);
	
	if(file_exists(configdir2))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir2, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				has_higher_access[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;

			has_access[id] = true;

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	
	new configdir3[200];
	get_configsdir(configdir3, 199);
	format(configdir3, 199, "%s/auto-admins.ini", configdir3);
	
	if(file_exists(configdir3))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir3, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				has_higher_access[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;

			has_access[id] = true;

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	return PLUGIN_CONTINUE;
}

public native_addmoney(id)
{
	return add_money[id];
}

public native_addhp(id)
{
	return add_hp[id];
}

public native_adddamage(id)
{
	return add_damage[id];
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!t2", "^0");
	
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}

///** ----------------------------------------- [ Plugin By ~D4rkSiD3Rs~ ] ------------------------------------------------ **///