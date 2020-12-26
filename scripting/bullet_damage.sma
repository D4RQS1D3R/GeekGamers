#include < amxmodx >
#include < engine >

#define VERSION "2.0"

#define DIRECTOR_HUD_MESSAGE	0
#define NORMAL_HUD_MESSAGE	1


new pCvar_VictimC, pCvar_OurselfC, pCvar_AttackerC, pCvar_BulletMode, pCvar_Bullet_Distance, pCvar_Bullet_Walls, 
pCvar_Bullet_ShowSpec, pCvar_Bullet_Hs_Mode, pCvar_Bullet_Text_Mode, pCvar_Bullet_Show_Mode, pCvar_Accumulated_Damage

new dhud_color, dhud_x, dhud_y, dhud_effect, dhud_fxtime, dhud_holdtime, dhud_fadeintime, dhud_fadeouttime, dhud_reliable

new Float: Yv[ 33 ], Float: Xv[ 33 ] /* Victim*/, Float: Ya[ 33 ], Float: Xa[ 33 ] // Attacker

new bool: ShowMeThisHud[ 33 ], MyCurrentDamages[ 33 ], iSyncObj

public plugin_init( ) 
{
	register_plugin( "Bullet Damage", VERSION, "Bboy Grun" )
	
	register_cvar( "Director_bullet_dmg", VERSION, FCVAR_SERVER | FCVAR_SPONLY )
	set_cvar_string( "Director_bullet_dmg", VERSION )
	
	register_event( "Damage", "Event_Damage", "b", "2!0", "3=0", "4!0" ) 
	
	register_clcmd( "say /showbd", "Say_showbd" )
	register_clcmd( "say showbd", "Say_showbd" )
	
	iSyncObj = CreateHudSyncObj( )
	
	pCvar_BulletMode =     		register_cvar( "Bullet_Damage_Mode", "0" ) 
	pCvar_Bullet_Distance =    	register_cvar( "Bullet_Damage_Distance", "600" ) 
	pCvar_Bullet_Walls = 		register_cvar( "Bullet_Damage_NoShowWalls", "0" )
	pCvar_Bullet_ShowSpec =		register_cvar( "Bullet_Show_Spec", "1" )
	pCvar_Bullet_Hs_Mode  = 	register_cvar( "Bullet_Hs_Mode", "2" )
	pCvar_Bullet_Text_Mode =	register_cvar( "Bullet_Text_Mode", "0" )
	pCvar_Bullet_Show_Mode = 	register_cvar( "Bullet_Show_Mode", "0" )
	pCvar_Accumulated_Damage = 	register_cvar( "Show_Accumulated_Damage", "0" )
	
	pCvar_VictimC = 		register_cvar( "Color_RGB_Victim", "255000000" )
	pCvar_AttackerC = 		register_cvar( "Color_RGB_Attacker", "000255000" )
	pCvar_OurselfC =		register_cvar( "Color_RGB_Ourself_Teammate", "255102021" )
}

public plugin_natives( )
{
	register_native( "bd_show_damage", "native_bd_show_damage", 0 )
	register_native( "bd_show_text", "native_bd_show_text", 0 )
}

// HELP : http://forums.alliedmods.net/showthread.php?p=1436434#post1436434 Thanks to schmurgel1983
public native_bd_show_text( iPlugin, iParams )
{
	new id = get_param( 1 )
	
	if( !is_user_connected( id ) ) // user disconnected .. return 0
	{
		return 0
	}
	
	new Text[ 128 ], Attacker, Size
	
	Attacker = get_param( 2 )
	Size = get_param( 3 )
	
	get_string( 3, Text, charsmax( Text ) )
	show_client_text( id, Text, Attacker, Size )
	
	if( Attacker ) // Is the player attacker ? Yes = 1 -- No = 0
	{
		CheckPosition( id, Attacker )
		return 1
	}
	
	CheckPosition( id, 0 )
	return 1
}

public native_bd_show_damage( iPlugin, iParams )
{
	new id = get_param( 1 )
	
	if( !is_user_connected( id ) )
	{
		return 0
	}
	
	new damage, style, Attacker
	damage = get_param( 2 ); style = get_param( 3 ); Attacker = get_param( 4 )
	
	show_client_value( id, damage, Attacker, style )
	
	if( Attacker ) // Is the player attacker ? Yes = 1 -- No = 0
	{
		CheckPosition( id, Attacker )
		return 1
	}
	
	CheckPosition( id, 0 )
	return 1
}

