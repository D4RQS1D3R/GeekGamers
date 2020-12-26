#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <newmenus>
#include <fcs>

#pragma compress 1
#pragma semicolon 1

new const PLUGIN[] = "[GG] Furien Weapons menu";
new const VERSION[] = "2.1.3";
new const AUTHOR[] = "D4RQS1D3R";

native gg_set_user_gatling(id);
native gg_set_user_k1ases(id);
native gg_set_user_m4a1darkknight(id);
native gg_set_user_m3bd(id);
native gg_set_user_crossbow(id);

native gg_set_user_goldak47(id);
native gg_set_user_goldm4a1(id);
native gg_set_user_goldmp5navy(id);
native gg_set_user_goldxm1014(id);

native gg_set_user_oicw(id);
native gg_set_user_ak47paladin(id);

native gg_set_user_thanatos3(id);
native gg_set_user_ethereal(id);

native gg_set_user_at4(id);

native gg_set_user_anaconda(id);
native gg_set_user_skull1(id);
native gg_set_user_k5(id);
native gg_set_user_dualinfinity(id);
native gg_set_user_dualdeagle(id);

native gg_set_user_dualberetta(id);
native gg_set_user_m79(id);

native gg_set_user_deaglegold(id);
native gg_set_user_janus1(id);

native is_registered(id);
native get_level(id);
native bool: dont_show_weaponsmenu(id);

#define VIP_FLAG ADMIN_LEVEL_H
#define SILVERVIP_FLAG ADMIN_LEVEL_F
#define GOLDVIP_FLAG ADMIN_LEVEL_E
#define DIAMONDVIP_FLAG ADMIN_LEVEL_D

new bool: BoughtCWeapons[33];
new bool: PrimaryChoosen[33];
new bool: SecondaryChoosen[33];
new bool: WeaponsChoosen[33];
new bool: SaveLastWeapons[33];
new bool: HaveLastWeapons[33];

new PriWeaponSelected[33];
new SecWeaponSelected[33];

new PCredits[33];

public plugin_natives()
{
	register_native("MenuArme", "ShowMenuArme", 1);
	register_native("WeaponsSaved", "native_WeaponsSaved", 1);
}

public native_WeaponsSaved(id)
{
	return SaveLastWeapons[id];
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("weapons","SayArme2");
	register_clcmd("weapon","SayArme2");
	register_clcmd("say /weapons","SayArme");
	register_clcmd("say /weapon","SayArme");
	register_clcmd("say weapons","SayArme");
	register_clcmd("say weapon","SayArme");

	register_clcmd("guns","EnableArme");
	register_clcmd("gun","EnableArme");
	register_clcmd("say /guns","EnableArme");
	register_clcmd("say /gun","EnableArme");
	register_clcmd("say guns","EnableArme");
	register_clcmd("say gun","EnableArme");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	RegisterHam(Ham_Killed, "player", "EventDeath");
}

public client_putinserver(id)
{
	PrimaryChoosen[id] = false;
	SecondaryChoosen[id] = false;
	BoughtCWeapons[id] = false;
	WeaponsChoosen[id] = false;
	SaveLastWeapons[id] = false;

	PriWeaponSelected[id] = 0;
	SecWeaponSelected[id] = 0;
}

public Spawn(id)
{
	if(is_user_alive(id))
	{
		give_item(id, "weapon_knife");

		PrimaryChoosen[id] = false;
		SecondaryChoosen[id] = false;
		BoughtCWeapons[id] = false;

		if(cs_get_user_team(id) == CS_TEAM_CT)
			ShowMenuArme(id);
	}
}

public EventDeath(const victim, const attacker)
{
	if(!is_user_connected(victim))
		return;
		
	PrimaryChoosen[victim] = false;
	SecondaryChoosen[victim] = false;
	BoughtCWeapons[victim] = false;
}

public ShowMenuArme(id)
{
	if( dont_show_weaponsmenu(id) )
		return PLUGIN_HANDLED;

	if(!WeaponsChoosen[id])
	{
		ShowMenuArme2(id);
		return PLUGIN_HANDLED;
	}

	if(SaveLastWeapons[id])
	{
		set_task(0.3, "GiveLastWeapons", id);
		SaveLastWeapons[id] = true;
		return PLUGIN_HANDLED;
	}

	new menu = menu_create ("\d[\yGeek~Gamers\d] \rAnti-Furien \yWeapons Menu", "MenuHandler");

	menu_additem(menu, "New Weapons", "1");
	menu_additem(menu, "Last Weapons", "2");
	menu_additem(menu, "2 + Don't ask again", "3", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu, 0 );

	return 1; 
}

