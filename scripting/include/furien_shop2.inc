#if defined _furien_shop
	#endinput
#endif
#define _furien_shop

#pragma reqlib furien_shop

#include <cstrike>

enum _:ShopReturns {
	ShopBought,
	ShopTeamNotAvail,
	ShopAlreadyHaveOne,
	ShopCantCarryAnymore,
	ShopNotEnoughMoney,
	ShopCannotBuyThis,
	ShopShowMenuAgain,
	ShopCloseMenu
}

native furien_register_item(szFurienName[32], iFurienCost=0, szAntiName[32], iAntiCost=0, szCallBack[32] = "furien_buy_item", iExtra = 0);

stock furien_try_buy(id, iCost)
{
	new iNewMoney = cs_get_user_money(id) - iCost;

	if( iNewMoney < 0 )
	{
		return 0;
	}

	cs_set_user_money(id, iNewMoney, 1);
	return 1;
}