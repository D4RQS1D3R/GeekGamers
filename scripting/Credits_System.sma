#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < nvault >
//#include < CC_ColorChat >

#pragma semicolon 1


#define PLUGIN "Furien Credits System"
#define VERSION "1.4.6" // Sper sa nu mai fie buguri.

#define	ONE_DAY_IN_SECONDS	86400

// |-- CC_ColorChat --|

enum Color
{
	NORMAL = 1, 		// Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
	GREEN, 			// Culoare Verde.
	TEAM_COLOR, 		// Culoare Rosu, Albastru, Gri.
	GREY, 			// Culoarea Gri.
	RED, 			// Culoarea Rosu.
	BLUE, 			// Culoarea Albastru.
};

new TeamName[  ][  ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

// |-- CC_ColorChat --|

new const g_szTag[ ] = "[Furien Credits]";

new const g_szGiveCreditsFlag[ ] = "a";

new g_szName[ 33 ][ 32 ];
new g_iUserCredits[ 33 ];
new g_iUserRetired[ 33 ];

new g_iCvarPruneDays;
new g_iCvarEntry;
new g_iCvarRetire;
new iVault;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, "Askhanar" );
	register_cvar( "fcs_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 

	g_iCvarPruneDays = register_cvar( "fcs_prunedays", "15" );
	g_iCvarEntry = register_cvar( "fcs_entry_credits", "300" );
	g_iCvarRetire = register_cvar( "fcs_maxretrieve", "0" );
	
	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );
	
	register_clcmd( "say /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say /deposit", "ClCmdSayDepozit" );
	register_clcmd( "say_team /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say_team /deposit", "ClCmdSayDepozit" );
	
	register_clcmd( "say /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say /withdraw", "ClCmdSayRetrage" );
	register_clcmd( "say_team /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say_team /withdraw", "ClCmdSayRetrage" );
	
	register_clcmd( "fcs_credite", "ClCmdCredits" );
	register_clcmd( "fcs_credits", "ClCmdCredits" );
	
	register_clcmd( "amx_give_credits", "ClCmdGiveCredits" );
	register_clcmd( "amx_take_credits", "ClCmdTakeCredits" );
	
	RegisterHam( Ham_Spawn, "player", "ham_SpawnPlayerPost", true );
	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );

}

public plugin_natives()
{
	
	register_library( "fcs" );
	register_native( "fcs_get_user_credits", "_fcs_get_user_credits" );
	register_native( "fcs_set_user_credits", "_fcs_set_user_credits" );
	
}

public _fcs_get_user_credits( iPlugin, iParams )
{
	return g_iUserCredits[  get_param( 1 )  ];
}

public _fcs_set_user_credits(  iPlugin, iParams  )
{
	new id = get_param( 1 );
	g_iUserCredits[ id ] = max( 0, get_param( 2 ) );
	SaveCredits( id );
	return g_iUserCredits[ id ];
}

public client_authorized( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	g_iUserRetired[ id ] = 0;
	get_user_name( id, g_szName[ id ], sizeof ( g_szName[] ) -1 );
	LoadCredits( id );
	
	return PLUGIN_CONTINUE;
	
}

public client_disconnect( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
		
	g_iUserRetired[ id ] = 0;
	SaveCredits( id );
	
	return PLUGIN_CONTINUE;
	
}