public MenuHandler(id, menu, item)
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
		case 1: ShowMenuArme2(id);
		case 2: GiveLastWeapons(id);
		case 3: 
		{
			ChatColor(id, "!g[GG][Furien-Weapons] !nWeapons choice has been saved, to enable the menu again type !t/guns !");
			GiveLastWeapons(id);
			SaveLastWeapons[id] = true;
		}
	}
	
	menu_destroy (menu);
	return 1;
}

public ShowMenuArme2(id)
{
	if( dont_show_weaponsmenu(id) )
		return PLUGIN_HANDLED;

	new temp[101];
	new iCredits = fcs_get_user_credits( id );
	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rAnti-Furien \yWeapons Menu^n\rYour Credits:\y %d", iCredits );
	new menu = menu_create(temp, "MenuHandler2");

	menu_additem(menu, "\wHunter Weapons", "1");

	if( get_user_flags(id) & VIP_FLAG )
		menu_additem(menu, "\yUltimate Weapons \r(Only V.I.P)^n", "2");
	else	menu_additem(menu, "\dUltimate Weapons \r(Only V.I.P)^n", "2");

	if( iCredits < 35 )
		menu_additem(menu, "\yGatling \rVulcano \d- No Credits", "3", 0);
	else	menu_additem(menu, "\yGatling \rVulcano \d- \w[ \y35 Credits \w]", "3", 0);

	if( iCredits < 45 )
		menu_additem(menu, "\rK1ASES \d- No Credits", "4", 0);
	else	menu_additem(menu, "\rK1ASES \d- \w[ \y45 Credits \w]", "4", 0);

	if( iCredits < 55 )
		menu_additem(menu, "\yM4A1 \rDark Knight \d- No Credits", "5", 0);
	else	menu_additem(menu, "\yM4A1 \rDark Knight \d- \w[ \y55 Credits \w]", "5", 0);

	if( iCredits < 65 )
		menu_additem(menu, "\yM3 \rBlack Dragon \d- No Credits", "6", 0);
	else	menu_additem(menu, "\yM3 \rBlack Dragon \d- \w[ \y65 Credits \w]", "6", 0);

	if( iCredits < 75 )
		menu_additem(menu, "\rCrossBow \d- No Credits", "7", 0);
	else	menu_additem(menu, "\rCrossBow \d- \w[ \y75 Credits \w]", "7", 0);

	menu_display(id, menu, 0 );

	return 1;
}

public MenuHandler2(id, menu, item)
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
		case 1: MenuPlayer(id);
		case 2:
		{
			if( get_user_flags( id ) & VIP_FLAG )
			{
				MenuVIP(id);
			}
			else
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nThese Weapons are Reserved Only For !gV.I.P");
				MenuVIP(id);
			}
		}
		case 3:
		{
			new iCredits = fcs_get_user_credits(id) - 35;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				PriWeaponSelected[id] = 27;
				BoughtCWeapons[id] = true;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_gatling(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tGatling Vulcano.");
				}
			}
		}
		case 4:
		{
			new iCredits = fcs_get_user_credits(id) - 45;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				PriWeaponSelected[id] = 28;
				BoughtCWeapons[id] = true;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_k1ases(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tK1ASES.");
				}
			}
		}
		case 5:
		{
			new iCredits = fcs_get_user_credits(id) - 55;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				PriWeaponSelected[id] = 29;
				BoughtCWeapons[id] = true;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_m4a1darkknight(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tM4A1 Dark Knight.");
				}
			}
		}
		case 6:
		{
			new iCredits = fcs_get_user_credits(id) - 65;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				PriWeaponSelected[id] = 30;
				BoughtCWeapons[id] = true;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_m3bd(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tM3 Black Dragon.");
				}
			}
		}
		case 7:
		{
			new iCredits = fcs_get_user_credits(id) - 75;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				PriWeaponSelected[id] = 31;
				BoughtCWeapons[id] = true;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_crossbow(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tCrossBow.");
				}
			}
		}
	}
	
	menu_destroy (menu);
	return 1;
}

