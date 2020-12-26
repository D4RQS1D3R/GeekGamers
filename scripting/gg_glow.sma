#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

public plugin_init()
{
	register_plugin("[GG] Admin Glow", "2.3", "~D4rkSiD3Rs~");
}

public client_putinserver(id)
{
	set_task(5.0, "g_Glows", id, _, _, "b");
}

public g_Glows(id)
{
	if(!is_user_alive(id))
		return;
		
	if(!(get_user_flags(id) & ADMIN_KICK))
		return;
		
	if(cs_get_user_team(id) != CS_TEAM_CT)
		return;

	set_user_rendering(id, kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal, 16);
}