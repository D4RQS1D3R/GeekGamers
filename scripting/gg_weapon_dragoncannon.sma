#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

// Modifiying Plugin Info Will Violate CopyRight  ///////////
#define PLUGIN "[GG] Red and Golden Dragon Cannon"	 ///
#define VERSION "1.0"					///
#define AUTHOR "ZinoZack47"			       ///
/////////////////////////////////////////////////////////

/*
	-if you want to use the Golden Dragon Cannon only, delete #define RED
	-if you want to use Both Red and Golden Dragon Cannon, then make sure #define RED and #define GOLD are added. May cause crashes so be warned.
	-if you want to use the Red Dragon Cannon only, delete #define GOLD
*/

#define RED
//#define GOLD

#define RDC_WEAPONKEY				118639647

#define WEAP_LINUX_XTRA_OFF			4
#define PLAYER_LINUX_XTRA_OFF			5

#define m_pPlayer             			41
#define m_flNextPrimaryAttack 			46
#define m_flNextSecondaryAttack 		47
#define m_flTimeWeaponIdle			48

#define m_flNextAttack				83
#define m_pActiveItem 				373

#define RDC_DRAW_TIME     			1.0

#define CSW_RDC 				CSW_P90
#define weapon_rdc				"weapon_p90"

#define RDC_FIRE_CLASSNAME 			"rdc_fire"
#define RDC_DRAGON_CLASSNAME 			"rdc_dragon"
#define RDC_DRAGONSPIRIT_CLASSNAME 		"rdc_dragon_spirit"
#define RDC_EXPLOSION_CLASSNAME 		"rdc_explosion"

#define WEAPON_ATTACH_F 			30.0
#define WEAPON_ATTACH_R 			10.0
#define WEAPON_ATTACH_U 			-5.0

const pev_mode = pev_iuser1
const pev_life = pev_fuser1
const pev_rate = pev_fuser2

enum ( += 47)
{
	RDC_TASK_SHOOT = 45756778,
	RDC_TASK_UNLEASH,
	RDC_TASK_RESET,
	RDC_TASK_COOLDOWN,
	RDC_TASK_REFILL
}

enum
{
	MODE_A = 0,
	MODE_B
}

enum
{
	RDC_IDLE = 0,
	RDC_IDLEB,
	RDC_DRAW,
	RDC_DRAWB,
	RDC_SHOOTA,
	RDC_SHOOTB,
	RDC_D_TRANSFORM,
	RDC_D_RELOAD1,
	RDC_D_RELOAD2
}

enum 
{
	RDC_P_MODEL = 0,
	RDC_P_MODELB,
	RDC_W_MODEL,
	RDC_W_MODELB
}

#if (defined GOLD) && (!defined RED)
new const GDC_V_MODEL[64] = "models/[GeekGamers]/Primary/v_cannonexgold.mdl"
#endif
#if (defined GOLD) && (defined RED)
new const RDC_V_MODEL[64] = "models/[GeekGamers]/Primary/v_cannonex.mdl"
new const GDC_V_MODEL[64] = "models/[GeekGamers]/Primary/v_cannonexgold.mdl"
#endif
#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
new const RDC_V_MODEL[64] = "models/[GeekGamers]/Primary/v_cannonex.mdl"
#endif

new const RDC_Models[][] = 
{
	"models/[GeekGamers]/Primary/p_cannonex.mdl",
	"models/[GeekGamers]/Primary/p_cannonexb.mdl",
	"models/[GeekGamers]/Primary/w_cannonex.mdl",
	"models/[GeekGamers]/Primary/w_cannonexb.mdl"
}

new const RDC_Sounds[][] = 
{
	"weapons/cannonex_shoota.wav",
	"weapons/cannonex_d_reload1.wav",
	"weapons/cannonex_d_reload2.wav",
	"weapons/cannonex_dtransform.wav",
	"weapons/cannonex_dragon_fire_end.wav",
	"weapons/cannonexplo.wav"
}

new const RDC_Effects[][] = 
{
	"models/[GeekGamers]/Primary/cannonexdragon.mdl",
	"models/[GeekGamers]/Primary/p_cannonexdragonfx.mdl",
	"models/[GeekGamers]/Primary/p_cannonexplo.mdl"
}

new const RDC_Sprites[][] = 
{
	"sprites/weapon_cannonex.txt",
	"sprites/640hud2_47.spr",
	"sprites/640hud161.spr",
	"sprites/fire_cannon.spr"
}

#if (defined GOLD) && (!defined RED)
new cvar_dmg_rdc, cvar_rdc_ammo, cvar_rdc_duration, cvar_rdc_cooldown, cvar_rdc_refill, cvar_one_round
#endif
#if (defined RED) && (defined GOLD)
new cvar_dmg_rdc[2], cvar_rdc_ammo[2], cvar_rdc_duration[2], cvar_rdc_cooldown[2], cvar_rdc_refill[2], cvar_one_round[2]
#endif
#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
new cvar_dmg_rdc, cvar_rdc_ammo, cvar_rdc_duration, cvar_rdc_cooldown, cvar_rdc_refill, cvar_one_round
#endif

new g_maxplayers
new m_iBlood[2], g_explo_spr
new g_current_mode[33], g_rdc_ammo[33], g_rdc_dragon[33], bool:g_rdc_preventmode[33]
new g_MsgWeaponList, g_MsgCurWeapon, g_MsgAmmoX, g_MsgEffect[3]

#if (defined GOLD) && (!defined RED)
new g_subpmodel[33]
new bool:g_has_rdc[33]
#endif
#if (defined RED) && (defined GOLD)
new g_subpmodel[33]
new g_has_rdc[33]
#endif
#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
new bool:g_has_rdc[33]
#endif

