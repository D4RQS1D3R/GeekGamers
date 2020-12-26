#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < newmenus >
#include < fcs >
#include < nvault >
#include < fvault_new >
#include < sqlx >
//#include < CC_ColorChat >

#pragma compress 1
#pragma semicolon 1

#define PLUGIN "[GG] Furien Credits System"
#define VERSION "1.4.6"

#define	ONE_DAY_IN_SECONDS	86400
#define TASK_PTR		06091993
#define FCS_TEAM_FURIEN CS_TEAM_T
#define FCS_TEAM_ANTIFURIEN CS_TEAM_CT

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

new const g_szTag[ ] = "[GG][Furien-Credits]";

new const g_szGiveCreditsFlag[ ] = "p";

new g_szName[ 33 ][ 32 ];
new g_iUserCredits[ 33 ];

new g_iCvarSave;

new g_iCvarPruneDays;
new g_iCvarEntry;
new g_iCvarAdminEntry;
new g_iCvarMaxCredits;
new iVault;

new g_iCvarPTREnable;
new g_iCvarPTRMinutes;
new g_iCvarPTRCredits;
new g_iUserTime[ 33 ];

new g_iCvarEnable;
new g_iCvarCredits;
new g_iCvarHSCredits;
new g_iCvarCTKnifeCredits;

new g_iCvarEnableBE;
new g_iCvarPlanted;
new g_iCvarExplode;
new g_iCvarDefused;

new accessmenu, iName[64], callback;
new bool: data_loaded[33];

//new bool: g_iUserEntry[ 33 ]; // = false

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
//#define S_F_N
#define S_M

static const VAULT_NAME[ ] = "CreditsSystem";

static const SQLX_HOSTNAME[] =	"127.0.0.1";
static const SQLX_USERNAME[] =	"gg_cs16_db";
static const SQLX_PASSWORD[] =	"GGCS16@Db";
static const SQLX_DBNAME[]   =	"gg_furien";

static Handle: g_Sqlx;

new g_iCvarBackup;
new const file_dir[] = "addons/amxmodx/data/file_vault";
new const backup_file_dir[] = "addons/amxmodx/data/file_vault/backup/credits";

native bool: HC_AllOFF(id);

