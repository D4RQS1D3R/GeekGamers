#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fcs>

#include <fun>
#include <fvault>

#pragma compress 1

#define PLUGIN "[GG] Credits Bank Menu"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

#pragma dynamic 32768
#define is_valid_player(%1) (1 <= %1 <= 32)

#define NICK

new g_credits[33]
new players_menu, players[32], num, i
new accessmenu, iName[64], callback

public plugin_init()
{
	register_plugin("PLUGIN", "VERSION", "AUTHOR")

	register_clcmd("bank", "Bank_Menu")
	register_clcmd("say /bank", "Bank_Menu")
	register_clcmd("say bank", "Bank_Menu")
	register_clcmd("say_team /bank", "Bank_Menu")

	register_clcmd("TakeCredits", "CmdTakeCredits")
	register_clcmd("SaveCredits", "CmdSaveCredits")

	register_clcmd("say /transfercredits", "Transfer_Credits")
	register_clcmd("say transfercredits", "Transfer_Credits")
	register_clcmd("DonateBankCredits", "Transfer_Credits_Msg")
}

public client_putinserver(id)
{
	set_task(0.1, "LoadData", id);
}

public client_disconnect(id)
{
	set_task(0.1, "SaveData", id);
}

public Bank_Menu(id)
{
	if(is_valid_player(id))
	{
		new title[100]
		formatex(title, 99, "\d[\yGeek~Gamers\d] \rCredits \yBank Menu^n\rYour Have:\y %d Credits", g_credits[id])
		new BankMenu = menu_create(title, "menuBankHandler")

		menu_additem(BankMenu, "\wTake \yCredits", "1")
		menu_additem(BankMenu, "\wTake All \yCredits^n", "2")

		menu_additem(BankMenu, "\wSave \yCredits", "3")
		menu_additem(BankMenu, "\wSave All \yCredits^n", "4")

		menu_additem(BankMenu, "\rDonate \yCredits \wFrom Your Bank^n", "5")

		menu_display(id, BankMenu, 0)
	}
	return PLUGIN_HANDLED;
}  

public menuBankHandler(id, menu, item)
{
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)

	new key = str_to_num(data)

	switch(key)
	{
		case 1: client_cmd(id, "messagemode TakeCredits")
		case 2: cmdTakeAll(id)
		case 3: client_cmd(id, "messagemode SaveCredits")
		case 4: cmdSaveAll(id)
		case 5: client_cmd(id, "donatecredits")
	}
}

public CmdTakeCredits(id)  
{
	new szCredits[11]
	read_args(szCredits, 10)
	remove_quotes(szCredits)

	if(equal(szCredits, "") || equal(szCredits, " "))
		return PLUGIN_HANDLED

	new iCredits = str_to_num(szCredits)

	if(iCredits < 1) return PLUGIN_HANDLED

	new iCreditsSum = iCredits + fcs_get_user_credits(id)

	if(iCredits <= g_credits[id])
	{
		fcs_set_user_credits(id, iCreditsSum)
		g_credits[id] -= iCredits
		ChatColor(id, "!g[GG] !nYou Took !t%i !nCredits from Your Bank. Now You Have !t%i !nCredits in Your Bank.", iCredits, g_credits[id])
		SaveData(id)

		return PLUGIN_CONTINUE
	}
	else
	{
		ChatColor(id, "!g[GG] !nYou Don't Have Enough !tCredits!n.")
	}
	return PLUGIN_CONTINUE
}

public cmdTakeAll(id)
{
	if( g_credits[id] <= 0)
		return PLUGIN_HANDLED

	if(g_credits[id] > 0)
	{
		new iCreditsSum = fcs_get_user_credits(id) + g_credits[id]
		fcs_set_user_credits(id, iCreditsSum)
		ChatColor(id, "!g[GG] !nYou Took All Your !t%i !nCredits from Your Bank.", g_credits[id])
		g_credits[id] = 0
		SaveData(id)
	}
	return PLUGIN_CONTINUE
}

