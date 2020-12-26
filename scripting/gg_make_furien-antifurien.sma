#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <Colorchat>

#pragma compress 1
#pragma tabsize 0

#define GOLD_LEVEL ADMIN_LEVEL_E
#define DIAMOND_LEVEL ADMIN_LEVEL_D
#define OWNER_LEVEL ADMIN_LEVEL_B

native bool: modstarted(id);

public plugin_init()
{
	register_plugin("[GG] Make Furien/Anti-Furien", "1.0", "~DarkSiDeRs~");

	register_clcmd("make", "Transfer", GOLD_LEVEL, "");
	register_clcmd("say /make", "Transfer", GOLD_LEVEL, "");
	register_clcmd("say_team /make", "Transfer", GOLD_LEVEL, "");
	register_clcmd("say /makeb", "ShowMenuB", OWNER_LEVEL, "");

	register_clcmd("say /team", "Transfer", GOLD_LEVEL, "");
	register_clcmd("say_team /team", "Transfer", GOLD_LEVEL, "");

	register_clcmd("say /transfer", "Transfer", GOLD_LEVEL, "");
	register_clcmd("say_team /transfer", "Transfer", GOLD_LEVEL, "");
}

public Transfer(id)
{
	if( !(get_user_flags(id) & GOLD_LEVEL) )
		return PLUGIN_HANDLED;

	if( get_user_flags(id) & OWNER_LEVEL )
		ShowMenu(id)
	else
	{
		if( modstarted(id) ) ChatColor(id, "!g[GG][TRANSFER] !nYou can't Open This Menu in The Current !tMod !n!");
		else ShowMenu(id);
	}

	return PLUGIN_HANDLED;
}

