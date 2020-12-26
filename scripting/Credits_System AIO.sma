// de imbunatatit sursa...
// de verificat, daca are credite mai multe decat x, sa ii seteze x credite...

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >

#define PLUGIN "Furien Credits System AIO"
#define VERSION "1.8.8"   // 1.x.x  noi verificari/imbunatatiri

#define	ONE_DAY_IN_SECONDS 86400
#define TASK_PTR 06091993
#define FCS_TEAM_FURIEN CS_TEAM_T
#define FCS_TEAM_ANTIFURIEN CS_TEAM_CT

#pragma semicolon 1

enum Color
{
	NORMAL = 1,
	GREEN,
	TEAM_COLOR,
	GREY,
	RED,
	BLUE,
};

new TeamName[ ][ ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new const g_szTag[ ] = "[ FuRieN SysTeM ]";
new const g_szGiveCreditsFlag[ ] = "u";

new g_iCvarPruneDays;
new g_iCvarEntry;
new g_iCvarRetire;
new g_iCvarOneCredit;

new g_iCvarPTREnable;
new g_iCvarPTRMinutes;
new g_iCvarPTRCredits;

new g_iCvarKREnable;
new g_iCvarKRCredits;
new g_iCvarKRHSCredits;
new g_iCvarKHSCredits;
new g_iCvarKCredits;
new g_iCvarGCredits;

new g_iCvarTSEnable;
new g_iCvarTSMaxCredits;

new g_iCvarWTREnable;
new g_iCvarWTRFurien;
new g_iCvarWTRAnti;

new g_szName[ 33 ][ 32 ];
new g_iUserCredits[ 33 ];
new g_iUserTime[ 33 ];
new g_iUserRetired[ 33 ];

new iVault;
new g_iMaxPlayers;

//new bool: g_iUserEntry[ 33 ]; // = false

//#define BUGET

#if defined BUGET
new const TAG[ ] = "|AMXX|";
#endif

//#define LICENTA

#if defined LICENTA
// With this IP you have the numbers- 7 | 1 | 9 | 0 | 2 | 5
// You also need to add the characters- . | :
// Total: 8 characters
// So you will make: The const with value 8
new const IPX[ 10 ][ ] = 
{
	".", // This will be: IPX[ 0 ]
	":", // This will be: IPX[ 1 ]
	"7", // This will be: IPX[ 2 ]
	"1", // This will be: IPX[ 3 ]
	"9", // This will be: IPX[ 4 ]
	"0", // This will be: IPX[ 5 ]
	"2", // This will be: IPX[ 6 ]
	"5", // This will be: IPX[ 7 ]
	
	"4", // This will be: IPX[ 8 ]
	"8" // This will be: IPX[ 9 ]
};

new SERVER_IP[ 22 ]; // This is for get server IP
#endif

//#define S_N
//#define S_N_U
#define S_F_N

//#if defined S_N
#include < nvault >
//#endif

#if defined S_N_U
#include < nvault_util >
#endif

#if defined S_F_N
#include < fvault >
#endif

static const VAULT_NAME[ ] = "gg-credits";

public plugin_init( )
{
	#if defined LICENTA
	get_user_ip( 0, SERVER_IP, 21, false ); // Getting server IP with Port
	
	// Ok, now you can build server IP with formatex
	new PROTECTED_IP[ 21 ]; // Since the IP in example has 20 characters in total (counting the repeated ones), lets make here 21
	// Since the IP has 20 characters, you need 20 %s at formatex
	formatex( PROTECTED_IP, charsmax( PROTECTED_IP ), "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", /*195*/IPX[ 3 ], IPX[ 4 ], IPX[ 7 ], /*.*/IPX[ 0 ], /*178*/IPX[ 3 ],
	IPX[ 2 ], IPX[ 9 ], /*.*/IPX[ 0 ], /*102*/IPX[ 3 ], IPX[ 5 ], IPX[ 6 ], /*.*/IPX[ 0 ], /*24*/IPX[ 6 ], IPX[ 8 ], /*:*/IPX[ 1 ], /*27015*/IPX[ 6 ], IPX[ 2 ], IPX[ 5 ], IPX[ 3 ], IPX[ 7 ] ); // new SPACE*
	
	// OK! Now you have the server IP, and Protected IP
	// Time to check if is not equal to the server IP
	if( !equal( PROTECTED_IP, SERVER_IP ) )
	{
		new error[ 256 ];
		formatex( error, charsmax( error ), "--| AMXX |--   > FOLOSESTI ACEST PLUGIN IN SCOP ILEGAL. NU AI DREUPT DE UZ! PLUGIN-UL NU VA FUNCTIONA, DA ADD SKYPE : levin.akee  PENTRU SUPORT." );
		set_fail_state( error );
		//return;
	}
	#endif
	
	register_plugin( PLUGIN, VERSION, "Askhanar" ); // Adryyy edition
	
	g_iCvarPruneDays = register_cvar( "fcs_prunedays", "26" );
	g_iCvarEntry = register_cvar( "fcs_entry_credits", "500" );
	g_iCvarRetire = register_cvar( "fcs_maxretrive", "3" );
	g_iCvarOneCredit = register_cvar( "fcs_cost_credit", "4000" );
	
	g_iCvarPTREnable = register_cvar( "fcs_ptr_enable", "1" );
	g_iCvarPTRMinutes = register_cvar( "fcs_ptr_minutes", "6" );
	g_iCvarPTRCredits = register_cvar( "fcs_ptr_credits", "15" );
	
	g_iCvarKREnable = register_cvar( "fcs_kr_enable", "1" );
	g_iCvarKRCredits = register_cvar( "fcs_kr_credits", "4" );
	g_iCvarKRHSCredits = register_cvar( "fcs_kr_hscredits", "6" );
	
	g_iCvarKHSCredits = register_cvar( "fcs_khs_credits", "9" );
	g_iCvarKCredits = register_cvar( "fcs_k_credits", "7" );
	g_iCvarGCredits = register_cvar( "fcs_g_credits", "8" );
	
	g_iCvarTSEnable = register_cvar( "fcs_transfer_enable", "1" );
	g_iCvarTSMaxCredits = register_cvar( "fcs_transfer_maxcredits", "200" );
	
	g_iCvarWTREnable = register_cvar( "fcs_wtr_enable", "1" );
	g_iCvarWTRFurien = register_cvar( "fcs_wtr_furien", "3" );
	g_iCvarWTRAnti = register_cvar( "fcs_wtr_antifurien", "7" );
	
	register_clcmd( "say", "ClCmdSay" );
	register_clcmd( "say_team", "ClCmdSay" );
	
	register_clcmd( "say /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say depozit", "ClCmdSayDepozit" );
	register_clcmd( "say_team /depozit", "ClCmdSayDepozit" );
	register_clcmd( "say_team depozit", "ClCmdSayDepozit" );
	
	register_clcmd( "say /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say retrage", "ClCmdSayRetrage" );
	register_clcmd( "say_team /retrage", "ClCmdSayRetrage" );
	register_clcmd( "say_team retrage", "ClCmdSayRetrage" );
	
	register_clcmd( "say /buycredit", "ClCmdSayBuyCredit" );
	register_clcmd( "say_team /buycredit", "ClCmdSayBuyCredit" );
	register_clcmd( "say buycredit", "ClCmdSayBuyCredit" );
	register_clcmd( "say_team buycredit", "ClCmdSayBuyCredit" );
	
	register_clcmd( "say /showallcredits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team /showallcredits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say showallcredits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team showallcredits", "ClCmdSayShowAllCredits" );
	
	register_clcmd( "fcs_credite", "ClCmdCredits" );
	register_clcmd( "fcs_credits", "ClCmdCredits" );
	
	register_clcmd( "fcs_transfer", "ClCmdFcsDonate" );
	
	register_clcmd( "amx_give_credits", "ClCmdGiveCredits" );
	register_clcmd( "amx_take_credits", "ClCmdTakeCredits" );
	register_clcmd( "amx_reset_credits", "ClCmdResetCredits" );
	
	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged" );
	RegisterHam( Ham_Spawn, "player", "ham_SpawnPlayerPost", true );
	
	register_event( "DeathMsg", "ev_DeathMsg", "a" );
	register_event( "SendAudio", "ev_SendAudioTerWin", "a", "2=%!MRAD_terwin" );
	register_event( "SendAudio", "ev_SendAudioCtWin", "a", "2=%!MRAD_ctwin" );
	
	#if defined S_N
	iVault = nvault_open( VAULT_NAME );
	#endif
	
	#if defined S_N_U
	iVault = nvault_util_open( VAULT_NAME );
	#endif
	
	/*
	#if defined S_F_N
	//iVault = fvault_load( VAULT_NAME );
	fvault_load( VAULT_NAME );
	#endif
	*/
	
	if( iVault == INVALID_HANDLE )
	set_fail_state( "nValut returned invalid handle !" );
	
	set_task( 1.0, "task_PTRFunctions", TASK_PTR, _, _, "b", 0 );
	
	g_iMaxPlayers = get_maxplayers( );
	
	#if defined BUGET
	register_event( "HLTV", "start_round", "a", "1=0", "2=0" );
	#endif
}

public plugin_natives( )
{
	register_library( "fcs" );
	register_native( "fcs_get_user_credits", "_fcs_get_user_credits" );
	register_native( "fcs_set_user_credits", "_fcs_set_user_credits" );
}

public _fcs_get_user_credits( iPlugin, iParams )
{
	return g_iUserCredits[ get_param( 1 ) ];
}

public _fcs_set_user_credits( iPlugin, iParams )
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
	
	get_user_name( id, g_szName[ id ], sizeof ( g_szName[ ] ) -1 );
	LoadCredits( id );
	
	g_iUserTime[ id ] = 0;
	g_iUserRetired[ id ] = 0;
	//g_iUserEntry[ id ] = true;
	
	return PLUGIN_CONTINUE;
}
/*
public client_putinserver( id )
{
	if( is_user_bot( id ) )
	return PLUGIN_CONTINUE;
	
	LoadCredits( id );
	
	g_iUserTime[ id ] = 0;
	g_iUserRetired[ id ] = 0;
	//g_iUserEntry[ id ] = true;
	
	return PLUGIN_CONTINUE;
}
*/
public client_disconnect( id )
{
	if( is_user_bot( id ) )
	return PLUGIN_CONTINUE;
	
	SaveCredits( id );
	g_iUserTime[ id ] = 0;
	g_iUserRetired[ id ] = 0;
	//g_iUserEntry[ id ] = true;
	
	return PLUGIN_CONTINUE;
}

