#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

new const PLUGIN[] = "[GG] Furien: Knife Menu";
new const VERSION[] = "1.0";
new const AUTHOR[] = "~DarkSiDeRs~";

#pragma semicolon 1

#define VIP_FLAG ADMIN_LEVEL_H
#define GoldVIP_FLAG ADMIN_LEVEL_G
#define Owner_FLAG ADMIN_LEVEL_E

new const HaveDaedricModel[66] = "models/[GeekGamers]/Knives/v_daedric.mdl";
new const HaveDaggerModel[66] = "models/[GeekGamers]/Knives/v_dagger.mdl";
new const HaveNataModel[66] = "models/[GeekGamers]/Knives/v_nata_knife.mdl";
new const HaveKatanaModel[66] = "models/[GeekGamers]/Knives/v_katana.mdl";
new const HaveDualKatanaModel[66] = "models/[GeekGamers]/Knives/v_dual_katana.mdl";
new const HaveMonkeyModel[66] = "models/[GeekGamers]/Knives/v_knife_monkey.mdl";
new const HaveClawHammerModel[66] = "models/[GeekGamers]/Knives/v_clawhamer.mdl";

new const HaveIronKnifeModel[66] = "models/[GeekGamers]/Knives/v_iron_knife.mdl";
new const HaveBloodyKatanaModel[66] = "models/[GeekGamers]/Knives/v_bloody_katana.mdl";
new const HaveGhorsAxeModel[66] = "models/[GeekGamers]/Knives/v_ghors_axe.mdl";

new const HaveKnifeChameleonModel[66] = "models/[GeekGamers]/Knives/v_chameleon_knife.mdl";
new const HaveSuperKatanaModel[66] = "models/[GeekGamers]/Knives/v_super_katana.mdl";
new const HaveShadowAxeModel[66] = "models/[GeekGamers]/Knives/v_shadow_axe.mdl";

new const HaveDarkSidersModel[66] = "models/[GeekGamers]/Knives/v_knife_DarkSiDeRs.mdl";
new const HaveOussamaModel[66] = "models/[GeekGamers]/Knives/v_knife_Oussama.mdl";

new bool: HaveDaedric[33];
new bool: HaveDagger[33];
new bool: HaveNata[33];
new bool: HaveKatana[33];
new bool: HaveDualKatana[33];
new bool: HaveMonkey[33];
new bool: HaveClawHammer[33];

new bool: HaveIronKnife[33];
new bool: HaveBloodyKatana[33];
new bool: HaveGhorsAxe[33];

new bool: HaveKnifeChameleon[33];
new bool: HaveSuperKatana[33];
new bool: HaveShadowAxe[33];

new bool: HaveDarkSiders[33];
new bool: HaveOussama[33];

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
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "DamageArme");
}

public Spawn(id)
{
	if(is_user_alive(id))
	{
		give_item(id, "weapon_knife");
		HaveKnifeChoosen[id] = false;
		
                HaveDaedric[id] = false;
                HaveDagger[id] = false;
                HaveNata[id] = false;
                HaveKatana[id] = false;
                HaveDualKatana[id] = false;
                HaveMonkey[id] = false;
                HaveClawHammer[id] = false;

                HaveIronKnife[id] = false;
                HaveBloodyKatana[id] = false;
                HaveGhorsAxe[id] = false;

                HaveKnifeChameleon[id] = false;
                HaveSuperKatana[id] = false;
                HaveShadowAxe[id] = false;

                HaveDarkSiders[id] = false;
                HaveOussama[id] = false;
		
		if(cs_get_user_team(id) == CS_TEAM_T)
			ShowMenuKnife(id);
	}
}

public plugin_precache()
{
        precache_model(HaveDaedricModel);
        precache_model(HaveDaggerModel);
        precache_model(HaveNataModel);
        precache_model(HaveKatanaModel);
        precache_model(HaveDualKatanaModel);
        precache_model(HaveMonkeyModel);
        precache_model(HaveClawHammerModel);

        precache_model(HaveIronKnifeModel);
        precache_model(HaveBloodyKatanaModel);
        precache_model(HaveGhorsAxeModel);

        precache_model(HaveKnifeChameleonModel);
        precache_model(HaveSuperKatanaModel);
        precache_model(HaveShadowAxeModel);

        precache_model(HaveDarkSidersModel);
        precache_model(HaveOussamaModel);
}

