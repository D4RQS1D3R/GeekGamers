#include <amxmodx>
#include <colorchat>

#pragma compress 1

new g_iTarget[33]

public plugin_init() 
{
	register_plugin("PM - Private Message", "1.0", "EaGle/Flicker-rewriten")

	register_clcmd("say /pm", "cmdPMMenu")
	register_clcmd("say_team /pm", "cmdPMMenu")

	register_clcmd("PrivateMessage", "cmd_player");
}

public cmdPMMenu(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rPrivate Message \wMenu:", "handlePMMEnu")

	new players[32], num
	new szName[32], szTempid[32]

	get_players(players, num, "ch")

	for(new i; i < num; i++)
	{
		if(players[i] == id)
			continue

		get_user_name(players[i], szName, charsmax(szName))
		num_to_str(get_user_userid(players[i]), szTempid, charsmax(szTempid))
		menu_additem(menu, szName, szTempid, 0)
	}

	menu_display(id, menu)
}

public handlePMMEnu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new szData[6], szName[64], iAccess, iCallback
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), szName, charsmax(szName), iCallback)

	g_iTarget[id] = find_player("k", str_to_num(szData))

	client_cmd(id, "messagemode PrivateMessage")

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public cmd_player(id)
{
	new say[300]
	read_args(say, charsmax(say))
	remove_quotes(say)

	if(!strlen(say) || containi(say, "%") != -1)
		return PLUGIN_HANDLED
		
	new szSenderName[32], szReceiverName[32]
	get_user_name(id, szSenderName, charsmax(szSenderName))
	get_user_name(g_iTarget[id], szReceiverName, charsmax(szReceiverName))

	ColorChat(id, GREY, "[GG]^4 Private Message To^3 %s^1: %s", szReceiverName, say)
	ColorChat(g_iTarget[id], GREY, "[GG]^4 Private Message From^3 %s^1: %s", szSenderName, say)

	g_iTarget[id] = 0;
    
	return PLUGIN_CONTINUE
}
