#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "1.0.1"

new g_bHasThermalGoggle
#define SetUserThermalGoggle(%1)		g_bHasThermalGoggle |= 1<<(%1&31)
#define RemoveUserThermalGoggle(%1)	g_bHasThermalGoggle &= ~(1<<(%1&31))
#define HasUserThermalGoggle(%1)		g_bHasThermalGoggle & 1<<(%1&31)

new g_bThermalGoggleActivated
#define ActiveUserThermalGoggle(%1)	g_bThermalGoggleActivated |= 1<<(%1&31)
#define DeactiveUserThermalGoggle(%1)	g_bThermalGoggleActivated &= ~(1<<(%1&31))
#define HasUserActiveThermalGoggle(%1)	g_bThermalGoggleActivated & 1<<(%1&31)

#define FREQUENCY 0.1
#define MAX_DISTANCE	1000.0

#define MAX_PLAYERS 32

new Float:g_flNextUpdate[MAX_PLAYERS+1]

new g_iSprite

new g_iCost[2]

public plugin_natives()
{
	register_native("cs_set_user_thermalgoggle", "native_set_user_thermalgoggle", 1);
}

public native_set_user_thermalgoggle(id)
{
	cs_set_user_nvg(id, 1)
	SetUserThermalGoggle(id)
}

public plugin_init()
{
	register_plugin("Thermal Imaging Goggle", VERSION, "Cheap_Suit")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/thermal_goggle.ini", szConfigFile);

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
		}
	}
	fclose( fp )

	if( g_iCost[Furien] || g_iCost[AntiFurien] )
	{
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_goggle")
	
		register_event("NVGToggle", "Event_NVGToggle", "be")
		RegisterHam(Ham_Killed, "player", "Ham_CBasePlayer_Killed_Post", true)
	}
}

public plugin_precache()
{
	g_iSprite = precache_model("sprites/poison.spr")
}

public client_putinserver(id)
{
	RemoveUserThermalGoggle(id)
	DeactiveUserThermalGoggle(id)
}

public Ham_CBasePlayer_Killed_Post(id)
{
	RemoveUserThermalGoggle(id)
	DeactiveUserThermalGoggle(id)
}

public furien_buy_goggle( id )
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

	if( ~HasUserThermalGoggle(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			cs_set_user_nvg(id, 1)
			SetUserThermalGoggle(id)
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	return ShopAlreadyHaveOne
}

public furien_team_change( /*iFurien */ )
{
	if( !g_iCost[Furien] || !g_iCost[AntiFurien] )
	{
		new iPlayers[32], iNum, id
		get_players(iPlayers, iNum, "a")
		for(new i; i<iNum; i++)
		{
			id = iPlayers[i]
			if( HasUserActiveThermalGoggle(id) )
			{
				cs_set_user_nvg(id, 0)
			}
		}
		g_bHasThermalGoggle = 0
		g_bThermalGoggleActivated = 0
	}
}

public furien_round_restart()
{
	g_bHasThermalGoggle = 0
	g_bThermalGoggleActivated = 0
}

public Event_NVGToggle(id)
{
	if( HasUserThermalGoggle(id) )
	{
		if( read_data(1) )
		{
			ActiveUserThermalGoggle(id)
		}
		else
		{
			DeactiveUserThermalGoggle(id)
		}
	}
}

public client_PostThink(id)
{
	if( ~HasUserActiveThermalGoggle(id) || !is_user_alive(id) )
	{
		return
	}

	new Float:flTime = get_gametime()

	if( g_flNextUpdate[id] > flTime )
	{
		return
	}

	g_flNextUpdate[id] = flTime + FREQUENCY

	new Float:fMyOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fMyOrigin)

	static Players[32], iNum
	get_players(Players, iNum, "ae", cs_get_user_team(id) == CS_TEAM_CT ? "TERRORIST" : "CT")
	for(new i = 0; i < iNum; ++i)
	{
		new target = Players[i]

		new Float:fTargetOrigin[3]
		entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
		
	/*	if((get_distance_f(fMyOrigin, fTargetOrigin) > MAX_DISTANCE) 
		|| !is_in_viewcone(id, fTargetOrigin))
			continue*/
		if( get_distance_f(fMyOrigin, fTargetOrigin) > MAX_DISTANCE )
		{
			continue
		}

		new Float:fMiddle[3], Float:fHitPoint[3]
		xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
		trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
								
		new Float:fWallOffset[3], Float:fDistanceToWall
		fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
	//	normalize(fMiddle, fWallOffset, fDistanceToWall)
		xs_vec_mul_scalar(fMiddle, fDistanceToWall/vector_length(fMiddle), fWallOffset)
		
		new Float:fSpriteOffset[3]
		xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
		new Float:fScale, Float:fDistanceToTarget = vector_distance(fMyOrigin, fTargetOrigin)
		if(fDistanceToWall > 100.0)
			fScale = 8.0 * (fDistanceToWall / fDistanceToTarget)
		else
			fScale = 2.0
	
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, .player=id)
		{
			write_byte(TE_SPRITE)
			engfunc(EngFunc_WriteCoord, fSpriteOffset[0])
			engfunc(EngFunc_WriteCoord, fSpriteOffset[1])
			engfunc(EngFunc_WriteCoord, fSpriteOffset[2])
			write_short(g_iSprite)
			write_byte(floatround(fScale)) 
			write_byte(125)
		}
		message_end()
	}
}

/*stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}*/

/*normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
//	xs_vec_normalize(fIn, fOut)
//	vector_length(fIn)
	xs_vec_mul_scalar(fIn, fMul/vector_length(fIn), fOut)
}*/