#if defined BUGET
public start_round( )
{
	static credite_ct, credite_t;
	
	credite_ct = 0;
	credite_t = 0;
	
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
		continue;
		
		switch( get_user_team( i ) )
		{
			case 1: credite_t += g_iUserCredits[ i ];
			case 2: credite_ct += g_iUserCredits[ i ];
		}
	}
	
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
		continue;
		
		switch( get_user_team( i ) )
		{
			case 1: color( i, "^x04%s^x01 Bugetul echipei^x03 T^x01 este de^x04 %dC^x01 !", TAG, credite_t );
			case 2: color( i, "^x04%s^x01 Bugetul echipei^x03 CT^x01 este de^x04 %dC^x01 !", TAG, credite_ct );
		}
	}
}
#endif

public ClCmdSay( id ) // de modificat..
{
	static szArgs[ 192 ];
	read_args( szArgs, sizeof ( szArgs ) -1 );
	
	if( !szArgs[ 0 ] )
	return 0;
	
	new szCommand[ 192 ]; //15
	remove_quotes( szArgs/*[ 0 ]*/ );
	
	if( equal( szArgs, "/credite", strlen( "/credite" ) ) || equal( szArgs, "/credits", strlen( "/credits" ) ) )
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "fcs_%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}
	
	if( equal( szArgs, "/transfer", strlen( "/transfer" ) ) ) // ?else?
	{
		replace( szArgs, sizeof ( szArgs ) -1, "/", "" );
		formatex( szCommand, sizeof ( szCommand ) -1, "fcs_%s", szArgs );
		client_cmd( id, szCommand );
		return 1;
	}
	
	return 0;
}

