#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.0"

new g_bHasNvg
#define SetUserNvg(%1)		g_bHasNvg |=	1<<(%1&31)
#define ClearUserNvg(%1)	g_bHasNvg &=	~(1<<(%1&31))
#define HasUserNvg(%1)		g_bHasNvg &	1<<(%1&31)

new g_iCost[2]

public plugin_init()
{
	register_plugin("Furien NightVision", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/nightvision.ini", szConfigFile);

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
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_nvg")
		RegisterHam(Ham_Spawn, "player", "Ham_CBasePlayer_Spawn_Post", 1)
		RegisterHam(Ham_Killed, "player", "Ham_CBasePlayer_Killed_Post", 1)
	}
}

public client_putinserver( id )
{
	ClearUserNvg( id )
}

public furien_buy_nvg( id )
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

	if( cs_get_user_nvg(id) )
	{
		return ShopAlreadyHaveOne
	}

	if( furien_try_buy(id, iItemCost) )
	{
		cs_set_user_nvg(id, 1)
		return ShopBought
	}
	return ShopNotEnoughMoney
}

public Ham_CBasePlayer_Killed_Post( id )
{
	if( HasUserNvg(id) )
	{
		ClearUserNvg( id )
	}
}

public Ham_CBasePlayer_Spawn_Post( id )
{
	if(	HasUserNvg(id)
	&&	is_user_alive(id)
	&&	cs_get_user_nvg(id)	)
	{
		cs_set_user_nvg(id, 1)
	}
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
			if( HasUserNvg(id) )
			{
				cs_set_user_nvg(id, 0)
			}
		}
		g_bHasNvg = 0
	}
}

public furien_round_restart()
{
	g_bHasNvg = 0
}