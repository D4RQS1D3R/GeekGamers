//#define POWERS
#define MAX_WEAPONS		100
#define EV_INT_WeaponKey	EV_INT_impulse

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#include "furien40/furien40.inc"
#if defined POWERS
#include "furien40/furien40_powers.inc"
#endif

#define PLUGIN "Weapons Menu"
#define VERSION "4.0"
#define AUTHOR "Aragon*"

//------| Settings |------//
#define VIP_LEVEL	ADMIN_LEVEL_F
#define ADMIN_LEVEL	ADMIN_LEVEL_E

//--| Primary Weapons |--//
#define OICW
#define THANATOS11
#define THANATOS7
//#define AEOLIS
#define JANUS11
//#define JANUS7
#define JANUS3
//#define SPEARGUN
//#define PETROLBOOMER
#define SALAMANDER
#define AT4
#define ETHEREAL
#define RAILCANNON
#define PLASMAGUN
#define CROSSBOW
//#define COMPOUNDBOW
#define HK416
#define AK47KNIFE
#define F2000
#define TAR21
#define K1ASES
#define DUALMP7A1
#define QUADBARREL
#define M1887
#define THOMPSON
#define M134
//#define SKULL5
//#define SL8
//#define AW50

//--| Secondary Weapons |--//
//#define DRAGONCANNON
//#define JANUS1
#define M79
#define DUALDEAGLE
#define INFINITY
#define SKULL1
//#define ANACONDA

//--| Knifes |--//
//#define CLAWS
//#define SUPERCLAWS
//#define DUALKATANA
//#define BALROG9
//#define JANUS9
//#define RUYISTICK
//#define DRAGONSWORD
//#define PAPIN

//--| Grenades |--//
//#define SNARK
//#define FIRENADE
//#define FROSTNADE
//#define SFNADE

//--| C4 |--//
//#define LASERMINE
//------| End Settings |------//

enum WeaponsList {
	WPN_PRIMARY = 0,
	WPN_SECONDARY,
	WPN_KNIFE,
	WPN_GRENADE,
	WPN_C4
}
enum WeaponData {
	WPN_MENUNAME = 0,
	WPN_TEAM,
	WPN_ACCES,
	WPN_LEVEL,
	WPN_NAME,
	WPN_ID,
	WPN_LIST,
	WPN_CLIP
};
enum WeaponTeam {
	WPN_TEAM_ALL = 0,
	WPN_TEAM_T,
	WPN_TEAM_CT
};
enum WeaponAcces {
	WPN_ACCES_ALL = 0,
	WPN_ACCES_VIP,
	WPN_ACCES_ADMIN
};

new Menu, bool:ShowMenu[33], Weapons[WeaponsList] = 1, HasChoose[33][WeaponsList][4], WeaponKey[33][WeaponsList][4],
PrimaryWeapon[MAX_WEAPONS+1][WeaponData][33], SecondaryWeapon[MAX_WEAPONS+1][WeaponData][33], Knife[MAX_WEAPONS+1][WeaponData][33],
Grenade[MAX_WEAPONS+1][WeaponData][33], C4[MAX_WEAPONS+1][WeaponData][33],
MSGID_WeaponList, MSGID_DeathMsg, MSGID_ScoreInfo, MSGID_SayText, 
MSGID_CurWeapon, MSGID_Crosshair/*, MSGID_ScreenFade, MSGID_ScreenShake*/;

//------| Weapons Menu |------//
#define PRIMARY_WEAPONS_BITSUM		(1<<CSW_SCOUT | 1<<CSW_XM1014 | 1<<CSW_MAC10 | 1<<CSW_AUG | 1<<CSW_UMP45 | 1<<CSW_SG550 | 1<<CSW_GALIL | 1<<CSW_FAMAS | 1<<CSW_AWP | 1<<CSW_MP5NAVY | 1<<CSW_M249 | 1<<CSW_M3 | 1<<CSW_M4A1 | 1<<CSW_TMP | 1<<CSW_G3SG1 | 1<<CSW_SG552 | 1<<CSW_AK47 | 1<<CSW_P90)
#define SECONDARY_WEAPONS_BITSUM 	(1<<CSW_GLOCK18 | 1<<CSW_USP | 1<<CSW_P228 | 1<<CSW_DEAGLE | 1<<CSW_FIVESEVEN | 1<<CSW_ELITE)
#define AMMOWP_NULL 			(1<<0 | 1<<CSW_KNIFE | 1<<CSW_FLASHBANG | 1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_C4)
new Shell, BloodSpray, BloodDrop,
WeaponsAmmo[][] = {
	{ -1, -1 },
	{ 13, 52 },
	{ -1, -1 },
	{ 10, 90 },
	{ -1, -1 },
	{ 7, 32 },
	{ -1, -1 },
	{ 30, 100 },
	{ 30, 90 },
	{ -1, -1 },
	{ 30, 120 },
	{ 20, 100 },
	{ 25, 100 },
	{ 30, 90 },
	{ 35, 90 },
	{ 25, 90 },
	{ 12, 100 },
	{ 20, 120 },
	{ 10, 30 },
	{ 30, 120 },
	{ 100, 200 },
	{ 8, 32 },
	{ 30, 90 },
	{ 30, 120 },
	{ 20, 90 },
	{ -1, -1 },
	{ 7, 35 },
	{ 30, 90 },
	{ 30, 90 },
	{ -1, -1 },
	{ 50, 100 }
},
Prefix[] = "[VitalCS]",
Contact[] = "gabi_ics";

#include "furien40/weapons/Config.h"
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	MSGID_WeaponList 	= get_user_msgid("WeaponList")
	MSGID_DeathMsg 		= get_user_msgid("DeathMsg")
	MSGID_ScoreInfo 	= get_user_msgid("ScoreInfo")
	MSGID_SayText 		= get_user_msgid("SayText")
	MSGID_CurWeapon 	= get_user_msgid("CurWeapon")
	MSGID_Crosshair 	= get_user_msgid("Crosshair")
	/*MSGID_ScreenFade 	= get_user_msgid("ScreenFade")
	MSGID_ScreenShake 	= get_user_msgid("ScreenShake");*/
	Shell 			= engfunc(EngFunc_PrecacheModel, "models/rshell.mdl");
	
	register_clcmd("guns", 				"CMD_Guns");
	register_clcmd("say guns", 			"CMD_Guns");
	register_clcmd("say /guns", 			"CMD_Guns");
	register_clcmd("say_team guns", 		"CMD_Guns");
	register_clcmd("say_team /guns", 		"CMD_Guns");
	
	register_event("CurWeapon", 			"EVENT_CurWeapon", "be", "1=1")
	RegisterHam(Ham_Spawn, "player", 		"HAM_Spawn_Post", 1);
	RegisterHam(Ham_Touch, "weaponbox", 		"HAM_Touch")
	RegisterHam(Ham_Touch, "armoury_entity", 	"HAM_Touch")
	RegisterHam(Ham_Touch, "weapon_shield", 	"HAM_Touch")
	
	
	weapons_init()
}

public plugin_precache() {
	BloodSpray 	= precache_model("sprites/bloodspray.spr");
	BloodDrop  	= precache_model("sprites/blood.spr");
	
	weapons_precache()
}

public plugin_natives() {
	register_native("RegisterPrimary", 	"native_register_primary", 1)
	register_native("RegisterSecondary", 	"native_register_secondary", 1)
	register_native("RegisterKnife", 	"native_register_knife", 1)
	register_native("RegisterGrenade", 	"native_register_grenade", 1)
	register_native("RegisterC4", 		"native_register_c4", 1)
	register_native("OpenWeaponsMenu", 	"CMD_Guns", 1)
	register_native("get_weapon", 		"get_weapon", 1)
	register_native("set_weapon", 		"set_weapon", 1)
	register_native("get_weapon_data", 	"get_weapon_data", 1)
	register_native("set_weapon_data", 	"set_weapon_data", 1)
	
	weapons_natives()
}

