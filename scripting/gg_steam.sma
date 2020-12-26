#include <amxmodx>

#pragma compress 1

new accessmenu, iName[64], callback;

public plugin_init()
{
	register_plugin("[GG] Show Steam/No-Steam", "1.0", "~Da4rkSiD3Rs~");

	register_clcmd("say /steam", "ShowMenu");
	register_clcmd("say /steams", "ShowMenu");
	register_clcmd("say /steamer", "ShowMenu");
	register_clcmd("say /steamers", "ShowMenu");
	register_clcmd("say steam", "ShowMenu");
	register_clcmd("say steams", "ShowMenu");
	register_clcmd("say steamer", "ShowMenu");
	register_clcmd("say steamers", "ShowMenu");
}

public ShowMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rSteam Players Menu^n\r>> \ySTEAM \w= \yNo Cheat", "ShowMenuHandler");
	
	new name[32], pid[32], players[32], text[555 char], pnum, tempid;

	get_players(players, pnum, "c");
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 
		formatex(text, charsmax(text), "%s \d- %s", name, is_user_steam(tempid) ? "\r[STEAM]" : "\y[NO-STEAM]");
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

stock bool:is_user_steam(id)
{
        static dp_pointer;
        if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
        {
            server_cmd("dp_clientinfo %d", id);
            server_exec();
            return (get_pcvar_num(dp_pointer) == 2) ? true : false;
        }
        return false;
}
