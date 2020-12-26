#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <Colorchat>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.2.0"

#define ADMIN_LEVEL ADMIN_LEVEL_C

#define FIRST_PLAYER_ID	1

new g_iMaxPlayers
#define IsPlayer(%1)	( FIRST_PLAYER_ID <= %1 <= g_iMaxPlayers )

#define XO_WEAPON 4
#define m_pPlayer 41

#define XO_PLAYER		5
#define m_pActiveItem	373

new g_bHasSuperKnife
#define SetUserSuperKnife(%1)		g_bHasSuperKnife |= 1<<(%1&31)
#define RemoveUserSuperKnife(%1)	g_bHasSuperKnife &= ~(1<<(%1&31))
#define HasUserSuperKnife(%1)		g_bHasSuperKnife & 1<<(%1&31)

new g_iszSuperKnifeModel
new Float:g_flSuperKnifeDamageFactor

new g_iCost[2]

public plugin_init()
{
    register_clcmd("say /superknifex3","givesuperx3")
    register_clcmd("say /superx3","givesuperx3")
    register_clcmd("say /knifex3","givesuperx3")
    register_clcmd("say /x3","givesuperx3")
    register_clcmd("say superknifex3","givesuperx3")
    register_clcmd("say superx3","givesuperx3")
    register_clcmd("say knifex3","givesuperx3")
    register_clcmd("say x3","givesuperx3")
}

public plugin_precache()
{
	register_plugin("Furien SuperKnife", VERSION, "ConnorMcLeod") // Edited By ~DarkSiDeRs~

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/superknifex3.ini", szConfigFile);

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
			case 'K':
			{
				switch( szKey[6] )
				{
					case 'M':
					{
						if( equal(szKey, "KNIFE_MODEL" ) )
						{
							precache_model(szValue)
							g_iszSuperKnifeModel = engfunc(EngFunc_AllocString, szValue)
						}
					}
					case 'D':
					{
						if( equal(szKey, "KNIFE_DAMAGE" ) )
						{
							g_flSuperKnifeDamageFactor = str_to_float(szValue)
						}
					}
				}
			}
		}
	}
	fclose( fp )

	if( g_iCost[Furien] || g_iCost[AntiFurien] )
	{
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_superknife")	

		RegisterHam(Ham_Killed, "player", "Ham_CBasePlayer_Killed_Post", true)
		RegisterHam(Ham_TakeDamage, "player", "CBasePlayer_TakeDamage", false)
		RegisterHam(Ham_Item_Deploy, "weapon_knife", "CKnife_Deploy", true)

		g_iMaxPlayers = get_maxplayers()
	}
}

public client_putinserver(id)
{
	RemoveUserSuperKnife(id)
}

public furien_buy_superknife( id )
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

	if( ~HasUserSuperKnife(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			SetUserSuperKnife(id)
			if( get_user_weapon(id) == CSW_KNIFE )
			{
				ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, m_pActiveItem, XO_PLAYER))
			}
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	return ShopAlreadyHaveOne
}

public CKnife_Deploy( iKnife )
{
	new id = get_pdata_cbase(iKnife, m_pPlayer, XO_WEAPON)

	if( HasUserSuperKnife(id) )
	{
		set_pev(id, pev_viewmodel, g_iszSuperKnifeModel)
	}
}

public CBasePlayer_TakeDamage(id, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if( IsPlayer(iInflictor) && HasUserSuperKnife(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE )
	{
		SetHamParamFloat( 4, flDamage * g_flSuperKnifeDamageFactor )
	}
}

public Ham_CBasePlayer_Killed_Post(id)
{
	RemoveUserSuperKnife(id)
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
			if( HasUserSuperKnife(id) )
			{
				RemoveUserSuperKnife(id)
				if( get_user_weapon(id) == CSW_KNIFE )
				{
					ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, m_pActiveItem, XO_PLAYER))
				}
			}
		}
		g_bHasSuperKnife = 0
	}
}

public furien_round_restart()
{
	g_bHasSuperKnife = 0
}

