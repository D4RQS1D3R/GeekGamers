///** ----------------------------------------- [ Plugin By ~DarkSiDeRs~ ] ------------------------------------------------ **///
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fvault_new>
#include <nvault>
#include <sqlx>
#include <csx>
#include <hamsandwich>
#include <fun>
#include <fcs>

#pragma compress 1
#pragma semicolon 1

#define TOP 10

#define ADMIN_LEVEL ADMIN_LEVEL_B

static const SQLX_HOSTNAME[] =	"127.0.0.1";
static const SQLX_USERNAME[] =	"gg_cs16_db";
static const SQLX_PASSWORD[] =	"GGCS16@Db";
static const SQLX_DBNAME[]   =	"gg_furien";

static Handle: g_Sqlx;

const pev_spec = pev_iuser2;

new key[64], name[65], data_[328];
new g_class[33][34], g_level[32], g_exp[32], g_exp2[32];
new g_add, g_max, g_save, g_fade, g_backup;
new accessmenu, iName[64], callback;
new g_MsgSync;
new path[128], data[256], top_level[33], top_exp[33], top_exp2[33], top_name[33][33];
new bool: data_loaded[33];

new const file_dir[] = "addons/amxmodx/data/file_vault";
new const backup_file_dir[] = "addons/amxmodx/data/file_vault/backup/level";

new sound[] = "[GeekGamers]/level_up_new.wav";

native HC_Level(id);
native WhiteListed(const PlayerName[]);

native assassin_mod(id);
native sniper_mod(id);
native ghost_mod(id);

