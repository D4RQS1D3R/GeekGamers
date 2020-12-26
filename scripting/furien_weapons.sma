#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.1"

#define MAX_WEAPONS	CSW_P90

enum _:mDatas {
	mFurienCost,
	mFurienBpAmmo,
	mFurienBpAmmoMax,
	mAntiCost,
	mAntiBpAmmo,
	mAntiBpAmmoMax
}

enum _:mAutoDatas {
	miId,
	miBpAmmo,
	miBpAmmoMax
}

new g_iWeaponsBuyDatas[MAX_WEAPONS+1][mDatas]

new Array:g_aFurienAutoWeapons, Array:g_aAntiAutoWeapons

public plugin_init()
{
	register_plugin("Furien Weapons", VERSION, "ConnorMcLeod")

	g_aFurienAutoWeapons = ArrayCreate(mAutoDatas)
	g_aAntiAutoWeapons = ArrayCreate(mAutoDatas)

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/weapons.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return
	}

	new szDatas[256], szWeaponName[20], szMode[2], szFurienBpAmmo[4], szAntiBpAmmo[4], szFurienBpAmmoMax[4], szAntiBpAmmoMax[4], 
		szFurienName[32], szAntiName[32], szFurienCost[6], szAntiCost[6]

	while( !feof(fp) )
	{
		fgets(fp, szDatas, charsmax(szDatas))
		trim(szDatas)
		if(!szDatas[0] || szDatas[0] == ';' || szDatas[0] == '#' || (szDatas[0] == '/' && szDatas[1] == '/'))
		{
			continue
		}

//		server_print("Weapons Entry")
//		server_print(szDatas)

		parse
		(
			szDatas, 
			szWeaponName, charsmax(szWeaponName),
			szMode, charsmax(szMode),
			szFurienBpAmmo, charsmax(szFurienBpAmmo),
			szAntiBpAmmo, charsmax(szAntiBpAmmo),
			szFurienBpAmmoMax, charsmax(szFurienBpAmmoMax),
			szAntiBpAmmoMax, charsmax(szAntiBpAmmoMax),
			szFurienName, charsmax(szFurienName),
			szAntiName, charsmax(szAntiName),
			szFurienCost, charsmax(szFurienCost),
			szAntiCost, charsmax(szAntiCost)
		)
/*
		server_print("%s %s | BpAmmo %s %s | Max %s %s | %s %s %s %s",
			szWeaponName, szMode, szFurienBpAmmo, szAntiBpAmmo, szFurienBpAmmoMax, szAntiBpAmmoMax,
			szFurienName, szAntiName, szFurienCost, szAntiCost)
*/
		new iId = get_weaponid( szWeaponName )
		if( iId <= 0 )
		{
			continue
		}

		switch( szMode[0] )
		{
			case '0':
			{
				if( (g_iWeaponsBuyDatas[iId][mFurienCost] = str_to_num(szFurienCost)) )
				{
					g_iWeaponsBuyDatas[iId][mFurienBpAmmo] = str_to_num(szFurienBpAmmo)
					g_iWeaponsBuyDatas[iId][mFurienBpAmmoMax] = max( str_to_num(szFurienBpAmmoMax) , g_iWeaponsBuyDatas[iId][mFurienBpAmmo] )
				}

				if( (g_iWeaponsBuyDatas[iId][mAntiCost] = str_to_num(szAntiCost)) )
				{	
					g_iWeaponsBuyDatas[iId][mAntiBpAmmo] = str_to_num(szAntiBpAmmo)
					g_iWeaponsBuyDatas[iId][mAntiBpAmmoMax] = max( str_to_num(szAntiBpAmmoMax) , g_iWeaponsBuyDatas[iId][mAntiBpAmmo] )
				}

				furien_register_item
				(
					szFurienName,
					g_iWeaponsBuyDatas[iId][mFurienCost],
					szAntiName,
					g_iWeaponsBuyDatas[iId][mAntiCost],
					"furien_buy_weapon",
					iId
				)	
			}
			case '1':
			{
				new Datas[mAutoDatas]

				Datas[miId] = iId
				Datas[miBpAmmo] = str_to_num(szFurienBpAmmo)
				Datas[miBpAmmoMax] = max( str_to_num(szFurienBpAmmoMax), Datas[miBpAmmo] )

				ArrayPushArray(g_aFurienAutoWeapons, Datas)
			}
			case '2':
			{
				new Datas[mAutoDatas]

				Datas[miId] = iId
				Datas[miBpAmmo] = str_to_num(szAntiBpAmmo)
				Datas[miBpAmmoMax] = max( str_to_num(szAntiBpAmmoMax), Datas[miBpAmmo] )

				ArrayPushArray(g_aAntiAutoWeapons, Datas)
			}
			case '3':
			{
				new Datas[mAutoDatas]

				Datas[miId] = iId
				Datas[miBpAmmo] = str_to_num(szAntiBpAmmo)
				Datas[miBpAmmoMax] = max( str_to_num(szAntiBpAmmoMax), Datas[miBpAmmo] )

				ArrayPushArray(g_aFurienAutoWeapons, Datas)
				ArrayPushArray(g_aAntiAutoWeapons, Datas)
			}
		}
	}
	fclose(fp)

	if( ArraySize(g_aFurienAutoWeapons) || ArraySize(g_aAntiAutoWeapons) )
	{
		RegisterHam(Ham_Spawn, "player", "Ham_CBasePlayer_Spawn_Post", 1)
	}
}

