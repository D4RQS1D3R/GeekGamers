#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <cs_player_models_api>
#include <rog>

#pragma compress 1

#define PLUGIN "[GG] Furien Game Mods"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new bool: randomknife;
new bool: dont_show_weapons_menu;
new bool: dont_show_knife_menu;
new bool: no_last_survivor;
new bool: mod_started;
new bool: furien_visible;

new nmod[33][34];

new next_mod;
new round;
new startmod;
new ModActuel;
new playersremaining;
new gHudSyncMod;

new iPlayers[32], iNum;
new TPlayers[32], TNum;
new CTPlayers[32], CTNum;

native cs_set_user_thermalgoggle(id);

native gg_set_user_gatling(id);
native gg_set_user_k1ases(id);
native gg_set_user_m4a1darkknight(id);
native gg_set_user_m3bd(id);
native gg_set_user_crossbow(id);

native gg_set_user_ak47paladin(id);
native gg_set_user_oicw(id);

native gg_set_user_thanatos3(id);
native gg_set_user_ethereal(id);

native gg_set_user_at4(id);

native gg_set_user_dualberetta(id);
native gg_set_user_m79(id);
native gg_set_user_janus1(id);

native gg_set_user_buffawp(id);
native gg_set_user_plasmagun(id);
native gg_set_user_plasmagrenade(id);

native gg_set_user_compoundbow(id, ammo)

native bool: HC_GameMods(id);

native class_furien_assassin(id);
native class_human_sniper(id);
native class_furien_ghost(id);

new const PLASMAVModel[66] = "models/[GeekGamers]/Knives/v_plasma_sword.mdl";
new const PLASMAPModel[66] = "models/[GeekGamers]/Knives/p_plasma_sword.mdl";

new const GHOSTVModel[66] = "models/[GeekGamers]/Knives/v_ghost.mdl";

new Float:g_flMaxSpeed = 250.0
new Float:g_flSideSpeed = 200.0
new g_szSpeedCommand[128]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
    ROGInitialize(250.0);
    ROGDumpOriginData();
	
	register_event("HLTV", "Round_Start", "a", "1=0", "2=0");
	register_event("SendAudio", "Round_End", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");
	register_event("TextMsg", "Restart_Round", "a", "2=#Game_will_restart_in");
	register_event("CurWeapon", "CurentWeapon", "be", "1=1");

	register_logevent("Game_Start", 2, "1=Round_Start");

	register_forward(FM_ClientKill, "fw_ClientKill");

	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage");
	RegisterHam(Ham_Killed, "player", "EventDeath");

	startmod = register_cvar("amx_start_mods", "8");
	playersremaining = register_cvar("amx_players_remaining", "6");

	set_task(0.2, "ShowHud", _, _, _, "b");
	gHudSyncMod = CreateHudSyncObj( );
	
	register_clcmd("nextmod", "Next_Mod_Menu");
	register_clcmd("say /nextmod", "Next_Mod_Menu");
	register_clcmd("say /next", "Next_Mod_Menu");

	formatex(g_szSpeedCommand, charsmax(g_szSpeedCommand), 
			";cl_forwardspeed %.1f;cl_sidespeed %.1f;cl_backspeed %.1f",
							g_flMaxSpeed, g_flSideSpeed, g_flMaxSpeed);
}

public plugin_natives()
{
	register_native("modstarted", "native_mod_started", 1);
	register_native("dont_show_weaponsmenu", "native_dont_show_weapons_menu", 1);
	register_native("dont_show_knifemenu", "native_dont_show_knife_menu", 1);
	register_native("random_knife", "native_random_knife", 1);
	register_native("no_last_survivor", "native_no_last_survivor", 1);
	register_native("replace_disc_player", "client_disconnected", 1);
	register_native("Become_Sniper", "native_Become_Sniper", 1);
	register_native("Become_Assassin", "native_Become_Assassin", 1);
	register_native("Become_Ghost", "native_Become_Ghost", 1);

	/* Game Mods */
	register_native("normal_mod", "native_normal_mod", 1);
	register_native("assassin_mod", "native_assassin_mod", 1);
	register_native("sniper_mod", "native_sniper_mod", 1);
	register_native("avs_mod", "native_avs_mod", 1);
	register_native("csdm_mod", "native_csdm_mod", 1);
	register_native("plasma_mod", "native_plasma_mod", 1);
	register_native("random_mod", "native_random_mod", 1);
	register_native("nightmare_mod", "native_nightmare_mod", 1);
	register_native("ghost_mod", "native_ghost_mod", 1);
}