native assassin_mod(id);
native sniper_mod(id);
native ghost_mod(id);

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

	register_plugin( PLUGIN, VERSION, "Askhanar" ); // Edited By ~DarkSiDeRs~
	register_cvar( "fcs_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY ); 

	g_iCvarSave				= register_cvar( "fcs_save", "3" ); // nvault(1), fvault(2), MySQL(3)

	g_iCvarPruneDays		= register_cvar( "fcs_prunedays", "0" );
	g_iCvarEntry			= register_cvar( "fcs_entry_credits", "150" );
	g_iCvarAdminEntry		= register_cvar( "fcs_owner_entry_credits", "10000" );
	g_iCvarMaxCredits		= register_cvar( "fcs_max_credit", "10000" );

	register_clcmd( "credits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say /credits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team /credits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say credits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team credits", "ClCmdSayShowAllCredits" );
	register_clcmd( "say /credit", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team /credit", "ClCmdSayShowAllCredits" );
	register_clcmd( "say credit", "ClCmdSayShowAllCredits" );
	register_clcmd( "say_team credit", "ClCmdSayShowAllCredits" );

	g_iCvarPTREnable		= register_cvar( "fcs_ptr_enable", "0" );
	g_iCvarPTRMinutes		= register_cvar( "fcs_ptr_minutes", "5" );
	g_iCvarPTRCredits		= register_cvar( "fcs_ptr_credits", "5" );

	g_iCvarEnable			= register_cvar( "fcs_kr_enable", "1" );
	g_iCvarCredits			= register_cvar( "fcs_kr_credits", "1" );
	g_iCvarHSCredits		= register_cvar( "fcs_kr_hscredits", "1" ); //( bonus, fcs_kr_credits + fcs_kr_hscredits )
	g_iCvarCTKnifeCredits	= register_cvar( "fcs_kr_ctknifecredits", "2" ); //( bonus, fcs_kr_credits + fcs_kr_ctknifecredits )

	g_iCvarEnableBE			= register_cvar( "fcs_be_enable", "1" );
	g_iCvarPlanted			= register_cvar( "fcs_be_planted", "10" );
	g_iCvarExplode			= register_cvar( "fcs_be_explode", "15" );
	g_iCvarDefused			= register_cvar( "fcs_be_defused", "20" );

	g_iCvarBackup			= register_cvar( "fcs_backup_enable", "1" );
	
	register_clcmd("amx_give_credits", "ClCmdGiveCredits");
	register_clcmd("amx_remove_credits", "ClCmdTakeCredits");

	register_clcmd("creditsmenu", "CreditsMenu");
	register_clcmd("say /creditsmenu", "CreditsMenu");

	register_clcmd("getcredits", "Get_Credits" );
	register_clcmd("say /getcredits", "Get_Credits");
	register_clcmd("GetCredits", "Get_Credits_Msg");

	register_clcmd("givecredits", "GiveCreditsMenu");
	register_clcmd("say /givecredits", "GiveCreditsMenu");
	register_clcmd("GiveCredits", "Give_Credits_Msg");

	register_clcmd("removecredits", "RemoveCreditsMenu");
	register_clcmd("say /removecredits", "RemoveCreditsMenu");
	register_clcmd("RemoveCredits", "Remove_Credits_Msg");

	register_clcmd("givecreditstero", "GiveCreditsTeroMenu");
	register_clcmd("say /givecreditstero", "GiveCreditsTeroMenu");
	register_clcmd("GiveCreditsTero", "Give_CreditsTero_Msg");

	register_clcmd("givecreditsct", "GiveCreditsCTMenu");
	register_clcmd("say /givecreditsct", "GiveCreditsAllMenu");
	register_clcmd("GiveCreditsCT", "Give_CreditsCT_Msg");

	register_clcmd("givecreditsall", "GiveCreditsCTMenu");
	register_clcmd("say /givecreditsall", "GiveCreditsAllMenu");
	register_clcmd("GiveCreditsAll", "Give_CreditsAll_Msg");

	register_event("SendAudio", "Furien_Win", "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "AntiFurien_Win", "a", "2&%!MRAD_ctwin");
	register_event("SendAudio", "Round_End", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");

	register_forward( FM_ClientUserInfoChanged, "Fwd_ClientUserInfoChanged");
	
	RegisterHam(Ham_Killed, "player", "ev_DeathMsg");
	
	if(get_pcvar_num(g_iCvarSave) == 1)
		iVault = nvault_open( VAULT_NAME );
	
	if(get_pcvar_num(g_iCvarSave) == 2)
	{
		//iVault = fvault_load( VAULT_NAME );
		fvault_load( VAULT_NAME );
	}
	
	if(get_pcvar_num(g_iCvarSave) == 3)
		MySQLInit();
	
	if( iVault == INVALID_HANDLE )
	set_fail_state( "nValut returned invalid handle !" );
	
	#if defined BUDGET
	register_event( "HLTV", "start_round", "a", "1=0", "2=0" );
	#endif

	if(!dir_exists(backup_file_dir)) mkdir(backup_file_dir);
	Backup();
}

MySQLInit()
{
	g_Sqlx = SQL_MakeDbTuple(SQLX_HOSTNAME, SQLX_USERNAME, SQLX_PASSWORD, SQLX_DBNAME);

	static query[256];
	formatex(query, sizeof(query) - 1, "CREATE TABLE IF NOT EXISTS %s (ID INT(10) UNSIGNED AUTO_INCREMENT, Player VARCHAR(35) NOT NULL PRIMARY KEY, Credits INT(10) NOT NULL, KEY `ID` (`ID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", VAULT_NAME);
	SQL_ThreadQuery(g_Sqlx, "QueryOK", query);
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

public _fcs_set_user_credits( iPlugin, iParams )
{
	new id = get_param( 1 );
	new current = g_iUserCredits[ id ];
	g_iUserCredits[ id ] = max( 0, get_param( 2 ) );
	// SaveCredits( id );
	new after = g_iUserCredits[ id ];
	after -= current;

	if(after != 0)
	{
		if(HC_AllOFF(id))
		{
		}
		else
		{
			set_dhudmessage(0, 255, 0, -1.0, 0.6, 0, 0.0, 5.0, 0.0, 1.5);
			show_dhudmessage(id, "%s%d Credits", after > 0 ? "+":"", after);
		}
	}

	return g_iUserCredits[ id ];
}

public client_putinserver( id )
{
	new ip[32];
	get_user_ip(id, ip, 31);

	if( equali(ip, "127.0.0.1") )
	{
		fcs_set_user_credits( id, random_num(150, 400) );
	}
	
	if( is_user_bot( id ) || is_user_hltv( id ) )
		return PLUGIN_CONTINUE;

	LoadCredits( id );
	g_iUserTime[ id ] = 0;
	
	return PLUGIN_CONTINUE;
}

public client_connect( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
	
	get_user_name( id, g_szName[ id ], sizeof ( g_szName[] ) -1 );
	data_loaded[id] = false;
	
	return PLUGIN_CONTINUE;
}

public client_disconnected( id )
{
	if( is_user_bot( id ) )
		return PLUGIN_CONTINUE;
		
	SaveCredits( id );
	g_iUserTime[ id ] = 0;
	
	return PLUGIN_CONTINUE;
}

#if defined BUDGET
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
			case 1: ColorChat( i, RED, "^x04%s^x01 The budget of^x03 Furiens^x01 is^x04 %d Credits^x01 !", g_szTag, credite_t );
		 	case 1: ColorChat( i, RED, "^x04%s^x01 The budget of^x03 Anti-Furiens^x01 is^x04 %d Credits^x01 !", g_szTag, credite_ct );
		}
	}
}
#endif

public task_PTRFunction( )
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
		
		new iTime;
		iTime = get_pcvar_num( g_iCvarPTRMinutes ) ;
		
		if( g_iUserTime[ id ] >= iTime * 60 )
		{
			g_iUserTime[ id ] -= iTime * 60;
			
			new iCredits = get_pcvar_num( g_iCvarPTRCredits );
			
			fcs_add_user_credits( id, iCredits );
			ColorChat( id, RED, "^x04%s^x01 You earned^x03 %i^x01 Credits for Playing^x03 %i^x01 minutes!", g_szTag, iCredits, iTime );
		}
	}
}

