#include <amxmodx>
#include <fun>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.0"

enum _:mDatas {
	iHpCost,
	iHp,
	iMaxHp
}

new g_iHealthDatas[2][mDatas]

public plugin_init()
{
	register_plugin("Furien Health", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/health.ini", szConfigFile);

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
							g_iHealthDatas[AntiFurien][iHpCost] = str_to_num(szValue)
						}
					}
					case '_':
					{
						if( equal(szKey, "ANTI_HP_MAX" ) )
						{
							g_iHealthDatas[AntiFurien][iMaxHp] = clamp(str_to_num(szValue), 1, 255)
						}
					}
					case 0:
					{
						if( equal(szKey, "ANTI_HP" ) )
						{
							g_iHealthDatas[AntiFurien][iHp] = max(str_to_num(szValue), 1)
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
							g_iHealthDatas[Furien][iHpCost] = str_to_num(szValue)
						}
					}
					case '_':
					{
						if( equal(szKey, "FURIEN_HP_MAX" ) )
						{
							g_iHealthDatas[Furien][iMaxHp] = clamp(str_to_num(szValue), 1, 255)
						}
					}
					case 0:
					{
						if( equal(szKey, "FURIEN_HP" ) )
						{
							g_iHealthDatas[Furien][iHp] = max(str_to_num(szValue), 1)
						}
					}
				}
			}
		}
	}
	fclose( fp )

	if( g_iHealthDatas[Furien][iHpCost] || g_iHealthDatas[AntiFurien][iHpCost] )
	{
		furien_register_item(szFurienName, g_iHealthDatas[Furien][iHpCost], szAntiName, g_iHealthDatas[AntiFurien][iHpCost], "furien_buy_health")	
	}
}

public furien_buy_health( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iHealthDatas[iTeam][iHpCost]
	if( iItemCost <= 0 )
	{
		return ShopTeamNotAvail
	}

	new iMaxHealth = g_iHealthDatas[iTeam][iMaxHp]

	new iHealth = get_user_health(id)
	if( iHealth >= iMaxHealth )
	{
		return ShopCantCarryAnymore
	}

	if( furien_try_buy(id, iItemCost) )
	{
		set_user_health(id, min(iHealth + g_iHealthDatas[iTeam][iHp], iMaxHealth))
		return ShopBought
	}
	return ShopNotEnoughMoney
}