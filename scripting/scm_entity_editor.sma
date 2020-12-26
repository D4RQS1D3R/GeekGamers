/*
	----------------------
	-*- Licensing Info -*-
	----------------------
	
	Semiclip Mod: Entity Editor
	by schmurgel1983(@msn.com)
	Copyright (C) 2014-2017 Stefan "schmurgel1983" Focke
	
	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.
	
	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
	Public License for more details.
	
	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	No warranties of any kind. Use at your own risk.
	
*/

/*================================================================================
 [Plugin Customization]
=================================================================================*/

#define MAX_STORAGE 64	/* Max stored entities per func_* ¬ 64 */

#define ADMIN_ACCESS_LEVEL ADMIN_RCON	/* Admin level for Editor */

/*	Uncomment the line below to have menu sound effects.
	*/
#define SOUND_EFFECTS

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#pragma semicolon 1

/*================================================================================
 [TODO]
 
 ? emulate use or touch
 
=================================================================================*/

/*================================================================================
 [Constants, Offsets and Defines]
=================================================================================*/

const m_aButtons = 205;
const linux_diff = 5;
const mac_diff   = 5;	/* the same? (i don't have a mac pc or server) */
const pdata_safe = 2;

const MENU_KEYS = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

/* All supported entity classes */
new const ENTITY_CLASSES[][] =
{
	"func_button",
	"func_door",
	"func_door_rotating",
	"func_guntarget",
	"func_pendulum",
	"func_plat",
	"func_platrot",
	"func_rot_button",
	"func_rotating",
	"func_tank",
	"func_trackchange",
	"func_tracktrain",
	"func_train",
	"func_vehicle",
	"momentary_door",
	"momentary_rot_button"
};
const CLASS_SIZE = sizeof(ENTITY_CLASSES);

#define SF_VEHICLE_PASSABLE  0x0008
#define SF_ROTATING_NOTSOLID 0x0040

/*================================================================================
 [Global Variables]
=================================================================================*/

/* Server Global */
new g_iListMenuId = -1,
	g_cListMenuId = -1;

new g_szEntitiesFile[128],
	g_szMapName[32];

new g_iEntityNum[CLASS_SIZE],
	g_iEntityIndex[CLASS_SIZE][MAX_STORAGE],
	g_iEntityTrigger[CLASS_SIZE][MAX_STORAGE],
	g_iEntityTarget[CLASS_SIZE][MAX_STORAGE],
	g_iEntityData[3];

new g_szEntityModel[CLASS_SIZE][MAX_STORAGE][6];

new g_iSpriteDot;

new g_iColoredMenus;

/* Client Global */
new g_iAbsBoxEnt[33],
	g_iMenuData[33][3];

/*================================================================================
 [Macros]
=================================================================================*/

#define MENU_FUNC		g_iMenuData[id][0]
#define MENU_ENTITY		g_iMenuData[id][1]
#define MENU_PAGE		g_iMenuData[id][2]

#define DATA_ENABLE_ENTITY		g_iEntityData[0]
#define DATA_CURRENT_DMG		g_iEntityData[1]
#define DATA_ORIGINAL_DMG		g_iEntityData[2]

#define get_entity_data(%1)		pev(%1, pev_vuser1, g_iEntityData)
#define set_entity_data(%1)		set_pev(%1, pev_vuser1, g_iEntityData)

#define fm_write_coord(%1)				engfunc(EngFunc_WriteCoord, %1)
#define fm_find_ent_by_target(%1,%2)	engfunc(EngFunc_FindEntityByString, %1, "target", %2)
#define fm_find_ent_by_tname(%1,%2)		engfunc(EngFunc_FindEntityByString, %1, "targetname", %2)

/*================================================================================
 [Natives, Init and Cfg]
=================================================================================*/

native scm_load_ini_file();

public plugin_precache()
{
	g_iSpriteDot = precache_model("sprites/dot.spr");
}