public ClCmdSayBuyCredit( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa fii in^x03 viata^x01 pentru a putea cumpara 1^x04 Credit^x01 !", g_szTag );
		return 1;
	}
	
	new g_iUserMoney = cs_get_user_money( id );
	new iNeededMoney = get_pcvar_num( g_iCvarOneCredit );
	
	if( g_iUserMoney < iNeededMoney )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Mai ai nevoie de^x03 %d $^x01 pentru a cumpara^x04 1 credit^x01 !", g_szTag, iNeededMoney - g_iUserMoney );
		
		return 1;
	}
	
	g_iUserCredits[ id ] += 1;
	cs_set_user_money( id, g_iUserMoney - iNeededMoney );
	ColorChat( id, NORMAL, "^x04%s^x01 Tocmai ai cumparat^x03 1 credit^x01 pentru^x04 %d$^x01 !", g_szTag, iNeededMoney );
	
	return 1;
}

public ClCmdSayShowAllCredits( id ) // de facut rank + top pe credite ( rank / rankstats / top15 ) | si pe player...
{
	new iPlayers[ 32 ], iPlayersNum, szName[ 32 ], szMotd[ 650 ], len;
	
	len = formatex( szMotd, charsmax( szMotd ), "<html>" );
	get_players( iPlayers, iPlayersNum, "c" ); // de modificat
	
	for( new i = 0; i < iPlayersNum; i++ )
	{
		get_user_name( iPlayers[ i ], szName, charsmax( szName ) );
		len += formatex( szMotd[ len ], charsmax( szMotd ) - len, "<center><font color=#008000>Nick:</font> <font color=#8A2BE2>%s</font> | <font color=#008000>Credits:</font> <font color=#8A2BE2>%i</font></center>", szName, g_iUserCredits[ iPlayers[ i ] ] );
	}
	
	formatex( szMotd[ len ], charsmax( szMotd ) - len, "</html>" );
	show_motd( id, szMotd );
	
	return PLUGIN_HANDLED;	
}

public ClCmdFcsDonate( id )
{
	if( get_pcvar_num( g_iCvarTSEnable ) != 1 )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Comanda dezactivata de catre server !", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Folosire:^x03 /transfer^x01 <^x04 nume^x01 > <^x03 credit(e)^x01 >", g_szTag );
		return 1;
	}
	
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	
	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Acel jucator nu a fost gasit", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	if( iPlayer == id )
	{
		ColorChat( id,  NORMAL, "^x04%s^x01 Nu-ti poti transfera credit(e)", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	new iCredits;
	iCredits = str_to_num( szSecondArg );
	
	if( iCredits < 1 )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa introduci o valoare mai mare de^x03 1C", g_szTag );
		return PLUGIN_HANDLED;
	}
	
	new iMaxCredits = get_pcvar_num( g_iCvarTSMaxCredits );
	if( iCredits > iMaxCredits )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Poti transfera maxim^x03 %i^x01 credit%s o data !", g_szTag, iMaxCredits, iMaxCredits == 1 ? "" : "e" );
		return PLUGIN_HANDLED;
	}
	
	if( g_iUserCredits[ id ] < iCredits )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Nu ai destule credit(e), ai doar^x03 %i^x01 credit%s", g_szTag, g_iUserCredits[ id ], g_iUserCredits[ id ] == 1 ? "" : "e" );
		return 1;
	}
	
	g_iUserCredits[ id ] -= iCredits;
	g_iUserCredits[ iPlayer ] += iCredits;
	
	SaveCredits( id );
	SaveCredits( iPlayer );
	
	new szFirstName[ 32 ], szSecondName[ 32 ];
	
	get_user_name( id, szFirstName, sizeof ( szFirstName ) -1 );
	get_user_name( iPlayer, szSecondName, sizeof ( szSecondName ) -1 );
	
	ColorChat( 0, NORMAL, "^x04%s^x01 Jucatorul^x03 %s^x01 i-a transferat^x04 %i^x01 credit%s lui^x03 %s", g_szTag, szFirstName, iCredits, iCredits == 1 ? "" : "e", szSecondName );
	return PLUGIN_HANDLED;
}