public client_disconnect(id)
{
        HaveDaedric[id] = false;
        HaveDagger[id] = false;
        HaveNata[id] = false;
        HaveKatana[id] = false;
        HaveDualKatana[id] = false;
        HaveMonkey[id] = false;
        HaveClawHammer[id] = false;

        HaveIronKnife[id] = false;
        HaveBloodyKatana[id] = false;
        HaveGhorsAxe[id] = false;

        HaveKnifeChameleon[id] = false;
        HaveSuperKatana[id] = false;
        HaveShadowAxe[id] = false;

        HaveDarkSiders[id] = false;
        HaveOussama[id] = false;
}

public ShowMenuKnife(id)
{
	new menu = menu_create ("\d[\yGeek~Gamers\d] \rFurien \yKnife Menu:", "CaseMenu");
	
	menu_additem(menu, "\wAssassin's Knife^n", "1");
	if(get_user_flags(id) & VIP_FLAG)
		menu_additem(menu, "\yUltimate Knife \r(Only Silver V.I.P)", "2");
		else
		menu_additem(menu, "\dUltimate Knife \r(Only Silver V.I.P)", "2");
	if(get_user_flags(id) & GoldVIP_FLAG)
		menu_additem(menu, "\yDanger Knife \r(Only Gold V.I.P)", "3");
		else
		menu_additem(menu, "\dDanger Knife \r(Only Gold V.I.P)", "3");
	if(get_user_flags(id) & Owner_FLAG)
        	menu_additem(menu, "\yHyper Knife \r(Only Owners)", "4");
		else
        	menu_additem(menu, "\dHyper Knife \r(Only Owners)", "4");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
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
			{
				MenuPlayeri(id);
			}
		}
		
		case 2:
		{
			if( get_user_flags( id ) & VIP_FLAG )
				{
				MenuVIP(id);
			}
			
			else
			{
				ChatColor(id, "!g[GG] !nThis Knifes is Reserved Only For !gSilver V.I.P");
				ShowMenuKnife(id);
			}
		}
		
		case 3:
		{
			if( get_user_flags( id ) & GoldVIP_FLAG )
				{
				MenuGoldVIP(id);
			}
			
			else
			{
				ChatColor(id, "!g[GG] !nThis Knifes is Reserved Only For !gGold V.I.P");
				ShowMenuKnife(id);
			}
		}
		
		case 4:
		{
			if( get_user_flags( id ) & Owner_FLAG )
				{
				MenuOwner(id);
			}
			
			else
			{
				ChatColor(id, "!g[GG] !nThis Knifes is Reserved Only For !gOwners");
				ShowMenuKnife(id);
			}
		}
	}
	
	menu_destroy (menu);
	return 1;
}
public MenuPlayeri(id)
{
	new menu = menu_create ("\r[GG] \yAssassin's \rKnife Menu:", "CaseArmePlayeri");
	
        menu_additem(menu, "Daedric", "1");
        menu_additem(menu, "Dagger", "2");
        menu_additem(menu, "Nata Knife", "3");
        menu_additem(menu, "Katana", "4");
        menu_additem(menu, "Dual Katana", "5");
        menu_additem(menu, "Knife Monkey", "6");
        menu_additem(menu, "Claw Hammer", "7");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
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
			HaveDaedric[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDaedric");
		}
		case 2:
		{
			HaveKnifeChoosen[id] = true;
			HaveDagger[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDagger");
		}
		case 3:
		{
			HaveKnifeChoosen[id] = true;
			HaveNata[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tNata Knife");
		}
		case 4:
		{
			HaveKnifeChoosen[id] = true;
			HaveKatana[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tKatana");
		}
		case 5:
		{
			HaveKnifeChoosen[id] = true;
			HaveDualKatana[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tDual Katana");
		}
		case 6:
		{
			HaveKnifeChoosen[id] = true;
			HaveMonkey[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tKnife Monkey");
		}
		case 7:
		{
			HaveKnifeChoosen[id] = true;
			HaveClawHammer[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tClaw Hammer");
		}
		
	}
	
	menu_destroy (menu);
	return 1;
}


public MenuVIP(id)
{
	new menu = menu_create ("\r[GG] \yFurien \wSilver V.I.P \rKnife Menu:", "CaseArmeVIP");
	
        menu_additem(menu, "Iron Knife", "1");
        menu_additem(menu, "Bloody Katana", "2");
        menu_additem(menu, "Ghors Axe", "3");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
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
		case 1:
		{
			HaveKnifeChoosen[id] = true;
			HaveIronKnife[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tIron Knife");
		}
		case 2:
		{
			HaveKnifeChoosen[id] = true;
			HaveBloodyKatana[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tBloody Katana");
		}
		case 3:
		{
			HaveKnifeChoosen[id] = true;
			HaveGhorsAxe[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tGhors Axe");
		}
		
		
	}
	
	menu_destroy (menu);
	return 1;
}


public MenuGoldVIP(id)
{
	new menu = menu_create ("\r[GG] \yFurien \wGold V.I.P \rKnife Menu:", "CaseArmeGoldVIP");
	
        menu_additem(menu, "Knife Chameleon", "1");
        menu_additem(menu, "Super Katana", "2");
        menu_additem(menu, "Shadow Axe", "3");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0 );
	
	return 1; 
}

public CaseArmeGoldVIP(id, menu, item)
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
			HaveKnifeChameleon[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tKnife Chameleon");
		}
		case 2:
		{
			HaveKnifeChoosen[id] = true;
			HaveSuperKatana[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tSuper Katana");
		}
		case 3:
		{
			HaveKnifeChoosen[id] = true;
			HaveShadowAxe[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose the !tShadow Axe");
		}
		
		
	}
	
	menu_destroy (menu);
	return 1;
}


public MenuOwner(id)
{
	new menu = menu_create ("\r[GG] \yFurien \wOwner \rKnife Menu:", "CaseArmeOwner");
	
        menu_additem(menu, "~DarkSiDeRs~", "1");
        menu_additem(menu, "Ou$$ama", "2");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0 );
	
	return 1; 
}

public CaseArmeOwner(id, menu, item)
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
			HaveDarkSiders[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose !t~DarkSiDeRs~ !nKnife");
		}
		case 2:
		{
			HaveKnifeChoosen[id] = true;
			HaveOussama[id] = true;
			CurentWeapon(id);
			ChatColor(id, "!g[GG] !nYou choose !tOu$$ama !nKnife");
		}
		
		
	}
	
	menu_destroy (menu);
	return 1;
}

public CurentWeapon(id)
{
	if(HaveDaedric[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveDaedricModel);

   	if(HaveDagger[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveDaggerModel);
   
   	if(HaveNata[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveNataModel);
   
   	if(HaveKatana[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveKatanaModel);
   
   	if(HaveDualKatana[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveDualKatanaModel);
   
   	if(HaveMonkey[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveMonkeyModel);
   
   	if(HaveClawHammer[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveClawHammerModel);
   
   	if(HaveIronKnife[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveIronKnifeModel);
   
   	if(HaveBloodyKatana[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveBloodyKatanaModel);
   
   	if(HaveGhorsAxe[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveGhorsAxeModel);
   
   	if(HaveKnifeChameleon[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveKnifeChameleonModel);
   
   	if(HaveSuperKatana[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveSuperKatanaModel);
   
   	if(HaveShadowAxe[id] && get_user_weapon(id) == CSW_KNIFE)
      	set_pev(id, pev_viewmodel2, HaveShadowAxeModel);

        if(HaveDarkSiders[id] && get_user_weapon(id) == CSW_KNIFE)
        set_pev(id, pev_viewmodel2, HaveDarkSidersModel);
   
   	if(HaveOussama[id] && get_user_weapon(id) == CSW_KNIFE)
        set_pev(id, pev_viewmodel2, HaveOussamaModel);
}

public DamageArme (iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
   if(iInflictor == iAttacker && HaveDaedric[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveDagger[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveNata[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveKatana[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveDualKatana[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveMonkey[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveClawHammer[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.0);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveIronKnife[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.3);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveBloodyKatana[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.3);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveGhorsAxe[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.3);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveKnifeChameleon[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.6);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveSuperKatana[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.6);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveShadowAxe[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.6);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveDarkSiders[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.8);
      return HAM_HANDLED;
   }
   
   if(iInflictor == iAttacker && HaveOussama[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_T)
   {
      SetHamParamFloat(4, fDamage * 1.8);
      return HAM_HANDLED;
   }

   if(iInflictor == iAttacker && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_SPECTATOR)
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
		ShowMenuKnife(id);
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