public CmdSaveCredits(id)  
{
	new szCredits[11]  
	read_args(szCredits, 10)  
	remove_quotes(szCredits)  
      
	if(equal(szCredits, "") || equal(szCredits, " "))  
		return PLUGIN_HANDLED

	new iCredits = str_to_num(szCredits)

	if(iCredits < 1) return PLUGIN_HANDLED

	new Credits = fcs_get_user_credits(id)

	if(iCredits <= Credits)
	{
		fcs_set_user_credits(id, Credits - iCredits)
		g_credits[id] += iCredits
		ChatColor(id, "!g[GG] !nYou Saved !t%i !nCredits in Your Bank. Now You Have !t%i !nCredits in Your Bank.", iCredits, g_credits[id])
		SaveData(id)
	}
	else
	{
		ChatColor(id, "!g[GG] !nYou Don't Have Enough Credits")
	}
	return PLUGIN_CONTINUE
}  

public cmdSaveAll(id)
{
	new Credits = fcs_get_user_credits(id)

	if( Credits <= 0)
		return PLUGIN_HANDLED

	if(Credits > 0)
	{
		fcs_set_user_credits(id, 0)
		g_credits[id] += Credits
		ChatColor(id, "!g[GG] !nYou Saved All Your !t%i !nCredits in Your Bank. Now You Have !t%i !nCredits in Your Bank.", Credits, g_credits[id])
		SaveData(id)
	}
	return PLUGIN_CONTINUE
}

public Transfer_Credits(id)
{
	get_players(players, num, "ch")
	if (num <= 1)
	{
		ChatColor(id, "!g[GG] !nThere are no !tPlayers !nin The Server !g!")
		return PLUGIN_HANDLED
	}

	new tempname[32], info[10]
	new temp[101]

	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rDonate Credits from Your Bank^nYour Have:\y %d Credits", g_credits[id] )
	players_menu = menu_create(temp, "Transfer_Credits_Handler")

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

public Transfer_Credits_Handler(id, players_menu, item)
{ 
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu)
		return PLUGIN_HANDLED
	}
   
	new data[6]  
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback) 

	new player = str_to_num(data)      
	client_cmd(id, "messagemode ^"DonateBankCredits %i^"", player)
	return PLUGIN_CONTINUE
}

public Transfer_Credits_Msg(id)
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
	new money = g_credits[id] - str_to_num(param)

	if ( g_credits[id] < amount )
	{   	          
		ChatColor(id, "!g[GG] !nYou Don't Have !tEnough !nCredits !g!")
		return 0
	}

	read_argv(1, param, charsmax(param))
	new player = str_to_num(param)
	new player_money = fcs_get_user_credits(player) + amount

	if( player == id)
		return PLUGIN_HANDLED

	g_credits[id] = money
	fcs_set_user_credits(player, player_money)
   
	new names[2][32]
	get_user_name(id, names[0], 31)
	get_user_name(player, names[1], 31)

	if( amount == 0)
		return PLUGIN_HANDLED

	ChatColor(id, "!g[GG] !nYou Donated !t%d Credits !nTo !g%s!n. Now You Have !t%d Credits !nin Your Bank !g!", amount, names[1], money)
	ChatColor(player, "!g[GG] !nPlayer !g%s !nDonated !t%d Credits !nTo !tYou!n. Now You Have !t%d Credits !g!", names[0], amount, player_money)

	SaveData(id)

	return 0
}

public SaveData(id)    
{    
	new szMethod[ 65 ];
       
	#if defined STEAM
	get_user_authid( id, szMethod, 34 );
	#endif
       
	#if defined NICK
	get_user_name( id, szMethod, 34 );
	#endif
       
	#if defined IP
	get_user_ip( id, szMethod, 34, 1 );
	#endif
       
	new vaultkey[64], vaultdata[328];
	format(vaultkey, 63, "%s", szMethod);
	format(vaultdata, 327, "%i", g_credits[id]);
       
	fvault_set_data( "gg-bank", vaultkey, vaultdata );
}

public LoadData(id)    
{
	new szMethod[ 65 ];

	#if defined STEAM
	get_user_authid( id, szMethod, 34 );
	#endif

	#if defined NICK
	get_user_name( id, szMethod, 34 );
	#endif

	#if defined IP
	get_user_ip( id, szMethod, 34, 1 );
	#endif

	new vaultkey[64], vaultdata[328];
	format(vaultkey, 63, "%s", szMethod);
	format(vaultdata, 327, "%i", g_credits[id]);

	fvault_get_data( "gg-bank", vaultkey, vaultdata, charsmax( vaultdata ) );

	g_credits[ id ] = str_to_num( vaultdata );
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