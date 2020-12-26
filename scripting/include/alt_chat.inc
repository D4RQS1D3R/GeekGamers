/* Alt_chat by anakin@2008 for CFG COMMUNITY
* adauga in plugin_init
* g_msgsaytext = get_user_msgid( "SayText" );
*/
new g_msgsaytext

print( id, const message[], { Float, Sql, Result, _ }:... )
{
	new Buffer[ 128 ],Buffer2[ 128 ];
	new players[ 32 ], index, num, i;
	
	formatex( Buffer2, sizeof Buffer2 - 1, "%s",message );
	vformat( Buffer, sizeof Buffer - 1, Buffer2, 3 );
	get_players( players, num, "c" );
	
	if( id )
	{
		if( !is_user_connected( id ))
			return;
			
		message_begin( MSG_ONE, g_msgsaytext, _, id );
		write_byte( id );
		write_string( Buffer );
		message_end();
	
	} else {
		
		for( i = 0; i < num;i++ )
		{
			index = players[ i ];
			if( !is_user_connected( index )) 
				continue;
				
			message_begin( MSG_ONE, g_msgsaytext, _, index );
			write_byte( index );
			write_string( Buffer );
			message_end();
		}
	}
}
