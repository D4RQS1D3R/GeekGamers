/*	Formatright © 2010, ConnorMcLeod

	Furien Shop is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Furien Shop; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#define ITEMS_PER_PAGE	7 // 7 max

#include <amxmodx>
#include <cstrike>

#include "furien.inc"
#include "furien_shop.inc"

#define szPickAmmoSound "items/9mmclip1.wav"

enum _:ItemDatas {
	szItemFurienName[32],
	iItemFurienCost,
	szItemAntiName[32],
	iItemAntiCost,
	iItemForwardIndex,
	iItemExtraArg
}

enum ( <<= 1 )
{
	ShouldBeInBuyZone = 1,
	ShouldBeInBuyTime
}

#define HUD_PRINTCENTER		4

new g_iBlinkAcct, g_iTextMsg, g_iShowMenu

new Array:g_aItems

//new CsTeams:g_iFurienTeam = CS_TEAM_T

#define MAX_PLAYERS 32
new g_iMenuPage[MAX_PLAYERS+1]

new g_iBuyType, g_pCvarBuyTime

new g_iShopMenu

new bool:g_bFreezeTime = true, bool:g_bBuyTime = true
new bool:g_bSwitchTime
new Float:g_flRoundStartGameTime

public plugin_init()
{
	register_plugin("Furien Shop", FURIEN_VERSION, "ConnorMcLeod")

	register_dictionary("common.txt")

	new pCvar = register_cvar("furien_shop_version", FURIEN_VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	set_pcvar_string(pCvar, FURIEN_VERSION)

	ReadCfgFile()

	if( g_iBuyType & ShouldBeInBuyZone )
	{
		register_event("StatusIcon", "Event_StatusIcon_OutOfBuyZone", "b", "1=0", "2=buyzone")
	}

	register_event("HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0")
	register_logevent("LogEvent_Round_Start", 2, "1=Round_Start")

	register_clcmd("shop", "ClientCommand_Shop")
	register_clcmd("say shop", "ClientCommand_Shop")
	register_clcmd("say_team shop", "ClientCommand_Shop")
	register_clcmd("buy", "ClientCommand_Shop")

	register_menucmd( (g_iShopMenu = register_menuid("Furien Shop")) , 1023, "ShopMenuAction")

	g_iBlinkAcct = get_user_msgid("BlinkAcct")
	g_iTextMsg = get_user_msgid("TextMsg")
	g_iShowMenu = get_user_msgid("ShowMenu")
	g_pCvarBuyTime = get_cvar_pointer("mp_buytime")
}

ReadCfgFile()
{
	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/shop.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return
	}

	new szDatas[32], szKey[16], szValue[16]
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
			case 'B':
			{
				if( equal(szKey, "BUY_TYPE" ) )
				{
					g_iBuyType = str_to_num(szValue)
				}
			}
		}
	}
	fclose( fp )
}

public plugin_precache()
{
	precache_sound(szPickAmmoSound)
}

public Event_HLTV_New_Round()
{
	g_bFreezeTime = true
	g_bBuyTime = true
	g_bSwitchTime = false
}

public LogEvent_Round_Start()
{
	g_bFreezeTime = false
	g_bBuyTime = true
	g_bSwitchTime = false
	g_flRoundStartGameTime = get_gametime()
}

bool:bIsBuyTime( id = 0 )
{
	new Float:flBuyTime
	if(	!g_bFreezeTime
	&&	( !g_bBuyTime || !(g_bBuyTime = get_gametime() < g_flRoundStartGameTime + (flBuyTime = get_buytime_value() * 60.0)) )	)
	{
		if( id )
		{
			new szBuyTime[3]
			float_to_str(flBuyTime, szBuyTime, charsmax(szBuyTime))
			Util_ClientPrint(id, HUD_PRINTCENTER, "#Cant_buy", szBuyTime)
		}
		return false
	}
	return true
}

Float:get_buytime_value()
{
	new Float:flBuyTime = get_pcvar_float(g_pCvarBuyTime)
	if( flBuyTime < 0.25 )
	{
		set_pcvar_float(g_pCvarBuyTime, 0.25)
		flBuyTime = 0.25
	}
	if( flBuyTime > 1.5 )
	{
		set_pcvar_float(g_pCvarBuyTime, 1.5)
		flBuyTime = 1.5
	}
	return flBuyTime
}

public furien_team_change(/* iNewTeam */)
{
	g_bSwitchTime = true
//	g_iFurienTeam = CsTeams:iNewTeam

	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "a")
	for(new i; i<iNum; i++)
	{
		CheckMenuClose(iPlayers[i])
	}
}

public Event_StatusIcon_OutOfBuyZone( id )
{
	CheckMenuClose(id)
}