new const Grades[][][] = {
	// { "*Empty*", "T Grade", "CT Grade", "*Empty*" },
	{ "", "", "", "" }, // 0
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Novice", "Private", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Bravi", "Private 2", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Rutterkin", "Private First Class", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Waghalter", "Specialist", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Murderer", "Corporal", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Thug", "Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Killer", "Staff Sergeant", "" },
	{ "", "Cutthroat", "Staff Sergeant", "" },
	{ "", "Cutthroat", "Staff Sergeants", "" },
	{ "", "Cutthroat", "Staff Sergeant", "" },
	{ "", "Cutthroat", "Staff Sergeant", "" },
	{ "", "Cutthroat", "Staff Sergeant", "" },
	{ "", "Cutthroat", "Sergeant First Class", "" },
	{ "", "Cutthroat", "Sergeant First Class", "" },
	{ "", "Cutthroat", "Sergeant First Class", "" },
	{ "", "Cutthroat", "Sergeant First Class", "" },
	{ "", "Cutthroat", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Executioner", "Sergeant First Class", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "Master Sergeant", "" },
	{ "", "Expert Assassin", "First Sergeant", "" },
	{ "", "Expert Assassin", "First Sergeant", "" },
	{ "", "Expert Assassin", "First Sergeant", "" },
	{ "", "Expert Assassin", "First Sergeant", "" },
	{ "", "Expert Assassin", "First Sergeant", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Senior Assassin", "First Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Chief Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Sergeant Major", "" },
	{ "", "Prime Assassin", "Command Sergeant Major", "" },
	{ "", "Prime Assassin", "Command Sergeant Major", "" },
	{ "", "Prime Assassin", "Command Sergeant Major", "" },
	{ "", "Prime Assassin", "Command Sergeant Major", "" },
	{ "", "Prime Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Guildmaster Assassin", "Command Sergeant Major", "" },
	{ "", "Grandfather of Assassins", "Sergeant Major of the Army", "" },
};

public plugin_precache()
{
	precache_sound(sound);
}

public plugin_init()
{
	register_plugin("[GG] Level Up System", "1.2", "~DarkSiDeRs~");

	register_clcmd("say /level", "show_level");
	register_clcmd("say /lvl", "show_level");
	register_clcmd("say /getinfo", "show_level");

	register_clcmd("say /toplevel", "show_top");
	register_clcmd("say toplevel", "show_top");
	register_clcmd("say /toplvl", "show_top");
	register_clcmd("say toplvl", "show_top");

	register_clcmd("givelevelmenu", "level_menu", ADMIN_LEVEL);

	register_clcmd("say /givelevel", "give_level_menu", ADMIN_LEVEL);
	register_clcmd("GiveLevel", "give_level", ADMIN_LEVEL);
	register_clcmd("amx_give_level", "give_level_cmd", ADMIN_LEVEL);

	register_clcmd("say /giveexp", "give_exp_menu", ADMIN_LEVEL);
	register_clcmd("GiveExp", "give_exp", ADMIN_LEVEL);
	register_clcmd("amx_give_exp", "give_exp_cmd", ADMIN_LEVEL);

	register_clcmd("say /resetlevel", "reset_level_menu", ADMIN_LEVEL);
	register_clcmd("amx_reset_level", "reset_level_cmd", ADMIN_LEVEL);

	register_event("StatusValue", "show_hud_pid", "be", "1=2", "2!0");
	// register_event("DeathMsg", "event_death", "a");
	register_event("SendAudio", "Furien_Win", "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "AntiFurien_Win", "a", "2&%!MRAD_ctwin");
	
	register_logevent("New_Round", 2, "1=Round_Start");
	
	RegisterHam(Ham_Killed, "player", "event_death");

	g_MsgSync = CreateHudSyncObj();

	g_add		= register_cvar("amx_add_exp", "1", ADMIN_LEVEL);
	g_max		= register_cvar("amx_maxlevel", "1000", ADMIN_LEVEL);
	g_save		= register_cvar("amx_level_save", "1", ADMIN_LEVEL); // file (0) - MySQL (1)
	g_fade		= get_user_msgid("ScreenFade");

	g_backup	= register_cvar("amx_level_backup", "1", ADMIN_LEVEL);
	
	// MySQL
	MySQLInit();
	
	if(!dir_exists(file_dir)) mkdir(file_dir);
	set_task(1.0, "read_top");
	
	if(!dir_exists(backup_file_dir)) mkdir(backup_file_dir);
	Backup();
}

MySQLInit()
{
	if(get_pcvar_num(g_save) != 1)
		return;

	g_Sqlx = SQL_MakeDbTuple(SQLX_HOSTNAME, SQLX_USERNAME, SQLX_PASSWORD, SQLX_DBNAME);
	SQL_ThreadQuery(g_Sqlx, "QueryOK", "CREATE TABLE IF NOT EXISTS LevelSystem (ID INT(10) UNSIGNED AUTO_INCREMENT, Player VARCHAR(35) NOT NULL PRIMARY KEY, Level INT(10) NOT NULL, EXP INT(10) NOT NULL, EXP2 INT(10) NOT NULL, KEY `ID` (`ID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

public client_connect(id)
{
	data_loaded[id] = false;
}

public client_putinserver(id)
{
	load_data(id);
	
	set_task(0.1, "show_hud", id, _, _, "b");
	// set_task(5.0, "WelcomeMessage", id);

	new ip[32];
	get_user_ip(id, ip, 31);

	if( equali(ip, "127.0.0.1") )
	{
		g_level[id] = random_num(3, 15);
		g_exp[id] = random_num(10, 24);
		g_exp2[id] = g_level[id] * 5;
	}
}

public client_disconnected(id)
{
	save_data(id);
	remove_task(id);
}

public New_Round()
{
	new players[32], pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i < pnum; i++)
	{
		tempid = players[i];
		save_data(tempid);
	}
}

public plugin_natives()
{
	/* Level */
	register_native("get_level", "native_level", 1);
	register_native("get_exp", "native_exp", 1);
	register_native("get_exp2", "native_exp2", 1);

	/* Classes */
	register_native("class_furien", "native_class_furien", 1);
	register_native("class_furien2", "native_class_furien2", 1);
	register_native("class_furien3", "native_class_furien3", 1);
	register_native("class_furien_assassin", "native_class_furien_assassin", 1);
	register_native("class_furien_ghost", "native_class_furien_ghost", 1);
	register_native("class_human", "native_class_human", 1);
	register_native("class_human2", "native_class_human2", 1);
	register_native("class_human3", "native_class_human3", 1);
	register_native("class_human_survivor", "native_class_human_survivor", 1);
	register_native("class_human_sniper", "native_class_human_sniper", 1);
}

///** ---------------------------------------- [ Level Up ] ----------------------------------------------- **///

public event_death(const victim, const attacker)
{
	if(!attacker || !is_user_connected(attacker))
		return;
		
	if(attacker == victim)
		return;
		
	AddEXP(attacker, get_pcvar_num(g_add));
}

public AddEXP(id, exp)
{
	while(exp > 0)
	{
		if(g_level[id] < get_pcvar_num(g_max))
		{
			if(g_exp[id] + 1 >= g_exp2[id])
			{
				g_level[id] ++;
				g_exp[id] = 0;
				g_exp2[id] = CalculateEXP2(g_level[id]);
				
				message_begin(MSG_ONE_UNRELIABLE, g_fade, _, id);
				write_short(1<<12);
				write_short(1);
				write_short(0x0000);
				write_byte(1);
				write_byte(200);
				write_byte(0);
				write_byte(205);
				message_end();
				
				emit_sound(id, CHAN_STREAM, sound, 1.0, ATTN_NORM, 0, PITCH_HIGH);
				
				new name[32];
				get_user_name(id, name, charsmax(name));
				
				emit_sound(id, CHAN_STREAM, sound, 1.0, ATTN_NORM, 0, PITCH_HIGH);
				ChatColor(0, "!g[GG][Level] !t%s !nLeveled up to !glevel %i!n.", name, g_level[id]);

				new iPlayers[ 32 ], iNum;

				get_players( iPlayers, iNum, "ch" );		
				for( new i = 0 ; i < iNum ; i++ )
				{
					if( HC_Level( iPlayers[ i ] ) )
					{
						set_hudmessage(0, 200, 0, 0.65, 0.5, 0, 0.0, 3.0, 2.0, 1.0, -1);
						show_hudmessage(iPlayers[ i ], "%s Leveled up to level %i", name, g_level[id]);
					}
				}
			}
			else g_exp[id] ++;
		}
		else g_exp[id] ++;

		exp--;
	}
}

public CalculateEXP2(level)
{
	new i = 1;
	while(i != 0)
	{
		new temp_level = i * 100;
		if(temp_level - 100 < level < temp_level)
		{
			i = 0;
			return (temp_level / 20) * level;
		}
		i++;
	}

	return 0;
}

///** -------------------------------------- [ Level Menu ] ---------------------------------------------- **///

public level_menu(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
		return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rLevel Menu:","LevelMenuHandler");

	menu_additem(menu, "\yGive \rLevel", "1", 0);
	menu_additem(menu, "\yLevel \rEXP^n", "2", 0);

	menu_additem(menu, "\rRestart \yLevel", "3", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public LevelMenuHandler(id, menu, item)
{
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	switch(key)
	{
		case 1: give_level_menu(id);
		case 2: give_exp_menu(id);
		case 3: reset_level_menu(id);
	}
}

///** -------------------------------------- [ Give Level Menu ] ---------------------------------------------- **///

public give_level_menu(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
		return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \wChoose a Player To Give \rLevel:", "give_exp_menu_handler");
	
	new name[32], pid[32], players[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 

		if( g_level[tempid] == get_pcvar_num(g_max) )
			formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r]", name, g_level[tempid], g_exp[tempid]);
		else formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r/\y%i\r]", name, g_level[tempid], g_exp[tempid], g_exp2[tempid]);

		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public give_level_menu_handler(id, players_menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu);
		return PLUGIN_HANDLED;
	}
   
	new data[6];
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	new player = str_to_num(data);
	client_cmd(id, "messagemode ^"GiveLevel %i^"", player);
	return PLUGIN_CONTINUE;
}

public give_level(id)
{
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

	if( amount <= 0 || amount > get_pcvar_num(g_max) )
		return 0;

	read_argv(1, param, charsmax(param));
	new player = str_to_num(param);

	new name[33];
	get_user_name(player, name, charsmax(name));

	server_cmd("amx_give_level ^"%s^" ^"%d^"", name, amount);

	return 0;
}

///** ---------------------------------------- [ Give Level ] ----------------------------------------------- **///

public give_level_cmd(id, level, cid)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
	{
		return PLUGIN_HANDLED;
	}

	if (!cmd_access(id, level, cid, 2))
	{
        	return PLUGIN_HANDLED;
	}

	new target[32],count[32];
	read_argv(1, target, 31);
	read_argv(2, count, 31);

	new name[32], nameid[32], level_id, target_id;
	level_id = str_to_num(count);
	target_id = find_player("bl", target);
	get_user_name(target_id, name, sizeof name - 1);
	get_user_name(id, nameid, sizeof nameid - 1);

	if(!target_id) 
	{
		console_print(id, "[GG] Can't find that player!");
		return PLUGIN_HANDLED;
	}

	if(read_argc() != 3)
		return PLUGIN_HANDLED;

	if( 0 < level_id <= get_pcvar_num(g_max) )
	{
		g_level[target_id] = level_id;
		g_exp[target_id] = 0;

		if( g_level[target_id] < 100 )
		{
			g_exp2[target_id] = g_level[target_id] * 5;
		}
		else
		if( 100 <= g_level[target_id] < 200 )
		{
			g_exp2[target_id] = g_level[target_id] * 10;
		}
		else
		if( 200 <= g_level[target_id] < 300 )
		{
			g_exp2[target_id] = g_level[target_id] * 15;
		}
		else
		if( 300 <= g_level[target_id] < 400 )
		{
			g_exp2[target_id] = g_level[target_id] * 20;
		}
		else
		if( 400 <= g_level[target_id] < get_pcvar_num(g_max) )
		{
			g_exp2[target_id] = g_level[target_id] * 25;
		}

		message_begin(MSG_ONE_UNRELIABLE, g_fade, _, target_id);
		write_short(1<<12);
		write_short(1);
		write_short(0x0000);
		write_byte(1);
		write_byte(200); 
		write_byte(0);
		write_byte(205);
		message_end();
		emit_sound(target_id, CHAN_STREAM, sound, 1.0, ATTN_NORM, 0, PITCH_HIGH);
		ChatColor(0, "!g[GG][Level] !nOWNER !t%s !nSet The Level Of !t%s !nTo !g%i !", nameid, name, level_id);

		set_hudmessage(0, 200, 0, 0.65, 0.5, 0, 0.0, 3.0, 2.0, 1.0, -1);
		show_hudmessage(0, "%s Has Cut Down %d level", name, g_level[target_id]);
		ChatColor(0, "!g[GG][Level] !t%s !nHas Cut Down !g%i level !g!", name, g_level[target_id]);
	}

	return PLUGIN_CONTINUE;
}

///** -------------------------------------- [ Give EXP Menu ] ----------------------------------------------- **///

public give_exp_menu(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
		return PLUGIN_HANDLED;

	new menu = menu_create("\d[\yGeek~Gamers\d] \wChoose a Player To Give \rEXP:", "give_exp_menu_handler");
	
	new name[32], pid[32], players[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 

		if( g_level[tempid] == get_pcvar_num(g_max) )
			formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r]", name, g_level[tempid], g_exp[tempid]);
		else formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r/\y%i\r]", name, g_level[tempid], g_exp[tempid], g_exp2[tempid]);

		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public give_exp_menu_handler(id, players_menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(players_menu);
		return PLUGIN_HANDLED;
	}
   
	new data[6];
	menu_item_getinfo(players_menu, item, accessmenu, data, charsmax(data), iName, charsmax(iName), callback);

	new player = str_to_num(data);
	client_cmd(id, "messagemode ^"GiveExp %i^"", player);
	return PLUGIN_CONTINUE;
}

public give_exp(id)
{
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

	new name[33];
	get_user_name(player, name, charsmax(name));

	client_cmd(id, "amx_give_exp ^"%s^" ^"%d^"", name, amount);

	return 0;
}

///** ---------------------------------------- [ Give EXP ] ----------------------------------------------- **///

public give_exp_cmd(id, level, cid)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
	{
		return PLUGIN_HANDLED;
	}

	if (!cmd_access(id, level, cid, 2))
	{
        	return PLUGIN_HANDLED;
	}

	new target[32],count[32];
	read_argv(1, target, 31);
	read_argv(2, count, 31);

	new name[32], nameid[32], exp_id, target_id;
	exp_id = str_to_num(count);
	target_id = find_player("bl", target);
	get_user_name(target_id, name, sizeof name - 1);
	get_user_name(id, nameid, sizeof nameid - 1);

	if(!target_id) 
	{
		console_print(id, "[GG] Can't find that player!");
		return PLUGIN_HANDLED;
	}

	if(read_argc() != 3)
		return PLUGIN_HANDLED;

	if( 0 < exp_id <= g_exp2[target_id] )
	{
		g_exp[target_id] = exp_id;
		ChatColor(0, "!g[GG][Level] !nOWNER !t%s !nGive !g%i EXP !nTo !t%s !g!", nameid, exp_id, name);
	}
	else console_print(id, "[GG] You can't give more than %d EXP!", g_exp2[target_id]);

	return PLUGIN_CONTINUE;
}