public ev_DeathMsg(const iVictim, const iKiller)
{
	if( get_pcvar_num( g_iCvarEnable ) != 1 )
		return;

	if(!iKiller || !is_user_connected(iKiller))
		return;
		
	if( iKiller == iVictim )
		return;
		
	new iWeapon = get_user_weapon(iKiller);

	new iCredits = get_pcvar_num( g_iCvarCredits );
	
	if( get_pdata_int(iVictim, 75, 5) == HIT_HEAD )
		iCredits += get_pcvar_num( g_iCvarHSCredits );

	if(cs_get_user_team(iKiller) == CS_TEAM_CT && cs_get_user_team(iVictim) == CS_TEAM_T && iWeapon == CSW_KNIFE)
		iCredits += get_pcvar_num( g_iCvarCTKnifeCredits );
	
	if(iCredits > 0)
	{
		fcs_add_user_credits( iKiller, iCredits );
	}
}

public bomb_planted( iPlanter )
{
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iPlanted = get_pcvar_num( g_iCvarPlanted );
	
	if( iPlanted == 0 || !is_user_connected( iPlanter ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iPlanter, iPlanted );
	new szPlanter[ 32 ];
	get_user_name( iPlanter, szPlanter, sizeof ( szPlanter ) -1 );
	ColorChat( 0, RED, "^x04%s ^x01The Player^x04 %s^x01 earned^x03 %i^x01 Credits for Planting The bomb!", g_szTag, szPlanter, iPlanted );
	
	return PLUGIN_CONTINUE;
}

public bomb_explode( iPlanter, iDefuser )
{
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iExplode = get_pcvar_num( g_iCvarExplode );
	
	if( iExplode == 0 || !is_user_connected( iPlanter ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iPlanter, iExplode );
	new szPlanter[ 32 ];
	get_user_name( iPlanter, szPlanter, sizeof ( szPlanter ) -1 );
	ColorChat( 0, RED, "^x04%s ^x01The Player^x04 %s^x01 earned^x03 %i^x01 Credits for bomb Exploding!", g_szTag, szPlanter, iExplode );

	return PLUGIN_CONTINUE;
}

public bomb_defused( iDefuser )
{
	if( get_pcvar_num( g_iCvarEnableBE ) == 0 )
		return PLUGIN_CONTINUE;
		
	new iDefused = get_pcvar_num( g_iCvarDefused );
	
	if( iDefused == 0 || !is_user_connected( iDefuser ) )
		return PLUGIN_CONTINUE;
		
	fcs_add_user_credits( iDefuser, iDefused );
	new szDefuser[ 32 ];
	get_user_name( iDefuser, szDefuser, sizeof ( szDefuser ) -1 );
	ColorChat( 0, RED, "^x04%s ^x01The Player^x04 %s^x01 earned^x03 %i^x01 Credits for Defusing The bomb!", g_szTag, szDefuser, iDefused );
	
	return PLUGIN_CONTINUE;
}

public BuyCredits(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rBuy Credits:", "BuyCreditsHandler");

	menu_additem(menu, "\r[  \y10 \wCredits  \r] \w- \r[\y3000$\r]", "", 0);
	menu_additem(menu, "\r[  \y20 \wCredits  \r] \w- \r[\y4000$\r]", "", 0);
	menu_additem(menu, "\r[  \y30 \wCredits  \r] \w- \r[\y5000$\r]", "", 0);
	menu_additem(menu, "\r[  \y40 \wCredits  \r] \w- \r[\y6000$\r]", "", 0);
	menu_additem(menu, "\r[  \y50 \wCredits  \r] \w- \r[\y8000$\r]", "", 0);
	menu_additem(menu, "\r[  \y70 \wCredits  \r] \w- \r[\y10000$\r]", "", 0);
	menu_additem(menu, "\r[  \y80 \wCredits  \r] \w- \r[\y13000$\r]", "", 0);
	menu_additem(menu, "\r[ \y100 \wCredits  \r] \w- \r[\y16000$\r]", "", 0);

	menu_addblank(menu, 1); 
	menu_additem(menu, "Exit", "MENU_EXIT"); 

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_setprop(menu, MPROP_NOCOLORS, 1);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public BuyCreditsHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		{
			new money = cs_get_user_money(id) - 3000;
			new iCredits = fcs_get_user_credits(id) + 10;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 10 Credits^x01.", g_szTag);
			}
		}
		case 1:
		{
			new money = cs_get_user_money(id) - 4000;
			new iCredits = fcs_get_user_credits(id) + 20;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 20 Credits^x01.", g_szTag);
			}
		}
		case 2:
		{
			new money = cs_get_user_money(id) - 5000;
			new iCredits = fcs_get_user_credits(id) + 30;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 30 Credits^x01.", g_szTag);
			}
		}
		case 3:
		{
			new money = cs_get_user_money(id) - 6000;
			new iCredits = fcs_get_user_credits(id) + 40;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 40 Credits^x01.", g_szTag);
			}
		}
		case 4:
		{
			new money = cs_get_user_money(id) - 8000;
			new iCredits = fcs_get_user_credits(id) + 50;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 50 Credits^x01.", g_szTag);
			}
		}
		case 5:
		{
			new money = cs_get_user_money(id) - 10000;
			new iCredits = fcs_get_user_credits(id) + 70;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 70 Credits^x01.", g_szTag);
			}
		}
		case 6:
		{
			new money = cs_get_user_money(id) - 13000;
			new iCredits = fcs_get_user_credits(id) + 80;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 80 Credits^x01.", g_szTag);
			}
		}
		case 7:
		{
			new money = cs_get_user_money(id) - 16000;
			new iCredits = fcs_get_user_credits(id) + 100;

			if( money < 0 )
			{
				ColorChat(id, RED, "^x04%s^x01 You Don't Have Enough^x03 Money^x01.", g_szTag);
				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money( id, money );
				fcs_add_user_credits( id, iCredits );
				ColorChat(id, RED, "^x04%s^x01 You've bought^x03 100 Credits^x01.", g_szTag);
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Furien_Win()
{
	new id, iPlayers[ 32 ], iNum, TPlayers[ 32 ], TNum, CTPlayers[ 32 ], CTNum, CreditsBonus = 5;

	get_players( iPlayers, iNum );
	get_players( TPlayers, TNum, "ahe", "TERRORIST" );
	get_players( CTPlayers, CTNum, "bhe", "CT" );
	
	if( iNum < 6 )
		return;

	if( assassin_mod(id) || ghost_mod(id) )
	{
		CreditsBonus += CTNum;
	}

	if(CreditsBonus <= 0)
		return;
	
	for( new i = 0; i < TNum; i++ )
	{
		fcs_add_user_credits( TPlayers[ i ], CreditsBonus );
	}
}

public AntiFurien_Win()
{
	new id, iPlayers[ 32 ], iNum, TPlayers[ 32 ], TNum, CTPlayers[ 32 ], CTNum, CreditsBonus = 10;

	get_players( iPlayers, iNum );
	get_players( CTPlayers, CTNum, "ahe", "CT" );
	get_players( TPlayers, TNum, "bhe", "TERRORIST" );
	
	if( iNum < 6 )
		return;

	if( sniper_mod(id) )
	{
		CreditsBonus += TNum;
	}

	if(CreditsBonus <= 0)
		return;
	
	for( new i = 0; i < CTNum; i++ )
	{
		fcs_add_user_credits( TPlayers[ i ], CreditsBonus );
	}
}

public Round_End()
{
	new iPlayers[ 32 ], iPlayersNum;

	get_players( iPlayers, iPlayersNum, "ch" );
	for( new i = 0; i < iPlayersNum ; i++ )
	{
		SaveCredits( iPlayers[ i ] );
	}
}

public ClCmdSayShowAllCredits( id )
{
	ColorChat( id, RED, "^x04%s^x01 You Have^x03 %i^x01 Credits.", g_szTag, g_iUserCredits[ id ] );

	new menu = menu_create("\d[\yGeek~Gamers\d] \rPlayers Credits \wMenu:", "ClCmdSayShowAllCredits_Handle");
	
	new name[32], pid[32], players[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 
		formatex(text, charsmax(text), "%s \y- \r[ Credits: \y%i \r]", name, g_iUserCredits[ tempid ]);
		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public ClCmdSayShowAllCredits_Handle(id, menu, item)
{
	if(item == MENU_EXIT) return PLUGIN_HANDLED;
	
	ClCmdSayShowAllCredits(id);
	return PLUGIN_CONTINUE;
}

public ClCmdGiveCredits( id )
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "You have no access to this command!" );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_give_credits < Name / @ALL / @T / @CT > <Credits>" );
		return PLUGIN_HANDLED;
	}
	
	new iPlayers[ 32 ];
	new iPlayersNum;
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
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
					// SaveCredits( id );
					ColorChat( 0, RED, "^x04^%s^x01 OWNER^x03 %s^x01 Give^x03 %i^x01 Credits To all Players!", g_szTag, szName, iCredits );
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
						client_cmd( id, "echo There is no Furien in The Server!" );
						return PLUGIN_HANDLED;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					// SaveCredits( id );
					ColorChat( 0, RED, "^x04^%s^x01 OWNER^x03 %s^x01 Give^x03 %i^x01 Credits To all Furien Players!", g_szTag, szName, iCredits );
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
						client_cmd( id, "echo There is no Anti-Furien in The Server!" );
						return PLUGIN_HANDLED;
					}
					for( new i = 0; i < iPlayersNum ; i++ )
						g_iUserCredits[ iPlayers[ i ] ] += iCredits;
						
					new szName[ 32 ];
					get_user_name( id, szName, sizeof ( szName ) -1 );
					// SaveCredits( id );
					ColorChat( 0, RED, "^x04^%s^x01 OWNER^x03 %s^x01 Give^x03 %i^x01 Credits To all Anti-Furien Players!", g_szTag, szName, iCredits );
					return PLUGIN_HANDLED;
				}
			}
		}
	}
		
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Player %s not found!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] += iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	// SaveCredits( id );
	ColorChat( 0, RED, "^x04%s^x01 OWNER^x03 %s^x01 Give^x03 %i^x01 Credits To^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return PLUGIN_HANDLED;
}

