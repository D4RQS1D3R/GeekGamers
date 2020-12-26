#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <fakemeta>

new vip_kills1, vip_kills2, vip_kills3;
new expir_day[33] = 0, expir_month[33] = 0, expir_year[33] = 0;
new bool: is_admin[33], bool: is_vip[33];
new bool: first_time[33];
new bool: claimed_vip_kills1[33], bool: claimed_vip_kills2[33], bool: claimed_vip_kills3[33];

native FreeVIP(id);

public plugin_init()
{
	register_plugin("[GG] Free VIP Score/Map", "1.0", "D4RQS1D3R");

	register_clcmd("say /vip", "ChatMsgID");
	register_clcmd("say /free", "ChatMsgID");
	register_clcmd("say /freevip", "ChatMsgID");
	register_clcmd("say freevip", "ChatMsgID");
	register_clcmd("freevip", "ChatMsgID");

	RegisterHam(Ham_Killed, "player", "EventDeathMsg");

	vip_kills1 = register_cvar("amx_freevip_kills1", "130");
	vip_kills2 = register_cvar("amx_freevip_kills2", "220");
	vip_kills3 = register_cvar("amx_freevip_kills3", "320");

	set_task(600.0, "ChatMsg", _, _, _, "b");
}

public EventDeathMsg(const iVictim, const iKiller)
{
	if(!iKiller || !is_user_connected(iKiller))
		return;
	
	if(iKiller == iVictim)
		return;
	
	if(get_user_frags(iKiller) + 1 == get_pcvar_num(vip_kills1) && !claimed_vip_kills1[iKiller])
	{
		CheckPlayerAccess(iKiller, "t");

		if(is_admin[iKiller])
			return;

		new name[32];
		get_user_name(iKiller, name, 31);

		new configdir[200], holder[200];
		get_configsdir(configdir, 199);
		format(configdir, 199, "%s/auto-admins.ini", configdir);
		
		if(file_exists(configdir))
		{
			if(!is_vip[iKiller])
			{
				new Year[32], Month[32], Day[32];
				get_time("%Y", Year, 31);
				get_time("%m", Month, 31);
				get_time("%d", Day, 31);
				new YearsNum = str_to_num(Year), MonthsNum = str_to_num(Month), DaysNum = str_to_num(Day);
				
				if( FreeVIP(iKiller) )
				{
					if(DaysNum+10 > 30)
					{
						DaysNum -= 20;

						if(MonthsNum+1 > 12)
						{
							MonthsNum = 01;
							YearsNum ++;
						}
						else MonthsNum ++;
					}
					else DaysNum += 10;

					formatex(holder, charsmax(holder), "^"%s^" ^"^" ^"t^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, DaysNum, MonthsNum, YearsNum);
					write_file(configdir, holder, -1);

					remove_user_flags(iKiller, read_flags("z"));
					set_user_flags(iKiller, read_flags("t"));

					set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
					show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ 10 days ]=-", get_user_frags(iKiller) + 1);

					ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g10 days!t)", get_user_frags(iKiller) + 1);

					ScreenFade(iKiller);

					claimed_vip_kills1[iKiller] = true;

					return;
				}
				else
				{
					if(MonthsNum+1 > 12)
					{
						MonthsNum -= 11;
						YearsNum ++;
					}
					else MonthsNum ++;

					formatex(holder, charsmax(holder), "^"%s^" ^"^" ^"t^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, DaysNum, MonthsNum, YearsNum);
					write_file(configdir, holder, -1);

					remove_user_flags(iKiller, read_flags("z"));
					set_user_flags(iKiller, read_flags("t"));

					set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
					show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ 1 month ]=-", get_user_frags(iKiller) + 1);

					ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g1 month!t)", get_user_frags(iKiller) + 1);

					ScreenFade(iKiller);

					first_time[iKiller] = true;
					claimed_vip_kills1[iKiller] = true;

					return;
				}
			}
			else
			{
				new line = 0, linetext[255], linetextlength;
				while((line = read_file(configdir, line, linetext, 256, linetextlength)))
				{
					if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
					{
						continue;
					}

					new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
					parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);

					if( !equali(p_login, name) || !equali(p_access, "t") )
						continue;
					
					if(expir_day[iKiller]+10 > 30)
					{
						expir_day[iKiller] -= 20;

						if(expir_month[iKiller]+1 > 12)
						{
							expir_month[iKiller] = 01;
							expir_year[iKiller] ++;
						}
						else expir_month[iKiller] ++;
					}
					else expir_day[iKiller] += 10;

					formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"t^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, expir_day[iKiller], expir_month[iKiller], expir_year[iKiller]);
					write_file(configdir, linetext, line - 1);

					remove_user_flags(iKiller, read_flags("z"));
					set_user_flags(iKiller, read_flags("t"));

					set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
					show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ +10 days ]=-", get_user_frags(iKiller) + 1);

					ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g+10 days!t)", get_user_frags(iKiller) + 1);

					ScreenFade(iKiller);

					claimed_vip_kills1[iKiller] = true;

					return;
				}

				if(expir_day[iKiller]+10 > 30)
				{
					expir_day[iKiller] -= 20;

					if(expir_month[iKiller]+1 > 12)
					{
						expir_month[iKiller] = 01;
						expir_year[iKiller] ++;
					}
					else expir_month[iKiller] ++;
				}
				else expir_day[iKiller] += 10;
				
				formatex(holder, charsmax(holder), "^"%s^" ^"^" ^"t^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, expir_day[iKiller], expir_month[iKiller], expir_year[iKiller]);
				write_file(configdir, holder, -1);
				
				remove_user_flags(iKiller, read_flags("z"));
				set_user_flags(iKiller, read_flags("t"));

				set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
				show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ +10 days ]=-", get_user_frags(iKiller) + 1);

				ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g+10 days!t)", get_user_frags(iKiller) + 1);

				ScreenFade(iKiller);

				claimed_vip_kills1[iKiller] = true;

				return;
			}
		}
	}
	
	if( (get_user_frags(iKiller) + 1 == get_pcvar_num(vip_kills2) && !claimed_vip_kills2[iKiller]) || (get_user_frags(iKiller) + 1 == get_pcvar_num(vip_kills3) && !claimed_vip_kills3[iKiller]) )
	{
		CheckPlayerAccess(iKiller, "t");
		
		new name[32];
		get_user_name(iKiller, name, 31);

		new configdir[200];
		get_configsdir(configdir, 199);
		format(configdir, 199, "%s/auto-admins.ini", configdir);
		
		if(file_exists(configdir))
		{
			new line = 0, linetext[255], linetextlength;
			while((line = read_file(configdir, line, linetext, 256, linetextlength)))
			{
				if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
				{
					continue;
				}

				new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
				parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);

				if( !equali(p_login, name) )
					continue;

				if( equali(p_login, name) && !equali(p_access, "t") )
					break;

				new day = str_to_num(p_day);
				new month = str_to_num(p_month);
				new year = str_to_num(p_year);

				if( first_time[iKiller] )
				{
					if(month+1 > 12)
					{
						month -= 11;
						year ++;
					}
					else month ++;
				}
				else
				{
					if(day+10 > 30)
					{
						day -= 20;

						if(month+1 > 12)
						{
							month = 01;
							year ++;
						}
						else month ++;
					}
					else day += 10;
				}

				formatex(linetext, charsmax(linetext), "^"%s^" ^"^" ^"t^" ^"e^" ^"^" ^"^" ^"%d^" ^"%d^" ^"%d^"", name, day, month, year);
				write_file(configdir, linetext, line - 1);

				remove_user_flags(iKiller, read_flags("z"));
				set_user_flags(iKiller, read_flags("t"));

				if( first_time[iKiller] )
				{
					set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
					show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ +1 month ]=-", get_user_frags(iKiller) + 1);

					ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g+1 month!t)", get_user_frags(iKiller) + 1);
				}
				else
				{
					set_dhudmessage(0, 0, 255, -1.0, 0.28, 0, 0.0, 3.0, 0.2, 0.2);
					show_dhudmessage(iKiller, ".:[Free-VIP]:.^nYou got a Free V.I.P for reaching !t%d kills^n-=[ +10 days ]=-", get_user_frags(iKiller) + 1);

					ChatColor(iKiller, "!g[!tGG!g][!tFree-VIP!g] !nYou got rewarded !gFree access to !gV.I.P Weapons/Knives !nfor reaching !t%d kills !non this map !t(!g+10 days!t)", get_user_frags(iKiller) + 1);
				}

				ScreenFade(iKiller);

				if(get_user_frags(iKiller) + 1 == get_pcvar_num(vip_kills2) && !claimed_vip_kills2[iKiller])
					claimed_vip_kills2[iKiller] = true;
				else
				if(get_user_frags(iKiller) + 1 == get_pcvar_num(vip_kills3) && !claimed_vip_kills3[iKiller])
					claimed_vip_kills3[iKiller] = true;
			}
		}
	}
}

