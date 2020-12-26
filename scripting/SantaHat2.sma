#include < amxmodx > 
#include < fakemeta > 

public plugin_precache( )
{
	precache_model( "models/[GeekGamers]/santahat.mdl" );
}

public plugin_init( )
{
	new const VERSION[ ] = "1.3";
	
	register_plugin( "Santa Hat", VERSION, "xPaw" );
	
	set_pcvar_string( register_cvar( "santa_hat", VERSION, FCVAR_SERVER ), VERSION );
	
	if( !get_pcvar_num( register_cvar( "amx_santahat", "1" ) ) )
	{
		return;
	}
	
	new iEntity,
		iMaxPlayers = get_maxplayers( ),
		iInfoTarget = engfunc( EngFunc_AllocString, "info_target" );
	
	new const MODEL[ ] = "models/[GeekGamers]/santahat.mdl";
	
	for( new id = 1; id <= iMaxPlayers; id++ )
	{
		iEntity = engfunc( EngFunc_CreateNamedEntity, iInfoTarget );
		
		if( pev_valid( iEntity ) )
		{
			engfunc( EngFunc_SetModel, iEntity, MODEL );
			set_pev( iEntity, pev_movetype, MOVETYPE_FOLLOW );
			set_pev( iEntity, pev_aiment, id );
			set_pev( iEntity, pev_owner, id );
		}
	}
}