// Director Hud Message, go to : http://forums.alliedmods.net/showthread.php?t=149210 by : ARKSHINE
public Event_Damage( Victim )
{    
	static Attacker, AttackerWpn, VictimBodyPart
	Attacker = get_user_attacker( Victim, AttackerWpn, VictimBodyPart )
	
	if( !is_user_alive( Attacker ) || ( get_pcvar_num( pCvar_Bullet_Walls ) && !is_visible( Attacker, Victim ) ) )
	{
		return;
	}
		
	static damage, R, G, B, pCvar_H, pCvar_TMODE 
	damage = read_data( 2 )
	
	pCvar_H = get_pcvar_num( pCvar_Bullet_Hs_Mode )
	pCvar_TMODE = get_pcvar_num( pCvar_Bullet_Text_Mode )
	
	static AttackerOrigin[ 3 ], VictimOrigin[ 3 ]
	
	if( Attacker != Victim && get_user_team( Attacker ) != get_user_team( Victim ) )
	{
		if( pCvar_H > 0 && VictimBodyPart == HIT_HEAD )
		{
			if( pCvar_H == 1 )
			{
				show_client_value( Victim, damage, 0, DIRECTOR_HUD_MESSAGE )
				show_client_value( Attacker, damage, 1, DIRECTOR_HUD_MESSAGE )
			}
			else
			{
				show_client_text( Victim, "HEADSHOT", 0, pCvar_TMODE )
				show_client_text( Attacker, "HEADSHOT", 1, pCvar_TMODE )
			}
		}
		else
		{
			if( !get_pcvar_num( pCvar_BulletMode ) )
			{
				show_client_value( Victim, damage, 0, DIRECTOR_HUD_MESSAGE )
				show_client_value( Attacker, damage, 1, DIRECTOR_HUD_MESSAGE )
			}
		
			else
			{
				get_user_origin( Attacker, AttackerOrigin )
				get_user_origin( Victim, VictimOrigin )
				
				if( get_distance( AttackerOrigin, VictimOrigin ) >  get_pcvar_num( pCvar_Bullet_Distance ) )
				{
					show_client_value( Victim, damage, 0, NORMAL_HUD_MESSAGE )
					show_client_value( Attacker, damage, 1, NORMAL_HUD_MESSAGE )
				}
				else
				{
					show_client_value( Victim, damage, 0, DIRECTOR_HUD_MESSAGE )
					show_client_value( Attacker, damage, 1, DIRECTOR_HUD_MESSAGE )
				}
			}
		}
        
		CheckPosition( Victim, 0 )
		CheckPosition( Attacker, 1 )
		
		if( MyCurrentDamages[ Attacker ] == -1 || !get_pcvar_num( pCvar_Accumulated_Damage ) )
		{
			 // MyCurrentDamages[ Attacker ] == -1 : The player is a BOT
			return;
		}
		
		MyCurrentDamages[ Attacker ] += damage
		UpdateDamages( Attacker )
	}
	else
	{
		// http://forums.alliedmods.net/showthread.php?t=62224
		static iColor; iColor = get_pcvar_num( pCvar_OurselfC )
		R = iColor / 1000000
		iColor %= 1000000
		G = iColor / 1000
		B = iColor % 1000
		
		set_dhudmessage( R, G, B, -1.0, -1.0, 2, 0.0, 2.0, 0.1, 0.1 )
		show_dhudmessage( Victim, "%i", damage )    // Show the damages to the player
	}
}

public Say_showbd( id ) 
{
	if( ShowMeThisHud[ id ] )
	{
		ShowMeThisHud[ id ] = false
		client_print( id, print_chat, "[ BULLET DAMAGE %s ] STATUS : OFF", VERSION )
		return;
	}
	
	client_print( id, print_chat, "[ BULLET DAMAGE %s ] STATUS : ON", VERSION )
	ShowMeThisHud[ id ] = true
}

public client_putinserver( id )
{
	iRefreshHudPosition( id )
	
	ShowMeThisHud[ id ] = true
	MyCurrentDamages[ id ] = is_user_bot( id ) ? -1 : 0
	
	// Don't show Current Accumulated Damages to bots
}

