	/*	Copyright © 2008, ConnorMcLeod

	Reconnect Features is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Reconnect Features; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <fakemeta>

/****** Customization Area ******/
// Flag to allow admin to reconnect without hudmessage
// This is usefull when you reconnect with another nick to watch a suspected cheater
// This will still set back your score/money/...
#define ADMIN_SILENT ADMIN_KICK

// Color for hud message
#define RED	0
#define GREEN	100
#define BLUE	200
/********************************/

#define PLUGIN "Reconnect Features"
#define AUTHOR "ConnorMcLeod"
#define VERSION "0.2.4 BETA"

#define MAX_PLAYERS	32
#define MAX_STORED 	64

#define OFFSET_CSMONEY	115
#define OFFSET_CSDEATHS	444

#define TASK_KILL	1946573517
#define TASK_CLEAR	2946573517
#define TASK_PLAYER 3946573517


enum Storage {
	StoreSteamId[20],
	StoreFrags,
	StoreDeaths,
	StoreMoney,
	StoreRound
}

new g_CurInfos[MAX_PLAYERS+1][Storage]
new g_StoredInfos[MAX_STORED][Storage]

new bool:g_bPlayerNonSpawnEvent[MAX_PLAYERS + 1]
new g_iFwFmClientCommandPost

new g_iRoundNum

new /*g_pcvarTime, */g_pcvarScore, g_pcvarMoney, g_pcvarSpawn, g_pcvarStartMoney, g_pcvarNotify
new mp_startmoney
new g_msgidDeathMsg
new g_iMaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("reconnect.txt")

	//register_cvar("reconnect_features", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	//g_pcvarTime = register_cvar("amx_noreconnect_time", "300")
	g_pcvarScore = register_cvar("amx_noreconnect_score", "1")
	g_pcvarMoney = register_cvar("amx_noreconnect_money", "1")
	g_pcvarSpawn = register_cvar("amx_noreconnect_spawn", "0")
	g_pcvarStartMoney = register_cvar("amx_noreconnect_startmoney", "0")
	g_pcvarNotify = register_cvar("amx_noreconnect_notify", "0")

	register_event("HLTV", "eNewRound", "a", "1=0", "2=0")

	register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w")

	register_event("ResetHUD", "Event_ResetHUD", "b")
	register_event("TextMsg", "Event_TextMsg_GameWillRestartIn", "a", "2=#Game_will_restart_in")
	register_clcmd("fullupdate", "ClientCommand_fullupdate")

	register_event("Money", "eMoney", "be")
	register_event("ScoreInfo", "eScoreInfo", "a")
}

public plugin_cfg()
{
	mp_startmoney = get_cvar_pointer("mp_startmoney")
	g_msgidDeathMsg = get_user_msgid("DeathMsg")
	g_iMaxPlayers = global_get(glb_maxClients)
}

public Event_TextMsg_GameWillRestartIn()
{
	static id
	for(id = 1; id <= g_iMaxPlayers; ++id)
		if( is_user_alive(id) )
			g_bPlayerNonSpawnEvent[id] = true
}

public ClientCommand_fullupdate(id)
{
	g_bPlayerNonSpawnEvent[id] = true
	static const szClientCommandPost[] = "Forward_ClientCommand_Post"
	g_iFwFmClientCommandPost = register_forward(FM_ClientCommand, szClientCommandPost, 1)
	return PLUGIN_CONTINUE
}

public Forward_ClientCommand_Post(id)
{
	unregister_forward(FM_ClientCommand, g_iFwFmClientCommandPost, 1)
	g_bPlayerNonSpawnEvent[id] = false
	return FMRES_HANDLED
}

public Event_ResetHUD(id)
{
	if (!is_user_alive(id))
		return

	if (g_bPlayerNonSpawnEvent[id])
	{
		g_bPlayerNonSpawnEvent[id] = false
		return
	}

	Forward_PlayerSpawn(id)
}

Forward_PlayerSpawn(id)
{
	if(g_CurInfos[id][StoreRound] == g_iRoundNum)
	{
		g_CurInfos[id][StoreRound] = 0
		set_task(0.1, "task_delay_kill", id+TASK_KILL)
	}
}

public task_delay_kill(id)
{
	id -= TASK_KILL

	new Float:fFrags
	pev(id, pev_frags, fFrags)
	set_pev(id, pev_frags, ++fFrags)

	set_pdata_int(id, OFFSET_CSDEATHS, get_pdata_int(id, OFFSET_CSDEATHS) - 1)

	new msgblock = get_msg_block(g_msgidDeathMsg)
	set_msg_block(g_msgidDeathMsg, BLOCK_ONCE)
	dllfunc(DLLFunc_ClientKill, id)
	set_msg_block(g_msgidDeathMsg, msgblock)

	client_print(id, print_chat, "** [GG][Reconnect] %L", id, "RF_SPAWN")
}

public eMoney(id)
{
	g_CurInfos[id][StoreMoney] = read_data(1)
}

public eScoreInfo()
{
	new id = read_data(1)
	if(!(1<= id <= g_iMaxPlayers))
		return

	g_CurInfos[id][StoreFrags] = read_data(2)
	g_CurInfos[id][StoreDeaths] = read_data(3)
}

