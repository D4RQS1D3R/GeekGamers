#include <amxmodx>
#include <amxmisc>
#include <file>

#pragma compress 1

#define PLUGIN "[GG] Chat Blocker"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new t;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_clcmd("say ", "client_chat", -1)
	register_clcmd("say_team ", "client_chat", -1)
}

public client_chat(id)
{
	new say[192];
	read_args(say, 192);

	new ip[32],user[32];
	get_user_ip(id, ip, 31, 1);
	get_user_name(id, user, 31);

	new counterString;
	counterString = 0

	new f = fopen("/addons/amxmodx/configs/chat_blocker.ini","r")

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
	format(fisierStringSpam, 127, "/addons/amxmodx/configs/chat_blocker.ini")

	for (new i=0; i < counterString; i++)
	{
		read_file(fisierStringSpam, i, textSpam, 192, t)
		replace_all(textSpam, 192, " ", "")
		replace_all(say, 192, " ", "")
		//new stringA[192], stringB[192];
		//stringA[id] = strtolower(say)
		//stringB[id] = strtolower(textSpam)
		if(containi( say, textSpam ) != -1)
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
