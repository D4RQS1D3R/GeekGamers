#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <fcs>

#pragma compress 1

new const PLUGIN[] = "[GG] Furien: Knife Menu";
new const VERSION[] = "3.0";
new const AUTHOR[] = "~D4rkSiD3Rs~";

native bool: FreeVIP(id);
native bool: random_knife(id);
native bool: dont_show_knifemenu(id);

#pragma semicolon 1

#define VIP_FLAG ADMIN_LEVEL_H
#define SILVERVIP_FLAG ADMIN_LEVEL_F
#define GOLDVIP_FLAG ADMIN_LEVEL_E

new const Knife1Model[66] = "models/[GeekGamers]/Knives/v_eagle_knife.mdl";
new const Knife2Model[66] = "models/[GeekGamers]/Knives/v_daedric.mdl";
new const Knife3Model[66] = "models/[GeekGamers]/Knives/v_dagger.mdl";
new const Knife4Model[66] = "models/[GeekGamers]/Knives/v_hunter_knife.mdl";
new const Knife5Model[66] = "models/[GeekGamers]/Knives/v_katana_v2.mdl";
new const Knife6Model[66] = "models/[GeekGamers]/Knives/v_dual_katana.mdl";
new const Knife7Model[66] = "models/[GeekGamers]/Knives/v_ruyi_stick.mdl";

new const KnifeVIP1Model[66] = "models/[GeekGamers]/Knives/v_horse_axe.mdl";
new const KnifeVIP2Model[66] = "models/[GeekGamers]/Knives/v_katana_pheonix.mdl";

new const KnifeSilverVIP1Model[66] = "models/[GeekGamers]/Knives/v_iron_knife.mdl";
new const KnifeSilverVIP2Model[66] = "models/[GeekGamers]/Knives/v_golden_thanatos.mdl";

new const KnifeGoldVIP1Model[66] = "models/[GeekGamers]/Knives/v_chameleon_knife.mdl";
new const KnifeGoldVIP2Model[66] = "models/[GeekGamers]/Knives/v_fire_katana_new.mdl";

new const KnifeCredits1Model[66] = "models/[GeekGamers]/Knives/v_night_crawler_v2.mdl";
new const KnifeCredits2Model[66] = "models/[GeekGamers]/Knives/v_bloody_katana.mdl";
new const KnifeCredits3Model[66] = "models/[GeekGamers]/Knives/v_balrog_kosa_v2.mdl";

new bool: HaveKnife1[33];
new bool: HaveKnife2[33];
new bool: HaveKnife3[33];
new bool: HaveKnife4[33];
new bool: HaveKnife5[33];
new bool: HaveKnife6[33];
new bool: HaveKnife7[33];

new bool: HaveKnifeVIP1[33];
new bool: HaveKnifeVIP2[33];

new bool: HaveKnifeSilverVIP1[33];
new bool: HaveKnifeSilverVIP2[33];

new bool: HaveKnifeGoldVIP1[33];
new bool: HaveKnifeGoldVIP2[33];

new bool: HaveKnifeCredits1[33];
new bool: HaveKnifeCredits2[33];
new bool: HaveKnifeCredits3[33];

new bool: HaveKnifeChoosen[33];

public plugin_natives()
{
	register_native("MenuKnife", "ShowMenuKnife", 1);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say /knife","SayArme");
	register_clcmd("say knife","SayArme");
	register_clcmd("knife","SayArme");
	
	register_event("CurWeapon", "CurentWeapon", "be", "1=1");
	register_event("DeathMsg", "EventDeath", "a");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "DamageArme");	
}

public plugin_precache()
{
	precache_model(Knife1Model);
	precache_model(Knife2Model);
	precache_model(Knife3Model);
	precache_model(Knife4Model);
	precache_model(Knife5Model);
	precache_model(Knife6Model);
	precache_model(Knife7Model);

	precache_model(KnifeVIP1Model);
	precache_model(KnifeVIP2Model);

	precache_model(KnifeSilverVIP1Model);
	precache_model(KnifeSilverVIP2Model);

	precache_model(KnifeGoldVIP1Model);
	precache_model(KnifeGoldVIP2Model);

	precache_model(KnifeCredits1Model);
	precache_model(KnifeCredits2Model);
	precache_model(KnifeCredits3Model);
}