public client_putinserver(id) {
	ShowMenu[id] = true
}

public grenade_throw(id, grenade, GrenadeID) {
	if(is_valid_ent(grenade) && is_user_alive(id)) {
		for(new i = 1; i < Weapons[WPN_GRENADE]; i++) {
			if(GrenadeID == str_to_num(Grenade[i][WPN_ID]) && get_user_weapon(id) == GrenadeID && get_weapon(id, Grenade[i][WPN_NAME], str_to_num(Grenade[i][WPN_ID]), i))
				entity_set_int(grenade, EV_INT_impulse, i);
		}
	}
	return FMRES_IGNORED;
}

public EVENT_CurWeapon(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		new Weapon = read_data(2)
		
		if(!(AMMOWP_NULL &(1<<Weapon))) {		
			if(fm_get_user_bpammo(id, Weapon) < WeaponsAmmo[Weapon][1]) 
				fm_set_user_bpammo(id, Weapon, WeaponsAmmo[Weapon][1])
		}
	}
	return PLUGIN_CONTINUE
}

public HAM_Spawn_Post(id) {
	if(is_user_alive(id)) {
		HasChoose[id][WPN_PRIMARY][get_user_team(id)] = false
		HasChoose[id][WPN_SECONDARY][get_user_team(id)] = false
		HasChoose[id][WPN_KNIFE][get_user_team(id)] = false
		HasChoose[id][WPN_GRENADE][get_user_team(id)] = false
		HasChoose[id][WPN_C4][get_user_team(id)] = false

		#if defined FIRENADE
		set_weapon(id, WPN_GRENADE, firenade_id())
		#endif
		#if defined FROSTNADE
		set_weapon(id, WPN_GRENADE, frostnade_id())
		#endif
		#if defined SFNADE
		set_weapon(id, WPN_GRENADE, sfnade_id())
		#endif
		
		if(get_user_team(id) == TEAM_ANTIFURIEN) {			
			if(ShowMenu[id]) 
				EquipmentMenu(id)
			else if(!ShowMenu[id])
				GiveLastWeapons(id)
			
		}
	}
	return HAM_IGNORED;
}

public HAM_Touch(ent, id) {
	if(is_user_alive(id)) {
		if(get_user_team(id) == TEAM_FURIEN && entity_get_int(ent, EV_INT_impulse) == 2)
			return HAM_SUPERCEDE	
		if(get_user_team(id) == TEAM_ANTIFURIEN && entity_get_int(ent, EV_INT_impulse) == 1)
			return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public CMD_Guns(id) {
	if(!ShowMenu[id]) {
		ShowMenu[id] = true
		ColorChat(id, "!t%s!gMeniul de!t echipamente!g a fost!t re-activat!g.", Prefix);
	}
	if(!HasChoose[id][WPN_PRIMARY][2] && !HasChoose[id][WPN_SECONDARY][2] && !HasChoose[id][WPN_KNIFE][2])
		EquipmentMenu(id)
	else if(!HasChoose[id][WPN_PRIMARY][2])
		PrimaryWeaponMenu(id, 0)
	else if(!HasChoose[id][WPN_SECONDARY][2])
		SecondaryWeaponMenu(id)
	else if(!HasChoose[id][WPN_KNIFE][2])
		KnifesMenu(id)
	return PLUGIN_CONTINUE;
}

public EquipmentMenu(id) {
	if(is_user_alive(id) && get_user_team(id) == TEAM_ANTIFURIEN) {
		menu_cancel(id)
		
		Menu = menu_create("\wAnti-Furien Weapons", "EquipmentCmd");
		menu_additem(Menu, "\wArme noi", "1", 0);
		if(WeaponKey[id][WPN_PRIMARY][2] && WeaponKey[id][WPN_SECONDARY][2] && WeaponKey[id][WPN_KNIFE][2]) {
			menu_additem(Menu, "\wArmele anterioare", "2", 0);
			menu_additem(Menu, "\wNu arata meniul din nou^n", "3", 0);
		}
		else {
			menu_additem(Menu, "\dArmele anterioare", "2", 0);
			menu_additem(Menu, "\dNu arata meniul din nou^n", "3", 0);
		}
		menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
		menu_display(id, Menu, 0);
	}
}

public EquipmentCmd(id, menu, item) {
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_team(id) != TEAM_ANTIFURIEN) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64], Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data, 5, Name, 63, CallBack);
	menu_destroy(menu);
	
	switch(str_to_num(Data)) {
		case 1: {
			if(!HasChoose[id][WPN_PRIMARY][2])
				PrimaryWeaponMenu(id, 0)
			else if(!HasChoose[id][WPN_SECONDARY][2])
				SecondaryWeaponMenu(id)
			else if(!HasChoose[id][WPN_KNIFE][2])
				KnifesMenu(id)
		}
		case 2: {
			if(WeaponKey[id][WPN_PRIMARY][2] && WeaponKey[id][WPN_SECONDARY][2] && WeaponKey[id][WPN_KNIFE][2])
				GiveLastWeapons(id)
			else EquipmentMenu(id)
		}
		case 3: {
			if(WeaponKey[id][WPN_PRIMARY][2] && WeaponKey[id][WPN_SECONDARY][2] && WeaponKey[id][WPN_KNIFE][2]) {
				ShowMenu[id] = false
				GiveLastWeapons(id)
			}
			else EquipmentMenu(id)
		}
	}
	return PLUGIN_HANDLED;
}

public PrimaryWeaponMenu(id, VIP) {
	if(is_user_alive(id) && get_user_team(id) == TEAM_ANTIFURIEN && !HasChoose[id][WPN_PRIMARY][2]) {
		menu_cancel(id);
		
		Menu = menu_create("\rPrimar", "PrimaryCmd");
		
		if(VIP == 0) {
			new UltimateWeapon = 0, VIPWeapon = 0
			for(new i = 1; i < Weapons[WPN_PRIMARY]; i++) {
				if(WeaponTeam:str_to_num(PrimaryWeapon[i][WPN_TEAM]) != WPN_TEAM_T && WeaponAcces:str_to_num(PrimaryWeapon[i][WPN_ACCES]) == WPN_ACCES_ADMIN)
					UltimateWeapon++
				if(WeaponTeam:str_to_num(PrimaryWeapon[i][WPN_TEAM]) != WPN_TEAM_T && WeaponAcces:str_to_num(PrimaryWeapon[i][WPN_ACCES]) == WPN_ACCES_VIP)
					VIPWeapon++
			}
			
			if(UltimateWeapon) {
				if(get_user_flags(id) & ADMIN_LEVEL)
					menu_additem(Menu, "\rUltimate Weapons", "-2", 0);
				else
					menu_additem(Menu, "\dUltimate Weapons \w- \rOnly Owner's", "-2", 0);
				
			}
			if(VIPWeapon) {
				if(get_user_flags(id) & VIP_LEVEL)
					menu_additem(Menu, "\rVIP Weapons", "-1", 0);
				else
					menu_additem(Menu, "\dVIP Weapons \w- \rOnly VIP's", "-1", 0);
				
			}
			if(UltimateWeapon || VIPWeapon)
				menu_addblank(Menu, 0);
			
			menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
		}
		else {
			menu_setprop(Menu, MPROP_EXITNAME, "Meniu Principal")
			menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL)
		}
		
		#if defined POWERS
		for(new i = 0; i < MAX_LEVEL; i++) {
			for(new k = 1; k < Weapons[WPN_PRIMARY]; k++) {
				if(str_to_num(PrimaryWeapon[k][WPN_LEVEL]) == i && WeaponTeam:str_to_num(PrimaryWeapon[k][WPN_TEAM]) != WPN_TEAM_T && str_to_num(PrimaryWeapon[k][WPN_ACCES]) == VIP)
					AddWeapon(id, Menu, PrimaryWeapon[k][WPN_MENUNAME], PrimaryWeapon[k][WPN_ACCES], PrimaryWeapon[k][WPN_LEVEL], k);
			}
		}
		#else
		for(new i = 1; i < Weapons[WPN_PRIMARY]; i++) {
			if(WeaponTeam:str_to_num(PrimaryWeapon[i][WPN_TEAM]) != WPN_TEAM_T && str_to_num(PrimaryWeapon[i][WPN_ACCES]) == VIP)
				AddWeapon(id, Menu, PrimaryWeapon[i][WPN_MENUNAME], PrimaryWeapon[i][WPN_ACCES], PrimaryWeapon[i][WPN_LEVEL], i);
		}
		#endif
		menu_display(id, Menu, 0);
	}
}