///** ---------------------------------------- [ Reset Level ] ----------------------------------------------- **///

public reset_level_menu(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
		return PLUGIN_HANDLED;

	new menu = menu_create ("\d[\yGeek~Gamers\d] \wChoose a Player To \rReset Level:", "reset_level_handler");
	
	new name[32], pid[32], players[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name)); 

		if( g_level[tempid] == get_pcvar_num(g_max) )
			formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r]", name, g_level[tempid], g_exp[tempid]);
		else formatex(text, charsmax(text), "%s \y- \r[Level: \y%i\r] [Exp: \y%i\r/\y%i\r]", name, g_level[tempid], g_exp[tempid], g_exp2[tempid]);

		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public reset_level_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new szName[33], szPlayerName[33];
	new data[6], name[64];
	new access, callback;
    
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback);
	new tempid = str_to_num(data);

	get_user_name(id, szName, 32);
	get_user_name(tempid, szPlayerName, 32);

	client_cmd(id, "amx_reset_level ^"%s^"",name);
	reset_level_menu(id);
    
	return PLUGIN_CONTINUE;
}

public reset_level_cmd(id, level, cid)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL))
	{
		return PLUGIN_HANDLED;
	}

	if (!cmd_access(id, level, cid, 2))
	{
        	return PLUGIN_HANDLED;
	}

	new target[32];
	read_argv(1, target, 31);

	new name[32], nameid[32], target_id;
	target_id = find_player("bl", target);
	get_user_name(target_id, name, sizeof name - 1);
	get_user_name(id, nameid, sizeof nameid - 1);

	if(!target_id) 
	{
		console_print(id, "[GG] Can't find that player!");
		return PLUGIN_HANDLED;
	}

	if(read_argc() != 3)
		return PLUGIN_HANDLED;

	g_level[target_id] = 1;
	g_exp[target_id] = 0;
	g_exp2[target_id] = 5;

	ChatColor(0, "!g[GG][Level] !nOWNER !t%s !nRestared The Level Of !t%s !g!", nameid, name);

	return PLUGIN_CONTINUE;
}