// Director Hud Message, go to : http://forums.alliedmods.net/showthread.php?t=149210 by : ARKSHINE
/*
stock set_dhudmessage( red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 6.0, Float:holdtime = 3.0, Float:fadeintime = 0.1, Float:fadeouttime = 1.5, bool:reliable = false )
{
	#define clamp_byte(%1)       		( clamp( %1, 0, 255 ) )
	#define pack_color(%1,%2,%3)	( %3 + ( %2 << 8 ) + ( %1 << 16 ) )

	dhud_color		= 		pack_color( clamp_byte( red ), clamp_byte( green ), clamp_byte( blue ) )
	dhud_x 			=	_:	x
	dhud_y 			= 	_: 	y
	dhud_effect 		= 		effects
	dhud_fxtime 		= 	_: 	fxtime
	dhud_holdtime 		=	_: 	holdtime
	dhud_fadeintime 	=	_: 	fadeintime
	dhud_fadeouttime 	=	_: 	fadeouttime
	dhud_reliable 		= 	_: 	reliable

	return 1;
}

stock show_dhudmessage( index, const message[ ], any:... )
{
	new buffer[ 128 ]
	new numArguments = numargs( )

	if( numArguments == 2 )
	{
		send_dhudMessage( index, message )
	}
	else if( index || numArguments == 3 )
	{
		vformat( buffer, charsmax( buffer ), message, 3 )
		send_dhudMessage( index, buffer )
	}
	else
	{
		new playersList[ 32 ], numPlayers;
		get_players( playersList, numPlayers, "ch" )

		if( !numPlayers )
		{
			return 0;
		}

		new Array:handleArrayML = ArrayCreate()

		for( new i = 2, j; i < numArguments; i++ )
		{
			if( getarg( i ) == LANG_PLAYER )
			{
				while( ( buffer[ j ] = getarg( i + 1, j++ ) ) ) {}
				j = 0

				if( GetLangTransKey( buffer ) != TransKey_Bad )
				{
					ArrayPushCell( handleArrayML, i++ )
				}
			}
		}

		new size = ArraySize( handleArrayML )

		if( !size )
		{
			vformat( buffer, charsmax( buffer ), message, 3 )
			send_dhudMessage( index, buffer )
		}
		else
		{
			for( new i = 0, j; i < numPlayers; i++ )
			{
				index = playersList[ i ]

				for( j = 0; j < size; j++ )
				{
					setarg( ArrayGetCell( handleArrayML, j ), 0, index )
				}
				
				vformat( buffer, charsmax( buffer ), message, 3 )
				send_dhudMessage( index, buffer )
			}
		}

		ArrayDestroy( handleArrayML )
	}
	return 1;
}
*/
stock send_dhudMessage( const index, const message[ ] )
{
	message_begin( dhud_reliable ? ( index ? MSG_ONE : MSG_ALL ) : ( index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST ), SVC_DIRECTOR, _, index )
	{
		write_byte( strlen( message ) + 31 )
		write_byte( DRC_CMD_MESSAGE )
		write_byte( dhud_effect )
		write_long( dhud_color )
		write_long( dhud_x )
		write_long( dhud_y )
		write_long( dhud_fadeintime )
		write_long( dhud_fadeouttime )
		write_long( dhud_holdtime )
		write_long( dhud_fxtime )
		write_string( message )
	}
	message_end()
} 

UpdateDamages( id )
{
	if( !ShowMeThisHud[ id ] )
	{
		return;
	}
	
	set_hudmessage( 0, 255, 0, -1.0, -0.50, 0, 0.0, 4.0, 0.0, 1.0, -1 )
	ShowSyncHudMsg( id, iSyncObj, "%d", MyCurrentDamages[ id ] )
	
	if( task_exists( 999_666_999 + id ) )
	{
		remove_task( 999_666_999 + id ) 
	}
	
	set_task( 5.0, "ResetCurrentDamages", 999_666_999 + id )
}

public ResetCurrentDamages( TaskID )
{
	MyCurrentDamages[ TaskID - 999_666_999 ] = 0
}

