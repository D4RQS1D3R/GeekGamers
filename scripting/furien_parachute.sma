#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>

#include "furien.inc"
#include "furien_shop.inc"

#define MAX_PLAYERS		32

new g_szParaModel[64]

new Float:g_flFallSpeed

new g_bHasParachute
#define SetUserParachute(%1)		g_bHasParachute |=	1<<(%1&31)
#define RemoveUserParachute(%1)	g_bHasParachute &=	~(1<<(%1&31))
#define HasUserAutoParachute(%1)	g_bHasParachute &	1<<(%1&31)

new g_iParachute[MAX_PLAYERS+1]
new Float:g_flFrame[MAX_PLAYERS+1]

new g_iCost[2]

public plugin_precache()
{
	register_plugin("AMX Parachute", "1.4.0", "KRoT@L") // Edited By ~DarkSiDeRs~

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/parachute.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return
	}

	new szFurienName[32], szAntiName[32]

	new szDatas[80], szKey[16], szValue[64]
	while( !feof(fp) )
	{
		fgets(fp, szDatas, charsmax(szDatas))
		trim(szDatas)
		if(!szDatas[0] || szDatas[0] == ';' || szDatas[0] == '#' || (szDatas[0] == '/' && szDatas[1] == '/'))
		{
			continue
		}

		parse(szDatas, szKey, charsmax(szKey), szValue, charsmax(szValue))

		switch( szKey[0] )
		{
			case 'A':
			{
				switch( szKey[7] )
				{
					case 'M':
					{
						if( equal(szKey, "ANTI_NAME" ) )
						{
							copy(szAntiName, charsmax(szAntiName), szValue)
						}
					}
					case 'S':
					{
						if( equal(szKey, "ANTI_COST" ) )
						{
							g_iCost[AntiFurien] = str_to_num(szValue)
						}
					}
				}
			}
			case 'F':
			{
				switch( szKey[9] )
				{
					case 'M':
					{
						if( equal(szKey, "FURIEN_NAME" ) )
						{
							copy(szFurienName, charsmax(szAntiName), szValue)
						}
					}
					case 'S':
					{
						if( equal(szKey, "FURIEN_COST" ) )
						{
							g_iCost[Furien] = str_to_num(szValue)
						}
					}
				}
			}
			case 'P':
			{
				switch( szKey[5] )
				{
					case 'M':
					{
						if( equal(szKey, "PARA_MODEL" ) )
						{
							copy(g_szParaModel, charsmax(g_szParaModel), szValue)
							precache_model(g_szParaModel)
						}
					}
					case 'F':
					{
						if( equal(szKey, "PARA_FALLSPEED" ) )
						{
							g_flFallSpeed = -str_to_float(szValue)
						}
					}
				}
			}
		}
	}
	fclose( fp )

	if( g_iCost[Furien] || g_iCost[AntiFurien] )
	{
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_parachute")	

		RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1)
		RegisterHam(Ham_Killed, "player", "Player_Killed", 1)
	}
}

public plugin_natives()
{
	register_native("HaveParachute", "native_HaveParachute", 1);
}

public native_HaveParachute(id)
{
	return HasUserAutoParachute(id)
}

public furien_team_change( /*iFurien */ )
{
	if( !g_iCost[Furien] || !g_iCost[AntiFurien] )
	{
		g_bHasParachute = 0
	}
}

public furien_round_restart()
{
	g_bHasParachute = 0
}