public MenuPlayer(id)
{
	new menu = menu_create ("\d[\yGeek~Gamers\d] \rAnti-Furien \yPrimary Weapons Menu:", "MenuPlayerHandler");
	
	menu_additem(menu, "M4A1", "1");
	menu_additem(menu, "AK47", "2");
	menu_additem(menu, "AUG", "3");
	menu_additem(menu, "SG552", "4");
	menu_additem(menu, "Galil", "5");
	menu_additem(menu, "Famas", "6");
	menu_additem(menu, "Scout", "7");
	menu_additem(menu, "AWP", "8");

	if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
		menu_additem(menu, "SG550", "9");
	else menu_additem(menu, "\dSG550 \r[LEVEL: 20]", "9");

	menu_additem(menu, "\dM249  \r[BLOCKED]", "10");

	if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
		menu_additem(menu, "SG3SG1", "11");
	else menu_additem(menu, "\dG3SG1 \r[LEVEL: 20]", "11");

	menu_additem(menu, "UMP 45", "12");
	menu_additem(menu, "MP5 Navy", "13");
	menu_additem(menu, "M3", "14");
	menu_additem(menu, "XM1014", "15");
	menu_additem(menu, "TMP", "16");
	menu_additem(menu, "Mac 10", "17");
	menu_additem(menu, "P90", "18");

	menu_display(id, menu, 0 );

	return 1;
}

public MenuPlayerHandler(id, menu, item)
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
			PriWeaponSelected[id] = 1;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_m4a1");
				cs_set_user_bpammo(id, CSW_M4A1, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tM4A1.");
			}
		}
		case 2:
		{
			PriWeaponSelected[id] = 2;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tAK-47.");
			}
		}
		case 3:
		{
			PriWeaponSelected[id] = 3;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_aug");
				cs_set_user_bpammo(id, CSW_AUG, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tAUG.");
			}
		}
		case 4:
		{
			PriWeaponSelected[id] = 4;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_sg552");
				cs_set_user_bpammo(id, CSW_SG552, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tSG552.");
			}
		}
		case 5:
		{
			PriWeaponSelected[id] = 5;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_galil");
				cs_set_user_bpammo(id, CSW_GALIL, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tGalil.");
			}
		}
		case 6:
		{
			PriWeaponSelected[id] = 6;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_famas");
				cs_set_user_bpammo(id, CSW_FAMAS, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tFamas.");
			}
		}
		case 7:
		{
			PriWeaponSelected[id] = 7;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_scout");
				cs_set_user_bpammo(id, CSW_SCOUT, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tScout.");
			}
		}
		case 8:
		{
			PriWeaponSelected[id] = 8;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_awp");
				cs_set_user_bpammo(id, CSW_AWP, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tAWP.");
			}
		}
		case 9:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
			{
				PriWeaponSelected[id] = 9;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					give_item(id, "weapon_sg550");
					cs_set_user_bpammo(id, CSW_SG550, 90);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tSG550.");
				}
			}
			else
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYour level is less than !tLevel 20");
				MenuPlayer(id);
			}
		}
		case 10:
		{
			ChatColor(id, "!g[GG][Furien-Weapons] !nThis Weapon !gM249 !nis Blocked in The Server.");
			MenuPlayer(id);
		}
		case 11:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
			{
				PriWeaponSelected[id] = 10;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					give_item(id, "weapon_g3sg1");
					cs_set_user_bpammo(id, CSW_G3SG1, 90);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tG3SG1.");
				}
			}
			else
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYour level is less than !tLevel 20");
				MenuPlayer(id);
			}
		}
		case 12:
		{
			PriWeaponSelected[id] = 11;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_ump45");
				cs_set_user_bpammo(id, CSW_UMP45, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tUMP 45.");
			}
		}
		case 13:
		{
			PriWeaponSelected[id] = 12;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_mp5navy");
				cs_set_user_bpammo(id, CSW_MP5NAVY, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tMP5 Navy.");
			}
		}
		case 14:
		{
			PriWeaponSelected[id] = 13;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_m3");
				cs_set_user_bpammo(id, CSW_M3, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tM3.");
			}
		}
		case 15:
		{
			PriWeaponSelected[id] = 14;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_xm1014");
				cs_set_user_bpammo(id, CSW_XM1014, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tXM1014.");
			}
		}
		case 16:
		{
			PriWeaponSelected[id] = 15;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_tmp");
				cs_set_user_bpammo(id, CSW_TMP, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tTMP.");
			}
		}
		case 17:
		{
			PriWeaponSelected[id] = 16;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_mac10");
				cs_set_user_bpammo(id, CSW_MAC10, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tMac 10.");
			}
		}
		case 18:
		{
			PriWeaponSelected[id] = 17;
			SecondaryWeapons(id);

			if(is_user_alive(id))
			{
				give_item(id, "weapon_p90");
				cs_set_user_bpammo(id, CSW_P90, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tP90.");
			}
		}
	}
	
	menu_destroy (menu);
	return 1;
}

