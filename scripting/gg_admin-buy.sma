/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Buy Admin"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd( "say buy","VIP1" );
	register_clcmd( "say /buy","VIP1" );
	register_clcmd( "say price","VIP1" );
	register_clcmd( "say /price","VIP1" );
	register_clcmd( "say prices","VIP1" );
	register_clcmd( "say /prices","VIP1" );
}

public VIP1( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_vip1" );

	menu_additem( menu, "\yAccess: \d[ \rV.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r1 Month \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r1EUR \r/ 10Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_vip1( id, menu, item )
{
	switch( item )
	{
		case 0: Silver1(id);
		case 1: VIP2(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public VIP2( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_vip2" );

	menu_additem( menu, "\yAccess: \d[ \rV.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r3 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r3EUR \r/ 30Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_vip2( id, menu, item )
{
	switch( item )
	{
		case 0: Silver1(id);
		case 1: VIP3(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public VIP3( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_vip3" );

	menu_additem( menu, "\yAccess: \d[ \rV.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r6 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r6EUR \r/ 60Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_vip3( id, menu, item )
{
	switch( item )
	{
		case 0: Silver1(id);
		case 1: VIP4(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public VIP4( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_vip4" );

	menu_additem( menu, "\yAccess: \d[ \rV.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r12 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r10EUR \r/ 100Dh \y(-16%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_vip4( id, menu, item )
{
	switch( item )
	{
		case 0: Silver1(id);
		case 1: VIP1(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Silver1( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_silver1" );

	menu_additem( menu, "\yAccess: \d[ \rSilver V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r1 Month \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r2EUR \r/ 20Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_silver1( id, menu, item )
{
	switch( item )
	{
		case 0: Gold1(id);
		case 1: Silver2(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Silver2( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_silver2" );

	menu_additem( menu, "\yAccess: \d[ \rSilver V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r3 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r6EUR \r/ 60Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_silver2( id, menu, item )
{
	switch( item )
	{
		case 0: Gold1(id);
		case 1: Silver3(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Silver3( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_silver3" );

	menu_additem( menu, "\yAccess: \d[ \rSilver V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r6 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r12EUR \r/ 120Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_silver3( id, menu, item )
{
	switch( item )
	{
		case 0: Gold1(id);
		case 1: Silver4(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Silver4( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_silver4" );

	menu_additem( menu, "\yAccess: \d[ \rSilver V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r12 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r20EUR \r/ 200Dh \y(-16%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_silver4( id, menu, item )
{
	switch( item )
	{
		case 0: Gold1(id);
		case 1: Silver1(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Gold1( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_gold1" );

	menu_additem( menu, "\yAccess: \d[ \rGold V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r1 Month \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r4EUR \r/ 40Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_gold1( id, menu, item )
{
	switch( item )
	{
		case 0: Diamond1(id);
		case 1: Gold2(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Gold2( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_gold2" );

	menu_additem( menu, "\yAccess: \d[ \rGold V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r3 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r12EUR \r/ 120Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_gold2( id, menu, item )
{
	switch( item )
	{
		case 0: Diamond1(id);
		case 1: Gold3(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Gold3( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_gold3" );

	menu_additem( menu, "\yAccess: \d[ \rGold V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r6 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r22EUR \r/ 220Dh \y(-8%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_gold3( id, menu, item )
{
	switch( item )
	{
		case 0: Diamond1(id);
		case 1: Gold4(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Gold4( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_gold4" );

	menu_additem( menu, "\yAccess: \d[ \rGold V.I.P \y+ \r5k Credits \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r12 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r40EUR \r/ 400Dh \y(-16%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_gold4( id, menu, item )
{
	switch( item )
	{
		case 0: Diamond1(id);
		case 1: Gold1(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Diamond1( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_diamond1" );

	menu_additem( menu, "\yAccess: \d[ \rDiamond V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r1 Month \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r6EUR \r/ 60Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_diamond1( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Diamond2(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Diamond2( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_diamond2" );

	menu_additem( menu, "\yAccess: \d[ \rDiamond V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r3 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r18EUR \r/ 180Dh \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_diamond2( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Diamond3(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Diamond3( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_diamond3" );

	menu_additem( menu, "\yAccess: \d[ \rDiamond V.I.P \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r6 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r33EUR \r/ 330Dh \y(-8%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_diamond3( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Diamond4(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Diamond4( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_diamond4" );

	menu_additem( menu, "\yAccess: \d[ \rDiamond V.I.P \y+ \r10k Credits \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r12 Months \d]", "", 0 );
	menu_addtext( menu, "\yPrice: \d[ \r60EUR \r/ 600Dh \y(-16%) \d]^n");
	menu_addtext( menu, "\rPayment Methode: \d[ \yPayPal \r/ \yBank Transfer \r/ \yRecharge Orange \d]");
	menu_addtext( menu, "\rE-Mail: \d[ \ycontact@geek-gamers.com \d]");
	menu_addtext( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_diamond4( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Diamond1(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/*
public Owner1( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_owner1" );

	menu_additem( menu, "\yAccess: \d[ \rCo-Owner \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r1 Month \d]", "", 0 );
	menu_additem( menu, "\rPrice: \d[ \y50Dh / 5EUR \d]", "", 0);
	menu_additem( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_owner1( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Owner2(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Owner2( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_owner2" );

	menu_additem( menu, "\yAccess: \d[ \rCo-Owner \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r2 Months \d]", "", 0 );
	menu_additem( menu, "\rPrice: \d[ \y100Dh / 10EUR \d]", "", 0);
	menu_additem( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_owner2( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Owner3(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Owner3( id )
{
	new menu = menu_create( "\d[\yGeek~Gamers\d] \rChoose Your Access and Duration", "menu_owner3" );

	menu_additem( menu, "\yAccess: \d[ \rCo-Owner \y+ \r20 Level \d]", "", 0 );
	menu_additem( menu, "\yDuration: \d[ \r3 Months \d]", "", 0 );
	menu_additem( menu, "\rPrice: \d[ \y130Dh / 13EUR \d]", "", 0);
	menu_additem( menu, "\rFacebook: \d[ \yfacebook.com/GeekGamersPage \d]");
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
}

public menu_owner3( id, menu, item )
{
	switch( item )
	{
		case 0: VIP1(id);
		case 1: Owner1(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
*/