///** ---------------------------------------- [ Win EXP Bonus ] ----------------------------------------------- **///

public Furien_Win()
{
	new id, iPlayers[ 32 ], iNum, TPlayers[ 32 ], TNum, CTPlayers[ 32 ], CTNum, EXPBonus = 0;

	get_players( iPlayers, iNum );
	get_players( TPlayers, TNum, "ahe", "TERRORIST" );
	get_players( CTPlayers, CTNum, "bhe", "CT" );
	
	if( iNum < 6 )
		return;

	if( assassin_mod(id) )
	{
		EXPBonus = CTNum;
		ChatColor(0, "!g[GG][ Win Bonus ] !tAssassin !nWin: !g%d EXP !n+ !g%d Credits !nWill be added to the !tAssassin!n.", EXPBonus, 5 + CTNum);
	}
	else if( ghost_mod(id) )
	{
		EXPBonus = CTNum;
		ChatColor(0, "!g[GG][ Win Bonus ] !tGhost !nWin: !g%d EXP !n+ !g%d Credits !nWill be added to the !tGhost!n.", EXPBonus, 5 + CTNum);
	}
	else
	{
		EXPBonus = 2;
		ChatColor(0, "!g[GG][ Win Bonus ] !tFuriens !nWin: !g%d EXP !n+ !g%d Credits !nWill be added to Alive !tFuriens!n.", EXPBonus, 5);
	}

	if(EXPBonus <= 0)
		return;
	
	for( new i = 0; i < TNum; i++ )
	{
		AddEXP(TPlayers[ i ], EXPBonus);
	}
}

