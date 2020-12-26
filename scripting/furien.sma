/*	Formatright � 2009, ConnorMcLeod

	Furiens is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Furiens; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#include "furien.inc"

#define MAX_PLAYERS 32

#define Ham_Player_ResetMaxSpeed Ham_Item_PreFrame

native furien_visible(id);

new g_iMaxPlayers
#define FIRST_PLAYER_ID	1
#define IsPlayer(%1)	( FIRST_PLAYER_ID <= %1 <= g_iMaxPlayers )

new CsTeams:g_iFuriensTeam = CS_TEAM_T

// players offsets
#define XTRA_OFS_PLAYER 5
#define m_iAccount 115
#define cs_set_money_value(%1,%2)	set_pdata_int(%1, m_iAccount, %2, XTRA_OFS_PLAYER)

// "weaponbox" offsets
#define XO_WEAPONBOX				4
#define m_rgpPlayerItems_wpnbx_Slot5	39
#define IsWeaponBoxC4(%1)	( get_pdata_cbase(%1, m_rgpPlayerItems_wpnbx_Slot5, XO_WEAPONBOX) > 0 )

new g_bShouldAnswerMenu, g_bCanModifyCvars
#define MarkUserSeeMenu(%1)	g_bShouldAnswerMenu |= 1<<(%1&31)
#define ClearUserSeeMenu(%1)	g_bShouldAnswerMenu &= ~(1<<(%1&31))
#define ShouldUserSeeMenu(%1)	g_bShouldAnswerMenu & 1<<(%1&31)

#define MarkUserCvars(%1)	g_bCanModifyCvars |= 1<<(%1&31)
#define ClearUserCvars(%1)	g_bCanModifyCvars &= ~(1<<(%1&31))
#define CanUserCvars(%1)		g_bCanModifyCvars & 1<<(%1&31)

const CVARS_MENU_KEYS = (1<<0)|(1<<1)

new g_iFurienTeamChangeForward

new g_iFurienRoundRestartForward, bool:g_bRestarting

new Float:g_flFurienGravity = 0.375
new g_iInvisFactor = 1
new Float:g_flMaxSpeed = 500.0
new g_iFurienReward = 1337
new g_iAntiReward = 400
new g_iAnnounce = 1

new bool:g_bSwitchTeam = true
new bool:g_bSwitchInProgress

new Trie:g_tPreventEntityKeyvalue
new g_iPickUp = 2

new g_szSpeedCommand[128]

new g_szFurienWinSound[64]
new g_szAntiWinSound[64]

new g_szGameDescription[32]

new g_bitBombPlant

new g_iNewMoney
new g_iMsgHookMoney

new g_iTextMsg, g_iMoney

new HamHook:g_iHhTakeDamage

public plugin_natives()
{
	register_library("furien")
	register_native("furien_get_user_team", "fr_get_user_team")
}

public plugin_precache()
{
	if( !ReadCfgFile() )
	{
		log_amx("Configuration file doesn't exist !!")
	}
}

public plugin_init()
{
	register_plugin("Furiens", FURIEN_VERSION, "ConnorMcLeod")

	register_dictionary("common.txt")
	register_dictionary("furiens.txt")

	new pCvar = register_cvar("furien_version", FURIEN_VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	set_pcvar_string(pCvar, FURIEN_VERSION)

	register_clcmd("say ?", "A_Propos")
	register_clcmd("say_team ?", "A_Propos")
	register_clcmd("?", "A_Propos")	

	register_menucmd(register_menuid("Furiens Cvars"), CVARS_MENU_KEYS, "CvarsMenuCallBack")

	RegisterHam(Ham_Spawn, "player", "Player_Spawn_Post", 1)
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "Player_ResetMaxSpeed", 1)

	register_message(get_user_msgid("SendAudio"), "Message_SendAudio")

	new iEnt
	iEnt = create_entity("info_target")
	set_pev(iEnt, pev_classname, "check_speed")
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	register_think("check_speed", "Set_Furiens_Visibility")

	iEnt = create_entity("info_target")
	set_pev(iEnt, pev_classname, "check_cvars")
	set_pev(iEnt, pev_nextthink, get_gametime() + 10.0)
	register_think("check_cvars", "Check_Players_Cvars")

	g_iFurienTeamChangeForward = CreateMultiForward("furien_team_change", ET_IGNORE, FP_CELL)

	register_event("TextMsg", "Event_TextMsg_Restart", "a", "2&#Game_C", "2&#Game_w")
	register_event("HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0")
	g_iFurienRoundRestartForward = CreateMultiForward("furien_round_restart", ET_IGNORE)

	register_event("DeathMsg", "Event_DeathMsg", "a")

	if( get_cvar_float("sv_maxspeed") < g_flMaxSpeed )
	{
		set_cvar_float("sv_maxspeed", g_flMaxSpeed)
	}

	formatex(g_szSpeedCommand, charsmax(g_szSpeedCommand), 
			";cl_forwardspeed %.1f;cl_sidespeed %.1f;cl_backspeed %.1f",
							g_flMaxSpeed, g_flMaxSpeed, g_flMaxSpeed)

	g_iMaxPlayers = get_maxplayers()
	g_iTextMsg = get_user_msgid("TextMsg")
	g_iMoney = get_user_msgid("Money")
}

ReadCfgFile()
{
	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/furien.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return 0
	}

	new szDatas[96], szKey[32], szValue[64]
	while( !feof(fp) )
	{
		fgets(fp, szDatas, charsmax(szDatas))
		trim(szDatas)
		if(!szDatas[0] || szDatas[0] == ';' || szDatas[0] == '#' || (szDatas[0] == '/' && szDatas[1] == '/'))
		{
			continue
		}

		if( parse(szDatas, szKey, charsmax(szKey), szValue, charsmax(szValue)) < 2 || szValue[0] == 0 )
		{
			continue
		}

		switch( szKey[0] )
		{
			case 'B':
			{
				switch( szKey[1] )
				{
					case 'U':
					{
						if( equal(szKey, "BUY") )
						{
							switch( clamp(str_to_num(szValue), 0, 1) )
							{
								case 0:
								{
									new iEnt

									g_tPreventEntityKeyvalue = TrieCreate()
									TrieSetCell(g_tPreventEntityKeyvalue, "player_weaponstrip", 1)
									TrieSetCell(g_tPreventEntityKeyvalue, "game_player_equip", 1)
									TrieSetCell(g_tPreventEntityKeyvalue, "info_map_parameters", 1)

									iEnt = create_entity("info_map_parameters")
									DispatchKeyValue(iEnt, "buying", "3")
									DispatchSpawn(iEnt)

									register_buy_cmd()
								}
							}
						}
					}
					case 'O':
					{
						if( equal(szKey, "BOMB_PLANT") )
						{
							g_bitBombPlant = clamp(str_to_num(szValue), 0, 3)
							if( g_bitBombPlant != 3 )
							{
								RegisterHam(Ham_AddPlayerItem, "player", "Player_AddPlayerItem")
							}
						}
					}
				}
			}
			case 'F':
			{
				if( equal(szKey, "FURIEN_ANNOUNCE") )
				{
					g_iAnnounce = str_to_num(szValue)
				}
			}
			case 'G':
			{
				switch( szKey[1] )
				{
					case 'A':
					{
						if( equal(szKey, "GAMENAME") )
						{
							replace(szValue, charsmax(szValue), "%v", FURIEN_VERSION)
							copy(g_szGameDescription, charsmax(g_szGameDescription), szValue)
							register_forward(FM_GetGameDescription, "GetGameDescription")
						}
					}
					case 'R':
					{
						if( equal(szKey, "GRAVITY") )
						{
							g_flFurienGravity = floatclamp(str_to_float(szValue), 0.0125, 1.0)
						}
					}
				}
			}
			case 'H':
			{
				if( equal(szKey, "HOSTAGE_REMOVE") && str_to_num(szValue) )
				{
					RegisterHam(Ham_Spawn, "hostage_entity", "Hostage_Spawn")
				}
			}
			case 'I':
			{
				if( equal(szKey, "INVIS_FACTOR") )
				{
					g_iInvisFactor = clamp(str_to_num(szValue), 1, 4)
				}
			}
			case 'K':
			{
				switch( szKey[5] )
				{
					case 'A':
					{
						if( equal(szKey, "KILL_ANTI_REWARD") )
						{
							g_iAntiReward = str_to_num(szValue)
						}
					}
					case 'F':
					{
						if( equal(szKey, "KILL_FURIEN_REWARD") )
						{
							g_iFurienReward = str_to_num(szValue)
						}
					}
				}
			}
			case 'M':
			{
				if( equal(szKey, "MAXSPEED") )
				{
					g_flMaxSpeed = floatclamp(str_to_float(szValue), 100.0, 2000.0)
				}
			}
			case 'P':
			{
				if( equal(szKey, "PICK_UP") )
				{
					g_iPickUp = clamp(str_to_num(szValue), 0, 3)
					switch( g_iPickUp )
					{
						case 0,1,2:
						{
							RegisterHam(Ham_Touch, "weaponbox", "CWeaponBox_Touch")
							RegisterHam(Ham_Touch, "armoury_entity", "GroundWeapon_Touch")
							RegisterHam(Ham_Touch, "weapon_shield", "GroundWeapon_Touch")
						}
					}
				}
			}
			case 'S':
			{
				if( equal(szKey, "SWITCH_TEAMS") )
				{
					g_bSwitchTeam = !!clamp(str_to_num(szValue), 0, 1)
					if( g_bSwitchTeam )
					{
						g_iHhTakeDamage = RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage")
						DisableHamForward( g_iHhTakeDamage )
					}
				}
			}
			case 'W':
			{
				if( equal(szKey, "WIN_SOUND_", 10) )
				{
					new szFullPath[128]
					switch(szKey[10])
					{
						case 'F':
						{
							formatex(szFullPath, charsmax(szFullPath), "sound/%s", szValue)
							if( file_exists(szFullPath) )
							{
								copy(g_szFurienWinSound, charsmax(g_szFurienWinSound), szValue)
								precache_sound(szValue)
							}
						}
						case 'A':
						{
							formatex(szFullPath, charsmax(szFullPath), "sound/%s", szValue)
							if( file_exists(szFullPath) )
							{
								copy(g_szAntiWinSound, charsmax(g_szAntiWinSound), szValue)
								precache_sound(szValue)
							}
						}
					}
				}
			}
		}
	}
	fclose( fp )

	return 1
}

public GetGameDescription()
{
	forward_return(FMV_STRING, g_szGameDescription)
	return FMRES_SUPERCEDE
}

public Event_TextMsg_Restart()
{
	g_bRestarting = true
}

public Event_HLTV_New_Round()
{
	if( g_bRestarting )
	{
		g_bRestarting = false
		new iRet
		ExecuteForward(g_iFurienRoundRestartForward, iRet)
	}

	if( g_bSwitchInProgress )
	{
		g_bSwitchInProgress = false
		DisableHamForward( g_iHhTakeDamage )
	}
}

public GroundWeapon_Touch(iWeapon, id)
{
	if( IsPlayer(id) )
	{
		if( !g_iPickUp )
		{
			remove_entity(iWeapon)
			return HAM_SUPERCEDE
		}

		if( !is_user_alive(id) )
		{
			return HAM_SUPERCEDE
		}

		new iTeam = __get_user_team(id)
		if(	( iTeam == -1 )
		||	(iTeam == Furien && g_iPickUp != 1)
		||	(iTeam == AntiFurien && g_iPickUp != 2)	)
		{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public CWeaponBox_Touch(iWeaponBox, id)
{
	if( IsPlayer(id) )
	{
		if( !is_user_alive(id) )
		{
			return HAM_SUPERCEDE
		}

		if( IsWeaponBoxC4(iWeaponBox) )
		{
			return HAM_IGNORED
		}

		if( !g_iPickUp )
		{
			remove_entity(iWeaponBox)
			return HAM_SUPERCEDE
		}

		new iTeam = __get_user_team(id)
		if(	( iTeam == -1 )
		||	(iTeam == Furien && g_iPickUp != 1)
		||	(iTeam == AntiFurien && g_iPickUp != 2)	)
		{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

register_buy_cmd()
{
	register_clcmd("buy", "ClientCommand_Buy")
	register_clcmd("bUy", "ClientCommand_Buy")
	register_clcmd("buY", "ClientCommand_Buy")
	register_clcmd("bUY", "ClientCommand_Buy")
	register_clcmd("Buy", "ClientCommand_Buy")
	register_clcmd("BUy", "ClientCommand_Buy")
	register_clcmd("BuY", "ClientCommand_Buy")
	register_clcmd("BUY", "ClientCommand_Buy")
}

public ClientCommand_Buy(id)
{
	return PLUGIN_HANDLED_MAIN
}

public pfn_keyvalue( iEnt ) 
{
	if( g_tPreventEntityKeyvalue )
	{
		new szClassName[32], szCrap[2]
		copy_keyvalue(szClassName, charsmax(szClassName), szCrap, charsmax(szCrap), szCrap, charsmax(szCrap)) 
		if( TrieKeyExists(g_tPreventEntityKeyvalue, szClassName) )
		{
			remove_entity(iEnt)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public plugin_cfg()
{
	if( g_tPreventEntityKeyvalue )
	{
		TrieDestroy(g_tPreventEntityKeyvalue)
		set_cvar_float("sv_restart", 1.0)
	}
}

public fr_get_user_team(/*iPlugin, iParams*/)
{
	return __get_user_team( get_param(1) )
}