CheckMenuClose(id)
{
	new iMenu, iKeys
	get_user_menu(id, iMenu, iKeys)
	if( iMenu == g_iShopMenu )
	{
		message_begin(MSG_ONE, g_iShowMenu, .player=id)
		{
			write_short(0)
			write_char(0)
			write_byte(0)
			write_string("")
		}
		message_end()
	}
}

public plugin_end()
{
	if( g_aItems != Invalid_Array )
	{
		ArrayDestroy( g_aItems )
	}
}

public plugin_natives()
{
	register_library("furien_shop")
	register_native("furien_register_item", "fr_register_item")
	register_native("furien_try_buy", "fr_try_buy")
}

public fr_register_item(iPlugin/*, iParams*/)
{
	CheckArrayExists()

	new mDatas[ItemDatas], szCallBack[32]

	get_string(1, mDatas[szItemFurienName], charsmax(mDatas[szItemFurienName]))
	mDatas[iItemFurienCost] = get_param(2)

	get_string(3, mDatas[szItemAntiName], charsmax(mDatas[szItemAntiName]))
	mDatas[iItemAntiCost] = get_param(4)

	get_string(5, szCallBack, charsmax(szCallBack))
	mDatas[iItemForwardIndex] = CreateOneForward(iPlugin, szCallBack, FP_CELL, FP_CELL)

	mDatas[iItemExtraArg] = get_param(6)
/*
	server_print("%s %d | %s %d | %s | %d", 
				mDatas[szItemFurienName], mDatas[iItemFurienCost], 
					mDatas[szItemAntiName], mDatas[iItemAntiCost], 
						szCallBack, mDatas[iItemExtraArg])
*/
	ArrayPushArray(g_aItems, mDatas)

	return mDatas[iItemForwardIndex]
}

public fr_try_buy(/*iPlugin, iParams*/)
{
	new id = get_param(1)
	new iCost = get_param(2)

	new iNewMoney = cs_get_user_money(id) - iCost

	if( iNewMoney < 0 )
	{
		return 0
	}

	cs_set_user_money(id, iNewMoney, 1)
	return 1
}

CheckArrayExists()
{
	if( g_aItems == Invalid_Array )
	{
		g_aItems = ArrayCreate(ItemDatas)
	}
}

public ClientCommand_Shop( id )
{
	if( !g_bSwitchTime && is_user_alive(id) )
	{
		if( !bCanBuy( id ) )
		{
			return PLUGIN_HANDLED_MAIN
		}

		g_iMenuPage[id] = 0
		ShowShopMenu(id)
		return PLUGIN_CONTINUE
	}

	return PLUGIN_HANDLED_MAIN
}

bCanBuy( id )
{
	if(	( g_iBuyType & ShouldBeInBuyZone && !cs_get_user_buyzone(id) )
	||	( g_iBuyType & ShouldBeInBuyTime && !bIsBuyTime(id) )	)
	{
		return false
	}

	return true
}

ShowShopMenu(id)
{
	new iTeam = furien_get_user_team(id)
	new iItemNums = ArraySize(g_aItems)
	new iPage = g_iMenuPage[id]
	new iPages = (iItemNums / ITEMS_PER_PAGE) + _:!!(iItemNums % ITEMS_PER_PAGE) - 1
	new iStart = ITEMS_PER_PAGE * iPage
	new iStop = min(iStart + ITEMS_PER_PAGE, iItemNums)

	new szMenu[1024], n, mDatas[ItemDatas], iKeys

	n += formatex(szMenu[n], charsmax(szMenu)-n, "\d[ \yGeek~Gamers \d] \rFurien Shop:^n\rYour Money:\y %d$\w^n^n", cs_get_user_money(id))

	new i, iCost
	for(i=iStart; i<iStop; i++)
	{
		ArrayGetArray(g_aItems, i, mDatas)
		iCost = mDatas[iTeam == Furien ? iItemFurienCost : iItemAntiCost]
		if( iCost <= 0 )
		{
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\r%d. \d%s \w^n", i+1-iStart, mDatas[iTeam == Furien ? szItemFurienName : szItemAntiName])
		}
		else
	//	if( iCost > 0 )
		{
			iKeys |= 1<<(i-iStart)
			n += formatex(szMenu[n], charsmax(szMenu)-n, "\r%d. \w%s \w- \r[\y %d$ \r]\w^n", i+1-iStart, mDatas[iTeam == Furien ? szItemFurienName : szItemAntiName], iCost)
		}
	}

	new j = iStop - iStart
	while( j++ < ITEMS_PER_PAGE )
	{
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
	}

	if( i+1-iStart == 1 )
	{
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
	}

	if( iPage > 0 )
	{
		iKeys |= 1<<7
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n\r8. \w%L", id, "BACK")
	}
	else
	{
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
	}

	if( iPages > iPage )
	{
		iKeys |= 1<<8
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n\r9. \w%L", id, "MORE")
	}
	else
	{
		n += formatex(szMenu[n], charsmax(szMenu)-n, "^n")
	}

	iKeys |= 1<<9
	n += formatex(szMenu[n], charsmax(szMenu)-n, "^n^n\r0. \w%L", id, "EXIT")

	show_menu(id, iKeys, szMenu, -1, "Furien Shop")
}