public AntiFurien_Win()
{
	new id, iPlayers[ 32 ], iNum, TPlayers[ 32 ], TNum, CTPlayers[ 32 ], CTNum, EXPBonus = 0;

	get_players( iPlayers, iNum );
	get_players( CTPlayers, CTNum, "ahe", "CT" );
	get_players( TPlayers, TNum, "bhe", "TERRORIST" );

	if( iNum < 6 )
		return;

	if( sniper_mod(id) )
	{
		EXPBonus = TNum;
		ChatColor(0, "!g[GG][ Win Bonus ] !tSniper !nWin: !g%d EXP !n+ !g%d Credits !nWill be added to the !tSniper!n.", EXPBonus, 10 + TNum);
	}
	else
	{
		EXPBonus = 3;
		ChatColor(0, "!g[GG][ Win Bonus ] !tAnti-Furiens !nWin: !g%d EXP !n+ !g%d Credits !nWill be added to Alive !tAnti-Furiens!n.", EXPBonus, 10);
	}
	
	if(EXPBonus <= 0)
		return;
	
	for( new i = 0; i < CTNum; i++ )
	{
		AddEXP(CTPlayers[ i ], EXPBonus);
	}
}

///** ----------------------------------------- [ Welcome Message ] ------------------------------------------------- **///
/*
public WelcomeMessage(id)
{
	new szName[32];
        get_user_name(id, szName, charsmax(szName));

	ChatColor(id, "!g[GG][Level] !nWelcome !t%s !nYour level is !g%i !", szName, g_level[id]);
}
*/
///** ---------------------------------------- [ Show Hud msg ] ----------------------------------------------- **///

public show_hud(id)
{
	if(!HC_Level(id))
		return;

	new name[33], spec = pev(id, pev_spec);
	get_user_name(spec, name, charsmax(name));

	if(is_user_alive(id))
	{
		set_hudmessage(0, 255, 0, -1.0, 0.85, _, _, 4.0, _, _, 1);
		
		if( g_level[id] == get_pcvar_num(g_max) )
			ShowSyncHudMsg(id, g_MsgSync, "-=[Geek~Gamers]=-^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d ]", get_user_health(id), get_user_armor(id), g_class[id], fcs_get_user_credits(id), (g_level[id] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(id)] : Grades[g_level[id]][get_user_team(id)]), g_level[id], g_exp[id]);
		else ShowSyncHudMsg(id, g_MsgSync, "-=[Geek~Gamers]=-^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d/%d ]", get_user_health(id), get_user_armor(id), g_class[id], fcs_get_user_credits(id), (g_level[id] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(id)] : Grades[g_level[id]][get_user_team(id)]), g_level[id], g_exp[id], g_exp2[id]);
	}

	if(is_user_alive(spec))
	{
		set_hudmessage(235, 10, 227, -1.0, 0.80, _, _, 4.0, _, _, 1);
		
		if(g_level[spec] == get_pcvar_num(g_max))
			ShowSyncHudMsg(id, g_MsgSync, "Spectating: %s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d ]", name, is_user_steam(spec) ? "- [STEAM USER]" : "", get_user_health(spec), get_user_armor(spec), g_class[spec], fcs_get_user_credits(spec), (g_level[spec] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(spec)] : Grades[g_level[spec]][get_user_team(spec)]), g_level[spec], g_exp[spec]);
		else ShowSyncHudMsg(id, g_MsgSync, "Spectating: %s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d/%d ]", name, is_user_steam(spec) ? "- [STEAM USER]" : "", get_user_health(spec), get_user_armor(spec), g_class[spec], fcs_get_user_credits(spec), (g_level[spec] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(spec)] : Grades[g_level[spec]][get_user_team(spec)]), g_level[spec], g_exp[spec], g_exp2[spec]);
	}
}

