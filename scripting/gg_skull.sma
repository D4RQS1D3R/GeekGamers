#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Death Sprite"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

#define write_coord_f(%1) engfunc(EngFunc_WriteCoord,%1)

new const szSprite[] = "sprites/[GeekGamers]/skull.spr"

new pSprite;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Killed, "player", "DeathMsg")
}

public plugin_precache()
{
	pSprite = precache_model(szSprite)
}

public DeathMsg(const victim, const attacker)
{
	if(!is_user_connected(victim))
		return;
	
	if(cs_get_user_team(victim) != CS_TEAM_T)
		return;
	
	new Float:fOrigin[3];
	pev(victim,pev_origin,fOrigin);
	
	fOrigin[2] += 35.0;
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY )
	write_byte(TE_SPRITE)
	write_coord_f(fOrigin[0])
	write_coord_f(fOrigin[1])
	write_coord_f(fOrigin[2])
	write_short(pSprite) 
	write_byte(10) 
	write_byte(255)
	message_end()
}
