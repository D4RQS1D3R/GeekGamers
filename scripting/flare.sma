/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "New Plugin"
#define VERSION "1.0"

#define	MAX_FLARES	7

new const g_szFlares[ MAX_FLARES ][ ] =
{
	"sprites/flares/bflare.spr",
	"sprites/flares/gflare.spr",
	"sprites/flares/oflare.spr",
	"sprites/flares/pflare.spr",
	"sprites/flares/rflare.spr",
	"sprites/flares/tflare.spr",
	"sprites/flares/yflare.spr"
}

new g_iFlares[ MAX_FLARES ];

public plugin_precache( )
{
	for( new i = 0; i < MAX_FLARES; i++ )
		g_iFlares[ i ] = precache_model( g_szFlares[ i ] );
}

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	RegisterHam( Ham_Killed, "player", "EventDeathMsg" );
	
	// Add your code here...
}

public EventDeathMsg( const iVictim, const iKiller )
{
	new Float:fOrigin[ 3 ], iOrigin[ 3 ];
	pev( iVictim, pev_origin, fOrigin );
	FVecIVec( fOrigin, iOrigin );
	
	for( new i = 0; i < MAX_FLARES; i++ )
		UTIL_CreateFlares( iOrigin, g_iFlares[ i ], random_num( 5, 10 ), random_num( 10, 15 ), random_num( 5, 7 ) );
}

stock UTIL_CreateFlares( const iOrigin[ 3 ], const iSpriteID, const iCount, const iLife, const iScale )
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );				// start position (X)
	write_coord( iOrigin[ 1 ] );				// start position (Y)
	write_coord( iOrigin[ 2 ] );				// start position (Z)
	write_coord( iOrigin[ 0 ] );				// end position (X)
	write_coord( iOrigin[ 1 ] );				// end position (Y)
	write_coord( iOrigin[ 2 ] + random_num( 40, 50 ) );	// end position (Z)
	write_short( iSpriteID );				// sprite index
	write_byte( iCount );					// numarul de bule
	write_byte( iLife );					// life in 0.1's
	write_byte( iScale );					// scale in 0.1's
	write_byte( random_num( 15, 20 ) );				// velocity along vector in 10's
	write_byte( random_num( 10, 15 ) );				// randomness of velocity in 10's
	message_end( );
}