public CheckPlayerAccess(id, access[])
{
	is_admin[id] = false;
	is_vip[id] = false;

	new name[32];
	get_user_name(id, name, 31);
	
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

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				is_admin[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;
			
			is_vip[id] = true;

			if(equal(p_year, ""))
			{
				new Years[32];
				get_time("%Y", Years, 31);

				p_year = Years;
			}

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	
	new configdir2[200];
	get_configsdir(configdir2, 199);
	format(configdir2, 199, "%s/manager/users.ini", configdir2);
	
	if(file_exists(configdir2))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir2, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				is_admin[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;

			is_vip[id] = true;

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	
	new configdir3[200];
	get_configsdir(configdir3, 199);
	format(configdir3, 199, "%s/auto-admins.ini", configdir3);
	
	if(file_exists(configdir3))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir3, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new p_login[32], p_passwd[32], p_access[32], p_flag[32], p_setinfo[32], p_setpw[32], p_day[32], p_month[32], p_year[32];
			parse(linetext, p_login, 31, p_passwd, 31, p_access, 31, p_flag, 31, p_setinfo, 31, p_setpw, 31, p_day, 31, p_month, 31, p_year, 31);
			
			if( equali(p_login, name) && (strlen(p_access) > strlen(access) || equal(p_day, "") || equal(p_month, "")) )
			{
				is_admin[id] = true;
				return PLUGIN_HANDLED;
			}
			
			if( !equali(p_login, name) || !equali(p_access, access) )
				continue;

			is_vip[id] = true;

			if( expir_day[id] >= str_to_num(p_day) && expir_month[id] >= str_to_num(p_month) && expir_year[id] >= str_to_num(p_year) )
				continue;
			
			expir_day[id] = str_to_num(p_day);
			expir_month[id] = str_to_num(p_month);
			expir_year[id] = str_to_num(p_year);
		}
	}
	return PLUGIN_CONTINUE;
}