public PrimaryCmd(id, menu, item) {
	if(!is_user_alive(id) || get_user_team(id) != TEAM_ANTIFURIEN || HasChoose[id][WPN_PRIMARY][2]) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	else if(item == MENU_EXIT) {
		menu_destroy(menu);
		PrimaryWeaponMenu(id, 0)
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64], Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data, 5, Name, 63, CallBack);
	menu_destroy(menu);
	
	if(equal(Data, "-2")) {
		if(get_user_flags(id) & ADMIN_LEVEL)
			PrimaryWeaponMenu(id, 2)
		else {
			if(!HasChoose[id][WPN_PRIMARY][2])
				PrimaryWeaponMenu(id, 0)
			else if(!HasChoose[id][WPN_SECONDARY][2])
				SecondaryWeaponMenu(id)
			else if(!HasChoose[id][WPN_KNIFE][2])
				KnifesMenu(id)
			ColorChat(id, "!t%s!gPentru a cumpara!t Admin!g adauga ID:!t %s", Prefix, Contact);
		}
	}
	else if(equal(Data, "-1")) {
		if(get_user_flags(id) & VIP_LEVEL)
			PrimaryWeaponMenu(id, 1)
		else {
			if(!HasChoose[id][WPN_PRIMARY][2])
				PrimaryWeaponMenu(id, 0)
			else if(!HasChoose[id][WPN_SECONDARY][2])
				SecondaryWeaponMenu(id)
			else if(!HasChoose[id][WPN_KNIFE][2])
				KnifesMenu(id)
			ColorChat(id, "!t%s!gPentru a cumpara!t VIP!g adauga ID:!t %s", Prefix, Contact);
		}
	}
	else {
		GivePrimary(id, str_to_num(Data))
		
		if(!HasChoose[id][WPN_PRIMARY][2])
			PrimaryWeaponMenu(id, 0)
		else
			SecondaryWeaponMenu(id)
	}
	return PLUGIN_HANDLED;
}

public SecondaryWeaponMenu(id) {
	if(is_user_alive(id)  && get_user_team(id) == TEAM_ANTIFURIEN && !HasChoose[id][WPN_SECONDARY][2]) {
		menu_cancel(id);
		
		Menu = menu_create("\rSecundar", "SecondaryCmd");
		
		#if defined POWERS		
		for(new i = 0; i < MAX_LEVEL; i++) {
			for(new k = 1; k < Weapons[WPN_SECONDARY]; k++) {
				if(WeaponTeam:str_to_num(SecondaryWeapon[k][WPN_TEAM]) != WPN_TEAM_T && str_to_num(SecondaryWeapon[k][WPN_LEVEL]) == i)
					AddWeapon(id, Menu, SecondaryWeapon[k][WPN_MENUNAME], SecondaryWeapon[k][WPN_ACCES], SecondaryWeapon[k][WPN_LEVEL], k);
			}
		}		
		#else
		for(new i = 1; i < Weapons[WPN_SECONDARY]; i++) {
			if(WeaponTeam:str_to_num(SecondaryWeapon[i][WPN_TEAM]) != WPN_TEAM_T)
				AddWeapon(id, Menu, SecondaryWeapon[i][WPN_MENUNAME], SecondaryWeapon[i][WPN_ACCES], SecondaryWeapon[i][WPN_LEVEL], i);
		}
		#endif
		menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
		menu_display(id, Menu, 0);
	}
	return PLUGIN_CONTINUE;
}

public SecondaryCmd(id, menu, item) {
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_team(id) != TEAM_ANTIFURIEN || HasChoose[id][WPN_SECONDARY][2]) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64], Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data, 5, Name, 63, CallBack);
	menu_destroy(menu);
	
	GiveSecondary(id, str_to_num(Data))
	
	if(!HasChoose[id][WPN_SECONDARY][2])
		SecondaryWeaponMenu(id)
	else
		KnifesMenu(id)
	
	return PLUGIN_HANDLED;
}

public KnifesMenu(id) {
	if(is_user_alive(id)  && get_user_team(id) == TEAM_ANTIFURIEN && !HasChoose[id][WPN_KNIFE][2]) {
		menu_cancel(id);
		
		Menu = menu_create("\rCutit", "KnifesCmd");
		
		#if defined POWERS		
		for(new i = 0; i < MAX_LEVEL; i++) {
			for(new k = 1; k < Weapons[WPN_KNIFE]; k++) {
				if(WeaponTeam:str_to_num(Knife[k][WPN_TEAM]) != WPN_TEAM_T && str_to_num(Knife[k][WPN_LEVEL]) == i)
					AddWeapon(id, Menu, Knife[k][WPN_MENUNAME], Knife[k][WPN_ACCES], Knife[k][WPN_LEVEL], k);
			}
		}
		#else
		for(new i = 1; i < Weapons[WPN_KNIFE]; i++) {
			if(WeaponTeam:str_to_num(Knife[i][WPN_TEAM]) != WPN_TEAM_T)
				AddWeapon(id, Menu, Knife[i][WPN_MENUNAME], Knife[i][WPN_ACCES], Knife[i][WPN_LEVEL], i);
		}
		#endif
		menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
		menu_display(id, Menu, 0);
	}
	return PLUGIN_CONTINUE;
}

public KnifesCmd(id, menu, item) {
	if(item == MENU_EXIT || !is_user_alive(id) || get_user_team(id) != TEAM_ANTIFURIEN || HasChoose[id][WPN_KNIFE][2]) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64], Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	menu_destroy(menu);
	
	GiveKnife(id, str_to_num(Data))
	
	if(!HasChoose[id][WPN_KNIFE][2])
		KnifesMenu(id)
	return PLUGIN_HANDLED;
}

public GiveLastWeapons(id) {
	if(!HasChoose[id][WPN_PRIMARY][2] && WeaponKey[id][WPN_PRIMARY][2] != -1)
		GivePrimary(id, WeaponKey[id][WPN_PRIMARY][2])
	if(!HasChoose[id][WPN_SECONDARY][2] && WeaponKey[id][WPN_SECONDARY][2] != -1)
		GiveSecondary(id, WeaponKey[id][WPN_SECONDARY][2])
	if(!HasChoose[id][WPN_KNIFE][2] && WeaponKey[id][WPN_KNIFE][2] != -1)
		GiveKnife(id, WeaponKey[id][WPN_KNIFE][2])
	
	if(!HasChoose[id][WPN_PRIMARY][2]) {
		WeaponKey[id][WPN_PRIMARY][2] = -1
		PrimaryWeaponMenu(id, 0)
	}
	else if(!HasChoose[id][WPN_SECONDARY][2]) {
		WeaponKey[id][WPN_SECONDARY][2] = -1
		SecondaryWeaponMenu(id)
	}
	else if(!HasChoose[id][WPN_KNIFE][2]) {
		WeaponKey[id][WPN_KNIFE][2] = -1
		KnifesMenu(id)
	}
}