public ShopMenuAction(id, iKey)
{
	if( is_user_alive(id) )
	{
		if( !bCanBuy( id ) )
		{
			return PLUGIN_HANDLED
		}

		new iItemNums = ArraySize(g_aItems)
		new iPages = (iItemNums / ITEMS_PER_PAGE) + (iItemNums % ITEMS_PER_PAGE) - 1

		switch( iKey )
		{
			case 7:
			{
				if( --g_iMenuPage[id] < 0 )
				{
					g_iMenuPage[id] = 0
				}
				ShowShopMenu(id)
			}
			case 8:
			{
				if( ++g_iMenuPage[id] > iPages )
				{
					g_iMenuPage[id] = iPages
				}
				ShowShopMenu(id)
			}
			case 9:
			{
				return PLUGIN_HANDLED
			}
			default:
			{
				iKey += ( g_iMenuPage[id] * ITEMS_PER_PAGE )
				new mDatas[ItemDatas]
				ArrayGetArray(g_aItems, iKey, mDatas)

				new iRet
				ExecuteForward(mDatas[iItemForwardIndex], iRet, id, mDatas[iItemExtraArg])
				switch( iRet )
				{
					case ShopBought:
					{
						emit_sound(id, CHAN_ITEM, szPickAmmoSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						return PLUGIN_HANDLED
					}
					case ShopTeamNotAvail:
					{
						Util_ClientPrint
						(
							id,
							HUD_PRINTCENTER,
							"#Alias_Not_Avail",
							mDatas[ furien_get_user_team(id) == Furien ? szItemFurienName : szItemAntiName ]
						)
					}
					case ShopNotEnoughMoney:
					{
						client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money")

						message_begin(MSG_ONE_UNRELIABLE, g_iBlinkAcct, .player=id)
						{
							write_byte(2)
						}
						message_end()
					}
					case ShopAlreadyHaveOne:
					{
						client_print(id, print_center, "#Cstrike_TitlesTXT_Already_Have_One")
					}
					case ShopCantCarryAnymore:
					{
						client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore")
					}
					case ShopCannotBuyThis:
					{
						client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Buy_This")
					}
					case ShopCloseMenu:
					{
						return PLUGIN_HANDLED
					}
				}
				ShowShopMenu(id)
			}
		}
	}
	return PLUGIN_HANDLED
}

// Only submessage1 is used but fully implemented for example.
// Based on HLSDK ClientPrint and UTIL_ClientPrintAll from util.cpp
Util_ClientPrint(id, iMsgDest, szMessage[], szSubMessage1[] = "", szSubMessage2[] = "", szSubMessage3[] = "", szSubMessage4[] = "")
{
	message_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, g_iTextMsg, .player=id)
	{
		write_byte(iMsgDest)
		write_string(szMessage)
		if( szSubMessage1[0] )
		{
			write_string(szSubMessage1)
		}
		if( szSubMessage2[0] )
		{
			write_string(szSubMessage2)
		}
		if( szSubMessage3[0] )
		{
			write_string(szSubMessage3)
		}
		if( szSubMessage4[0] )
		{
			write_string(szSubMessage4)
		}
	}
	message_end()
}

////// client_print //////
// #Cstrike_TitlesTXT_Cannot_Buy_This		"You cannot buy this item!"
// #Cstrike_TitlesTXT_Cannot_Carry_Anymore	"You cannot carry anymore!"
// #Cstrike_Already_Own_Weapon			"You already own that weapon."
// #Cstrike_TitlesTXT_Weapon_Not_Available	"This weapon is not available to you!"
// #Cstrike_TitlesTXT_Not_Enough_Money		"You have insufficient funds!"
// #Cstrike_TitlesTXT_CT_cant_buy			"CTs aren't allowed to buy"
// #Cstrike_TitlesTXT_Terrorist_cant_buy	"Terrorists aren't allowed to buy anything on this map!"
// #Cstrike_TitlesTXT_VIP_cant_buy			"You are the VIP. You can't buy anything!"

////// Util_ClientPrint ///////
// #Cstrike_TitlesTXT_Alias_Not_Avail + szWeapon		"The \"%s1\"is not available for your team to buy."
// #Cstrike_TitlesTXT_Cant_buy + szSeconds			"%s1 seconds have passed. You can't buy anything now!"