public EventDeath()
{
	new victim = read_data(2);

	HaveKnifeCredits1[victim] = false;
	HaveKnifeCredits2[victim] = false;
	HaveKnifeCredits3[victim] = false;
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;

	give_item(id, "weapon_knife");

	if(HaveKnifeCredits1[id] || HaveKnifeCredits2[id] || HaveKnifeCredits3[id])
		return;

	HaveKnifeChoosen[id] = false;

	HaveKnife1[id] = false;
	HaveKnife2[id] = false;
	HaveKnife3[id] = false;
	HaveKnife4[id] = false;
	HaveKnife5[id] = false;
	HaveKnife6[id] = false;
	HaveKnife7[id] = false;

	HaveKnifeVIP1[id] = false;
	HaveKnifeVIP2[id] = false;

	HaveKnifeSilverVIP1[id] = false;
	HaveKnifeSilverVIP2[id] = false;

	HaveKnifeGoldVIP1[id] = false;
	HaveKnifeGoldVIP2[id] = false;

	HaveKnifeCredits1[id] = false;
	HaveKnifeCredits2[id] = false;
	HaveKnifeCredits3[id] = false;

	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if( random_knife(id) )
		{
			switch( random_num(1,9) )
			{
				case 1: HaveKnifeVIP1[id] = true;
				case 2: HaveKnifeVIP2[id] = true;
				case 3: HaveKnifeSilverVIP1[id] = true;
				case 4: HaveKnifeSilverVIP2[id] = true;
				case 5: HaveKnifeGoldVIP1[id] = true;
				case 6: HaveKnifeGoldVIP2[id] = true;
				case 7: HaveKnifeCredits1[id] = true;
				case 8: HaveKnifeCredits2[id] = true;
				case 9: HaveKnifeCredits3[id] = true;
			}

			HaveKnifeChoosen[id] = true;
			return;
		}

		ShowMenuKnife(id);
	}

	new ip[32];
	get_user_ip(id, ip, 31);

	if( equali(ip, "127.0.0.1") && cs_get_user_team(id) == CS_TEAM_T )
	{
		if( dont_show_knifemenu(id) )
			return;
		
		switch( random_num(1,12) )
		{
			case 1: HaveKnife1[id] = true;
			case 2: HaveKnife2[id] = true;
			case 3: HaveKnife3[id] = true;
			case 4: HaveKnife4[id] = true;
			case 5: HaveKnife5[id] = true;
			case 6: HaveKnife6[id] = true;
			case 7: HaveKnife7[id] = true;
			case 8:
			{
				if(FreeVIP(id))
					HaveKnifeVIP1[id] = true;
				else Spawn(id);
			}
			case 9:
			{
				if(FreeVIP(id))
					HaveKnifeVIP2[id] = true;
				else Spawn(id);
			}
			case 10: HaveKnifeCredits1[id] = true;
			case 11: HaveKnifeCredits2[id] = true;
			case 12: HaveKnifeCredits3[id] = true;
		}
	}
}

