#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.1"

#define	FL_WATERJUMP	(1<<11)
#define	FL_ONGROUND	(1<<9)

new g_bHasAutoBhop
#define SetUserAutoBhop(%1)		g_bHasAutoBhop |=	1<<(%1&31)
#define RemoveUserAutoBhop(%1)	g_bHasAutoBhop &=	~(1<<(%1&31))
#define HasUserAutoBhop(%1)		g_bHasAutoBhop &	1<<(%1&31)

new g_iCost[2]

native ghost_mod(id)

public plugin_init()
{
	register_plugin("Furien AutoBhop", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/autobhop.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return
	}

	new szFurienName[32], szAntiName[32]

	new szDatas[64], szKey[16], szValue[32]
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
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_autobhop")

		RegisterHam(Ham_Killed, "player", "CBasePlayer_Killed", true)
	}
}

public plugin_natives()
{
	register_native("set_user_autobhop", "native_set_user_autobhop", 1);
}

public native_set_user_autobhop(id)
{
	if( ~HasUserAutoBhop(id) && !ghost_mod(id) )
	{
		SetUserAutoBhop( id )
	}
}

public furien_buy_autobhop( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iCost[iTeam]
	if( iItemCost <= 0 || ghost_mod(id) )
	{
		return ShopTeamNotAvail
	}

	if( ~HasUserAutoBhop(id) && !ghost_mod(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			SetUserAutoBhop( id )
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	return ShopAlreadyHaveOne
}

public client_PreThink(id)  
{ 
	if( HasUserAutoBhop(id) && is_user_alive(id) && !ghost_mod(id) )
	{	
		entity_set_float(id, EV_FL_fuser2, 0.0) 
	
		if (entity_get_int(id, EV_INT_button) & 2)  
		{ 
			new flags = entity_get_int(id, EV_INT_flags) 
		
			if (flags & FL_WATERJUMP) 
				return PLUGIN_CONTINUE 
			if ( entity_get_int(id, EV_INT_waterlevel) >= 2 ) 
				return PLUGIN_CONTINUE 
			if ( !(flags & FL_ONGROUND) ) 
				return PLUGIN_CONTINUE 
		
			new Float:velocity[3] 
			entity_get_vector(id, EV_VEC_velocity, velocity) 
			velocity[0] *= 1.09
			velocity[1] *= 1.09
			velocity[2] += 250.5 
			entity_set_vector(id, EV_VEC_velocity, velocity) 
		
			entity_set_int(id, EV_INT_gaitsequence, 9) 
		}
	}
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	RemoveUserAutoBhop(id)
}

public CBasePlayer_Killed(id)
{
	RemoveUserAutoBhop(id)
}

public furien_team_change( /*iFurien */ )
{
	if( !g_iCost[Furien] || !g_iCost[AntiFurien] )
	{
		g_bHasAutoBhop = 0
	}
}

public furien_round_restart()
{
	g_bHasAutoBhop = 0
}