public plugin_end()
{
	ArrayDestroy( g_aFurienAutoWeapons )
	ArrayDestroy( g_aAntiAutoWeapons )
}

public Ham_CBasePlayer_Spawn_Post( id )
{
	if( is_user_alive(id) )
	{
		switch( furien_get_user_team(id) )
		{
			case Furien :
			{
				GiveAutoWeapons(id, g_aFurienAutoWeapons)
			}
			case AntiFurien :
			{
				GiveAutoWeapons(id, g_aAntiAutoWeapons)
			}
		}
	}
}

public furien_buy_weapon( id, iId )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iWeaponsBuyDatas[iId][ iTeam == Furien ? mFurienCost : mAntiCost ]

	if( iItemCost <= 0 )
	{
		return ShopTeamNotAvail
	}

	if( user_has_weapon(id, iId) )
	{
		return ShopAlreadyHaveOne
	}

	if( furien_try_buy(id, iItemCost) )
	{
		new szWeaponName[20]
		get_weaponname(iId, szWeaponName, charsmax(szWeaponName))
		give_item(id, szWeaponName)
		new iBpAmmo = g_iWeaponsBuyDatas[iId][ iTeam == Furien ? mFurienBpAmmo : mAntiBpAmmo ]
		if( iBpAmmo )
		{
			new iBpAmmoMax = g_iWeaponsBuyDatas[iId][ iTeam == Furien ? mFurienBpAmmoMax : mAntiBpAmmoMax ]
			new iCurrentBpAmmo = cs_get_user_bpammo(id, iId)
			if( iCurrentBpAmmo < iBpAmmoMax )
			{
				cs_set_user_bpammo(id, iId, min(iCurrentBpAmmo + iBpAmmo, iBpAmmoMax))
			}
		}
		return ShopBought
	}
	return ShopNotEnoughMoney
}

GiveAutoWeapons(id, Array:aWeapons)
{
	new iItemsNum = ArraySize(aWeapons)

	new Datas[mAutoDatas], iId, szWeaponName[20], iBpAmmo, iBpAmmoMax, iCurrentBpAmmo

	for(new i; i<iItemsNum; i++)
	{
		ArrayGetArray(aWeapons, i, Datas)
		iId = Datas[miId]
		if( !user_has_weapon(id, iId) )
		{
			get_weaponname(iId, szWeaponName, charsmax(szWeaponName))
			give_item(id, szWeaponName)
		}

		iBpAmmo = Datas[miBpAmmo]
		if( iBpAmmo )
		{
			iBpAmmoMax = Datas[miBpAmmoMax]
			iCurrentBpAmmo = cs_get_user_bpammo(id, iId)
			if( iCurrentBpAmmo < iBpAmmoMax )
			{
				cs_set_user_bpammo(id, iId, min(iCurrentBpAmmo + iBpAmmo, iBpAmmoMax))
			}
		}
	}
}