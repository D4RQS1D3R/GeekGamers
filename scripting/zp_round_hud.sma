#include <amxmodx>
#include <dhudmessage>

#pragma semicolon 1

enum _:iTeamWons
{
	ZOMBIE,
	HUMAN
}

new g_iTeamWons[ iTeamWons ];
new g_iRounds;

public plugin_init()
{
	register_plugin("[ZP] Rounds", "1.0", "D4rkSiD3Rs");

	register_event( "HLTV", "ev_NewRound", "a", "1=0", "2=0" );
	register_event( "TextMsg", "ev_RoundRestart", "a", "2&#Game_C", "2&#Game_w" );

	register_event( "SendAudio", "ev_TerroristWin", "a", "2&%!MRAD_terwin" );
	register_event( "SendAudio", "ev_CtWin", "a", "2&%!MRAD_ctwin" );

	g_iRounds = 0;
	g_iTeamWons[ ZOMBIE ] = 0;
	g_iTeamWons[ HUMAN ] = 0;

	set_task( 1.0, "ShowHudScore", _, _, _, "b", 0 );
}

public ev_RoundRestart()
{
	g_iRounds = 0;
	g_iTeamWons[ ZOMBIE ] = 0;
	g_iTeamWons[ HUMAN ] = 0;
}

public ev_NewRound()		g_iRounds++;
public ev_TerroristWin()	g_iTeamWons[ ZOMBIE ]++;
public ev_CtWin()		g_iTeamWons[ HUMAN ]++;

public ShowHudScore( )
{
	static iPlayers[ 32 ], iPlayersNum;
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
		return;

	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];

		set_dhudmessage( 255, 255, 255, -1.0, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 1.0, _, _ );
		show_dhudmessage( id, "[%d] Zombi ( %d ) Insan [%d]^nTUR", g_iTeamWons[ ZOMBIE ], g_iRounds, g_iTeamWons[ HUMAN ] );
	}
}