public plugin_precache()
{
	precache_sound("[GeekGamers]/Game_Mods/Assassin_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/Sniper_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/AvS_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/DeathMatch_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/Random_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/NightMare_Round.mp3");
	precache_sound("[GeekGamers]/Game_Mods/Ghost_Round.mp3");

	// ** Christmas **
	/*
	precache_sound("[GeekGamers]/Game_Mods/Xmas_Music.mp3");
	precache_sound("[GeekGamers]/Game_Mods/Xmas_Music2.mp3");
	*/
	precache_model(PLASMAVModel);
	precache_model(PLASMAPModel);
	precache_model(GHOSTVModel);

        precache_model("models/player/gg_furien_assassin/gg_furien_assassin.mdl");
        precache_model("models/player/gg_antifurien_sniper/gg_antifurien_sniper.mdl");
        precache_model("models/player/gg_furien_ghost/gg_furien_ghost.mdl");
}

public client_disconnected(id)
{
	if(ModActuel == 1 || ModActuel == 8)
	{
		if( cs_get_user_team(id) == CS_TEAM_T )
		{
			get_players (iPlayers, iNum, "a");
			for ( new i = 0 ; i < iNum ; i++ )
			{
				new tempid = iPlayers[i]
				cs_set_user_team(tempid, CS_TEAM_CT);
			}

			if( iNum )
			{
				new iRandomIndex = random( iNum );
				new RandomT = iPlayers[ iRandomIndex ];

				cs_set_user_team(RandomT, CS_TEAM_T);
				ExecuteHamB(Ham_CS_RoundRespawn, RandomT);
				force_cmd(RandomT, "knife");
			}
		}
	}
	if(ModActuel == 2)
	{
		if( cs_get_user_team(id) == CS_TEAM_CT )
		{
			get_players (iPlayers, iNum, "a");
			for ( new i = 0 ; i < iNum ; i++ )
			{
				new tempid = iPlayers[i]
				cs_set_user_team(tempid, CS_TEAM_T);
			}

			if( iNum )
			{
				new iRandomIndex = random( iNum );
				new RandomCT = iPlayers[ iRandomIndex ];

				cs_set_user_team(RandomCT, CS_TEAM_CT);
				ExecuteHamB(Ham_CS_RoundRespawn, RandomCT);
			}
		}
	}
}

public client_putinserver(id)
{
	set_task(2.0, "Play_RoundSounds", id);
}

public Start_Sound()
{
	get_players(iPlayers, iNum, "c");
	for(new i = 0; i < iNum; i++)
	{
		new Players = iPlayers [ i ];
		Play_RoundSounds(Players)
	}
}

public Play_RoundSounds(id)
{
	if(ModActuel == 1) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Assassin_Round.mp3^"");

	else if(ModActuel == 2) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Sniper_Round.mp3^"");

	else if(ModActuel == 3) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/AvS_Round.mp3^"");

	else if(ModActuel == 4) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/DeathMatch_Round.mp3^"");

	else if(ModActuel == 5) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Random_Round.mp3^"");

	else if(ModActuel == 6) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Random_Round.mp3^"");

	else if(ModActuel == 7) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/NightMare_Round.mp3^"");

	else if(ModActuel == 8) force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Ghost_Round.mp3^"");

	// ** Christmas **
	/*
	else
	{
		switch(random_num(1,2))
		{
			case 1: force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Xmas_Music.mp3^"");
			case 2: force_cmd(id, "mp3 play ^"sound/[GeekGamers]/Game_Mods/Xmas_Music2.mp3^"");
		}
	}
	*/
}

public Game_Start()
{
	Start_Sound();
	remove_godmode();
}

public Restart_Round(id)
{
	ModActuel = 0;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = false;
	randomknife = false;
	furien_visible = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_respawn 0");
	server_cmd("amx_lights l");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("napalm_on 1");
	mod_started = false;
	no_last_survivor = false;
	round = 0;
}

public EventDeath(const victim, const attacker)
{
	if(!is_user_connected(victim))
		return;
	
	if(ModActuel == 8)
	{
		if(cs_get_user_team(victim) == CS_TEAM_T)
			set_user_noclip(victim, 0);
	}
}