public ShowMenu(id)
{
	if( !(get_user_flags(id) & GOLD_LEVEL) )
		return PLUGIN_HANDLED;

	if( !(get_user_flags(id) & OWNER_LEVEL) && modstarted(id) )
		return PLUGIN_HANDLED;

	new TransferPlayer = menu_create ("\d[\yGeek~Gamers\d] \rMake \yFurien \w/ \yAnti-Furien:", "HandleTransfer")

	new num, players[32], tempid, szTempID [10], tempname [32], szName [32], textmenu [64]

	get_players (players, num, "c")
	for (new i = 0; i < num; i++)
	{
		tempid = players [ i ]

		get_user_name(tempid, tempname, 31)
		get_user_name(tempid, szName, charsmax(szName))
		num_to_str(tempid, szTempID, 9)

		if( (get_user_flags(id) & GOLD_LEVEL) && !(get_user_flags(id) & DIAMOND_LEVEL) )
		{
			if( tempid != id )
				continue;
		}

		if(cs_get_user_team(tempid) == CS_TEAM_T)
        		formatex(textmenu, 63, "%s \d- \r[Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_CT)
    	   	 	formatex(textmenu, 63, "%s \d- \y[Anti-Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
			formatex(textmenu, 63, "%s \d- [SPECTATOR]", szName)

		menu_additem(TransferPlayer, textmenu, szTempID, 0)
	}

	menu_display (id, TransferPlayer)
	return PLUGIN_HANDLED
}

public HandleTransfer(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if( !(get_user_flags(id) & OWNER_LEVEL) && modstarted(id) )
		return PLUGIN_HANDLED;
	
	new data[6], name[64], szPlayerName[33], szName[33]
	new access, callback
	
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num (data)
	
	get_user_name(id, szName, charsmax(szName))
	get_user_name(tempid, szPlayerName, charsmax(szPlayerName))

	if(cs_get_user_team(tempid) == CS_TEAM_CT || cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
	{
		cs_set_user_team(tempid, CS_TEAM_T)
		ColorChat(0, RED, "^3[GG] ^1%s ^4%s ^1Turned Back ^4%s ^1To ^3Furien ^4!", get_user_flags(id) & ADMIN_LEVEL_E ? "OWNER":"ADMIN", szName, szPlayerName)
	}
	else
	if(cs_get_user_team(tempid) == CS_TEAM_T)
	{
		cs_set_user_team(tempid, CS_TEAM_CT)
		ColorChat(0, RED, "^3[GG] ^1%s ^4%s ^1Turned Back ^4%s ^1To ^3Anti-Furien ^4!", get_user_flags(id) & ADMIN_LEVEL_E ? "OWNER":"ADMIN", szName, szPlayerName)
	}
/*
	if(is_user_alive(tempid))
		spawn_func(tempid)
*/
	user_silentkill(tempid)

	menu_destroy(menu);
	ShowMenu(id);

	return PLUGIN_CONTINUE
}

public ShowMenuB(id)
{
	if( !(get_user_flags(id) & OWNER_LEVEL) )
		return PLUGIN_HANDLED;

	new TransferPlayer = menu_create ("\d[\yGeek~Gamers\d] \rMake \yFurien \w/ \yAnti-Furien:", "HandleTransferB")

	new num, players[32], tempid, szTempID [10], tempname [32], szName [32], textmenu [64]

	get_players (players, num, "d")
	for (new i = 0; i < num; i++)
	{
		tempid = players [ i ]

		if(cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
			continue

		get_user_name(tempid, tempname, 31)
		get_user_name(tempid, szName, charsmax(szName))
		num_to_str(tempid, szTempID, 9)

		if(cs_get_user_team(tempid) == CS_TEAM_T)
        		formatex(textmenu, 63, "%s \d- \r[Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_CT)
    	   	 	formatex(textmenu, 63, "%s \d- \y[Anti-Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
			formatex(textmenu, 63, "%s \d- [SPECTATOR]", szName)

		menu_additem(TransferPlayer, textmenu, szTempID, 0)
	}

	menu_display (id, TransferPlayer)
	return PLUGIN_HANDLED
}

public HandleTransferB(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], name[64], szPlayerName[33], szName[33]
	new access, callback
	
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num (data)
	
	get_user_name(id, szName, charsmax(szName))
	get_user_name(tempid, szPlayerName, charsmax(szPlayerName))

	if(cs_get_user_team(tempid) == CS_TEAM_CT || cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
	{
		cs_set_user_team(tempid, CS_TEAM_T)
		ColorChat(0, RED, "^3[GG] ^1%s ^4%s ^1Turned Back ^4%s ^1To ^3Furien ^4!", get_user_flags(id) & ADMIN_LEVEL_E ? "OWNER":"ADMIN", szName, szPlayerName)
	}
	else
	if(cs_get_user_team(tempid) == CS_TEAM_T)
	{
		cs_set_user_team(tempid, CS_TEAM_CT)
		ColorChat(0, RED, "^3[GG] ^1%s ^4%s ^1Turned Back ^4%s ^1To ^3Anti-Furien ^4!", get_user_flags(id) & ADMIN_LEVEL_E ? "OWNER":"ADMIN", szName, szPlayerName)
	}
/*
	if(is_user_alive(tempid))
		spawn_func(tempid)
*/
	user_silentkill(tempid)

	menu_destroy(menu);
	ShowMenuB(id);

	return PLUGIN_CONTINUE
}

public spawn_func(id) 
{
	ExecuteHamB(Ham_CS_RoundRespawn, id);

	if(cs_get_user_team(id) == CS_TEAM_CT)
		client_cmd(id, "weapons");
	else if(cs_get_user_team(id) == CS_TEAM_T)
		client_cmd(id, "knife");
}
/*
public spawn_func(id) 
{
	new svIndex[2];
	svIndex[0] = id;
	set_task(0.2, "respawn", 0, svIndex, 2);
}

public respawn(svIndex[]) 
{ 
	new vIndex = svIndex[0]
	spawn(vIndex)
}
*/
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1055\\ f0\\ fs16 \n\\ par }
*/