const PRIMARY_WEAPONS_BIT_SUM =
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|
(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

	//RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Item_Deploy, weapon_rdc, "fw_DragonCannon_Deploy_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_rdc, "fw_DragonCannon_AddToPlayer")
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_rdc, "fw_DragonCannon_WeaponIdle_Post", 1)

	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_Think, "fw_Think")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)

	#if (defined GOLD) && (!defined RED)
	cvar_rdc_ammo = register_cvar("amx_cannonexgold_ammo", "40")
	cvar_dmg_rdc = register_cvar("amx_cannonexgold_dmg", "80.0")
	cvar_rdc_duration = register_cvar("amx_cannonexgold_dragonduration", "20.0")
	cvar_rdc_cooldown = register_cvar("amx_cannonexgold_mode_cooldown", "25.0")
	cvar_rdc_refill = register_cvar("amx_cannonexgold_refill", "40.0")
	cvar_one_round = register_cvar("amx_cannonexgold_one_round", "0")
	
	#endif
	#if (defined RED) && (defined GOLD)
	cvar_rdc_ammo[0] = register_cvar("amx_cannonexred_ammo", "40")
	cvar_dmg_rdc[0] = register_cvar("amx_cannonexred_dmg", "80.0")
	cvar_rdc_duration[0] = register_cvar("amx_cannonexred_dragonduration", "20.0")
	cvar_rdc_cooldown[0] = register_cvar("amx_cannonexred_mode_cooldown", "25.0")
	cvar_rdc_refill[0] = register_cvar("amx_cannonexred_refill", "40.0")
	cvar_one_round[0] = register_cvar("amx_cannonexred_one_round", "0")
	
	cvar_rdc_ammo[1] = register_cvar("amx_cannonexgold_ammo", "60")
	cvar_dmg_rdc[1] = register_cvar("amx_cannonexgold_dmg", "100.0")
	cvar_rdc_duration[1] = register_cvar("amx_cannonexgold_dragonduration", "30.0")
	cvar_rdc_cooldown[1] = register_cvar("amx_cannonexgold_mode_cooldown", "15.0")
	cvar_rdc_refill[1] = register_cvar("amx_cannonexgold_refill", "30.0")
	cvar_one_round[1] = register_cvar("amx_cannonexgold_one_round", "0")

	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	cvar_rdc_ammo = register_cvar("amx_cannonexred_ammo", "40")
	cvar_dmg_rdc = register_cvar("amx_cannonexred_dmg", "80.0")
	cvar_rdc_duration = register_cvar("amx_cannonexred_dragonduration", "20.0")
	cvar_rdc_cooldown = register_cvar("amx_cannonexred_mode_cooldown", "25.0")
	cvar_rdc_refill = register_cvar("amx_cannonexred_refill", "40.0")
	cvar_one_round = register_cvar("amx_cannonexred_one_round", "0")
	#endif

	g_MsgWeaponList = get_user_msgid("WeaponList")
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	g_MsgAmmoX = get_user_msgid("AmmoX")
	g_MsgEffect[0] = get_user_msgid("Damage")
	g_MsgEffect[1] = get_user_msgid("ScreenFade")
	g_MsgEffect[2] = get_user_msgid("ScreenShake")

	register_clcmd("weapon_cannonex", "select_cannonex")
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	#if (defined GOLD) && (!defined RED)
	precache_model(GDC_V_MODEL)
	#endif
	#if (defined RED) && (defined GOLD)
	precache_model(RDC_V_MODEL)
	precache_model(GDC_V_MODEL)
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	precache_model(RDC_V_MODEL)
	#endif

	for(new i = 0; i < sizeof(RDC_Models); i++)
		precache_model(RDC_Models[i])

	for(new i = 0; i < sizeof(RDC_Sounds); i++)
		precache_sound(RDC_Sounds[i])	
	
	for(new i = 0; i < sizeof(RDC_Effects); i++)
		precache_model(RDC_Effects[i])

	for(new i = 0; i < sizeof(RDC_Sprites); i++)
		0 <= i <= 2 ? precache_generic(RDC_Sprites[i]) : precache_model(RDC_Sprites[i])

	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	g_explo_spr = precache_model("sprites/ef_cannonex.spr")
}

public plugin_natives()
{
	#if (defined GOLD) && (!defined RED)
	register_native("gg_set_user_gdc", "native_give_gdc_add", 1)
	#endif
	#if (defined GOLD) && (defined RED)
	register_native("gg_set_user_rdc", "native_give_rdc_add", 1)
	register_native("gg_set_user_gdc", "native_give_gdc_add", 1)
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	register_native("gg_set_user_rdc", "native_give_rdc_add", 1)
	#endif
}

#if (defined GOLD) && (!defined RED)
public native_give_gdc_add(id)
	give_cannonex(id)
#endif
#if (defined RED) && (defined GOLD)
public native_give_rdc_add(id)
	give_cannonex(id, 1)
public native_give_gdc_add(id)
	give_cannonex(id, 2)
#endif
#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
public native_give_rdc_add(id)
	give_cannonex(id)
#endif
public select_cannonex(id)
{
    engclient_cmd(id, weapon_rdc)
    return PLUGIN_HANDLED
}

public Event_CurWeapon(id)
{
	new weapon = read_data(2)

	if(weapon != CSW_RDC || !g_has_rdc[id])
	{
		#if defined GOLD
		if(pev_valid(g_subpmodel[id]))
		{
			set_pev(g_subpmodel[id], pev_body, 0)
			set_pev(g_subpmodel[id], pev_flags, FL_KILLME)
			engfunc(EngFunc_RemoveEntity, g_subpmodel[id])
		}
		#endif
		return
	}

	update_ammo(id)
}

public Event_NewRound()
{
	for(new id = 0; id <= g_maxplayers; id++)
	{
		if(!g_has_rdc[id])
			continue
		
		#if (defined GOLD) && (!defined RED)	
		if(get_pcvar_num(cvar_one_round))
			remove_cannonex(id)

		else
		{
			if(g_rdc_dragon[id])
			{
				engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
				g_rdc_dragon[id] = 0
				
				fm_set_weapon_idle_time(id, weapon_rdc, 2.5)
				set_pdata_float(id, m_flNextAttack, 2.5, PLAYER_LINUX_XTRA_OFF)
				
				remove_task(id+RDC_TASK_RESET)
				ResetMode(id+RDC_TASK_RESET)
			}

			remove_task(id+RDC_TASK_COOLDOWN)
			g_rdc_preventmode[id] = false

			remove_task(id+RDC_TASK_REFILL)
			Refill_Cannon(id+RDC_TASK_REFILL)
		}
		#endif
		#if (defined RED) && (defined GOLD)
		switch(g_has_rdc[id])
		{
			case 1:
			{
				if(get_pcvar_num(cvar_one_round[0]))
					remove_cannonex(id)

				else
				{
					if(g_rdc_dragon[id])
					{
						engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
						g_rdc_dragon[id] = 0
						
						fm_set_weapon_idle_time(id, weapon_rdc, 2.5)
						set_pdata_float(id, m_flNextAttack, 2.5, PLAYER_LINUX_XTRA_OFF)
						
						remove_task(id+RDC_TASK_RESET)
						ResetMode(id+RDC_TASK_RESET)
					}

					remove_task(id+RDC_TASK_COOLDOWN)
					g_rdc_preventmode[id] = false

					remove_task(id+RDC_TASK_REFILL)
					Refill_Cannon(id+RDC_TASK_REFILL)
				}
			}
			case 2:
			{
				if(get_pcvar_num(cvar_one_round[1]))
					remove_cannonex(id)

				else
				{
					if(g_rdc_dragon[id])
					{
						engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
						g_rdc_dragon[id] = 0
						
						fm_set_weapon_idle_time(id, weapon_rdc, 2.5)
						set_pdata_float(id, m_flNextAttack, 2.5, PLAYER_LINUX_XTRA_OFF)
						
						remove_task(id+RDC_TASK_RESET)
						ResetMode(id+RDC_TASK_RESET)
					}

					remove_task(id+RDC_TASK_COOLDOWN)
					g_rdc_preventmode[id] = false

					remove_task(id+RDC_TASK_REFILL)
					Refill_Cannon(id+RDC_TASK_REFILL)
				}
			}
		}
		#endif
		#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
		if(get_pcvar_num(cvar_one_round))
			remove_cannonex(id)

		else
		{
			if(g_rdc_dragon[id])
			{
				engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
				g_rdc_dragon[id] = 0
				
				fm_set_weapon_idle_time(id, weapon_rdc, 2.5)
				set_pdata_float(id, m_flNextAttack, 2.5, PLAYER_LINUX_XTRA_OFF)
				
				remove_task(id+RDC_TASK_RESET)
				ResetMode(id+RDC_TASK_RESET)
			}

			remove_task(id+RDC_TASK_COOLDOWN)
			g_rdc_preventmode[id] = false

			remove_task(id+RDC_TASK_REFILL)
			Refill_Cannon(id+RDC_TASK_REFILL)
		}
		#endif
	}
}
/*
public fw_PlayerKilled(id)
	remove_cannonex(id)
*/
public client_disconnected(id)
	remove_cannonex(id)

