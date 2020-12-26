#include < amxmodx >


static const 
	PLUGIN_NAME	[ ] = "Sky Changer Updated",
	PLUGIN_VERSION	[ ] = "0.3",
	PLUGIN_AUTHOR	[ ] = "CryWolf"


new const g_sky [ ] [ ] =
{
    "hav"
};


#pragma semicolon 1
new pCvar_sky;


public plugin_init ( )
{
	register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
}

public plugin_precache ( )
{
	pCvar_sky    = register_cvar ( "amx_sky", "1", ADMIN_ADMIN );
	
	switch ( get_pcvar_num ( pCvar_sky ) )
	{
		case 0: return;
		case 1:
		{
			for ( new i = 0; i < sizeof g_sky; i++ )
			{
				static dir [ 160 ];
				formatex ( dir, charsmax ( dir ), "gfx/env/%sbk.tga", g_sky [ i ] );
				precache_generic ( dir );
				formatex ( dir, charsmax ( dir ), "gfx/env/%sdn.tga", g_sky [ i ] );
				precache_generic ( dir );
				formatex ( dir, charsmax ( dir ), "gfx/env/%sft.tga", g_sky [ i ] );
				precache_generic ( dir );
				formatex ( dir, charsmax ( dir ), "gfx/env/%slf.tga", g_sky [ i ] );
				precache_generic ( dir );
				formatex ( dir, charsmax ( dir ), "gfx/env/%srt.tga", g_sky [ i ] );
				precache_generic ( dir );
				formatex ( dir, charsmax ( dir ), "gfx/env/%sup.tga", g_sky [ i ] );
				precache_generic ( dir );
			}
		}
	}
	
	server_cmd ( "sv_skyname %s", g_sky [ random_num ( 0, charsmax ( g_sky ) ) ] );
}