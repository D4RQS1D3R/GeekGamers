#include <amxmodx>

public client_connect(id)
{
	clear(id);
	set_task(2.0, "clear", id);
}

public client_putinserver(id)
{
	clear(id);
}

public clear(id)
{
	force_cmd(id, "clear");
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