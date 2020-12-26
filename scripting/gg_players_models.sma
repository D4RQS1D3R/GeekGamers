#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_player_models_api>

native white_furien(id)
native red_furien(id)
native black_furien(id)
native green_human(id)
native white_human(id)
native black_human(id)

public plugin_init()
{
        register_plugin("[GG] Players Models", "1.0", "~D4rkSiD3Rs~")

	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawnPost", true)

	new iEnt
	iEnt = create_entity("info_target")
	set_pev(iEnt, pev_classname, "check_speed")
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	register_think("check_speed", "Set_Spectator_Visibility")

        return PLUGIN_CONTINUE
}

public plugin_precache()
{
        precache_model("models/player/gg_furien/gg_furien.mdl")
        precache_model("models/player/gg_furien2/gg_furien2.mdl")
        precache_model("models/player/gg_furien3/gg_furien3.mdl")

        precache_model("models/player/gg_antifurien/gg_antifurien.mdl")
        precache_model("models/player/gg_antifurien/gg_antifurienT.mdl")
        precache_model("models/player/gg_antifurien2/gg_antifurien2.mdl")
        precache_model("models/player/gg_antifurien2/gg_antifurien2T.mdl")
        precache_model("models/player/gg_antifurien3/gg_antifurien3.mdl")
        precache_model("models/player/gg_antifurien3/gg_antifurien3T.mdl")

        precache_model("models/player/gg_furien_admin/gg_furien_admin.mdl")
        precache_model("models/player/gg_antifurien_admin/gg_antifurien_admin.mdl")

        return PLUGIN_CONTINUE
}

public Ham_PlayerSpawnPost(id)
{
        if (!is_user_alive(id))
                return;

	if(get_user_flags(id) & ADMIN_KICK)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			cs_set_player_model(id, "gg_furien_admin")
		}
		else if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_player_model(id, "gg_antifurien_admin")
		}
		else cs_reset_user_model(id)
	}
	else
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			if(white_furien(id))
			{
				cs_set_player_model(id, "gg_furien")
			}
			if(red_furien(id))
			{
				cs_set_player_model(id, "gg_furien2")
			}
			if(black_furien(id))
			{
				cs_set_player_model(id, "gg_furien3")
			}
		}
		else if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			if(green_human(id))
			{
				cs_set_player_model(id, "gg_antifurien")
			}
			if(white_human(id))
			{
				cs_set_player_model(id, "gg_antifurien2")
			}
			if(black_human(id))
			{
				cs_set_player_model(id, "gg_antifurien3")
			}
		}
		else cs_reset_user_model(id)
	}
}

public Set_Spectator_Visibility( iEnt )
{
	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

	new iPlayers[32], iNum, id, Float:fVecVelocity[3], iSpeed

	get_players(iPlayers, iNum, "ae", "SPECTATOR")

	for(new i; i<iNum; i++)
	{
		id = iPlayers[i]

		entity_get_vector(id, EV_VEC_velocity, fVecVelocity)
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, iSpeed)
	}
}
