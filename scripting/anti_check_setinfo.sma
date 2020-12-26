#include <amxmodx>
#include <amxmisc>

#pragma compress 1

new amx_password_field;

public plugin_init()
{
	register_plugin("[GG] Anti check setinfo", "2.0", "~D4rkSiD3Rs~");

	amx_password_field = register_cvar("amx_password_field", "_pw");
}

public client_connect(id)
	Setinfo(id);

public client_authorized(id)
	Setinfo(id);

public client_putinserver(id)
	Setinfo(id);

public client_disconnect(id)
	Setinfo(id);

public Setinfo(id)
{
	new passfield[32];
	get_pcvar_string(amx_password_field, passfield, 31);

	force_cmd(id, "setinfo %s ^"^"", passfield);
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