__get_user_team(id)
{
	new CsTeams:iTeam = cs_get_user_team(id)
	if( CS_TEAM_T <= iTeam <= CS_TEAM_CT )
	{
		if( iTeam == g_iFuriensTeam )
		{
			return Furien
		}
		return AntiFurien
	}
	return -1
}

public client_connect(id)
{
	// credit : http://forums.alliedmods.net/showthread.php?p=752203
	if( !is_user_bot(id) )
	{
		query_client_cvar(id, "gl_clear", "Client_Cvar_Result")
	}
}

public Client_Cvar_Result(id, const szCvar[], const szValue[])
{
	if( szValue[0] == 'B' )
	{
		server_cmd("kick #%d Software video mode forbidden !! Acceleration logicielle interdite !!", get_user_userid(id))
	}
}

public client_putinserver( id )
{
	MarkUserSeeMenu( id )
	ClearUserCvars( id )

	if( g_iAnnounce )
	{
		set_task(random_float(11.0, 19.0), "A_Propos", id)
	}
}

public Player_Spawn_Post( id )
{
	if( is_user_alive(id) )
	{
		if( ShouldUserSeeMenu(id) )
		{
			ShowSpeedCvarsMenu(id)
		}

		strip_user_weapons(id)

		if( __get_user_team(id) == Furien )
		{
			set_user_gravity(id, g_flFurienGravity)
			set_user_footsteps(id, 1)
		}
		else
		{
			set_user_footsteps(id, 0)
			set_user_gravity(id, 1.0)
		}

		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
	}
}