public eRestart()
{
	for(new i; i < MAX_STORED; i++)
	{
		remove_task(i+TASK_CLEAR)
		remove_task(i+TASK_PLAYER)
		g_StoredInfos[i][StoreSteamId][0] = 0
	}
}

public eNewRound()
{
	g_iRoundNum++
}

public client_disconnected(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
	{
		return
	}
/*
	new Float:fTaskTime = get_pcvar_float(g_pcvarTime)
	if(!fTaskTime)
		return
*/
	static iFree
	for(iFree = 0; iFree <= MAX_STORED; iFree++)
	{
		if(iFree == MAX_STORED)
		{
			return
		}
		if(!g_StoredInfos[iFree][StoreSteamId][0])
			break
	}

	copy(g_StoredInfos[iFree][StoreSteamId], 19, g_CurInfos[id][StoreSteamId])
	g_StoredInfos[iFree][StoreFrags] = g_CurInfos[id][StoreFrags]
	g_StoredInfos[iFree][StoreDeaths] = g_CurInfos[id][StoreDeaths]
	g_StoredInfos[iFree][StoreMoney] = g_CurInfos[id][StoreMoney]
	g_StoredInfos[iFree][StoreRound] = g_iRoundNum

	g_CurInfos[id][StoreSteamId][0] = 0
	g_CurInfos[id][StoreFrags] = 0
	g_CurInfos[id][StoreDeaths] = 0
	g_CurInfos[id][StoreMoney] = 0
	g_CurInfos[id][StoreRound] = 0

	//set_task(fTaskTime, "task_clear", iFree+TASK_CLEAR)
}

public task_clear(iTaskId)
{
	iTaskId -= TASK_CLEAR
	g_StoredInfos[iTaskId][StoreSteamId][0] = 0
}

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return

	g_bPlayerNonSpawnEvent[id] = false

	static szSteamId[20]
	get_user_authid(id, szSteamId, 19)
	copy(g_CurInfos[id][StoreSteamId], 19, szSteamId)

	for(new i; i < MAX_STORED; i++)
	{
		if(!g_StoredInfos[i][StoreSteamId][0])
			continue

		if( equal(g_StoredInfos[i][StoreSteamId], szSteamId, strlen(szSteamId)) )
		{
			if(get_pcvar_num(g_pcvarScore))
			{
				set_pev(id, pev_frags, float(g_StoredInfos[i][StoreFrags]))
				set_pdata_int(id, OFFSET_CSDEATHS, g_StoredInfos[i][StoreDeaths])
				g_CurInfos[id][StoreFrags] = g_StoredInfos[i][StoreFrags]
				g_CurInfos[id][StoreDeaths] = g_StoredInfos[i][StoreDeaths]
			}
			if(get_pcvar_num(g_pcvarMoney))
			{
				new iMoney = g_StoredInfos[i][StoreMoney]
				new iStartMoney = get_pcvar_num(mp_startmoney)
				if(get_pcvar_num(g_pcvarStartMoney) && iMoney > iStartMoney)
				{
					set_pdata_int(id, OFFSET_CSMONEY, iStartMoney)
					g_CurInfos[id][StoreMoney] = iStartMoney
				}
				else
				{
					set_pdata_int(id, OFFSET_CSMONEY, iMoney)
					g_CurInfos[id][StoreMoney] = iMoney
				}
			}
			if(get_pcvar_num(g_pcvarSpawn))
			{
				g_CurInfos[id][StoreRound] = g_StoredInfos[i][StoreRound]
			}

			remove_task(id+TASK_PLAYER)
			set_task(10.0, "task_print_player", id+TASK_PLAYER)

			g_StoredInfos[i][StoreSteamId][0] = 0

			new iNotifyType = get_pcvar_num(g_pcvarNotify)
			if(iNotifyType && !(get_user_flags(id)&ADMIN_SILENT) )
			{
				static szName[32]
				get_user_name(id, szName, 31)
				if( iNotifyType == 1 )
				{
					set_hudmessage(RED, GREEN, BLUE, -1.0, 0.35, 2, 3.0, 10.0, 0.1, 0.2, -1)
					show_hudmessage(0, "%L", LANG_PLAYER, "RF_ALL", szName)
				}
				else
				{
					client_print(0, print_chat, "** [GG][Reconnect] %L", LANG_PLAYER, "RF_ALL", szName)
				}
			}
			return
		}
	}
	g_CurInfos[id][StoreRound] = -1
}

public task_print_player(id)
{
	if(is_user_connected(id -= TASK_PLAYER))
	{
		static szText[128]
		new n = formatex(szText, 127, "** [GG][Reconnect] %L", id, "RF_PLAYER_PRINT")
		if(get_pcvar_num(g_pcvarScore))
			n += formatex(szText[n], 127 - n, " %L", id, "RF_SCORE")
		if(get_pcvar_num(g_pcvarMoney))
			n += formatex(szText[n], 127 - n, " %L", id, "RF_MONEY")
		client_print(id, print_chat, szText)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