public plugin_init()
{
	/* Register plugin */
	register_plugin("[SCM] Entity Editor", "1.3.1", "schmurgel1983");
	
	/* Multi-Language */
	register_dictionary("scm_entity_editor.txt");
	register_dictionary("common.txt");
	
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect", false);
	
	/* Colored Menus? */
	g_iColoredMenus = colored_menus();
	
	/* Store Map name and *.ini file */
	get_mapname(g_szMapName, charsmax(g_szMapName));
	get_configsdir(g_szEntitiesFile, charsmax(g_szEntitiesFile));
	format(g_szEntitiesFile, charsmax(g_szEntitiesFile), "%s/scm/entities/%s.ini", g_szEntitiesFile, g_szMapName);
	
	/* Create Menus */
	new szMenuName[48];
	format(szMenuName, charsmax(szMenuName), "Entity List: %s", g_szMapName);
	g_iListMenuId = menu_create(szMenuName, "ListMenuHandler", 0);
	g_cListMenuId = menu_makecallback("CallbackListHandler");
	
	for (new iIndex = 0, szCmd[4]; iIndex < CLASS_SIZE; iIndex++)
	{
		format(szCmd, charsmax(szCmd), "%d", iIndex);
		menu_additem(g_iListMenuId, ENTITY_CLASSES[iIndex], szCmd, 0, g_cListMenuId);
	}
	
	register_menu("Main Menu", MENU_KEYS, "MainMenuHandler");
	register_menu("Func Menu", MENU_KEYS, "FuncMenuHandler");
	
	/* Register Client Cmds */
	register_clcmd("say /scm_editor", "clcmd_menu");
	register_clcmd("say_team /scm_editor", "clcmd_menu");
	register_clcmd("scm_editor", "clcon_menu");
}

public plugin_cfg()
{
	/* Get all entities */
	for (new iIndex = 0, iEntity, iNum; iIndex < CLASS_SIZE; iIndex++)
	{
		/* Pre-Define entities, accurate is not 100% */
		iEntity = -1, iNum = 0;
		while ((iEntity = find_ent_by_class(iEntity, ENTITY_CLASSES[iIndex])) != 0)
		{
			/* Set Entity Index */
			g_iEntityIndex[iIndex][iNum] = iEntity;
			
			/* Get BSP Model */
			pev(iEntity, pev_model, g_szEntityModel[iIndex][iNum], charsmax(g_szEntityModel[][]));
			
			/* Setup Entity Data */
			switch (ENTITY_CLASSES[iIndex][5])
			{
				case 'b': /* func_button */
				{
					if (pev(iEntity, pev_spawnflags) & SF_BUTTON_DONTMOVE)
						DATA_ENABLE_ENTITY = 0;
					else
						DATA_ENABLE_ENTITY = 1;
				}
				case 'd':
				{
					/* func_door */
					if (pev(iEntity, pev_spawnflags) & SF_DOOR_PASSABLE)
						DATA_ENABLE_ENTITY = 0;
					else
						DATA_ENABLE_ENTITY = 1;
				}
				case 'g': DATA_ENABLE_ENTITY = 1; /* func_guntarget */
				case 'p':
				{
					/* func_pendulum */
					if (ENTITY_CLASSES[iIndex][9] == 'u')
					{
						if (pev(iEntity, pev_spawnflags) & SF_DOOR_PASSABLE)
							DATA_ENABLE_ENTITY = 0;
						else
							DATA_ENABLE_ENTITY = 1;
					}
					else /* func_plat, func_platrot */
						DATA_ENABLE_ENTITY = 1;
				}
				case 'r':
				{
					/* func_rot_button */
					if (ENTITY_CLASSES[iIndex][9] == 'b')
					{
						if (pev(iEntity, pev_spawnflags) & SF_ROTBUTTON_NOTSOLID)
							DATA_ENABLE_ENTITY = 0;
						else
							DATA_ENABLE_ENTITY = 1;
					}
					else /* func_rotating */
					{
						if (pev(iEntity, pev_spawnflags) & SF_ROTATING_NOTSOLID)
							DATA_ENABLE_ENTITY = 0;
						else
							DATA_ENABLE_ENTITY = 1;
					}
				}
				case 't':
				{
					switch (ENTITY_CLASSES[iIndex][10])
					{
						case 'd': /* momentary_door */
						{
							if (pev(iEntity, pev_spawnflags) & SF_DOOR_PASSABLE)
								DATA_ENABLE_ENTITY = 0;
							else
								DATA_ENABLE_ENTITY = 1;
						}
						case 'r': /* momentary_rot_button */
						{
							if (pev(iEntity, pev_spawnflags) & SF_MOMENTARY_DOOR)
								DATA_ENABLE_ENTITY = 1;
							else
								DATA_ENABLE_ENTITY = 0;
						}
						default:
						{
							if (ENTITY_CLASSES[iIndex][6] == 'a') /* func_tank */
								DATA_ENABLE_ENTITY = 1;
							else if (ENTITY_CLASSES[iIndex][10] == 'c') /* func_trackchange */
								DATA_ENABLE_ENTITY = 1;
							else /* func_tracktrain, func_train */
							{
								if (pev(iEntity, pev_spawnflags) & SF_TRAIN_PASSABLE)
									DATA_ENABLE_ENTITY = 0;
								else
									DATA_ENABLE_ENTITY = 1;
							}
						}
					}
				}
				case 'v': /* func_vehicle */
				{
					if (pev(iEntity, pev_spawnflags) & SF_VEHICLE_PASSABLE)
						DATA_ENABLE_ENTITY = 0;
					else
						DATA_ENABLE_ENTITY = 1;
				}
			}
			
			/* All entities do damage as default */
			DATA_CURRENT_DMG = DATA_ORIGINAL_DMG = 1;
			
			/* Set Entity Data */
			set_entity_data(iEntity);
			
			/* Get Entity Trigger */
			new szTarget[32];
			pev(iEntity, pev_targetname, szTarget, charsmax(szTarget));
			new iTarget = fm_find_ent_by_target(-1, szTarget);
			if (iTarget)
			{
				new szTriggerClass[32];
				pev(iTarget, pev_classname, szTriggerClass, charsmax(szTriggerClass));
				if (equal(szTriggerClass, "trigger_", 8))
				{
					pev(iTarget, pev_targetname, szTarget, charsmax(szTarget));
					iTarget = fm_find_ent_by_target(-1, szTarget);
				}
			}
			g_iEntityTrigger[iIndex][iNum] = iTarget;
			
			/* Get Entity Target */
			pev(iEntity, pev_target, szTarget, charsmax(szTarget));
			g_iEntityTarget[iIndex][iNum] = fm_find_ent_by_tname(-1, szTarget);
			
			if (++iNum >= MAX_STORAGE)
				break;
		}
		g_iEntityNum[iIndex] = iNum;
	}
	
	/* /scm/entities/<mapname>.ini file exists */
	if (file_exists(g_szEntitiesFile)) LoadIniFile();
	else SaveIniFile(false);
	
	/* Add [SCM] Entity Editor to Client Menu */
	AddClientMenuItem("SCM: Entity Editor", "scm_editor", ADMIN_ACCESS_LEVEL, "[SCM] Entity Editor");
}

