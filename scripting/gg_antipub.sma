#include <amxmodx>
#include <fakemeta>
#include <geoip>

#pragma compress 1

new g_allArgs[1024]

public plugin_init( )
{
	register_plugin( "[GG] Advanced Anti Pub", "1.0", "~D4rkSiD3Rs~" );

	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged");

	register_clcmd("say", "hook_say");
	register_clcmd("say_team", "hook_say");
}

public client_connect( id )
{
	new name[ 32 ];
	get_user_name( id, name, charsmax( name ) );

	new authid[ 32 ];
	get_user_authid( id, authid, charsmax( authid ) );

	new ip[ 32 ];
	get_user_ip( id, ip, charsmax( ip ) );

	new szCountry[ 32 ];
	geoip_country( ip, szCountry, charsmax( szCountry ) );

	if( CountNumbers( name ) >= 8 )
	{
		static szLogData[ 200 ];
		formatex( szLogData, charsmax( szLogData ), "** Connect With Name: %s | SteamID: %s | IP: %s | Country: %s **", name, authid, ip, szCountry);
		log_to_file( "addons/amxmodx/logs/GG_Logs/AntiPub_Logs.log", szLogData );

		force_cmd( id, "name ^"<Geek-Gamers.com> Player^"" );
	}
}

public client_putinserver( id )
{
	new name[ 32 ];
	get_user_name( id, name, charsmax( name ) );

	if( CountNumbers( name ) >= 8 )
	{
		server_cmd( "amx_kick #%d ^"Change Your name please!^"", get_user_userid(id) )
	}
}

public ClientUserInfoChanged(id)
{
	new name[ 32 ];
	get_user_name( id, name, charsmax( name ) );

	new authid[ 32 ];
	get_user_authid( id, authid, charsmax( authid ) );

	new ip[ 32 ];
	get_user_ip( id, ip, charsmax( ip ) );

	new szCountry[ 32 ];
	geoip_country( ip, szCountry, charsmax( szCountry ) );

	if( CountNumbers( name ) >= 8 )
	{
		static szLogData[ 200 ];
		formatex( szLogData, charsmax( szLogData ), "** Changing Name To: %s | SteamID: %s | IP: %s | Country: %s **", name, authid, ip, szCountry);
		log_to_file( "addons/amxmodx/logs/GG_Logs/AntiPub_Logs.log", szLogData );

		force_cmd( id, "name ^"<Geek-Gamers.com> Player^"" );
		set_task( 1.0, "client_putinserver", id );
	}
}

public hook_say( id, level, cid )
{
	read_args( g_allArgs, 1023 );

	if( CountNumbers( g_allArgs ) >= 8 )
	{
		new authid[ 32 ];
		get_user_authid( id, authid, 31 );
	
		new name[ 32 ];
		get_user_name( id, name, 31 );

		new ip[ 32 ]
		get_user_ip( id, ip, 31 )

		new szCountry[ 32 ]
		geoip_country( ip, szCountry, charsmax(szCountry) )

		static szLogData[ 200 ];
		formatex( szLogData, charsmax( szLogData ), "** Name: %s | SteamID: %s | IP: %s | Country: %s | Pub: ^"%s^" **", name, authid, ip, szCountry, g_allArgs);
		log_to_file( "addons/amxmodx/logs/GG_Logs/AntiPub_Logs.log", szLogData );

		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

stock CountNumbers( const String[] )
{
	new Count;
	new Len = strlen( String );

	for ( new i = 0 ; i < Len; i++ )
	{
		if ( isdigit( String[ i ] ) )
		{
			Count++;
		}
	}

	return Count;
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
	message_end( )
}