public MenuVIP(id)
{
	new temp[101];
	new iCredits = fcs_get_user_credits( id );
	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rAnti-Furien \wV.I.P \yWeapons Menu^n\rYour Credits:\y %d", iCredits );
	new menu = menu_create(temp, "VIP");

	if(get_user_flags(id) & VIP_FLAG)
	{
		menu_additem(menu, "\yGolden \rM4A1", "1");
		menu_additem(menu, "\yGolden \rAK47", "2");
		menu_additem(menu, "\yGolden \rMP5 Navy", "3");
		menu_additem(menu, "\yGolden \rXM1014^n", "4");
	}
	else
	{
		menu_additem(menu, "\dGolden M4A1 \r(Only V.I.P)", "1");
		menu_additem(menu, "\dGolden AK47 \r(Only V.I.P)", "2");
		menu_additem(menu, "\dGolden MP5 Navy \r(Only V.I.P)", "3");
		menu_additem(menu, "\dGolden XM1014 \r(Only V.I.P)^n", "4");
	}

	if(get_user_flags(id) & SILVERVIP_FLAG)
	{
		if( iCredits < 45 )
			menu_additem(menu, "\rOICW \d- No Credits", "5", 0);
		else	menu_additem(menu, "\rOICW \d- \w[ \y45 Credits \w]", "5", 0);

		if( iCredits < 55 )
			menu_additem(menu, "\rAK47 \yPaladin \d- No Credits^n", "6", 0);
		else	menu_additem(menu, "\rAK47 \yPaladin \d- \w[ \y55 Credits \w]^n", "6", 0);
	}
	else
	{
		menu_additem(menu, "\dOICW \r(Only Silver V.I.P)", "5", 0);
		menu_additem(menu, "\dAK47 Paladin \r(Only Silver V.I.P)^n", "6", 0);
	}

	if(get_user_flags(id) & GOLDVIP_FLAG)
	{
		if( iCredits < 65 )
			menu_additem(menu, "\yThanatos \r3 \d- No Credits", "7", 0);
		else	menu_additem(menu, "\yThanatos \r3 \d- \w[ \y65 Credits \w]", "7", 0);

		if( iCredits < 75 )
			menu_additem(menu, "\yEthereal \rBalrog \d- No Credits^n", "8", 0);
		else	menu_additem(menu, "\yEthereal \rBalrog \d- \w[ \y75 Credits \w]^n", "8", 0);
	}
	else
	{
		menu_additem(menu, "\dThanatos 3 \r(Only Gold V.I.P)", "7", 0);
		menu_additem(menu, "\dEthereal Balrog \r(Only Gold V.I.P)^n", "8", 0);
	}

	if(get_user_flags(id) & DIAMONDVIP_FLAG)
	{
		if( iCredits < 140 )
			menu_additem(menu, "\rAT4 \d- No Credits", "9", 0);
		else	menu_additem(menu, "\rAT4 \d- \w[ \y120 Credits \w]", "9", 0);
	}
	else
	{
		menu_additem(menu, "\dAT4 \r(Only Diamond V.I.P)", "9", 0);
	}

	menu_addblank(menu, 0);
	menu_setprop(menu, MPROP_PERPAGE, 0);

	menu_additem(menu, "Back", "MENU_EXIT");
	menu_display(id, menu, 0);

	return 1;
}

