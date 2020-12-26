#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.0.1"

#define FLASHBANG_SEARCH_RADIUS 1500.0

new g_bHasNoFlash
#define SetUserNoFlash(%1)		g_bHasNoFlash |=   1<<(%1&31)
#define RemoveUserNoFlash(%1)		g_bHasNoFlash &= ~(1<<(%1&31))
#define HasUserNoFlash(%1)		g_bHasNoFlash &    1<<(%1&31)

new g_iMaxPlayers
#define IsPlayer(%1)	( 1 <= %1 <= g_iMaxPlayers )

new g_iCost[2]

public plugin_init()
{
	register_plugin("Furien NoFlash", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/noflash.ini", szConfigFile);

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
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_noflash")
	
		register_forward(FM_FindEntityInSphere, "FindEntityInSphere")
		RegisterHam(Ham_Killed, "player", "CBasePlayer_Killed", true)

		g_iMaxPlayers = get_maxplayers()
	}
}

public client_putinserver(id)
{
	RemoveUserNoFlash(id)
}

public CBasePlayer_Killed(id)
{
	RemoveUserNoFlash(id)
}

public furien_team_change( /*iFurien */ )
{
	if( !g_iCost[Furien] || !g_iCost[AntiFurien] )
	{
		g_bHasNoFlash = 0
	}
}

public furien_round_restart()
{
	g_bHasNoFlash = 0
}

public furien_buy_noflash( id )
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

	if( ~HasUserNoFlash(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			SetUserNoFlash( id )
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	return ShopAlreadyHaveOne
}

public FindEntityInSphere(id, Float:fVecOrigin[3], Float:flRadius)
{
	if( flRadius == FLASHBANG_SEARCH_RADIUS )
	{
		while( IsPlayer( (id=engfunc(EngFunc_FindEntityInSphere, id, fVecOrigin, flRadius)) ) )
		{
			if( ~HasUserNoFlash(id) && is_user_alive(id) )
			{
				forward_return(FMV_CELL, id)
				return FMRES_SUPERCEDE
			}
		}
		forward_return(FMV_CELL, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}