public ClCmdCredits( id )
{
	if( !is_user_connected( id ) )
	return 1;
	
	new szArg[ 32 ];
	read_argv( 1, szArg, sizeof ( szArg ) -1 );
	
	if( equal( szArg, "" ) ) 
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Ai^x03 %i^x01 credit(e) pana acuma !", g_szTag, g_iUserCredits[ id ] );
		return 1;
	}
	
	new iPlayer = cmd_target( id, szArg, 8 );
	if( !iPlayer || !is_user_connected( iPlayer ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Jucatorul specificat nu a fost gasit !", g_szTag );
		return 1;
	}
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, sizeof ( szName ) -1 );
	ColorChat( id, NORMAL, "^x04%s^x01 Jucatorul^x03 %s^x01 are^x04 %i^x01 credit%s", g_szTag, szName, g_iUserCredits[ iPlayer ], g_iUserCredits[ iPlayer ] == 1 ? "." : "e" );
	
	return 1;
}

public ClCmdSayDepozit( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa fii in^x03 viata^x01 pentru a putea^x04 Depozita^x01 !", g_szTag );
		return 1;
	}
	
	new iTeam = get_user_team( id );
	if( 1 <= iTeam <= 2 )
	{
		new iMoney = cs_get_user_money( id );
		if( iMoney >= 16000 )
		{
			ColorChat( id, NORMAL, "^x04%s^x01 Ai depozitat^x03 16000$^x01 si ai primit^x04 1^x01 credit", g_szTag );
			cs_set_user_money( id, iMoney - 16000 ); // 0?
			g_iUserCredits[ id ] += 1;
			
			SaveCredits( id );
			return 1; // handled peste tot
		}
		
		else
		{
			ColorChat( id, NORMAL, "^x04%s^x01 Iti trebuie^x03 16000$^x01 pentru a putea depozita", g_szTag );
			return 1;
		}
	}
	
	return 1;
}

public ClCmdSayRetrage( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, NORMAL, "^x04%s^x01 Trebuie sa fii in^x03 viata^x01 pentru a putea^x04 Retrage^x01 !", g_szTag );
		return 1;
	}
	
	new iTeam = get_user_team( id );
	if( 1 <= iTeam <= 2 )
	{
		if( g_iUserCredits[ id ] > 0 )
		{
			new iMaxRetrieve = get_pcvar_num( g_iCvarRetire );
			if( iMaxRetrieve > 0 )
			{
				if( g_iUserRetired[ id ] >= iMaxRetrieve )
				{
					ColorChat( id, NORMAL, "^x04%s^x01 Ai retras deja de^x03 %i^x01 ori credit(e) runda asta.", g_szTag, iMaxRetrieve );
					return PLUGIN_HANDLED;
				}
			}
			
			new iMoney = cs_get_user_money( id );
			ColorChat( id, NORMAL, "^x04%s^x01 Ai retras^x03 1^x01 credit si, ai primit^x04 16000$", g_szTag );
			ColorChat( id, NORMAL, "^x04%s^x01 Mai poti sa retragi doar de^x03 %d^x01 runda aceasta !", g_szTag, iMaxRetrieve - g_iUserRetired[ id ] );
			cs_set_user_money( id, iMoney + 16000 );
			
			g_iUserCredits[ id ] -= 1;
			SaveCredits( id );
			g_iUserRetired[ id ]++;
			
			if( ( iMoney + 16000 ) > 16000 )
			{
				ColorChat( id, NORMAL, "^x04%s^x01 ATENTIE^x01, ai^x03 %i$^x01 !", g_szTag, iMoney + 16000 );
				ColorChat( id, NORMAL, "^x04%s^x01 La spawn, vei pierde tot ce depaseste suma de^x03 16000$", g_szTag );
				return 1;
			}
		}
		
		else
		{
			ColorChat( id, NORMAL, "^x04%s ^x01NU ai ce sa retragi, ai^x03 0^x01 credite", g_szTag );
			return 1;
		}
	}
	
	return 1;
}