public PlayerSpawn(id)
{
	if(!is_user_alive(id))
		return;

	get_players(TPlayers, TNum, "e", "TERRORIST");
	get_players(CTPlayers, CTNum, "e", "CT");
	if( TNum + CTNum < get_pcvar_num(playersremaining) )
		return;

	if(ModActuel == 1)
	{
		if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_player_model(id, "gg_furien_assassin");
			class_furien_assassin(id);
			set_user_health(id, 1000 * CTNum);
		}
	}
	else
	if(ModActuel == 2)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			set_user_health(id, 1000);
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_player_model(id, "gg_antifurien_sniper");
			class_human_sniper(id);
			set_user_health(id, 800 * TNum);
			set_task(0.3, "GiveAWP", id);
		}
	}
	else
	if(ModActuel == 3)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_player_model(id, "gg_furien_assassin");
			class_furien_assassin(id);
			set_user_health(id, 1000);
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_player_model(id, "gg_antifurien_sniper");
			class_human_sniper(id);
			set_user_health(id, 150);
			set_task(0.3, "GiveAWP", id);
		}
	}
	else
	if(ModActuel == 4)
	{
		new Float:Origin[3];
		ROGGetOrigin(Origin);
		engfunc(EngFunc_SetOrigin, id, Origin);
	}
	else
	if(ModActuel == 5)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			strip_user_weapons(id);
			give_item(id, "weapon_knife")
			set_user_health(id, get_user_health(id) + 50);
			set_task(0.3, "Give_PlasmaGrenade", id);
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			strip_user_weapons(id);
			give_item(id, "weapon_knife")
			set_task(0.3, "Give_Plasma", id);
		}
	}
	else
	if(ModActuel == 6)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			set_user_health(id, get_user_health(id) + 50);
			switch(random_num(1,3))
			{
				case 1: set_task(0.3, "Give_Compound_Bow", id);
				case 2..3: return;
			}
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			set_user_health(id, 255);
			set_task(0.3, "Give_Random_Weapons", id);
		}
	}
	else
	if(ModActuel == 7)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_user_nvg(id, 1);
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			force_cmd(id, "impulse 100");
			cs_set_user_thermalgoggle(id);
		}
	}
	else
	if(ModActuel == 8)
	{
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_user_nvg(id, 1);
			gg_set_user_laser(id);
		}
		else
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_player_model(id, "gg_furien_ghost");
			class_furien_ghost(id);
			set_user_health(id, 400 * CTNum);
			reset_speed(id);
			set_user_noclip(id, 1);
			force_cmd(id, "knife");
			set_task(0.5, "knife_only", id);
		}
	}
}

public Round_Start(id)
{
	get_players(TPlayers, TNum, "e", "TERRORIST");
	get_players(CTPlayers, CTNum, "e", "CT");
	if( TNum + CTNum < get_pcvar_num(playersremaining) )
	{
		ChatColor(0, "!g[GG][MODS]!t %d/%d !nPlayers remaining To Start Mods.", TNum + CTNum, get_pcvar_num(playersremaining) );
		server_cmd("amx_lights l");
		server_cmd("amx_weather_type 0");
		server_cmd("amx_weather_storm 0");
	}
	else ChatColor(0, "!g[GG][MODS]!t %d/%d !nRound To Win Before Starting A Mod.", round, get_pcvar_num(startmod) );

	if(ModActuel == 0)
	{
		server_cmd("amx_lights l");
		server_cmd("amx_weather_type 0");
		server_cmd("amx_weather_storm 0");
		server_cmd("napalm_on 1");
		dont_show_weapons_menu = false;
		dont_show_knife_menu = false;
		randomknife = false;
		mod_started = false;
		furien_visible = false;
		no_last_survivor = false;
	}
}