ShowSpeedCvarsMenu(id)
{
	new szMenu[256], n
	n += formatex(szMenu[n], charsmax(szMenu)-n, "%L^n", id, "FURIEN_MENU_CVAR")
	n += formatex(szMenu[n], charsmax(szMenu)-n, "^n\y1\w. %L", id, "YES")
	n += formatex(szMenu[n], charsmax(szMenu)-n, "^n\y2\w. %L", id, "NO")

	show_menu(id, CVARS_MENU_KEYS, szMenu, -1, "Furiens Cvars")
}

public CvarsMenuCallBack(id, iKey)
{
	switch( iKey )
	{
		case 0:
		{
			MarkUserCvars( id )
			ClearUserSeeMenu( id )
		}
		case 1:
		{
			ClearUserCvars( id )
		}
	}
	return PLUGIN_HANDLED
}

public Player_ResetMaxSpeed( id )
{
	if( is_user_alive(id) && __get_user_team(id) == Furien && get_user_maxspeed(id) != 1.0 )
	{
		set_pev(id, pev_maxspeed, g_flMaxSpeed)
	}
}

public Check_Players_Cvars( iEnt )
{
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 5.0)

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players(iPlayers, iNum, "ace", g_iFuriensTeam == CS_TEAM_T ? "TERRORIST" : "CT")
	for(new i; i<iNum; i++)
	{
		id = iPlayers[i]
		if( CanUserCvars( id ) )
		{
			query_client_cvar(id, "cl_forwardspeed", "CvarResult")
			query_client_cvar(id, "cl_backspeed", "CvarResult")
			query_client_cvar(id, "cl_sidespeed", "CvarResult")
		}
	}
}