public fw_DragonCannon_Deploy_Post(weapon_ent)
{
	if(!pev_valid(weapon_ent))
		return

	static id
	id = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	if(fm_cs_get_current_weapon_ent(id) != weapon_ent)
		return

	if(!g_has_rdc[id])
		return

	#if (defined GOLD) && (!defined RED)
	set_pev(id, pev_viewmodel2, GDC_V_MODEL)
	switch(g_current_mode[id])
	{
		case MODE_A: sub_p_model(id, RDC_Models[RDC_P_MODEL]), fm_play_weapon_animation(id, RDC_DRAW)
		case MODE_B: sub_p_model(id, RDC_Models[RDC_P_MODELB]), fm_play_weapon_animation(id, RDC_DRAWB)
	}
	#endif
	#if (defined RED) && (defined GOLD)
	switch(g_has_rdc[id])
	{
		case 1:
		{
			set_pev(id, pev_viewmodel2, RDC_V_MODEL)
			switch(g_current_mode[id])
			{
				case MODE_A: set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODEL]), fm_play_weapon_animation(id, RDC_DRAW)
				case MODE_B: set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODELB]), fm_play_weapon_animation(id, RDC_DRAWB)
			}
		}
		case 2:
		{
			set_pev(id, pev_viewmodel2, GDC_V_MODEL)
			switch(g_current_mode[id])
			{
				case MODE_A: sub_p_model(id, RDC_Models[RDC_P_MODEL]), fm_play_weapon_animation(id, RDC_DRAW)
				case MODE_B: sub_p_model(id, RDC_Models[RDC_P_MODELB]), fm_play_weapon_animation(id, RDC_DRAWB)
			}
		}
	}
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	set_pev(id, pev_viewmodel2, RDC_V_MODEL)
	switch(g_current_mode[id])
	{
		case MODE_A: set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODEL]), fm_play_weapon_animation(id, RDC_DRAW)
		case MODE_B: set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODELB]), fm_play_weapon_animation(id, RDC_DRAWB)
	}
	#endif

	fm_set_weapon_idle_time(id, weapon_rdc, RDC_DRAW_TIME)
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED

	if(get_user_weapon(id) != CSW_RDC || !g_has_rdc[id])
		return FMRES_IGNORED
	
	if(get_pdata_float(id, m_flNextAttack) > 0.0)
			return FMRES_IGNORED

	static CurButton
	CurButton = get_uc(uc_handle, UC_Buttons)
	
	if(CurButton & IN_ATTACK)
	{
		CurButton &= ~IN_ATTACK
		set_uc(uc_handle, UC_Buttons, CurButton)

		if(get_pdata_float(id, m_flNextPrimaryAttack, PLAYER_LINUX_XTRA_OFF) <= 0.0 && g_rdc_ammo[id] > 0)
		{
			#if (defined GOLD) && (!defined RED)
			if(get_pcvar_float(cvar_rdc_refill) && !task_exists(id+RDC_TASK_REFILL))
			{
				if(g_rdc_ammo[id] == 1)
					set_task(get_pcvar_float(cvar_rdc_refill), "Refill_Cannon", id+RDC_TASK_REFILL)
			}
			#endif
			#if (defined RED) && (defined GOLD)
			switch(g_has_rdc[id])
			{
				case 1:
				{
					if(get_pcvar_float(cvar_rdc_refill[0]) && !task_exists(id+RDC_TASK_REFILL))
					{
						if(g_rdc_ammo[id] == 1)
							set_task(get_pcvar_float(cvar_rdc_refill[0]), "Refill_Cannon", id+RDC_TASK_REFILL)
					}
				}
				case 2:
				{
					if(get_pcvar_float(cvar_rdc_refill[1]) && !task_exists(id+RDC_TASK_REFILL))
					{
						if(g_rdc_ammo[id] == 1)
							set_task(get_pcvar_float(cvar_rdc_refill[1]), "Refill_Cannon", id+RDC_TASK_REFILL)
					}
				}
			}
			#endif
			#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
			if(get_pcvar_float(cvar_rdc_refill) && !task_exists(id+RDC_TASK_REFILL))
			{
				if(g_rdc_ammo[id] == 1)
					set_task(get_pcvar_float(cvar_rdc_refill), "Refill_Cannon", id+RDC_TASK_REFILL)
			}
			#endif

			g_rdc_ammo[id]--
			update_ammo(id)
			
			fm_set_weapon_idle_time(id, weapon_rdc, g_rdc_dragon[id] && pev(g_rdc_dragon[id], pev_life) - get_gametime() <= 0.0 ? 5.0 : 3.5)
			set_pdata_float(id, m_flNextAttack, g_rdc_dragon[id] && pev(g_rdc_dragon[id], pev_life) - get_gametime() <= 0.0 ? 5.0 : 3.5, PLAYER_LINUX_XTRA_OFF)

			Set_1st_Attack(id)
			set_task(0.1, "Set_2nd_Attack", id + RDC_TASK_SHOOT)
		}
	}
	else if(CurButton & IN_ATTACK2)
	{
		CurButton &= ~IN_ATTACK2
		set_uc(uc_handle, UC_Buttons, CurButton)

		if(get_pdata_float(id, m_flNextSecondaryAttack, PLAYER_LINUX_XTRA_OFF) <= 0.0 && !g_rdc_preventmode[id] && g_rdc_ammo[id] > 0)
			Switch_Mode(id)

	}
	
	return FMRES_HANDLED
}

public Refill_Cannon(id)
{
	id -= RDC_TASK_REFILL
	
	if(!g_has_rdc[id])
		return

	#if (defined GOLD) && (!defined RED)
	g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo)

	#endif
	#if (defined RED) && (defined GOLD)
	switch(g_has_rdc[id])
	{
		case 1: g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo[0])
		case 2: g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo[1])
	}
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo)
	#endif

	update_ammo(id)
}

public Switch_Mode(id)
{
	if(!g_has_rdc[id])
		return

	if(g_current_mode[id])
		return

	g_current_mode[id] = MODE_B
	
	#if (defined GOLD) && (!defined RED)
	sub_p_model(id, RDC_Models[RDC_P_MODELB])
	#endif
	
	#if (defined RED) && (defined GOLD)
	if(g_has_rdc[id] == 1)
		set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODELB])
	else if(g_has_rdc[id] == 2)
		sub_p_model(id, RDC_Models[RDC_P_MODELB])
	#endif

	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODELB])
	#endif

	fm_play_weapon_animation(id, RDC_D_TRANSFORM)
	fm_set_weapon_idle_time(id, weapon_rdc, 3.5)
	set_pdata_float(id, m_flNextAttack, 3.5, PLAYER_LINUX_XTRA_OFF)
	make_dragon_spirit(id)
}

public Allow_Mode(id)
{
	id -= RDC_TASK_COOLDOWN

	if(!g_has_rdc[id])
		return

	g_rdc_preventmode[id] = false
}

public make_dragon_spirit(id)
{
	if(!g_has_rdc[id])
		return

	new Float:flOrigin[3]
	
	pev(id, pev_origin, flOrigin)

	new rdc_dragonspirit = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")) 

	if(!pev_valid(rdc_dragonspirit))
		return

	set_pev(rdc_dragonspirit, pev_classname, RDC_DRAGONSPIRIT_CLASSNAME)

	engfunc(EngFunc_SetOrigin, rdc_dragonspirit, flOrigin)

	set_pev(rdc_dragonspirit, pev_movetype, MOVETYPE_FOLLOW)

	set_pev(rdc_dragonspirit, pev_aiment, id)

	engfunc(EngFunc_SetModel, rdc_dragonspirit, RDC_Effects[1])

	set_pev(rdc_dragonspirit, pev_solid, SOLID_NOT)

	set_pev(rdc_dragonspirit, pev_animtime, get_gametime())
	
	set_pev(rdc_dragonspirit, pev_framerate, 1.0)
	
	set_pev(rdc_dragonspirit, pev_sequence, 1)

	set_task(3.5, "unleash_dragon", rdc_dragonspirit + RDC_TASK_UNLEASH)

	set_pev(rdc_dragonspirit, pev_nextthink, get_gametime() + 1.0)
}

public make_explosion(iEnt)
{
	new Float:flOrigin[3]
	pev(iEnt, pev_origin, flOrigin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) 
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_short(g_explo_spr)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND)
	message_end()
}

