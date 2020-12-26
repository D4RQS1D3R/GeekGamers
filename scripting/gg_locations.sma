#include <amxmodx>
#include <sxgeo>

#pragma compress 1

new accessmenu, iName[64], callback;
new g_pcvar_amx_language;

public plugin_init()
{
	register_plugin("[GG] Show Players Location", "1.0", "~D4rkSiD3Rs~");

	register_clcmd("say /location", "ShowMenu");
	register_clcmd("say_team /location", "ShowMenu");
	register_clcmd("say location", "ShowMenu");
	register_clcmd("say_team location", "ShowMenu");

	register_clcmd("say /locations", "ShowMenu");
	register_clcmd("say_team /locations", "ShowMenu");
	register_clcmd("say locations", "ShowMenu");
	register_clcmd("say_team locations", "ShowMenu");

	register_clcmd("say /country", "ShowMenu");
	register_clcmd("say_team /country", "ShowMenu");
	register_clcmd("say country", "ShowMenu");
	register_clcmd("say_team country", "ShowMenu");

	register_clcmd("say /countries", "ShowMenu");
	register_clcmd("say_team /countries", "ShowMenu");
	register_clcmd("say countries", "ShowMenu");
	register_clcmd("say_team countries", "ShowMenu");

	g_pcvar_amx_language = get_cvar_pointer("amx_language");
}

public ShowMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rPlayers Location:", "ShowMenuHandler");
	
	new pid[32], players[32], text[555 char], pnum, tempid;

	new szLanguage[3];
	get_pcvar_string(g_pcvar_amx_language, szLanguage, charsmax(szLanguage));

	get_players(players, pnum);
	for(new i; i< pnum; i++)
	{
		tempid = players[i];

		new szName[32], szIP[16];
		get_user_name(tempid, szName, charsmax(szName));
		get_user_ip(tempid, szIP, charsmax(szIP), /*strip port*/ 0);

		new szCountry[64], szCity[64];

		new bool:bCountryFound = sxgeo_country(szIP, szCountry, charsmax(szCountry), /*use lang server*/ szLanguage);
		new bool:bCityFound    = sxgeo_city   (szIP, szCity,    charsmax(szCity),    /*use lang server*/ szLanguage);

		if(bCountryFound && equali(szCity, ""))
		{
			formatex(text, charsmax(text), "%s \d- \r[\y%s\r]", szName, szCountry);
		}
		else if(bCountryFound && bCityFound)
		{
			formatex(text, charsmax(text), "%s \d- \r[\y%s, %s\r]", szName, szCountry, szCity);
		}
		else
		{
			continue;
		}

		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public ShowMenuHandler(id, players_menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu);
		return PLUGIN_HANDLED;
	}
   
	new data[6];
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	return PLUGIN_CONTINUE;
}