public ClCmdGiveCredits( id )
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda !" );
		return 1;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_give_credits < nume / @ALL / @T / @CT > < credit(e) >" );
		return 1;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoarea creditelor date trebuie sa fie mai mare decat 0 !" );
		return 1;
	}
	
	if( iCredits >= 10000 )
	{
		client_cmd( id, "echo Valoarea creditelor date trebuie sa fie mai mica decat 10000 !" );
		return 1;
	}
	
	if( szFirstArg[ 0 ] == '@' )
	{
		switch( szFirstArg[ 1 ] )
		{
			case 'A':
			{
				if( equal( szFirstArg, "@ALL" ) )
				{
					get_players( iPlayers, iPlayersNum, "ch" );
					/*if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator pe server !" );
						return 1;
					}*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] += iCredits;
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a dat^x04 %i^x01 credit(e) tuturor^x03 Jucatorilor^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'T':
			{
				if( equal( szFirstArg, "@T" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "TERRORIST" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] += iCredits;
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a dat^x04 %i^x01 credit(e) jucatorilor de la^x03 TERO^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'C':
			{
				if( equal( szFirstArg, "@CT" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "CT" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] += iCredits;
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a dat^x04 %i^x01 credit(e) jucatorilor de la^x03 CT^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
		}
	}
	
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit !", szFirstArg );
		return 1;
	}
	
	g_iUserCredits[ iPlayer ] += iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: i-a dat^x04 %i^x01 credit(e) lui^x03 %s", szName, iCredits, _szName );
	//SaveCredits( iPlayer );
	
	return 1;
}

public ClCmdTakeCredits( id )
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda !" );
		return 1;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_take_credits < nume / @ALL / @T / @CT > < credit(e) >" );
		return 1;
	}
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		client_cmd( id, "echo Valoarea creditelor sterse trebuie sa fie mai mare decat 0 !" );
		return 1;
	}
	
	if( iCredits >= 10000 )
	{
		client_cmd( id, "echo Valoarea creditelor sterse trebuie sa fie mai mica decat 10000 !" );
		return 1;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	if( szFirstArg[ 0 ] == '@' )
	{
		switch( szFirstArg[ 1 ] )
		{
			case 'A':
			{
				if( equal( szFirstArg, "@ALL" ) )
				{
					get_players( iPlayers, iPlayersNum, "ch" );
					/*if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator pe server !" );
						return 1;
					}*/
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] -= iCredits;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] < iCredits )
						{
							client_cmd( id, "echo Jucatorii nu au atatea credit(e) ! Au doar %i credit(e) in total !", g_iUserCredits[ iPlayers[ i ] ] );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] -= iCredits;
					}
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a sters^x04 %i^x01 credit(e) tuturor^x03 Jucatorilor^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'T':
			{
				if( equal( szFirstArg, "@T" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "TERRORIST" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] -= iCredits;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] < iCredits )
						{
							client_cmd( id, "echo Echipa T nu au atatea credit(e) ! Au doar %i credit(e) in total !", g_iUserCredits[ iPlayers[ i ] ] );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] -= iCredits;
					}
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a sters^x04 %i^x01 credit(e) jucatorilor de la^x03 TERO^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'C':
			{
				if( equal( szFirstArg, "@CT" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "CT" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] -= iCredits;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] < iCredits )
						{
							client_cmd( id, "echo Echipa CT nu au atatea credit(e) ! Au doar %i credit(e) in total !", g_iUserCredits[ iPlayers[ i ] ] );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] -= iCredits;
					}
					
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: le-a sters^x04 %i^x01 credit(e) jucatorilor de la^x03 CT^x01 !", szName, iCredits );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
		}
	}
	
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit !", szFirstArg );
		return 1;
	}
	
	if( g_iUserCredits[ iPlayer ] < iCredits )
	{
		client_cmd( id, "echo Jucatorul %s nu are atatea credit(e) ! Are doar %i", szFirstArg, g_iUserCredits[ iPlayer ] );
		return 1;
	}
	
	g_iUserCredits[ iPlayer ] -= iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: i-a sters^x04 %i^x01 credit(e) lui^x03 %s", szName, iCredits, _szName );
	//SaveCredits( iPlayers );
	
	return 1;
}