public Next_Mod_Menu(id)
{
	if(! (get_user_flags(id) & ADMIN_LEVEL_C) ) return PLUGIN_HANDLED;

	switch( next_mod )
	{
		case 0: nmod[id] = "Randomly"
		case 1: nmod[id] = "Assassin Mod"
		case 3: nmod[id] = "Sniper Mod"
		case 5: nmod[id] = "Assassin VS Sniper Mod"
		case 7: nmod[id] = "DeathMatch Mod"
		case 9: nmod[id] = "Plasma Mod"
		case 10: nmod[id] = "Random Mod"
		case 12: nmod[id] = "NightMare Mod"
		case 13: nmod[id] = "Ghost Mod"
	}

	new temp[101];
	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rNext Mod:^nNext Mod: \y%s", nmod[id] );
	new menu = menu_create(temp, "Next_Mod_Menu_Handler");

	if( next_mod == 1 )
		menu_additem(menu, "\yAssassin Mod", "1", 0);
	else menu_additem(menu, "Assassin Mod", "1", 0);

	if( next_mod == 3 )
		menu_additem(menu, "\ySniper Mod", "2", 0);
	else menu_additem(menu, "Sniper Mod", "2", 0);

	if( next_mod == 5 )
		menu_additem(menu, "\yAssassin VS Sniper Mod", "3", 0);
	else menu_additem(menu, "Assassin VS Sniper Mod", "3", 0);

	if( next_mod == 7 )
		menu_additem(menu, "\yDeathMatch Mod", "4", 0);
	else menu_additem(menu, "DeathMatch Mod", "4", 0);

	if( next_mod == 9 )
		menu_additem(menu, "\yPlasma Mod", "5", 0);
	else menu_additem(menu, "Plasma Mod", "5", 0);

	if( next_mod == 10 )
		menu_additem(menu, "\yRandom Mod", "6", 0);
	else menu_additem(menu, "Random Mod", "6", 0);

	if( next_mod == 12 )
		menu_additem(menu, "\yNightMare Mod", "7", 0);
	else menu_additem(menu, "NightMare Mod", "7", 0);

	if( next_mod == 13 )
		menu_additem(menu, "\yGhost Mod^n", "8", 0);
	else menu_additem(menu, "Ghost Mod^n", "8", 0);

	if( next_mod == 15 )
		menu_additem(menu, "\yRandomly", "9", 0);
	else menu_additem(menu, "\rRandomly", "9", 0);

	menu_addblank(menu, 0); 
	menu_additem(menu, "Exit", "MENU_EXIT"); 

	menu_setprop(menu, MPROP_PERPAGE, 0);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public Next_Mod_Menu_Handler(id, menu, item)
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
		case 0: next_mod = 1;
		case 1: next_mod = 3;
		case 2: next_mod = 5;
		case 3: next_mod = 7;
		case 4: next_mod = 9;
		case 5: next_mod = 10;
		case 6: next_mod = 12;
		case 7: next_mod = 13;
		case 8: next_mod = 15;
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Round_End()
{
	set_godmode();

	get_players(TPlayers, TNum, "e", "TERRORIST");
	get_players(CTPlayers, CTNum, "e", "CT");
	if( TNum + CTNum < get_pcvar_num(playersremaining) )
	{
		ModActuel = 0;
		dont_show_weapons_menu = false;
		dont_show_knife_menu = false;
		randomknife = false;
		//server_cmd("sv_autoteambalance 1");
		server_cmd("amx_respawn 0");
		server_cmd("amx_lights l");
		server_cmd("amx_weather_type 0");
		server_cmd("amx_weather_storm 0");
		server_cmd("napalm_on 1");
		mod_started = false;
		furien_visible = false;
		no_last_survivor = false;

		return PLUGIN_HANDLED;
	}

	if(ModActuel == 8)
	{
		get_players(iPlayers, iNum);
		for( new i = 0 ; i < iNum ; i++ )
		{
			new tempid = iPlayers[i];
			set_user_noclip(tempid, 0);
		}
	}

	round ++;

	if( round >= get_pcvar_num(startmod) )
	{
		mod_started = true;
		round = 0;

		new select_nextmod;

		if( next_mod == 0 )
		{
			select_nextmod = random_num(1, 15)
		}
		else 
		{
			select_nextmod = next_mod
		}

		switch(select_nextmod)
		{
			case 1..2:
			{
				set_task(2.5, "Start_Assassin_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tAssassin Mod !g!");
			}
			case 3..4:
			{
				set_task(2.5, "Start_Sniper_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tSniper Mod !g!");
			}
			case 5..6:
			{
				set_task(2.5, "Start_AvS_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tAssassin Vs Sniper Mod !g!");
			}
			case 7..8:
			{
				set_task(2.5, "Start_DeathMatch_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tDeathMatch Mod !g!");
			}
			case 9:
			{
				set_task(2.5, "Start_Plasma_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tPlasma Mod !g!");
			}
			case 10..11:
			{
				set_task(2.5, "Start_Random_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tRandom Mod !g!");
			}
			case 12:
			{
				set_task(2.5, "Start_NightMare_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tNightMare Mod !g!");
			}
			case 13..14:
			{
				set_task(2.5, "Start_Ghost_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tGhost Mod !g!");
			}
			case 15:
			{
				set_task(2.5, "Start_Plasma_mod");
				ChatColor(0, "!g[GG][MODS]!n Next Mod is : !tPlasma Mod !g!");
			}
		}
	}
	else
	{
		ModActuel = 0;
		dont_show_weapons_menu = false;
		dont_show_knife_menu = false;
		randomknife = false;
		//server_cmd("sv_autoteambalance 1");
		server_cmd("amx_respawn 0");
		server_cmd("amx_lights l");
		server_cmd("amx_weather_type 0");
		server_cmd("amx_weather_storm 0");
		server_cmd("napalm_on 1");
		mod_started = false;
		furien_visible = false;
		no_last_survivor = false;
	}

	return PLUGIN_CONTINUE;
}

public Start_Assassin_mod()
{
	round = 0;
	ModActuel = 1;
	next_mod = 0;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights g");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_CT);
	}

	if( iNum )
	{
		new iRandomIndex = random( iNum );
		new RandomT = iPlayers[ iRandomIndex ];

		if( cs_get_user_team(RandomT) == CS_TEAM_SPECTATOR || cs_get_user_team(RandomT) == CS_TEAM_UNASSIGNED || is_user_bot(RandomT) )
		{
			Start_Assassin_mod();
			return;
		}
		
		cs_set_user_team(RandomT, CS_TEAM_T);
	}
}