public ClCmdTakeCredits( id )
{
	
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) )
	{
		client_cmd( id, "You have no access to this command!" );
		return PLUGIN_HANDLED;
	}
	
	new szFirstArg[ 32 ], szSecondArg[ 10 ];
	
	read_argv( 1, szFirstArg, sizeof ( szFirstArg ) -1 );
	read_argv( 2, szSecondArg, sizeof ( szSecondArg ) -1 );
	
	if( equal( szFirstArg, "" ) || equal( szSecondArg, "" ) )
	{
		client_cmd( id, "echo amx_take_credits < Name > < credits >" );
		return PLUGIN_HANDLED;
	}
	
	new iCredits = str_to_num( szSecondArg );
	if( iCredits <= 0 )
	{
		return PLUGIN_HANDLED;
	}
			
	new iPlayer = cmd_target( id, szFirstArg, 8 );
	if( !iPlayer )
	{
		client_cmd( id, "echo Player %s not found!", szFirstArg );
		return PLUGIN_HANDLED;
	}
	
	if( g_iUserCredits[ iPlayer ] < iCredits )
	{
		client_cmd( id, "echo Player %s don't have enough Credits to remove", szFirstArg, g_iUserCredits[ iPlayer ] );
		return PLUGIN_HANDLED;
	}
	
	g_iUserCredits[ iPlayer ] -= iCredits;
	
	new szName[ 32 ], _szName[ 32 ];
	get_user_name( id, szName, sizeof ( szName ) -1 );
  	get_user_name( iPlayer, _szName, sizeof ( _szName ) -1 );
	
	ColorChat( 0, RED, "^x04%s^x01 OWNER^x03 %s^x01 Remove^x03 %i^x01 Credits of^x03 %s^x01.", g_szTag, szName, iCredits, _szName );
	
	return PLUGIN_HANDLED;
}

public CreditsMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rCredits Menu:", "CreditsMenuHandler");

	menu_additem(menu, "Get Credits^n", "", 0);

	menu_additem(menu, "\yGive Credits", "", 0);
	menu_additem(menu, "\yRemove Credits^n", "", 0);

	menu_additem(menu, "\yGive Credits To All \rFuriens", "", 0);
	menu_additem(menu, "\yGive Credits To All \rAnti-Furiens^n", "", 0);

	menu_additem(menu, "\yGive Credits To All \rPlayers", "", 0);

	menu_setprop(menu, MPROP_NOCOLORS, 1);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public CreditsMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0: client_cmd(id, "getcredits");
		case 1: client_cmd(id, "givecredits");
		case 2: client_cmd(id, "removecredits");
		case 3: client_cmd(id, "givecreditstero");
		case 4: client_cmd(id, "givecreditsct");
		case 5: client_cmd(id, "givecreditsall");
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Get_Credits(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	client_cmd(id, "messagemode ^"GetCredits %i^"", id);

	return PLUGIN_CONTINUE;
}

public Get_Credits_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}
   
	new amount = str_to_num(param);

	new name[2][32];
	get_user_name(id, name[0], 31);

	client_cmd(id, "amx_give_credits ^"%s^" ^"%d^"", name[0], amount);

	return 0;
}

public GiveCreditsMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new players[32], num;

	get_players(players, num, "ch");
	if (num <= 1)
		return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rChoose a Player To Give Credits:", "GiveCreditsMenuHandler");
	
	new name[32], pid[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 
		formatex(text, charsmax(text), "%s \y- \r[ Credits: \y%i \r]", name, g_iUserCredits[tempid]);
		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	return PLUGIN_CONTINUE;
}

public GiveCreditsMenuHandler(id, menu, item)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6];
	menu_item_getinfo(menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	new player = str_to_num(data);
	client_cmd(id, "messagemode ^"GiveCredits %i^"", player);
	return PLUGIN_CONTINUE;
}

public Give_Credits_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}
   
	new amount = str_to_num(param);

	if( amount <= 0 )
		return 0;

	read_argv(1, param, charsmax(param));
	new player = str_to_num(param);

	new name[2][32];
	get_user_name(player, name[1], 31);

	client_cmd(id, "amx_give_credits ^"%s^" ^"%d^"", name[1], amount);

	return 0;
}

public RemoveCreditsMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new players[32], num;

	get_players(players, num, "ch");
	if (num <= 1)
		return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rChoose a Player To Remove Credits:", "RemoveCreditsMenuHandler");
	
	new name[32], pid[32], text[555 char], pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 
		formatex(text, charsmax(text), "%s \y- \r[ Credits: \y%i \r]", name, g_iUserCredits[tempid]);
		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	return PLUGIN_CONTINUE;
}

public RemoveCreditsMenuHandler(id, menu, item)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6];
	menu_item_getinfo(menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	new player = str_to_num(data);
	client_cmd(id, "messagemode ^"RemoveCredits %i^"", player);

	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public Remove_Credits_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}

	new amount = str_to_num(param);

	read_argv(1, param, charsmax(param));
	new player = str_to_num(param);

	new name[2][32];
	get_user_name(player, name[1], 31);

	client_cmd(id, "amx_remove_credits ^"%s^" ^"%d^"", name[1], amount);

	return 0;
}

public GiveCreditsTeroMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	client_cmd(id, "messagemode ^"GetCreditsTero^"");
	return PLUGIN_CONTINUE;
}

public Give_CreditsTero_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}

	new amount = str_to_num(param);
	client_cmd(id, "amx_give_credits @T ^"%d^"", amount);

	return 0;
}

public GiveCreditsCTMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	client_cmd(id, "messagemode ^"GetCreditsCT^"");
	return PLUGIN_CONTINUE;
}

public Give_CreditsCT_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}

	new amount = str_to_num(param);
	client_cmd(id, "amx_give_credits @CT ^"%d^"", amount);

	return 0;
}

public GiveCreditsAllMenu(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	client_cmd(id, "messagemode ^"GetCreditsAll^"");
	return PLUGIN_CONTINUE;
}

