/*
	Grenade Trail 1.0
	Author: Jim

	Cvars:
	grenade_tr: default 2
	0 - None
	1 - Random Colors
	2 - Nade Specific
	3 - Team Specific

	grenade_he "255000000" set the trail color of Hegrenade
	grenade_fb "000000255" set the trail color of Flashbang
	grenade_sg "000255000" set the trail color of Smokegrenade
*/

#include <amxmodx>
#include <csx>

#define PLUGIN "Grenade Trail"
#define VERSION "1.0"
#define AUTHOR "Jim"

new g_cvar_tr
new g_cvar_he
new g_cvar_fb
new g_cvar_sg
new g_trail

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_cvar_tr = register_cvar("grenade_tr", "2")
	g_cvar_he = register_cvar("grenade_he", "255000000")
	g_cvar_fb = register_cvar("grenade_fb", "000000255")
	g_cvar_sg = register_cvar("grenade_sg", "000255000")
}

public plugin_precache()
{
	g_trail = precache_model("sprites/smoke.spr")
}

public grenade_throw(id, gid, wid)
{
	new gtm = get_pcvar_num(g_cvar_tr)
	if(!gtm) return
	new r, g, b
	switch(gtm)
	{
		case 1:
		{
			r = random(256)
			g = random(256)
			b = random(256)
		}
		case 2:
		{
			new nade, color[10]
			switch(wid)
			{
				case CSW_HEGRENADE:	nade = g_cvar_he
				case CSW_FLASHBANG:	nade = g_cvar_fb
				case CSW_SMOKEGRENADE:	nade = g_cvar_sg
			}
			get_pcvar_string(nade, color, 9)
			new c = str_to_num(color)
			r = c / 1000000
			c %= 1000000 
			g = c / 1000
			b = c % 1000
		}
		case 3:
		{
			switch(get_user_team(id))
			{
				case 1: r = 255
				case 2: b = 255
			}
		}
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(gid)
	write_short(g_trail)
	write_byte(10)
	write_byte(5)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(192)
	message_end()
}