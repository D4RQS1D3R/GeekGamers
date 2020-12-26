#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fvault_new>
#include <sqlx>
#include <cs_player_models_api>

//#define STEAMID
#define NICK
//#define IP

static const SQLX_HOSTNAME[] =	"127.0.0.1";
static const SQLX_USERNAME[] =	"gg_cs16_db";
static const SQLX_PASSWORD[] =	"GGCS16@Db";
static const SQLX_DBNAME[]   =	"gg_furien";

static Handle: g_Sqlx;

static const VAULT_NAME[ ] = "FurienClasses";

new g_save;
new FurienClass[33], HumanClass[33];

native get_level(id);

native class_furien(id);
native class_furien2(id);
native class_furien3(id);
native class_human(id);
native class_human2(id);
native class_human3(id);

native get_addmoney(id);
native get_addhp(id);
native get_adddamage(id);

public plugin_init()
{
	register_plugin("[GG] Furien Mod Classes", "1.0", "~D4rkSiD3Rs~");
	
	register_clcmd("say /class", "ClassesMenu");
	register_clcmd("say_team /class", "ClassesMenu");
	register_clcmd("say /furienclass", "FurienClassesMenu");
	register_clcmd("say_team /furienclass", "FurienClassesMenu");
	register_clcmd("say /humanclass", "HumanClassesMenu");
	register_clcmd("say_team /humanclass", "HumanClassesMenu");

	g_save		= register_cvar("amx_fclasses_save", "1", ADMIN_LEVEL_B); // file (0) - MySQL (1)

	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawnPost", true);

	MySQLInit();
}

public plugin_precache()
{
	precache_model("models/player/gg_furien/gg_furien.mdl");
	precache_model("models/player/gg_furien2/gg_furien2.mdl");
	precache_model("models/player/gg_furien3/gg_furien3.mdl");

	precache_model("models/player/gg_antifurien/gg_antifurien.mdl");
	precache_model("models/player/gg_antifurien/gg_antifurienT.mdl");
	precache_model("models/player/gg_antifurien2/gg_antifurien2.mdl");
	precache_model("models/player/gg_antifurien2/gg_antifurien2T.mdl");
	precache_model("models/player/gg_antifurien3/gg_antifurien3.mdl");
	precache_model("models/player/gg_antifurien3/gg_antifurien3T.mdl");

	return PLUGIN_CONTINUE
}

public plugin_natives()
{
	register_native("white_furien", "native_white_furien", 1);
	register_native("red_furien", "native_red_furien", 1);
	register_native("black_furien", "native_black_furien", 1);
	register_native("green_human", "native_green_human", 1);
	register_native("white_human", "native_white_human", 1);
	register_native("black_human", "native_black_human", 1);
}

MySQLInit()
{
	if(get_pcvar_num(g_save) != 1)
		return;

	g_Sqlx = SQL_MakeDbTuple(SQLX_HOSTNAME, SQLX_USERNAME, SQLX_PASSWORD, SQLX_DBNAME);

	static query[256];
	formatex(query, sizeof(query) - 1, "CREATE TABLE IF NOT EXISTS %s (ID INT(10) UNSIGNED AUTO_INCREMENT, Player VARCHAR(35) NOT NULL PRIMARY KEY, Furien INT(10) NOT NULL, AntiFurien INT(10) NOT NULL, KEY `ID` (`ID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", VAULT_NAME);
	SQL_ThreadQuery(g_Sqlx, "QueryOK", query);
}

public client_putinserver(id)
{
	if(is_user_bot(id))
	{
		FurienClass[id] = random_num(1,3);
		HumanClass[id] = random_num(1,3);
	}
	else LoadData(id);
}

public Ham_PlayerSpawnPost(id)
{
	if (!is_user_alive(id))
		return;

	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(FurienClass[id] == 1)
		{
			class_furien(id)
		}
		if(FurienClass[id] == 2)
		{
			class_furien2(id)
		}
		if(FurienClass[id] == 3)
		{
			class_furien3(id)
		}
	}
	else if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		if(HumanClass[id] == 1)
		{
			class_human(id)
		}
		if(HumanClass[id] == 2)
		{
			class_human2(id)
		}
		if(HumanClass[id] == 3)
		{
			class_human3(id)
		}
	}
}