public Start_Sniper_mod()
{
	round = 0;
	ModActuel = 2;
	next_mod = 0;
	dont_show_weapons_menu = true;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = true;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights i");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_T);
	}

	if( iNum )
	{
		new iRandomIndex = random( iNum );
		new RandomCT = iPlayers[ iRandomIndex ];

		if( cs_get_user_team(RandomCT) == CS_TEAM_SPECTATOR || cs_get_user_team(RandomCT) == CS_TEAM_UNASSIGNED || is_user_bot(RandomCT) )
		{
			Start_Sniper_mod();
			return;
		}

		cs_set_user_team(RandomCT, CS_TEAM_CT);
	}
}

public Start_AvS_mod()
{
	round = 0;
	ModActuel = 3;
	next_mod = 0;
	dont_show_weapons_menu = true;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = false;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_lights i");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");
}

public Start_DeathMatch_mod()
{
	round = 0;
	ModActuel = 4;
	next_mod = 0;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = false;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_lights l");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 1");
	server_cmd("napalm_on 1");
}

public Start_Plasma_mod()
{
	round = 0;
	ModActuel = 5;
	next_mod = 0;
	dont_show_weapons_menu = true;
	dont_show_knife_menu = true;
	randomknife = false;
	mod_started = true;
	furien_visible = false;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_lights l");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 0");
}

public Start_Random_mod()
{
	round = 0;
	ModActuel = 6;
	next_mod = 0;
	dont_show_weapons_menu = true;
	dont_show_knife_menu = false;
	randomknife = true;
	mod_started = true;
	furien_visible = false;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_lights i");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");
}

public Start_NightMare_mod()
{
	round = 0;
	ModActuel = 7;
	next_mod = 0;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = false;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 1");
	server_cmd("amx_lights b");
	server_cmd("amx_weather_type 1");
	server_cmd("amx_weather_storm 70");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");
}

public Start_Ghost_mod()
{
	round = 0;
	ModActuel = 8;
	next_mod = 0;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = true;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = true;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights c");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_CT);
	}

	if( iNum )
	{
		new iRandomIndex = random( iNum );
		new RandomT = iPlayers[ iRandomIndex ];

		if( cs_get_user_team(RandomT) == CS_TEAM_SPECTATOR || cs_get_user_team(RandomT) == CS_TEAM_UNASSIGNED || is_user_bot(RandomT) )
		{
			Start_Ghost_mod();
			return;
		}

		cs_set_user_team(RandomT, CS_TEAM_T);
	}
}

public GiveAWP(id)
{
	gg_set_user_buffawp(id);
}

public Give_Compound_Bow(id)
{
	gg_set_user_compoundbow(id, random_num(5,30));
}

public Give_Plasma(id)
{
	Give_PlasmaGrenade(id);
	gg_set_user_plasmagun(id);
}