stock make_explosion2(id)
{
	if(!g_has_rdc[id])
		return

	static flOrigin[3]
	pev(id, pev_origin, flOrigin)

	new rdc_hole = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")) 

	if(!pev_valid(rdc_hole))
		return

	set_pev(rdc_hole, pev_classname, RDC_EXPLOSION_CLASSNAME)
	
	engfunc(EngFunc_SetModel, rdc_hole, RDC_Effects[2])

	set_pev(rdc_hole, pev_rendermode, kRenderTransAdd)

	set_pev(rdc_hole, pev_renderamt, 200.0)

	engfunc(EngFunc_SetOrigin, rdc_hole, flOrigin)

	set_pev(rdc_hole, pev_solid, SOLID_NOT)

	set_pev(rdc_hole, pev_scale, 0.1)

	set_pev(rdc_hole, pev_animtime, get_gametime())

	set_pev(rdc_hole, pev_framerate, 1.0)
	
	set_pev(rdc_hole, pev_sequence, 1)

	set_pev(rdc_hole, pev_life, get_gametime() + 0.5)

	set_pev(rdc_hole, pev_nextthink, get_gametime() + 0.1)

	emit_sound(id, CHAN_WEAPON, RDC_Sounds[5], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, flOrigin, 400.0)) != 0)
	{
		if (!is_user_alive(victim) || cs_get_user_team(victim) != CS_TEAM_T)
			continue
		
		fm_create_velocity_vector(victim, id, 200.0)
	}
	
}

public Set_1st_Attack(id)
{
	create_fake_attack(id)

	switch(g_current_mode[id])
	{
		case MODE_A: fm_play_weapon_animation(id, RDC_SHOOTA)
		case MODE_B: fm_play_weapon_animation(id, RDC_SHOOTB)
	}

	emit_sound(id, CHAN_WEAPON, RDC_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	make_fire_effect(id)
	
	static Float:cl_pushangle[3]
	cl_pushangle[0] = random_float(-3.5, -7.0)
	cl_pushangle[1] = random_float(3.0, -3.0)
	cl_pushangle[2] = 0.0
	
	set_pev(id, pev_punchangle, cl_pushangle)	
}

public create_fake_attack(id)
{
	static fake_weapon
	fake_weapon = fm_find_ent_by_owner(-1, "weapon_knife", id)
	
	if(pev_valid(fake_weapon))
		ExecuteHamB(Ham_Weapon_PrimaryAttack, fake_weapon)
}


public Set_2nd_Attack(id)
{
	id -= RDC_TASK_SHOOT

	if(!g_has_rdc[id])
		return

	create_fake_attack(id)

	switch(g_current_mode[id])
	{
		case MODE_A:
		{
			fm_play_weapon_animation(id, RDC_SHOOTA)
			emit_sound(id, CHAN_WEAPON, RDC_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
		}
		case MODE_B:
		{
			if(pev(g_rdc_dragon[id], pev_life) - get_gametime() <= 0.0)
			{
				fm_play_weapon_animation(id, RDC_D_RELOAD1)
				emit_sound(id, CHAN_WEAPON, RDC_Sounds[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
				g_rdc_dragon[id] = 0
				set_task(2.5, "ResetMode", id + RDC_TASK_RESET)

				#if (defined GOLD) && (!defined RED)
				if(get_pcvar_float(cvar_rdc_cooldown))
				{
					g_rdc_preventmode[id] = true
					set_task(get_pcvar_float(cvar_rdc_cooldown), "Allow_Mode", id + RDC_TASK_COOLDOWN)
				}
				#endif
				#if (defined RED) && (defined GOLD)
				switch(g_has_rdc[id])
				{
					case 1:
					{
						if(get_pcvar_float(cvar_rdc_cooldown[0]))
						{
							g_rdc_preventmode[id] = true
							set_task(get_pcvar_float(cvar_rdc_cooldown[0]), "Allow_Mode", id + RDC_TASK_COOLDOWN)
						}
					}
					case 2:
					{
						if(get_pcvar_float(cvar_rdc_cooldown[1]))
						{
							g_rdc_preventmode[id] = true
							set_task(get_pcvar_float(cvar_rdc_cooldown[1]), "Allow_Mode", id + RDC_TASK_COOLDOWN)
						}
					}
				}
				#endif
				#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
				if(get_pcvar_float(cvar_rdc_cooldown))
				{
					g_rdc_preventmode[id] = true
					set_task(get_pcvar_float(cvar_rdc_cooldown), "Allow_Mode", id + RDC_TASK_COOLDOWN)
				}
				#endif
			}
			else
			{
				fm_play_weapon_animation(id, RDC_SHOOTB)
				emit_sound(id, CHAN_WEAPON, RDC_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
			}

		}
	}
	
	make_fire_effect(id)
	check_radius_damage(id)
}

public ResetMode(id)
{
	id -= RDC_TASK_RESET

	if(!g_has_rdc[id])
		return

	fm_play_weapon_animation(id, RDC_D_RELOAD2)
	g_current_mode[id] = MODE_A

	#if (defined GOLD) && (!defined RED)
	sub_p_model(id, RDC_Models[RDC_P_MODEL])
	#endif
	
	#if (defined RED) && (defined GOLD)
	switch(g_has_rdc[id])
	{
		case 1:	set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODEL])
		case 2: sub_p_model(id, RDC_Models[RDC_P_MODEL])
	}
	#endif
	
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	set_pev(id, pev_weaponmodel2, RDC_Models[RDC_P_MODEL])
	#endif
}

public make_fire_effect(id)
{
	const MAX_FIRE = 12
	static Float:StartOrigin[3], Float:TargetOrigin[MAX_FIRE][3], Float:Speed[MAX_FIRE]

	// Get Target
	
	// -- Left
	get_position(id, 100.0, random_float(-10.0, -30.0), WEAPON_ATTACH_U, TargetOrigin[0]); Speed[0] = 150.0
	get_position(id, 100.0, random_float(-10.0, -30.0), WEAPON_ATTACH_U, TargetOrigin[1]); Speed[1] = 180.0
	get_position(id, 100.0,	random_float(-10.0, -30.0), WEAPON_ATTACH_U, TargetOrigin[2]); Speed[2] = 210.0
	get_position(id, 100.0, random_float(-10.0, -30.0), WEAPON_ATTACH_U, TargetOrigin[3]); Speed[3] = 240.0
	get_position(id, 100.0, random_float(-10.0, -30.0), WEAPON_ATTACH_U, TargetOrigin[4]); Speed[4] = 300.0

	// -- Center
	get_position(id, 100.0, 0.0, WEAPON_ATTACH_U, TargetOrigin[5]); Speed[5] = 150.0
	get_position(id, 100.0, 0.0, WEAPON_ATTACH_U, TargetOrigin[6]); Speed[6] = 300.0
	
	// -- Right
	get_position(id, 100.0, random_float(10.0, 30.0), WEAPON_ATTACH_U, TargetOrigin[7]); Speed[7] = 150.0
	get_position(id, 100.0, random_float(10.0, 30.0), WEAPON_ATTACH_U, TargetOrigin[8]); Speed[8] = 180.0
	get_position(id, 100.0,	random_float(10.0, 30.0), WEAPON_ATTACH_U, TargetOrigin[9]); Speed[9] = 210.0
	get_position(id, 100.0, random_float(10.0, 30.0), WEAPON_ATTACH_U, TargetOrigin[10]); Speed[10] = 240.0
	get_position(id, 100.0, random_float(10.0, 30.0), WEAPON_ATTACH_U, TargetOrigin[11]); Speed[11] = 300.0

	for(new i = 0; i < MAX_FIRE; i++)
	{
		// Get Start
		get_position(id, random_float(30.0, 40.0), 0.0, WEAPON_ATTACH_U, StartOrigin)
		create_fire(id, StartOrigin, TargetOrigin[i], Speed[i])
	}
}

public check_radius_damage(id)
{
	static Float:Origin[3]
	
	for(new i = 0; i <= g_maxplayers; i++)
	{
		if(!is_user_alive(i))
			continue
		
		if(cs_get_user_team(i) != CS_TEAM_T)
			continue

		if(id == i)
			continue
		
		pev(i, pev_origin, Origin)
		
		if(!fm_is_in_viewcone(id, Origin))
			continue

		if(fm_entity_range(id, i) >= 600.0)
			continue

		#if (defined GOLD) && (!defined RED)
		new Float:flDamageBase = get_pcvar_float(cvar_dmg_rdc)
		#endif
		#if (defined RED) && (defined GOLD)
		static Float:flDamageBase
		switch(g_has_rdc[id])
		{
			case 1: flDamageBase = get_pcvar_float(cvar_dmg_rdc[0])
			case 2: flDamageBase = get_pcvar_float(cvar_dmg_rdc[1])
		}
		#endif
		#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
		new Float:flDamageBase = get_pcvar_float(cvar_dmg_rdc)
		#endif

		new Float:flDamage = flDamageBase *	(fm_entity_range(id, i) + 100.0) / fm_entity_range(id, i)
		
		if(!is_user_bot(i))
		make_victim_effects(i, DMG_BURN, 226, 88, 34)
		fm_create_velocity_vector(i, id, 50.0)

		ExecuteHamB(Ham_TakeDamage, i, id, id, flDamage, DMG_NEVERGIB | DMG_BULLET)
		make_blood(i, flDamage)
	}
}

stock create_fire(id, Float:Origin[3], Float:TargetOrigin[3], Float:Speed, bool:dragon = false)
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	set_pev(iEnt, pev_classname, RDC_FIRE_CLASSNAME)
	engfunc(EngFunc_SetModel, iEnt, RDC_Sprites[3])

	static Float:vfAngle[3], Float:Velocity[3]
	pev(id, pev_angles, vfAngle)

	vfAngle[2] = float(random(18) * 20)

	// set info for ent
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	set_pev(iEnt, pev_rendermode, kRenderTransAdd)
	set_pev(iEnt, pev_renderamt, 250.0)
	
	
	if(dragon)
	{
		set_pev(iEnt, pev_life, get_gametime() + 1.5)
		set_pev(iEnt, pev_owner, id)
	}
	else
		set_pev(iEnt, pev_life, get_gametime() + 3.0)
		
	set_pev(iEnt, pev_scale, dragon ? 0.1 : 1.0)
	
	set_pev(iEnt, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEnt, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	engfunc(EngFunc_SetOrigin, iEnt, Origin)
	set_pev(iEnt, pev_gravity, 0.01)
	set_pev(iEnt, pev_angles, vfAngle)
	
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	
	set_pev(iEnt, pev_frame, 0.0)
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.05)

	get_speed_vector(Origin, TargetOrigin, Speed, Velocity)
	set_pev(iEnt, pev_velocity, Velocity)
}

public update_ammo(id)
{
	if(!is_user_alive(id))
		return
		
	message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, _, id)
	write_byte(1)
	write_byte(CSW_RDC)
	write_byte(-1)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_MsgAmmoX, .player = id)
	write_byte(7)
	write_byte(g_rdc_ammo[id])
	message_end()
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED

	static weapon[32], old_rdc[64]

	if(!fm_is_ent_classname(entity, "weaponbox"))
		return FMRES_IGNORED

	copy(weapon, charsmax(weapon), weapon_rdc)
	replace(weapon, charsmax(weapon), "weapon_", "")

	formatex(old_rdc, charsmax(old_rdc), "models/w_%s.mdl", weapon)

	static owner
	owner = pev(entity, pev_owner)

	if(equal(model, old_rdc))
	{
		static StoredWepID
		
		StoredWepID = fm_find_ent_by_owner(-1, weapon_rdc, entity)
	
		if(!pev_valid(StoredWepID))
			return FMRES_IGNORED
	
		if(g_has_rdc[owner])
		{
			#if (defined GOLD) && (!defined RED)
			set_pev(StoredWepID, pev_impulse, RDC_WEAPONKEY)
			switch(g_current_mode[owner])
			{
				case MODE_A: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODEL])
				case MODE_B: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODELB])
			}
			set_pev(entity, pev_body, 1)
			#endif
			#if (defined RED) && (defined GOLD)
			switch(g_has_rdc[owner])
			{
				case 1:
				{
					set_pev(StoredWepID, pev_impulse, RDC_WEAPONKEY)
					switch(g_current_mode[owner])
					{
						case MODE_A: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODEL])
						case MODE_B: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODELB])
					}
				}
				case 2:
				{
					set_pev(StoredWepID, pev_impulse, RDC_WEAPONKEY + 1)
					switch(g_current_mode[owner])
					{
						case MODE_A: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODEL])
						case MODE_B: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODELB])
					}
					set_pev(entity, pev_body, 1)
				}
			}
			#endif
			#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
			set_pev(StoredWepID, pev_impulse, RDC_WEAPONKEY)
			switch(g_current_mode[owner])
			{
				case MODE_A: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODEL])
				case MODE_B: engfunc(EngFunc_SetModel, entity, RDC_Models[RDC_W_MODELB])
			}
			#endif
			set_pev(StoredWepID, pev_mode, g_current_mode[owner])

			remove_cannonex(owner)

			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

