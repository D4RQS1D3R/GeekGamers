#include <amxmodx>
#include <amxmisc>
#include <file>

#pragma compress 1

#define PLUGIN "[GG] Commands Blocker"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new t;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_command(id)
{
	new command[512], command1[512], command2[512], command3[512];
	read_argv(0, command, 511);
	read_argv(1, command1, 511);
	read_argv(2, command2, 511);
	read_argv(3, command3, 511);

	new ip[32], user[32];
	get_user_ip(id, ip, 31, 1);
	get_user_name(id, user, 31);

	new counterString;
	counterString = 0

	new f = fopen("/addons/amxmodx/configs/commands_blocker.ini","r")

	new data[128]
	while( !feof(f) )
	{
		fgets(f, data, 127)
		if(data[0] != ';')
		{
			counterString++;
		}
	}
	fclose(f)

	new fisierStringSpam[128], textSpam[192];
	format(fisierStringSpam, 127, "/addons/amxmodx/configs/commands_blocker.ini")

	for (new i=0; i < counterString; i++)
	{
		read_file(fisierStringSpam, i, textSpam, 192, t)
		replace_all(textSpam, 192, " ", "")
		replace_all(command, 511, " ", "")
		replace_all(command1, 511, " ", "")
		replace_all(command2, 511, " ", "")
		replace_all(command3, 511, " ", "")

		//new stringA[192], stringB[192];
		//stringA[id] = strtolower(command)
		//stringB[id] = strtolower(textSpam)

		if(containi( command, textSpam ) != -1 || containi( command1, textSpam ) != -1 || containi( command2, textSpam ) != -1 || containi( command3, textSpam ) != -1)
		{
			return PLUGIN_HANDLED
 		}
		else
		{
		}
	}
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