public ShowMenuKnife(id)
{
	if( dont_show_knifemenu(id) )
		return PLUGIN_HANDLED;

	new temp[101];
	new iCredits = fcs_get_user_credits( id );
	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rFurien \yKnife Menu^n\rYour Credits:\y %d", iCredits );
	new menu = menu_create(temp, "CaseMenu");
	
	menu_additem(menu, "\wAssassin's Knife", "1");
	if( get_user_flags(id) & VIP_FLAG )
		menu_additem(menu, "\yUltimate Knife \r(Only V.I.P)^n", "2");
	else	menu_additem(menu, "\dUltimate Knife \r(Only V.I.P)^n", "2");

	if( iCredits < 35 )
		menu_additem(menu, "\yNight \rCrawler \d- No Credits", "3", 0);
	else	menu_additem(menu, "\yNight \rCrawler \y(70 Damage) \d- \w[ \y35 Credits \w]", "3", 0);

	if( iCredits < 45 )
		menu_additem(menu, "\yBloody \rKatana \d- No Credits", "4", 0);
	else	menu_additem(menu, "\yBloody \rKatana \y(75 Damage) \d- \w[ \y45 Credits \w]", "4", 0);

	if( iCredits < 55 )
		menu_additem(menu, "\yBalrog \rKosa \d- No Credits", "5", 0);
	else	menu_additem(menu, "\yBalrog \rKosa \y(80 Damage) \d- \w[ \y55 Credits \w]", "5", 0);

	menu_display(id, menu, 0 );

	return 1;
}

public CaseMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		return 1;
	}
	
	new data [6], szName [64];
	new access, callback;
	menu_item_getinfo (menu, item, access, data,charsmax (data), szName,charsmax (szName), callback);
	new key = str_to_num (data);
	
	switch (key)
	{
		case 1:
		{
			MenuPlayeri(id);
		}
		case 2:
		{
			if( get_user_flags( id ) & VIP_FLAG )
			{
				MenuVIP(id);
			}
			else
			{
				ChatColor(id, "!g[GG] !nThese Knives are Reserved Only For !gV.I.P");
				MenuVIP(id);
			}
		}
		case 3:
		{
			if(!is_user_alive(id))
			{
				ChatColor(id, "!g[GG] !nYou can't choose the knife when you're dead");
				return 1;
			}

			new iCredits = fcs_get_user_credits(id) - 35;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG] !nYou don't Have enough !tCredits.");
				ShowMenuKnife(id);
			}
			else
			{
				fcs_set_user_credits( id, iCredits );
				HaveKnifeChoosen[id] = true;
				HaveKnifeCredits1[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou've bought the !tNight Crawler");
			}
		}
		case 4:
		{
			if(!is_user_alive(id))
			{
				ChatColor(id, "!g[GG] !nYou can't choose the knife when you're dead");
				return 1;
			}

			new iCredits = fcs_get_user_credits(id) - 45;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuKnife(id);
			}
			else
			{
				fcs_set_user_credits( id, iCredits );
				HaveKnifeChoosen[id] = true;
				HaveKnifeCredits2[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou've bought the !tBloody Katana");
			}
		}
		case 5:
		{
			if(!is_user_alive(id))
			{
				ChatColor(id, "!g[GG] !nYou can't choose the knife when you're dead");
				return 1;
			}

			new iCredits = fcs_get_user_credits(id) - 55;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG] !nYou don't Have enough !tCredits.");
				ShowMenuKnife(id);
			}
			else
			{
				fcs_set_user_credits( id, iCredits );
				HaveKnifeChoosen[id] = true;
				HaveKnifeCredits3[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou've bought the !tBalrog Kosa");
			}
		}
	}
	menu_destroy (menu);
	return 1;
}

public MenuPlayeri(id)
{
	new menu = menu_create ("\r[GG] \yAssassin's \rKnife Menu:", "CaseArmePlayeri");
	
	menu_additem(menu, "Eagle Knife", "1");
	menu_additem(menu, "Daedric", "2");
	menu_additem(menu, "Dagger", "3");
	menu_additem(menu, "Hunter Knife", "4");
	menu_additem(menu, "Katana", "5");
	menu_additem(menu, "Dual Katana", "6");
	menu_additem(menu, "Ruyi Stick", "7");
	
	menu_display(id, menu, 0 );
	
	return 1;
}