show_client_value( id, damage, Attacker, iSize )
{
	if( !ShowMeThisHud[ id ] )
	{
		return;
	}
	
	static iColor, R, G, B, Float: Y_Pos, Float: X_Pos
	
	if( Attacker ) // The user is the Attacker ( Attacker value = 1 )
	{
		// Attacker
		iColor = get_pcvar_num( pCvar_AttackerC )
		Y_Pos = Ya[ id ]
		X_Pos = Xa[ id ]
	}
	else
	{
		// Victim
		iColor = get_pcvar_num( pCvar_VictimC )
		Y_Pos = Yv[ id ]
		X_Pos = Xv[ id ]
	}
	
	R = iColor / 1000000
	iColor %= 1000000
	G = iColor / 1000
	B = iColor % 1000
	
	if( iSize )
	{
		set_hudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02 )
		show_hudmessage( id, "%i", damage )
	}
	else
	{
		set_dhudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02 )
		show_dhudmessage( id, "%i", damage )
	}
	
	if( !get_pcvar_num( pCvar_Bullet_ShowSpec ) )
	{
		return;
	}
	
	SpectatorHud( id, damage, _, 0, iSize, Float: X_Pos, Float: Y_Pos, R, G, B )
}

show_client_text( id, iText[ ], Attacker, iSize )
{
	if( !ShowMeThisHud[ id ] )
	{
		return;
	}
	
	static iColor, R, G, B, Float: Y_Pos, Float: X_Pos
	
	if( Attacker ) // The user is the Attacker ( Attacker value = 1 )
	{
		// Attacker
		iColor = get_pcvar_num( pCvar_AttackerC )
		Y_Pos = Ya[ id ]
		X_Pos = Xa[ id ]
	}
	else
	{
		// Victim
		iColor = get_pcvar_num( pCvar_VictimC )
		Y_Pos = Yv[ id ]
		X_Pos = Xv[ id ]
	}
	
	R = iColor / 1000000
	iColor %= 1000000
	G = iColor / 1000
	B = iColor % 1000
	
	if( !iSize )
	{
		set_dhudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02 )
		show_dhudmessage( id, "%s", iText )
	}
	else
	{
		set_hudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02, -1 )
		show_hudmessage( id, "%s", iText )
	}
	
	if( !get_pcvar_num( pCvar_Bullet_ShowSpec ) )
	{
		return;
	}
	
	SpectatorHud( id, _, iText, 1, iSize, Float: X_Pos, Float: Y_Pos, R, G, B )
}

SpectatorHud( id, iDamage = 0, iText[ ] = "", TextMode, Size, Float: X_Pos, Float: Y_Pos, R, G, B )
{
	static iPlayers[ 32 ], iNum
	get_players( iPlayers, iNum, "bch" )
	
	for( new i = 0, Spectator = iPlayers[ 0 ]; i < iNum; Spectator = iPlayers[ i++ ] )
	{		
		if( ShowMeThisHud[ Spectator ] && entity_get_int( Spectator, EV_INT_iuser2 ) == id )
		{
			if( !Size )
			{
				set_dhudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02 )
				TextMode ? show_dhudmessage( Spectator, "%s", iText ) : show_dhudmessage( Spectator, "%d", iDamage )
			}
			else
			{
				set_hudmessage( R, G, B, X_Pos, Y_Pos, 2, 0.0, 1.0, 0.02, 0.02, -1 )
				TextMode ? show_hudmessage( Spectator, "%s", iText ) : show_hudmessage( Spectator, "%d", iDamage )
			}
		}
	}
}

iRefreshHudPosition( id )
{
	switch( get_pcvar_num( pCvar_Bullet_Show_Mode ) )
	{
		case 0:
		{
			Ya[ id ] = -0.50
			Xa[ id ] = -0.70
			
			Yv[ id ] = -0.45
			Xv[ id ] = -0.30
			
		}
		case 1:
		{
			Ya[ id ] = 0.55
			Xa[ id ] = 0.53
			
			Xv[ id ] = 0.45
			Yv[ id ] = 0.50
		}
		case 2:
		{
			Ya[ id ] = -0.35
			Xa[ id ] = -0.70
			
			Yv[ id ] = -0.20
			Xv[ id ] = -0.70
		}
		case 3:
		{
			Xv[ id ] = -0.80
			Yv[ id ] = -0.90
			
			Xa[ id ] = -0.20
			Ya[ id ] = -0.90
		}
	}
}

