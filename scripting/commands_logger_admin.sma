#include <amxmodx>
#include <amxmisc>

new g_cmdLine1[512], g_cmdLine2[512], g_cmdLine3[512], g_cmdLine4[512]

new const g_Commands[][] =  
{
	"amx",
	"rcon"
}

public plugin_init()
{
	register_plugin("Admin Commands Logger", "1.0", "TheWhitesmith") // Edited by D4rkSiD3Rs
}

public client_command(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK) && !(get_user_flags(id) & ADMIN_BAN))
		return PLUGIN_CONTINUE

	new name[32]
	new authid[32]
	new logfile[50]
	new configsdir[200]

	new text[charsmax(name)+(4*charsmax(g_cmdLine1))]
	get_configsdir(configsdir, charsmax(configsdir))
	formatex(logfile, charsmax(logfile), "%s/admin_commands_log.txt", configsdir)
	get_user_name(id, name, charsmax(name))
	get_user_authid(id, authid, charsmax(authid))

	read_argv(0, g_cmdLine1, 511)
	read_argv(1, g_cmdLine2, 511)
	read_argv(2, g_cmdLine3, 511)
	read_argv(3, g_cmdLine4, 511)

	for(new i = 0; i < sizeof(g_Commands); i++)
	{
		if(containi(g_cmdLine1, g_Commands[i]) != -1)
		{
			static datestr[11]
			get_time("%Y-%m-%d", datestr, 10)
			new timestr[9]
			get_time("%H:%M:%S", timestr, 8)

			formatex(text, charsmax(text), "L %s - %s: Name: %s | SteamID: %s | Command: %s %s %s %s", datestr, timestr, name, authid, g_cmdLine1, g_cmdLine2, g_cmdLine3, g_cmdLine4)
			write_file(logfile, text)
		}
	}
	
	return PLUGIN_CONTINUE
}