public CaseArmePlayeri(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		return 1;
	}

	if(!is_user_alive(id))
	{
		ChatColor(id, "!g[GG] !nYou can't choose the knife when you're dead");
		return 1;
	}
	
	new data [6], szName [64];
	new access, callback;
	menu_item_getinfo (menu, item, access, data,charsmax (data), szName,charsmax (szName), callback);
	new key = str_to_num (data);
	
	switch (key)
	{
		case 1:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife1[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tEagle Knife");
		}
		case 2:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife2[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDaedric");
		}
		case 3:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife3[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDagger");
		}
		case 4:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife4[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tHunter Knife");
		}
		case 5:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife5[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tKatana");
		}
		case 6:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife6[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDual Katana");
		}
		case 7:
		{
			HaveKnifeChoosen[id] = true;
			HaveKnife7[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tRuyi Stick");
		}
	}
	
	menu_destroy (menu);
	return 1;
}

public MenuVIP(id)
{
	new menu = menu_create ("\r[GG] \yFurien \wV.I.P \rKnife Menu:", "CaseArmeVIP");
	
	if( get_user_flags(id) & VIP_FLAG )
	{
		menu_additem(menu, "Horse Axe \y(75 Damage)", "1");
		menu_additem(menu, "Pheonix Katana \y(75 Damage)^n", "2");
	}
	else
	{
		menu_additem(menu, "\dHorse Axe \r(Only V.I.P)", "1");
		menu_additem(menu, "\dPheonix Katana \r(Only V.I.P)^n", "2");
	}

	if(get_user_flags(id) & SILVERVIP_FLAG)
	{
		menu_additem(menu, "Iron Knife \y(85 Damage)", "3");
		menu_additem(menu, "Golden Thanatos \y(85 Damage)^n", "4");
	}
	else
	{
		menu_additem(menu, "\dIron Knife \r(Only Silver V.I.P)", "3");
		menu_additem(menu, "\dGolden Thanatos \r(Only Silver V.I.P)^n", "4");
	}

	if(get_user_flags(id) & GOLDVIP_FLAG)
	{
		menu_additem(menu, "Knife Chameleon \y(100 Damage)", "5");
		menu_additem(menu, "Fire Katana \y(100 Damage)", "6");
	}
	else
	{
		menu_additem(menu, "\dKnife Chameleon \r(Only Gold V.I.P)", "5");
		menu_additem(menu, "\dFire Katana \r(Only Gold V.I.P)", "6");
	}
	
	menu_display(id, menu, 0 );
	
	return 1;
}

public CaseArmeVIP(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		return 1;
	}

	if(!is_user_alive(id))
	{
		ChatColor(id, "!g[GG] !nYou can't choose the knife when you're dead");
		return 1;
	}
	
	new data [6], szName [64];
	new access, callback;
	menu_item_getinfo (menu, item, access, data,charsmax (data), szName,charsmax (szName), callback);
	new key = str_to_num (data);
	
	switch (key)
	{
		case 0: ShowMenuKnife(id);
		case 1:
		{
			if( get_user_flags(id) & VIP_FLAG )
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeVIP1[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tHorse Axe");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gV.I.P");
			}
		}
		case 2:
		{
			if( get_user_flags(id) & VIP_FLAG )
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeVIP2[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tPheonix Katana");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gV.I.P");
			}
		}
		case 3:
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeSilverVIP1[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tIron Knife");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gSilver V.I.P");
			}
		}
		case 4:
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeSilverVIP2[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tGolden Thanatos");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gSilver V.I.P");
			}
		}
		case 5:
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeGoldVIP1[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tKnife Chameleon");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gGold V.I.P");
			}
		}
		case 6:
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				HaveKnifeChoosen[id] = true;
				HaveKnifeGoldVIP2[id] = true;
				CurentWeapon(id);
				ChatColor(id, "!g[GG] !nYou choose the !tFire Katana");
			}
			else
			{
				ShowMenuKnife(id);
				ChatColor(id, "!g[GG] !nThis Knife is Reserved Only For !gGold V.I.P");
			}
		}
	}
	
	menu_destroy (menu);
	return 1;
}