public ClCmdSay( id )
{
	static szArgs[192];
	read_args( szArgs, sizeof ( szArgs ) -1 );
	
	if( !szArgs[ 0 ] )
		return PLUGIN_CONTINUE;
	
	new szCommand[ 15 ];
	remove_quotes( szArgs );
	
	if( equal( szArgs, "/credite", strlen( "/credite" ) )
		|| equal( szArgs, "/credits", strlen( "/credits" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "fcs_%s", szArgs );
		client_cmd( id, szCommand );
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public ClCmdCredits( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_HANDLED;
		
	new szArg[ 32 ];
    	read_argv( 1, szArg, sizeof ( szArg ) -1 );

	if( equal( szArg, "" ) ) 
	{
		
		ColorChat( id, RED, "^x04%s^x01 Ai^x03 %i^x01 credite.", g_szTag, g_iUserCredits[ id ] );
		return PLUGIN_HANDLED;
	}
	
    	new iPlayer = cmd_target( id, szArg, 8 );
    	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, RED,"^x04%s^x01 Jucatorul specificat nu a fost gasit!", g_szTag, szArg );
		return PLUGIN_HANDLED;
	}

	new szName[ 32 ];
	get_user_name( iPlayer, szName, sizeof ( szName ) -1 );
	ColorChat( id, RED,"^x04%s^x01 Jucatorul^x03 %s^x01 are^x03 %i^x01 credit%s", g_szTag, szName, g_iUserCredits[ iPlayer ], g_iUserCredits[ iPlayer ] == 1 ? "." : "e." );
	
	return PLUGIN_HANDLED;
	
}

public ClCmdSayDepozit( id)
{
	
	if( !is_user_connected( id ) )
		return PLUGIN_HANDLED;
		
	new CsTeams:iTeam = cs_get_user_team( id );
	
	if( CS_TEAM_T <= iTeam <= CS_TEAM_CT )
	{
		new iMoney = cs_get_user_money( id );
		if( iMoney >= 16000 )
		{
			
			ColorChat( id, RED, "^x04%s^x01 Ai depozitat^x03 16000$^x01 si ai primit^x03 1^x01 credit.", g_szTag );
			cs_set_user_money( id, 0 );
			g_iUserCredits[ id ] += 1;
			
			SaveCredits( id );
			return PLUGIN_HANDLED;
		}
		else
		{
			ColorChat( id, RED, "^x04%s^x01 Iti trebuie^x03 16000$^x01 pentru a putea depozita.", g_szTag );
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_HANDLED;

}

public ClCmdSayRetrage( id)
{
	
	new CsTeams:iTeam = cs_get_user_team( id );
	
	if( CS_TEAM_T <= iTeam <= CS_TEAM_CT )
	{
		
		if( g_iUserCredits[ id ] > 0 )
		{
			new iMaxRetrieve = get_pcvar_num( g_iCvarRetire );
			if( iMaxRetrieve > 0 )
			{
				if( g_iUserRetired[ id ] >= iMaxRetrieve )
				{
					ColorChat( id, RED, "^x04%s^x01 Ai retras deja^x03 %i^x01 credit%s runda asta^x01.", g_szTag, iMaxRetrieve, iMaxRetrieve == 1 ? "" : "e" );
					return PLUGIN_HANDLED;
				}
			}
			
			new iMoney = cs_get_user_money( id );
			
			ColorChat( id, RED, "^x04%s^x01 Ai retras^x03 1^x01 credit si, ai primi^x03 16000$^x01.", g_szTag );
			cs_set_user_money( id, iMoney + 16000 );
			
			g_iUserCredits[ id ] -=1;
			g_iUserRetired[ id ]++;
			
			SaveCredits( id );
			
			if( ( iMoney + 16000 ) > 16000 )
			{
				ColorChat( id, RED, "^x04%s^x03 ATENTIE^x01, ai^x03 %i$^x01 !", g_szTag, iMoney + 16000 );
				ColorChat( id, RED, "^x04%s^x01 La spawn, vei pierde tot ce depaseste suma de^x03 16000$^x01.", g_szTag );
				return PLUGIN_HANDLED;
			}
		}
		else
		{
			ColorChat(id, RED, "^x04%s^x03 NU^x01 ai ce sa retragi, ai^x03 0^x01 credite.", g_szTag );
			return PLUGIN_HANDLED;
		}
		
	}
	
	return PLUGIN_HANDLED;

}

public ClCmdGiveCredits( id )
{
	
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_give_credits < nume/ @ALL/ @T/ @CT > < credite >" );
		return PLUGIN_HANDLED;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoare creditelor trebuie sa fie mai mare decat 0!" );
		return PLUGIN_HANDLED;
	}
	
	if( szFirstArg[ 0 ] == '@' )
	{
		
		switch ( szFirstArg[ 1 ] )
		{
			case 'A':
			{
				if( equal( szFirstArg, "@ALL" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ch" );
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite tuturor jucatorilor!", g_szTag, szName, iCredits );
					return PLUGIN_HANDLED;
				}
			}
			
			case 'T':
			{
				if( equal( szFirstArg, "@T" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ceh", "TERRORIST" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa!" );
						return PLUGIN_HANDLED;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite jucatorilor de la^x03 TERO^x01!", g_szTag, szName, iCredits );
					return PLUGIN_HANDLED;
				}
			}
			
			case 'C':
			{
				if( equal( szFirstArg, "@CT" ) )
				{
					
					get_players( iPlayers, iPlayersNum, "ceh", "CT" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa!" );
						return PLUGIN_HANDLED;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, RED, "^x04^%s^x01 Adminul^x03 %s^x01 le-a dat^x03 %i^x01 credite jucatorilor de la^x03 CT^x01!", g_szTag, szName, iCredits );
					return PLUGIN_HANDLED;
				}
			}
		}
	}
		
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] += iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a dat^x03 %i^x01 credite lui^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return PLUGIN_HANDLED;
	
	
}

public ClCmdTakeCredits( id )
{
	
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda!" );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_take_credits < nume > < credite >" );
		return PLUGIN_HANDLED;
	}
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoarea creditelor trebuie sa fie mai mare decat 0!" );
		return PLUGIN_HANDLED;
	}
			
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	if( g_iUserCredits[ iPlayer ] < iCredits )
	{
		client_cmd( id, "echo Jucatorul %s nu are atatea credite!Are doar %i", szFirstArg, g_iUserCredits[ iPlayer ] );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] -= iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
  	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 Adminul^x03 %s^x01 i-a sters^x03 %i^x01 credite lui^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return PLUGIN_HANDLED;
	
	
}