public CvarResult(const id, const szCvar[], const szValue[])
{
	if( CanUserCvars( id ) && is_user_connected(id) && str_to_float(szValue) < g_flMaxSpeed )
	{
		client_cmd(id, g_szSpeedCommand)
	}
}

public Set_Furiens_Visibility( iEnt )
{
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

	new iPlayers[MAX_PLAYERS], iNum, id, Float:fVecVelocity[3], iSpeed

	get_players(iPlayers, iNum, "ae", g_iFuriensTeam == CS_TEAM_T ? "TERRORIST" : "CT")

	for(new i; i<iNum; i++)
	{
		id = iPlayers[i]
		if( get_user_weapon(id) == CSW_KNIFE )
		{
			entity_get_vector(id, EV_VEC_velocity, fVecVelocity)
			iSpeed = floatround( vector_length(fVecVelocity) )
			if( iSpeed < g_iInvisFactor*255 )
			{
				if( furien_visible(id) )
					set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
				else set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, iSpeed/g_iInvisFactor)
			}
			else
			{
				set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
			}
		}
		else
		{
			set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
		}
	}
}

public Message_SendAudio(iMsgId, iMsgDest, id)
{
	if( !id )
	{
		new bool:bAntiWins
		new bool:bSwitchTeams
		new szSound[14]
		get_msg_arg_string(2, szSound, charsmax(szSound))
		if( equal(szSound, "%!MRAD_ctwin") )
		{
			if( g_iFuriensTeam == CS_TEAM_T )
			{
				if( g_bSwitchTeam )
				{
					bSwitchTeams = true
					g_iFuriensTeam = CS_TEAM_CT
				}
				bAntiWins = true
			}
		}
		else if( equal(szSound, "%!MRAD_terwin") )
		{
			if( g_iFuriensTeam == CS_TEAM_CT )
			{
				if( g_bSwitchTeam )
				{
					bSwitchTeams = true
					g_iFuriensTeam = CS_TEAM_T
				}
				bAntiWins = true
			}
		}
		else
		{
			return
		}

		if( get_msg_block(g_iTextMsg) == BLOCK_NOT )
		{
			set_msg_block(g_iTextMsg, BLOCK_ONCE)
		}

		new iPlayers[32], iNum, iPlayer
		get_players(iPlayers, iNum)
		for(new i; i<iNum; i++)
		{
			iPlayer = iPlayers[i]
			client_print(iPlayer, print_center, "%L", iPlayer, bAntiWins ? "FURIEN_ANTI_WIN_MSG" : "FURIEN_FURIEN_WIN_MSG")
		}

		if( bAntiWins )
		{
			if( g_szAntiWinSound[0] )
			{
				set_msg_arg_string(2, g_szAntiWinSound)
			}

			if( bSwitchTeams )
			{
				new iRet
				ExecuteForward(g_iFurienTeamChangeForward, iRet, g_iFuriensTeam)
				g_bSwitchInProgress = true
				EnableHamForward( g_iHhTakeDamage )
			}
		}
		else
		{
			if( g_szFurienWinSound[0] )
			{
				set_msg_arg_string(2, g_szFurienWinSound)
			}
		}		
	}
}

