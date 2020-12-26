#include <amxmodx>

#define PLUGIN "[GG] Loading Music"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_connect(id)
{
	force_cmd(id, "mp3 play ^"media/Half-Life17.mp3^"");
}

public client_putinserver(id)
{
	force_cmd(id, "mp3 stop");
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