#if (defined GOLD) && (!defined RED)
public give_cannonex(id)
#endif
#if (defined RED) && (defined GOLD)
public give_cannonex(id, mode)
#endif
#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
public give_cannonex(id)
#endif
{
	#if defined GOLD
	if(pev_valid(g_subpmodel[id]))
	{
		set_pev(g_subpmodel[id], pev_body, 0)
		set_pev(g_subpmodel[id], pev_flags, FL_KILLME)
		engfunc(EngFunc_RemoveEntity, g_subpmodel[id])
	}

	#endif
	//drop_weapons(id)

	#if (defined GOLD) && (!defined RED)
	g_has_rdc[id] = true
	#endif
	#if (defined RED) && (defined GOLD)
	g_has_rdc[id] = mode
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	g_has_rdc[id] = true
	#endif

	g_current_mode[id] = MODE_A

	fm_give_item(id, weapon_rdc)
	
	static weapon_ent
	weapon_ent = fm_find_ent_by_owner(-1, weapon_rdc, id)

	message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
	write_string("weapon_cannonex")
	write_byte(7)
	write_byte(100)
	write_byte(-1)
	write_byte(-1)
	write_byte(0)
	write_byte(8)
	write_byte(CSW_RDC)
	write_byte(0)
	message_end()
	
	cs_set_weapon_ammo(weapon_ent, 50)

	#if (defined GOLD) && (!defined RED)
	g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo)
	#endif
	#if (defined RED) && (defined GOLD)
	switch(g_has_rdc[id])
	{
		case 1: g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo[0])
		case 2: g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo[1])
	}
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	g_rdc_ammo[id] = get_pcvar_num(cvar_rdc_ammo)
	#endif
}

public remove_cannonex(id)
{
	#if defined GOLD
	if(pev_valid(g_subpmodel[id]))
	{
		set_pev(g_subpmodel[id], pev_body, 0)
		engfunc(EngFunc_RemoveEntity, g_subpmodel[id])
	}
	#endif

	g_has_rdc[id] = false
	g_current_mode[id] = 0
	engfunc(EngFunc_RemoveEntity, g_rdc_dragon[id])
	g_rdc_dragon[id] = 0
	drop_weapons(id, CSW_RDC)
	remove_task(id+RDC_TASK_SHOOT)
	remove_task(id+RDC_TASK_RESET)
	remove_task(id+RDC_TASK_REFILL)
}