public ham_SpawnPlayerPost( id )
{
	if( !is_user_alive( id ) )
		return;
		
	g_iUserRetired[ id ] = 0;
}

public Fwd_ClientUserInfoChanged( id, szBuffer )
{
	if ( !is_user_connected( id ) ) 
		return FMRES_IGNORED;
	
	static szNewName[ 32 ];
	
	engfunc( EngFunc_InfoKeyValue, szBuffer, "name", szNewName, sizeof ( szNewName ) -1 );
	
	if ( equal( szNewName, g_szName[ id ] ) )
		return FMRES_IGNORED;
	
	SaveCredits(  id  );
	
	ColorChat( id, RED, "^x04%s^x01 Tocmai ti-ai schimbat numele din^x03 %s^x01 in^x03 %s^x01 !", g_szTag, g_szName[ id ], szNewName );
	ColorChat( id, RED, "^x04%s^x01 Am salvat^x03 %i^x01 credite pe numele^x03 %s^x01 !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	copy( g_szName[ id ], sizeof ( g_szName[] ) -1, szNewName );
	LoadCredits( id );
	
	ColorChat( id, RED, "^x04%s^x01 Am incarcat^x03 %i^x01 credite de pe noul nume (^x03 %s^x01 ) !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	return FMRES_IGNORED;
}


public LoadCredits( id )
{
	iVault  =  nvault_open(  "FurienCreditsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	static szData[ 256 ],  iTimestamp;
	
	if(  nvault_lookup( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) )
	{
		static szCredits[ 15 ];
		parse( szData, szCredits, sizeof ( szCredits ) -1 );
		g_iUserCredits[ id ] = str_to_num( szCredits );
		return;
	}
	else
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
	}
	
	nvault_close( iVault );
	
}


public SaveCredits(  id  )
{
	iVault  =  nvault_open(  "FurienCreditsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	static szData[ 256 ];
	formatex( szData, sizeof ( szData ) -1, "%i", g_iUserCredits[ id ] );
	
	nvault_set( iVault, g_szName[ id ], szData );
	nvault_close( iVault );
}

public plugin_end( )
{
	iVault  =  nvault_open(  "FurienCreditsSystem"  );
	
	if(  iVault  ==  INVALID_HANDLE  )
	{
		set_fail_state(  "nValut returned invalid handle!"  );
	}
	
	new iDays = get_pcvar_num( g_iCvarPruneDays );
	if( iDays > 0 )
	{
		nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
	}
	
	nvault_close( iVault );
}

// |-- CC_ColorChat --|

ColorChat(  id, Color:iType, const msg[  ], { Float, Sql, Result, _}:...  )
{
	
	// Daca nu se afla nici un jucator pe server oprim TOT. Altfel dam de erori..
	if( !get_playersnum( ) ) return;
	
	new szMessage[ 256 ];

	switch( iType )
	{
		 // Culoarea care o are jucatorul setata in cvar-ul scr_concolor.
		case NORMAL:	szMessage[ 0 ] = 0x01;
		
		// Culoare Verde.
		case GREEN:	szMessage[ 0 ] = 0x04;
		
		// Alb, Rosu, Albastru.
		default: 	szMessage[ 0 ] = 0x03;
	}

	vformat(  szMessage[ 1 ], 251, msg, 4  );

	// Ne asiguram ca mesajul nu este mai lung de 192 de caractere.Altfel pica server-ul.
	szMessage[ 192 ] = '^0';
	

	new iTeam, iColorChange, iPlayerIndex, MSG_Type;
	
	if( id )
	{
		MSG_Type  =  MSG_ONE_UNRELIABLE;
		iPlayerIndex  =  id;
	}
	else
	{
		iPlayerIndex  =  CC_FindPlayer(  );
		MSG_Type = MSG_ALL;
	}
	
	iTeam  =  get_user_team( iPlayerIndex );
	iColorChange  =  CC_ColorSelection(  iPlayerIndex,  MSG_Type, iType);

	CC_ShowColorMessage(  iPlayerIndex, MSG_Type, szMessage  );
		
	if(  iColorChange  )	CC_Team_Info(  iPlayerIndex, MSG_Type,  TeamName[ iTeam ]  );

}

CC_ShowColorMessage(  id, const iType, const szMessage[  ]  )
{
	
	static bool:bSayTextUsed;
	static iMsgSayText;
	
	if(  !bSayTextUsed  )
	{
		iMsgSayText  =  get_user_msgid( "SayText" );
		bSayTextUsed  =  true;
	}
	
	message_begin( iType, iMsgSayText, _, id  );
	write_byte(  id  );		
	write_string(  szMessage  );
	message_end(  );
}

CC_Team_Info( id, const iType, const szTeam[  ] )
{
	static bool:bTeamInfoUsed;
	static iMsgTeamInfo;
	if(  !bTeamInfoUsed  )
	{
		iMsgTeamInfo  =  get_user_msgid( "TeamInfo" );
		bTeamInfoUsed  =  true;
	}
	
	message_begin( iType, iMsgTeamInfo, _, id  );
	write_byte(  id  );
	write_string(  szTeam  );
	message_end(  );

	return PLUGIN_HANDLED;
}

CC_ColorSelection(  id, const iType, Color:iColorType)
{
	switch(  iColorType  )
	{
		
		case RED:	return CC_Team_Info(  id, iType, TeamName[ 1 ]  );
		case BLUE:	return CC_Team_Info(  id, iType, TeamName[ 2 ]  );
		case GREY:	return CC_Team_Info(  id, iType, TeamName[ 0 ]  );

	}

	return PLUGIN_CONTINUE;
}

CC_FindPlayer(  )
{
	new iMaxPlayers  =  get_maxplayers(  );
	
	for( new i = 1; i <= iMaxPlayers; i++ )
		if(  is_user_connected( i )  )
			return i;
	
	return -1;
}

// |-- CC_ColorChat --|