/*================================================================================
 [Client Put in, Disconnect]
=================================================================================*/

public fw_ClientDisconnect(id)
{
	remove_task(id);
	
	if (pev_valid(g_iAbsBoxEnt[id]))
	{
		remove_entity(g_iAbsBoxEnt[id]);
		g_iAbsBoxEnt[id] = 0;
	}
}

/*================================================================================
 [Client Commands]
=================================================================================*/

public clcmd_menu(id)
{
	if (get_user_flags(id) & ADMIN_ACCESS_LEVEL)
		ShowMainMenu(id);
	else
		client_print(id, print_chat, "[SCM: Entity Editor] %L.", id, "NO_ACC_COM");
}

public clcon_menu(id)
{
	if (get_user_flags(id) & ADMIN_ACCESS_LEVEL)
		ShowMainMenu(id);
	else
		console_print(id, "[SCM: Entity Editor] %L.", id, "NO_ACC_COM");
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Menus]
=================================================================================*/

/* Main Menu */
ShowMainMenu(id)
{
	static szMenu[512], iLength, iKeys;
	iLength = iKeys = 0;
	
	/* Title */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\ySCM: Entity Editor^n" : "SCM: Entity Editor^n");
	
	/* Info */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\yMap: %s^n^n" : "Map: %s^n^n", g_szMapName);
	
	/* 1. Entity List */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r1.\w Entity List^n^n" : "1. Entity List^n^n");
	iKeys += MENU_KEY_1;
	
	/* 4. Save and apply file settings */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r4.\w %L\y %s.ini\w %L." : "4. %L ^"%s.ini^" %L.", id, "SCM_MENU_SAVE", g_szMapName, id, "SCM_MENU_SET");
	iKeys += MENU_KEY_4;
	
	/* 0. Exit */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "^n^n\r0.\w %L" : "^n^n0. %L", id, "EXIT");
	iKeys += MENU_KEY_0;
	
	fm_amxx_fix_custom_menu(id);
	show_menu(id, iKeys, szMenu, -1, "Main Menu");
}

