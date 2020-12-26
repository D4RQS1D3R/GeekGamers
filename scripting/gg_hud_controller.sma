#include <amxmodx>

#pragma compress 1

#define PLUGIN "[GG] HudMessage Controller"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new bool: freevip[33];
new bool: adminonline[33];
new bool: gamemods[33];
new bool: level[33];
new bool: speclist[33];
new bool: allhuds[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /hud",		"HudMessages_Menu");
	register_clcmd("say /hudmsg",		"HudMessages_Menu");
	register_clcmd("say /hudmessage",	"HudMessages_Menu");
	register_clcmd("say /hudmessages",	"HudMessages_Menu");
}

public plugin_natives()
{
	register_native("HC_FreeVIP",		"native_HC_FreeVIP",		1);
	register_native("HC_AdminOnline",	"native_HC_AdminOnline",	1);
	register_native("HC_GameMods",		"native_HC_GameMods",		1);
	register_native("HC_Level",		"native_HC_Level",		1);
	register_native("HC_SpecList",		"native_HC_SpecList",		1);
	register_native("HC_AllOFF",		"native_HC_AllOFF",		1);
}

public native_HC_FreeVIP(id)
{
	return freevip[id];
}

public native_HC_AdminOnline(id)
{
	return adminonline[id];
}

public native_HC_GameMods(id)
{
	return gamemods[id];
}

public native_HC_Level(id)
{
	return level[id];
}

public native_HC_SpecList(id)
{
	return speclist[id];
}

public native_HC_AllOFF(id)
{
	return allhuds[id];
}

public client_putinserver(id)
{
	allhuds[id] = false;
	freevip[id] = true;
	adminonline[id] = true;
	gamemods[id] = true;
	level[id] = true;
	speclist[id] = true;
}

public HudMessages_Menu(id)
{
	new InfoStatus[198], InfoStatus2[198], InfoStatus3[198], InfoStatus4[198], InfoStatus5[198], InfoStatus6[198];

	if(!freevip[id] && !adminonline[id] && !gamemods[id] && !level[id] && !speclist[id])
	{
		allhuds[id] = true;
	}
	else allhuds[id] = false;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rHUD Messages Controller^n\r>> \yDisable HUDs to increase your FPS.", "HudMessages_MenuHandler");

	formatex(InfoStatus, charsmax(InfoStatus), "\wFree VIP : \d[%s\d]", freevip[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus, "1");

	formatex(InfoStatus2, charsmax(InfoStatus2), "\wAdmin Online : \d[%s\d]", adminonline[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus2, "2");

	formatex(InfoStatus3, charsmax(InfoStatus3), "\wGame Mods : \d[%s\d]", gamemods[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus3, "3");

	formatex(InfoStatus4, charsmax(InfoStatus4), "\wLevel : \d[%s\d]", level[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus4, "4");

	formatex(InfoStatus5, charsmax(InfoStatus5), "\wSpectator List : \d[%s\d]^n", speclist[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus5, "5");

	formatex(InfoStatus6, charsmax(InfoStatus6), "\wHide All HUD Messages : \d[%s\d]", allhuds[id] ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus6, "6");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public HudMessages_MenuHandler(id, menu, item)
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
			if(freevip[id])
				freevip[id] = false;
			else freevip[id] = true;
		}
		case 1:
		{
			if(adminonline[id])
				adminonline[id] = false;
			else adminonline[id] = true;
		}
		case 2:
		{
			if(gamemods[id])
				gamemods[id] = false;
			else gamemods[id] = true;
		}
		case 3:
		{
			if(level[id])
				level[id] = false;
			else level[id] = true;
		}
		case 4:
		{
			if(speclist[id])
				speclist[id] = false;
			else speclist[id] = true;
		}
		case 5:
		{
			if(allhuds[id])
			{
				allhuds[id] = false;
				freevip[id] = true;
				adminonline[id] = true;
				gamemods[id] = true;
				level[id] = true;
				speclist[id] = true;
			}
			else
			{
				allhuds[id] = true;
				freevip[id] = false;
				adminonline[id] = false;
				gamemods[id] = false;
				level[id] = false;
				speclist[id] = false;
			}
		}
	}

	menu_destroy(menu);
	HudMessages_Menu(id);

	return PLUGIN_HANDLED;
}