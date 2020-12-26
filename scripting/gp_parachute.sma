#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
//#include <zombie_plague_advance>

#pragma compress 1

#define PLUGIN "GP Parachute"
#define VERSION "1.0"
#define AUTHOR "Dexter"

//------------------------------------------------------------------------------
new para_ent[33]
new Float:last_grav[33];
new g_Players
//------------------------------------------------------------------------------

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "Round_Start", "a", "1=0", "2=0")
	g_Players = get_maxplayers();
}
//------------------------------------------------------------------------------

public plugin_precache()
{
	precache_model("models/gp_parachute.mdl")
}


//------------------------------------------------------------------------------
public Round_Start()
{
	for(new id=1;id<=g_Players;id++)
	{
		last_grav[id] = 1.0;
	}
}

//------------------------------------------------------------------------------
public client_PreThink(id)
{
	if( !is_user_alive(id) )
	{
		return PLUGIN_CONTINUE
	}

	if (get_user_button(id) & IN_USE)
	{
		if (! (get_user_oldbutton(id) & IN_USE)/* && !zp_get_user_frozen(id)*/)
		{
			last_grav[id] = get_user_gravity(id);
		}
		if ( !( get_entity_flags(id) & FL_ONGROUND ) )
		{
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			if(velocity[2] < 0)
			{
				if (para_ent[id] <= 0)
				{
					para_ent[id] = create_entity("info_target")
					if (para_ent[id] > 0)
					{
						entity_set_model(para_ent[id], "models/gp_parachute.mdl")
						entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
						entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					}
				}
				if (para_ent[id] > 0)
				{
					entity_set_int(id, EV_INT_sequence, 3)
					entity_set_int(id, EV_INT_gaitsequence, 1)
					velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
					if (entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0)
					{
						if (entity_get_int(para_ent[id], EV_INT_sequence) != 1)
						{
							entity_set_int(para_ent[id], EV_INT_sequence, 1)
						}
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					}
					else 
					{
						entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0)
					}
					set_user_gravity(id, 0.1)
				}
			}
			else
			{
				if (para_ent[id] > 0)
				{
					set_user_gravity(id, last_grav[id])
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			}
		}
		else
		{
			if (para_ent[id] > 0)
			{
				set_user_gravity(id, last_grav[id])
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	}
	else if (get_user_oldbutton(id) & IN_USE)
	{
		if (para_ent[id] > 0)
		{
			set_user_gravity(id, last_grav[id])
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}
	
	
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
