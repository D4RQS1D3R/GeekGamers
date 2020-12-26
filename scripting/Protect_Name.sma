#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <sqlx>
#include <geoip>
#include <amxmail>

#pragma compress 1

#define VERSION "10.0"
#define TASK_MESS 1000
#define TASK_KICK 2000
#define TASK_MENU 3000
#define TASK_TIMER 4000
#define TASK_ADVERT 5000
#define TASK_AJC 6000
#define AJC_TASK_TIME 0.1
#define AJC_ADMIN_FLAG ADMIN_IMMUNITY
#define SALT "8c4f4370c53e0c1e1ae9acd577dddbed"
#define MAX_NAMES 1000

//Start of CVAR pointers
new g_on;
new g_save;
new g_host;
new g_user;
new g_pass;
new g_db;
new g_table;
new g_regtime;
new g_logtime;
new g_ver_on;
new g_vertime;
new g_pass_length;
new g_chp_time;
new g_reg_log;
new g_chp_log;
new g_blind;
new g_comm;
new g_count;
new g_announce;
new g_advert;
new g_advert_int;
new g_ajc_team;
new g_ajc_admin;
new g_ajc_class[2];
new g_ajc_change;
new g_member;
new g_time;
new g_time_pass;
new g_whitelist;
new g_alogtime;
new g_alog_on;
//End of CVAR pointers

//Start of Arrays
new mysql_host[64];
new mysql_user[32];
new mysql_pass[32];
new mysql_db[128];
new mysql_table[128];
new configs_dir[64]
new cfg_file[256];
new reg_file[256];
new commands_file[256];
new whitelist_file[256];
new part_names[MAX_NAMES][32];
new starting_names[MAX_NAMES][32];
new ending_names[MAX_NAMES][32];
new count;
new sz_time[9];
new line = 0;
new text[512];
new params[2];
new player_name[33][34];
new player_authid[33][34];
new player_ip[33][34];
new player_country[33][34];
new check_name[33];
new check_client_data[35];
new check_hash[34];
new check_pass[34];
new check_email[34];
new query[512];
new Handle:g_sqltuple;
new password[33][34];
new passwd[33][34];
new adminpasswd[33][34];
new typedpass[32];
new typedemail[32];
new typedadminpass[32];
new hash[34];
new attempts[33];
new times[33];
new g_player_time[33];
new g_client_data[33][35];
new value;
new menu[512];
new keys;
new length;
new g_maxplayers;
new g_saytxt
new g_screenfade
new g_sync_hud
new temp1[2];
new temp2[2];
new temp_count;
new type;
new col_command;
new col_name;
new input[32];
new temp_name[32];
new flags[33];
new email[33][34];
new has_email[33];
new emailsent[33];
//End fo Arrays

//Start of Booleans
new bool:error = false
new bool:data_ready = false;
new bool:is_logged[33];
new bool:is_logged_a[33];
new bool:is_registered[33];
new bool:is_registered_old[33];
new bool:is_verified[33];
new bool:is_admin[33];
new bool:cant_change_pass[33];
new bool:changing_name[33];
new bool:name_checked[33];
new bool:admin_exist[33];
new bool:already[33];
new bool:is_true = false
//End of Booleans

//Start of Trie handles
new Trie:g_commands;
new Trie:g_login_times;
new Trie:g_cant_login_time;
new Trie:g_pass_change_times;
new Trie:g_cant_change_pass_time;
new Trie:g_full_nmaes;
//End of Trie handles

//Start of Natives
native assassin_mod(id);
native sniper_mod(id);
native ghost_mod(id);
//End of Natives

//Start of Constants
new const separator_1[] = "==============================================================================="
new const separator_2[] = "-------------------------------------------------------------------------------"
new const prefix[] = "[GG][Protect]";
//new const log_file[] = "addons/amxmodx/logs/GG_Logs/Register_System_Logs.txt";
new const JOIN_TEAM_MENU_FIRST[] = "#Team_Select";
new const JOIN_TEAM_MENU_FIRST_SPEC[] = "#Team_Select_Spect";
new const JOIN_TEAM_MENU_INGAME[] = "#IG_Team_Select";
new const JOIN_TEAM_MENU_INGAME_SPEC[] = "#IG_Team_Select_Spect";
new const JOIN_TEAM_VGUI_MENU = 2;

new const whitelistfile[] = "gg_whitelist.ini"

//Start of CVARs
new const g_InvalidCharacter[][] =  
{
	"!",
	"?",
	"#",
	"$",
	"%",
	"&",
	"'",
	"^"",
	"+",
	"-",
	"*",
	"/",
	"\",
	"=",
	"_",
	"`",
	"|",
	"(",
	")",
	"{",
	"}",
	"[",
	"]",
	"<",
	">",
	"~",
	",",
	":",
	";",
	"�",
	" "
};

new const g_cvars[][][] =
{
	{"rs_on", "1"},
	{"rs_save_type", "0"},
	{"rs_remember", "0"},
	{"rs_host", "127.0.0.1"},
	{"rs_user", "root"},
	{"rs_pass", "123456"},
	{"rs_db", "registersystem"},
	{"rs_table", "registersystem"},
	{"rs_register_time", "0"},
	{"rs_login_time", "40.0"},
	{"rs_password_len", "0"},
	{"rs_chngpass_times", "0"},
	{"rs_register_log", "1"},
	{"rs_chngpass_log", "1"},
	{"rs_blind", "1"},
	{"rs_commands", "1"},
	{"rs_count", "1"},
	{"rs_announce", "0"},
	{"rs_advert", "0"},
	{"rs_advert_int", "300.0"},
	{"rs_ajc_team", "5"},
	{"rs_ajc_class_t", "5"},
	{"rs_ajc_class_ct", "5"},
	{"rs_ajc_admin", "0"},
	{"rs_ajc_change", "0"},
	{"rs_cant_login_time", "300"},
	{"rs_cant_change_pass_time", "300"},
	{"rs_whitelist", "1"},
	{"rs_verf_on", "1"},
	{"rs_verf_time", "20.0"},
	{"rs_admin_login_on", "1"},
	{"rs_admin_login_time", "15.0"}
};
//End of CVARs
//End of Constants

/*==============================================================================
	Start of Plugin Init
================================================================================*/
public plugin_init()
{
	register_plugin("Register System", VERSION, "m0skVi4a ;]/~D4rkSiD3Rs~")

	g_on = register_cvar(g_cvars[0][0], g_cvars[0][1])
	g_save = register_cvar(g_cvars[1][0], g_cvars[1][1])
	g_member = register_cvar(g_cvars[2][0], g_cvars[2][1])
	g_host = register_cvar(g_cvars[3][0], g_cvars[3][1])
	g_user = register_cvar(g_cvars[4][0], g_cvars[4][1])
	g_pass = register_cvar(g_cvars[5][0], g_cvars[5][1])
	g_db = register_cvar(g_cvars[6][0], g_cvars[6][1])
	g_table = register_cvar(g_cvars[7][0], g_cvars[7][1])
	g_regtime = register_cvar(g_cvars[8][0], g_cvars[8][1])
	g_logtime = register_cvar(g_cvars[9][0], g_cvars[9][1])
	g_pass_length = register_cvar(g_cvars[10][0], g_cvars[10][1])
	g_chp_time = register_cvar(g_cvars[11][0], g_cvars[11][1])
	g_reg_log = register_cvar(g_cvars[12][0], g_cvars[12][1])
	g_chp_log = register_cvar(g_cvars[13][0], g_cvars[13][1])
	g_blind = register_cvar(g_cvars[14][0], g_cvars[14][1])
	g_comm = register_cvar(g_cvars[15][0], g_cvars[15][1])
	g_count = register_cvar(g_cvars[16][0], g_cvars[16][1])
	g_announce = register_cvar(g_cvars[17][0], g_cvars[17][1])
	g_advert = register_cvar(g_cvars[18][0], g_cvars[18][1])
	g_advert_int = register_cvar(g_cvars[19][0], g_cvars[19][1])
	g_ajc_team = register_cvar(g_cvars[20][0], g_cvars[20][1])
	g_ajc_class[0] = register_cvar(g_cvars[21][0], g_cvars[21][1])
	g_ajc_class[1] = register_cvar(g_cvars[22][0], g_cvars[22][1])
	g_ajc_admin = register_cvar(g_cvars[23][0], g_cvars[23][1])
	g_ajc_change = register_cvar(g_cvars[24][0], g_cvars[24][1])	
	g_time = register_cvar(g_cvars[25][0], g_cvars[25][1])
	g_time_pass = register_cvar(g_cvars[26][0], g_cvars[26][1])
	g_whitelist = register_cvar(g_cvars[27][0], g_cvars[27][1])
	g_ver_on = register_cvar(g_cvars[28][0], g_cvars[28][1])
	g_vertime = register_cvar(g_cvars[29][0], g_cvars[29][1])
	g_alog_on = register_cvar(g_cvars[30][0], g_cvars[30][1])
	g_alogtime = register_cvar(g_cvars[31][0], g_cvars[31][1])

	get_localinfo("amxx_configsdir", configs_dir, charsmax(configs_dir))
	formatex(cfg_file, charsmax(cfg_file), "%s/registersystem.cfg", configs_dir)
	formatex(reg_file, charsmax(reg_file), "%s/regusers.ini", configs_dir)
	formatex(commands_file, charsmax(commands_file), "%s/registersystem_commands.ini", configs_dir)
	formatex(whitelist_file, charsmax(whitelist_file), "%s/%s", configs_dir, whitelistfile)

	register_message(get_user_msgid("ShowMenu"), "TextMenu")
	register_message(get_user_msgid("VGUIMenu"), "VGUIMenu")
	register_menucmd(register_menuid("Register System Main Menu"), 1023, "HandlerMainMenu")

	register_clcmd("jointeam", "HookTeamCommands")
	register_clcmd("chooseteam", "HookTeamCommands")
	register_clcmd("Connecting", "Login")
	register_clcmd("SetPass", "Register")
	register_clcmd("NewPass", "ChangePassword")
	register_clcmd("SetEmail", "RegisterEmail")
	register_clcmd("AdminPassword", "Login_Admin")

	RegisterHam(Ham_Spawn, "player", "CloseMenu", 1)
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_ClientUserInfoChanged, "ClientInfoChanged")

	if(get_pcvar_num(g_alog_on))
	{
		register_event("SendAudio", "ReloadAdmins", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw")
	}
/*
	if(get_pcvar_num(g_alog_on))
	{
		set_task(200.0, "ReloadAdmins", _, _, _, "b");
	}
*/
	register_dictionary("register_system.txt")
	g_maxplayers = get_maxplayers()
	g_saytxt = get_user_msgid("SayText")
	g_screenfade = get_user_msgid("ScreenFade")
	g_sync_hud = CreateHudSyncObj()
	g_commands = TrieCreate()
	g_login_times = TrieCreate()
	g_cant_login_time = TrieCreate()
	g_pass_change_times = TrieCreate()
	g_cant_change_pass_time = TrieCreate()
	g_full_nmaes = TrieCreate()
}
/*==============================================================================
	End of Plugin Init
================================================================================*/