public VIP(id, menu, item)
{
	if(item == MENU_EXIT)
	{	
		ShowMenuArme(id);
	}
	
	new data [6], szName [64];
	new access, callback;
	menu_item_getinfo (menu, item, access, data,charsmax (data), szName,charsmax (szName), callback);
	new key = str_to_num (data);
	
	switch (key)
	{
		case 0: ShowMenuArme2(id);
		case 1:
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				PriWeaponSelected[id] = 18;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					gg_set_user_goldm4a1(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tM4A1 Gold.");
				}
			}
			else ShowMenuArme2(id);
		}
		case 2:
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				PriWeaponSelected[id] = 19;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					gg_set_user_goldak47(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tAK47 Gold.");
				}
			}
			else ShowMenuArme2(id);
		}
		case 3:
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				PriWeaponSelected[id] = 20;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					gg_set_user_goldmp5navy(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tMP5 Gold.");
				}
			}
			else ShowMenuArme2(id);
		}
		case 4:
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				PriWeaponSelected[id] = 21;
				SecondaryWeapons(id);

				if(is_user_alive(id))
				{
					gg_set_user_goldxm1014(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tXM1014 Gold.");
				}
			}
			else ShowMenuArme2(id);
		}
		case 5 :
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 45;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					PriWeaponSelected[id] = 22;
					BoughtCWeapons[id] = true;
					SecondaryWeapons(id);

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_oicw(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tOICW.");
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 6 :
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 55;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					PriWeaponSelected[id] = 23;
					BoughtCWeapons[id] = true;
					SecondaryWeapons(id);

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_ak47paladin(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tAK47 Paladin.");
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 7 :
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 65;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					PriWeaponSelected[id] = 24;
					BoughtCWeapons[id] = true;
					SecondaryWeapons(id);

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_thanatos3(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tThanatos 3.");
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 8 : 
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 75;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					PriWeaponSelected[id] = 25;
					BoughtCWeapons[id] = true;
					SecondaryWeapons(id);

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_ethereal(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tEthereal Balrog.");
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 9 : 
		{
			if(get_user_flags(id) & DIAMONDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 120;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					PriWeaponSelected[id] = 26;
					BoughtCWeapons[id] = true;
					SecondaryWeapons(id);

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_at4(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tAT4.");
					}
				}
			}
			else ShowMenuArme2(id);
		}
	}
	
	menu_destroy(menu);
	return 1;
}

public SecondaryWeapons(id)
{
	new temp[101];
	new iCredits = fcs_get_user_credits( id );
	formatex( temp, 100, "\d[\yGeek~Gamers\d] \rAnti-Furien \ySecondary Weapons^n\rYour Credits:\y %d", iCredits );
	new menu = menu_create(temp, "SecondaryHandle");

	menu_additem(menu, "Anaconda", "1");
	menu_additem(menu, "Skull1", "2");
	menu_additem(menu, "K5", "3");
	menu_additem(menu, "Dual Infinity", "4");
	menu_additem(menu, "Dual Deagle^n", "5");

	if(BoughtCWeapons[id])
	{
		menu_additem(menu, "\yDual \rBerreta Gunslinger", "6");
		menu_additem(menu, "\rM79^n", "7");
	}
	else
	{
		if( iCredits < 15 )
			menu_additem(menu, "\yDual \rBerreta Gunslinger \d- No Credits", "6");
		else	menu_additem(menu, "\yDual \rBerreta Gunslinger \d- \w[ \y15 Credits \w]", "6");

		if( iCredits < 25 )
			menu_additem(menu, "\rM79 \d- No Credits^n", "7");
		else	menu_additem(menu, "\rM79 \d- \w[ \y25 Credits \w]^n", "7");
	}
	
	if(get_user_flags(id) & VIP_FLAG)
	{
		menu_additem(menu, "\yDeagle \rGold", "8");
	}
	else menu_additem(menu, "\dDeagle Gold \r(Only V.I.P)", "8");

	if(BoughtCWeapons[id])
	{
		if(get_user_flags(id) & SILVERVIP_FLAG)
		{
			menu_additem(menu, "\yJanus \r1", "9", 0);
		}
		else menu_additem(menu, "\dJanus 1 \r(Only Silver V.I.P)", "9", 0);
	}
	else
	{
		if(get_user_flags(id) & SILVERVIP_FLAG)
		{
			if( iCredits < 30 )
				menu_additem(menu, "\yJanus \r1 \d- No Credits", "9", 0);
			else	menu_additem(menu, "\yJanus \r1 \d- \w[ \y30 Credits \w]", "9", 0);
		}
		else menu_additem(menu, "\dJanus 1 \r(Only Silver V.I.P)", "9", 0);
	}

	menu_addblank(menu, 0);
	menu_additem(menu, "Exit", "MENU_EXIT");

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
	
	return 1;
}

public SecondaryHandle(id, menu, item)
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
			SecWeaponSelected[id] = 1;
			WeaponsChoosen[id] = true;

			if(is_user_alive(id))
			{
				gg_set_user_anaconda(id);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tAnaconda.");
			}
		}
		case 2:
		{
			SecWeaponSelected[id] = 2;
			WeaponsChoosen[id] = true;

			if(is_user_alive(id))
			{
				gg_set_user_skull1(id);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tSkull1.");
			}
		}
		case 3:
		{
			SecWeaponSelected[id] = 3;
			WeaponsChoosen[id] = true;

			if(is_user_alive(id))
			{
				gg_set_user_k5(id);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tK5.");
			}
		}
		case 4:
		{
			SecWeaponSelected[id] = 4;
			WeaponsChoosen[id] = true;

			if(is_user_alive(id))
			{
				gg_set_user_dualinfinity(id);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tDual Infinity.");
			}
		}
		case 5:
		{
			SecWeaponSelected[id] = 5;
			WeaponsChoosen[id] = true;

			if(is_user_alive(id))
			{
				gg_set_user_dualdeagle(id);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tDual Deagle.");
			}
		}
		case 6: 
		{
			if(BoughtCWeapons[id])
			{
				SecWeaponSelected[id] = 6;
				WeaponsChoosen[id] = true;

				if(is_user_alive(id))
				{
					gg_set_user_dualberetta(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tDual Berreta Gunslinger.");
				}
			}
			else
			{
				new iCredits = fcs_get_user_credits(id) - 15;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					SecondaryWeapons(id);
				}
				else
				{
					SecWeaponSelected[id] = 6;
					WeaponsChoosen[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_dualberetta(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tDual Berreta Gunslinger.");
					}
				}
			}
		}
		case 7: 
		{
			if(BoughtCWeapons[id])
			{
				SecWeaponSelected[id] = 7;
				WeaponsChoosen[id] = true;

				if(is_user_alive(id))
				{
					gg_set_user_m79(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tM79.");
				}
			}
			else
			{
				new iCredits = fcs_get_user_credits(id) - 25;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					SecondaryWeapons(id);
				}
				else
				{
					SecWeaponSelected[id] = 7;
					WeaponsChoosen[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_m79(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tM79.");
					}
				}
			}
		}
		case 8: 
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				SecWeaponSelected[id] = 8;
				WeaponsChoosen[id] = true;

				if(is_user_alive(id))
				{
					gg_set_user_deaglegold(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tDeagle Gold.");
				}
			}
			else SecondaryWeapons(id);
		}
		case 9: 
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				if(BoughtCWeapons[id])
				{
					SecWeaponSelected[id] = 9;
					WeaponsChoosen[id] = true;

					if(is_user_alive(id))
					{
						gg_set_user_janus1(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou've chosen !tJanus 1.");
					}
				}
				else
				{
					new iCredits = fcs_get_user_credits(id) - 30;
					if( iCredits < 0 )
					{
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
						SecondaryWeapons(id);
					}
					else
					{
						SecWeaponSelected[id] = 9;
						WeaponsChoosen[id] = true;

						if(is_user_alive(id))
						{
							fcs_set_user_credits( id, iCredits );
							gg_set_user_janus1(id);
							PrimaryChoosen[id] = true;
							SecondaryChoosen[id] = true;
							ChatColor(id, "!g[GG][Furien-Weapons] !nYou've bought !tJanus 1.");
						}
					}
				}
			}
			else SecondaryWeapons(id);
		}
	}

	menu_destroy (menu);
	return 1;
}