public ChatMsg()
{
	new iPlayers[32], iNum;
	get_players( iPlayers, iNum, "ch" );

	for( new i = 0 ; i < iNum ; i++ )
	{
		new id = iPlayers[i];

		ChatMsgID(id);
	}
}

public ChatMsgID(id)
{
	CheckPlayerAccess(id, "t");
	
	if( is_admin[id] )
		return;
	
	if( first_time[id] )
	{
		ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g1 month!t)", get_pcvar_num(vip_kills1));
		ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g2 months!t)", get_pcvar_num(vip_kills2));
		ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g3 months!t)", get_pcvar_num(vip_kills3));
	}
	else
	{
		if( FreeVIP(id) )
		{
			ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g+10 days!t)", get_pcvar_num(vip_kills1));
			ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g+20 days!t)", get_pcvar_num(vip_kills2));
			ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g+30 days!t)", get_pcvar_num(vip_kills3));
		}
		else
		{
			if( is_vip[id] )
			{
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess to VIP Weapons/Knives !t(!g+10 days!t)", get_pcvar_num(vip_kills1));
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess to VIP Weapons/Knives !t(!g+20 days!t)", get_pcvar_num(vip_kills2));
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess to VIP Weapons/Knives !t(!g+30 days!t)", get_pcvar_num(vip_kills3));
			}
			else
			{
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess to VIP Weapons/Knives !t(!g1 month!t)", get_pcvar_num(vip_kills1));
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g2 months!t)", get_pcvar_num(vip_kills2));
				ChatColor(id, "!g[!tGG!g][!tFree-VIP!g] !n%d kills on a single map !t= !nAccess VIP Weapons/Knives !t(!g3 months!t)", get_pcvar_num(vip_kills3));
			}
		}
	}
}

public ScreenFade(id)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<12);
	write_short(1);
	write_short(0x0000)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	write_byte(75)
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