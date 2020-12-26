#include <amxmodx>
#include <cstrike>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.0"

enum _:mDatas {
	iApCost,
	iAp,
	iMaxAp,
	iApType
}

new g_iDatas[2][mDatas]

public plugin_init()
{
	register_plugin("Furien Armor", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/armor.ini", szConfigFile);

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
							g_iDatas[AntiFurien][iApCost] = str_to_num(szValue)
						}
					}
					case 'X':
					{
						if( equal(szKey, "ANTI_MAX" ) )
						{
							g_iDatas[AntiFurien][iMaxAp] = clamp(str_to_num(szValue), 1, 999)
						}
					}
					case 'P':
					{
						if( equal(szKey, "ANTI_TYPE" ) )
						{
							g_iDatas[AntiFurien][iApType] = clamp(str_to_num(szValue), 1, 2)
						}
					}
					case 0:
					{
						if( equal(szKey, "ANTI_AP" ) )
						{
							g_iDatas[AntiFurien][iAp] = max(str_to_num(szValue), 1)
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
							g_iDatas[Furien][iApCost] = str_to_num(szValue)
						}
					}
					case 'X':
					{
						if( equal(szKey, "FURIEN_MAX" ) )
						{
							g_iDatas[Furien][iMaxAp] = clamp(str_to_num(szValue), 1, 999)
						}
					}
					case 'P':
					{
						if( equal(szKey, "FURIEN_TYPE" ) )
						{
							g_iDatas[Furien][iApType] = clamp(str_to_num(szValue), 1, 999)
						}
					}
					case 0:
					{
						if( equal(szKey, "FURIEN_AP" ) )
						{
							g_iDatas[Furien][iAp] = max(str_to_num(szValue), 1)
						}
					}
				}
			}
		}
	}
	fclose( fp )

	if( g_iDatas[Furien][iApCost] || g_iDatas[AntiFurien][iApCost] )
	{
		furien_register_item(szFurienName, g_iDatas[Furien][iApCost], szAntiName, g_iDatas[AntiFurien][iApCost], "furien_buy_armor")
	}	
}

public furien_buy_armor( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iDatas[iTeam][iApCost]
	if( iItemCost <= 0 )
	{
		return ShopTeamNotAvail
	}

	new CsArmorType:iArmorType, iArmor = cs_get_user_armor(id, iArmorType)

	new ARMOR_TYPE = g_iDatas[iTeam][iApType]
	new iArmorMax = g_iDatas[iTeam][iMaxAp]

	if( iArmor >= iArmorMax && _:iArmorType >= ARMOR_TYPE )
	{
		return ShopCantCarryAnymore
	}

	if( furien_try_buy(id, iItemCost) )
	{
		cs_set_user_armor(id, min(iArmor + g_iDatas[iTeam][iAp], iArmorMax), CsArmorType:max(_:iArmorType, ARMOR_TYPE))
		return ShopBought
	}
	return ShopNotEnoughMoney
}