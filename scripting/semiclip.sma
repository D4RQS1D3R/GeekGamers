#include <amxmodx>
#include <fakemeta>

#pragma semicolon 1

#define DISTANCE 120.0
#define UPDATE_FREQ 0.2

new bool:g_bSemiclip[33][33];
new bool:g_bHasSemiclip[33];
new bool:g_bSemiclipEnabled;

new g_iTaskId;
new g_iForwardId[3];
new g_iMaxPlayers;
new g_iCvar[3];

public plugin_init( )
{
	register_plugin( "(Team-)Semiclip", "1.0", "SchlumPF*" );
	
	g_iCvar[0] = register_cvar( "semiclip_enabled", "1" );
	g_iCvar[1] = register_cvar( "semiclip_teamclip", "1" );
	g_iCvar[2] = register_cvar( "semiclip_transparancy", "0" );
	
	register_forward( FM_Think, "fwdThink" );
	register_forward( FM_ClientCommand, "fwdClientCommand" );
	
	if( get_pcvar_num( g_iCvar[0] ) )
	{
		g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
		g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );
		g_iForwardId[2] = register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
		
		g_bSemiclipEnabled = true;
	}
	else
		g_bSemiclipEnabled = false;
	
	g_iMaxPlayers = get_maxplayers( );
	
	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	set_pev( ent, pev_classname, "task_semiclip" );
	set_pev( ent, pev_nextthink, get_gametime( ) + 1.01 );
	g_iTaskId = ent;
}

public fwdPlayerPreThink( plr )
{
	static id;
	
	if( is_user_alive( plr ) )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( pev( id, pev_solid ) == SOLID_SLIDEBOX && g_bSemiclip[plr][id] && id != plr )
			{
				set_pev( id, pev_solid, SOLID_NOT );
				g_bHasSemiclip[id] = true;
			}
		}
	}
}

public fwdPlayerPostThink( plr )
{
	static id;

	if( is_user_alive( plr ) )
	{
		for( id = 1 ; id <= g_iMaxPlayers ; id++ )
		{
			if( g_bHasSemiclip[id] )
			{
				set_pev( id, pev_solid, SOLID_SLIDEBOX );
				g_bHasSemiclip[id] = false;
			}
		}
	}
}

public fwdThink( ent )
{
	static i, j;
	static team[33];
	static Float:origin[33][3];
	
	if( ent == g_iTaskId )
	{
		if( get_pcvar_num( g_iCvar[0] ) )
		{
			for( i = 1 ; i <= g_iMaxPlayers ; i++ )
			{
				if( is_user_alive( i ) )
				{
					pev( i, pev_origin, origin[i] );
						
					if( get_pcvar_num( g_iCvar[1] ) )
						team[i] = get_user_team( i );
					
					for( j = 1 ; j <= g_iMaxPlayers ; j++ )
					{
						if( is_user_alive( j ) )
						{
							if( get_pcvar_num( g_iCvar[1] ) && team[i] != team[j] )
							{
								g_bSemiclip[i][j] = false;
								g_bSemiclip[j][i] = false;
								
							}	
							else if( floatabs( origin[i][0] - origin[j][0] ) < DISTANCE && floatabs( origin[i][1] - origin[j][1] ) < DISTANCE && floatabs( origin[i][2] - origin[j][2] ) < ( DISTANCE * 2 ) )
							{
								g_bSemiclip[i][j] = true;
								g_bSemiclip[j][i] = true;
							}
							else
							{
								g_bSemiclip[i][j] = false;
								g_bSemiclip[j][i] = false;
							}
						}
					}
				}
			}
		}
		
		set_pev( ent, pev_nextthink, get_gametime( ) + UPDATE_FREQ );
	}
}

public fwdAddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pset )
{
	if( player )
	{
		if( g_bSemiclip[host][ent] )
		{
			set_es( es_handle, ES_Solid, SOLID_NOT ); // makes semiclip flawless
			
			if( get_pcvar_num( g_iCvar[2] ) == 1 )
			{
				set_es( es_handle, ES_RenderMode, kRenderTransAlpha );
				set_es( es_handle, ES_RenderAmt, 85 );
			}
			else if( get_pcvar_num( g_iCvar[2] ) == 2 )
			{
				set_es( es_handle, ES_Effects, EF_NODRAW );
				set_es( es_handle, ES_Solid, SOLID_NOT );
			}
		}
	}
}

// is there a better way to detect changings of g_iCvar[0]?
public fwdClientCommand( plr )
{
	// use the forwards just when needed, for good performance
	if( !get_pcvar_num( g_iCvar[0] ) && g_bSemiclipEnabled )
	{
		unregister_forward( FM_PlayerPreThink, g_iForwardId[0] );
		unregister_forward( FM_PlayerPostThink, g_iForwardId[1] );
		unregister_forward( FM_AddToFullPack, g_iForwardId[2], 1 );
		
		g_bSemiclipEnabled = false;
	}
	else if( get_pcvar_num( g_iCvar[0] ) && !g_bSemiclipEnabled )
	{
		g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
		g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );
		g_iForwardId[2] = register_forward( FM_AddToFullPack, "fwdAddToFullPack_Post", 1 );
		
		g_bSemiclipEnabled = true;
	}
}