public MainMenuHandler(id, key)
{
	switch (key)
	{
		case 0: /* 1. Entity List */
		{
			if (pev_valid(g_iAbsBoxEnt[id]))
				set_pev(g_iAbsBoxEnt[id], pev_nextthink, get_gametime() + 99999.0);
			
			MENU_PAGE = min(MENU_PAGE, menu_pages(g_iListMenuId) - 1);
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/blip1");
			#endif // SOUND_EFFECTS
			
			fm_amxx_fix_custom_menu(id);
			menu_display(id, g_iListMenuId, MENU_PAGE);
		}
		case 3: /* 4. Save and apply file settings */
		{
			if (LibraryExists("cs_team_semiclip", LibType_Library) || LibraryExists("zp_team_semiclip", LibType_Library))
			{
				if (SaveIniFile(true))
				{
					if (scm_load_ini_file())
					{
						client_print(id, print_chat, "[SCM: Entity Editor] %L", id, "SCM_CHAT_SAVED", g_szMapName);
						#if defined SOUND_EFFECTS
						client_cmd(id, "spk buttons/button9");
						#endif // SOUND_EFFECTS
					}
					else
					{
						client_print(id, print_chat, "[SCM: Entity Editor] %L", id, "SCM_CHAT_FAILED", g_szMapName);
						#if defined SOUND_EFFECTS
						client_cmd(id, "spk buttons/button11");
						#endif // SOUND_EFFECTS
					}
				}
				else
				{
					client_print(id, print_chat, "[SCM: Entity Editor] %L", id, "SCM_CHAT_FAIL_SAVE", g_szMapName);
					#if defined SOUND_EFFECTS
					client_cmd(id, "spk buttons/button11");
					#endif // SOUND_EFFECTS
				}
			}
			else
			{
				client_print(id, print_chat, "[SCM: Entity Editor] %L", id, "SCM_CHAT_FAIL_APPLY", g_szMapName);
				#if defined SOUND_EFFECTS
				client_cmd(id, "spk buttons/button11");
				#endif // SOUND_EFFECTS
			}
			ShowMainMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

/* Entity List */
public CallbackListHandler(id, menu, item)
{
	if (item < 0 || item >= CLASS_SIZE)
		return ITEM_IGNORE;
	
	new szItemName[32];
	if (!g_iEntityNum[item])
	{
		format(szItemName, charsmax(szItemName), "%s", ENTITY_CLASSES[item]);
		menu_item_setname(menu, item, szItemName);
		return ITEM_DISABLED;
	}
	
	format(szItemName, charsmax(szItemName), "%s [%d]", ENTITY_CLASSES[item], g_iEntityNum[item]);
	menu_item_setname(menu, item, szItemName);
	return ITEM_ENABLED;
}

public ListMenuHandler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		if (pev_valid(g_iAbsBoxEnt[id]))
			set_pev(g_iAbsBoxEnt[id], pev_nextthink, get_gametime() + 99999.0);
		
		ShowMainMenu(id);
		return PLUGIN_HANDLED;
	}
	else if (item < 0 || item >= CLASS_SIZE)
		return PLUGIN_CONTINUE;
	
	static dummy;
	player_menu_info(id, dummy, dummy, MENU_PAGE);
	
	if (MENU_FUNC != item)
		MENU_ENTITY = 0;
	MENU_FUNC = item;
	
	/* Create Entity */
	if (!g_iAbsBoxEnt[id])
	{
		new iAbsBoxEnt = create_entity("info_target");
		if (pev_valid(iAbsBoxEnt))
		{
			register_think("SCM_AbsBoxEntity", "AbsBoxThink");
			g_iAbsBoxEnt[id] = iAbsBoxEnt;
			
			set_pev(iAbsBoxEnt, pev_classname, "SCM_AbsBoxEntity");
			set_pev(iAbsBoxEnt, pev_owner, id);
			set_pev(iAbsBoxEnt, pev_nextthink, get_gametime() + 0.2);
		}
		else
		{
			client_print(id, print_chat, "[SCM: Entity Editor] %L", id, "SCM_CHAT_FAIL_CREATE");
			
			MENU_PAGE = min(MENU_PAGE, menu_pages(g_iListMenuId) - 1);
			
			fm_amxx_fix_custom_menu(id);
			menu_display(id, g_iListMenuId, MENU_PAGE);
			return PLUGIN_HANDLED;
		}
	}
	else
		AbsBoxThink(g_iAbsBoxEnt[id]);
	
	#if defined SOUND_EFFECTS
	client_cmd(id, "spk buttons/blip1");
	#endif // SOUND_EFFECTS
	ShowFuncMenu(id);
	return PLUGIN_HANDLED;
}

/* Funcion Menu */
public ShowFuncMenu(id)
{
	static szMenu[512], iLength, iKeys, iItem, iNum, iEntityValid;
	iLength = iKeys = 0;
	iItem = MENU_FUNC;
	iNum = MENU_ENTITY;
	iEntityValid = pev_valid(g_iEntityIndex[iItem][iNum]);
	
	/* Title + Info */
	if (iEntityValid)
		iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\y%L:\r %s\y [%d/%d]\w %s^n^n" : "%L: %s [%d/%d] %s^n^n", id, "SCM_MENU_EDIT", ENTITY_CLASSES[iItem], 1+iNum, g_iEntityNum[iItem], g_szEntityModel[iItem][iNum]);
	else
		iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\y%L:\d %s\y [%d/%d]^n^n" : "%L: #%s [%d/%d]^n^n", id, "SCM_MENU_EDIT", ENTITY_CLASSES[iItem], 1+iNum, g_iEntityNum[iItem]);
	
	/* 1. Previous | 2. Next */
	if (!iNum)
	{
		if (1+iNum >= g_iEntityNum[iItem])
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d1. %L\w | \d2. %L^n" : "#. %L | #. %L^n", id, "SCM_MENU_PREVIOUS", id, "SCM_MENU_NEXT");
		else
		{
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d1. %L\w | \r2.\w %L^n" : "#. %L | 2. %L^n", id, "SCM_MENU_PREVIOUS", id, "SCM_MENU_NEXT");
			iKeys += MENU_KEY_2;
		}
	}
	else
	{
		if (1+iNum >= g_iEntityNum[iItem])
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r1.\w %L | \d2. %L^n" : "1. %L | #. %L^n", id, "SCM_MENU_PREVIOUS", id, "SCM_MENU_NEXT");
		else
		{
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r1.\w %L | \r2.\w %L^n" : "1. %L | 2. %L^n", id, "SCM_MENU_PREVIOUS", id, "SCM_MENU_NEXT");
			iKeys += MENU_KEY_2;
		}
		iKeys += MENU_KEY_1;
	}
	
	/* 3. Teleport to Entity */
	if (!is_user_alive(id))
	{
		if (iEntityValid)
		{
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r3.\w %L^n" : "3. %L^n", id, "SCM_MENU_TELE");
			iKeys += MENU_KEY_3;
		}
		else
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d3. %L^n" : "#. %L^n", id, "SCM_MENU_TELE");
	}
	else
		iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d3. %L %L^n" : "#. %L %L^n", id, "SCM_MENU_TELE", id, "SCM_MENU_SPEC");
	
	/* 4. Trigger */
	if (pev_valid(g_iEntityTrigger[iItem][iNum]))
	{
		static szTriggerClass[32];
		pev(g_iEntityTrigger[iItem][iNum], pev_classname, szTriggerClass, charsmax(szTriggerClass));
		if (equal(szTriggerClass, "func_tankcontrols"))
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d4. %L [E: %s]^n^n" : "#. %L [E: %s]^n^n", id, "SCM_MENU_TRIGGER", szTriggerClass);
		else
		{
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r4.\w %L\y [E:\w %s\y]^n^n" : "4. %L [E: %s]^n^n", id, "SCM_MENU_TRIGGER", szTriggerClass);
			iKeys += MENU_KEY_4;
		}
	}
	else
	{
		if (iEntityValid)
		{
			if (pev_valid(g_iEntityTarget[iItem][iNum]))
			{
				static szTargetClass[32];
				pev(g_iEntityTarget[iItem][iNum], pev_classname, szTargetClass, charsmax(szTargetClass));
				if (equal(szTargetClass, "trigger_camera") || equal(szTargetClass, "ambient_generic"))
					iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d4. %L [T: %s]^n^n" : "#. %L [T: %s]^n^n", id, "SCM_MENU_TRIGGER", szTargetClass);
				else
				{
					iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r4.\w %L\y [E:\w %L\y T:\w %s\y]^n^n" : "4. %L [E: %L T: %s]^n^n", id, "SCM_MENU_TRIGGER", id, "SCM_MENU_USE", szTargetClass);
					iKeys += MENU_KEY_4;
				}
			}
			else
			{
				iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r4.\w %L\y [E:\w %L\y]^n^n" : "4. %L [E: %L]^n^n", id, "SCM_MENU_TRIGGER", id, "SCM_MENU_USE");
				iKeys += MENU_KEY_4;
			}
		}
		else
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d4. %L [E: %L]^n^n" : "#. %L [E: %L]^n^n", id, "SCM_MENU_TRIGGER", id, "SCM_MENU_USE");
	}
	
	/* Info */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r%L:\w %L^n^n" : "%L: %L^n^n", id, "SCM_MENU_ATT", id, "SCM_MENU_ALL");
	
	/* Get Entity Data */
	if (iEntityValid)
		get_entity_data(g_iEntityIndex[iItem][iNum]);
	else
		DATA_ENABLE_ENTITY = DATA_CURRENT_DMG = DATA_ORIGINAL_DMG = 0;
	
	if (DATA_ENABLE_ENTITY)
	{
		/* 5. Semiclip */
		iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r5.\w Semiclip\y [%L]^n" : "5. Semiclip [%L]^n", id, "SCM_MENU_ENABLED");
		iKeys += MENU_KEY_5;
		
		/* 6. Damage */
		if (DATA_CURRENT_DMG)
		{
			/* Enable */
			if (DATA_CURRENT_DMG != DATA_ORIGINAL_DMG)
				iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r6.\w %L\y [\r%L\y] [\w%L\y]^n" : "6. %L [%L] [#%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_ENABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
			else
				iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r6.\w %L\y [\w%L\y] [\w%L\y]^n" : "6. %L [%L] [%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_ENABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
		}
		else
		{
			/* Disable */
			if (DATA_CURRENT_DMG != DATA_ORIGINAL_DMG)
				iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r6.\w %L\y [\r%L\y] [\w%L\y]^n" : "6. %L [%L] [#%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_DISABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
			else
				iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r6.\w %L\y [\w%L\y] [\w%L\y]^n" : "6. %L [%L] [%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_DISABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
		}
		iKeys += MENU_KEY_6;
	}
	else
	{
		/* 5. Semiclip */
		if (iEntityValid)
		{
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\r5.\w Semiclip\y [%L]^n" : "5. Semiclip [%L]^n", id, "SCM_MENU_IGNORED");
			iKeys += MENU_KEY_5;
		}
		else
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d5. Semiclip [%L]^n" : "#. Semiclip [%L]^n", id, "SCM_MENU_NOT");
		
		/* 6. Damage */
		if (DATA_CURRENT_DMG)
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d6. %L [%L] [%L]^n" : "#. %L [%L] [%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_ENABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
		else
			iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "\d6. %L [%L] [%L]^n" : "#. %L [%L] [%L]^n", id, "SCM_MENU_DMG", id, "SCM_MENU_DISABLED", id, DATA_ORIGINAL_DMG ? "SCM_MENU_ENABLED" : "SCM_MENU_DISABLED");
	}
	
	/* 0. Exit */
	iLength += formatex(szMenu[iLength], charsmax(szMenu) - iLength, g_iColoredMenus ? "^n\r0.\w %L" : "^n0. %L", id, "BACK");
	iKeys += MENU_KEY_0;
	
	fm_amxx_fix_custom_menu(id);
	show_menu(id, iKeys, szMenu, -1, "Func Menu");
	set_task(1.0, "ShowFuncMenu", id);
}

public FuncMenuHandler(id, key)
{
	remove_task(id);
	new iEntityIndex = g_iEntityIndex[MENU_FUNC][MENU_ENTITY];
	
	switch (key)
	{
		case 0: /* 1. Previous Entity */
		{
			MENU_ENTITY--;
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/blip1");
			#endif // SOUND_EFFECTS
			ShowFuncMenu(id);
		}
		case 1: /* 2. Next Entity */
		{
			MENU_ENTITY++;
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/blip1");
			#endif // SOUND_EFFECTS
			ShowFuncMenu(id);
		}
		case 2: /* 3. Teleport to Entity */
		{
			new Float:flCenter[3];
			GetEntityCenter(iEntityIndex, flCenter);
			engfunc(EngFunc_SetOrigin, id, flCenter);
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/blip2");
			#endif // SOUND_EFFECTS
			ShowFuncMenu(id);
		}
		case 3: /* 4. Trigger */
		{
			if (pev_valid(g_iEntityTrigger[MENU_FUNC][MENU_ENTITY]))
				dllfunc(DLLFunc_Use, g_iEntityTrigger[MENU_FUNC][MENU_ENTITY], 0);
			else
				dllfunc(DLLFunc_Use, iEntityIndex, 0);
			
			ShowFuncMenu(id);
		}
		case 4: /* 5. Semiclip */
		{
			get_entity_data(iEntityIndex);
			switch (DATA_ENABLE_ENTITY)
			{
				case 1: DATA_ENABLE_ENTITY = 0;
				case 0: DATA_ENABLE_ENTITY = 1;
			}
			set_entity_data(iEntityIndex);
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/lightswitch2");
			#endif // SOUND_EFFECTS
			ShowFuncMenu(id);
		}
		case 5: /* 6. Damage */
		{
			get_entity_data(iEntityIndex);
			switch (DATA_CURRENT_DMG)
			{
				case 1: DATA_CURRENT_DMG = 0;
				case 0: DATA_CURRENT_DMG = 1;
			}
			set_entity_data(iEntityIndex);
			
			#if defined SOUND_EFFECTS
			client_cmd(id, "spk buttons/lightswitch2");
			#endif // SOUND_EFFECTS
			ShowFuncMenu(id);
		}
		case 9: MainMenuHandler(id, 0); /* 0. Exit */
	}
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

public AbsBoxThink(entity)
{
	if (!pev_valid(entity))
		return;
	
	static id;
	id = pev(entity, pev_owner);
	
	if (!is_user_connected(id))
		return;
	
	static iFunction, iEntity, iEntityIndex;
	iFunction = MENU_FUNC;
	iEntity = MENU_ENTITY;
	iEntityIndex = g_iEntityIndex[iFunction][iEntity];
	
	if (!pev_valid(iEntityIndex))
		return;
	
	static Float:flCenter[3], Float:flClientPos[3];
	pev(id, pev_origin, flClientPos);
	flClientPos[2] -= 8.0;
	
	if (pev_valid(g_iEntityTrigger[iFunction][iEntity]))
	{
		GetEntityCenter(g_iEntityTrigger[iFunction][iEntity], flCenter);
		DrawLine(id, flClientPos[0], flClientPos[1], flClientPos[2], flCenter[0], flCenter[1], flCenter[2], 255, 255, 0);
	}
	else if (pev_valid(g_iEntityTarget[iFunction][iEntity]))
	{
		GetEntityCenter(g_iEntityTarget[iFunction][iEntity], flCenter);
		DrawLine(id, flClientPos[0], flClientPos[1], flClientPos[2], flCenter[0], flCenter[1], flCenter[2], 255, 255, 0);
	}
	
	get_entity_data(iEntityIndex);
	if (DATA_ENABLE_ENTITY)
	{
		static Float:flAbsMin[3], Float:flAbsMax[3];
		GetEntityCenter2(iEntityIndex, flCenter, flAbsMin, flAbsMax);
		DrawLine(id, flClientPos[0], flClientPos[1], flClientPos[2], flCenter[0], flCenter[1], flCenter[2], 255, 0, 0);
		
		DrawLine(id, flAbsMax[0], flAbsMax[1], flAbsMax[2], flAbsMin[0], flAbsMax[1], flAbsMax[2], 255, 255, 255);
		DrawLine(id, flAbsMax[0], flAbsMax[1], flAbsMax[2], flAbsMax[0], flAbsMin[1], flAbsMax[2], 255, 255, 255);
		DrawLine(id, flAbsMax[0], flAbsMax[1], flAbsMax[2], flAbsMax[0], flAbsMax[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMin[2], flAbsMax[0], flAbsMin[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMin[2], flAbsMin[0], flAbsMax[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMin[2], flAbsMin[0], flAbsMin[1], flAbsMax[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMax[1], flAbsMax[2], flAbsMin[0], flAbsMax[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMax[1], flAbsMin[2], flAbsMax[0], flAbsMax[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMax[0], flAbsMax[1], flAbsMin[2], flAbsMax[0], flAbsMin[1], flAbsMin[2], 255, 255, 255);
		DrawLine(id, flAbsMax[0], flAbsMin[1], flAbsMin[2], flAbsMax[0], flAbsMin[1], flAbsMax[2], 255, 255, 255);
		DrawLine(id, flAbsMax[0], flAbsMin[1], flAbsMax[2], flAbsMin[0], flAbsMin[1], flAbsMax[2], 255, 255, 255);
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMax[2], flAbsMin[0], flAbsMax[1], flAbsMax[2], 255, 255, 255);
		
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMin[2], flAbsMax[0], flAbsMax[1], flAbsMax[2], 0, 255, 0);
		DrawLine(id, flAbsMin[0], flAbsMin[1], flAbsMax[2], flAbsMax[0], flAbsMax[1], flAbsMin[2], 0, 255, 0);
		DrawLine(id, flAbsMin[0], flAbsMax[1], flAbsMin[2], flAbsMax[0], flAbsMin[1], flAbsMax[2], 0, 255, 0);
		DrawLine(id, flAbsMax[0], flAbsMin[1], flAbsMin[2], flAbsMin[0], flAbsMax[1], flAbsMax[2], 0, 255, 0);
	}
	else
	{
		GetEntityCenter(iEntityIndex, flCenter);
		DrawLine(id, flClientPos[0], flClientPos[1], flClientPos[2], flCenter[0], flCenter[1], flCenter[2], 255, 0, 0);
	}
	
	set_pev(entity, pev_nextthink, get_gametime() + 0.1);
}

GetEntityCenter(const iIndex, Float:flCenter[3])
{
	static Float:flAbsMin[3], Float:flAbsMax[3];
	pev(iIndex, pev_absmin, flAbsMin);
	pev(iIndex, pev_absmax, flAbsMax);
	
	flCenter[0] = (flAbsMin[0] + flAbsMax[0]) * 0.5;
	flCenter[1] = (flAbsMin[1] + flAbsMax[1]) * 0.5;
	flCenter[2] = (flAbsMin[2] + flAbsMax[2]) * 0.5;
}

GetEntityCenter2(const iIndex, Float:flCenter[3], Float:flAbsMin[3], Float:flAbsMax[3])
{
	pev(iIndex, pev_absmin, flAbsMin);
	pev(iIndex, pev_absmax, flAbsMax);
	
	flCenter[0] = (flAbsMin[0] + flAbsMax[0]) * 0.5;
	flCenter[1] = (flAbsMin[1] + flAbsMax[1]) * 0.5;
	flCenter[2] = (flAbsMin[2] + flAbsMax[2]) * 0.5;
}

DrawLine(const id, const Float:x1, const Float:y1, const Float:z1, const Float:x2, const Float:y2, const Float:z2, const r, const g, const b)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id);
	{
		write_byte(TE_BEAMPOINTS);
		fm_write_coord(x1);
		fm_write_coord(y1);
		fm_write_coord(z1);
		fm_write_coord(x2);
		fm_write_coord(y2);
		fm_write_coord(z2);
		write_short(g_iSpriteDot);
		write_byte(1);	// framestart 
		write_byte(1);	// framerate 
		write_byte(1);	// life in 0.1's 
		write_byte(2);	// width
		write_byte(0);	// noise 
		write_byte(r);	// r, g, b 
		write_byte(g);	// r, g, b 
		write_byte(b);	// r, g, b 
		write_byte(200);	// brightness 
		write_byte(0);	// speed 
	}
	message_end();
}

public LoadIniFile()
{
	new iFile = fopen(g_szEntitiesFile, "rt");
	if (!iFile) return;
	
	new szLineData[64], szData[4][32];
	while (!feof(iFile))
	{
		fgets(iFile, szLineData, charsmax(szLineData));
		replace(szLineData, charsmax(szLineData), "^n", "");
		
		if (!szLineData[0] || szLineData[0] == '/' || szLineData[0] == ';' || szLineData[0] == '#')
			continue;
		
		/* func_ *model semiclip damage */
		parse(szLineData, szData[0], charsmax(szData[]), szData[1], charsmax(szData[]), szData[2], charsmax(szData[]), szData[3], charsmax(szData[]));
		
		new iIndex = find_ent_by_model(-1, szData[0], szData[1]);
		if (!iIndex) continue;
		
		get_entity_data(iIndex);
		
		if (equali(szData[2], "ignore"))
			DATA_ENABLE_ENTITY = 0;
		else
			DATA_ENABLE_ENTITY = 1;
		
		if (equali(szData[3], "enable"))
			DATA_CURRENT_DMG = 1;
		else
			DATA_CURRENT_DMG = 0;
		
		set_entity_data(iIndex);
	}
	fclose(iFile);
}

SaveIniFile(bool:delete)
{
	if (delete && file_exists(g_szEntitiesFile))
		delete_file(g_szEntitiesFile);
	
	new iFile = fopen(g_szEntitiesFile, "wt+");
	if (!iFile) return 0;
	
	/* Info */
	new szBuffer[96];
	format(szBuffer, charsmax(szBuffer), "// Map: %s^n//^n// func_ *model semiclip damage^n^n", g_szMapName);
	fputs(iFile, szBuffer);
	
	for (new i = 0, j, iNum; i < CLASS_SIZE; i++)
	{
		iNum = g_iEntityNum[i];
		if (!iNum)
			continue;
		
		for (j = 0; j < iNum; j++)
		{
			if (pev_valid(g_iEntityIndex[i][j]))
			{
				get_entity_data(g_iEntityIndex[i][j]);
				
				format(szBuffer, charsmax(szBuffer), "%s %s %s %s^n", ENTITY_CLASSES[i], g_szEntityModel[i][j], DATA_ENABLE_ENTITY ? "enable" : "ignore", DATA_CURRENT_DMG ? "enable" : "disable");
				fputs(iFile, szBuffer);
			}
		}
	}
	fclose(iFile);
	return 1;
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock fm_amxx_fix_custom_menu(id)
{
	if (pev_valid(id) != pdata_safe)
		return;
	
	#if AMXX_VERSION_NUM >= 182
	set_pdata_int(id, m_aButtons, 0, linux_diff, mac_diff);
	#else
	set_pdata_int(id, m_aButtons, 0, linux_diff);
	#endif
}