public furien_buy_parachute( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iCost[iTeam]
	if( iItemCost <= 0 )
	{
		return ShopTeamNotAvail
	}

	if( ~HasUserAutoParachute(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			SetUserParachute( id )
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	return ShopAlreadyHaveOne
}

public client_disconnect(id)
{
	parachute_reset(id, false)
}

public Player_Spawn(id)
{

	parachute_reset(id, false)
}

public Player_Killed(id)
{
	parachute_reset(id, true)
	RemoveUserParachute(id)
}

public client_putinserver(id)
{
	RemoveUserParachute(id)
}

parachute_reset(id, bool:bReSetGravity = true)
{
	new iEnt = g_iParachute[id]
	if( iEnt > 0 )
	{
		if( is_valid_ent(iEnt) )
		{
			entity_set_int(iEnt, EV_INT_flags, FL_KILLME)
		}
	}

	if( bReSetGravity && is_user_alive(id) )
	{
		set_user_gravity(id)
	}

	g_iParachute[id] = 0
}

public client_PreThink(id)
{
	if( ~HasUserAutoParachute(id) || !is_user_alive(id) )
	{
		return
	}

	if( cs_get_user_team(id) == CS_TEAM_T )
	{
		parachute_reset(id, true)
		RemoveUserParachute(id)
	}

	//parachute.mdl animation information
	//0 - deploy - 84 frames
	//1 - idle - 39 frames
	//2 - detach - 29 frames

	static const info_target[] = "info_target"
	static iEnt, Float:flFrame
	iEnt = g_iParachute[id]
	flFrame = g_flFrame[id]

	if ( iEnt > 0 && entity_get_int(id, EV_INT_flags) & FL_ONGROUND )
	{
		if ( get_user_gravity(id) == 0.1 )
		{
			set_user_gravity(id)
		}

		if( entity_get_int(iEnt, EV_INT_sequence) != 2 )
		{
			entity_set_int(iEnt, EV_INT_sequence, 2)
			entity_set_int(iEnt, EV_INT_gaitsequence, 1)

			entity_set_float(iEnt, EV_FL_frame, 0.0)
			g_flFrame[id] = 0.0

			entity_set_float(iEnt, EV_FL_animtime, 0.0)
			entity_set_float(iEnt, EV_FL_framerate, 0.0)
			return
		}

		flFrame += 2.0
		entity_set_float(iEnt, EV_FL_frame, flFrame)

		if ( flFrame > 254.0 )
		{
			entity_set_int(iEnt, EV_INT_flags, FL_KILLME)
			iEnt = 0
		}
	}
	else if(entity_get_int(id, EV_INT_button) & IN_USE)
	{
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)

		if ( velocity[2] < 0.0 )
		{
			if ( iEnt <= 0 )
			{
				iEnt = create_entity(info_target)
				if( iEnt > 0 )
				{
					entity_set_edict(iEnt, EV_ENT_aiment, id)
					entity_set_edict(iEnt, EV_ENT_owner, id)
					entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FOLLOW)
					entity_set_model(iEnt, g_szParaModel)
					entity_set_int(iEnt, EV_INT_sequence, 0)
					entity_set_int(iEnt, EV_INT_gaitsequence, 1)

					flFrame = 0.0
					entity_set_float(iEnt, EV_FL_frame, 0.0)
				}
			}

			if ( iEnt > 0 )
			{
				entity_set_int(id, EV_INT_sequence, 3)
				entity_set_int(id, EV_INT_gaitsequence, 1)
				entity_set_float(id, EV_FL_frame, 1.0)
				entity_set_float(id, EV_FL_animtime, 100.0)
				entity_set_float(id, EV_FL_framerate, 1.0)
				set_user_gravity(id, 0.1)

				velocity[2] += 40
				velocity[2] = (velocity[2] < g_flFallSpeed) ? velocity[2] : g_flFallSpeed
				entity_set_vector(id, EV_VEC_velocity, velocity)

				if ( entity_get_int(iEnt, EV_INT_sequence) == 0 )
				{
					flFrame += 1.0
					entity_set_float(iEnt, EV_FL_frame, flFrame)

					if ( flFrame > 100.0 )
					{
						entity_set_float(iEnt, EV_FL_animtime, 120.0)
						entity_set_float(iEnt, EV_FL_framerate, 0.4)
						entity_set_int(iEnt, EV_INT_sequence, 1)
						entity_set_int(iEnt, EV_INT_gaitsequence, 1)
						flFrame = 0.0
						entity_set_float(iEnt, EV_FL_frame, 0.0)
					}
				}
			}
		}
		else if ( iEnt > 0 )
		{
			entity_set_int(iEnt, EV_INT_flags, FL_KILLME)
			set_user_gravity(id)
			iEnt = 0
		}
	}
	else if( iEnt > 0 && get_user_oldbutton(id) & IN_USE )
	{
		entity_set_int(iEnt, EV_INT_flags, FL_KILLME)
		set_user_gravity(id)
		iEnt = 0
	}
	g_iParachute[id] = iEnt
	g_flFrame[id] = flFrame
}