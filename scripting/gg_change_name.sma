#include <amxmodx>
#include <amxmisc>
#include <sqlx>

static const SQLX_HOSTNAME[] =	"127.0.0.1";
static const SQLX_USERNAME[] =	"gg_cs16_db";
static const SQLX_PASSWORD[] =	"GGCS16@Db";
static const SQLX_DBNAME[]   =	"gg_furien";

static Handle: g_Sqlx;

new g_wlsave/*, g_wltable*/;
new const whitelistfile[] = "gg_whitelist.ini";
new Array:WhiteList;

public plugin_init()
{
	register_plugin("[GG] Change Whitelisted Name", "1.0", "~D4rkSiD3Rs~");
	
	g_wlsave	= register_cvar("amx_whitelist_save", "1", ADMIN_LEVEL_B); // file (0) - MySQL (1)
	// g_wltable	= register_cvar("rs_table", "whitelist", ADMIN_LEVEL_B);
	
	MySQLInit();

	WhiteList = ArrayCreate(32, 1);
	read_user_from_file();
}

public plugin_natives()
{
	register_native("WhiteListed", "_WhiteListed", 1);
}

MySQLInit()
{
	if(get_pcvar_num(g_wlsave) != 1)
		return;
	
	g_Sqlx = SQL_MakeDbTuple(SQLX_HOSTNAME, SQLX_USERNAME, SQLX_PASSWORD, SQLX_DBNAME);
}

public read_user_from_file()
{
	if(get_pcvar_num(g_wlsave) == 1)
	{
		static query[256];
		/*
		new table_name[32];
		get_pcvar_string(g_wltable, table_name, charsmax(table_name));
		*/
		formatex(query, sizeof(query) - 1, "SELECT * FROM `RegisterSystem_whitelist`");
		SQL_ThreadQuery(g_Sqlx, "QueryLoadWhiteList", query);
	}
	else
	{
		static user_file_url[64], config_dir[32];
		
		get_configsdir(config_dir, sizeof(config_dir));
		format(user_file_url, sizeof(user_file_url), "%s/%s", config_dir, whitelistfile);
		
		if(!file_exists(user_file_url))
			return;
		
		static file_handle, line_data[64], line_count;
		file_handle = fopen(user_file_url, "rt");
	
		while(!feof(file_handle))
		{
			fgets(file_handle, line_data, sizeof(line_data));
			
			replace(line_data, charsmax(line_data), "^n", "");
			
			if(!line_data[0] || line_data[0] == ';') 
				continue;
				
			ArrayPushString(WhiteList, line_data);
			line_count++;
		}

		fclose(file_handle);
	}
}

public client_connect(id)
{
	check_and_handle(id);
}

public check_and_handle(id)
{
	static name[64], Data[32];
	get_user_name(id, name, sizeof(name));
	
	for(new i = 0; i < ArraySize(WhiteList); i++)
	{
		ArrayGetString(WhiteList, i, Data, sizeof(Data))
		
		if(equali(name, Data))
		{
			if(!(contain(name, "<Geek-Gamers.com> Player") != -1))
			{
				force_cmd(id, "name ^"<Geek-Gamers.com> Player^"");
				force_cmd(id, "retry");
			}
		}
	}
}

public _WhiteListed(const PlayerName[])
{
	param_convert(1);
	
	for(new i = 0; i < ArraySize(WhiteList); i++)
	{
		static Data[32];
		ArrayGetString(WhiteList, i, Data, sizeof(Data))
		
		if(equali(PlayerName, Data))
		{
			return true;
		}
	}
	
	return false;
}

public QueryLoadWhiteList(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate)
	{
		return SQL_Error(query, error, errcode, failstate);
	}
	
	if(SQL_AffectedRows(query) < 1)
		return SQL_FreeHandle(query);
	
	new i_ColUser = SQL_FieldNameToNum(query, "User");
	
	while(SQL_MoreResults(query))
	{
		static name[64];
		SQL_ReadResult(query, i_ColUser, name, sizeof(name));
		
		ArrayPushString(WhiteList, name);
		
		SQL_NextRow(query);
	}
	
	return SQL_FreeHandle(query);
}

stock SQL_Error(Handle:query, const error[], errornum, failstate)
{
	static qstring[512];
	SQL_GetQueryString(query, qstring, 1023);
	
	if(failstate == TQUERY_CONNECT_FAILED) 
	{
		set_fail_state("[GG][WhiteList] [SQLX] Could not connect to database!");
	}
	else if (failstate == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[GG][WhiteList] [SQLX] Query failed!");
	}
	
	log_amx("[GG][WhiteList] [SQLX] Error '%s' with '%s'", error, errornum);
	log_amx("[GG][WhiteList] [SQLX] %s", qstring);
	
	return SQL_FreeHandle(query);
}

stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	new szMessage[ 256 ];

	format_args( szMessage ,charsmax( szMessage ) , 1 );

	message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
	write_byte( strlen( szMessage ) + 2 )
	write_byte( 10 )
	write_string( szMessage )
	message_end( )
}