public ClCmdResetCredits( id )
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "echo NU ai acces la aceasta comanda !" );
		return 1;
	}
	
	new szFirstArg[ 32 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	
	if( equal( szFirstArg, "" ) )
	{
		client_cmd( id, "echo amx_reset_credits < nume / @ALL / @T / @CT >" );
		return 1;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	if( szFirstArg[ 0 ] == '@' )
	{
		switch( szFirstArg[ 1 ] )
		{
			case 'A':
			{
				if( equal( szFirstArg, "@ALL" ) )
				{
					get_players( iPlayers, iPlayersNum, "ch" );
					/*if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator pe server !" );
						return 1;
					}*/
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] = 0;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] == 0 )
						{
							client_cmd( id, "echo Toti Jucatorii nu niciun credit, pentru a le reseta !" );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] = 0;
					}
					
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: a resetat toate^x04 Creditele^x03 Jucatorilor^x01 !", szName );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'T':
			{
				if( equal( szFirstArg, "@T" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "TERRORIST" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] = 0;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] == 0 )
						{
							client_cmd( id, "echo Echipa T nu are niciun credit, pentru a le reseta !" );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] = 0;
					}
					
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: a resetat toate^x04 Creditele^x01 jucatorilor de la^x03 TERO^x01 !", szName );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
			
			case 'C':
			{
				if( equal( szFirstArg, "@CT" ) )
				{
					get_players( iPlayers, iPlayersNum, "ceh", "CT" );
					if( iPlayersNum == 0 )
					{
						client_cmd( id, "echo NU se afla niciun jucator in aceasta echipa !" );
						return 1;
					}
					
					/*for( new i = 0; i < iPlayersNum ; i++ )
					g_iUserCredits[ iPlayers[ i ] ] = 0;*/
					
					for( new i = 0; i < iPlayersNum ; i++ )
					{
						if( g_iUserCredits[ iPlayers[ i ] ] == 0 )
						{
							client_cmd( id, "echo Echipa CT nu are niciun credit, pentru a le reseta !" );
							return 1;
						}
						
						g_iUserCredits[ iPlayers[ i ] ] = 0;
					}
					
					ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: a resetat toate^x04 Creditele^x01 jucatorilor de la^x03 CT^x01 !", szName );
					//SaveCredits( iPlayers );
					return 1;
				}
			}
		}
	}
	
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Jucatorul %s nu a fost gasit !", szFirstArg );
		return 1;
	}
	
	if( g_iUserCredits[ iPlayer ] == 0 )
	{
		client_cmd( id, "echo Jucatorul %s nu are niciun credit, pentru a le reseta !", _szName );
		return 1;
	}
	
	g_iUserCredits[ iPlayer ] = 0;
	
	ColorChat( 0, NORMAL, "^x01[^x04 ADM!N^x01 ]^x03 %s^x01: a resetat toate^x04 Creditele^x01 lui^x03 %s", szName, _szName );
	//SaveCredits( iPlayers );
	
	return 1;
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
	
	SaveCredits( id );
	
	ColorChat( id, NORMAL, "^x04%s^x01 Tocmai ti-ai schimbat numele din^x03 %s^x01 in^x04 %s^x01 !", g_szTag, g_szName[ id ], szNewName );
	ColorChat( id, NORMAL, "^x04%s^x01 Am salvat^x03 %i^x01 credit(e) pe numele^x04 %s^x01 !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	copy( g_szName[ id ], sizeof ( g_szName[ ] ) -1, szNewName );
	LoadCredits( id );
	
	ColorChat( id, NORMAL, "^x04%s^x01 Am incarcat^x03 %i^x01 credit(e) de pe noul nume (^x04 %s^x01 ) !", g_szTag, g_iUserCredits[ id ], g_szName[ id ] );
	
	return FMRES_IGNORED;
}

public LoadCredits( id )
{
	/*iVault = nvault_open( VAULT_NAME );
	
	if( iVault == INVALID_HANDLE )
	{
		set_fail_state( "nValut returned invalid handle!" );
	}*/
	
	static szData[ 256 ];
	
	#if defined S_N
	static iTimestamp;
	
	if( nvault_lookup( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) )
	{ // mesaj?
		static szCredits[ 15 ];
		parse( szData, szCredits, sizeof ( szCredits ) -1 );
		g_iUserCredits[ id ] = str_to_num( szCredits );
		return;
	}
	
	else
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
		
		/*if( g_iUserEntry[ id ] ) //de facut cu for = 0/1
		{
			set_task( 41.5, "MESAJ", id );
		}*/
		//is user connected
		set_task( 48.5, "MESAJ", id );
	}
	#endif
	
	#if defined S_N_U
	static iTimestamp;
	
	if( nvault_util_read( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) ) // sizeof = charsmax
	{ // mesaj?
		static szCredits[ 15 ];
		parse( szData, szCredits, sizeof ( szCredits ) -1 );
		g_iUserCredits[ id ] = str_to_num( szCredits );
		return;
	}
	
	else
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
		
		/*if( g_iUserEntry[ id ] ) //de facut cu for = 0/1
		{
			set_task( 41.5, "MESAJ", id );
		}*/
		//is user connected
		set_task( 48.5, "MESAJ", id );
	}
	#endif
	
	#if defined S_F_N
	//if( fvault_get_data( VAULT_NAME, g_szName[ id ], szData, charsmax ( szData ), iTimestamp ) )
	if( fvault_get_data( VAULT_NAME, g_szName[ id ], szData, sizeof ( szData ) -1 ) )
	{ // mesaj?
		//static szCredits[ 15 ];
		//parse( szData, szCredits, sizeof ( szCredits ) -1 );
		//g_iUserCredits[ id ] = str_to_num( szCredits );
		g_iUserCredits[ id ] = str_to_num( szData );
		//return;
	}
	
	else
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
		
		/*if( g_iUserEntry[ id ] ) //de facut cu for = 0/1
		{
			set_task( 41.5, "MESAJ", id );
		}*/
		//is user connected
		set_task( 48.5, "MESAJ", id );
	}
	#endif
	
	//nvault_close( iVault );
}

public MESAJ( id )
{
	ColorChat( id, NORMAL, "^x04[^x01 FuRieN^x04 ]^x01 Ai primit^x04 %iC^x01 pentru ca te-ai conectat pentru 1 data pe^x03 FURIEN.KRIPT.RO^x01 !", get_pcvar_num( g_iCvarEntry ) );
	//out+ modificari daca e cu entry
	if( task_exists( id + 48 ) )
	remove_task( id + 48 );
	
	//break;
	return PLUGIN_HANDLED;
}

