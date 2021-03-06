#include <amxmodx>
#include <cstrike>
#include <colorchat>

#pragma compress 1

#pragma tabsize 0

new players_menu, players[32], num, i
new accessmenu, iName[64], callback

public plugin_init()
{
	register_plugin("[GG] Donate Money", "0.0.2", "~DarkSiDeRS~")

	register_clcmd("say /donate", "Transfer_Money")
	register_clcmd("say /give", "Transfer_Money")

	register_clcmd("DonateMoney", "Transfer_Money_Msg")
}

///** ---------------------------------------- [ Donate Money ] ----------------------------------------------- **///

public Transfer_Money(id)
{ 
	get_players(players, num, "ch")       
	if (num <= 1)
	{   	    
		ColorChat(id, TEAM_COLOR, "^4[GG] ^1There are no ^3Players ^1in The Server ^4!")      
		return PLUGIN_HANDLED    
	}   
    
	new tempname[32], info[10]  
	new Temp[101], money = cs_get_user_money(id)

	formatex(Temp,100, "\d[\yGeek~Gamers\d] \rChoose a Player To Donate Money^nYour Money:\y %d$", money)
	players_menu = menu_create(Temp, "Transfer_Money_Handler")
 
	for(i = 0; i < num; i++)
	{   	    
		if(players[i] == id)           
			continue

		get_user_name(players[i], tempname, 31)       
		num_to_str(players[i], info, 9)       
		menu_additem(players_menu, tempname, info, 0)   
	}  
		 
	menu_setprop(players_menu, MPROP_EXIT, MEXIT_ALL)  
	menu_display(id, players_menu, 0)   
	return PLUGIN_CONTINUE
}

public Transfer_Money_Handler(id, players_menu, item)
{ 
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu)
		return PLUGIN_HANDLED
	}
   
	new data[6]
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback)

	new player = str_to_num(data)
	client_cmd(id, "messagemode ^"DonateMoney %i^"", player)

	menu_destroy(players_menu)
	return PLUGIN_HANDLED
}

public Transfer_Money_Msg(id)
{   	 
	new param[6]    
	read_argv(2, param, charsmax(param))

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0       
 		}  
	}    
   
	new amount = str_to_num(param)
	new money = cs_get_user_money(id) - str_to_num(param)

	if( amount <= 0)
		return 0

	if( cs_get_user_money(id) < amount )
	{   	          
		ColorChat(id, TEAM_COLOR, "^4[GG] ^1You Don't Have ^3Enough ^1Money ^4!")
		return 0   
	}

	read_argv(1, param, charsmax(param))
	new player = str_to_num(param)
	new player_money = cs_get_user_money(player) + amount

	if( player == id )
		return 0

	cs_set_user_money(id, money)
	cs_set_user_money(player, player_money)

	new names[2][32]
	get_user_name(id, names[0], 31)
	get_user_name(player, names[1], 31)

	ColorChat(id, TEAM_COLOR, "^4[GG] ^1You Donated ^3%d$ ^1To ^4%s^1. Now You Have ^3%d$ ^4!", amount, names[1], money)
	ColorChat(player, TEAM_COLOR, "^4[GG] ^1Player ^4%s ^1Donated ^3%d$ To ^3You^1. Now You Have ^3%d$ ^4!", names[0], amount, player_money)

	return 0
}
