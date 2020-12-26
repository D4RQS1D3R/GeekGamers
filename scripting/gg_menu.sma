#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#pragma compress 1

public plugin_init()
{
	register_plugin("GG Menu", "1.0", "D4RQS1D3R");

	register_clcmd("say /ggmenu", "GGMenu");
}

public GGMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rMenu", "GGMenuHandler");

	menu_additem(menu, "Players Menu", "", 0);
	menu_additem(menu, "Online Admins", "", 0);
	menu_additem(menu, "Buy Admin", "", 0);
	menu_additem(menu, "Private Message", "", 0);
	menu_additem(menu, "Donate Money", "", 0);
	menu_additem(menu, "Camera View", "", 0);
	menu_additem(menu, "Vote Map Menu", "", 0);
	menu_additem(menu, "Control HUD Messages", "", 0);
	menu_additem(menu, "Free VIP Requirements", "", 0);
	menu_additem(menu, "Reset your Score", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public GGMenuHandler(id, menu, item)
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
		case 0: PlayersMenu(id);
		case 1: client_cmd(id, "say who");
		case 2: client_cmd(id, "say /buy");
		case 3: client_cmd(id, "say /pm");
		case 4: client_cmd(id, "say /cam");	
		case 5: VoteMap(id);
		case 6: client_cmd(id, "say /hud");
		case 7: client_cmd(id, "say /freevip");
		case 8: client_cmd(id, "say /rs");
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public PlayersMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rPlayers Menu", "PlayersMenuHandler");

	menu_additem(menu, "Players Levels", "", 0);
	menu_additem(menu, "Top 15 Levels", "", 0);
	menu_additem(menu, "Players Credits", "", 0);
	menu_additem(menu, "Steam Players", "", 0);
	menu_additem(menu, "Players Locations", "", 0);
	menu_additem(menu, "Mute Players", "", 0);
	menu_additem(menu, "VoteBan Players", "", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public PlayersMenuHandler(id, menu, item)
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
		case 0: client_cmd(id, "say /level");
		case 1: client_cmd(id, "say /toplevel");
		case 2: client_cmd(id, "say /credits");
		case 3: client_cmd(id, "say /steam");
		case 4: client_cmd(id, "say /location");
		case 5: client_cmd(id, "say /mute");
		case 6: client_cmd(id, "say /voteban");
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public VoteMap(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rVote Map Menu", "VoteMapHandler");

	menu_additem(menu, "Change Map", "", 0);
	menu_additem(menu, "Nominate Map", "", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public VoteMapHandler(id, menu, item)
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
		case 0: client_cmd(id, "say rtv");
		case 1: client_cmd(id, "say nominate de");
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