public native_register_primary(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[], WeaponName[], WeaponID, Weapon_List[], WeaponClip[]) {
	param_convert(1)
	param_convert(4)
	param_convert(5)
	param_convert(7)
	param_convert(8)
	
	return RegisterPrimary(MenuName, Team, Acces, Level, WeaponName, WeaponID, Weapon_List, WeaponClip)
}

public native_register_secondary(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[], WeaponName[], WeaponID, Weapon_List[], WeaponClip[]) {
	param_convert(1)
	param_convert(4)
	param_convert(5)
	param_convert(7)
	param_convert(8)
	
	return RegisterSecondary(MenuName, Team, Acces, Level, WeaponName, WeaponID, Weapon_List, WeaponClip)
}

public native_register_knife(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[], Weapon_List[]) {
	param_convert(1)
	param_convert(4)
	param_convert(5)
	
	return RegisterKnife(MenuName, Team, Acces, Level, Weapon_List)
}

public native_register_grenade(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[], WeaponName[], WeaponID, Weapon_List[]) {
	param_convert(1)
	param_convert(4)
	param_convert(5)
	param_convert(7)
	
	return RegisterGrenade(MenuName, Team, Acces, Level, WeaponName, WeaponID, Weapon_List)
}

public native_register_c4(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[], Weapon_List[]) {
	param_convert(1)
	param_convert(4)
	param_convert(5)
	
	return RegisterC4(MenuName, Team, Acces, Level, Weapon_List)
}

public get_weapon(id, weapon_[], CSW_, WeaponID) {
	if(is_user_connected(id)) {
		new Weapon = find_ent_by_owner(-1, weapon_, id);
		
		if(is_user_alive(id) && user_has_weapon(id, CSW_) && pev_valid(Weapon))
			return entity_get_int(Weapon, EV_INT_impulse) == WeaponID ? true : false
	}
	return false
}

public set_weapon(id, WeaponsList:WeaponSet, WeaponID) {
	switch(WeaponSet) {	
		case WPN_PRIMARY:
			return GivePrimary(id, WeaponID)
		case WPN_SECONDARY:
			return GiveSecondary(id, WeaponID)
		case WPN_KNIFE:
			return GiveKnife(id, WeaponID)
		case WPN_GRENADE:
			return GiveGrenade(id, WeaponID)
		case WPN_C4:
			return GiveC4(id, WeaponID)
	}
	return false
}

public get_weapon_data(WeaponsList:WeaponSet, WeaponID, WeaponData:Data, Buffer[], len) {
	param_convert(4)
	
	if(WeaponID > -1 && WeaponID < Weapons[WeaponSet]) {
		switch(WeaponSet) {
			case WPN_PRIMARY: 
				format(Buffer, len, PrimaryWeapon[WeaponID][Data])
			case WPN_SECONDARY: 
				format(Buffer, len, SecondaryWeapon[WeaponID][Data])
			case WPN_KNIFE: 
				format(Buffer, len, Knife[WeaponID][Data])
			case WPN_GRENADE: 
				format(Buffer, len, Grenade[WeaponID][Data])
			case WPN_C4: 
				format(Buffer, len, C4[WeaponID][Data])
		}
	}
}

public set_weapon_data(WeaponsList:WeaponSet, WeaponID, WeaponData:Data, Buffer[]) {
	param_convert(4)
	
	if(WeaponID > -1 && WeaponID < Weapons[WeaponSet]) {
		switch(WeaponSet) {
			case WPN_PRIMARY: 
				format(PrimaryWeapon[WeaponID][Data], 32, Buffer)
			case WPN_SECONDARY: 
				format(PrimaryWeapon[WeaponID][Data], 32, Buffer)
			case WPN_KNIFE: 
				format(PrimaryWeapon[WeaponID][Data], 32, Buffer)
			case WPN_GRENADE: 
				format(Grenade[WeaponID][Data], 32, Buffer)
			case WPN_C4: 
				format(C4[WeaponID][Data], 32, Buffer)
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Stock's |
//==========================================================================================================
public AddWeapon(id, Menu, Name[], Acces[], Level[], WeaponID) {
	new Weapon[64], Num[32];
	if(WeaponAcces:str_to_num(Acces) == WPN_ACCES_VIP && !(get_user_flags(id) & VIP_LEVEL))
		formatex(Weapon, sizeof(Weapon)-1, "\d%s \w- \rOnly VIP", Name);
	else if(WeaponAcces:str_to_num(Acces) == WPN_ACCES_ADMIN && !(get_user_flags(id) & ADMIN_LEVEL))
		formatex(Weapon, sizeof(Weapon)-1, "\d%s \w- \rOnly ADMIN", Name);
	#if defined POWERS
	else if(get_user_level(id) < (str_to_num(Level) > MAX_LEVEL ? MAX_LEVEL : str_to_num(Level)))
		formatex(Weapon, sizeof(Weapon)-1, "\d%s \w- \rLocked \r[\yLevel: \r%d]", Name, (str_to_num(Level) > MAX_LEVEL) ? MAX_LEVEL : str_to_num(Level));
	#endif
	else
		formatex(Weapon, sizeof(Weapon)-1, "\w%s", Name);
	formatex(Num, sizeof(Num)-1, "%d", WeaponID);
	
	menu_additem(Menu, Weapon, Num, 0);
	return
}

public CanAcces(id, Team[], Acces[], Level[]) {
	if(WeaponAcces:str_to_num(Acces) == WPN_ACCES_VIP && !(get_user_flags(id) & VIP_LEVEL) || WeaponAcces:str_to_num(Acces) == WPN_ACCES_ADMIN && !(get_user_flags(id) & ADMIN_LEVEL))
		return false;
	if(WeaponTeam:str_to_num(Team) == WPN_TEAM_T && WeaponTeam:get_user_team(id) != WPN_TEAM_T || WeaponTeam:str_to_num(Team) == WPN_TEAM_CT && WeaponTeam:get_user_team(id) != WPN_TEAM_CT)
		return false;
	#if defined POWERS
	else if(get_user_level(id) < (str_to_num(Level) > MAX_LEVEL ? MAX_LEVEL : str_to_num(Level)))
		return false;
	#endif
	return true;
}

stock RegisterPrimary(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[] = "0", WeaponName[], WeaponID, Weapon_List[] = "None", WeaponClip[] = "0") {
	if(Weapons[WPN_PRIMARY] < 1)
		Weapons[WPN_PRIMARY] = 1
	
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_MENUNAME], 	32, MenuName)
	if(Team > WeaponTeam || Team < WPN_TEAM_ALL)
		format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_TEAM], 	32, "%d", WPN_TEAM_ALL)
	else
		format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_TEAM], 	32, "%d", Team)
	if(Acces > WeaponAcces || Acces < WPN_ACCES_ALL)
		format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_ACCES], 	32, "%d", WPN_ACCES_ALL)
	else
		format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_ACCES], 	32, "%d", Acces)
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_LEVEL], 		32, Level)
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_NAME], 		32, WeaponName)
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_ID], 		32, "%d", WeaponID)
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_LIST], 		32, Weapon_List)
	format(PrimaryWeapon[Weapons[WPN_PRIMARY]][WPN_CLIP], 		32, WeaponClip)
	Weapons[WPN_PRIMARY]++
	
	return Weapons[WPN_PRIMARY] - 1
}

