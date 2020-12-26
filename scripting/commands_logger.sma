#include <amxmodx>
#include <amxmisc>
#include <geoip>

#pragma compress 1

#define PLUGIN "Commands Logger"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new g_cmdLine1[512], g_cmdLine2[512], g_cmdLine3[512], g_cmdLine4[512], g_bSuspected[33]

new const szLogDir[] = "addons/amxmodx/logs/GG_CommandsLogger"

new const g_UsualCommands[][] =  
{
	"amxmodmenu",
	"menuselect",
	"weapon_",
	"VModEnable",
	"jointeam",
	"kill",
	"joinclass",
	"guns",
	"chooseteam",
	"jointeam",
	"vban",
	"lastinv",
	"specmode",
	"shop",
	"vmenu",
	"say",
	"changeview",
	"drag",
	"drop",
	"nightvision",
	"paint",
	"radio",
	"VTC_CheckStart",
	"VTC_CheckEnd"
}

new const g_CheatCommands[][] = {
	"xScript",
	"xHack_",
	"superstref",
	"jumpbug",
	"xdaa",
	"bog",
	"gstrafe",
	"ground"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	if(!dir_exists(szLogDir)) mkdir(szLogDir)
}

public plugin_natives()
{
	register_native("set_suspected", "_set_suspected")
}

public _set_suspected(id)
{
	g_bSuspected[id] = true
}

public client_disconnected(id)
{
	g_bSuspected[id] = false
}

public client_command(id)
{
	new name[32]
	get_user_name(id, name, charsmax(name))

	new authid[32]
	get_user_authid(id, authid, 31)

	new ip[32]
	get_user_ip(id, ip, 31)

	new szCountry[32]
	geoip_country( ip, szCountry )

	new logfile[50];
	new datadir[20];
	new text[charsmax(name)+(4*charsmax(g_cmdLine1))]
	get_datadir(datadir, charsmax(datadir));
	//formatex(logfile, charsmax(logfile), "%s/command_logs.txt", datadir);
	read_argv(0, g_cmdLine1, 511)
	read_argv(1, g_cmdLine2, 511)
	read_argv(2, g_cmdLine3, 511)
	read_argv(3, g_cmdLine4, 511)

	if(!g_bSuspected[id])
	{
		for (new i = 0; i < sizeof(g_UsualCommands); i++)
		{
			if(containi(g_cmdLine1, g_UsualCommands[i]) != -1)
			{
				return PLUGIN_CONTINUE
			}
		}
	}
	
	for (new i = 0; i < sizeof(g_CheatCommands); i++)
	{
		if(containi(g_cmdLine1, g_CheatCommands[i]) != -1)
		{
			formatex(logfile, charsmax(logfile), "%s/Log_Cheaters.log", szLogDir)
			static szLogData[ 200 ]
			formatex( szLogData, sizeof szLogData - 1, "** Name: %s | SteamID: %s | IP: %s | Country: %s | Command: %s %s %s %s **", name, authid, ip, szCountry, g_cmdLine1, g_cmdLine2, g_cmdLine3, g_cmdLine4)
			log_to_file( logfile, szLogData )
		}
	}
	
	static datestr[11]
	get_time("%Y-%m-%d", datestr, 10)
	new timestr[9]
	get_time("%H:%M:%S", timestr, 8)

	formatex(logfile, charsmax(logfile), "%s/%s", szLogDir, datestr)
	formatex(text, charsmax(text), "L %s: ** Name: %s | SteamID: %s | IP: %s | Country: %s | Command: %s %s %s %s **", timestr, name, authid, ip, szCountry, g_cmdLine1, g_cmdLine2, g_cmdLine3, g_cmdLine4)
	write_file(logfile, text)

	//static szLogData2[ 200 ]
	//formatex( szLogData2, sizeof szLogData2 - 1, "** Name: %s | SteamID: %s | IP: %s | Country: %s | Command: %s %s %s %s **", name, authid, ip, szCountry, g_cmdLine1, g_cmdLine2, g_cmdLine3, g_cmdLine4)
	//log_to_file( "addons/amxmodx/logs/GG_Logs/Commands_Logs.log", szLogData2 )

	//formatex(logfile, charsmax(logfile), "%s/command_logs.txt", datadir)
	//formatex(text, charsmax(text), "%s: %s %s %s %s", name, g_cmdLine1, g_cmdLine2, g_cmdLine3, g_cmdLine4)
	//write_file(logfile, text)

	if(g_bSuspected[id])
	{
		formatex(logfile, charsmax(logfile), "%s/%s-Suspected.txt", szLogDir, name)
		write_file(logfile, text)
	}
	
	return PLUGIN_CONTINUE
}

public punish_cheater(id)
{
	if(is_user_connected(id))
	{
		force_cmd(id, "bind mouse3 ^"^"")
		force_cmd(id, "bind alt ^"^"")
		force_cmd(id, "bind tab ^"+showscores^"")
		force_cmd(id, "bind ctrl ^"+duck^"")
		force_cmd(id, "bind x ^"+hook^"")
		force_cmd(id, "bind z ^"+radio1^"")
		force_cmd(id, "bind c ^"+radio3^"")
		force_cmd(id, "bind b ^"buy^"")
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