CheckPosition( id, Attacker )
{
	switch( get_pcvar_num( pCvar_Bullet_Show_Mode ) ) 
	// [ 0 = CIRCLE ] [ 1 = VERTICAL ] [ 2 = HORIZONTAL ] [ 3 = ARCH OF CIRCLE  ]
	{
		case 0:
		{
			if( Attacker )
			{
				switch( Xa[ id ] )
				{
					case -0.70: // First attack
					{
						Xa[ id ] = -0.575
						Ya[ id ] = -0.60
					}
					case -0.575: // Second
					{
						Xa[ id ] = -0.50
						Ya[ id ] = -0.625
					}
					case -0.50: // Third
					{
						Xa[ id ] = -0.425
						Ya[ id ] = -0.60
					}
					case -0.425: // Fourth
					{		
						Xa[ id ] = -0.30
						Ya[ id ] = -0.50
					}
					case -0.30: // Last
					{
						Xa[ id ] = -0.70
					}
					default: iRefreshHudPosition( id )
				}
			}
			else
			{
				switch( Xv[ id ] )
				{
					case -0.30: // First attack
					{
						Xv[ id ] = -0.425
						Yv[ id ] = -0.35
					}
					case -0.425: // Second
					{		
						Xv[ id ] = -0.50
						Yv[ id ] = -0.30
					}
					case -0.50: // Third
					{
						Xv[ id ] = -0.575
						Yv[ id ] = -0.35
					}
					case -0.575: // fourth
					{
						Xv[ id ] = -0.70
						Yv[ id ] = -0.45
					}
					case -0.70: // Last
					{
						Xv[ id ] = -0.30
					}
					default: iRefreshHudPosition( id )
				}
			}
		}
		case 1:
		{
			if( Attacker ) 
			{
				Ya[ id ] += 0.05
				if( Ya[ id ] >= 0.90 )
				{
					Ya[ id ] = 0.55
				}
			}
			else
			{
				Yv[ id ] += 0.05
				if( Yv[ id ] >= 0.85 )
				{
					Yv[ id ] = 0.50
				}
			}
		}
		case 2:
		{
			if( Attacker )
			{
				Xa[ id ] += 0.05
				if( Xa[ id ] >= -0.35 )
				{
					Xa[ id ] = -0.70
				}
			}
			else
			{
				Xa[ id ] += 0.05
				if( Xv[ id ] >= -0.35 )
				{
					Xv[ id ] = -0.70
				}
			}
		}
		case 3:
		{
			if( Attacker )
			{
				switch( Xa[ id ] )
				{
					case -0.20: // First attack
					{
						
						if( Ya[ id ] == -0.20 )
						{
							Xa[ id ] = -0.20
							Ya[ id ] = -0.90
						}
						else
						{
							Xa[ id ] = -0.15
							Ya[ id ] = -0.80
						}
					}
					case -0.15:
					{
						switch( Ya[ id ] )
						{
							case -0.80: Ya[ id ] = -0.70
							case -0.70: Ya[ id ] = -0.60
							case -0.60: Ya[ id ] = -0.50
							case -0.50: Ya[ id ] = -0.40
							case -0.40: Ya[ id ] = -0.30
							case -0.30:
							{
								Xa[ id ] = -0.20
								Ya[ id ] = -0.20
							}
						}
					}
					default: iRefreshHudPosition( id )
				}
			}
			else
			{
				switch( Xv[ id ] )
				{
					case -0.80: // First attack
					{
						
						if( Yv[ id ] == -0.20 )
						{
							Xv[ id ] = -0.80
							Yv[ id ] = -0.90
						}
						else
						{
							Xv[ id ] = -0.85
							Yv[ id ] = -0.80
						}
					}
					case -0.85:
					{
						switch( Yv[ id ] )
						{
							case -0.80: Yv[ id ] = -0.70
							case -0.70: Yv[ id ] = -0.60
							case -0.60: Yv[ id ] = -0.50
							case -0.50: Yv[ id ] = -0.40
							case -0.40: Yv[ id ] = -0.30
							case -0.30:
							{
								Xv[ id ] = -0.80
								Yv[ id ] = -0.20
							}
						}
					}
					default: iRefreshHudPosition( id )
				}
			}
		}
		default: iRefreshHudPosition( id )
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
