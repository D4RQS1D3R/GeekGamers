#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#pragma compress 1

#define OWNER_LEVEL ADMIN_LEVEL_C

new amx_password_field;
new mic;
new restared;
new max_restarts;

new expir_day[33] = 0, expir_month[33] = 0, expir_year[33] = 0, days_remaining[33] = 0;

native bool: modstarted(id);

public plugin_init()
{
	register_plugin("[GG] Admin Menu", "1.0", "~D4rkSiD3Rs~");

	register_clcmd("amenu", "AdminMenu", ADMIN_KICK, "");
	register_clcmd("adminmenu", "AdminMenu", ADMIN_KICK, "");
	register_clcmd("say amenu", "AdminMenu", ADMIN_KICK, "");
	register_clcmd("say adminmenu", "AdminMenu", ADMIN_KICK, "");
	register_clcmd("say /amenu", "AdminMenu", ADMIN_KICK, "");
	register_clcmd("say /adminmenu", "AdminMenu", ADMIN_KICK, "");

	register_clcmd("say /rr", "rs", ADMIN_BAN, "");
	register_clcmd("say /restartround", "rs", ADMIN_BAN, "");

	amx_password_field = register_cvar("amx_password_field", "_pw");
	max_restarts = register_cvar("amx_max_restarts", "3");
}

public client_connect(id)
{
	Setinfo(id);
}

public Setinfo(id)
{
	new passfield[32];
	get_pcvar_string(amx_password_field, passfield, 31);

	force_cmd(id, "setinfo %s ^"^"", passfield);
	force_cmd(id, "setinfo %s ^"Geek-Gamers.com^"", passfield);
}

public plugin_precache()
{
	precache_sound("[GeekGamers]/mic_activated.wav");
	precache_sound("[GeekGamers]/mic_muted.wav");

	return PLUGIN_CONTINUE;
}

public AdminMenu(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
		return PLUGIN_HANDLED;

	GetExpirationDate(id);
	new temp[101], InfoStatus[198], InfoStatus2[198];

	if(!expir_day[id] || !expir_month[id])
	{
		formatex(temp, 100, "\d[\yGeek~Gamers\d] \rAdmin Menu^nExpiration Date: \y-");
	}
	else
	{
		formatex(temp, 100, "\d[\yGeek~Gamers\d] \rAdmin Menu^nExpiration Date: \y%d\w/\y%d\w/\y%d (~\r%d day%s left\y)", expir_day[id], expir_month[id], expir_year[id], days_remaining[id], days_remaining[id] > 1 ? "s" : "");
	}

	new menu = menu_create(temp, "AdminMenuMenuHandler");

	menu_additem(menu, "\rAMX\w-\rMOD\w-\rMENU^n", "", ADMIN_KICK);

	menu_additem(menu, "\yMake \rFurien\y/\rAnti-Furien", "", ADMIN_BAN);
	menu_additem(menu, "\wRevive \rMenu^n", "", ADMIN_KICK);

	menu_additem(menu, "\yKick \rMenu", "", ADMIN_KICK);
	menu_additem(menu, "\wBan \rMenu", "", ADMIN_BAN);
	menu_additem(menu, "\yUnBan \rMenu^n", "", ADMIN_BAN);

	formatex(InfoStatus, charsmax(InfoStatus), "\wMic is \y: \d[%s\d]", mic ? "\yON" : "\rOFF");
	menu_additem(menu, InfoStatus, "1", ADMIN_KICK);
	formatex(InfoStatus2, charsmax(InfoStatus2), "\rRestart \yRound \r[\y%d\r/\y%d\r]", restared, get_pcvar_num(max_restarts));
	menu_additem(menu, InfoStatus2, "2", ADMIN_BAN);

	menu_addblank(menu, 1);
	menu_additem(menu, "Exit", "MENU_EXIT");

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public AdminMenuMenuHandler(id, menu, item)
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
		case 0: force_cmd(id, "amxmodmenu");
		case 1: force_cmd(id, "say /make");
		case 2: force_cmd(id, "say /revive");
		case 3: force_cmd(id, "amx_kickmenu");
		case 4: force_cmd(id, "amx_banmenu");
		case 5: force_cmd(id, "amx_unbanmenu");
		case 6: micro(id);
		case 7: rs(id);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public micro(id)
{
	static szName[32];
	get_user_name(id, szName, 33)

	mic = !mic

	if(mic)
	{
		set_cvar_string("sv_voicecodec", "voice_speex");
		set_cvar_num("sv_voiceenable", 1);
		set_cvar_num("sv_voicequality", 5);
		set_cvar_num("sv_alltalk", 1);
		client_cmd(0, "spk ^"[GeekGamers]/mic_activated^"");
		ChatColor(0, "!g[GG] !n%s !t%s !nTurn The Mic : !g[ON]", szName, get_user_flags(id) & OWNER_LEVEL ? "OWNER" : "ADMIN");
		AdminMenu(id);
	}
	else
	{
		set_cvar_string("sv_voicecodec", "voice_speex");
		set_cvar_num("sv_voiceenable", 0);
		set_cvar_num("sv_voicequality", 0);
		set_cvar_num("sv_alltalk", 0);
		client_cmd(0, "spk ^"[GeekGamers]/mic_muted^"");
		ChatColor(0, "!g[GG] !n%s !t%s !nTurn The Mic : !g[OFF]", szName, get_user_flags(id) & OWNER_LEVEL ? "OWNER" : "ADMIN");
		AdminMenu(id);
	}
}
	
public rs(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
		return PLUGIN_HANDLED;

	if( modstarted(id) )
		return PLUGIN_HANDLED;

	if(restared >= get_pcvar_num(max_restarts))
		return PLUGIN_HANDLED;

	static szName[32];
	get_user_name(id, szName , 33)
	set_cvar_num("sv_restartround", 1);
	restared ++;

	ChatColor(0, "!g[GG][Restart-Round] !n%s !t%s !nRestart The Round !t!", get_user_flags(id) & OWNER_LEVEL ? "OWNER" : "ADMIN", szName);

	return PLUGIN_CONTINUE;
}

public GetExpirationDate(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
		return;
		
	new Days[32], Months[32], Years[32];
	get_time("%m", Months, 31);
	get_time("%d", Days, 31);
	get_time("%Y", Years, 31);
	new Day = str_to_num(Days), Month = str_to_num(Months), Year = str_to_num(Years);
	
	new name[32], authid[32], ip[32];
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_user_ip(id, ip, 31);

	new configdir[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/users.ini", configdir);

	if(file_exists(configdir))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
					
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}

				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
	}

	new configdir2[200];
	get_configsdir(configdir2, 199);
	format(configdir2, 199, "%s/auto-admins.ini", configdir2);

	if(file_exists(configdir2))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir2, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
			
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}
				
				if( expir_day[id] >= str_to_num(expiration_day) && expir_month[id] >= str_to_num(expiration_month) && expir_year[id] >= str_to_num(expiration_year) )
					continue;
				
				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
	}

	new configdir3[200];
	get_configsdir(configdir3, 199);
	format(configdir3, 199, "%s/manager/users.ini", configdir3);
	
	if(file_exists(configdir3))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir3, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
			
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}
				
				if( expir_day[id] >= str_to_num(expiration_day) && expir_month[id] >= str_to_num(expiration_month) && expir_year[id] >= str_to_num(expiration_year) )
					continue;
				
				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
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