public givesuperx3(id)
{ 
	if(!(get_user_flags(id) & ADMIN_LEVEL)) return PLUGIN_HANDLED

	new Menu = menu_create("\d[\yGeek~Gamers\d] \rSuper Knife x3 \yMenu:", "Handlegivebow")
	
	menu_additem(Menu, "\wGet \rSuper Knife \yx3^n"   , "1", ADMIN_LEVEL)
	menu_additem(Menu, "\wGive \rSuper Knife \yx3 \wTo 1 \rFurien"   , "2", ADMIN_LEVEL)
	menu_additem(Menu, "\wGive \rSuper Knife \yx3 \wTo All \rFuriens"   , "3", ADMIN_LEVEL)
	
	menu_setprop(Menu,MPROP_EXITNAME,"Close")
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, Menu, 0)
	return PLUGIN_HANDLED
	
}

public Handlegivebow(id,menu,item){
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}	
	new iPlayers[ 32 ], iNum;
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	
	new iArg[ 64 ], szName[ 32 ];
	read_argv( 1, iArg, charsmax( iArg ) );
	get_user_name( id, szName, charsmax( szName ) ); 
	get_players( iPlayers, iNum );

	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
		if(cs_get_user_team(id) == CS_TEAM_T)
			SetUserSuperKnife(id)
		else
			ChatColor(id, "!t[GG] !nOnly !gFuriens !nCan Get a !gSuper Knife [x3]");
		}
		case 2:
		{
			menusuperx3(id)	
		}
		case 3:
		{
			new num, players[32], tempid

			get_players (players, num, "ae", "TERRORIST")

   			for (new i = 0; i < num; i++)
   			 {
     			  	tempid = players [ i ]
				SetUserSuperKnife(tempid);
  			  }
			ColorChat(0, RED, "^4[GG] ^1OWNER ^4%s ^1: Give Super Knife [x3] To All ^3Furiens", szName)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED
}

public menusuperx3(id)
{
	new GiveSuperx3 = menu_create ("\d[\yGeek~Gamers\d] \rGive \ySuper Knife x3:", "Handlemenusuperx3")
	
	new num, players[32], tempid, szTempID [10], tempname [32], szName [32], textmenu [64]
	get_players (players, num, "ae", "TERRORIST")

	for (new i = 0; i < num; i++)
	{
		tempid = players [ i ]

		get_user_name(tempid, tempname, 31)
      		get_user_name(tempid, szName, charsmax(szName))
		num_to_str(tempid, szTempID, 9)
		if(HasUserSuperKnife(tempid))
        		formatex(textmenu, 63, "%s \r- \y[ON]", szName)	
		else
        		formatex(textmenu, 63, "%s \y- \r[OFF]", szName)
		menu_additem(GiveSuperx3, textmenu, szTempID, 0)
	}
	menu_display (id, GiveSuperx3)
	return PLUGIN_HANDLED
}

public Handlemenusuperx3(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], name[64], szPlayerName[33], szName[33]
	new access, callback
	
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num (data)
	
	get_user_name(id, szName, charsmax(szName))
	get_user_name(tempid, szPlayerName, charsmax(szPlayerName))
	
	if(HasUserSuperKnife(tempid))
	{
		RemoveUserSuperKnife(tempid)
		ColorChat(0, RED, "^4[GG] ^1OWNER ^4%s ^1: Remove Super Knife [x3] To ^3%s", szName, szPlayerName)
	}
	else
	{
		SetUserSuperKnife(tempid)
		ColorChat(0, RED, "^4[GG] ^1OWNER ^4%s ^1: Give Super Knife [x3] To ^3%s", szName, szPlayerName)
	}

	menu_destroy(menu);
	menusuperx3(id)
	return PLUGIN_CONTINUE
}

stock ChatColor(const id, const input[], any:...)
	{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!t2", "^0");
	
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
		for (new i = 0; i < count; i++)
			{
			if (is_user_connected(players[i]))
				{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}