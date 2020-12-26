/*	Copyright © 2008, ConnorMcLeod

	Instant AutoTeamBalance is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Instant AutoTeamBalance; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <cstrike>

#define PLUGIN "Instant AutoTeamBalance"
#define AUTHOR "ConnorMcLeod"
#define VERSION "1.2.0"

#define BALANCE_IMMUNITY		ADMIN_RCON

#define MAX_PLAYERS	32

enum {
	aTerro,
	aCt
}

new bool:g_bImmuned[MAX_PLAYERS+1]

new Float:g_fJoinedTeam[MAX_PLAYERS+1] = {-1.0, ...}

new g_iMaxPlayers
new g_pcvarEnable, g_pcvarImmune, g_pCvarMessage

// true when connected and not a HLTV
new bool:g_bValid[MAX_PLAYERS+1]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_pcvarEnable = register_cvar("iatb_active", "1")
	g_pcvarImmune = register_cvar("iatb_admins_immunity", "1")
	g_pCvarMessage = register_cvar("iatb_message", "Teams Auto Balanced")

	register_logevent("LogEvent_JoinTeam", 3, "1=joined team")

	register_event("TextMsg", "Auto_Team_Balance_Next_Round", "a", "1=4", "2&#Auto_Team")

	g_iMaxPlayers = get_maxplayers()
}

public LogEvent_JoinTeam()
{
	new loguser[80], name[32], id
	read_logargv(0, loguser, 79)
	parse_loguser(loguser, name, 31)
	id = get_user_index(name)

	g_fJoinedTeam[id] = get_gametime()
}

public client_authorized(id)
{
	g_bImmuned[id] = bool:(get_user_flags(id) & BALANCE_IMMUNITY)
}

public client_putinserver(id)
{
	g_bValid[id] = bool:!is_user_hltv(id)
}

public client_disconnect(id)
{
	g_bValid[id] = false
}

public Auto_Team_Balance_Next_Round()
{
	if(!get_pcvar_num(g_pcvarEnable))
		return

	if( balance_teams()  )
	{
		new szMessage[128]
		get_pcvar_string(g_pCvarMessage, szMessage, charsmax(szMessage))
		client_print(0, print_center, szMessage)
	}
}

cs_set_user_team_custom(id, CsTeams:iTeam)
{
	switch(iTeam)
	{
		case CS_TEAM_T: 
		{
			if( cs_get_user_defuse(id) )
			{
				cs_set_user_defuse(id, 0)
				// set body to 0 ?
			}
		}
		case CS_TEAM_CT:
		{
			if( user_has_weapon(id, CSW_C4) )
			{
				engclient_cmd(id, "drop", "weapon_c4")
			}
		}
	}

	cs_set_user_team(id, iTeam)

	return 1
}

balance_teams()
{
	new aTeams[2][MAX_PLAYERS], aNum[2], id

	for(id = 1; id <= g_iMaxPlayers; id++)
	{
		if(!g_bValid[id])
		{
			continue
		}

		switch( cs_get_user_team(id) )
		{
			case CS_TEAM_T:
			{
				aTeams[aTerro][aNum[aTerro]++] = id
			}
			case CS_TEAM_CT:
			{
				aTeams[aCt][aNum[aCt]++] = id
			}
			default:
			{
				continue
			}
		}
	}

	new iCheck
	new iTimes = aNum[aCt] - aNum[aTerro]

	if(iTimes > 0)
	{
		iCheck = aCt
	}
	else if(iTimes < 0)
	{
		iCheck = aTerro
	}
	else
	{
		return 0
	}

	iTimes = abs(iTimes/2)

	new bool:bTransfered[MAX_PLAYERS+1],
		bool:bAdminsImmune = bool:get_pcvar_num(g_pcvarImmune)

	new iLast, iCount
	while( iTimes > 0 )
	{
		iLast = 0
		for(new i=0; i <aNum[iCheck]; i++)
		{
			id = aTeams[iCheck][i]
			if( g_bImmuned[id] && bAdminsImmune )
			{
				continue
			}
			if(bTransfered[id])
			{
				continue
			}
			if(g_fJoinedTeam[id] > g_fJoinedTeam[iLast])
			{
				iLast = id
			}
		}

		if(!iLast)
		{
			return 0
		}

		cs_set_user_team_custom(iLast, iCheck ? CS_TEAM_T : CS_TEAM_CT)

		bTransfered[iLast] = true
		iCount++
		iTimes--
	}
	return 1
}