public Give_PlasmaGrenade(id)
{
	if(!is_user_bot(id))
		gg_set_user_plasmagrenade(id);
}

public Give_Random_Weapons(id)
{
	switch( random_num(1,21) )
	{
		case 1..2: gg_set_user_gatling(id);
		case 3..4: gg_set_user_k1ases(id);
		case 5..6: gg_set_user_m4a1darkknight(id);
		case 7..8: gg_set_user_m3bd(id);
		case 9..10: gg_set_user_crossbow(id);
		case 11..12: gg_set_user_ak47paladin(id);
		case 13..14: gg_set_user_oicw(id);
		case 15..16: gg_set_user_thanatos3(id);
		case 17..18: gg_set_user_ethereal(id);
		case 19: gg_set_user_at4(id);
		case 20..21: gg_set_user_plasmagun(id);
	}
	Give_Random_Secondary_Weapons(id);
}


public Give_Random_Secondary_Weapons(id)
{
	switch( random_num(1,3) )
	{
		case 1: gg_set_user_dualberetta(id);
		case 2: gg_set_user_m79(id);
		case 3: gg_set_user_janus1(id);
	}
}

public CurentWeapon(id)
{
	if( ModActuel == 5 && get_user_weapon(id) == CSW_KNIFE )
	{
		set_pev(id, pev_viewmodel2, PLASMAVModel);
		set_pev(id, pev_weaponmodel2, PLASMAPModel);
	}

	if( ModActuel == 8 && get_user_weapon(id) == CSW_KNIFE && cs_get_user_team(id) == CS_TEAM_T )
	{
		set_pev(id, pev_viewmodel2, GHOSTVModel);
	}
}

public Player_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(iInflictor == iAttacker && ModActuel == 5 && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
	{
		SetHamParamFloat(4, fDamage * 1.538461538461538);
	}

	if(iInflictor == iAttacker && ModActuel == 8 && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
	{
		SetHamParamFloat(4, fDamage * 1.538461538461538);
	}
}

public client_PreThink(id)
{
	if( !furien_visible )
		return PLUGIN_CONTINUE;

	new iPlayers[32], iNum;
	get_players(iPlayers, iNum, "ae", "TERRORIST");
	for(new i; i < iNum ; i++)
	{
		new id = iPlayers[i];
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	}
	
	return PLUGIN_CONTINUE;
}

public set_godmode()
{
	get_players (iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];
		set_user_godmode(tempid, 1);
	}
}

public remove_godmode()
{
	get_players (iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];
		set_user_godmode(tempid, 0);
	}
}

public gg_set_user_laser(id)
{
	cs_set_user_money(id, cs_get_user_money(id) + 7000);
	force_cmd(id, "shop;menuselect 9;menuselect 3");
	CloseMenu(id);
	force_cmd(id, "weapons");
}

public CloseMenu(id)
{
	if(is_user_connected(id))
	{
		show_menu(id, 0, "^n", 1)
	}
}

public reset_speed(id)
{
	g_flMaxSpeed = floatclamp(300.0, 100.0, 2000.0)
	client_cmd(id, g_szSpeedCommand)
	set_pev(id, pev_maxspeed, g_flMaxSpeed)
}

public knife_only(id)
{
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
}

public RespawnAll()
{
	new iPlayers[ 32 ], iNum, i, players;

	get_players( iPlayers, iNum );
	for( i = 0; i < iNum; i++ )
	{
		players = iPlayers[ i ];

		if(cs_get_user_team(players) == CS_TEAM_UNASSIGNED || cs_get_user_team(players) == CS_TEAM_SPECTATOR)
			continue;

		spawn_func(players);
	}
}

public spawn_func(id)
{
	ExecuteHamB(Ham_CS_RoundRespawn, id);

	if(cs_get_user_team(id) == CS_TEAM_CT)
		client_cmd(id, "weapons");
	else if(cs_get_user_team(id) == CS_TEAM_T)
		client_cmd(id, "knife");
}

public client_PostThink(id)
{
	if(ModActuel == 8)
	{
		if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
		{
			reset_speed(id);
		}
	}
}