public CurentWeapon(id)
{
	if(get_user_weapon(id) == CSW_KNIFE && cs_get_user_team(id) == CS_TEAM_T)
	{
		if(HaveKnife1[id])
			set_pev(id, pev_viewmodel2, Knife1Model);

	   	if(HaveKnife2[id])
			set_pev(id, pev_viewmodel2, Knife2Model);

	   	if(HaveKnife3[id])
			set_pev(id, pev_viewmodel2, Knife3Model);

	   	if(HaveKnife4[id])
			set_pev(id, pev_viewmodel2, Knife4Model);

	   	if(HaveKnife5[id])
			set_pev(id, pev_viewmodel2, Knife5Model);

	   	if(HaveKnife6[id])
			set_pev(id, pev_viewmodel2, Knife6Model);

	   	if(HaveKnife7[id])
			set_pev(id, pev_viewmodel2, Knife7Model);

	   	if(HaveKnifeVIP1[id])
			set_pev(id, pev_viewmodel2, KnifeVIP1Model);

	   	if(HaveKnifeVIP2[id])
			set_pev(id, pev_viewmodel2, KnifeVIP2Model);

	   	if(HaveKnifeSilverVIP1[id])
			set_pev(id, pev_viewmodel2, KnifeSilverVIP1Model);

	   	if(HaveKnifeSilverVIP2[id])
			set_pev(id, pev_viewmodel2, KnifeSilverVIP2Model);

	   	if(HaveKnifeGoldVIP1[id])
			set_pev(id, pev_viewmodel2, KnifeGoldVIP1Model);

	   	if(HaveKnifeGoldVIP2[id])
			set_pev(id, pev_viewmodel2, KnifeGoldVIP2Model);

	   	if(HaveKnifeCredits1[id])
			set_pev(id, pev_viewmodel2, KnifeCredits1Model);

	   	if(HaveKnifeCredits2[id])
			set_pev(id, pev_viewmodel2, KnifeCredits2Model);

	   	if(HaveKnifeCredits3[id])
			set_pev(id, pev_viewmodel2, KnifeCredits3Model);
	}
}

public DamageArme(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(iInflictor == iAttacker && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
	{
		if(HaveKnifeVIP1[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.153846153846154);
			return HAM_HANDLED;
		}

		if(HaveKnifeVIP2[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.153846153846154);
			return HAM_HANDLED;
		}
   
		if(HaveKnifeSilverVIP1[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.307692307692308);
			return HAM_HANDLED;
		}

		if(HaveKnifeSilverVIP2[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.307692307692308);
			return HAM_HANDLED;
		}

		if(HaveKnifeGoldVIP1[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.538461538461538);
			return HAM_HANDLED;
		}

		if(HaveKnifeGoldVIP2[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.538461538461538);
			return HAM_HANDLED;
		}

		if(HaveKnifeCredits1[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.076923076923077);
			return HAM_HANDLED;
		}

		if(HaveKnifeCredits2[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.153846153846154);
			return HAM_HANDLED;
		}

		if(HaveKnifeCredits3[iAttacker])
		{
			SetHamParamFloat(4, fDamage * 1.230769230769231);
			return HAM_HANDLED;
		}
	}

	if(is_user_alive(iAttacker) && cs_get_user_team(iAttacker) == CS_TEAM_SPECTATOR)
	{
		SetHamParamFloat(4, fDamage * 0.0);
		return HAM_HANDLED;
	}

	return HAM_IGNORED;
}

public SayArme(id)
{
	if(HaveKnifeChoosen[id]) 
	{
		ChatColor(id, "!g[GG] !nYou have already choosen a knife in this round");
		return;
	}
	
	if(cs_get_user_team(id) == CS_TEAM_T) 
	{
		if( dont_show_knifemenu(id) ) ChatColor(id, "!g[GG] !nYou can't Open The Knife Menu in The Current !tMod !n!");
		else ShowMenuKnife(id);
	}
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4"); // Verde
	replace_all(msg, 190, "!n", "^1"); // Galben
	replace_all(msg, 190, "!t", "^3"); // CT-Albastru ; T-Rosu
	replace_all(msg, 190, "!t2", "^0"); // CT-Albastru2 ; T-Rosu2
	
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