stock RegisterSecondary(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[] = "0", WeaponName[], WeaponID, Weapon_List[] = "None", WeaponClip[] = "0") {
	if(Weapons[WPN_SECONDARY] < 1)
		Weapons[WPN_SECONDARY] = 1
	
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_MENUNAME], 		32, MenuName)
	if(Team > WeaponTeam || Team < WPN_TEAM_ALL)
		format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_TEAM], 	32, "%d", WPN_TEAM_ALL)
	else
		format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_TEAM], 	32, "%d", Team)
	if(Acces > WeaponAcces || Acces < WPN_ACCES_ALL)
		format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_ACCES], 	32, "%d", WPN_ACCES_ALL)
	else
		format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_ACCES], 	32, "%d", Acces)
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_LEVEL], 		32, Level)
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_NAME], 		32, WeaponName)
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_ID], 		32, "%d", WeaponID)
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_LIST], 		32, Weapon_List)
	format(SecondaryWeapon[Weapons[WPN_SECONDARY]][WPN_CLIP], 		32, WeaponClip)
	Weapons[WPN_SECONDARY]++
	
	return Weapons[WPN_SECONDARY] - 1
}

stock RegisterKnife(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[] = "0", Weapon_List[] = "None") {
	if(Weapons[WPN_KNIFE] < 1)
		Weapons[WPN_KNIFE] = 1
	
	format(Knife[Weapons[WPN_KNIFE]][WPN_MENUNAME], 	32, MenuName)
	if(Team > WeaponTeam || Team < WPN_TEAM_ALL)
		format(Knife[Weapons[WPN_KNIFE]][WPN_TEAM], 	32, "%d", WPN_TEAM_ALL)
	else
		format(Knife[Weapons[WPN_KNIFE]][WPN_TEAM], 	32, "%d", Team)
	if(Acces > WeaponAcces || Acces < WPN_ACCES_ALL)
		format(Knife[Weapons[WPN_KNIFE]][WPN_ACCES], 	32, "%d", WPN_ACCES_ALL)
	else
		format(Knife[Weapons[WPN_KNIFE]][WPN_ACCES], 	32, "%d", Acces)
	format(Knife[Weapons[WPN_KNIFE]][WPN_LEVEL], 		32, Level)
	format(Knife[Weapons[WPN_KNIFE]][WPN_LIST], 		32, Weapon_List)
	Weapons[WPN_KNIFE]++
	
	return Weapons[WPN_KNIFE] - 1
}

stock RegisterGrenade(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[] = "0", WeaponName[], WeaponID, Weapon_List[] = "None") {
	if(Weapons[WPN_GRENADE] < 1)
		Weapons[WPN_GRENADE] = 1
	
	format(Grenade[Weapons[WPN_GRENADE]][WPN_MENUNAME], 		32, MenuName)
	if(Team > WeaponTeam || Team < WPN_TEAM_ALL)
		format(Grenade[Weapons[WPN_GRENADE]][WPN_TEAM], 	32, "%d", WPN_TEAM_ALL)
	else
		format(Grenade[Weapons[WPN_GRENADE]][WPN_TEAM], 	32, "%d", Team)
	if(Acces > WeaponAcces || Acces < WPN_ACCES_ALL)
		format(Grenade[Weapons[WPN_GRENADE]][WPN_ACCES], 	32, "%d", WPN_ACCES_ALL)
	else
		format(Grenade[Weapons[WPN_GRENADE]][WPN_ACCES], 	32, "%d", Acces)
	format(Grenade[Weapons[WPN_GRENADE]][WPN_LEVEL], 		32, Level)
	format(Grenade[Weapons[WPN_GRENADE]][WPN_NAME], 		32, WeaponName)
	format(Grenade[Weapons[WPN_GRENADE]][WPN_ID], 			32, "%d", WeaponID)
	format(Grenade[Weapons[WPN_GRENADE]][WPN_LIST], 		32, Weapon_List)
	Weapons[WPN_GRENADE]++
	
	return Weapons[WPN_GRENADE] - 1
}

stock RegisterC4(MenuName[], WeaponTeam:Team, WeaponAcces:Acces, Level[] = "0", Weapon_List[] = "None") {
	if(Weapons[WPN_C4] < 1)
		Weapons[WPN_C4] = 1
	
	format(C4[Weapons[WPN_C4]][WPN_MENUNAME], 	32, MenuName)
	if(Team > WeaponTeam || Team < WPN_TEAM_ALL)
		format(C4[Weapons[WPN_C4]][WPN_TEAM], 	32, "%d", WPN_TEAM_ALL)
	else
		format(C4[Weapons[WPN_C4]][WPN_TEAM], 	32, "%d", Team)
	if(Acces > WeaponAcces || Acces < WPN_ACCES_ALL)
		format(C4[Weapons[WPN_C4]][WPN_ACCES], 	32, "%d", WPN_ACCES_ALL)
	else
		format(C4[Weapons[WPN_C4]][WPN_ACCES], 	32, "%d", Acces)
	format(C4[Weapons[WPN_C4]][WPN_LEVEL], 		32, Level)
	format(C4[Weapons[WPN_C4]][WPN_LIST], 		32, Weapon_List)
	Weapons[WPN_C4]++
	
	return Weapons[WPN_C4] - 1
}

public GivePrimary(id, WeaponID) {
	if(is_user_alive(id)) {
		if(WeaponID > 0 && WeaponID < Weapons[WPN_PRIMARY]) {
			if(CanAcces(id, PrimaryWeapon[WeaponID][WPN_TEAM], PrimaryWeapon[WeaponID][WPN_ACCES], PrimaryWeapon[WeaponID][WPN_LEVEL])) {
				new Weapon, Impulse = entity_get_int(id, EV_INT_impulse)
				HasChoose[id][WPN_PRIMARY][get_user_team(id)] = true
				WeaponKey[id][WPN_PRIMARY][get_user_team(id)] = WeaponID
				/*if(get_user_team(id) == TEAM_FURIEN)
					special_primary(id, true)*/
				
				drop_primary_weapons(id);
				
				if(equal(PrimaryWeapon[WeaponID][WPN_LIST], "None"))
					WeaponList(id, str_to_num(PrimaryWeapon[WeaponID][WPN_ID]), PrimaryWeapon[WeaponID][WPN_NAME], 0)
				else
					WeaponList(id, str_to_num(PrimaryWeapon[WeaponID][WPN_ID]), PrimaryWeapon[WeaponID][WPN_LIST], 0)
				
				entity_set_int(id, EV_INT_impulse, WeaponID);
				Weapon = fm_give_item(id, PrimaryWeapon[WeaponID][WPN_NAME]);
				entity_set_int(Weapon, EV_INT_impulse, WeaponID)
				entity_set_int(id, EV_INT_impulse, Impulse);
				
				if(!equal(PrimaryWeapon[WeaponID][WPN_CLIP], "0"))
					cs_set_weapon_ammo(Weapon, str_to_num(PrimaryWeapon[WeaponID][WPN_CLIP]))
				return true
			}
		}
	}
	return false
}

