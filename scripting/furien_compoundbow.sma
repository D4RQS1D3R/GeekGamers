#include <amxmodx>
#include <cstrike>

#pragma compress 1

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.0"

new g_iCost[2]

native assassin_mod(id)
native sniper_mod(id)
native avs_mod(id)
native ghost_mod(id)
native plasma_mod(id)

native gg_get_user_compoundbow(id)
native gg_set_user_compoundbow(id, ammo)

public plugin_init()
{
	register_plugin("Furien CompoundBow", VERSION, "~D4rkSiD3Rs~")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/compoundbow.ini", szConfigFile);

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

	if( g_iCost[AntiFurien] || g_iCost[Furien] )
	{
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_compoundbow")
	}	
}

public furien_buy_compoundbow( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iCost[iTeam]
	if( iItemCost <= 0 || assassin_mod(id) || sniper_mod(id) || avs_mod(id) || ghost_mod(id) || plasma_mod(id) )
	{
		return ShopTeamNotAvail
	}

	if( gg_get_user_compoundbow(id) )
	{
		return ShopAlreadyHaveOne
	}

	if( furien_try_buy(id, iItemCost) )
	{
		gg_set_user_compoundbow(id, 5)
		return ShopBought
	}
	return ShopNotEnoughMoney
}