#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#pragma compress 1

#define PLUGIN "[GG] Owner Menu"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

#define OWNER_LEVEL ADMIN_LEVEL_C
#define OWNERCMD_LEVEL ADMIN_LEVEL_B

#define PASS "n9lsd1w"

new OwPass[32];
new bool: Get_pack[32];
new bool: Case1;
new bool: Case2;
new bool: Case3;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /ownermenu","OwnerMenu", OWNER_LEVEL);
	register_clcmd("ownermenu","OwnerMenu", OWNER_LEVEL);

	register_clcmd("OwnerPass", "OwnerPass1");

	register_clcmd("say /owpack", "OwnerPack");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public Spawn(id)
{
	Get_pack[id] = false;
}

public OwnerMenu(id)
{
	if(! (get_user_flags(id) & OWNER_LEVEL) ) return PLUGIN_HANDLED

	new menu = menu_create("\d[\yGeek~Gamers\d] \rOwner Menu:","MenuOwnerHandler")

	menu_additem(menu, "\yGet \w16000$ \r& \wPack Grenade^n", "1", 0);

	menu_additem(menu, "\yLevel \rMenu", "2", 0);
	menu_additem(menu, "\yCredits \rMenu^n", "3", 0);

	menu_additem(menu, "\rCompound Bow \yMenu", "4", 0);
	menu_additem(menu, "\rSuper Knife \yMenu^n", "5", 0);

	menu_additem(menu, "\yDestroy \rMenu", "6", 0);
	menu_additem(menu, "\yTeleport \rMenu", "7", 0);
	menu_additem(menu, "\yRestart \rRound", "8", 0);

	menu_addblank(menu, 1); 
	menu_additem(menu, "Exit", "MENU_EXIT");

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public MenuOwnerHandler(id, menu, item)
{
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1:
		{
			if(get_user_flags(id) & OWNERCMD_LEVEL)
			{
				OwnerPack(id);
			}
			else
			{
				if(!Get_pack[id])
				{
					OwnerPack(id);
					Get_pack[id] = true;
				}
				else ChatColor(id, "!t[GG][OWNER-MENU]!n You can get !gMoney !nand !gPack Grenades Only once per round !t!");
			}
		}
		case 2:
		{
			Case1 = true;
			Case2 = false;
			Case3 = false;
			client_cmd(id, "messagemode OwnerPass");
		}
		case 3:
		{
			Case1 = false;
			Case2 = true;
			Case3 = false;
			client_cmd(id, "messagemode OwnerPass");
		}
		case 4: client_cmd(id, "say /bow");
		case 5: client_cmd(id, "say /superknife");
		case 6:
		{
			Case1 = false;
			Case2 = false;
			Case3 = true;
			client_cmd(id, "messagemode OwnerPass");
		}
		case 7: client_cmd(id,"amx_teleportmenu");
		case 8: client_cmd(id, "say /rr");
	}
}

public OwnerPass1(id)
{
	read_args(OwPass, charsmax(OwPass));
	remove_quotes(OwPass);

	if(equal(OwPass, PASS))
	{
		if( Case1 )
			client_cmd(id, "givelevelmenu");
		else
		if( Case2 )
			client_cmd(id, "creditsmenu");
		else
		if( Case3 )
			client_cmd(id, "say /destroy");
	}
}

public OwnerPack(id)
{
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");
	cs_set_user_money(id, 16000);
}
/*
public SUPER(id)
{
	if(! (get_user_flags(id) & OWNER_LEVEL) ) return PLUGIN_HANDLED

	new menu = menu_create("\d[\yGeek~Gamers\d] \rSuper Knife \yMenu:", "SUPERHandler");

	menu_additem(menu, "\y[ \wSuper Knife \rx2 \y]", "", OWNER_LEVEL);
	menu_additem(menu, "\y[ \wSuper Knife \rx3 \y]", "", OWNER_LEVEL);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_setprop(menu, MPROP_NOCOLORS, 1);

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public SUPERHandler(id, menu, item)
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
		case 0: client_cmd(id, "say /superknifex2");
		case 1: client_cmd(id, "say /superknifex3");
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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