/*==============================================================================
	Start of Plugin Natives
================================================================================*/
public plugin_natives()
{
	register_library("register_system")
	register_native("is_registered", "_is_registered")
	register_native("is_logged", "_is_logged")
	register_native("get_cant_login_time", "_get_cant_login_time")
	register_native("get_cant_change_pass_time", "_get_cant_change_pass_time")
}

public _is_registered(plugin, parameters)
{
	if(parameters != 1)
		return false

	new id = get_param(1)

	if(!name_checked[id])
		return false

	if(!id)
		return false

	if(is_registered[id])
	{
		return true
	}

	return false
}

public _is_logged(plugin, parameters)
{
	if(parameters != 1)
		return false

	new id = get_param(1)

	if(!id)
		return false

	if(is_logged[id])
	{
		return true
	}

	return false
}

public _get_cant_login_time(plugin, parameters)
{
	if(parameters != 1)
		return -1

	new id = get_param(1)

	if(!id)
		return -1

	new data[35];

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, data, charsmax(data))
		}
		case 1:
		{
			get_user_ip(id, data, charsmax(data))
		}
		case 2:
		{
			get_user_authid(id, data, charsmax(data))
		}		
		default:
		{
			get_user_name(id, data, charsmax(data))
		}
	}

	if(TrieGetCell(g_cant_login_time, data, value))
	{
		new cal_time = get_pcvar_num(g_time) - (time() - value)
		return cal_time
	}

	return -1
}

public _get_cant_change_pass_time(plugin, parameters)
{
	if(parameters != 1)
		return -1

	new id = get_param(1)

	if(!id)
		return -1

	new data[35];

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, data, charsmax(data))
		}
		case 1:
		{
			get_user_ip(id, data, charsmax(data))
		}
		case 2:
		{
			get_user_authid(id, data, charsmax(data))
		}		
		default:
		{
			get_user_name(id, data, charsmax(data))
		}
	}

	if(TrieGetCell(g_cant_change_pass_time, data, value))
	{
		new cal_time = get_pcvar_num(g_time_pass) - (time() - value)
		return cal_time
	}

	return -1
}
/*==============================================================================
	End of Plugin Natives
================================================================================*/

/*==============================================================================
	Start of Executing plugin's config and choose the save mode
================================================================================*/
public plugin_cfg()
{
	if(!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on))
		return PLUGIN_HANDLED

	server_print(" ")
	server_print(separator_1)
	server_print("Title	: Register System")
	server_print("Version	: %s", VERSION)
	server_print("Author	: ~D4rkSiD3Rs~")
	server_print("Site	: https://www.facebook.com/GeekGamersPage/")
	server_print(separator_2)

	get_time("%H:%M:%S", sz_time, charsmax(sz_time))

	if(!file_exists(cfg_file))
	{
		server_print("[%s] [ERROR] > File registersystem.cfg not found!", sz_time)
		error = true
	}
	else
	{
		server_print("[%s] > Loading settings from registersystem.cfg", sz_time)

		line = 0, length = 0, count = 0, error = false;

		while(read_file(cfg_file, line++ , text, charsmax(text), length))
		{
			if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
				continue

			new cvar[32], param[32], bool:error_1 = true, bool:error_2 = true

			trim(text)
			parse(text, cvar, charsmax(cvar), param, charsmax(param))

			for(new i = 0; i <= charsmax(g_cvars); i++)
			{
				if(equal(cvar, g_cvars[i][0]))
				{
					error_1 = false
				}
			}

			if(param[0] && !(equali(param, " ")))
			{
				error_2 = false
			}

			if(error_1)
			{
				server_print("[%s] [ERROR] > Unknown CVAR ^"%s^"", sz_time, cvar)
				error = true
			}
			else
			{
				if(error_2)
				{
					server_print("[%s] [ERROR] > Bad value for ^"%s^"", sz_time, cvar)
					error = true
				}
				else
				{
					server_print("[%s] [OK] > Read cvar ^"%s^" ^"%s^"", sz_time, cvar, param)
					server_cmd("%s %s", cvar, param)
					count++
				}
			}
		}

		if(!count)
		{
			server_print("[%s] [ERROR] > There were no CVARs in registersystem.cfg", sz_time)
			error = true
		}
	}

	server_print(separator_2)

	if(error)
	{
		server_print("[%s] [WARNING] > Reading some data from configuration file failed!", sz_time)
		server_print("> Please check [ERROR] messages above for solving this problem!")
	}
	else
	{
		server_print("[%s] [OK] > All settings loaded successfully!", sz_time)
	}

	server_print(separator_1)
	server_print(" ")

	set_task(1.0, "LoadData")

	set_cvar_num("mp_limitteams", 32);
	set_cvar_num("sv_restart", 1);
	
	return PLUGIN_CONTINUE
}

public LoadData()
{
	if(get_pcvar_num(g_save))
	{
		Init_MYSQL()
		return
	}
	else
	{
		if(!file_exists(reg_file))
		{
			write_file(reg_file,";Register System file^n;Modifying may cause the clients to can not Login!^n^n")
			server_print("%s Could not find Register System file -  %s   Creating new...", prefix, reg_file)
		}
	}
	
	if(get_pcvar_num(g_comm) == 1)
	{
		line = 0, length = 0, count = 0, error = false;
		get_time("%H:%M:%S", sz_time, charsmax(sz_time))

		server_print(" ")
		server_print(separator_1)
		server_print(prefix)
		server_print(separator_2)

		if(!file_exists(commands_file))
		{
			server_print("[%s] [ERROR] > File registersystem_commands.ini not found!", sz_time)
			error = true
		}
		else
		{
			server_print("[%s] > Loading settings from registersystem_commands.ini", sz_time)

			line = 0, length = 0, count = 0;

			while(read_file(commands_file, line++ , text, charsmax(text), length))
			{
				if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
					continue

				trim(text)
				parse(text, text, charsmax(text))

				TrieSetCell(g_commands, text, 1)
				count++
			}

			if(count)
			{
				server_print("[%s] [OK] > %d command%s loaded!", sz_time, count, count > 1 ? "s" : "")
			}
			else
			{
				server_print("[%s] [ERROR] > There were no commands in registersystem_commands.ini", sz_time)
				error = true
			}
		}

		server_print(separator_2)

		if(error)
		{
			server_print("[%s] [WARNING] > Reading some data from commands file failed!", sz_time)
			server_print("> Please check [ERROR] messages above for solving this problem!")
		}
		else
		{
			server_print("[%s] [OK] > Commands file loaded successfully!", sz_time)
		}

		server_print(separator_1)
		server_print(" ")
	}
	
	if(get_pcvar_num(g_whitelist))
	{
		line = 0, length = 0, count = 0, error = false;
		get_time("%H:%M:%S", sz_time, charsmax(sz_time))

		server_print(" ")
		server_print(separator_1)
		server_print(prefix)
		server_print(separator_2)
		
		if(!file_exists(whitelist_file))
		{
			server_print("[%s] [ERROR] > File gg_whitelist.ini not found!", sz_time)
			error = true
		}
		else
		{
			server_print("[%s] > Loading settings from gg_whitelist.ini", sz_time)
	
			line = 0, length = 0, count = 0, error = false;
			new t_text[32];
			new count1  = 0, count2 = 0, count3 = 0, count4 = 0

			while(read_file(whitelist_file, line++ , t_text, charsmax(t_text), length))
			{
				if(!t_text[0] || t_text[0] == '^n' || t_text[0] == ';' || (t_text[0] == '/' && t_text[1] == '/'))
					continue
	
				trim(t_text)
				parse(t_text, t_text, charsmax(t_text))
				
				if(t_text[0] == '%')
				{
					if(t_text[strlen(t_text) - 1] == '%') //Part name
					{
						if(count1 >= MAX_NAMES)
							continue

						replace_all(t_text, charsmax(t_text), "%", "")
						part_names[count1++] = t_text
					}
					else //Ending name
					{
						if(count2 >= MAX_NAMES)
							continue

						replace_all(t_text, charsmax(t_text), "%", "")
						ending_names[count2++] = t_text
					}				
				}
				else // Starting name
				{
					if(t_text[strlen(t_text) - 1] == '%') 
					{
						if(count3 >= MAX_NAMES)
							continue

						replace_all(t_text, charsmax(t_text), "%", "")
						starting_names[count3++] = t_text
					}
					else //Full name
					{
						if(++count4 >= MAX_NAMES)
							continue

						replace_all(t_text, charsmax(t_text), "%", "")
						TrieSetCell(g_full_nmaes, t_text, 1)
					}
				}
		
				count++
			}
	
			if(count)
			{
				server_print("[%s] [OK] > %d name%s loaded!", sz_time, count, count > 1 ? "s" : "")
			}
			else
			{
				server_print("[%s] [ERROR] > There were no names in gg_whitelist.ini", sz_time)
				error = true
			}
		}
	
		if(error)
		{
			server_print("[%s] [WARNING] > Reading some data from whitelist file failed!", sz_time)
			server_print("> Please check [ERROR] messages above for solving this problem!")
		}
		else
		{
			server_print("[%s] [OK] > Whitelist file loaded successfully!", sz_time)
		}

		server_print(separator_1)
		server_print(" ")
	}

	data_ready = true

	for(new i = 1 ; i <= g_maxplayers ; i++)
	{
		if(!is_user_connecting(i) && !is_user_connected(i))
			continue

		if(get_pcvar_num(g_whitelist))
		{
			CheckName(i)
		}
		else
		{
			CheckClient(i)
		}
	}
}

public Init_MYSQL()
{
	get_pcvar_string(g_host, mysql_host, charsmax(mysql_host))
	get_pcvar_string(g_user, mysql_user, charsmax(mysql_user))
	get_pcvar_string(g_pass, mysql_pass, charsmax(mysql_pass))
	get_pcvar_string(g_db, mysql_db, charsmax(mysql_db))
	get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

	g_sqltuple = SQL_MakeDbTuple(mysql_host, mysql_user, mysql_pass, mysql_db)
	formatex(query, charsmax(query), "CREATE TABLE IF NOT EXISTS %s (ID INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY, User VARCHAR(35) NOT NULL, Password VARCHAR(34) NULL, Email VARCHAR(35) NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; CREATE TABLE IF NOT EXISTS %s_commands (ID INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY, Command VARCHAR(64) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; CREATE TABLE IF NOT EXISTS %s_whitelist (ID INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY, User VARCHAR(64) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", mysql_table, mysql_table, mysql_table)
	SQL_ThreadQuery(g_sqltuple, "QueryCreateTable", query)
}

