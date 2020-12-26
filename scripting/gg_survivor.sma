#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <cs_player_models_api>

#pragma compress 1

#pragma tabsize 0

native bool: no_last_survivor(id);

new bool: cmd_used;
new bool: last_survivor[33];
new szName[33];

native class_human_survivor(id);

/*------------------------- plugin_init ----------------------------*/

public plugin_init( )
{
	register_plugin( "[GG] Last Survivor", "1.0", "~DarkSiDeRs~" );

	register_event("HLTV", "Round_Start", "a", "1=0", "2=0");
	RegisterHam(Ham_Killed, "player", "EventDeath");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

/*----------------------- plugin_precache --------------------------*/

public plugin_precache( ) 
{
	precache_model("models/player/gg_antifurien_srvivor/gg_antifurien_srvivor.mdl");
	precache_model("models/player/gg_antifurien_srvivor/gg_antifurien_srvivorT.mdl");

	return PLUGIN_CONTINUE;
}

/*------------------------ Round Start ----------------------------*/

public Round_Start()
{
	cmd_used = false;
}

/*------------------------ Spawn Player ----------------------------*/

public Spawn(id)
{
	last_survivor[id] = false;
}

/*------------------------- Last Survivor ----------------------------*/

public EventDeath(const victim, const attacker)
{
	if( no_last_survivor(victim) )
		return;

	new Players[32], iNum;
	get_players(Players, iNum, "ae", "CT");

	if(iNum == 1 && !cmd_used)
	{
		for(new i = 0; i < iNum; i++)
		{
			new tempid = Players[i];
			get_user_name(tempid, szName, 32);

			if(get_user_health(tempid) < 255) set_user_health(tempid, 255);
			set_user_gravity(tempid, 0.43);
			cs_set_player_model(tempid, "gg_antifurien_srvivor");
			class_human_survivor(tempid);
			last_survivor[tempid] = true;
			cmd_used = true;
			ChatColor( 0, "!t[GG][ Survivor ]!g %s !nis the Last Survivor with!t %d HP !nand !tLow Gravity !t!", szName, get_user_health(tempid) );
		}
	}
}

public client_PreThink(id)
{
	if(last_survivor[id])
	{
		if( (get_entity_flags(id) & FL_ONGROUND) && !(get_user_button(id) & IN_USE) )
		{
			set_user_gravity(id, 0.43);
		}
	}
}

/*-------------------------- ChatColor -----------------------------*/

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
