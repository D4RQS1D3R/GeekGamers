#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <fakemeta>
#include <engine>
#include <cs_player_models_api>

#pragma compress 1

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "1.0"

new g_iCost[2]
new Float:g_flMaxSpeed = 250.0
new Float:g_flSideSpeed = 200.0
new g_szSpeedCommand[128]
new bool: BeCarefulBought[33]

native sniper_mod(id)
native avs_mod(id)
native plasma_mod(id)
native gg_set_user_buffawp(id)
native gg_set_user_plasmagun(id)

native green_human(id)
native white_human(id)
native black_human(id)

public plugin_init()
{
	register_plugin("Furien BeCareful", VERSION, "~D4rkSiD3Rs~")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/becareful.ini", szConfigFile);

	formatex(g_szSpeedCommand, charsmax(g_szSpeedCommand), 
			";cl_forwardspeed %.1f;cl_sidespeed %.1f;cl_backspeed %.1f",
							g_flMaxSpeed, g_flSideSpeed, g_flMaxSpeed)

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
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_becareful")
		RegisterHam(Ham_Spawn, "player", "Ham_CBasePlayer_Spawn_Post", 1)
		RegisterHam(Ham_Killed, "player", "Ham_CBasePlayer_Killed_Post", 1)
		RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage")
	}
}

public plugin_natives()
{
	register_native("bought_becareful", "native_bought_becareful", 1)
}

public furien_buy_becareful( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iCost[iTeam]
	if( iItemCost <= 0 || sniper_mod(id) )
	{
		return ShopTeamNotAvail
	}

	if( BeCarefulBought[id] )
	{
		return ShopAlreadyHaveOne
	}

	if( furien_try_buy(id, iItemCost) )
	{
		GetBeCareful(id)
		BeCarefulBought[id] = true
		return ShopBought
	}
	return ShopNotEnoughMoney
}

public GetBeCareful(id)
{
	if(avs_mod(id))
	{
		cs_set_player_model(id, "gg_antifurien_sniper")
		gg_set_user_buffawp(id)
	}
	else
	{
		if(green_human(id))
			cs_set_player_model(id, "gg_antifurien")
		else if(white_human(id))
			cs_set_player_model(id, "gg_antifurien2")
		else if(black_human(id))
			cs_set_player_model(id, "gg_antifurien3")

		if(plasma_mod(id))
			gg_set_user_plasmagun(id)
		else GetRandomPrimaryWeapon(id)
	}

	set_user_gravity(id, 1.0)
	reset_speed(id)
}

public GetRandomPrimaryWeapon(id)
{
	switch (random_num(1,16))
	{
		case 1:
		{
			give_item(id, "weapon_m4a1")
			cs_set_user_bpammo(id, CSW_M4A1, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 2:
		{
			give_item(id, "weapon_ak47")
			cs_set_user_bpammo(id, CSW_AK47, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 3:
		{
			give_item(id, "weapon_aug")
			cs_set_user_bpammo(id, CSW_AUG, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 4:
		{
			give_item(id, "weapon_sg552")
			cs_set_user_bpammo(id, CSW_SG552, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 5:
		{
			give_item(id, "weapon_galil")
			cs_set_user_bpammo(id, CSW_GALIL, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 6:
		{
			give_item(id, "weapon_famas")
			cs_set_user_bpammo(id, CSW_FAMAS, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 7:
		{
			give_item(id, "weapon_scout")
			cs_set_user_bpammo(id, CSW_SCOUT, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 8:
		{
			give_item(id, "weapon_awp")
			cs_set_user_bpammo(id, CSW_AWP, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 9:
		{
			give_item(id, "weapon_sg550")
			cs_set_user_bpammo(id, CSW_SG550, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 10:
		{
			give_item(id, "weapon_g3sg1")
			cs_set_user_bpammo(id, CSW_G3SG1, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 11:
		{
			give_item(id, "weapon_ump45")
			cs_set_user_bpammo(id, CSW_UMP45, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 12:
		{
			give_item(id, "weapon_mp5navy")
			cs_set_user_bpammo(id, CSW_MP5NAVY, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 13:
		{
			give_item(id, "weapon_m3")
			cs_set_user_bpammo(id, CSW_M3, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 14:
		{
			give_item(id, "weapon_xm1014")
			cs_set_user_bpammo(id, CSW_XM1014, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 15:
		{
			give_item(id, "weapon_tmp")
			cs_set_user_bpammo(id, CSW_TMP, 90)
			GetRandomSecondaryWeapon(id)
		}
		case 16:
		{
			give_item(id, "weapon_mac10")
			cs_set_user_bpammo(id, CSW_MAC10, 90)
			GetRandomSecondaryWeapon(id)
		}
	}
}

public GetRandomSecondaryWeapon(id)
{
	switch (random_num(1,6))
	{
		case 1:
		{
			give_item(id, "weapon_usp")
			cs_set_user_bpammo(id, CSW_USP, 90)
		}
		case 2:
		{
			give_item(id, "weapon_glock18")
			cs_set_user_bpammo(id, CSW_GLOCK18, 90)
		}
		case 3:
		{
			give_item(id, "weapon_deagle")
			cs_set_user_bpammo(id, CSW_DEAGLE, 90)
		}
		case 4:
		{
			give_item(id, "weapon_p228")
			cs_set_user_bpammo(id, CSW_P228, 90)
		}
		case 5:
		{
			give_item(id, "weapon_elite")
			cs_set_user_bpammo(id, CSW_ELITE, 90)
		}
		case 6:
		{
			give_item(id, "weapon_fiveseven")
			cs_set_user_bpammo(id, CSW_FIVESEVEN, 90)
		}
	}
}

public Player_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if( iInflictor == iAttacker && BeCarefulBought[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) != CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T )
	{
		SetHamParamFloat(4, fDamage * 0.0)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public reset_speed(id)
{
	g_flMaxSpeed = floatclamp(300.0, 100.0, 2000.0)
	client_cmd(id, g_szSpeedCommand)
	set_pev(id, pev_maxspeed, g_flMaxSpeed)
}

public client_PreThink(id)
{
	if( BeCarefulBought[id] )
	{
		if( (get_entity_flags(id) & FL_ONGROUND) && !(get_user_button(id) & IN_USE) )
		{
			set_user_gravity(id, 1.0)
		}
	}
}

public client_PostThink(id)
{
	if( BeCarefulBought[id] )
	{
		g_flMaxSpeed = floatclamp(300.0, 100.0, 2000.0)
		client_cmd(id, g_szSpeedCommand)
		set_pev(id, pev_maxspeed, g_flMaxSpeed)
	}
}

public Ham_CBasePlayer_Killed_Post( id )
{
	BeCarefulBought[id] = false
}

public Ham_CBasePlayer_Spawn_Post( id )
{
	BeCarefulBought[id] = false
}

public native_bought_becareful( id )
{
	return bool: BeCarefulBought[id]
}