public QueryCreateTable(failstate, Handle:query1, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("%s Could not connect to database!", prefix)
	}
	else if(failstate == TQUERY_QUERY_FAILED)
	{
		set_fail_state("%s Query failed!", prefix)
	}
	else if(errcode)
	{
		server_print("%s Error on query: %s", prefix, error)
	}
	else
	{
		server_print("%s MYSQL connection succesful!", prefix)

		new data[1];
		get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

		if(get_pcvar_num(g_comm) == 1)
		{
			data[0] = 0
			formatex(query, charsmax(query), "SELECT * FROM `%s_commands`;", mysql_table)
			SQL_ThreadQuery(g_sqltuple, "QueryCollectData", query, data, 1)
		}

		if(get_pcvar_num(g_whitelist))
		{
			data[0] = 1
			formatex(query, charsmax(query), "SELECT * FROM `%s_whitelist`;", mysql_table)
			SQL_ThreadQuery(g_sqltuple, "QueryCollectData", query, data, 1)
		}
		else
		{
			data_ready = true

			for(new i = 1 ; i <= g_maxplayers ; i++)
			{
				if(!is_user_connecting(i) && !is_user_connected(i))
					continue

				if(get_pcvar_num(g_whitelist))
				{
					CheckName(i)
				}
				else
				{
					CheckClient(i)
				}
			}
		}
	}	
}

public QueryCollectData(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		type = data[0]
		get_time("%H:%M:%S", sz_time, charsmax(sz_time))
		get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

		if(!type)
		{
			count = 0
			col_command = SQL_FieldNameToNum(query, "Command")

			server_print(" ")
			server_print(separator_1)
			server_print(prefix)
			server_print(separator_2)
			server_print("[%s] > Loading SQL table ^"%s_commands^"", sz_time, mysql_table)

			while(SQL_MoreResults(query)) 
			{
				SQL_ReadResult(query, col_command, input, charsmax(input))
				TrieSetCell(g_commands, input, 1)
				count++
				SQL_NextRow(query)
			}
			
			if(count)
			{
				server_print("[%s] [OK] > %d command%s loaded!", sz_time, count, count > 1 ? "s" : "")
				server_print("[%s] [OK] > SQL table ^"%s_commands^" loaded successfully!", sz_time, mysql_table)
			}
			else
			{
				server_print("[%s] [ERROR] > There were no commands in SQL table ^"%s_commands^"", sz_time, mysql_table)
				server_print("[%s] [WARNING] > Reading some data from the table failed!", sz_time)
				server_print("> Please check [ERROR] messages above for solving this problem!")
			}

			server_print(separator_1)
			server_print(" ")
		}
		else
		{
			new count1  = 0, count2 = 0, count3 = 0, count4 = 0
			count = 0
			col_name = SQL_FieldNameToNum(query, "User")

			server_print(" ")
			server_print(separator_1)
			server_print(prefix)
			server_print(separator_2)
			server_print("[%s] > Loading SQL table ^"%s_whitelist^"", sz_time, mysql_table)

			while(SQL_MoreResults(query))
			{
				SQL_ReadResult(query, col_name, input, charsmax(input))

				if(input[0] == '%')
				{
					if(input[strlen(input) - 1] == '%') //Part name
					{
						if(count1 >= MAX_NAMES)
							continue

						replace_all(input, charsmax(input), "%", "")
						part_names[count1++] = input
					}
					else // Starting name
					{
						if(count2 >= MAX_NAMES)
							continue

						replace_all(input, charsmax(input), "%", "")
						ending_names[count2++] = input
					}				
				}
				else
				{
					if(input[strlen(input) - 1] == '%') //Ending name
					{
						if(count3 >= MAX_NAMES)
							continue

						replace_all(input, charsmax(input), "%", "")
						starting_names[count3++] = input
					}
					else //Full name
					{
						if(++count4 >= MAX_NAMES)
							continue

						replace_all(input, charsmax(input), "%", "")
						TrieSetCell(g_full_nmaes, input, 1)
					}
				}

				count++
				SQL_NextRow(query)
			}
			
			
			if(count)
			{
				server_print("[%s] [OK] > %d name%s loaded!", sz_time, count, count > 1 ? "s" : "")
				server_print("[%s] [OK] > SQL table ^"%s_whitelist^" loaded successfully!", sz_time, mysql_table)
			}
			else
			{
				server_print("[%s] [ERROR] > There were no names in SQL table ^"%s_whitelist^"", sz_time, mysql_table)
				server_print("[%s] [WARNING] > Reading some data from the table failed!", sz_time)
				server_print("> Please check [ERROR] messages above for solving this problem!")
			}

			server_print(separator_1)
			server_print(" ")

			data_ready = true

			for(new i = 1 ; i <= g_maxplayers ; i++)
			{
				if(!is_user_connecting(i) && !is_user_connected(i))
					continue

				if(get_pcvar_num(g_whitelist))
				{
					CheckName(i)
				}
				else
				{
					CheckClient(i)
				}
			}
		}
	}
}
/*==============================================================================
	End of Executing plugin's config and choose the save mode
================================================================================*/

/*==============================================================================
	Start of plugin's end function
================================================================================*/
public plugin_end()
{
	TrieDestroy(g_commands)
	TrieDestroy(g_login_times)
	TrieDestroy(g_cant_login_time)
	TrieDestroy(g_pass_change_times)
	TrieDestroy(g_cant_change_pass_time)
}
/*==============================================================================
	End of plugin's end function
================================================================================*/

/*==============================================================================
	Start of Client's connect and disconenct functions
================================================================================*/
public client_authorized(id)
{
	clear_user(id)
	remove_tasks(id)

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}		
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(TrieGetCell(g_pass_change_times, g_client_data[id], value))
	{
		times[id] = value

		if(times[id] >= get_pcvar_num(g_chp_time))
		{
			cant_change_pass[id] = true
		}
	}
	
	if(data_ready)
	{
		if(get_pcvar_num(g_whitelist))
		{
			CheckName(id)
		}
		else
		{
			CheckClient(id)
		}
	}
}

public client_putinserver(id)
{
	if(get_pcvar_num(g_alog_on))
	{
		new line = 0;
		new linetext[255], linetextlength;
		new login[32], pword[32];

		new configdir[200];
		get_configsdir(configdir, 199);

		format(configdir, 199, "%s/users.ini", configdir);

		if(file_exists(configdir))
		{
			while((line = read_file(configdir, line, linetext, 256, linetextlength)))
			{
				if(linetext[0] == ';')
				{
					continue
				}

				parse(linetext, login, 31, pword, 31);

				if( (equali(login, player_name[id]) || equali(login, player_authid[id]) || equali(login, player_ip[id])) && !equali(pword, "") )
				{
					admin_exist[id] = true;
					adminpasswd[id] = pword;

					break;
				}
				else
				{
					admin_exist[id] = false;
					adminpasswd[id] = "";
				}
			}
		}
		
		if(!admin_exist[id])
		{
			new configdir2[200];
			get_configsdir(configdir2, 199);

			format(configdir2, 199, "%s/auto-admins.ini", configdir2);

			if(file_exists(configdir2))
			{
				while((line = read_file(configdir2, line, linetext, 256, linetextlength)))
				{
					if(linetext[0] == ';')
					{
						continue
					}
					
					parse(linetext, login, 31, pword, 31);
					
					if( (equali(login, player_name[id]) || equali(login, player_authid[id]) || equali(login, player_ip[id])) && !equali(pword, "") )
					{
						admin_exist[id] = true;
						adminpasswd[id] = pword;

						break;
					}
					else
					{
						admin_exist[id] = false;
						adminpasswd[id] = "";
					}
				}
			}
		}

		if(!admin_exist[id])
		{
			new configdir3[200];
			get_configsdir(configdir3, 199);

			format(configdir3, 199, "%s/manager/users.ini", configdir3);

			if(file_exists(configdir3))
			{
				while((line = read_file(configdir3, line, linetext, 256, linetextlength)))
				{
					if(linetext[0] == ';')
					{
						continue
					}

					parse(linetext, login, 31, pword, 31);

					if( (equali(login, player_name[id]) || equali(login, player_authid[id]) || equali(login, player_ip[id])) && !equali(pword, "") )
					{
						admin_exist[id] = true;
						adminpasswd[id] = pword;

						break;
					}
					else
					{
						admin_exist[id] = false;
						adminpasswd[id] = "";
					}
				}
			}
		}

		if(admin_exist[id])
		{
			is_admin[id] = true
			is_logged_a[id] = false

			flags[id] = get_user_flags(id);

			remove_user_flags(id, read_flags("abcdefghijklmnopqrstu"));
			set_user_flags(id, read_flags("z"));
		}
		else
		{
			is_admin[id] = false
			is_logged_a[id] = false
		}
	}

	if(get_pcvar_num(g_ver_on))
	{
		VerificationShowMsg(id)
		return
	}
	if(get_pcvar_num(g_on))
	{
		register_system(id)
		return
	}
	if(get_pcvar_num(g_alog_on))
	{
		if(is_admin[id] && !is_logged_a[id])
		{
			AdminLoginShowMsg(id)
		}
	}
}

public client_disconnected(id)
{
	clear_user(id)
	remove_tasks(id)
	remove_task(id)
}
/*==============================================================================
	End of Client's connect and disconenct functions
================================================================================*/

/*==============================================================================
	Start of Check Client functions
================================================================================*/
new Array:WhiteList

public plugin_precache()
{
	WhiteList = ArrayCreate(32, 1)
	read_user_from_file()
}

public read_user_from_file()
{
	static user_file_url[64], config_dir[32]

	get_configsdir(config_dir, sizeof(config_dir))
	format(user_file_url, sizeof(user_file_url), "%s/%s", config_dir, whitelistfile)

	if(!file_exists(user_file_url))
		return

	static file_handle, line_data[64], line_count
	file_handle = fopen(user_file_url, "rt")
	
	while(!feof(file_handle))
	{
		fgets(file_handle, line_data, sizeof(line_data))
	
		replace(line_data, charsmax(line_data), "^n", "")
	
		if(!line_data[0] || line_data[0] == ';') 
			continue
			
		ArrayPushString(WhiteList, line_data)
		line_count++
	}

	fclose(file_handle)
}

