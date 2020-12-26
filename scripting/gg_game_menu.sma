#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#pragma compress 1

native bool: WeaponsSaved(id);

public plugin_init()
{
	register_plugin("Game Menu", "1.0", "~DarkSiDeRs~");

	register_clcmd("say /menu", "GameMenu");
	register_clcmd("say /gamemenu", "GameMenu");

	register_clcmd("chooseteam", "cmd_jointeam");
	register_clcmd("jointeam", "cmd_jointeam");
}

public GameMenu(id)
{
	new menu = menu_create("\y.::||\r Geek~Gamers \y||::.", "GameMenu_MenuHandler");

	menu_additem(menu, "\wGeek~Gamers Menu", "1", 0);

	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		if(WeaponsSaved(id))
	        	menu_additem(menu, "\rRe-Enable \yWeapons \r- \yMenu", "2", 0);
		else menu_additem(menu, "\yWeapons \r- \yMenu", "2", 0);
		menu_additem(menu, "\wHuman Classes", "3", 0);
	}
	else
	{
		menu_additem(menu, "\yKnife \r- \yMenu", "2", 0);
		menu_additem(menu, "\wFurien Classes", "3", 0);
	}

	menu_additem(menu, "\ySecure UserName^n", "4", 0);
	menu_additem(menu, "\wLevel Menu", "5", 0);
	menu_additem(menu, "\yRank Menu^n", "6", 0);

	if(get_user_flags(id) & ADMIN_LEVEL_G)
		menu_additem(menu, "\yFurien VIP \r- \wMenu \d[OPEN]", "7", 0);
	else
		menu_additem(menu, "\dFurien VIP - Menu \r(V.I.P)", "7", 0);

	if(get_user_flags(id) & ADMIN_KICK)
		menu_additem(menu, "\wAdmin \r- \yMenu \d[OPEN]^n", "8", 0);
	else
		menu_additem(menu, "\dAdmin - Menu \r(Silver V.I.P)^n", "8", 0);

	if(get_user_flags(id) & ADMIN_LEVEL_C)
		menu_additem(menu, "\rOwner \w- \rMenu \d[OPEN]", "9", 0);
	else
		menu_additem(menu, "\dOwner - Menu \r(Only Owners)", "9", 0);

	menu_addblank(menu, 0);
	menu_additem(menu, "Exit", "MENU_EXIT");

	menu_setprop(menu, MPROP_PERPAGE, 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public GameMenu_MenuHandler(id, menu, item)
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

	switch(item)
	{
		case 0: client_cmd(id, "say /ggmenu");
	        case 1:
		{
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				if(WeaponsSaved(id))
					client_cmd(id, "say /guns");
				else client_cmd(id, "say /weapons");
			}
			else
			if(cs_get_user_team(id) == CS_TEAM_T)
				client_cmd(id, "say /knife");
		}
	        case 2:
		{
			if(cs_get_user_team(id) == CS_TEAM_CT)
				client_cmd(id, "say /humanclass");
			else
			if(cs_get_user_team(id) == CS_TEAM_T)
				client_cmd(id, "say /furienclass");
		}
		case 3: client_cmd(id, "say /reg");
		case 4: client_cmd(id, "say /lvlmenu");
		case 5: client_cmd(id, "say /rank");
		case 6: client_cmd(id, "vmenu; say vmenu By [Geek~Gamers]");
		case 7:
		{
			if(get_user_flags(id) & ADMIN_KICK)
				client_cmd(id, "amenu");
			else
			{
				ChatColor(id, "!t[GG] !nThis Menu is reserved Only for !gSilver V.I.P");
				GameMenu(id);
			}
		}
		case 8:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_C)
				client_cmd(id, "ownermenu");
			else
			{
				ChatColor(id, "!t[GG] !nThis Menu is reserved Only for !gOwners");
				GameMenu(id);
			}
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public cmd_jointeam(id)
{
	if(!is_user_connected(id))
		return 1;

	if(cs_get_user_team(id) != CS_TEAM_UNASSIGNED && cs_get_user_team(id) != CS_TEAM_SPECTATOR)
	{
		GameMenu(id);
		return 1;
	}
	
	return PLUGIN_CONTINUE;
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
