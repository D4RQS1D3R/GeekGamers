#include < amxmodx >

#pragma semicolon 1

#define PLUGIN "Furien Invasion"
#define VERSION "1.0"
#define AUTHOR "Askhanar"

new const InvasionSounds[ 6 ][ ] = {
	
	"[GeekGamers]/Round_Start/timestart",
	"[GeekGamers]/Round_Start/timer01",
	"[GeekGamers]/Round_Start/timer02",
	"[GeekGamers]/Round_Start/timer03",
	"[GeekGamers]/Round_Start/timer04",
	"[GeekGamers]/Round_Start/timer05"
};

new SecondsUntillInvasion = 6;
new mp_freezetime;

native bool: HC_AllOFF(id);

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "HLTV", "ev_HookRoundStart", "a", "1=0", "2=0" );
	register_event( "SendAudio","ev_TerroWin","a","2=%!MRAD_terwin" );
	register_event( "SendAudio","ev_CounterWin","a","2=%!MRAD_ctwin" );
	
	mp_freezetime = get_cvar_pointer( "mp_freezetime" );
	set_pcvar_num( mp_freezetime, 5 );
}

public plugin_precache( )
{
	new soundpath[ 64 ];
	for( new i = 0 ; i < 6 ; i++ )
	{
		formatex( soundpath, sizeof ( soundpath ) -1 , "%s.wav", InvasionSounds[ i ] );
		precache_sound( soundpath );
	}

	precache_sound("[GeekGamers]/Round_End/Furien_Win_1.wav");
	precache_sound("[GeekGamers]/Round_End/Furien_Win_2.wav");
	precache_sound("[GeekGamers]/Round_End/Furien_Win_3.wav");
	precache_sound("[GeekGamers]/Round_End/AntiFurien_Win_1.wav");
	precache_sound("[GeekGamers]/Round_End/AntiFurien_Win_2.wav");
	precache_sound("[GeekGamers]/Round_End/AntiFurien_Win_3.wav");
}

public ev_HookRoundStart( )
{
	SecondsUntillInvasion = 5;
	set_task( 0.1, "CountDown" );
}

public CountDown( )
{
	if( SecondsUntillInvasion > 0 )
	{
		TerroTeamEffects( );
		CounterTeamEffects( );
		
		client_cmd( 0, "spk %s", InvasionSounds[ SecondsUntillInvasion ] );
		static const Seconds[6][ ] = { "0","1","2","3","4","5" };

		new iPlayers[ 32 ];
		new iPlayersNum;

		get_players( iPlayers, iPlayersNum, "c" );		
		for( new i = 0 ; i < iPlayersNum ; i++ )
		{
			new tempid = iPlayers[ i ];

			if( HC_AllOFF(tempid) )
				continue;

			set_dhudmessage( 0, 255, 0, -1.0, 0.28, 0, 0.0, 0.8, 0.2, 0.2 );
			show_dhudmessage( iPlayers[ i ], "-=[Geek~Gamers]=-^nStarting Mod in: %s s !", Seconds[ SecondsUntillInvasion ] );
		}
	}
	else if( SecondsUntillInvasion <= 0 )
	{
		client_cmd( 0, "spk %s", InvasionSounds[ SecondsUntillInvasion ] );

		new iPlayers[ 32 ];
		new iPlayersNum;

		get_players( iPlayers, iPlayersNum, "c" );		
		for( new i = 0 ; i < iPlayersNum ; i++ )
		{
			new tempid = iPlayers[ i ];

			if( HC_AllOFF(tempid) )
				continue;

			set_dhudmessage( 255, 0, 0, -1.0, 0.28, 0, 0.0, 1.0, 0.2, 0.2 );
			show_dhudmessage( iPlayers[ i ], "-=[Geek~Gamers]=-^nGo Go Go !" );
		}
		return 1;
	}
	
	SecondsUntillInvasion -= 1;
	set_task( 1.0, "CountDown" );
	
	return 0;
}