public fw_DragonCannon_AddToPlayer(item, id)
{
	if(!pev_valid(item))
		return HAM_IGNORED

	switch(pev(item, pev_impulse))
	{
		case 0:
		{
			message_begin(MSG_ONE, g_MsgWeaponList, .player = id)
			write_string(weapon_rdc)
			write_byte(7)
			write_byte(100)
			write_byte(-1)
			write_byte(-1)
			write_byte(0)
			write_byte(8)
			write_byte(CSW_RDC)
			write_byte(0)
			message_end()
			
			return HAM_IGNORED
		}
		#if (defined GOLD) && (!defined RED)
		case RDC_WEAPONKEY:
		{
			g_has_rdc[id] = true

			if(pev(item, pev_mode))
				ResetMode(id+RDC_TASK_RESET)

			message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
			write_string("weapon_cannonex")
			write_byte(7)
			write_byte(100)
			write_byte(-1)
			write_byte(-1)
			write_byte(0)
			write_byte(8)
			write_byte(CSW_RDC)
			write_byte(0)
			message_end()

			set_pev(item, pev_impulse, 0)
			set_pev(item, pev_mode, 0)

			return HAM_HANDLED
		}
		#endif
		#if (defined RED) && (defined GOLD)
		case RDC_WEAPONKEY:
		{
			g_has_rdc[id] = 1

			if(pev(item, pev_mode))
				ResetMode(id+RDC_TASK_RESET)

			message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
			write_string("weapon_cannonex")
			write_byte(7)
			write_byte(100)
			write_byte(-1)
			write_byte(-1)
			write_byte(0)
			write_byte(8)
			write_byte(CSW_RDC)
			write_byte(0)
			message_end()

			set_pev(item, pev_impulse, 0)
			set_pev(item, pev_mode, 0)

			return HAM_HANDLED
		}
		case RDC_WEAPONKEY + 1:
		{
			g_has_rdc[id] = 2

			if(pev(item, pev_mode))
				ResetMode(id+RDC_TASK_RESET)

			message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
			write_string("weapon_cannonex")
			write_byte(7)
			write_byte(100)
			write_byte(-1)
			write_byte(-1)
			write_byte(0)
			write_byte(8)
			write_byte(CSW_RDC)
			write_byte(0)
			message_end()

			set_pev(item, pev_impulse, 0)
			set_pev(item, pev_mode, 0)

			return HAM_HANDLED
		}
		#endif
		#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
		case RDC_WEAPONKEY:
		{
			g_has_rdc[id] = true

			if(pev(item, pev_mode))
				ResetMode(id+RDC_TASK_RESET)

			message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, .player = id)
			write_string("weapon_cannonex")
			write_byte(7)
			write_byte(100)
			write_byte(-1)
			write_byte(-1)
			write_byte(0)
			write_byte(8)
			write_byte(CSW_RDC)
			write_byte(0)
			message_end()

			set_pev(item, pev_impulse, 0)
			set_pev(item, pev_mode, 0)

			return HAM_HANDLED
		}
		#endif
	}

	return HAM_IGNORED
}

public fw_DragonCannon_WeaponIdle_Post(rdc)
{
	if(pev_valid(rdc) != 2)
		return HAM_IGNORED

	new id = fm_cs_get_weapon_ent_owner(rdc)
	
	if(fm_cs_get_current_weapon_ent(id) != rdc)
		return HAM_IGNORED

	if (!g_has_rdc[id])
		return HAM_IGNORED;

	if(get_pdata_float(rdc, m_flTimeWeaponIdle, WEAP_LINUX_XTRA_OFF) <= 0.1)
	{
		switch(g_current_mode[id])
		{
			case MODE_A: fm_play_weapon_animation(id, RDC_IDLE)
			case MODE_B: fm_play_weapon_animation(id, RDC_IDLEB)
		}

		set_pdata_float(rdc, m_flTimeWeaponIdle, 10.0, WEAP_LINUX_XTRA_OFF)
	}

	return HAM_IGNORED
}

public fw_UpdateClientData_Post(id, SendWeapons, CD_Handle)
{
	if(!is_user_alive(id) || get_user_weapon(id) != CSW_RDC || !g_has_rdc[id])
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001)
	return FMRES_HANDLED
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static TruncatedWeapon[33], iAttacker, iVictim, weapon[32]
	
	copy(weapon, charsmax(weapon), weapon_rdc)
	replace(weapon, charsmax(weapon), "weapon_", "")

	get_msg_arg_string(4, TruncatedWeapon, charsmax(TruncatedWeapon))

	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)

	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE

	if(equal(TruncatedWeapon, weapon) && get_user_weapon(iAttacker) == CSW_RDC && g_has_rdc[iAttacker])
			set_msg_arg_string(4, "Dragon Cannon")

	return PLUGIN_CONTINUE
}

public fw_Touch(iEnt, iTouchedEnt)
{
	if (!pev_valid(iEnt) || !pev_valid(iTouchedEnt))
		return FMRES_IGNORED

	if(fm_is_ent_classname(iEnt, RDC_FIRE_CLASSNAME) && !fm_is_ent_classname(iTouchedEnt, RDC_FIRE_CLASSNAME))
	{
		set_pev(iEnt, pev_movetype, MOVETYPE_NONE)
		set_pev(iEnt, pev_solid, SOLID_NOT)

		new id = pev(iEnt, pev_owner)

		if(id)
		{
			if(is_user_alive(iTouchedEnt) && cs_get_user_team(iTouchedEnt) == CS_TEAM_T)
			{
				#if (defined GOLD) && (!defined RED)
				new Float:flDamage = get_pcvar_float(cvar_dmg_rdc)
				#endif
				#if (defined RED) && (defined GOLD)
				static Float:flDamage
				switch(g_has_rdc[id])
				{
					case 1: flDamage = get_pcvar_float(cvar_dmg_rdc[0])
					case 2: flDamage = get_pcvar_float(cvar_dmg_rdc[1])
				}
				#endif
				#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
				new Float:flDamage = get_pcvar_float(cvar_dmg_rdc)
				#endif

				if(!is_user_bot(iTouchedEnt))
				make_victim_effects(iTouchedEnt, DMG_BURN, 226, 88, 34)
				fm_create_velocity_vector(iTouchedEnt, id, 50.0)
				ExecuteHamB(Ham_TakeDamage, iTouchedEnt, id, id, flDamage, DMG_NEVERGIB | DMG_BULLET)
			}
		}
	}

	return FMRES_IGNORED
}