public GiveSecondary(id, WeaponID) {
	if(is_user_alive(id)) {
		if(WeaponID > 0 && WeaponID < Weapons[WPN_SECONDARY]) {
			if(CanAcces(id, SecondaryWeapon[WeaponID][WPN_TEAM], SecondaryWeapon[WeaponID][WPN_ACCES], SecondaryWeapon[WeaponID][WPN_LEVEL])) {
				new Weapon, Impulse = entity_get_int(id, EV_INT_impulse)
				HasChoose[id][WPN_SECONDARY][get_user_team(id)] = true
				WeaponKey[id][WPN_SECONDARY][get_user_team(id)] = WeaponID
				/*if(get_user_team(id) == TEAM_FURIEN)
					special_secondary(id, true)*/
				
				drop_secondary_weapons(id);
				
				if(equal(SecondaryWeapon[WeaponID][WPN_LIST], "None"))
					WeaponList(id, str_to_num(SecondaryWeapon[WeaponID][WPN_ID]), SecondaryWeapon[WeaponID][WPN_NAME], 0)
				else
					WeaponList(id, str_to_num(SecondaryWeapon[WeaponID][WPN_ID]), SecondaryWeapon[WeaponID][WPN_LIST], 0)
				
				entity_set_int(id, EV_INT_impulse, WeaponID);
				Weapon = fm_give_item(id, SecondaryWeapon[WeaponID][WPN_NAME]);
				entity_set_int(Weapon, EV_INT_impulse, WeaponID)
				entity_set_int(id, EV_INT_impulse, Impulse);
				
				if(!equal(SecondaryWeapon[WeaponID][WPN_CLIP], "0"))
					cs_set_weapon_ammo(Weapon, str_to_num(SecondaryWeapon[WeaponID][WPN_CLIP]))
				return true
			}
		}
	}
	return false
}

public GiveKnife(id, WeaponID) {
	if(is_user_alive(id)) {
		if(WeaponID > 0 && WeaponID < Weapons[WPN_KNIFE]) {
			if(CanAcces(id, Knife[WeaponID][WPN_TEAM], Knife[WeaponID][WPN_ACCES], Knife[WeaponID][WPN_LEVEL])) {
				new Weapon, Impulse = entity_get_int(id, EV_INT_impulse)
				HasChoose[id][WPN_KNIFE][get_user_team(id)] = true
				WeaponKey[id][WPN_KNIFE][get_user_team(id)] = WeaponID
				
				bacon_strip_weapon(id, "weapon_knife");
				
				if(equal(Knife[WeaponID][WPN_LIST], "None"))
					WeaponList(id, CSW_KNIFE, Knife[WeaponID][WPN_NAME], 0)
				else
					WeaponList(id, CSW_KNIFE, Knife[WeaponID][WPN_LIST], 0)
				
				entity_set_int(id, EV_INT_impulse, WeaponID);
				Weapon = fm_give_item(id, "weapon_knife");
				entity_set_int(Weapon, EV_INT_impulse, WeaponID)
				entity_set_int(id, EV_INT_impulse, Impulse);
				return true
			}
		}
	}
	return false
}

public GiveGrenade(id, WeaponID) {
	if(is_user_alive(id)) {
		if(WeaponID > 0 && WeaponID < Weapons[WPN_GRENADE]) {
			if(CanAcces(id, Grenade[WeaponID][WPN_TEAM], Grenade[WeaponID][WPN_ACCES], Grenade[WeaponID][WPN_LEVEL])) {
				new Weapon, Impulse = entity_get_int(id, EV_INT_impulse)
				HasChoose[id][WPN_GRENADE][get_user_team(id)] = true
				WeaponKey[id][WPN_GRENADE][get_user_team(id)] = WeaponID
				
				bacon_strip_weapon(id, Grenade[WeaponID][WPN_NAME]);
				
				if(equal(Grenade[WeaponID][WPN_LIST], "None"))
					WeaponList(id, str_to_num(Grenade[WeaponID][WPN_ID]), Grenade[WeaponID][WPN_NAME], 0)
				else
					WeaponList(id, str_to_num(Grenade[WeaponID][WPN_ID]), Grenade[WeaponID][WPN_LIST], 0)
				
				entity_set_int(id, EV_INT_impulse, WeaponID);
				Weapon = fm_give_item(id, Grenade[WeaponID][WPN_NAME]);
				entity_set_int(Weapon, EV_INT_impulse, WeaponID)
				entity_set_int(id, EV_INT_impulse, Impulse);
				return true
			}
		}
	}
	return false
}

public GiveC4(id, WeaponID) {
	if(is_user_alive(id)) {
		if(WeaponID > 0 && WeaponID < Weapons[WPN_C4]) {
			if(CanAcces(id, C4[WeaponID][WPN_TEAM], C4[WeaponID][WPN_ACCES], C4[WeaponID][WPN_LEVEL])) {
				new Weapon, Impulse = entity_get_int(id, EV_INT_impulse)
				HasChoose[id][WPN_C4][get_user_team(id)] = true
				WeaponKey[id][WPN_C4][get_user_team(id)] = WeaponID
				
				bacon_strip_weapon(id, "weapon_c4");
				
				if(equal(C4[WeaponID][WPN_LIST], "None"))
					WeaponList(id, CSW_C4, C4[WeaponID][WPN_NAME], 0)
				else
					WeaponList(id, CSW_C4, C4[WeaponID][WPN_LIST], 0)
				
				entity_set_int(id, EV_INT_impulse, WeaponID);
				Weapon = fm_give_item(id, "weapon_c4");
				entity_set_int(Weapon, EV_INT_impulse, WeaponID)
				entity_set_int(id, EV_INT_impulse, Impulse);
				return true
			}
		}
	}
	return false
}

