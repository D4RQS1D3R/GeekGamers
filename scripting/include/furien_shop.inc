#if defined _furien_shop
	#endinput
#endif
#define _furien_shop

#pragma reqlib furien_shop

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
native furien_try_buy(id, iCost);