public Give_CreditsAll_Msg(id)
{
	if( !( get_user_flags( id ) & read_flags( g_szGiveCreditsFlag ) ) ) return PLUGIN_HANDLED;

	new param[6];
	read_argv(2, param, charsmax(param));

	for (new x; x < strlen(param); x++)
	{   	    
		if(!isdigit(param[x]))
		{
			return 0;
 		}  
	}

	new amount = str_to_num(param);
	client_cmd(id, "amx_give_credits @ALL ^"%d^"", amount);

	return 0;
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
	/*iVault = nvault_open( VAULT_NAME );
	
	if( iVault == INVALID_HANDLE )
	{
		set_fail_state( "nValut returned invalid handle!" );
	}*/
	if(is_user_bot(id)) return;
	
	data_loaded[id] = false;
	
	static szData[ 256 ];
	
	if( get_pcvar_num( g_iCvarSave ) == 1 )
	{
		static iTimestamp;
		
		if( nvault_lookup( iVault, g_szName[ id ], szData, sizeof ( szData ) -1, iTimestamp ) )
		{ // mesaj?
			static szCredits[ 15 ];
			parse( szData, szCredits, sizeof ( szCredits ) -1 );
			g_iUserCredits[ id ] = str_to_num( szCredits );
			data_loaded[id] = true;
			return;
		}
		else
		{
			g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
			data_loaded[id] = true;
			
			/*if( g_iUserEntry[ id ] ) //de facut cu for = 0/1
			{
				set_task( 41.5, "MESAJ", id );
			}*/
			//is user connected
			//set_task( 48.5, "MESAJ", id );
		}
	}
	
	if( get_pcvar_num( g_iCvarSave ) == 2 )
	{
		//if( fvault_get_data( VAULT_NAME, g_szName[ id ], szData, charsmax ( szData ), iTimestamp ) )
		if( fvault_get_data( VAULT_NAME, g_szName[ id ], szData, sizeof ( szData ) -1 ) )
		{ // mesaj?
			//static szCredits[ 15 ];
			//parse( szData, szCredits, sizeof ( szCredits ) -1 );
			//g_iUserCredits[ id ] = str_to_num( szCredits );
			g_iUserCredits[ id ] = str_to_num( szData );
			data_loaded[id] = true;
			//return;
		}
		else
		{
			g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
			data_loaded[id] = true;
			
			/*if( g_iUserEntry[ id ] ) //de facut cu for = 0/1
			{
				set_task( 41.5, "MESAJ", id );
			}*/
			//is user connected
			//set_task( 48.5, "MESAJ", id );
		}
	}
	
	//nvault_close( iVault );

	if( get_pcvar_num( g_iCvarSave ) == 3 )
	{
		static query[ 256 ], data[1]; data[ 0 ] = id;
		
		formatex( query, sizeof(query) - 1, "SELECT * FROM `%s` WHERE `Player` = ^"%s^"", VAULT_NAME, g_szName[ id ] );
		SQL_ThreadQuery( g_Sqlx, "QueryLoadPlayer", query, data, 1 );
	}

	if( get_user_flags(id) & read_flags(g_szGiveCreditsFlag) ) {
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarAdminEntry );
		data_loaded[id] = true;
	}
}

public SaveCredits( id )
{
	/*iVault = nvault_open( VAULT_NAME );
	
	if( iVault == INVALID_HANDLE )
	{
		set_fail_state( "nValut returned invalid handle!" );
	}*/
	if(!data_loaded[id]) return;

	if(is_user_bot(id)) return;
	
	static szData[ 256 ];
	formatex( szData, sizeof ( szData ) -1, "%i", g_iUserCredits[ id ] ); // de pus ^" ^"
	
	if( get_pcvar_num( g_iCvarSave ) == 1 )
		nvault_set( iVault, g_szName[ id ], szData );
	
	if( get_pcvar_num( g_iCvarSave ) == 2 )
		fvault_set_data( VAULT_NAME, g_szName[ id ], szData );

	if( get_pcvar_num( g_iCvarSave ) == 3 )
	{
		static query[ 256 ];
		
		formatex( query, sizeof( query ) - 1, "INSERT INTO `%s` (`Player`, `Credits`) VALUES (^"%s^", ^"%d^") ON DUPLICATE KEY UPDATE `Credits` = ^"%d^"", VAULT_NAME, g_szName[ id ], g_iUserCredits[ id ], g_iUserCredits[ id ] );
		SQL_ThreadQuery (g_Sqlx, "QueryOK", query );
	}
	
	//nvault_close( iVault );
}