public fw_Think(iEnt)
{
	if(!pev_valid(iEnt))
		return FMRES_IGNORED

	if(fm_is_ent_classname(iEnt, RDC_FIRE_CLASSNAME))
	{
		new Float:fFrame, Float:fNextThink, Float:fScale
		pev(iEnt, pev_frame, fFrame)
		pev(iEnt, pev_scale, fScale)
		
		// effect exp
		new iMoveType = pev(iEnt, pev_movetype)
		
		if (iMoveType == MOVETYPE_NONE)
		{
			fNextThink = 0.0015
			fFrame += 0.5
			
			if (fFrame > 21.0)
			{
				engfunc(EngFunc_RemoveEntity, iEnt)
				return FMRES_IGNORED
			}
		}
		
		// effect normal
		else
		{
			fNextThink = 0.045
			
			fFrame += 0.5
			fScale += 0.01
			
			fFrame = floatmin(21.0, fFrame)
			fScale = floatmin(2.0, fFrame)
		}
		
		set_pev(iEnt, pev_frame, fFrame)
		set_pev(iEnt, pev_scale, fScale)
		set_pev(iEnt, pev_nextthink, get_gametime() + fNextThink)
		
		// time remove
		new Float:fTimeRemove
		pev(iEnt, pev_life, fTimeRemove)
		
		if (get_gametime() >= fTimeRemove)
		{
			if(!pev(iEnt, pev_owner))
				emit_sound(iEnt, CHAN_BODY, RDC_Sounds[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			engfunc(EngFunc_RemoveEntity, iEnt)
		}
	}
	else if(fm_is_ent_classname(iEnt, RDC_DRAGONSPIRIT_CLASSNAME))
	{
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	}
	else if(fm_is_ent_classname(iEnt, RDC_EXPLOSION_CLASSNAME))
	{
		if(pev(iEnt, pev_life) - get_gametime() <= 0.0)
		{
			set_pev(iEnt, pev_flags, FL_KILLME)
			engfunc(EngFunc_RemoveEntity, iEnt)
			return FMRES_IGNORED
		}

		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	}
	else if(fm_is_ent_classname(iEnt, RDC_DRAGON_CLASSNAME))
	{
		static Float:flOrigin[3], Float:TargetOrigin[3], Float:flSpeed, Float:flRate
		
		flRate = 0.2

		static id
		id = pev(iEnt, pev_owner)
		
		if(!g_has_rdc[id])
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return FMRES_IGNORED
		}

		pev(iEnt, pev_origin, flOrigin)

		flSpeed = pev(id, pev_maxspeed) - 5.0

		fm_get_aim_origin(id, TargetOrigin)
		npc_turntotarget(iEnt, TargetOrigin)

		if(pev(iEnt, pev_life) - get_gametime() >= 0.0 && pev(iEnt, pev_rate) - get_gametime() <= 0.0)
		{
			create_fire(id, flOrigin, TargetOrigin, 300.0, true)
			set_pev(iEnt, pev_rate, get_gametime() + flRate)
		}

		hook_ent2(iEnt, id, flSpeed)
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	}

	return FMRES_IGNORED
}

public unleash_dragon(rdc_dragonspirit)
{
	rdc_dragonspirit -= RDC_TASK_UNLEASH

	new id = pev(rdc_dragonspirit, pev_aiment)

	set_pev(rdc_dragonspirit, pev_flags, FL_KILLME)
	engfunc(EngFunc_RemoveEntity, rdc_dragonspirit)

	if(!is_user_alive(id) || !g_has_rdc[id])
		return

	g_rdc_dragon[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if(!pev_valid(g_rdc_dragon[id]))
		return

	new Float:flOrigin[3]
	
	pev(id, pev_origin, flOrigin)
	
	flOrigin[2] += 75.0

	set_pev(g_rdc_dragon[id], pev_classname, RDC_DRAGON_CLASSNAME)
	engfunc(EngFunc_SetModel, g_rdc_dragon[id], RDC_Effects[0])

	#if (defined GOLD) && (!defined RED)
	set_pev(g_rdc_dragon[id], pev_body, 1)
	#endif

	#if (defined RED) && (defined GOLD)
	if(g_has_rdc[id] == 2)
		set_pev(g_rdc_dragon[id], pev_body, 1)
	#endif

	engfunc(EngFunc_SetOrigin, g_rdc_dragon[id], flOrigin)

	make_explosion(g_rdc_dragon[id])
	
	make_explosion2(id)

	set_pev(g_rdc_dragon[id], pev_movetype, MOVETYPE_FLY)
	
	set_pev(g_rdc_dragon[id], pev_owner, id)

	set_pev(g_rdc_dragon[id], pev_solid, SOLID_NOT)

	set_pev(g_rdc_dragon[id], pev_animtime, get_gametime())

	set_pev(g_rdc_dragon[id], pev_framerate, 1.0)
	
	set_pev(g_rdc_dragon[id], pev_sequence, 1)

	#if (defined GOLD) && (!defined RED)
	set_pev(g_rdc_dragon[id], pev_life, get_gametime() + get_pcvar_float(cvar_rdc_duration))
	#endif
	#if (defined RED) && (defined GOLD)
	switch(g_has_rdc[id])
	{
		case 1: set_pev(g_rdc_dragon[id], pev_life, get_gametime() + get_pcvar_float(cvar_rdc_duration[0]))
		case 2: set_pev(g_rdc_dragon[id], pev_life, get_gametime() + get_pcvar_float(cvar_rdc_duration[1]))
	}
	#endif
	#if (!defined GOLD) && (defined RED) || (!defined GOLD) && (!defined RED)
	set_pev(g_rdc_dragon[id], pev_life, get_gametime() + get_pcvar_float(cvar_rdc_duration))
	#endif

	set_pev(g_rdc_dragon[id], pev_nextthink, get_gametime() + 0.1)
}

#if defined GOLD
stock sub_p_model(id, const weapon_model[], submodel = 1)
{
	if(pev_valid(g_subpmodel[id]))
	{
		engfunc(EngFunc_SetModel, g_subpmodel[id], weapon_model)
		return
	}

	g_subpmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if (!pev_valid(g_subpmodel[id]))
		return

	set_pev(id, pev_weaponmodel2, "")
	set_pev(g_subpmodel[id], pev_classname, "SubPCannonexModel")
	engfunc(EngFunc_SetModel, g_subpmodel[id], weapon_model)
	set_pev(g_subpmodel[id], pev_movetype, MOVETYPE_FOLLOW)
	set_pev(g_subpmodel[id], pev_aiment, id)
	set_pev(g_subpmodel[id], pev_body, submodel)
}
#endif

stock make_blood(id, Float:Damage)
{
	new bloodColor = ExecuteHam(Ham_BloodColor, id)
	new Float:origin[3]
	pev(id, pev_origin, origin)

	if (bloodColor == -1)
		return

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(bloodColor)
	write_byte(min(max(3, floatround(Damage)/5), 16))
	message_end()
}

stock fm_get_aim_origin(index, Float:origin[3])
{
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);

	return 1;
}

stock npc_turntotarget(ent, Float:Vic_Origin[3])
{
	static Float:newAngle[3], Float:EntOrigin[3]
	static Float:x, Float:z, Float:radians

	pev(ent, pev_angles, newAngle)
	pev(ent, pev_origin, EntOrigin)

	x = Vic_Origin[0] - EntOrigin[0]
	z = Vic_Origin[1] - EntOrigin[1]

	radians = floatatan(z / x, radian)
	newAngle[1] = radians * (180 / 3.14)

	if(Vic_Origin[0] < EntOrigin[0]) newAngle[1] -= 180.00

	set_pev(ent, pev_angles, newAngle)
}


stock fm_cs_get_current_weapon_ent(id)
	return get_pdata_cbase(id, m_pActiveItem, PLAYER_LINUX_XTRA_OFF)

stock fm_cs_get_weapon_ent_owner(ent)
	return get_pdata_cbase(ent, m_pPlayer, WEAP_LINUX_XTRA_OFF)

stock fm_set_weapon_idle_time(id, const class[], Float:IdleTime)
{
	static weapon_ent
	weapon_ent = fm_find_ent_by_owner(-1, class, id)

	if(!pev_valid(weapon_ent))
		return

	set_pdata_float(weapon_ent, m_flNextPrimaryAttack, IdleTime, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_ent, m_flNextSecondaryAttack, IdleTime, WEAP_LINUX_XTRA_OFF)
	set_pdata_float(weapon_ent, m_flTimeWeaponIdle, IdleTime + 0.50, WEAP_LINUX_XTRA_OFF)
}

stock fm_play_weapon_animation(const id, const Sequence)
{
	set_pev(id, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id)
	write_byte(Sequence)
	write_byte(pev(id, pev_body))
	message_end()
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", ent = index;

	switch (jghgtype)
	{
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
}

stock fm_give_item(index, const item[])
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock fm_get_user_weapon_entity(id, wid = 0)
{
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;

	if(!pev_valid(weap))
		return 0

	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return fm_find_ent_by_owner(-1, class, id);
}

stock bool:fm_is_ent_classname(index, const classname[])
{
	if (!pev_valid(index))
		return false;

	new class[32];
	pev(index, pev_classname, class, sizeof class - 1);

	if (equal(class, classname))
		return true;

	return false;
}

stock Float:fm_entity_range(ent1, ent2)
{
	new Float:origin1[3], Float:origin2[3]
	
	pev(ent1, pev_origin, origin1)
	pev(ent2, pev_origin, origin2)

	return get_distance_f(origin1, origin2)
}

stock hook_ent2(ent, id, Float:speed)
{
	if(!pev_valid(ent))
		return
	
	static Float:flVelocity[3], Float:EntOrigin[3], Float:flOrigin[3], Float:flDistance, Float:flTime
	
	pev(ent, pev_origin, EntOrigin)
	pev(id, pev_origin, flOrigin)

	flDistance = get_distance_f(EntOrigin, flOrigin)
	
	flTime = flDistance / speed

	if(pev(ent, pev_life) - get_gametime() <= 0.0)
	{
		flOrigin[2] += 50.0

		if(flDistance >= 20.0)
		{
			flVelocity[0] = (flOrigin[0] - EntOrigin[0]) / flTime
			flVelocity[1] = (flOrigin[1] - EntOrigin[1]) / flTime
			flVelocity[2] = (flOrigin[2] - EntOrigin[2]) / flTime
		}
		else
		{
			flVelocity[0] = 1.0
			flVelocity[1] = 1.0
			flVelocity[2] = 1.0
		}
	}

	else
	{
		if(flDistance >= 150.0)
		{
			flVelocity[0] = (flOrigin[0] - EntOrigin[0]) / flTime
			flVelocity[1] = (flOrigin[1] - EntOrigin[1]) / flTime
			flVelocity[2] = (flOrigin[2] - EntOrigin[2]) / flTime + 125.0
		}
		else
		{
			flVelocity[0] = 1.0
			flVelocity[1] = 1.0
			flVelocity[2] = 1.0
		}
	}
	set_pev(ent, pev_velocity, flVelocity)
}

stock bool:fm_is_in_viewcone(index, const Float:point[3])
{
	new Float:angles[3];
	pev(index, pev_angles, angles);
	engfunc(EngFunc_MakeVectors, angles);
	global_get(glb_v_forward, angles);
	angles[2] = 0.0;

	new Float:origin[3], Float:diff[3], Float:norm[3];
	pev(index, pev_origin, origin);
	xs_vec_sub(point, origin, diff);
	diff[2] = 0.0;
	xs_vec_normalize(diff, norm);

	new Float:dot, Float:fov;
	dot = xs_vec_dot(norm, angles);
	pev(index, pev_fov, fov);
	
	if (dot >= floatcos(fov * M_PI / 360))
		return true;

	return false;
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp) //for player
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock get_angle_to_target(id, const Float:fTarget[3], Float:TargetSize = 0.0)
{
	new Float:fOrigin[3], iAimOrigin[3], Float:fAimOrigin[3], Float:fV1[3]
	pev(id, pev_origin, fOrigin)
	get_user_origin(id, iAimOrigin, 3) // end position from eyes
	IVecFVec(iAimOrigin, fAimOrigin)
	xs_vec_sub(fAimOrigin, fOrigin, fV1)
	
	new Float:fV2[3]
	xs_vec_sub(fTarget, fOrigin, fV2)
	
	new iResult = get_angle_between_vectors(fV1, fV2)
	
	if (TargetSize > 0.0)
	{
		new Float:fTan = TargetSize / get_distance_f(fOrigin, fTarget)
		new fAngleToTargetSize = floatround( floatatan(fTan, degrees) )
		iResult -= (iResult > 0) ? fAngleToTargetSize : -fAngleToTargetSize
	}
	
	return iResult
}

stock get_angle_between_vectors(const Float:fV1[3], const Float:fV2[3])
{
	new Float:fA1[3], Float:fA2[3]
	engfunc(EngFunc_VecToAngles, fV1, fA1)
	engfunc(EngFunc_VecToAngles, fV2, fA2)
	
	new iResult = floatround(fA1[1] - fA2[1])
	iResult = iResult % 360
	iResult = (iResult > 180) ? (iResult - 360) : iResult
	
	return iResult
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]

	new Float:num = floatsqroot(speed * speed / (new_velocity[0] * new_velocity[0] + new_velocity[1] * new_velocity[1] + new_velocity[2] * new_velocity[2]))
	
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock fm_create_velocity_vector(victim, attacker, Float:Coef)
{
	if(is_user_connected(victim))
	{
		if(cs_get_user_team(victim) != CS_TEAM_T || !is_user_alive(attacker))
		return 0;

		new Float:velocity[3], Float:oldvelo[3]

		pev(victim, pev_velocity, oldvelo)

		new Float:vicorigin[3], Float:attorigin[3]

		pev(victim, pev_origin, vicorigin)
		pev(attacker, pev_origin, attorigin)

		new Float:origin2[3]

		origin2[0] = vicorigin[0] - attorigin[0]
		origin2[1] = vicorigin[1] - attorigin[1]
		
		new Float:largestnum
		
		if(floatabs(origin2[0]) > largestnum)
			largestnum = floatabs(origin2[0])
		
		if(floatabs(origin2[1]) > largestnum)
			largestnum = floatabs(origin2[1])
		
		origin2[0] /= largestnum
		origin2[1] /= largestnum
		
		velocity[0] = (origin2[0] * (Coef * 1000)) / floatround(fm_entity_range(victim, attacker))
		velocity[1] = (origin2[1] * (Coef * 1000)) / floatround(fm_entity_range(victim, attacker))
		
		if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
			velocity[2] = random_float(200.0 , 275.0)

		velocity[0] += oldvelo[0]
		velocity[1] += oldvelo[1]
		
		set_pev(victim, pev_velocity, velocity)
	}
	return 1;
}

stock make_victim_effects(victim, DMG_MESSAGE, FadeR, FadeG, FadeB)
{
	message_begin(MSG_ONE_UNRELIABLE, g_MsgEffect[0], .player = victim)
	write_byte(0)
	write_byte(0)
	write_long(DMG_MESSAGE)
	write_coord(0) 
	write_coord(0)
	write_coord(0)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_MsgEffect[1], .player = victim)
	write_short(1<<13)
	write_short(1<<14)
	write_short(0x0000)
	write_byte(FadeR)
	write_byte(FadeG)
	write_byte(FadeB)
	write_byte(100) 
	message_end()
		
	message_begin(MSG_ONE, g_MsgEffect[2], .player = victim)
	write_short(0xFFFF)
	write_short(1<<13)
	write_short(0xFFFF) 
	message_end()
}

stock bool:drop_weapons(id, wid = 0)
{
	static wname[32]

	if(wid)
	{
		new weapon = wid, clip, ammo;
		
		if (!weapon && !(weapon = get_user_weapon(id, clip, ammo)))
			return false
		
		get_weaponname(weapon, wname, sizeof wname - 1)
		engclient_cmd(id, "drop", wname)
	}

	else
	{
		static weapons[32], num, i, weaponid
		num = 0
		get_user_weapons(id, weapons, num)

		for (i = 0; i < num; i++)
		{
			weaponid = weapons[i]

			if((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)
			{
				get_weaponname(weaponid, wname, sizeof wname - 1)
				engclient_cmd(id, "drop", wname)
			}
		}
	}

	return true
}