stock WeaponList(id, CSW_WEAPON, const Weapon[], Flag=0) {
	switch(CSW_WEAPON) {
		case CSW_P228: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(9);			// PrimaryAmmoID
			write_byte(52);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(3);			// NumberInSlot (1...N)
			write_byte(CSW_P228);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_SCOUT: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(2);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(9);			// NumberInSlot (1...N)
			write_byte(CSW_SCOUT);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_HEGRENADE: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(12);			// PrimaryAmmoID
			write_byte(1);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(3);			// SlotID (0...N)
			write_byte(1);			// NumberInSlot (1...N)
			write_byte(CSW_HEGRENADE);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_XM1014: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(5);			// PrimaryAmmoID
			write_byte(32);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(12);			// NumberInSlot (1...N)
			write_byte(CSW_XM1014);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_C4: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(14);			// PrimaryAmmoID
			write_byte(1);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(4);			// SlotID (0...N)
			write_byte(3);			// NumberInSlot (1...N)
			write_byte(CSW_C4);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_MAC10: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(6);			// PrimaryAmmoID
			write_byte(100);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(13);			// NumberInSlot (1...N)
			write_byte(CSW_MAC10);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_AUG: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(14);			// NumberInSlot (1...N)
			write_byte(CSW_AUG);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_SMOKEGRENADE: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(13);			// PrimaryAmmoID
			write_byte(1);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(3);			// SlotID (0...N)
			write_byte(3);			// NumberInSlot (1...N)
			write_byte(CSW_SMOKEGRENADE);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_ELITE: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(10);			// PrimaryAmmoID
			write_byte(120);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(5);			// NumberInSlot (1...N)
			write_byte(CSW_ELITE);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_FIVESEVEN: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(7);			// PrimaryAmmoID
			write_byte(100);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(6);			// NumberInSlot (1...N)
			write_byte(CSW_FIVESEVEN);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_UMP45: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(6);			// PrimaryAmmoID
			write_byte(100);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(15);			// NumberInSlot (1...N)
			write_byte(CSW_UMP45);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_SG550: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(16);			// NumberInSlot (1...N)
			write_byte(CSW_SG550);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_GALIL: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(17);			// NumberInSlot (1...N)
			write_byte(CSW_GALIL);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_FAMAS: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(18);			// NumberInSlot (1...N)
			write_byte(CSW_FAMAS);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_USP: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(6);			// PrimaryAmmoID
			write_byte(100);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(4);			// NumberInSlot (1...N)
			write_byte(CSW_USP);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_GLOCK18: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(10);			// PrimaryAmmoID
			write_byte(120);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(2);			// NumberInSlot (1...N)
			write_byte(CSW_GLOCK18);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_AWP: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(1);			// PrimaryAmmoID
			write_byte(30);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(2);			// NumberInSlot (1...N)
			write_byte(CSW_AWP);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_MP5NAVY: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(10);			// PrimaryAmmoID
			write_byte(120);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(7);			// NumberInSlot (1...N)
			write_byte(CSW_MP5NAVY);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_M249: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(3);			// PrimaryAmmoID
			write_byte(200);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(4);			// NumberInSlot (1...N)
			write_byte(CSW_M249);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_M3: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(5);			// PrimaryAmmoID
			write_byte(32);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(5);			// NumberInSlot (1...N)
			write_byte(CSW_M3);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_M4A1: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(6);			// NumberInSlot (1...N)
			write_byte(CSW_M4A1);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_TMP: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(10);			// PrimaryAmmoID
			write_byte(120);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(11);			// NumberInSlot (1...N)
			write_byte(CSW_TMP);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_G3SG1: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(2);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(3);			// NumberInSlot (1...N)
			write_byte(CSW_G3SG1);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_FLASHBANG: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(11);			// PrimaryAmmoID
			write_byte(2);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(3);			// SlotID (0...N)
			write_byte(2);			// NumberInSlot (1...N)
			write_byte(CSW_FLASHBANG);	// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_DEAGLE: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(8);			// PrimaryAmmoID
			write_byte(35);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(1);			// SlotID (0...N)
			write_byte(1);			// NumberInSlot (1...N)
			write_byte(CSW_DEAGLE);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_SG552: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(10);			// NumberInSlot (1...N)
			write_byte(CSW_SG552);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_AK47: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(2);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(1);			// NumberInSlot (1...N)
			write_byte(CSW_AK47);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_KNIFE: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(-1);			// PrimaryAmmoID
			write_byte(-1);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(2);			// SlotID (0...N)
			write_byte(1);			// NumberInSlot (1...N)
			write_byte(CSW_KNIFE);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
		case CSW_P90: {
			message_begin(MSG_ONE, MSGID_WeaponList, _, id);
			write_string(Weapon);		// WeaponName
			write_byte(7);			// PrimaryAmmoID
			write_byte(100);		// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(8);			// NumberInSlot (1...N)
			write_byte(CSW_P90);		// WeaponID
			write_byte(Flag);		// Flags
			message_end();
		}
	}
}

public death_message(killer, victim, const WeaponName[]) {
	if(is_user_connected(killer) && is_user_alive(victim)) {
		set_msg_block(MSGID_DeathMsg, BLOCK_SET);
		ExecuteHamB(Ham_Killed, victim, killer);
		set_msg_block(MSGID_DeathMsg, BLOCK_NOT);
		cs_set_user_money(killer, cs_get_user_money(killer) + 300);
		
		make_deathmsg(killer, victim, 0, WeaponName);
		
		message_begin(MSG_BROADCAST, MSGID_ScoreInfo);
		write_byte(killer); 				// id
		write_short(pev(killer, pev_frags)); 		// frags
		write_short(cs_get_user_deaths(killer)); 	// deaths
		write_short(0); 				// class?
		write_short(get_user_team(killer)); 		// team
		message_end();
		
		message_begin(MSG_BROADCAST, MSGID_ScoreInfo);
		write_byte(victim); 				// id
		write_short(pev(victim, pev_frags)); 		// frags
		write_short(cs_get_user_deaths(victim)); 	// deaths
		write_short(0); 				// class?
		write_short(get_user_team(victim)); 		// team
		message_end();
	}
}

public make_knockback(id, Float:origin[3], Float:maxspeed) {
	if(is_user_alive(id)) {
		new Float:Velocity[3], Float:Origin[3], Float:Distance[3],
		Float:Time = (vector_distance(Origin,origin) / maxspeed);
		entity_get_vector(id, EV_VEC_origin, Origin);
		
		Distance[0] = Origin[0] - origin[0], Distance[1] = Origin[1] - origin[1], Distance[2] = Origin[2] - origin[2];
		Velocity[0] = Distance[0] / Time, Velocity[1] = Distance[1] / Time, Velocity[2] = Distance[2] / Time;
		
		entity_set_vector(id, EV_VEC_velocity, Velocity);
	}
}

public make_blood(id, Amount) {
	if(is_user_alive(id)) {
		new BloodColor = ExecuteHam(Ham_BloodColor, id);
		
		if(BloodColor != -1) {
			new Float:Origin[3]
			pev(id, pev_origin, Origin);
			Amount *= 2; //according to HLSDK
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BLOODSPRITE);
			write_coord(floatround(Origin[0]));
			write_coord(floatround(Origin[1]));
			write_coord(floatround(Origin[2]));
			write_short(BloodSpray);
			write_short(BloodDrop);
			write_byte(BloodColor);
			write_byte(min(max(3, Amount/10), 16));
			message_end();
		}
	}
}

public make_bullet(id, Float:Origin[3]) {
	if(is_user_alive(id)) {
		new Target, Body;
		get_user_aiming(id, Target, Body, 999999);
		
		if(is_user_connected(Target)) {
			new Float:Start[3], Float:End[3], Float:Res[3], Float:Vel[3], Res2;
			pev(id, pev_origin, Start);
			
			velocity_by_aim(id, 64, Vel);
			
			Start[0] = Origin[0];
			Start[1] = Origin[1];
			Start[2] = Origin[2];
			End[0] = Start[0]+Vel[0];
			End[1] = Start[1]+Vel[1];
			End[2] = Start[2]+Vel[2];
			
			engfunc(EngFunc_TraceLine, Start, End, 0, Target, Res2);
			get_tr2(Res2, TR_vecEndPos, Res);
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY) ;
			write_byte(TE_BLOODSPRITE);
			write_coord(floatround(Start[0]));
			write_coord(floatround(Start[1]));
			write_coord(floatround(Start[2]));
			write_short(BloodSpray);
			write_short(BloodDrop);
			write_byte(70);
			write_byte(random_num(1,2));
			message_end();
			
			
		} 
		else {
			if(Target) {
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_DECAL);
				write_coord(floatround(Origin[0]));
				write_coord(floatround(Origin[1]));
				write_coord(floatround(Origin[2]));
				write_byte(41);
				write_short(Target);
				message_end();
			} 
			else {
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_WORLDDECAL);
				write_coord(floatround(Origin[0]));
				write_coord(floatround(Origin[1]));
				write_coord(floatround(Origin[2]));
				write_byte(41);
				message_end();
			}
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_GUNSHOTDECAL);
			write_coord(floatround(Origin[0]));
			write_coord(floatround(Origin[1]));
			write_coord(floatround(Origin[2]));
			write_short(id);
			write_byte(41);
			message_end();
		}
	}
}

public set_weapon_anim(id, anim) {
	if(is_user_connected(id)) {
		set_pev(id, pev_weaponanim, anim);
		message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
		write_byte(anim);
		write_byte(pev(id, pev_body));
		message_end();
	}
}

public get_damage_body(body, Float:damage) {
	switch(body) {
		case HIT_HEAD:
			damage *= 2.0;
		case HIT_STOMACH: 
			damage *= 1.0;
		case HIT_CHEST: 
			damage *= 1.5;
		case HIT_LEFTARM: 
			damage *= 0.75;
		case HIT_RIGHTARM: 
			damage *= 0.75;
		case HIT_LEFTLEG: 
			damage *= 0.75;
		case HIT_RIGHTLEG: 
			damage *= 0.75;
		default: damage *= 1.0;
	}
	
	return floatround(damage);
}	