public show_hud_pid(id)
{
	if(!HC_Level(id))
		return;

	new name[33], pid = read_data(2); get_user_name(pid, name, charsmax(name));
	new aim, body; get_user_aiming(id, aim, body);

	set_hudmessage(238, 50, 0, -1.0, 0.55, 0, 0.01, 3.0, 0.1, 0.1, 2);

	if(is_user_alive(aim) && get_user_team(id) == 1 && get_user_team(aim) == 1) 
	{
		if( g_level[aim] == get_pcvar_num(g_max) )
			ShowSyncHudMsg(id, g_MsgSync, "%s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d ]", name, is_user_steam(pid) ? "- [STEAM USER]" : "", get_user_health(pid), get_user_armor(pid), g_class[pid], fcs_get_user_credits(pid), (g_level[pid] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(pid)] : Grades[g_level[pid]][get_user_team(pid)]), g_level[pid], g_exp[pid]);
		else ShowSyncHudMsg(id, g_MsgSync, "%s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d/%d ]", name, is_user_steam(pid) ? "- [STEAM USER]" : "", get_user_health(pid), get_user_armor(pid), g_class[pid], fcs_get_user_credits(pid), (g_level[pid] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(pid)] : Grades[g_level[pid]][get_user_team(pid)]), g_level[pid], g_exp[pid], g_exp2[pid]);
	}	
	else
	if(is_user_alive(aim) && get_user_team(id) == 2 && get_user_team(aim) == 2) 
	{
		if( g_level[aim] == get_pcvar_num(g_max) )
			ShowSyncHudMsg(id, g_MsgSync, "%s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d ]", name, is_user_steam(pid) ? "- [STEAM USER]" : "", get_user_health(pid), get_user_armor(pid), g_class[pid], fcs_get_user_credits(pid), (g_level[pid] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(pid)] : Grades[g_level[pid]][get_user_team(pid)]), g_level[pid], g_exp[pid]);
		else ShowSyncHudMsg(id, g_MsgSync, "%s %s^n[ Health: %d | Armor: %d | Class: %s | Credits: %d ]^n[ Grade: %s | Level: %d | Exp: %d/%d ]", name, is_user_steam(pid) ? "- [STEAM USER]" : "", get_user_health(pid), get_user_armor(pid), g_class[pid], fcs_get_user_credits(pid), (g_level[pid] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][get_user_team(pid)] : Grades[g_level[pid]][get_user_team(pid)]), g_level[pid], g_exp[pid], g_exp2[pid]);
	}
}

///** ----------------------------------------- [ Show level ] ------------------------------------------------ **///

public show_level(id)
{
	new menu = menu_create("\d[\yGeek~Gamers\d] \rPlayers Level \wMenu:", "level_handle");
	
	new name[32], pid[32], players[32], text[555 char],pnum, tempid;
	get_players(players, pnum, "c");
	
	for(new i; i< pnum; i++)
	{
		tempid = players[i];
		
		get_user_name(tempid, name, charsmax(name));

		if( g_level[tempid] == get_pcvar_num(g_max) )
			formatex(text, charsmax(text), "%s \y- \r[Level: \y%d\r] [Exp: \y%d r]", name, g_level[tempid], g_exp[tempid]);
		else formatex(text, charsmax(text), "%s \y- \r[Level: \y%d\r] [Exp: \y%d\r/\y%d\r]", name, g_level[tempid], g_exp[tempid], g_exp2[tempid]);

		num_to_str(get_user_userid(tempid), pid, 9);
		menu_additem(menu, text, pid, 0);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public level_handle(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6], name[64];
	new access, callback;
    
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback);

	show_level(id);
	return PLUGIN_CONTINUE;
}

///** --------------------------------------- [ Save/Load level ] --------------------------------------------- **///

public save_data(id)
{
	if(!data_loaded[id]) return;

	if(is_user_bot(id)) return;
	
	get_user_name(id, name, 34);
	
	if(get_pcvar_num(g_save) == 1)
	{
		static query[256];
		
		formatex(query, sizeof(query) - 1, "INSERT INTO `LevelSystem` (`Player`, `Level`, `EXP`, `EXP2`) VALUES (^"%s^", ^"%d^", ^"%d^", ^"%d^") ON DUPLICATE KEY UPDATE `Level` = ^"%d^", `EXP` = ^"%d^", `EXP2` = ^"%d^"", name, g_level[id], g_exp[id], g_exp2[id], g_level[id], g_exp[id], g_exp2[id]);
		SQL_ThreadQuery(g_Sqlx, "QueryOK", query);
	}
	else
	{
		format(key, 63, "%s", name);
		format(data_, 327, "^"%d^" ^"%d^" ^"%d^"", g_level[id], g_exp[id], g_exp2[id]);
		fvault_set_data("gg-level", key, data_);
	}
	
	update_top(id, g_level[id], g_exp[id], g_exp2[id]);
}

public load_data(id)
{
	if(is_user_bot(id)) return;
	
	data_loaded[id] = false;
	
	new level[32], exp[32], exp2[32];
	get_user_name(id, name, 34);
	
	if(get_pcvar_num(g_save) == 1)
	{
		static query[256], data[1]; data[0] = id;
		
		formatex(query, sizeof(query) - 1, "SELECT * FROM `LevelSystem` WHERE `Player` = ^"%s^"", name);
		SQL_ThreadQuery(g_Sqlx, "QueryLoadPlayer", query, data, 1);
	}
	else
	{
		format(key, 63, "%s", name);
		format(data_, 327, "^"%d^" ^"%d^" ^"%d^"", g_level[id], g_exp[id], g_exp2[id]);
		fvault_get_data("gg-level", key, data_, charsmax(data_));
		
		parse(data_, level, sizeof(level) - 1, exp, sizeof(exp) - 1, exp2, sizeof(exp2) - 1);

		g_level[id] = str_to_num(level);
		g_exp[id] = str_to_num(exp);
		g_exp2[id] = str_to_num(exp2);
		
		if(g_level[id] == 0)
		{
			g_level[id] = 1;
			g_exp[id] = 0;
			g_exp2[id] = 5;
		}

		data_loaded[id] = true;
	}
}