public Event_DeathMsg()
{
	new iKiller = read_data(1)
	if( IsPlayer(iKiller) && is_user_connected(iKiller) )
	{
		new iVictim = read_data(2)
		if( iVictim != iKiller )
		{
			new iVicTimTeam = __get_user_team(iVictim)
			if( __get_user_team(iKiller) == iVicTimTeam )
			{
				return
			}
			g_iNewMoney = clamp
						( 
							cs_get_user_money(iKiller) + (iVicTimTeam == Furien ? g_iFurienReward : g_iAntiReward), 
							0, 
							16000
						)
			g_iMsgHookMoney = register_message(g_iMoney, "Message_Money")
		}
	}
}

public Message_Money(iMsgId, iMsgDest, id)
{
	unregister_message(g_iMoney, g_iMsgHookMoney)
	cs_set_money_value(id, g_iNewMoney)
	set_msg_arg_int(1, ARG_LONG, g_iNewMoney)
}

public A_Propos(id)
{
	if( is_user_connected(id) )
	{
		client_print(id, print_chat, "%L", id, "FURIEN_CREDIT", FURIEN_VERSION)
		client_print(id, print_console, "%L", id, "FURIEN_LINK")
	}
}

public Player_AddPlayerItem(id , iWeapon)
{
	if(	ExecuteHam(Ham_Item_GetWeaponPtr, iWeapon) != iWeapon
	||	cs_get_weapon_id(iWeapon) != CSW_C4	
	||	g_bitBombPlant & __get_user_team(id)	)
	{
		return HAM_IGNORED
	}

	set_pev(iWeapon, pev_flags, pev(iWeapon, pev_flags) | FL_KILLME)
	cs_set_user_plant(id, 0)
	set_pev(id, pev_body, 0)
	SetHamReturnInteger(0)
	return HAM_SUPERCEDE
}

public Hostage_Spawn( iHostage )
{
	remove_entity(iHostage)
	return HAM_SUPERCEDE
}

public Player_TakeDamage() // switch teams
{
	return HAM_SUPERCEDE
}