public GiveLastWeapons(id)
{
	if(HaveLastWeapons[id])
		return;

	PCredits[id] = fcs_get_user_credits(id);

	LastPriWeapons(id);
	LastSecWeapons(id);

	if( PCredits[id] - fcs_get_user_credits(id) > 0 )
		ChatColor(id, "!g[GG][Furien-Weapons] !nYou paid !t%d Credits !nfor your last weapons, Now you have !t%d Credits !g!", PCredits[id] - fcs_get_user_credits(id), fcs_get_user_credits(id));

	HaveLastWeapons[id] = true;
	set_task(0.5, "resetHaveLastWeapons", id);
}

public resetHaveLastWeapons(id)
{
	HaveLastWeapons[id] = false;
}

public LastPriWeapons(id)
{
	switch(PriWeaponSelected[id])
	{
		case 1:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_m4a1");
				cs_set_user_bpammo(id, CSW_M4A1, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 2:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 3:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_aug");
				cs_set_user_bpammo(id, CSW_AUG, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 4:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_sg552");
				cs_set_user_bpammo(id, CSW_SG552, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 5:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_galil");
				cs_set_user_bpammo(id, CSW_GALIL, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 6:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_famas");
				cs_set_user_bpammo(id, CSW_FAMAS, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 7:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_scout");
				cs_set_user_bpammo(id, CSW_SCOUT, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 8:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_awp");
				cs_set_user_bpammo(id, CSW_AWP, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 9:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
			{
				if(is_user_alive(id))
				{
					give_item(id, "weapon_sg550");
					cs_set_user_bpammo(id, CSW_SG550, 90);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou must have !tLevel 20");
				MenuPlayer(id);
			}
		}
		case 10:
		{
			if( get_level(id) >= 20 || get_user_flags(id) & ADMIN_LEVEL_C )
			{
				if(is_user_alive(id))
				{
					give_item(id, "weapon_g3sg1");
					cs_set_user_bpammo(id, CSW_G3SG1, 90);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou must have !tLevel 20");
				MenuPlayer(id);
			}
		}
		case 11:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_ump45");
				cs_set_user_bpammo(id, CSW_UMP45, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 12:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_mp5navy");
				cs_set_user_bpammo(id, CSW_MP5NAVY, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 13:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_m3");
				cs_set_user_bpammo(id, CSW_M3, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 14:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_xm1014");
				cs_set_user_bpammo(id, CSW_XM1014, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 15:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_tmp");
				cs_set_user_bpammo(id, CSW_TMP, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 16:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_mac10");
				cs_set_user_bpammo(id, CSW_MAC10, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 17:
		{
			if(is_user_alive(id))
			{
				give_item(id, "weapon_p90");
				cs_set_user_bpammo(id, CSW_P90, 90);
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = false;
			}
		}
		case 18:
		{
			if(get_user_flags(id) & VIP_FLAG || get_level(id) >= get_cvar_num("amx_levelmenu_vipweapons"))
			{
				if(is_user_alive(id))
				{
					gg_set_user_goldm4a1(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else ShowMenuArme2(id);
		}
		case 19:
		{
			if(get_user_flags(id) & VIP_FLAG || get_level(id) >= get_cvar_num("amx_levelmenu_vipweapons"))
			{
				if(is_user_alive(id))
				{
					gg_set_user_goldak47(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else ShowMenuArme2(id);
		}
		case 20:
		{
			if(get_user_flags(id) & VIP_FLAG || get_level(id) >= get_cvar_num("amx_levelmenu_vipweapons"))
			{
				if(is_user_alive(id))
				{
					gg_set_user_goldmp5navy(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else ShowMenuArme2(id);
		}
		case 21:
		{
			if(get_user_flags(id) & VIP_FLAG || get_level(id) >= get_cvar_num("amx_levelmenu_vipweapons"))
			{
				if(is_user_alive(id))
				{
					gg_set_user_goldxm1014(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
			else ShowMenuArme2(id);
		}
		case 22: 
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 45;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					BoughtCWeapons[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_oicw(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 23: 
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 55;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
					return 1;
				}
				else
				{
					BoughtCWeapons[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_ak47paladin(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 24: 
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 65;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					BoughtCWeapons[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_thanatos3(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 25: 
		{
			if(get_user_flags(id) & GOLDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 75;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					BoughtCWeapons[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_ethereal(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 26: 
		{
			if(get_user_flags(id) & DIAMONDVIP_FLAG)
			{
				new iCredits = fcs_get_user_credits(id) - 140;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					ShowMenuArme2(id);
				}
				else
				{
					BoughtCWeapons[id] = true;

					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_at4(id);
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = false;
					}
				}
			}
			else ShowMenuArme2(id);
		}
		case 27: 
		{
			new iCredits = fcs_get_user_credits(id) - 35;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				BoughtCWeapons[id] = true;

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_gatling(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
		}
		case 28: 
		{
			new iCredits = fcs_get_user_credits(id) - 45;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				BoughtCWeapons[id] = true;

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_k1ases(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
		}
		case 29:
		{
			new iCredits = fcs_get_user_credits(id) - 55;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				BoughtCWeapons[id] = true;

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_m4a1darkknight(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
		}
		case 30:
		{
			new iCredits = fcs_get_user_credits(id) - 65;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				BoughtCWeapons[id] = true;

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_m3bd(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
		}
		case 31: 
		{
			new iCredits = fcs_get_user_credits(id) - 75;
			if( iCredits < 0 )
			{
				ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
				ShowMenuArme2(id);
			}
			else
			{
				BoughtCWeapons[id] = true;

				if(is_user_alive(id))
				{
					fcs_set_user_credits( id, iCredits );
					gg_set_user_crossbow(id);
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = false;
				}
			}
		}
	}
	return 1;
}

public LastSecWeapons(id)
{
	switch(SecWeaponSelected[id])
	{
		case 1:
		{
			if(is_user_alive(id))
			{
				gg_set_user_anaconda(id);
				WeaponsChoosen[id] = true;
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
			}
		}
		case 2:
		{
			if(is_user_alive(id))
			{
				gg_set_user_skull1(id);
				WeaponsChoosen[id] = true;
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
			}
		}
		case 3:
		{
			if(is_user_alive(id))
			{
				gg_set_user_k5(id);
				WeaponsChoosen[id] = true;
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
			}
		}
		case 4:
		{
			if(is_user_alive(id))
			{
				gg_set_user_dualinfinity(id);
				WeaponsChoosen[id] = true;
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
			}
		}
		case 5:
		{
			if(is_user_alive(id))
			{
				gg_set_user_dualdeagle(id);
				WeaponsChoosen[id] = true;
				PrimaryChoosen[id] = true;
				SecondaryChoosen[id] = true;
			}
		}
		case 6: 
		{
			if(BoughtCWeapons[id])
			{
				if(is_user_alive(id))
				{
					gg_set_user_dualberetta(id);
					WeaponsChoosen[id] = true;
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
				}
			}
			else
			{
				new iCredits = fcs_get_user_credits(id) - 15;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					SecondaryWeapons(id);
				}
				else
				{
					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_dualberetta(id);
						WeaponsChoosen[id] = true;
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
					}
				}
			}
		}
		case 7: 
		{
			if(BoughtCWeapons[id])
			{
				if(is_user_alive(id))
				{
					gg_set_user_m79(id);
					WeaponsChoosen[id] = true;
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
				}
			}
			else
			{
				new iCredits = fcs_get_user_credits(id) - 25;
				if( iCredits < 0 )
				{
					ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
					SecondaryWeapons(id);
				}
				else
				{
					if(is_user_alive(id))
					{
						fcs_set_user_credits( id, iCredits );
						gg_set_user_m79(id);
						WeaponsChoosen[id] = true;
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
					}
				}
			}
		}
		case 8:
		{
			if(get_user_flags(id) & VIP_FLAG)
			{
				if(is_user_alive(id))
				{
					gg_set_user_deaglegold(id);
					WeaponsChoosen[id] = true;
					PrimaryChoosen[id] = true;
					SecondaryChoosen[id] = true;
				}
			}
			else SecondaryWeapons(id);
		}
		case 9: 
		{
			if(get_user_flags(id) & SILVERVIP_FLAG)
			{
				if(BoughtCWeapons[id])
				{
					if(is_user_alive(id))
					{
						gg_set_user_janus1(id);
						WeaponsChoosen[id] = true;
						PrimaryChoosen[id] = true;
						SecondaryChoosen[id] = true;
					}
				}
				else
				{
					new iCredits = fcs_get_user_credits(id) - 30;
					if( iCredits < 0 )
					{
						ChatColor(id, "!g[GG][Furien-Weapons] !nYou don't Have enough !tCredits.");
						SecondaryWeapons(id);
					}
					else
					{
						if(is_user_alive(id))
						{
							fcs_set_user_credits( id, iCredits );
							gg_set_user_janus1(id);
							WeaponsChoosen[id] = true;
							PrimaryChoosen[id] = true;
							SecondaryChoosen[id] = true;
						}
					}
				}
			}
			else SecondaryWeapons(id);
		}
	}
	return 1;
}

public EnableArme(id)
{
	if(SaveLastWeapons[id])
	{
		SaveLastWeapons[id] = false;
		ChatColor(id, "!g[GG][Furien-Weapons] !nYour !tAnti-Furien !nweapons menu is now activated !g!");
	}
	else
	{
		ChatColor(id, "!g[GG][Furien-Weapons] !nYour !tAnti-Furien !nweapons menu is already activated !g!");
	}
}

public SayArme(id)
{
	if( PrimaryChoosen[id] && SecondaryChoosen[id] )
	{
		ChatColor(id, "!g[GG][Furien-Weapons] !nYou have already choosed your weapons, wait until the next respawn !g!");
		return;
	}

	if( PrimaryChoosen[id] && !SecondaryChoosen[id] )
	{
		SecondaryWeapons(id);
	}

	if( !PrimaryChoosen[id] && !SecondaryChoosen[id] )
	{
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			if( dont_show_weaponsmenu(id) ) ChatColor(id, "!g[GG][Furien-Weapons] !nYou can't Open The Weapon Menu in The Current !tMod !n!");
			else ShowMenuArme(id);
		}
	}
}

public SayArme2(id)
{
	if( PrimaryChoosen[id] && SecondaryChoosen[id] )
		return;

	if( PrimaryChoosen[id] && !SecondaryChoosen[id] )
	{
		SecondaryWeapons(id);
	}

	if( !PrimaryChoosen[id] && !SecondaryChoosen[id] )
	{
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			if( dont_show_weaponsmenu(id) ) return;
			else ShowMenuArme(id);
		}
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