///** ----------------------------------------- [ Top level ] ------------------------------------------------- **///

public read_top()
{
	if(get_pcvar_num(g_save) == 1)
	{
		static query[256];
		
		formatex(query, sizeof(query) - 1, "SELECT * FROM `LevelSystem` ORDER BY Level DESC, EXP DESC LIMIT %d", TOP+1);
		SQL_ThreadQuery(g_Sqlx, "QueryLoadTopPlayers", query);
	}
	else
	{
		formatex(path, 127, "%s/gg-toplevel.txt", file_dir);
	
		new f = fopen(path, "rt");
		new i = 0;
		new level[25], exp[25], exp2[25];
		
		while(!feof(f) && i < TOP+1)
		{
			fgets(f, data, 255);
			parse(data, top_name[i], 31, level, 25,  exp, 25, exp2, 25);
		
			top_level[i] = str_to_num(level);
			top_exp[i] = str_to_num(exp);
			top_exp2[i] = str_to_num(exp2);
			i++;
		}
		fclose(f);
	}
}

public save_top()
{
	if(get_pcvar_num(g_save) == 1)
		return PLUGIN_HANDLED;
	
	formatex(path, 127, "%s/gg-toplevel.txt", file_dir);
	
	if(file_exists(path))
		delete_file(path);
	
	new f = fopen(path, "at");
	
	for(new i = 0; i < TOP; i++)
	{
		formatex(data, 255, "^"%s^" ^"%d^" ^"%d^" ^"%d^"^n", top_name[i], top_level[i], top_exp[i], top_exp2[i]);
		fputs(f, data);
	}
	fclose(f);

	return PLUGIN_CONTINUE;
}

public update_top(id, level, exp, exp2) 
{
	static name[32]; get_user_name(id, name, charsmax(name) - 1);
	
	if(WhiteListed(name))
		return;
	
	for(new i = 0; i < TOP; i++)
	{
		if(level > top_level[i] || level == top_level[i] && exp > top_exp[i])
		{
			new pos = i;	
			while(!equali(top_name[pos], name) && pos < TOP)
				pos++;
			
			for(new j = pos; j > i; j--)
			{
				formatex(top_name[j], 31, top_name[j-1]);
				top_level[j] = top_level[j-1];
				top_exp[j] = top_exp[j-1];
			}
			
			formatex(top_name[i], charsmax(name) - 1, name);
			
			top_level[i] = level;
			top_exp[i] = exp;
			top_exp2[i] = exp2;
			
			save_top();
			break;
		}
		else if(equali(top_name[i], name)) 
			break;
	}
}

public show_top(id)
{	
	static buffer[2368], name[131], len;
	
	len = format(buffer[len], 2367-len,"<meta charset=UTF-8><style>body{background:#112233;font-family:Arial}th{background:#558866;color:#FFF;padding:10px 2px;text-align:left}td{padding:4px 3px}table{background:#EEEECC;font-size:12px;font-family:Arial}h2,h3{color:#FFF;font-family:Verdana}#c{background:#E2E2BC}img{height:10px;background:#09F;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#FFF;font-size:20px}</style>");
	len += format(buffer[len], 2367-len, "<body><table width=100%% border=0 align=center cellpadding=0 cellspacing=1>");	
	len += format(buffer[len], 2367-len, "<body><tr><th>%s<th>%s<th>%s<th>%s<th>%s<th>%s</tr>", "#", "Name", "Level", "Exp", "Assassin Grade", "Human Grade");	
	
	for(new i = 0; i < TOP; i++)
	{		
		name = top_name[i];
		
		if(top_level[i] == 0) 
		{
			len += format(buffer[len], 2367-len, "<tr><td>%d.<td>%s<td>%s<td>%s/%s<td>%s</tr>", (i+1), "-", "-", "-", "-", "-", "-");
		}
		else
		{
			while(containi(name, "<") != -1) replace(name, 129, "<", "&lt;");
			while(containi(name, ">") != -1) replace(name, 129, ">", "&gt;");
			
			len += format(buffer[len], 2367-len, "<tr><td>%d<td>%s<td>%d<td>%d/%d<td>%s<td>%s</tr>", (i+1), name, top_level[i], top_exp[i], top_exp2[i], (top_level[i] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][1] : Grades[top_level[i]][1]), (top_level[i] >= sizeof(Grades) ? Grades[sizeof(Grades) - 1][2] : Grades[top_level[i]][2]));
		}
	}
	
	static strin[20]; format(strin,33, "[Geek~Gamers] Top 15 Levels");
	show_motd(id, buffer, strin);
}