public plugin_end( )
{
	/*iVault = nvault_open( VAULT_NAME );
	
	if( iVault == INVALID_HANDLE )
	{
		set_fail_state( "nValut returned invalid handle!" );
	}*/
		
	new iDays = get_pcvar_num( g_iCvarPruneDays );

	if( iDays <= 0 )
		return;
	
	if( get_pcvar_num( g_iCvarSave ) == 1 )
	{
		nvault_prune( iVault, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
		nvault_close( iVault );
	}
	
	if( get_pcvar_num( g_iCvarSave ) == 2 )
	{
		fvault_prune( VAULT_NAME, 0, get_systime( ) - ( iDays * ONE_DAY_IN_SECONDS ) );
		//nvault_close( iVault );
	}
}

public QueryOK( failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime )
{
	if( failstate )
	{
		return SQL_Error( query, error, errcode, failstate );
	}

	return SQL_FreeHandle( query );
}

public QueryLoadPlayer( failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime )
{
	if( failstate )
	{
		return SQL_Error( query, error, errcode, failstate );
	}

	new id = data[ 0 ];
	if( SQL_AffectedRows(query) < 1 )
	{
		g_iUserCredits[ id ] = get_pcvar_num( g_iCvarEntry );
		data_loaded[id] = true;

		return SQL_FreeHandle( query );
	}

	new i_ColCredits = SQL_FieldNameToNum( query, "Credits" );
	g_iUserCredits[ id ] = SQL_ReadResult( query, i_ColCredits );
	
	if( g_iUserCredits[ id ] > get_pcvar_num(g_iCvarMaxCredits) && g_iUserCredits[ id ] < get_pcvar_num(g_iCvarMaxCredits) + 2000 )
		g_iUserCredits[ id ] = get_pcvar_num(g_iCvarMaxCredits);
		
	data_loaded[id] = true;
	
	return SQL_FreeHandle( query );
}

stock SQL_Error( Handle:query, const error[], errornum, failstate )
{
	static qstring[ 512 ];
	SQL_GetQueryString( query, qstring, 1023 );
	
	if( failstate == TQUERY_CONNECT_FAILED ) 
	{
		set_fail_state( "%s [SQLX] Could not connect to database!", g_szTag );
	}
	else if ( failstate == TQUERY_QUERY_FAILED ) 
	{
		set_fail_state( "%s [SQLX] Query failed!", g_szTag );
	}
	
	log_amx( "%s [SQLX] Error '%s' with '%s'", g_szTag, error, errornum );
	log_amx( "%s [SQLX] %s", g_szTag, qstring );
	
	return SQL_FreeHandle( query );
}
/*
stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	if( id == 0 || is_user_connected( id ) )
	{
		new szMessage[ 256 ];

		format_args( szMessage ,charsmax( szMessage ) , 1 );

		message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
		write_byte( strlen( szMessage ) + 2 )
		write_byte( 10 )
		write_string( szMessage )
		message_end()
	}
}
*/

// |-- Backup --|

public Backup()
{
	if(!get_pcvar_num(g_iCvarBackup))
		return;

	new szFile1[ 300 ], szFile2[ 300 ];

	new iYear, iMonth, iDay;
	date(iYear, iMonth, iDay);

	formatex( szFile1 , charsmax( szFile1 ), "%s/gg-credits.txt", file_dir );
	formatex( szFile2 , charsmax( szFile2 ), "%s/gg-credits-%d-%d-%d.txt", backup_file_dir, iYear, iMonth, iDay);

	if(file_exists(szFile1) && !file_exists(szFile2))
	{
		fcopy(szFile1, szFile2);
	}
}

// |-- Copy File --|

#define BUFFERSIZE	256

enum FWrite
{
	FW_NONE = 0,
	FW_DELETESOURCE = (1<<0),
	FW_CANOVERRIDE = (1<<1)
}

stock fcopy(read_path[300], dest_path[300], FWrite:flags = FW_NONE)
{
	// Prepare for read
	new fp_read = fopen(read_path, "rb");

	// No file to read, errors!
	if (!fp_read)
	{
		fclose(fp_read);
		return 0;
	}

	// If the native cannot override
	if (file_exists(dest_path) && !(flags & FW_CANOVERRIDE))
	{
		return 0;
	}

	// Prepare for write
	new fp_write = fopen(dest_path, "wb");

	// Used for copying
	static buffer[BUFFERSIZE];
	static readsize;

	// Find the size of the files
	fseek(fp_read, 0, SEEK_END);
	new fsize = ftell(fp_read);
	fseek(fp_read, 0, SEEK_SET);

	// Here we copy the info
	for (new j = 0; j < fsize; j += BUFFERSIZE)
	{
		readsize = fread_blocks(fp_read, buffer, BUFFERSIZE, BLOCK_CHAR);
		fwrite_blocks(fp_write, buffer, readsize, BLOCK_CHAR);
	}

	// Close the files
	fclose(fp_read);
	fclose(fp_write);

	// Can delete source?
	if (flags & FW_DELETESOURCE)
		delete_file(read_path);

	// Success
	return 1;
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