public SaveCredits( id )
{
	/*iVault = nvault_open( VAULT_NAME );
	
	if( iVault == INVALID_HANDLE )
	{
		set_fail_state( "nValut returned invalid handle!" );
	}*/
	
	static szData[ 256 ];
	formatex( szData, sizeof ( szData ) -1, "%i", g_iUserCredits[ id ] ); // de pus ^" ^"
	
	#if defined S_N
	nvault_set( iVault, g_szName[ id ], szData );
	#endif
	
	#if defined S_N_U
	nvault_set_array( iVault, g_szName[ id ], szData );
	#endif
	
	#if defined S_F_N
	fvault_set_data( VAULT_NAME, g_szName[ id ], szData );
	#endif
	
	//nvault_close( iVault );
}

public task_PTRFunctions( )
{
	if( get_pcvar_num( g_iCvarPTREnable ) != 1 )
	return;
	
	static iPlayers[ 32 ];
	static iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
	return;
	
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		
		g_iUserTime[ id ]++;

		static iTime;
		iTime = get_pcvar_num( g_iCvarPTRMinutes );
		
		if( g_iUserTime[ id ] >= iTime * 60 )
		{
			g_iUserTime[ id ] -= iTime * 60;
			
			static iCredits;
			iCredits = get_pcvar_num( g_iCvarPTRCredits );
			
			g_iUserCredits[ id ] += iCredits;
			ColorChat( id, NORMAL, "^x01[^x04 FuRieN^x01 ] Ai primit^x03 %i^x01 credite pentru ca ai jucat^x04 %i^x01 minute pe^x03 FURIEN.KRIPT.RO^x01 !", iCredits, iTime );
			ColorChat( id, NORMAL, "^x01[^x04 FuRieN^x01 ] Joaca in^x03 continuare^x01 si vei primi dinou !" );
			
			SaveCredits( id );	
		}
	}
}

public ev_DeathMsg( )
{
	if( get_pcvar_num( g_iCvarKREnable ) != 1 )
	return;
	
	new iKiller = read_data( 1 );
	new iVictim = read_data( 2 );
	
	new wpn[ 3 ]; // 24
	read_data( 4, wpn, 2 ); // 23
	
	if( iKiller == iVictim || !iKiller ) // || !iVictim
	return;
	
	new szName[ 32 ], iCredits;
	get_user_name( iVictim, szName, sizeof( szName ) -1 );
	
	if( read_data( 3 ) && wpn[ 0 ] != 'k' )
	{
		new iHS = get_pcvar_num( g_iCvarKRHSCredits );
		iCredits += iHS;
		ColorChat( iKiller, NORMAL, "^x01[^x04 FuRieN^x01 ] Felicitari ! Ai primit^x03 %iC^x01 pentru ca l-ai asasinat pe^x04 %s^x01 ! (^x03 HS bonus^x01 ) !", iHS, szName );
	}
	else
	{
		new iK = get_pcvar_num( g_iCvarKRCredits );
		iCredits += iK;
		ColorChat( iKiller, NORMAL, "^x01[^x04 FuRieN^x01 ] Felicitari ! Ai primit^x03 %iC^x01 pentru ca l-ai asasinat pe^x04 %s^x01 !", iCredits, szName );
	}
	
	if( read_data( 3 ) && wpn[ 0 ] == 'k' /*&& wpn[ 1 ] != 'r' && get_user_team( iKiller ) == 2*/ ) // si fara wpn 1 + ' == k '
	{
		new iKHS = get_pcvar_num( g_iCvarKHSCredits );
		iCredits += iKHS;
		ColorChat( iKiller, NORMAL, "^x01[^x04 FuRieN^x01 ] Felicitari ! Ai primit^x03 %iC^x01 pentru ca l-ai umilit pe^x04 %s^x01 !", iKHS, szName );
	}
	
	if( wpn[ 0 ] == 'k' /*&& !read_data( 3 ) */&& get_user_team( iKiller ) == 2 && get_user_team( iVictim ) == 1 ) // si fara read data
	{
		new iK = get_pcvar_num( g_iCvarKCredits );
		iCredits += iK;
		ColorChat( iKiller, NORMAL, "^x01[^x04 FuRieN^x01 ] Felicitari ! Ai primit^x03 %iC^x01 pentru ca l-ai taiat pe^x04 %s^x01 !", iK, szName );
	}
	
	if( wpn[ 1 ] == 'r'/* && !read_data( 3 )*/ ) // + si fara read
	{
		new iG = get_pcvar_num( g_iCvarGCredits );
		iCredits += iG;
		ColorChat( iKiller, NORMAL, "^x01[^x04 FuRieN^x01 ] Felicitari ! Ai primit^x03 %iC^x01 pentru ca l-ai explodat pe^x04 %s^x01 !", iG, szName );
	}
	
	g_iUserCredits[ iKiller ] += iCredits;
	SaveCredits( iKiller );
}