public CheckName(id)
{
	if((!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || is_user_bot(id) || !data_ready)
		return PLUGIN_HANDLED

	static name[64], steamid[64], ip[64], Data[32]
	
	get_user_name(id, name, sizeof(name))
	get_user_authid(id, steamid, sizeof(steamid))
	get_user_ip(id, ip, sizeof(ip))

	for(new i = 0; i < ArraySize(WhiteList); i++)
	{
		ArrayGetString(WhiteList, i, Data, sizeof(Data))
		
		if(equali(name, Data) || equali(steamid, Data) || equali(ip, Data))
		{
			name_checked[id] = false
			return PLUGIN_CONTINUE
		}
	}

	get_user_name(id, check_name, charsmax(check_name))

	if(TrieGetCell(g_full_nmaes, check_name, value))
	{
		name_checked[id] = false
		return PLUGIN_CONTINUE
	}

	for(new i = 0 ; i <= charsmax(part_names) ;i++)
	{
		if(containi(check_name, part_names[i]) != -1)
		{
			name_checked[id] = false
			return PLUGIN_CONTINUE
		}
	}

	for(new i = 0 ; i <= charsmax(starting_names) ; i++)
	{
		is_true = false

		for(new j = 0 ; j <= strlen(starting_names[i]) - 1 ; j++)
		{
			formatex(temp1, charsmax(temp1), "%c", starting_names[i][j])
			formatex(temp2, charsmax(temp2), "%c", check_name[j])
			
			if(equali(temp1, temp2))
			{
				is_true = true
			}
			else
			{
				is_true = false
				break
			}
		}
		
		if(is_true)
		{
			name_checked[id] = false
			return PLUGIN_CONTINUE
		}
	}

	for(new i = 0 ; i <= charsmax(ending_names) ; i++)
	{
		is_true = false
		
		if(!(strlen(check_name) >= strlen(ending_names[i])))
			continue
		
		temp_count = strlen(check_name) - strlen(ending_names[i])

		for(new j = strlen(ending_names[i]) - 1 ; j >= 0 ; j--)
		{	
			formatex(temp1, charsmax(temp1), "%c", ending_names[i][j])
			formatex(temp2, charsmax(temp2), "%c", check_name[j + temp_count])
			
			if(equali(temp1, temp2))
			{
				is_true = true
			}
			else
			{
				is_true = false
				break
			}
		}
		
		if(is_true)
		{
			name_checked[id] = false
			return PLUGIN_CONTINUE
		}		
	}

	name_checked[id] = true
	CheckClient(id)
	return PLUGIN_CONTINUE
}

public CheckClient(id)
{
	if((!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || is_user_bot(id) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	remove_tasks(id)
	is_registered[id] = false
	is_logged[id] = false
	is_registered_old[id] = false
	email[id] = ""
	has_email[id] = false

	new name[32], authid[32], ip[32], szCountry[32]

	get_user_name(id, name, 31)
	get_user_authid(id, authid, 31)
	get_user_ip(id, ip, 31)
	geoip_country(ip, szCountry)

	player_name[id] = name
	player_authid[id] = authid
	player_ip[id] = ip
	player_country[id] = szCountry
	
	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}		
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(get_pcvar_num(g_save))
	{
		new data[1]
		data[0] = id

		get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

		formatex(query, charsmax(query), "SELECT `Password`, `Email` FROM `%s` WHERE User = ^"%s^";", mysql_table, g_client_data[id])

		SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)
	}
	else
	{
		line = 0, length = 0;

		while(read_file(reg_file, line++ , text, charsmax(text), length))
		{
			if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
				continue

			parse(text, check_client_data, charsmax(check_client_data), check_hash, charsmax(check_hash), check_pass, charsmax(check_pass), check_email, charsmax(check_email))

			if(equali(check_client_data, g_client_data[id]))
			{
				if(!(equali(check_hash, "")))
				{
					is_registered[id] = true
					password[id] = check_hash
					passwd[id] = check_pass

					if(is_user_connected(id))
					{
						if(get_pcvar_num(g_ver_on))
						{
							VerificationShowMsg(id)
						}
						else
						{
							if(get_pcvar_num(g_on))
							{
								register_system(id)

								if(get_pcvar_num(g_advert) && get_pcvar_num(g_advert_int))
								{
									set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)
								}
							}
							else
							{
								if(get_pcvar_num(g_alog_on))
								{
									if(is_admin[id] && !is_logged_a[id])
									{
										AdminLoginShowMsg(id)
									}
								}
							}
						}
					}

					break
				}
				else
				{
					is_registered_old[id] = true

					break
				}
			}
		}

		line = 0, length = 0;

		while(read_file(reg_file, line++ , text, charsmax(text), length))
		{
			if(!text[0] || text[0] == '^n' || text[0] == ';' || (text[0] == '/' && text[1] == '/'))
				continue

			parse(text, check_client_data, charsmax(check_client_data), check_hash, charsmax(check_hash), check_pass, charsmax(check_pass), check_email, charsmax(check_email))

			if(equali(check_client_data, g_client_data[id]) && !(equali(check_email, "")))
			{
				email[id] = check_email
				has_email[id] = true

				break
			}
		}
	}
	return PLUGIN_CONTINUE
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		new id = data[0];
		new col_pass = SQL_FieldNameToNum(Query, "Password")
		new col_email = SQL_FieldNameToNum(Query, "Email")

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_pass, check_pass, charsmax(check_pass))
			SQL_ReadResult(Query, col_email, check_email, charsmax(check_email))
			password[id] = convert_password(check_pass)
			passwd[id] = check_pass
			email[id] = check_email

			if(!equali(check_pass, ""))
				is_registered[id] = true
			else is_registered_old[id] = true

			if(!equali(check_email, ""))
				has_email[id] = true

			if(is_user_connected(id))
			{
				if(get_pcvar_num(g_ver_on))
				{
					VerificationShowMsg(id)
				}
				else
				{
					if(get_pcvar_num(g_on))
					{
						register_system(id)

						if(get_pcvar_num(g_advert) && get_pcvar_num(g_advert_int))
						{
							set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)
						}
					}
					else
					{
						if(get_pcvar_num(g_alog_on))
						{
							if(is_admin[id] && !is_logged_a[id])
							{
								AdminLoginShowMsg(id)
							}
						}
					}
				}
			}

			SQL_NextRow(Query)
		}
	}
}
/*==============================================================================
	End of Check Client functions
================================================================================*/

