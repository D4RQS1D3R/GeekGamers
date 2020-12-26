#include <amxmodx>
#include <amxmisc>

#pragma compress 1

#define PLUGIN "[GG] Black List"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public client_authorized(id)
{
	client_check(id);
}

public client_infochanged(id)
{
	client_check(id);
}

public client_check(id)
{
	new configdir[200];
	get_configsdir(configdir, 199);

	format(configdir, 199, "%s/gg_blacklist.ini", configdir);

	new line = 0;
	new linetextlength = 0;
	new linetext[512];

	new name[32], steamid[32], ip[32];

	get_user_name(id, name, charsmax(name));
	get_user_authid(id, steamid, charsmax(steamid));
	get_user_ip(id, ip, charsmax(ip));

	new user[32], kicktype[32], bantype[32], banduration[32], reason[64];

	if(file_exists(configdir))
	{
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			parse(linetext, user, charsmax(user),
					kicktype, charsmax(kicktype),
					bantype, charsmax(bantype),
					banduration, charsmax(banduration),
					reason, charsmax(reason) );

			if(equali(user, name) || equali(user, steamid) || equali(user, ip))
			{
				if(equali(kicktype, "kick") || equali(kicktype, "1"))
				{
					server_cmd("kick #%d ^"%s^"", get_user_userid(id), reason);
					break;
				}
				else
				if(equali(kicktype, "ban") || equali(kicktype, "2"))
				{
					if(equali(bantype, "name") || equali(bantype, "1"))
					{
						server_cmd("amx_banggp ^"%s^" ^"%s^" ^"%s^"", name, banduration, reason);
						break;
					}
					else
					if(equali(bantype, "steamid") || equali(bantype, "2"))
					{
						server_cmd("amx_banggp ^"%s^" ^"%s^" ^"%s^"", steamid, banduration, reason);
						break;
					}
					else
					if(equali(bantype, "ip") || equali(bantype, "3"))
					{
						server_cmd("amx_banipggp ^"%s^" ^"%s^" ^"%s^"", name, banduration, reason);
						break;
					}
				}
				else
				if(equali(kicktype, "destroy") || equali(kicktype, "3"))
				{
					server_cmd("amx_destroy ^"%s^"", name);
					break;
				}
			}
		}
	}
}