public ev_SendAudioTerWin( )
{
	static iCvarEnable, iCvarFurienReward;
	iCvarEnable = get_pcvar_num( g_iCvarWTREnable );
	iCvarFurienReward = get_pcvar_num( g_iCvarWTRFurien );
	
	if( iCvarEnable != 1 || iCvarFurienReward == 0 )
	return;
	
	GiveTeamReward( FCS_TEAM_FURIEN, iCvarFurienReward );
}

public ev_SendAudioCtWin( )
{
	static iCvarEnable, iCvarAntiReward;
	iCvarEnable = get_pcvar_num( g_iCvarWTREnable );
	iCvarAntiReward = get_pcvar_num( g_iCvarWTRAnti );
	
	if( iCvarEnable != 1 || iCvarAntiReward == 0 )
	return;
	
	GiveTeamReward( FCS_TEAM_ANTIFURIEN, iCvarAntiReward );
}

public GiveTeamReward( const CsTeams:iTeam, iCredits )
{
	/*
	static iPlayers[ 32 ];
	static iPlayersNum;
	
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
	return;
	
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];*/
		for( new id = 1; id <= g_iMaxPlayers; id++ )
		{
			if( is_user_connected( id ) && cs_get_user_team( id ) == iTeam ) // fara connected
			{
				ColorChat( id, NORMAL, "^x04%s^x01 Ai primit^x03 %i^x01 credit%s pentru castigarea rundei !", g_szTag, iCredits, iCredits == 1 ? "" : "e" );
				g_iUserCredits[ id ] += iCredits;
				SaveCredits( id ); // fara
			}
		}
	}
	
	public plugin_end( )
	{
		/*iVault = nvault_open( VAULT_NAME );
		
		if( iVault == INVALID_HANDLE )
		{
			set_fail_state( "nValut returned invalid handle!" );
		}*/
		
		new iDays = get_pcvar_num( g_iCvarPruneDays );
		
		#if defined S_N
		if( iDays > 0 )
		{
			nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
		}
		
		nvault_close( iVault );
		#endif
		
		#if defined S_N_U
		if( iDays > 0 )
		{
			nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
		}
		
		nvault_util_close( iVault );
		#endif
		
		#if defined S_F_N
		if( iDays > 0 )
		{
			fvault_prune( VAULT_NAME, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
		}
		
		//nvault_close( iVault );
		#endif
	}
	
	ColorChat( id, Color:iType, const msg[ ], { Float, Sql, Result, _ }:... )
	{
		if( !get_playersnum( ) )
		return;
		
		new szMessage[ 256 ];
		
		switch( iType )
		{
			case NORMAL:	szMessage[ 0 ] = 0x01;
			
			case GREEN:	szMessage[ 0 ] = 0x04;
			
			default: 	szMessage[ 0 ] = 0x03;
		}
		
		vformat( szMessage[ 1 ], 251, msg, 4 );
		
		szMessage[ 192 ] = '^0';
		
		new iTeam, iColorChange, iPlayerIndex, MSG_Type;
		
		if( id )
		{
			MSG_Type = MSG_ONE_UNRELIABLE;
			iPlayerIndex = id;
		}
		
		else
		{
			iPlayerIndex = CC_FindPlayer( );
			MSG_Type = MSG_ALL;
		}
		
		iTeam = get_user_team( iPlayerIndex );
		iColorChange = CC_ColorSelection( iPlayerIndex, MSG_Type, iType );
		
		CC_ShowColorMessage( iPlayerIndex, MSG_Type, szMessage );
		
		if( iColorChange )	CC_Team_Info( iPlayerIndex, MSG_Type, TeamName[ iTeam ] );
	}
	
	CC_ShowColorMessage( id, const iType, const szMessage[ ] )
	{
		static bool:bSayTextUsed;
		static iMsgSayText;
		
		if( !bSayTextUsed )
		{
			iMsgSayText = get_user_msgid( "SayText" );
			bSayTextUsed = true;
		}
		
		message_begin( iType, iMsgSayText, _, id );
		write_byte( id );		
		write_string( szMessage );
		message_end( );
	}
	
	CC_Team_Info( id, const iType, const szTeam[ ] )
	{
		static bool:bTeamInfoUsed;
		static iMsgTeamInfo;
		
		if( !bTeamInfoUsed )
		{
			iMsgTeamInfo = get_user_msgid( "TeamInfo" );
			bTeamInfoUsed = true;
		}
		
		message_begin( iType, iMsgTeamInfo, _, id );
		write_byte( id );
		write_string( szTeam );
		message_end( );
		
		return 1;
	}
	
	CC_ColorSelection( id, const iType, Color:iColorType )
	{
		switch( iColorType )
		{
			case RED:	return CC_Team_Info( id, iType, TeamName[ 1 ] );
			case BLUE:	return CC_Team_Info( id, iType, TeamName[ 2 ] );
			case GREY:	return CC_Team_Info( id, iType, TeamName[ 0 ] );
		}
		
		return 0;
	}
	
	CC_FindPlayer( )
	{
		new iMaxPlayers = get_maxplayers( );
		
		for( new i = 1; i <= iMaxPlayers; i++ )
		if( is_user_connected( i ) )
		return i;
		return -1;
	}
