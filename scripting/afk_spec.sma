#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "[GG] AFK to Spectator"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

new bool: transfered[33];
new Float: player_origin[33][3]; 
new killed_times[33];
new cvar_killed_times;

native csdm_mod(id);
native replace_disc_player(id);

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHam(Ham_Spawn, "player", "e_Spawn", 1);
	RegisterHam(Ham_Killed, "player", "EventDeath");

	cvar_killed_times = register_cvar("amx_afk_rounds_to_spec", "3");
}

public client_putinserver(id)
{
	killed_times[id] = 0;
	transfered[id] = false;

	//set_task(2.0, "show_msg", id, _, _, "b");
}
/*
public show_msg(id)
{
	if(!is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		if(transfered[id])
		{
			client_print(id, print_center, "You were transfered to SPECTATOR for being AFK! Press <M> To Join the Game!");
		}
	}
}
*/
public e_Spawn(id)
{
	if(csdm_mod(id))
		return;

	remove_task(id)
	if(is_user_alive(id))
	{
		set_task(4.0, "get_spawn", id);
	}
}

public get_spawn(id)
{
	pev(id, pev_origin, player_origin[id]);
	set_task(11.0, "check_afk", id);
}

public check_afk(id)
{
	if(!is_user_alive(id))
		return;

	new name[33];
	get_user_name(id, name, 32);

	if(same_origin(id))
	{
		if(killed_times[id] >= get_pcvar_num(cvar_killed_times))
		{
			replace_disc_player(id);
			user_silentkill(id);
			transfered[id] = true;
		}
		else
		{
			replace_disc_player(id);
			user_silentkill(id);
			ChatColor(0, "!g[GG]!t %s !nwas killed for being !gAFK!n.", name);
			transfered[id] = false;
		}
	}
	else
	{
		killed_times[id] = 0;
		transfered[id] = false;
	}
}

public EventDeath(const victim, const attacker)
{
	new name[33];
	get_user_name(victim, name, 32);

	if(same_origin(victim))
	{
		if(killed_times[victim] >= get_pcvar_num(cvar_killed_times))
		{
			cs_set_user_team(victim, CS_TEAM_SPECTATOR);
			ChatColor(0, "!g[GG]!t %s !nwas transfered to SPECTATOR for being !gAFK !nfor so long.", name);
			transfered[victim] = true;
		}
		else
		{
			killed_times[victim] ++;
			transfered[victim] = false;
		}
	}
	else
	{
		killed_times[victim] = 0;
		transfered[victim] = false;
	}
}

public same_origin(id)
{
	new Float:origin[3];
	pev(id, pev_origin, origin);

	for(new i = 0; i < 3; i++)
	{
		if(origin[i] != player_origin[id][i])
			return 0;
	}

	return 1;
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
    
	replace_all(msg, 190, "!g", "^x04");
	replace_all(msg, 190, "!n", "^x01");
	replace_all(msg, 190, "!t", "^x03");
    
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