#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "[GG] Death Sound"
#define VERSION "1.0"
#define AUTHOR "D4RQS1D3R"

new const furien_death_sounds[][] = {
	"scientist/scream5.wav",
	"scientist/scream08.wav",
	"scientist/scream20.wav",
	"scientist/scream21.wav",
	"scientist/scream23.wav",
	"scientist/scream24.wav"
};

new const antifurien_death_sounds[][] = {
	"[GeekGamers]/Death_Sounds/death1.wav",
	"[GeekGamers]/Death_Sounds/death2.wav",
	"[GeekGamers]/Death_Sounds/death3.wav",
	"[GeekGamers]/Death_Sounds/death4.wav",
	"[GeekGamers]/Death_Sounds/death5.wav"
};

new const suicide_sounds[][] = {
	"scientist/scream1.wav",
	"scientist/scream2.wav"
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("DeathMsg", "event_death", "a");
	RegisterHam(Ham_Killed, "player", "event_death2");
}

public plugin_precache()
{
	for(new i = 0; i < sizeof furien_death_sounds; i++)
		precache_sound(furien_death_sounds[i]);
	
	for(new i = 0; i < sizeof furien_death_sounds; i++)
		precache_sound(antifurien_death_sounds[i]);
	
	for(new i = 0; i < sizeof suicide_sounds; i++)
		precache_sound(suicide_sounds[i]);
}

public event_death()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	new origin[3];
	pev(victim, pev_origin, origin);
	
	new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	engfunc(EngFunc_SetOrigin, entity, origin);
	set_pev(entity, pev_classname, "emitter");
	
	if(cs_get_user_team(killer) == CS_TEAM_CT && cs_get_user_team(victim) == CS_TEAM_T)
		emit_sound(entity, CHAN_AUTO, furien_death_sounds[random_num(0, sizeof furien_death_sounds - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	if(cs_get_user_team(killer) == CS_TEAM_T && cs_get_user_team(victim) == CS_TEAM_CT)
		emit_sound(entity, CHAN_AUTO, antifurien_death_sounds[random_num(0, sizeof antifurien_death_sounds - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	set_task(5.5, "kill_entity", entity+1337);
}

public event_death2(const victim, const attacker)
{
	if(!attacker && get_pdata_int(victim, 76) & DMG_FALL)
	{
		new origin[3];
		pev(victim, pev_origin, origin);
		
		new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
		engfunc(EngFunc_SetOrigin, entity, origin);
		set_pev(entity, pev_classname, "emitter");

		emit_sound(entity, CHAN_AUTO, suicide_sounds[random_num(0, sizeof suicide_sounds - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_task(5.5, "kill_entity", entity+1337);
	}
}

public kill_entity(ent)
{
	new id = ent-1337;
	
	if(!pev_valid(id))
		return;
	
	engfunc(EngFunc_RemoveEntity, id);
}