public ClassesMenu(id)
{
	new menu = menu_create ("\d[\yGeek~Gamers\d] \rClasses Menu:", "ClassesMenuHandle");
	
	menu_additem(menu, "Furien Classes", "", 0);
	menu_additem(menu, "Human Classes", "", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0 );
}

public ClassesMenuHandle(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0: FurienClassesMenu(id);
		case 1: HumanClassesMenu(id);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public FurienClassesMenu(id)
{
	new menu = menu_create ("\d[\yGeek~Gamers\d] \rFurien \yClasses Menu:", "FurienClassesMenuHandle");
	
	new temp[101];
	formatex( temp, 100, "%sWhite Furien \r[ \y+%d \rMoney ]", FurienClass[id] == 1 ? "\y" : "\w", get_addmoney(id) );
	menu_additem(menu, temp, "", 0);
	
	new temp2[101];
	formatex( temp2, 100, "%sRed Furien \r[ \y+%d \rHealth ]", FurienClass[id] == 2 ? "\y" : "\w", get_addhp(id) );
	menu_additem(menu, temp2, "", 0);
	
	new temp3[101];
	formatex( temp3, 100, "%sBlack Furien \r[ \y+%d \rDamage ]", FurienClass[id] == 3 ? "\y" : "\w", get_adddamage(id) );
	menu_additem(menu, temp3, "", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0 );
}

public FurienClassesMenuHandle(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

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
			FurienClass[id] = 1;
			ChatColor(id, "!g[GG] !nYou choose the !tWhite Furien !nClass!");
			SaveData(id);
		}
		case 1:
		{
			FurienClass[id] = 2;
			ChatColor(id, "!g[GG] !nYou choose the !tRed Furien !nClass!");
			SaveData(id);
		}
		case 2:
		{
			FurienClass[id] = 3;
			ChatColor(id, "!g[GG] !nYou choose the !tBlack Furien !nClass!");
			SaveData(id);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public HumanClassesMenu(id)
{
	new menu = menu_create ("\d[\yGeek~Gamers\d] \rHuman \yClasses Menu:", "HumanClassesMenuHandle");
	
	new temp4[101];
	formatex( temp4, 100, "%sGreen Human \r[ \y+%d \rMoney ]", HumanClass[id] == 1 ? "\y" : "\w", get_addmoney(id) );
	menu_additem(menu, temp4, "", 0);
	
	new temp5[101];
	formatex( temp5, 100, "%sWhite Human \r[ \y+%d \rHealth ]", HumanClass[id] == 2 ? "\y" : "\w", get_addhp(id) );
	menu_additem(menu, temp5, "", 0);
	
	new temp6[101];
	formatex( temp6, 100, "%sBlack Human \r[ \y+%d \rDamage ]", HumanClass[id] == 3 ? "\y" : "\w", get_adddamage(id) );
	menu_additem(menu, temp6, "", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0 );
}

public HumanClassesMenuHandle(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

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
			HumanClass[id] = 1;
			ChatColor(id, "!g[GG] !nYou choose the !tGreen Human !nClass!");
			SaveData(id);
		}
		case 1:
		{
			HumanClass[id] = 2;
			ChatColor(id, "!g[GG] !nYou choose the !tWhite Human !nClass!");
			SaveData(id);
		}
		case 2:
		{
			HumanClass[id] = 3;
			ChatColor(id, "!g[GG] !nYou choose the !tBlack Human !nClass!");
			SaveData(id);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public SaveData(id)    
{
	new szMethod[ 65 ];

	#if defined STEAMID
	get_user_authid( id, szMethod, 34 );
	#endif

	#if defined NICK
	get_user_name( id, szMethod, 34 );
	#endif

	#if defined IP
	get_user_ip( id, szMethod, 34, 1 );
	#endif

	if(get_pcvar_num(g_save) == 1)
	{
		static query[256];
		
		formatex(query, sizeof(query) - 1, "INSERT INTO `%s` (`Player`, `Furien`, `AntiFurien`) VALUES (^"%s^", ^"%i^", ^"%i^") ON DUPLICATE KEY UPDATE `Player` = ^"%s^"", VAULT_NAME, szMethod, FurienClass[id], HumanClass[id], szMethod);
		SQL_ThreadQuery(g_Sqlx, "QueryOK", query);
	}
	else
	{
		new vaultkey[64], vaultdata[328];
		format(vaultkey, 63, "%s", szMethod);
		format(vaultdata, 327, "^"%i^" ^"%i^"", FurienClass[id], HumanClass[id]);
		fvault_set_data(VAULT_NAME, vaultkey, vaultdata);
	}
}

public LoadData(id)    
{
	new szMethod[ 65 ];

	#if defined STEAMID
	get_user_authid( id, szMethod, 34 );
	#endif

	#if defined NICK
	get_user_name( id, szMethod, 34 );
	#endif

	#if defined IP
	get_user_ip( id, szMethod, 34, 1 );
	#endif
	
	if(get_pcvar_num(g_save) == 1)
	{
		static query[256], data[1]; data[0] = id;
		
		formatex(query, sizeof(query) - 1, "SELECT * FROM `%s` WHERE `Player` = ^"%s^"", VAULT_NAME, szMethod);
		SQL_ThreadQuery(g_Sqlx, "QueryLoadPlayer", query, data, 1);
	}
	else
	{
		new vaultkey[64], vaultdata[328];
		format(vaultkey, 63, "%s", szMethod);
		format(vaultdata, 327, "^"%i^" ^"%i^"", FurienClass[id], HumanClass[id]);
		fvault_get_data(VAULT_NAME, vaultkey, vaultdata, charsmax(vaultdata));

		new furienclass[32], antifurienclass[32];
		parse(vaultdata, furienclass, charsmax(furienclass), antifurienclass, charsmax(antifurienclass));

		FurienClass[id] = str_to_num(furienclass);
		HumanClass[id] = str_to_num(antifurienclass);

		if(!FurienClass[id])
			FurienClass[id] = 1;

		if(!HumanClass[id])
			HumanClass[id] = 1;
	}
}

public QueryOK(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate)
	{
		return SQL_Error(query, error, errcode, failstate);
	}
        
	return SQL_FreeHandle(query);
}

public QueryLoadPlayer(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate)
	{
		return SQL_Error(query, error, errcode, failstate);
	}
	
	new id = data[0];
	if(SQL_AffectedRows(query) < 1)
	{
		FurienClass[id] = 1;
		HumanClass[id] = 1;
		
		return SQL_FreeHandle(query);
	}

	new i_ColFurien = SQL_FieldNameToNum(query, "Furien");
	new i_ColAntiFurien = SQL_FieldNameToNum(query, "AntiFurien");
	
	FurienClass[id] = SQL_ReadResult(query, i_ColFurien);
	HumanClass[id] = SQL_ReadResult(query, i_ColAntiFurien);

	return SQL_FreeHandle(query);
}

stock SQL_Error(Handle:query, const error[], errornum, failstate)
{
	static qstring[512];
	SQL_GetQueryString(query, qstring, 1023);
	
	if(failstate == TQUERY_CONNECT_FAILED) 
	{
		set_fail_state("[GG][%s] [SQLX] Could not connect to database!", VAULT_NAME);
	}
	else if (failstate == TQUERY_QUERY_FAILED) 
	{
		set_fail_state("[GG][%s] [SQLX] Query failed!", VAULT_NAME);
	}
	
	log_amx("[GG][%s] [SQLX] Error '%s' with '%s'", VAULT_NAME, error, errornum);
	log_amx("[GG][%s] [SQLX] %s", VAULT_NAME, qstring);
	
	return SQL_FreeHandle(query);
}

public native_white_furien(id)
{
	return FurienClass[id] == 1;
}

public native_red_furien(id)
{
	return FurienClass[id] == 2;
}

public native_black_furien(id)
{
	return FurienClass[id] == 3;
}

public native_green_human(id)
{
	return HumanClass[id] == 1;
}

public native_white_human(id)
{
	return HumanClass[id] == 2;
}

public native_black_human(id)
{
	return HumanClass[id] == 3;
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!t2", "^0");
	
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}