public ShowHud()
{
	get_players(TPlayers, TNum, "ae", "TERRORIST");
	get_players(CTPlayers, CTNum, "ae", "CT");

	get_players(iPlayers, iNum, "c");
	for( new i; i < iNum; i++ )
	{
		new id = iPlayers[i];

		if(!HC_GameMods(id))
			continue;

		if(ModActuel == 0)
		{
			set_hudmessage( 0, 255, 0, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Normal [%d/%d]^nFuriens: %d | Humans: %d", round, get_pcvar_num(startmod), TNum, CTNum );
		}
		else
		if(ModActuel == 1)
		{
			set_hudmessage( 255, 0, 0, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Assassin^nAssassins: %d | Humans: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 2)
		{
			set_hudmessage( 0, 80, 200, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Sniper^nFuriens: %d | Snipers: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 3)
		{
			set_hudmessage( 235, 10, 227, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Assassin Vs Sniper^nAssassins: %d | Snipers: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 4)
		{
			set_hudmessage( 255, 113, 0, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: DeathMatch^nFuriens: %d | Humans: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 5)
		{
			set_hudmessage( 0, 255, 0, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Plasma^nFuriens: %d | Humans: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 6)
		{
			set_hudmessage( random_num(0,255), random_num(0,255), random_num(0,255), 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Random^nFuriens: %d | Humans: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 7)
		{
			set_hudmessage( 102, 28, 26, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: NightMare^nFuriens: %d | Humans: %d", TNum, CTNum );
		}
		else
		if(ModActuel == 8)
		{
			set_hudmessage( 102, 28, 26, 0.6, 0.2, _, _, 4.0, _, _, 3 );
			ShowSyncHudMsg( id, gHudSyncMod, "Current Mod: Ghost Mod^nGhosts: %d | Humans: %d", TNum, CTNum );
		}
	}
}

public fw_ClientKill(id)
{
	if( is_user_alive(id) && ((ModActuel == 1 || ModActuel == 8) && cs_get_user_team(id) == CS_TEAM_T) || (ModActuel == 2 && cs_get_user_team(id) == CS_TEAM_CT) )
	{
		ChatColor(id, "!g[GG] !nHaha Nice Try! !t;)");
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public native_Become_Assassin(id)
{
	ModActuel = 1;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = false;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights g");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_CT);
	}

	cs_set_user_team(id, CS_TEAM_T);
	RespawnAll();
}

public native_Become_Sniper(id)
{
	ModActuel = 2;
	dont_show_weapons_menu = true;
	dont_show_knife_menu = false;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = true;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights i");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_T);
	}

	cs_set_user_team(id, CS_TEAM_CT);
	RespawnAll();
}

public native_Become_Ghost(id)
{
	ModActuel = 8;
	dont_show_weapons_menu = false;
	dont_show_knife_menu = true;
	randomknife = false;
	mod_started = true;
	furien_visible = true;
	no_last_survivor = true;
	//server_cmd("sv_autoteambalance 0");
	server_cmd("amx_lights c");
	server_cmd("amx_weather_type 0");
	server_cmd("amx_weather_storm 0");
	server_cmd("amx_respawn 0");
	server_cmd("napalm_on 1");

	get_players(iPlayers, iNum);
	for( new i = 0 ; i < iNum ; i++ )
	{
		new tempid = iPlayers[i];

		if( cs_get_user_team(tempid) == CS_TEAM_SPECTATOR || cs_get_user_team(tempid) == CS_TEAM_UNASSIGNED )
			continue;

		cs_set_user_team(tempid, CS_TEAM_CT);
	}

	cs_set_user_team(id, CS_TEAM_T);
	RespawnAll();
}

public native_mod_started()
{
	return mod_started;
}

public native_dont_show_weapons_menu()
{
	return dont_show_weapons_menu;
}

public native_dont_show_knife_menu()
{
	return dont_show_knife_menu;
}

public native_no_last_survivor()
{
	return no_last_survivor;
}

public native_random_knife()
{
	return randomknife;
}

public native_normal_mod()
{
	return ModActuel == 0;
}

public native_assassin_mod()
{
	return ModActuel == 1;
}

public native_sniper_mod()
{
	return ModActuel == 2;
}

public native_avs_mod()
{
	return ModActuel == 3;
}

public native_csdm_mod()
{
	return ModActuel == 4;
}

public native_plasma_mod()
{
	return ModActuel == 5;
}

public native_random_mod()
{
	return ModActuel == 6;
}

public native_nightmare_mod()
{
	return ModActuel == 7;
}

public native_ghost_mod()
{
	return ModActuel == 8;
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
	message_end()
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
