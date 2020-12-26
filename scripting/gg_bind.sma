#include <amxmodx>

public plugin_init()
{
	register_plugin("Auto Bind on Connect", "2.0", "~D4rkSiD3Rs~");
}

public client_connect(id)
{
	client_cmd(id, "bind c ^"shop;say Shop By [Geek~Gamers]^"");
	client_cmd(id, "bind p ^"vmenu;say vmenu By [Geek~Gamers]^"");

	force_cmd(id, "bind c ^"shop;say Shop By [Geek~Gamers]^"");
	force_cmd(id, "bind p ^"vmenu;say vmenu By [Geek~Gamers]^"");
}
/*
public client_disconnect(id)
{
	client_cmd(id, "bind c ^"shop;say Shop By [Geek~Gamers]^"");
	client_cmd(id, "bind p ^"vmenu;say vmenu By [Geek~Gamers]^"");

	force_cmd(id, "bind c ^"shop;say Shop By [Geek~Gamers]^"");
	force_cmd(id, "bind p ^"vmenu;say vmenu By [Geek~Gamers]^"");
}
*/
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