public ev_TerroWin( )
{
	client_cmd(0, "mp3 stop; stopsound");

	switch(random_num(1,3))
	{
		case 1: client_cmd(0, "spk [GeekGamers]/Round_End/Furien_Win_1");
		case 2: client_cmd(0, "spk [GeekGamers]/Round_End/Furien_Win_2");
		case 3: client_cmd(0, "spk [GeekGamers]/Round_End/Furien_Win_3");
	}

	new iPlayers[ 32 ];
	new iPlayersNum;

	get_players( iPlayers, iPlayersNum, "c" );		
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		if( is_user_connected( iPlayers[ i ] ) )
		{
			ShakeScreen( iPlayers[ i ], 3.0 );
			FadeScreen( iPlayers[ i ] , 3.0, 230, 0, 0, 160 );
		}

		new tempid = iPlayers[ i ];

		if( HC_AllOFF(tempid) )
			continue;

		set_dhudmessage( 0, 255, 0, -1.0, 0.40, 0, 0.0, 3.0, 2.0, 2.0 );
		show_dhudmessage( iPlayers[ i ], "-=[Geek~Gamers]=-^nThe Furiens Have Won This Round !" );
	}
	
	return 0;
}

public ev_CounterWin( )
{
	client_cmd(0, "mp3 stop; stopsound");

	switch(random_num(1,3))
	{
		case 1: client_cmd(0, "spk [GeekGamers]/Round_End/AntiFurien_Win_1");
		case 2: client_cmd(0, "spk [GeekGamers]/Round_End/AntiFurien_Win_2");
		case 3: client_cmd(0, "spk [GeekGamers]/Round_End/AntiFurien_Win_3");
	}

	new iPlayers[ 32 ];
	new iPlayersNum;

	get_players( iPlayers, iPlayersNum, "c" );		
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		if( is_user_connected( iPlayers[ i ] ) )
		{
			ShakeScreen( iPlayers[ i ], 3.0 );
			FadeScreen( iPlayers[ i ] , 3.0, 0, 0, 230, 160 );
		}

		new tempid = iPlayers[ i ];

		if( HC_AllOFF(tempid) )
			continue;

		set_dhudmessage( 0, 255, 0, -1.0, 0.40, 0, 0.0, 3.0, 2.0, 2.0 );
		show_dhudmessage( 0, "-=[Geek~Gamers]=-^nThe Anti Furiens Have Won This Round !" );
	}
}

public TerroTeamEffects( )
{
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	get_players(iPlayers, iPlayersNum, "ae", "TERRORIST");
	
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		if( is_user_connected( iPlayers[ i ] ) )
		{	
			ShakeScreen( iPlayers[ i ], 0.7 );
			FadeScreen( iPlayers[ i ] , 0.5, 230, 0, 0, 160 );
		}
	}
}
public CounterTeamEffects( )
{
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "ae", "CT" );
	
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		if( is_user_connected( iPlayers[ i ] ) )
		{	
			ShakeScreen( iPlayers[ i ], 0.7 );
			FadeScreen( iPlayers[ i ] , 0.5, 0, 0, 230, 160 );
		}
	}
}

public ShakeScreen( id, const Float:seconds )
{
	message_begin( MSG_ONE, get_user_msgid( "ScreenShake" ), { 0, 0, 0 }, id );
	write_short( floatround( 4096.0 * seconds, floatround_round ) );
	write_short( floatround( 4096.0 * seconds, floatround_round ) );
	write_short( 1<<13 );
	message_end( );
	
}

public FadeScreen( id, const Float:seconds, const red, const green, const blue, const alpha )
{      
	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
	write_short( floatround( 4096.0 * seconds, floatround_round ) );
	write_short( floatround( 4096.0 * seconds, floatround_round ) );
	write_short( 0x0000 );
	write_byte( red );
	write_byte( green );
	write_byte( blue );
	write_byte( alpha );
	message_end( );

}