public velocity_to_aim(id, Float:Origin[3], Speed, Float:Velocity[3]) {
	if(is_user_alive(id)) {
		new Float:AimOrigin[3]
		fm_get_aim_origin(id, AimOrigin)
		
		Velocity[0] = AimOrigin[0] - Origin[0]
		Velocity[1] = AimOrigin[1] - Origin[1]
		Velocity[2] = AimOrigin[2] - Origin[2]
		
		new Float:X
		X = floatsqroot(Speed*Speed / (Velocity[0]*Velocity[0] + Velocity[1]*Velocity[1] + Velocity[2]*Velocity[2]))
		
		Velocity[0] *= X
		Velocity[1] *= X
		Velocity[2] *= X
	}
}

public get_position(id, Float:forw, Float:right, Float:up, Float:Start[]) {
	if(is_user_alive(id)) {
		new Float:Origin[3], Float:Angle[3], Float:Forward[3], Float:Right[3], Float:Up[3]
		pev(id, pev_origin, Origin)
		pev(id, pev_view_ofs, Up)
		xs_vec_add(Origin, Up, Origin)
		if(id <= get_maxplayers())
			pev(id, pev_v_angle, Angle)
		else 
			pev(id, pev_angles, Angle)
		
		angle_vector(Angle, ANGLEVECTOR_FORWARD, Forward)
		angle_vector(Angle, ANGLEVECTOR_RIGHT, Right)
		angle_vector(Angle, ANGLEVECTOR_UP, Up)
		
		Start[0] = Origin[0] + Forward[0] * forw + Right[0] * right + Up[0] * up
		Start[1] = Origin[1] + Forward[1] * forw + Right[1] * right + Up[1] * up
		Start[2] = Origin[2] + Forward[2] * forw + Right[2] * right + Up[2] * up
	}
}

public fm_get_user_bpammo(id, CSW_WEAPON) {
	if(is_user_alive(id)) {
		switch(CSW_WEAPON) {
			case CSW_AWP:
				return get_pdata_int(id, 377)
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: 
				return get_pdata_int(id, 378)
			case CSW_M249: 
				return get_pdata_int(id, 379)
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, CSW_SG550, CSW_GALI, CSW_SG552: 
				return get_pdata_int(id, 380)
			case CSW_M3, CSW_XM1014: 
				return get_pdata_int(id, 381)
			case CSW_USP, CSW_UMP45, CSW_MAC10: 
				return get_pdata_int(id, 382)
			case CSW_FIVESEVEN, CSW_P90: 
				return get_pdata_int(id, 383)
			case CSW_DEAGLE: 
				return get_pdata_int(id, 384)
			case CSW_P228: 
				return get_pdata_int(id, 385)
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, CSW_MP5NAVY: 
				return get_pdata_int(id, 386)
			default: return 0
		}
	}
	return 0
}

public fm_set_user_bpammo(id, CSW_WEAPON, Amount) {
	if(is_user_alive(id)) {
		switch(CSW_WEAPON) {
			case CSW_AWP:
				set_pdata_int(id, 377, Amount)
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: 
				set_pdata_int(id, 378, Amount)
			case CSW_M249: 
				set_pdata_int(id, 379, Amount)
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, CSW_SG550, CSW_GALI, CSW_SG552: 
				set_pdata_int(id, 380, Amount)
			case CSW_M3, CSW_XM1014: 
				set_pdata_int(id, 381, Amount)
			case CSW_USP, CSW_UMP45, CSW_MAC10: 
				set_pdata_int(id, 382, Amount)
			case CSW_FIVESEVEN, CSW_P90: 
				set_pdata_int(id, 383, Amount)
			case CSW_DEAGLE: 
				set_pdata_int(id, 384, Amount)
			case CSW_P228: 
				set_pdata_int(id, 385, Amount)
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, CSW_MP5NAVY: 
				set_pdata_int(id, 386, Amount)
			default: return 0
		}
	}
	return 1
}

public drop_primary_weapons(id) {
	if(is_user_alive(id)) {
		new Weapons[32], Num = 0, WeaponID;
		get_user_weapons(id, Weapons, Num);
		
		for(new i = 0; i < Num; i++) {
			WeaponID = Weapons[i];
			
			if(((1<<WeaponID) & PRIMARY_WEAPONS_BITSUM)) {
				new WName[32];
				get_weaponname(WeaponID, WName, charsmax(WName));
				
				engclient_cmd(id, "drop", WName);
			}
		}
	}
}

public drop_secondary_weapons(id) {
	if(is_user_alive(id)) {
		new Weapons[32], Num = 0, WeaponID;
		get_user_weapons(id, Weapons, Num);
		
		for(new i = 0; i < Num; i++) {
			WeaponID = Weapons[i];
			
			if(((1<<WeaponID) & SECONDARY_WEAPONS_BITSUM)) {
				new WName[32];
				get_weaponname(WeaponID, WName, charsmax(WName));
				
				engclient_cmd(id, "drop", WName);
			}
		}
	}
}

public bacon_strip_weapon(index, weapon[]) {
	if(is_user_alive(index) && equal(weapon, "weapon_", 7)) {
		new WeaponID = get_weaponid(weapon)
		
		if(WeaponID) {
			new WeaponEnt = fm_find_ent_by_owner(-1, weapon, index)
			
			if(WeaponEnt) {
				if(get_user_weapon(index) == WeaponID) 
					ExecuteHamB(Ham_Weapon_RetireWeapon, WeaponEnt)
				
				ExecuteHamB(Ham_RemovePlayerItem, index, WeaponEnt)
				ExecuteHamB(Ham_Item_Kill, WeaponEnt)
				set_pev(index, pev_weapons, pev(index, pev_weapons) & ~(1<<WeaponID))
			}
		}
	}
}

stock HudMessage(const id, const message[], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 0.01, Float:holdtime = 3.0, Float:fadeintime = 0.01, Float:fadeouttime = 0.01) {
	new Players[32], Num = 1, Player;
	
	if(id) Players[0] = id;
	else get_players(Players, Num, "ch"); {
		for(new i = 0; i < Num; i++) {
			Player = Players[i]
			
			if(is_user_connected(Player)) {
				new color = (clamp(blue, 0, 255) + (clamp(green, 0, 255) << 8) + (clamp(red, 0, 255) << 16))
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, Player);
				write_byte(strlen(message) + 31);
				write_byte(DRC_CMD_MESSAGE);
				write_byte(effects);
				write_long(color);
				write_long(_:x);
				write_long(_:y);
				write_long(_:fadeintime);
				write_long(_:fadeouttime);
				write_long(_:holdtime);
				write_long(_:fxtime);
				write_string(message);
				message_end();
			}
		}
	}
}

stock ColorChat(const id, const input[], any:...) {
	new Players[32], Message[191], Num = 1, Player;
	vformat(Message, 190, input, 3);
	
	replace_all(Message, 190, "!g", "^4");
	replace_all(Message, 190, "!y", "^1");
	replace_all(Message, 190, "!t", "^3");
	
	if(id) Players[0] = id;
	else get_players(Players, Num, "ch"); {
		for(new i = 0; i < Num; i++) {
			Player = Players[i]
			
			if(is_user_connected(Player)) {
				message_begin(MSG_ONE_UNRELIABLE, MSGID_SayText, _, Player);
				write_byte(Player);
				write_string(Message);
				message_end();
			}
		}
	} 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/