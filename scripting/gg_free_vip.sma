#include <amxmodx>
#include <amxmisc>
#include <unixtime>

#pragma compress 1

new bool: freevip;

new freevipmod;
new startfreevip;
new endfreevip;

new endfreevipday;
new endfreevipmonth;
new endfreevipyear;

new const name_file[] = "hostname.ini"

new server_names[100][180], num_of_names, current_name

native bool: HC_FreeVIP(id);

public plugin_init()
{
	register_plugin("[GG] Free V.I.P", "1.0", "~DarkSiDeRs~");

	freevipmod = register_cvar("amx_freevip", "1");

	startfreevip = register_cvar("amx_start_freevip", "22");
	endfreevip = register_cvar("amx_end_freevip", "10");

	endfreevipday = register_cvar("amx_end_freevip_day", "");
	endfreevipmonth = register_cvar("amx_end_freevip_month", "");
	endfreevipyear = register_cvar("amx_end_freevip_year", "");

	read_names()
	set_task(0.1, "Check", _, _, _, "b");
}

public plugin_natives()
{
	register_native("FreeVIP", "native_freevip", 1);
}

public client_putinserver(id)
{
	set_task( 1.0, "ShowHud", id, _, _, "b" );
}

public read_names()
{
	new configsdir[64], dir[132]
	get_configsdir(configsdir, 63)
	
	format(dir, 131, "%s/%s", configsdir, name_file)
	new file = fopen(dir, "rt")
	
	if(!file)
	{
		server_print("Could not find the %s file", name_file)
		return PLUGIN_CONTINUE
	}
	
	new text[180]
	
	while(!feof(file))
	{
		fgets(file, text, 179)
		
		if( (strlen(text) < 2) || (equal(text, "//", 2)) )
		continue;
		
		num_of_names++
		server_names[num_of_names] = text
		
		server_print("%s", server_names[num_of_names])
	}
	
	fclose(file)
	server_print("Successfully added %d server names", num_of_names)
	
	return PLUGIN_CONTINUE
}

public Check()
{
	new iPlayers[32], iNum;
/*
	new year[3];
	get_time("%Y", year, 2);
	new n_year = str_to_num(year);

	new month[3];
	get_time("%m", month, 2);
	new n_month = str_to_num(month);

	new day[3];
	get_time("%d", day, 2);
	new n_day = str_to_num(day);
*/
	new hour[3];
	get_time("%H", hour, 2);
	new n_hour = str_to_num(hour);

	new minute[3];
	get_time("%M", minute, 2);
	new n_minute = str_to_num(minute);

	new second[3];
	get_time("%S", second, 2);
	new n_second = str_to_num(second);

	if(get_pcvar_num(freevipmod) == 1)
	{
		if( n_hour == get_pcvar_num(startfreevip) && n_minute == 00 && n_second == 00 )
		{
			get_players(iPlayers, iNum, "c");
			for(new i = 0; i < iNum; i++)
			{
				new Players = iPlayers[ i ];

				remove_user_flags(Players, read_flags("z"));
				set_user_flags(Players, read_flags("t"));
			}
		}
	}

	if(current_name + 1 > num_of_names)
		current_name = 0
	
	current_name++

	switch( get_pcvar_num(freevipmod) )
	{
		case 0:
		{
			server_cmd("hostname ^"%s^"", server_names[current_name]);
			server_cmd("amx_default_access z");
			freevip = false;
		}
		case 1:
		{
			new EndTime = TimeToUnix(get_pcvar_num(endfreevipyear), get_pcvar_num(endfreevipmonth), get_pcvar_num(endfreevipday), 0, 0, 0);
			if(get_systime() < EndTime)
			{
				server_cmd("hostname ^"%s .:[Free V.I.P]:.^"", server_names[current_name]);
				server_cmd("amx_default_access t");
				freevip = true;
			}
			else
			{
				if( get_pcvar_num(startfreevip) <= n_hour <= 23 || 00 <= n_hour < get_pcvar_num(endfreevip) )
				{
					server_cmd("hostname ^"%s .:[Free V.I.P]:.^"", server_names[current_name]);
					server_cmd("amx_default_access t");
					freevip = true;
				}
				else
				if( get_pcvar_num(startfreevip) > n_hour >= get_pcvar_num(endfreevip) )
				{
					server_cmd("hostname ^"%s^"", server_names[current_name]);
					server_cmd("amx_default_access z");
					freevip = false;
				}
			}
		}
		case 2:
		{
			server_cmd("hostname ^"%s .:[Free V.I.P]:.^"", server_names[current_name]);
			server_cmd("amx_default_access t");
			freevip = true;
		}
	}

	return PLUGIN_HANDLED;
}

public ShowHud(id)
{
	if(!HC_FreeVIP(id))
		return;
/*
	new year[3];
	get_time("%Y", year, 2);
	new n_year = str_to_num(year);

	new month[3];
	get_time("%m", month, 2);
	new n_month = str_to_num(month);

	new day[3];
	get_time("%d", day, 2);
	new n_day = str_to_num(day);
*/
	new hour[3];
	get_time("%H",hour,2);
	new n_hour = str_to_num(hour);

	switch( get_pcvar_num(freevipmod) )
	{
		case 1:
		{
			new EndTime = TimeToUnix(get_pcvar_num(endfreevipyear), get_pcvar_num(endfreevipmonth), get_pcvar_num(endfreevipday), 0, 0, 0);
			if(get_systime() < EndTime)
			{
				set_dhudmessage(0, 128, 255, -1.0, 0.02, 0, 0.0, 5.0, 1.0, 1.0);
				show_dhudmessage(id, ".:[Free V.I.P]:.^nFree VIP for all Enjoy Playing !^nEnds the %d/%d/%d at 00:00 GMT", get_pcvar_num(endfreevipday)+1, get_pcvar_num(endfreevipmonth), get_pcvar_num(endfreevipyear) );
			}
			else
			{
				if( 23 >= n_hour >= get_pcvar_num(startfreevip) || get_pcvar_num(endfreevip) > n_hour >= 00 )
				{
					set_dhudmessage(0, 128, 255, -1.0, 0.02, 0, 0.0, 5.0, 1.0, 1.0);
					show_dhudmessage(id, ".:[Free V.I.P]:.^nFree VIP for all Enjoy Playing !^nEnds at %d:00 GMT", get_pcvar_num(endfreevip) );
				}
				else
				if( get_pcvar_num(startfreevip) > n_hour >= get_pcvar_num(endfreevip) )
				{
					set_dhudmessage(0, 255, 0, -1.0, 0.02, 0, 0.0, 5.0, 1.0, 1.0);
					show_dhudmessage(id, ".:[Free V.I.P]:.^nStarting From %d:00 GMT To %d:00 GMT", get_pcvar_num(startfreevip), get_pcvar_num(endfreevip) );
				}
			}
		}
		case 2:
		{
			set_dhudmessage(0, 128, 255, -1.0, 0.02, 0, 0.0, 5.0, 1.0, 1.0);
			show_dhudmessage(id, ".:[Free V.I.P]:.^nFree VIP for all Enjoy Playing !");
		}
	}
}

public native_freevip(id)
{
	return freevip;
}