/*==============================================================================
	Start of Show Client's informative Verification messages
================================================================================*/
public VerificationShowMsg(id)
{
	if(!get_pcvar_num(g_ver_on))
		return PLUGIN_HANDLED

	remove_tasks(id)

	params[0] = id

	CreateVerificationMenuTask(id+TASK_MENU)
	
	if(get_pcvar_num(g_count))
	{
		g_player_time[id] = get_pcvar_num(g_vertime)
		VerificationShowTimer(id+TASK_TIMER)
	}

	if(!is_user_bot(id))
	{
		params[1] = 2
		set_task(get_pcvar_float(g_vertime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public VerificationShowTimer(id)
{
	id -= TASK_TIMER

	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	switch(g_player_time[id])
	{
		case 10..19:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
		case 0..9:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		case -1:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		default:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
	}

	if(g_player_time[id] == 0)
	{
		//ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "KICK_HUD")
		return PLUGIN_CONTINUE
	}
	else
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "LOGIN_AFTER")
			set_task(1.0, "VerificationShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}
		ShowSyncHudMsg(id, g_sync_hud, "%L ", LANG_SERVER, "LOGIN_HUD", g_player_time[id])
	}

	g_player_time[id]--

	set_task(1.0, "VerificationShowTimer", id+TASK_TIMER)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Show Client's informative Verification messages
================================================================================*/

/*==============================================================================
	Start of the Anti-Bot Verification Menu
================================================================================*/
public CreateVerificationMenuTask(id)
{
	id -= TASK_MENU

	if(already[id]) return

	Verification(id)
	set_task(0.5, "CreateVerificationMenuTask", id+TASK_MENU)
}

public Verification(id)
{
	switch( random_num(1,12) )
	{
		case 1: menu1(id+TASK_MENU)
		case 2: menu2(id+TASK_MENU)
		case 3: menu3(id+TASK_MENU)
		case 4: menu4(id+TASK_MENU)
		case 5: menu5(id+TASK_MENU)
		case 6: menu6(id+TASK_MENU)
		case 7: menu7(id+TASK_MENU)
		case 8: menu8(id+TASK_MENU)
		case 9: menu9(id+TASK_MENU)
		case 10: menu10(id+TASK_MENU)
		case 11: menu11(id+TASK_MENU)
		case 12: menu12(id+TASK_MENU)
	}
	return PLUGIN_CONTINUE
}

public menu1(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y8558", "Handle1")

	menu_additem(menu, "\y8558", "", 0)
	menu_additem(menu, "8422", "", 0)
	menu_additem(menu, "2733", "", 0)
	menu_additem(menu, "1834", "", 0)
	menu_additem(menu, "6283", "", 0)
	menu_additem(menu, "3937", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu1", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu2(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y2277", "Handle2")

	menu_additem(menu, "8843", "", 0)
	menu_additem(menu, "\y2277", "", 0)
	menu_additem(menu, "8812", "", 0)
	menu_additem(menu, "1942", "", 0)
	menu_additem(menu, "2664", "", 0)
	menu_additem(menu, "8173", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu2", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu3(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y2860", "Handle3")

	menu_additem(menu, "7342", "", 0)
	menu_additem(menu, "6618", "", 0)
	menu_additem(menu, "\y2860", "", 0)
	menu_additem(menu, "2626", "", 0)
	menu_additem(menu, "8834", "", 0)
	menu_additem(menu, "1488", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu3", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu4(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y2587", "Handle4")

	menu_additem(menu, "6382", "", 0)
	menu_additem(menu, "1183", "", 0)
	menu_additem(menu, "9764", "", 0)
	menu_additem(menu, "\y2587", "", 0)
	menu_additem(menu, "4772", "", 0)
	menu_additem(menu, "1944", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu4", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu5(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y9704", "Handle5")

	menu_additem(menu, "2273", "", 0)
	menu_additem(menu, "1443", "", 0)
	menu_additem(menu, "1277", "", 0)
	menu_additem(menu, "8433", "", 0)
	menu_additem(menu, "\y9704", "", 0)
	menu_additem(menu, "1092", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu5", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu6(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y5273", "Handle6")

	menu_additem(menu, "6348", "", 0)
	menu_additem(menu, "1134", "", 0)
	menu_additem(menu, "7342", "", 0)
	menu_additem(menu, "1233", "", 0)
	menu_additem(menu, "9674", "", 0)
	menu_additem(menu, "\y5273", "", 0)


	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu6", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu7(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y8452", "Handle1")

	menu_additem(menu, "\y8452", "", 0)
	menu_additem(menu, "8283", "", 0)
	menu_additem(menu, "1123", "", 0)
	menu_additem(menu, "9753", "", 0)
	menu_additem(menu, "1294", "", 0)
	menu_additem(menu, "8342", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu7", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu8(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y4301", "Handle2")

	menu_additem(menu, "8233", "", 0)
	menu_additem(menu, "\y4301", "", 0)
	menu_additem(menu, "9372", "", 0)
	menu_additem(menu, "1843", "", 0)
	menu_additem(menu, "2274", "", 0)
	menu_additem(menu, "1871", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu8", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu9(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y1513", "Handle3")

	menu_additem(menu, "2763", "", 0)
	menu_additem(menu, "2266", "", 0)
	menu_additem(menu, "\y1513", "", 0)
	menu_additem(menu, "8232", "", 0)
	menu_additem(menu, "1722", "", 0)
	menu_additem(menu, "8654", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu9", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu10(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y6336", "Handle4")

	menu_additem(menu, "1234", "", 0)
	menu_additem(menu, "1842", "", 0)
	menu_additem(menu, "7232", "", 0)
	menu_additem(menu, "\y6336", "", 0)
	menu_additem(menu, "9876", "", 0)
	menu_additem(menu, "6273", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu10", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu11(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y2082", "Handle5")

	menu_additem(menu, "8772", "", 0)
	menu_additem(menu, "1274", "", 0)
	menu_additem(menu, "2974", "", 0)
	menu_additem(menu, "7492", "", 0)
	menu_additem(menu, "\y2082", "", 0)
	menu_additem(menu, "1734", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu11", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}

public menu12(id)
{
	id -= TASK_MENU

	new menu = menu_create("\yAnti-Bot Verification^n^n\rCode: \y7456", "Handle6")

	menu_additem(menu, "8462", "", 0)
	menu_additem(menu, "1834", "", 0)
	menu_additem(menu, "7632", "", 0)
	menu_additem(menu, "1237", "", 0)
	menu_additem(menu, "6283", "", 0)
	menu_additem(menu, "\y7456", "", 0)

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r")

	menu_display(id, menu, 0)

	set_task(0.1, "menu12", id+TASK_MENU)
	already[id] = true

	return PLUGIN_HANDLED
}


public Handle1(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 0:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
			
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public Handle2(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 1:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public Handle3(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 2:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public Handle4(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 3:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public Handle5(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 4:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public Handle6(id, menu, item)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(item == MENU_EXIT)
	{
		menu_cancel(id)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 5:
		{
			is_verified[id] = true
			remove_tasks(id)
			CloseMenu(id)
			client_printcolor(id, "%L", LANG_SERVER, "VER_DONE", prefix)
			client_cmd(id, "jointeam")

			if(get_pcvar_num(g_on))
			{
				register_system(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on))
			{
				if(is_admin[id] && !is_logged_a[id])
				{
					AdminLoginShowMsg(id)
					return PLUGIN_HANDLED
				}
			}

			CloseMenu(id)
			client_cmd(id, "jointeam")
		}
		default: kickbot(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public kickbot(id)
{
	if(is_registered[id])
		params[1] = 3
	else if(!is_registered[id])
		params[1] = 2

	set_task(0.1, "KickPlayer", id+TASK_KICK, params, sizeof params)
	return PLUGIN_HANDLED
}
/*==============================================================================
	End of Anti-Bot Verification Menu
================================================================================*/

/*==============================================================================
	Start of Show Client's informative Register messages
================================================================================*/
public register_system(id)
{
	if(get_pcvar_num(g_alog_on))
	{
		if(!is_registered[id] && is_admin[id])
		{
			if(data_ready && name_checked[id])
			{
				AdminLoginShowMsg(id)
				client_cmd(id, "messagemode AdminPassword")
			}
		}
		else
		{
			if(data_ready && name_checked[id])
			{
				RegShowMsg(id)

				if(get_pcvar_num(g_advert) && get_pcvar_num(g_advert_int))
				{
					set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)
				}
			}
		}
	}
	else
	{
		if(data_ready && name_checked[id])
		{
			RegShowMsg(id)

			if(get_pcvar_num(g_advert) && get_pcvar_num(g_advert_int))
			{
				set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)
			}
		}
	}
}

public RegShowMsg(id)
{
	if(!get_pcvar_num(g_on))
		return PLUGIN_HANDLED

	remove_tasks(id)

	set_task(5.0, "RegMessages", id+TASK_MESS)

	params[0] = id

	if(!is_registered[id])
	{
		if(get_pcvar_float(g_regtime) != 0)
		{
			if(!changing_name[id])
			{
				CreateMainMenuTask(id+TASK_MENU)

				if(get_pcvar_num(g_count))
				{
					g_player_time[id] = get_pcvar_num(g_regtime)
					RegShowTimer(id+TASK_TIMER)
				}
				params[1] = 1
				set_task(get_pcvar_float(g_regtime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
				return PLUGIN_HANDLED
			}
			else
			{
				g_player_time[id] = -1
				set_task(1.0, "RegShowTimer", id+TASK_TIMER)
			}
		}
	}
	else if(!is_logged[id])
	{
		if(!changing_name[id])
		{
			CreateMainMenuTask(id+TASK_MENU)
	
			if(get_pcvar_num(g_count))
			{
				g_player_time[id] = get_pcvar_num(g_logtime)
				RegShowTimer(id+TASK_TIMER)
			}
			params[1] = 1
			set_task(get_pcvar_float(g_logtime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
			return PLUGIN_HANDLED
		}
		else
		{
			g_player_time[id] = -1
			set_task(1.0, "RegShowTimer", id+TASK_TIMER)
		}
	}
	return PLUGIN_CONTINUE
}

public RegShowTimer(id)
{
	id -= TASK_TIMER

	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	switch(g_player_time[id])
	{
		case 10..19:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
		case 0..9:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		case -1:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		default:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
	}

	if(g_player_time[id] == 0)
	{
		//ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "KICK_HUD")
		return PLUGIN_CONTINUE
	}
	else if(!is_registered[id] && get_pcvar_float(g_regtime))
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "REGISTER_AFTER")
			set_task(1.0, "RegShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}

		ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, g_player_time[id] > 1 ? "REGISTER_HUD" : "REGISTER_HUD_SEC", g_player_time[id])
	}
	else if(is_registered[id] && !is_logged[id])
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "LOGIN_AFTER")
			set_task(1.0, "RegShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}

		ShowSyncHudMsg(id, g_sync_hud, "%L ", LANG_SERVER, g_player_time[id] > 1 ? "LOGIN_HUD" : "LOGIN_HUD_SEC", g_player_time[id])
	}
	else return PLUGIN_HANDLED

	g_player_time[id]--

	set_task(1.0, "RegShowTimer", id+TASK_TIMER)

	return PLUGIN_CONTINUE
}

public RegMessages(id)
{
	id -= TASK_MESS

	if(!is_registered[id])
	{
		if(get_pcvar_float(g_regtime) != 0)
		{
			//client_printcolor(id, "%L", LANG_SERVER, "REGISTER_CHAT", prefix, get_pcvar_num(g_regtime))
		}
		else
		{
			client_printcolor(id, "%L", LANG_SERVER, "YOUCANREG_CHAT", prefix)
		}
	}
	/*else if(!is_logged[id])
	{
		//client_printcolor(id, "%L", LANG_SERVER, "LOGIN_CHAT", prefix, get_pcvar_num(g_logtime))
	}*/
	else if(is_registered[id] && !has_email[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "YOUCANSETEMAIL_CHAT", prefix)
	}
}
/*==============================================================================
	End of Show Client's informative Register messages
================================================================================*/

/*==============================================================================
	Start of the Main Menu function
================================================================================*/
public CreateMainMenuTask(id)
{
	id -= TASK_MENU

	if(get_pcvar_num(g_on) && is_registered[id] && !is_logged[id])
	{
		MainMenu(id)
		set_task(1.0, "CreateMainMenuTask", id+TASK_MENU)
	}
}

public MainMenu(id)
{
	if(!get_pcvar_num(g_on) || !is_user_connected(id) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	length = 0

	if(is_registered[id])
	{
		if(is_logged[id])
		{
			if(has_email[id])
			{
				length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_LOG", player_name[id], passwd[id], email[id])
				keys = MENU_KEY_1|MENU_KEY_3|MENU_KEY_0
			}
			else
			{
				length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_LOG_NOEMAIL", player_name[id], passwd[id])
				keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0
			}
		}
		else
		{
			if(has_email[id])
			{
				length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_REG", player_name[id])
				keys = MENU_KEY_1|MENU_KEY_2
			}
			else
			{
				length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_REG_NOEMAIL", player_name[id])
				keys = MENU_KEY_2
			}
		}
	}
	else
	{
		length += formatex(menu[length], charsmax(menu) - length, "%L", LANG_SERVER, "MAIN_MENU_NOTREG", player_name[id])
		keys = MENU_KEY_1|MENU_KEY_0
	}
	show_menu(id, keys, menu, -1, "Register System Main Menu")

	return PLUGIN_CONTINUE
}
public HandlerMainMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			if(!is_registered[id] && !is_logged[id])
			{
				client_cmd(id, "messagemode SetPass")
			}
			if(is_registered[id] && is_logged[id])
			{
				client_cmd(id, "messagemode NewPass")
			}
			if(is_registered[id] && !is_logged[id])
			{
				if(has_email[id])
				{
					if(emailsent[id])
						client_printcolor(id, "%L", LANG_SERVER, "EMAIL_SENT_ALREADY", prefix)
					else RecoverPassword(id)
				}
			}
		}
		case 1:
		{
			if(is_registered[id] && !is_logged[id])
			{
				client_cmd(id, "messagemode Connecting")
			}
			if(is_registered[id] && is_logged[id])
			{
				client_cmd(id, "messagemode SetEmail")
			}
		}
		case 2:
		{
			if(is_registered[id] && is_logged[id])
			{
				RemovePassword(id)
			}
		}
	}
	return PLUGIN_HANDLED
}
/*==============================================================================
	End of the Main Menu function
================================================================================*/

/*==============================================================================
	Start of Login function
================================================================================*/
public Login(id)
{
	if(!get_pcvar_num(g_on) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(changing_name[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOGIN_AFTER")
		return PLUGIN_HANDLED
	}

	if(!is_registered[id])
	{	
		client_printcolor(id, "%L", LANG_SERVER, "LOG_NOTREG", prefix)
		return PLUGIN_HANDLED
	}

	if(is_logged[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGGED", prefix);
		return PLUGIN_HANDLED
	}

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	if(equal(typedpass, ""))
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID2", prefix)
		CreateMainMenuTask(id+TASK_MENU)
		return PLUGIN_HANDLED
	}

	hash = convert_password(typedpass)

	if(!equal(hash, password[id]))
	{
		TrieSetCell(g_login_times, g_client_data[id], ++attempts[id])
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix)
		log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_WrongPasswords_Logs.log", "%L", LANG_SERVER, "LOGFILE_PASS_INVALID", player_name[id], player_authid[id], player_ip[id], player_country[id], typedpass)
		CreateMainMenuTask(id+TASK_MENU)
	}
	else
	{
		passwd[id] = typedpass
		is_logged[id] = true
		attempts[id] = 0
		remove_task(id+TASK_KICK)

		if(get_pcvar_num(g_announce))
		{
			get_user_name(id, temp_name, charsmax(temp_name))
			client_printcolor(0, "%L", LANG_SERVER, "LOG_LOGING_G", prefix, temp_name)
		}
		else
		{
			client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGING", prefix)
		}

		if(get_pcvar_num(g_alog_on))
		{
			if(is_admin[id] && !is_logged_a[id])
			{
				CloseMenu(id)
				AdminLoginShowMsg(id)
				client_cmd(id, "messagemode AdminPassword")
			}
			else
			{
				CloseMenu(id)
				client_cmd(id, "jointeam")
			}
		}
		else
		{
			CloseMenu(id)
			client_cmd(id, "jointeam")

			if(is_registered[id])
			{
				remove_user_flags(id, read_flags("z"))
				set_user_flags(id, flags[id])
			}
		}
	}
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Login function
================================================================================*/

/*==============================================================================
	Start of Register function
================================================================================*/
public Register(id)
{
	if(!get_pcvar_num(g_on) || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	if(changing_name[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "REGISTER_AFTER")
		return PLUGIN_HANDLED
	}

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlength = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED
	
	if(is_registered[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_EXISTS", prefix)
		return PLUGIN_HANDLED
	}

	if( passlength < get_pcvar_num(g_pass_length) )
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, get_pcvar_num(g_pass_length))
		client_cmd(id, "messagemode SetPass")
		return PLUGIN_HANDLED
	}

	if(containi(typedpass, "^"") != -1)
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID2", prefix)
		client_cmd(id, "messagemode SetPass")
		return PLUGIN_HANDLED
	}

	remove_task(id+TASK_MENU)

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}		
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	hash = convert_password(typedpass)

	if(get_pcvar_num(g_save))
	{
		if(is_registered_old[id])
		{
			get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

			new sql_typedpass[32];
			sql_typedpass = typedpass
			replace_all(sql_typedpass, charsmax(sql_typedpass), "\", "\\")

			formatex(query, charsmax(query), "UPDATE `%s` SET Password = ^"%s^" WHERE User = ^"%s^";", mysql_table, sql_typedpass, g_client_data[id])
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)

			if(get_pcvar_num(g_reg_log))
			{
				log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_REG", g_client_data[id], player_authid[id], player_ip[id], player_country[id], typedpass, email[id])
			}
		}
		else
		{
			get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))
			formatex(query, charsmax(query), "INSERT INTO `%s` (`User`, `Password`, `Email`) VALUES (^"%s^", ^"%s^", ^"^");", mysql_table, g_client_data[id], typedpass)
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)

			if(get_pcvar_num(g_reg_log))
			{
				log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_FIRST_REG", g_client_data[id], player_authid[id], player_ip[id], player_country[id], typedpass)
			}
		}
	}
	else
	{
		if(is_registered_old[id])
		{
			line = 0, length = 0;

			while(read_file(reg_file, line++ , text, charsmax(text), length))
			{
				parse(text, text, charsmax(text))

				if(!(equali(text, g_client_data[id])))
					continue

				formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^" ^"%s^"", g_client_data[id], hash, typedpass, email[id])
				write_file(reg_file, text, line - 1)							

				break
			}

			if(get_pcvar_num(g_reg_log))
			{
				log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_REG", g_client_data[id], player_authid[id], player_ip[id], player_country[id], typedpass, email[id])
			}
		}
		else
		{
			new file_pointer = fopen(reg_file, "a")
			format(text, charsmax(text), "^n^"%s^" ^"%s^" ^"%s^" ^"%s^"", g_client_data[id], hash, typedpass, email[id])
			fprintf(file_pointer, text)
			fclose(file_pointer)

			if(get_pcvar_num(g_reg_log))
			{
				log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_FIRST_REG", g_client_data[id], player_authid[id], player_ip[id], player_country[id], typedpass)
			}
		}
	}

	is_registered[id] = true
	is_logged[id] = true
	password[id] = hash
	passwd[id] = typedpass
	client_printcolor(id, "%L", LANG_SERVER, "CHANGE_NEW", prefix, typedpass)
	MainMenu(id)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Register function
================================================================================*/

/*==============================================================================
	Start of Change Password function
================================================================================*/
public ChangePassword(id)
{
	if(!get_pcvar_num(g_on) || !is_registered[id] || !is_logged[id] || changing_name[id] || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlenght = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED

	if(passlenght < get_pcvar_num(g_pass_length))
	{
		client_printcolor(id, "%L", LANG_SERVER, "REG_LEN", prefix, get_pcvar_num(g_pass_length))
		client_cmd(id, "messagemode NewPass")
		return PLUGIN_HANDLED
	}

	if(containi(typedpass, "^"") != -1)
	{
		client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID2", prefix)
		client_cmd(id, "messagemode NewPass")
		return PLUGIN_HANDLED
	}

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	hash = convert_password(typedpass)

	if(is_registered[id])
	{
		if(get_pcvar_num(g_save))
		{
			get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

			new sql_typedpass[32];
			sql_typedpass = typedpass
			replace_all(sql_typedpass, charsmax(sql_typedpass), "\", "\\")

			formatex(query, charsmax(query), "UPDATE `%s` SET Password = ^"%s^" WHERE User = ^"%s^";", mysql_table, sql_typedpass, g_client_data[id])
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
		}
		else
		{
			line = 0, length = 0;

			while(read_file(reg_file, line++ , text, charsmax(text), length))
			{
				parse(text, text, charsmax(text))

				if(!(equali(text, g_client_data[id])))
					continue

				formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^" ^"%s^"", g_client_data[id], hash, typedpass, email[id])
				write_file(reg_file, text, line - 1)

				break
			}
		}

		password[id] = hash
		passwd[id] = typedpass

		TrieSetCell(g_pass_change_times, g_client_data[id], ++times[id])
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_NEW", prefix, typedpass)

		if(times[id] >= get_pcvar_num(g_chp_time))
		{
			cant_change_pass[id] = true

			if(get_pcvar_num(g_time_pass))
			{
				TrieSetCell(g_cant_change_pass_time, g_client_data[id], time())
			}
			else
			{
				TrieSetCell(g_cant_change_pass_time, g_client_data[id], 0)
			}

			if(get_pcvar_num(g_time_pass))
			{	
				set_task(get_pcvar_float(g_time), "RemoveCantChangePass", 0, g_client_data[id], sizeof g_client_data)
			}
		}

		if(get_pcvar_num(g_chp_log))
		{
			log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_CHNG_PASS", g_client_data[id], player_authid[id], player_ip[id], player_country[id], typedpass, email[id])
		}
		MainMenu(id)
	}
	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Change Password function
================================================================================*/

/*==============================================================================
	Start of Remove Password function
================================================================================*/
public RemovePassword(id)
{
	if(!get_pcvar_num(g_on) || !is_registered[id] || !is_logged[id] || changing_name[id] || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(is_registered[id])
	{
		if(get_pcvar_num(g_save))
		{
			get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))

			formatex(query, charsmax(query), "UPDATE `%s` SET Password = ^"^" WHERE User = ^"%s^";", mysql_table, g_client_data[id])
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
		}
		else
		{
			line = 0, length = 0;

			while(read_file(reg_file, line++ , text, charsmax(text), length))
			{
				parse(text, text, charsmax(text))

				if(!(equali(text, g_client_data[id])))
					continue

				formatex(text, charsmax(text), "^"%s^" ^"^" ^"^" ^"%s^"", g_client_data[id], email[id])
				write_file(reg_file, text, line - 1)							

				break
			}
		}

		if(get_pcvar_num(g_chp_log))
		{
			log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_REMOVE_PASS", g_client_data[id], player_authid[id], player_ip[id], player_country[id], email[id])
		}

		remove_tasks(id)
		is_registered[id] = false
		is_logged[id] = false
		password[id] = ""
		passwd[id] = ""
		is_registered_old[id] = true
		client_printcolor(id, "%L", LANG_SERVER, "REMOVE_PASS", prefix)
	}
	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Remove Password function
================================================================================*/

/*==============================================================================
	Start of Register Email function
================================================================================*/
public RegisterEmail(id)
{
	if(!get_pcvar_num(g_on) || !is_registered[id] || !is_logged[id] || has_email[id] || changing_name[id] || !data_ready || !name_checked[id])
		return PLUGIN_HANDLED

	read_args(typedemail, charsmax(typedemail))
	remove_quotes(typedemail)

	for (new i = 0; i < sizeof(g_InvalidCharacter); i++)
	{
		if(containi(typedemail, g_InvalidCharacter[i]) != -1 || !(containi(typedemail, "@") != -1) || !(containi(typedemail, ".") != -1) || equali(typedemail, ""))
		{
			client_printcolor(id, "%L", LANG_SERVER, "LOG_EMAIL_INVALID", prefix)
			MainMenu(id)
			return PLUGIN_CONTINUE
		}
	}

	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
		case 1:
		{
			get_user_ip(id, g_client_data[id], charsmax(g_client_data), 1)
		}
		case 2:
		{
			get_user_authid(id, g_client_data[id], charsmax(g_client_data))
		}
		default:
		{
			get_user_name(id, g_client_data[id], charsmax(g_client_data))
		}
	}

	if(is_registered[id])
	{
		if(get_pcvar_num(g_save))
		{
			get_pcvar_string(g_table, mysql_table, charsmax(mysql_table))
			formatex(query, charsmax(query), "UPDATE `%s` SET Email = ^"%s^" WHERE User = ^"%s^";", mysql_table, typedemail, g_client_data[id])
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
		}
		else
		{
			line = 0, length = 0;

			while(read_file(reg_file, line++ , text, charsmax(text), length))
			{
				parse(text, text, charsmax(text))

				if(!(equali(text, g_client_data[id])))
					continue

				formatex(text, charsmax(text), "^"%s^" ^"%s^" ^"%s^" ^"%s^"", g_client_data[id], password[id], passwd[id], typedemail)
				write_file(reg_file, text, line - 1)

				break
			}
		}

		if(get_pcvar_num(g_chp_log))
		{
			log_to_file("addons/amxmodx/logs/GG_Logs/Register_System_Logs.log", "%L", LANG_SERVER, "LOGFILE_REG_EMAIL", g_client_data[id], player_authid[id], player_ip[id], player_country[id], passwd[id], typedemail)
		}

		email[id] = typedemail
		has_email[id] = true
		client_printcolor(id, "%L", LANG_SERVER, "CHANGE_EMAIL", prefix, typedemail)
		MainMenu(id)
	}
	return PLUGIN_CONTINUE
}

public QuerySetData(FailState, Handle:Query, error[], errcode, data[], datasize)
{
	static qstring[512];
	SQL_GetQueryString(Query, qstring, 1023);
	
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		log_amx("%s [SQLX] Could not connect to database!", prefix);
		return
	}
	else if (FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s [SQLX] Query failed!", prefix);
		log_amx("%s [SQLX] Error '%s' with '%s'", prefix, error, errcode);
		log_amx("%s [SQLX] %s", prefix, qstring);
		return
	}
}

/*==============================================================================
	End of Register Email function
================================================================================*/

/*==============================================================================
	Start of Recover Password function
================================================================================*/
public RecoverPassword(id)
{
	if(!is_registered[id] || is_logged[id] || !has_email[id] || emailsent[id])
		return PLUGIN_HANDLED

	new hostname[64], server_ip[64]
	get_cvar_string("hostname", hostname, 63)
	get_user_ip(0, server_ip, 63)

	new text[2024]
	format(text, charsmax(text), "Dear Mister or Madam,^n^nYou have asked to receive your Username and Password again in order to connect you to your GeekGamers account^n^nServer Name : %s^nAddress IP : %s^nUsername : %s^nPassword : %s^n^nRemember to change your password often.^nWe thank you for the trust you show us.^n^nBest Regards,", hostname, server_ip, player_name[id], passwd[id])

	new connect
	connect = smtp_connect("mail.example.com", 587)

	if(connect != -1)
	{
		smtp_auth(connect, "contact@geek-gamers.com", "Password")
		smtp_send(connect, "contact@geek-gamers.com", email[id], "[Geek~Gamers] Recover Forgotten Password", text, "To:")
		smtp_quit(connect)
		client_printcolor(id, "%L", LANG_SERVER, "EMAIL_SENT", prefix)
		emailsent[id] = true
	}
	else
	{
		server_print("ERROR Connect to SMTP")
		client_printcolor(id, "%L", LANG_SERVER, "EMAIL_ERROR", prefix)
	}
	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Recover Password function
================================================================================*/

/*==============================================================================
	Start of Show Client's informative Admin Login messages
================================================================================*/
public AdminLoginShowMsg(id)
{
	if(!get_pcvar_num(g_alog_on))
		return PLUGIN_HANDLED

	remove_tasks(id)

	params[0] = id
	
	if(get_pcvar_num(g_count))
	{
		g_player_time[id] = get_pcvar_num(g_alogtime)
		AdminLoginShowTimer(id+TASK_TIMER)
	}

	if(!is_user_bot(id))
	{
		params[1] = 4
		set_task(get_pcvar_float(g_alogtime) + 3, "KickPlayer", id+TASK_KICK, params, sizeof params)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public AdminLoginShowTimer(id)
{
	id -= TASK_TIMER

	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	switch(g_player_time[id])
	{
		case 10..19:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
		case 0..9:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		case -1:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.02, 1.0, _, _, 1)
		}
		default:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 0.02, 1.0, _, _, 1)
		}
	}

	if(g_player_time[id] == 0)
	{
		//ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "KICK_HUD")
		return PLUGIN_CONTINUE
	}
	else
	{
		if(g_player_time[id] == -1)
		{
			ShowSyncHudMsg(id, g_sync_hud, "%L", LANG_SERVER, "LOGIN_AFTER")
			set_task(1.0, "AdminLoginShowTimer", id+TASK_TIMER)
			return PLUGIN_HANDLED
		}
		ShowSyncHudMsg(id, g_sync_hud, "%L ", LANG_SERVER, "LOGIN_HUD", g_player_time[id])
	}
	
	g_player_time[id]--
	
	if(!is_logged_a[id])
	{
		set_task(1.0, "AdminLoginShowTimer", id+TASK_TIMER)
		client_cmd(id, "messagemode AdminPassword")
	}

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Show Client's informative Admin Login messages
================================================================================*/

/*==============================================================================
	Start of Admin Login function
================================================================================*/
public Login_Admin(id)
{
	if(!get_pcvar_num(g_alog_on) || !is_admin[id] || is_logged_a[id] || !name_checked[id])
		return PLUGIN_HANDLED

	read_args(typedadminpass, charsmax(typedadminpass))
	remove_quotes(typedadminpass)

	new line = 0
	new linetext[255], linetextlength
	new adminlogin[32], pword[32]

	new usercfg[64]
	get_configsdir(usercfg, 63)
	format(usercfg, 63, "%s/users.ini", usercfg)

	if(file_exists(usercfg))
	{
		while((line = read_file(usercfg, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, pword, 31)

			if( (equali(adminlogin, player_ip[id]) || equali(adminlogin, player_authid[id]) || equali(adminlogin, player_name[id])) && equal(pword, typedadminpass) )
			{
				attempts[id] = 0
				remove_task(id+TASK_KICK)
				remove_tasks(id)

				client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGING_A", prefix)
				log_to_file("addons/amxmodx/logs/GG_Logs/Admin_System_Logs.log", "%L", LANG_SERVER, "ADMINLOG_LOGIN", player_name[id], player_authid[id], player_ip[id], player_country[id], typedadminpass)

				is_logged_a[id] = true
				remove_user_flags(id, read_flags("z"))
				set_user_flags(id, flags[id])

				client_cmd(id, "jointeam")

				return PLUGIN_HANDLED
			}
		}
	}

	new usercfg2[64]
	get_configsdir(usercfg2, 63)
	format(usercfg2, 63, "%s/auto-admins.ini", usercfg2)

	if(file_exists(usercfg2))
	{
		while((line = read_file(usercfg2, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, pword, 31)

			if( (equali(adminlogin, player_ip[id]) || equali(adminlogin, player_authid[id]) || equali(adminlogin, player_name[id])) && equal(pword, typedadminpass) )
			{
				attempts[id] = 0
				remove_task(id+TASK_KICK)
				remove_tasks(id)

				client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGING_A", prefix)
				log_to_file("addons/amxmodx/logs/GG_Logs/Admin_System_Logs.log", "%L", LANG_SERVER, "ADMINLOG_LOGIN", player_name[id], player_authid[id], player_ip[id], player_country[id], typedadminpass)

				is_logged_a[id] = true
				remove_user_flags(id, read_flags("z"))
				set_user_flags(id, flags[id])

				client_cmd(id, "jointeam")

				return PLUGIN_HANDLED
			}
		}
	}

	new usercfg3[64]
	get_configsdir(usercfg3, 63)
	format(usercfg3, 63, "%s/manager/users.ini", usercfg3)

	if(file_exists(usercfg3))
	{
		while((line = read_file(usercfg3, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, pword, 31)

			if( (equali(adminlogin, player_ip[id]) || equali(adminlogin, player_authid[id]) || equali(adminlogin, player_name[id])) && equal(pword, typedadminpass) )
			{
				attempts[id] = 0
				remove_task(id+TASK_KICK)
				remove_tasks(id)

				client_printcolor(id, "%L", LANG_SERVER, "LOG_LOGING_A", prefix)
				log_to_file("addons/amxmodx/logs/GG_Logs/Admin_System_Logs.log", "%L", LANG_SERVER, "ADMINLOG_LOGIN", player_name[id], player_authid[id], player_ip[id], player_country[id], typedadminpass)

				is_logged_a[id] = true
				remove_user_flags(id, read_flags("z"))
				set_user_flags(id, flags[id])

				client_cmd(id, "jointeam")

				return PLUGIN_HANDLED
			}
		}
	}
	
	client_printcolor(id, "%L", LANG_SERVER, "LOG_PASS_INVALID", prefix)
	log_to_file("addons/amxmodx/logs/GG_Logs/Admin_System_Logs.log", "%L", LANG_SERVER, "ADMINLOG_PASS_INVALID", player_name[id], player_authid[id], player_ip[id], player_country[id], typedadminpass)
	client_cmd(id, "messagemode AdminPassword")
	
	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Admin Login function
================================================================================*/

/*==============================================================================
	Start of Jointeam menus and commands functions
================================================================================*/
public HookTeamCommands(id)
{
	if( (!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || !is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if( (get_pcvar_num(g_ver_on) && !is_verified[id]) || (get_pcvar_num(g_on) && is_registered[id] && !is_logged[id]) || (get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id]) )
	{
		if(get_pcvar_num(g_ver_on) && !is_verified[id])
		{
			return PLUGIN_HANDLED
		}
		if(get_pcvar_num(g_on) && is_registered[id] && !is_logged[id])
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		if(get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id])
		{
			client_cmd(id, "messagemode AdminPassword")
			return PLUGIN_HANDLED
		}
	}
	else if(get_pcvar_num(g_ajc_change) && cs_get_user_team(id) != CS_TEAM_UNASSIGNED && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
	{
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public TextMenu(msgid, dest, id)
{
	if( (!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || !is_user_connected(id) )
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	static menu_text[64];

	get_msg_arg_string(4, menu_text, charsmax(menu_text))

	if(equal(menu_text, JOIN_TEAM_MENU_FIRST) || equal(menu_text, JOIN_TEAM_MENU_FIRST_SPEC))
	{
		if( (get_pcvar_num(g_ver_on) && !is_verified[id]) || (get_pcvar_num(g_on) && is_registered[id] && !is_logged[id]) || (get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id]) )
		{
			if(get_pcvar_num(g_ver_on) && !is_verified[id])
			{
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_on) && is_registered[id] && !is_logged[id])
			{
				//MainMenu(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id])
			{
				client_cmd(id, "messagemode AdminPassword")
				return PLUGIN_HANDLED
			}
		}
		else if( (get_pcvar_num(g_ajc_team) && cs_get_user_team(id) == CS_TEAM_UNASSIGNED) && !task_exists(TASK_AJC) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)) )
		{
			SetAutoJoinTask(id, msgid)
			return PLUGIN_HANDLED
		}
	}
	else if(equal(menu_text, JOIN_TEAM_MENU_INGAME) || equal(menu_text, JOIN_TEAM_MENU_INGAME_SPEC))
	{
		if( (get_pcvar_num(g_ver_on) && !is_verified[id]) || (get_pcvar_num(g_on) && is_registered[id] && !is_logged[id]) || (get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id]) )
		{
			if(get_pcvar_num(g_ver_on) && !is_verified[id])
			{
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_on) && is_registered[id] && !is_logged[id])
			{
				//MainMenu(id)
				return PLUGIN_HANDLED
			}
			if(get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id])
			{
				client_cmd(id, "messagemode AdminPassword")
				return PLUGIN_HANDLED
			}
		}
		else if( get_pcvar_num(g_ajc_change) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)) )
		{
			return PLUGIN_HANDLED
		}	
	}
	return PLUGIN_CONTINUE
}

public VGUIMenu(msgid, dest, id)
{
	if((!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || get_msg_arg_int(1) != JOIN_TEAM_VGUI_MENU || !is_user_connected(id))
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if( (get_pcvar_num(g_ver_on) && !is_verified[id]) || (get_pcvar_num(g_on) && is_registered[id] && !is_logged[id]) || (get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id]) )
	{
		if(get_pcvar_num(g_ver_on) && !is_verified[id])
		{
			return PLUGIN_HANDLED
		}
		if(get_pcvar_num(g_on) && is_registered[id] && !is_logged[id])
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		if(get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id])
		{
			client_cmd(id, "messagemode AdminPassword")
			return PLUGIN_HANDLED
		}
	}
	else if(get_pcvar_num(g_ajc_team))
	{
		if((!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
		{
			if(cs_get_user_team(id) == CS_TEAM_UNASSIGNED && !task_exists(TASK_AJC))
			{
				SetAutoJoinTask(id, msgid)
				return PLUGIN_HANDLED
			}
			else if(get_pcvar_num(g_ajc_change))
			{
				return PLUGIN_HANDLED
			}
		}
	}
	else if(get_pcvar_num(g_ajc_change) && (!get_pcvar_num(g_ajc_admin) || !(get_user_flags(id) & AJC_ADMIN_FLAG)))
	{
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Jointeam menus and commands functions
================================================================================*/

/*==============================================================================
	Start of Auto Join function
================================================================================*/
public AutoJoin(parameters[], msgid)
{
	new id = parameters[0]

	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	if(cs_get_user_team(id) != CS_TEAM_UNASSIGNED)
		return PLUGIN_HANDLED

	new g_team[2], g_team_num = get_pcvar_num(g_ajc_team)

	if(g_team_num == 6)
	{
		num_to_str(g_team_num, g_team, charsmax(g_team))
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}

	if(g_team_num == 5)
	{
		new TNum, TPlayers[32], CTNum, CTPlayers[32]

		get_players (TPlayers, TNum, "e", "TERRORIST")
		get_players (CTPlayers, CTNum, "e", "CT")

		if(assassin_mod(id) || ghost_mod(id))
		{
			g_team_num = 2
		}
		else
		if(sniper_mod(id))
		{
			g_team_num = 1
		}
		else
		{
			if( TNum < CTNum )
				g_team_num = 1
			else
			if( TNum > CTNum )
				g_team_num = 2
			else
			if( TNum == CTNum )
				g_team_num = random_num(1, 2)
		}
	}
	else if(g_team_num != 1 && g_team_num != 2)
		return PLUGIN_HANDLED

	new g_class_num = get_pcvar_num(g_ajc_class[g_team_num - 1])
	num_to_str(g_team_num, g_team, charsmax(g_team))
	
	if(g_class_num == 5)
	{
		g_class_num = random_num(1, 4)

	}

	if(g_class_num == 0 || (g_class_num != 1 && g_class_num != 2 && g_class_num != 3 && g_class_num != 4))
	{
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}	

	new g_class[2], msg_block = get_msg_block(parameters[1])

	num_to_str(g_class_num, g_class, charsmax(g_class))

	set_msg_block(parameters[1], BLOCK_SET)
	engclient_cmd(id, "jointeam", g_team)
	engclient_cmd(id, "joinclass", g_class)
	set_msg_block(parameters[1], msg_block)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Auto Join functions
================================================================================*/

/*==============================================================================
	Start of Hook Client's commands
================================================================================*/
public client_command(id)
{
	if((!get_pcvar_num(g_ver_on) && !get_pcvar_num(g_on) && !get_pcvar_num(g_alog_on)) || !data_ready)
		return PLUGIN_HANDLED
		
	new command[64], arg[16], allargs[1024];

	read_argv(0, command, charsmax(command))
	read_argv(1, arg, charsmax(arg))
	read_args(allargs, charsmax(allargs))

	if((equali(command, "say") || equali(command, "say_team")) && (containi(allargs, passwd[id]) != -1 || containi(allargs, adminpasswd[id]) != -1))
		return PLUGIN_HANDLED
	
	if( get_pcvar_num(g_on) && ((equali(command, "say") || equali(command, "say_team")) && (equali(arg, "/reg") || equali(arg, "/register") || equali(arg, "/protect") || equali(arg, "/account"))) )
	{
		if(!name_checked[id])
		{
			client_printcolor(id, "%L", LANG_SERVER, "WHITE_LIST", prefix)
		}
		else
		{
			MainMenu(id)
		}

		return PLUGIN_CONTINUE
	}
	if(get_pcvar_num(g_comm) == 1)
	{
		if(TrieKeyExists(g_commands, command))
		{
			if(!is_registered[id] && get_pcvar_float(g_regtime))
			{
				// console_print(id, "%s %L", prefix, LANG_SERVER, "COMMAND_REG")
				// client_printcolor(id, "!g%s!t %L", prefix, LANG_SERVER, "COMMAND_REG")
				return PLUGIN_HANDLED
			}
			else if(is_registered[id] && !is_logged[id])
			{
				// console_print(id, "%s %L", prefix, LANG_SERVER, "COMMAND_LOG")
				// client_printcolor(id, "!g%s!t %L", prefix, LANG_SERVER, "COMMAND_LOG")
				return PLUGIN_HANDLED
			}	
		}
	}
	else if(get_pcvar_num(g_comm) == 2)
	{
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

/*==============================================================================
	End of Hook Client's commands
================================================================================*/

/*==============================================================================
	Start of Advret function
================================================================================*/
public ShowAdvert(id)
{
	id -= TASK_ADVERT
	
	if(!get_pcvar_num(g_on) || !get_pcvar_num(g_advert) || !is_user_connected(id))
		return PLUGIN_HANDLED

	if(!is_registered[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "YOUCANREG_CHAT", prefix)
	}
	else if(is_registered[id] && !has_email[id])
	{
		client_printcolor(id, "%L", LANG_SERVER, "YOUCANSETEMAIL_CHAT", prefix)
	}

	set_task(get_pcvar_float(g_advert_int), "ShowAdvert", id+TASK_ADVERT)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Advret function
================================================================================*/

/*==============================================================================
	Start of Player Spawn function
================================================================================*/
public CloseMenu(id)
{
	if(is_user_connected(id))
	{
		show_menu(id, 0, "^n", 1)
	}
}
/*==============================================================================
	End of Player Spawn function
================================================================================*/

/*==============================================================================
	Start of Reload Admins function
================================================================================*/
public ReloadAdmins()
{
	server_cmd("ggsv_amx_reloadadmins");
	set_task(0.5, "ReloadFlags");
}

public ReloadFlags()
{
	new iPlayers[ 32 ], iNum;

	get_players( iPlayers, iNum, "c" );
	for( new i = 0; i < iNum; i++ )
	{
		new player = iPlayers[ i ];

		if(is_admin[player] && !is_logged_a[player])
		{
			remove_user_flags(player, read_flags("abcdefghijklmnopqrstu"));
			set_user_flags(player, read_flags("z"));
		}
	}
}
/*==============================================================================
	End of Reload Admins function
================================================================================*/

/*==============================================================================
	Start of Player PreThink function for the blind function
================================================================================*/
public PlayerPreThink(id)
{
	if( (!get_pcvar_num(g_on) && !get_pcvar_num(g_ver_on) && !get_pcvar_num(g_alog_on)) || !get_pcvar_num(g_blind) || !is_user_connected(id) || changing_name[id] )
		return PLUGIN_HANDLED

	if( (get_pcvar_num(g_ver_on) && !is_verified[id]) || (get_pcvar_num(g_on) && is_registered[id] && !is_logged[id]) || (get_pcvar_num(g_alog_on) && is_admin[id] && !is_logged_a[id]) )
	{
		message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
		write_short(1<<12)
		write_short(1<<12)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Player PreThink function for the blind function
================================================================================*/

/*==============================================================================
	Start of Client Info Change function for hooking name change of clients
================================================================================*/
public ClientInfoChanged(id)
{
	if((!get_pcvar_num(g_on) && !get_pcvar_num(g_ver_on) && !get_pcvar_num(g_alog_on)) || !is_user_connected(id))
		return FMRES_IGNORED

	new oldname[32], newname[32];

	get_user_name(id, oldname, charsmax(oldname))
	get_user_info(id, "name", newname, charsmax(newname))

	if(!equali(oldname, newname))
	{
		replace_all(newname, charsmax(newname), "%", " ")

		changing_name[id] = false

		if(!is_user_alive(id))
		{
			changing_name[id] = true
		}
		else
		{
			if(is_logged[id])
			{
				set_user_info(id, "name", oldname)
				client_printcolor(id, "%L", LANG_SERVER, "NAME_CHANGE_LOG", prefix)
				return FMRES_HANDLED
			}

			if(get_pcvar_num(g_whitelist))
			{
				set_task(1.0, "CheckName", id)
			}
			else
			{
				set_task(1.0, "CheckClient", id)
			}
		}
	}
	return FMRES_IGNORED
}
/*==============================================================================
	End of Client Info Change function for hooking name change of clients
================================================================================*/

/*==============================================================================
	Start of Kick Player function
================================================================================*/
public KickPlayer(parameters[])
{
	new id = parameters[0]
	new reason = parameters[1]

	if(!is_user_connecting(id) && !is_user_connected(id))
		return PLUGIN_HANDLED

	new ip[32]
	get_user_ip(id, ip, 31)

	if( equali(ip, "127.0.0.1")  )
		return PLUGIN_HANDLED

	new userid = get_user_userid(id)

	switch(reason)
	{
		case 1:
		{
			if(is_logged[id])
				return PLUGIN_HANDLED

			console_print(id, "%L", LANG_SERVER, "KICK_INFO")
			server_cmd("kick #%i ^"%L^"", userid, LANG_SERVER, "KICK_LOGIN")
		}
		case 2:
		{
			console_print(id, "%L", LANG_SERVER, "KICK_INFO2")
			server_cmd("kick #%i ^"%L^"", userid, LANG_SERVER, "KICK_VERIFICATION")
		}
		case 3:
		{
			console_print(id, "%L", LANG_SERVER, "KICK_INFO3")
			server_cmd("kick #%i ^"%L^"", userid, LANG_SERVER, "KICK_LOGIN_VERIFICATION")
		}
		case 4:
		{
			console_print(id, "%L", LANG_SERVER, "KICK_INFO4")
			server_cmd("kick #%i ^"%L^"", userid, LANG_SERVER, "KICK_LOGIN_ADMIN")
		}
	}
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Kick Player function
================================================================================*/

/*==============================================================================
	Start of Removing Punishes function
================================================================================*/
public RemoveCantLogin(data[])
{
	TrieDeleteKey(g_login_times, data)
	TrieDeleteKey(g_cant_login_time, data)
}

public RemoveCantChangePass(data[])
{
	TrieDeleteKey(g_cant_change_pass_time, data)
	TrieDeleteKey(g_pass_change_times, data)

	new target;
	
	switch(get_pcvar_num(g_member))
	{
		case 0:
		{
			target = find_player("a", data)
		}
		case 1:
		{
			target = find_player("d", data)
		}
		case 2:
		{
			target = find_player("c", data)
		}
		default:
		{
			target = find_player("a", data)
		}
	}

	if(!target)
		return PLUGIN_HANDLED

	cant_change_pass[target] = false
	client_printcolor(target, "%L", LANG_SERVER, "CHANGE_CAN", prefix)
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Removing Punish function
================================================================================*/

/*==============================================================================
	Start of Plugin's stocks
================================================================================*/
stock client_printcolor(const id, const message[], any:...)
{
	new g_message[191];
	new i = 1, players[32];

	vformat(g_message, charsmax(g_message), message, 3)

	replace_all(g_message, charsmax(g_message), "!g", "^4")
	replace_all(g_message, charsmax(g_message), "!n", "^1")
	replace_all(g_message, charsmax(g_message), "!t", "^3")

	if(id)
	{
		players[0] = id
	}
	else
	{
		get_players(players, i, "ch")
	}

	for(new j = 0; j < i; j++)
	{
		if(is_user_connected(players[j]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_saytxt,_, players[j])
			write_byte(players[j])
			write_string(g_message)
			message_end()
		}
	}
}

stock convert_password(const password[])
{
	new pass_salt[64], converted_password[34];

	formatex(pass_salt, charsmax(pass_salt), "%s%s", password, SALT)
	md5(pass_salt, converted_password)
	
	return converted_password
}

stock SetAutoJoinTask(id, menu_msgid)
{
	params[0] = id
	params[1] = menu_msgid

	set_task(AJC_TASK_TIME, "AutoJoin", id+TASK_AJC, params, sizeof params)
}

stock clear_user(const id)
{
	is_logged[id] = false
	is_registered[id] = false
	is_registered_old[id] = false
	cant_change_pass[id] = false
	changing_name[id] = false
	name_checked[id] = true
	attempts[id] = 0
	times[id] = 0
	already[id] = false
	is_verified[id] = false
	is_admin[id] = false
	is_logged_a[id] = false
	admin_exist[id] = false
	adminpasswd[id] = "";
	has_email[id] = false
}

stock remove_tasks(const id)
{
	remove_task(id+TASK_MESS)
	remove_task(id+TASK_KICK)
	remove_task(id+TASK_MENU)
	remove_task(id+TASK_TIMER)
	//remove_task(id+TASK_ADVERT)
	remove_task(id+TASK_AJC)
	remove_task(id)
}

/*==============================================================================
	End of Plugin's stocks
================================================================================*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