///** ----------------------------------------- [ SQL ] ------------------------------------------------ **///

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
		g_level[id] = 1;
		g_exp[id] = 0;
		g_exp2[id] = 5;
		
		data_loaded[id] = true;
		
		return SQL_FreeHandle(query);
	}
	
	new i_ColLevel = SQL_FieldNameToNum(query, "Level");
	new i_ColExp = SQL_FieldNameToNum(query, "EXP");
	new i_ColExp2 = SQL_FieldNameToNum(query, "EXP2");
	
	g_level[id] = SQL_ReadResult(query, i_ColLevel);
	g_exp[id] = SQL_ReadResult(query, i_ColExp);
	g_exp2[id] = SQL_ReadResult(query, i_ColExp2);
	
	data_loaded[id] = true;
	
	return SQL_FreeHandle(query);
}

public QueryLoadTopPlayers(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate)
	{
		return SQL_Error(query, error, errcode, failstate);
	}
	
	if(SQL_AffectedRows(query) < 1)
		return SQL_FreeHandle(query);
	
	new i_ColPlayer = SQL_FieldNameToNum(query, "Player");
	new i_ColLevel = SQL_FieldNameToNum(query, "Level");
	new i_ColExp = SQL_FieldNameToNum(query, "EXP");
	new i_ColExp2 = SQL_FieldNameToNum(query, "EXP2");
	
	new i = 0;
	while(SQL_MoreResults(query) && i < TOP+1)
	{
		static name[64];
		SQL_ReadResult(query, i_ColPlayer, name, sizeof(name));
		
		if(!WhiteListed(name))
		{
			formatex(top_name[i], charsmax(name) - 1, name);
			top_level[i] = SQL_ReadResult(query, i_ColLevel);
			top_exp[i] = SQL_ReadResult(query, i_ColExp);
			top_exp2[i] = SQL_ReadResult(query, i_ColExp2);
			
			i++;
		}
		
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
		set_fail_state("[GG][Level] [SQLX] Could not connect to database!");
	}
	else if (failstate == TQUERY_QUERY_FAILED) 
	{
		set_fail_state("[GG][Level] [SQLX] Query failed!");
	}
	
	log_amx("[GG][Level] [SQLX] Error '%s' with '%s'", error, errornum);
	log_amx("[GG][Level] [SQLX] %s", qstring);
	
	return SQL_FreeHandle(query);
}

///** ----------------------------------------- [ Natives ] ------------------------------------------------ **///

public native_level(id)
{
	return g_level[id];
}

public native_exp(id)
{
	return g_exp[id];
}

public native_exp2(id)
{
	return g_exp2[id];
}

public native_class_furien(id)
{
	g_class[id] = "White Assassin";
}

public native_class_furien2(id)
{
	g_class[id] = "Red Assassin";
}

public native_class_furien3(id)
{
	g_class[id] = "Black Assassin";
}

public native_class_furien_assassin(id)
{
	g_class[id] = "Assassin";
}

public native_class_furien_ghost(id)
{
	g_class[id] = "Ghost";
}

public native_class_human(id)
{
	g_class[id] = "Green Human";
}

public native_class_human2(id)
{
	g_class[id] = "White Human";
}

public native_class_human3(id)
{
	g_class[id] = "Black Human";
}

public native_class_human_survivor(id)
{
	g_class[id] = "Survivor";
}

public native_class_human_sniper(id)
{
	g_class[id] = "Sniper";
}

///** ----------------------------------------- [ Steam Tag ] ------------------------------------------------ **///

stock bool:is_user_steam(id)
{
        static dp_pointer;
        if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
        {
            server_cmd("dp_clientinfo %d", id);
            server_exec();
            return (get_pcvar_num(dp_pointer) == 2) ? true : false;
        }
        return false;
}

///** ----------------------------------------- [ Chat Color ] ------------------------------------------------ **///

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

///** ----------------------------------------- [ Backup ] ------------------------------------------------ **///

public Backup()
{
	if(!get_pcvar_num(g_backup) || get_pcvar_num(g_save) == 1)
		return;

	new iYear, iMonth, iDay;
	date(iYear, iMonth, iDay);

	new szFile1[ 300 ], szFile2[ 300 ];

	formatex( szFile1 , charsmax( szFile1 ), "%s/gg-level.txt", file_dir );
	formatex( szFile2 , charsmax( szFile2 ), "%s/gg-level-%d-%d-%d.txt", backup_file_dir, iYear, iMonth, iDay);

	if(file_exists(szFile1) && !file_exists(szFile2))
	{
		fcopy(szFile1, szFile2);
	}

	new szFile3[ 300 ], szFile4[ 300 ];

	formatex( szFile3, charsmax( szFile3 ), "%s/gg-toplevel.txt", file_dir );
	formatex( szFile4, charsmax( szFile4 ), "%s/gg-toplevel-%d-%d-%d.txt", backup_file_dir, iYear, iMonth, iDay);

	if(file_exists(szFile3) && !file_exists(szFile4))
	{
		fcopy(szFile3, szFile4);
	}
}

///** ----------------------------------------- [ Copy File ] ------------------------------------------------ **///

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

///** ----------------------------------------- [ Plugin By ~DarkSiDeRs~ ] ------------------------------------------------ **///
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
