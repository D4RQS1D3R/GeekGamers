/*
*	Stun Rifle is a CSO weapon, More information about it: http://cso.wikia.com/wiki/Stun_Rifle
*	
*	This plugin written by me: Raheem (The basic things for any weapon not written by me)
*
*	I tried to simulate it same as in CSO, I think it's nearly same else simple things
*	That will be done in next versions.
*
*	Version 1.0 creation date: 16-6-2018
*	Version 1.0 publication date: 20-6-2018
*
*	Last update: 4-8-2018
*
*	TODO List: Fix any problem, include good ideas
*/

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta_util>

#define CustomItem(%0) (pev(%0, pev_impulse) == WEAPON_KEY)

// CWeaponBox
#define m_rgpPlayerItems_CWeaponBox 34

// CBasePlayerItem
#define m_pPlayer 41
#define m_pNext 42
#define m_iId 43

// CBasePlayerWeapon
#define m_flNextPrimaryAttack 46
#define m_flNextSecondaryAttack 47
#define m_flTimeWeaponIdle 48
#define m_iPrimaryAmmoType 49
#define m_iClip 51
#define m_fInReload 54
#define m_iWeaponState 74

// CBaseMonster
#define m_flNextAttack 83

// CBasePlayer
#define m_iFOV 363
#define m_rpgPlayerItems 367
#define m_pActiveItem 373
#define m_rgAmmo 376

/*-----------------------------------------------------*/

#define WEAPON_KEY 776544229
#define WEAPON_OLD "weapon_ak47"
#define WEAPON_NEW "weapon_stunrifle"

/*-----------------------------------------------------*/

new const WPN_SPRITES[][] =
{
	"sprites/weapon_stunrifle.txt",
	"sprites/640hud169.spr",
	"sprites/640hud7.spr"
}

new const g_szSounds[][] =
{
	"weapons/stunrifle-1.wav",
	"weapons/stunrifle_drawa.wav",
	"weapons/stunrifle_drawb.wav",
	"weapons/stunrifle_drawc.wav",
	"weapons/stunrifle_reloada.wav",
	"weapons/stunrifle_reloadb.wav",
	"weapons/stunrifle_reloadc.wav",
	"weapons/stunrifle_idlea.wav",
	"weapons/stunrifle_idleb.wav",
	"weapons/stunrifle_idlec.wav",
	"weapons/stunrifle_lowbattery.wav",
	"weapons/stunrifle-2.wav"
}

new const iWeaponList[] =
{  
	2, 30, -1, -1, 0, 1, CSW_AK47, 0
}

#define WEAPON_MODEL_V "models/[GeekGamers]/Primary/v_stunrifle.mdl"
#define WEAPON_MODEL_P "models/[GeekGamers]/Primary/p_stunrifle.mdl"
#define WEAPON_MODEL_W "models/[GeekGamers]/Primary/w_stunrifle.mdl"
#define WEAPON_BODY 0

/*-----------------------------------------------------*/

#define WEAPON_COST 0

#define WEAPON_CLIP 30
#define WEAPON_AMMO 90
#define WEAPON_RATE 0.098
#define WEAPON_RECOIL 0.96
#define WEAPON_DAMAGE 1.0 // AK47 damage multiplied by this factor

#define WEAPON_RATE_EX 0.169
#define WEAPON_RECOIL_EX 0.79
#define WEAPON_DAMAGE_EX 1.3
#define WEAPON_NATIVE "gg_set_user_stunrifle"

/*-----------------------------------------------------*/

// Animations
#define ANIM_IDLE_A 0
#define ANIM_IDLE_B 1
#define ANIM_IDLE_C 2
#define ANIM_ATTACK_A 3
#define ANIM_ATTACK_B 4
#define ANIM_ATTACK_C 5
#define ANIM_RELOAD_A 6
#define ANIM_RELOAD_B 7
#define ANIM_RELOAD_C 8
#define ANIM_DRAW_A 9
#define ANIM_DRAW_B 10
#define ANIM_DRAW_C 11

// from model: Frames / FPS
#define ANIM_IDLE_TIME_A 90/30.0
#define ANIM_SHOOT_TIME_A 31/30.0
#define ANIM_RELOAD_TIME_A 101/30.0
#define ANIM_DRAW_TIME_A 46/30.0
#define ANIM_IDLE_TIME_B 90/30.0
#define ANIM_SHOOT_TIME_B 31/30.0
#define ANIM_RELOAD_TIME_B 101/30.0
#define ANIM_DRAW_TIME_B 46/30.0
#define ANIM_IDLE_TIME_C 90/30.0
#define ANIM_SHOOT_TIME_C 31/30.0
#define ANIM_RELOAD_TIME_C 101/30.0
#define ANIM_DRAW_TIME_C 46/30.0

new g_AllocString_V, 
	g_AllocString_P, 
	g_AllocString_E,

	HamHook: g_fw_TraceAttack[4],
	
	g_iMsgID_Weaponlist,
	g_iStoredEnergy[33],
	bool:g_bHasStunRifle[33],
	g_pCvarBarFillTime,
	g_pCvarRadius,
	g_pCvarElecDmg,
	g_iLigSpr,
	g_iEffSpr,
	g_iEff2Spr,
	bool:g_bReloading[33],
	g_iAppearTimes[33]

public plugin_init()
{
	register_plugin("[GG] Stun Rifle", "1.1", "Raheem");
	
	RegisterHam(Ham_Item_Deploy, WEAPON_OLD, "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_PostFrame, WEAPON_OLD, "fw_Item_PostFrame");
	RegisterHam(Ham_Item_AddToPlayer, WEAPON_OLD, "fw_Item_AddToPlayer_Post", 1);
	RegisterHam(Ham_Weapon_Reload, WEAPON_OLD, "fw_Weapon_Reload");
	RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_OLD, "fw_Weapon_WeaponIdle");
	RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_OLD, "fw_Weapon_PrimaryAttack");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	g_fw_TraceAttack[0] = RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack");
	g_fw_TraceAttack[1] = RegisterHam(Ham_TraceAttack, "info_target",    "fw_TraceAttack");
	g_fw_TraceAttack[2] = RegisterHam(Ham_TraceAttack, "player",         "fw_TraceAttack");
	g_fw_TraceAttack[3] = RegisterHam(Ham_TraceAttack, "hostage_entity", "fw_TraceAttack");
	fm_ham_hook(false);
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");
	register_forward(FM_SetModel, "fw_SetModel");
	
	g_pCvarBarFillTime = register_cvar("amx_stunrifle_barfill_time", "5")	// Bar fill time in seconds
	g_pCvarRadius = register_cvar("amx_stunrifle_radius", "500")		// elec radius
	g_pCvarElecDmg = register_cvar("amx_stunrifle_electricity_dmg", "2")	// electricity damage - lowest damage for 1 bar only
	
	register_clcmd(WEAPON_NEW, "HookSelect");
	g_iMsgID_Weaponlist = get_user_msgid("WeaponList");
}

public plugin_precache()
{
	g_AllocString_V = engfunc(EngFunc_AllocString, WEAPON_MODEL_V);
	g_AllocString_P = engfunc(EngFunc_AllocString, WEAPON_MODEL_P);
	g_AllocString_E = engfunc(EngFunc_AllocString, WEAPON_OLD);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_V);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_P);
	engfunc(EngFunc_PrecacheModel, WEAPON_MODEL_W);
	
	for (new i = 0; i < sizeof g_szSounds; i++) engfunc(EngFunc_PrecacheSound, g_szSounds[i]);
	
	for(new i = 0; i < sizeof WPN_SPRITES;i++) precache_generic(WPN_SPRITES[i]);
	
	g_iLigSpr = precache_model("sprites/lightning.spr");
	g_iEffSpr = precache_model("sprites/ef_buffak_hit.spr");
	g_iEff2Spr = precache_model("sprites/muzzleflash67.spr");
}

public HookSelect(iPlayer)
{
	engclient_cmd(iPlayer, WEAPON_OLD);
}

public give(id)
{
	give_weapon_stunrifle(id)
}

public give_weapon_stunrifle(iPlayer)
{
	static iEnt; iEnt = engfunc(EngFunc_CreateNamedEntity, g_AllocString_E);
	if(iEnt <= 0) return 0;
	set_pev(iEnt, pev_spawnflags, SF_NORESPAWN);
	set_pev(iEnt, pev_impulse, WEAPON_KEY);
	ExecuteHam(Ham_Spawn, iEnt);
	UTIL_DropWeapon(iPlayer, 1);
	if(!ExecuteHamB(Ham_AddPlayerItem, iPlayer, iEnt)) {
		engfunc(EngFunc_RemoveEntity, iEnt);
		return 0;
	}
	ExecuteHamB(Ham_Item_AttachToPlayer, iEnt, iPlayer);
	set_pdata_int(iEnt, m_iClip, WEAPON_CLIP, 4);
	new iAmmoType = m_rgAmmo +get_pdata_int(iEnt, m_iPrimaryAmmoType, 4);
	if(get_pdata_int(iPlayer, m_rgAmmo, 5) < WEAPON_AMMO)
	set_pdata_int(iPlayer, iAmmoType, WEAPON_AMMO, 5);
	emit_sound(iPlayer, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	g_iStoredEnergy[iPlayer] = 0;
	g_bHasStunRifle[iPlayer] = true;
	set_task(get_pcvar_float(g_pCvarBarFillTime), "RechargeTask", iPlayer, _, _, "a", 6)
	return 1;
}

public plugin_natives()
{
	register_native(WEAPON_NATIVE, "give_weapon_stunrifle", 1);
}

public fw_Item_Deploy_Post(iItem)
{
	if(!CustomItem(iItem)) return;
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, 4);

	set_pev_string(iPlayer, pev_viewmodel2, g_AllocString_V);
	set_pev_string(iPlayer, pev_weaponmodel2, g_AllocString_P);
	
	if (g_iStoredEnergy[iPlayer] == 0)
	{
		// Draw A
		UTIL_SendWeaponAnim(iPlayer, ANIM_DRAW_A);
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_DRAW_TIME_A, 5);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_DRAW_TIME_A, 4);
	}
	else if (g_iStoredEnergy[iPlayer] > 0 && g_iStoredEnergy[iPlayer] <= 3)
	{
		// Draw B
		UTIL_SendWeaponAnim(iPlayer, ANIM_DRAW_B);
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_DRAW_TIME_B, 5);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_DRAW_TIME_B, 4);
	}
	else if (g_iStoredEnergy[iPlayer] > 3 && g_iStoredEnergy[iPlayer] <= 6)
	{
		// Draw C
		UTIL_SendWeaponAnim(iPlayer, ANIM_DRAW_C);
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_DRAW_TIME_C, 5);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_DRAW_TIME_C, 4);
	}
}

public fw_Item_PostFrame(iItem)
{
	if(!CustomItem(iItem)) return HAM_IGNORED;
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, 4);
	if(get_pdata_int(iItem, m_fInReload, 4) == 1) {
		static iClip; iClip = get_pdata_int(iItem, m_iClip, 4);
		static iAmmoType; iAmmoType = m_rgAmmo + get_pdata_int(iItem, m_iPrimaryAmmoType, 4);
		static iAmmo; iAmmo = get_pdata_int(iPlayer, iAmmoType, 5);
		static j; j = min(WEAPON_CLIP - iClip, iAmmo);
		set_pdata_int(iItem, m_iClip, iClip+j, 4);
		set_pdata_int(iPlayer, iAmmoType, iAmmo-j, 5);
		set_pdata_int(iItem, m_fInReload, 0, 4);
	}
	else switch(get_pdata_int(iItem, m_iWeaponState, 4) ) {
		case 0: {
			if(get_pdata_float(iItem, m_flNextSecondaryAttack, 4) <= 0.0)
			if(pev(iPlayer, pev_button) & IN_ATTACK2) {
				set_pdata_int(iPlayer, m_iFOV, get_pdata_int(iPlayer, m_iFOV, 5) == 90 ? 60 : 90);
				set_pdata_float(iItem, m_flNextSecondaryAttack, 0.3, 4);
			}
		}
	}
	
	return HAM_IGNORED;
}

public fw_Item_AddToPlayer_Post(iItem, iPlayer)
{
	switch(pev(iItem, pev_impulse)) {
		case WEAPON_KEY: { 
		s_weaponlist(iPlayer, true); 
		g_bHasStunRifle[iPlayer] = true;
		
		if (g_iStoredEnergy[iPlayer] < 6)
		{
			set_task(101/30.0, "OnReloadFinished", iPlayer);
		}
		else if (g_iStoredEnergy[iPlayer] == 6)
		{
			client_print(iPlayer, print_center, "Your Stun Rifle is fully charged!")
		}
		}
		case 0: s_weaponlist(iPlayer, false);
	}
}

public HAM_Spawn_Post(id)
{
	g_bHasStunRifle[id] = false
	g_iStoredEnergy[id] = 0;
}

public fw_Weapon_Reload(iItem)
{
	if(!CustomItem(iItem)) return HAM_IGNORED;
	static iClip; iClip = get_pdata_int(iItem, m_iClip, 4);
	if(iClip >= WEAPON_CLIP) return HAM_SUPERCEDE;
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, 4);
	static iAmmoType; iAmmoType = m_rgAmmo + get_pdata_int(iItem, m_iPrimaryAmmoType, 4);
	if(get_pdata_int(iPlayer, iAmmoType, 5) <= 0) return HAM_SUPERCEDE
	if(get_pdata_int(iPlayer, m_iFOV, 5) != 90) set_pdata_int(iPlayer, m_iFOV, 90, 5);

	set_pdata_int(iItem, m_iClip, 0, 4);
	ExecuteHam(Ham_Weapon_Reload, iItem);
	set_pdata_int(iItem, m_iClip, iClip, 4);

	set_pdata_int(iItem, m_fInReload, 1, 4);
	
	g_bReloading[iPlayer] = true;
	set_task(3.0, "AttackTask", iPlayer+444)

	if (g_iStoredEnergy[iPlayer] == 0)
	{
		// Reload A
		set_pdata_float(iItem, m_flNextPrimaryAttack, ANIM_RELOAD_TIME_A, 4);
		set_pdata_float(iItem, m_flNextSecondaryAttack, ANIM_RELOAD_TIME_A, 4);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_RELOAD_TIME_A, 4);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_RELOAD_TIME_A, 5);
		
		UTIL_SendWeaponAnim(iPlayer, ANIM_RELOAD_A);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[10], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	else if (g_iStoredEnergy[iPlayer] > 0 && g_iStoredEnergy[iPlayer] <= 3)
	{
		// Reload B
		set_pdata_float(iItem, m_flNextPrimaryAttack, ANIM_RELOAD_TIME_B, 4);
		set_pdata_float(iItem, m_flNextSecondaryAttack, ANIM_RELOAD_TIME_B, 4);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_RELOAD_TIME_B, 4);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_RELOAD_TIME_B, 5);
		
		UTIL_SendWeaponAnim(iPlayer, ANIM_RELOAD_B);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[5], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		
		if (notEmpty(iPlayer))
		{
			emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[11], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
	}
	else if (g_iStoredEnergy[iPlayer] > 3 && g_iStoredEnergy[iPlayer] <= 6)
	{
		// Reload C
		set_pdata_float(iItem, m_flNextPrimaryAttack, ANIM_RELOAD_TIME_C, 4);
		set_pdata_float(iItem, m_flNextSecondaryAttack, ANIM_RELOAD_TIME_C, 4);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_RELOAD_TIME_C, 4);
		set_pdata_float(iPlayer, m_flNextAttack, ANIM_RELOAD_TIME_C, 5);
		
		UTIL_SendWeaponAnim(iPlayer, ANIM_RELOAD_C);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[6], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		
		if (notEmpty(iPlayer))
		{
			emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[11], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
	}
	
	// Set task to recharge the battary
	remove_task(iPlayer)
	set_task(101/30.0, "OnReloadFinished", iPlayer)

	return HAM_SUPERCEDE;
}

public AttackTask(taskid)
{
	g_bReloading[taskid - 444] = false;
		
	// After reload reset the stored energy
	g_iStoredEnergy[taskid - 444] = 0;
	
	g_iAppearTimes[taskid - 444] = 0;
}

public client_PreThink(id)
{
	if (g_bReloading[id] && g_bHasStunRifle[id] && (get_user_weapon(id) == CSW_AK47))
	{
		if (g_iStoredEnergy[id] == 0)
		{
			// Reload A
			
		}
		else if (g_iStoredEnergy[id] > 0 && g_iStoredEnergy[id] <= 3)
		{
			// Reload B
			static Float:flOrigin[3]
			pev(id, pev_origin, flOrigin)
			new iVictim = -1;
			
			while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, flOrigin, get_pcvar_float(g_pCvarRadius))) != 0)
			{
				if (!is_user_alive(iVictim) || cs_get_user_team(iVictim) != CS_TEAM_T)
					continue
				
				static Float:flVecOrigin[3];
				pev(iVictim, pev_origin, flVecOrigin);
					
				ElectricBeam(id, flVecOrigin);
					
				ExecuteHam(Ham_TakeDamage, iVictim, id, id, get_pcvar_float(g_pCvarElecDmg) * g_iStoredEnergy[id], DMG_SLASH);
			
				fm_set_user_rendering(iVictim, kRenderFxGlowShell, 51, 51, 225, kRenderNormal, 10);
				set_task(101/30.0, "Delete_Glow", iVictim+4444);
			}
		}
		else if (g_iStoredEnergy[id] > 3 && g_iStoredEnergy[id] <= 6)
		{
			// Reload C
			static Float:flOrigin[3]
			pev(id, pev_origin, flOrigin)
			new iVictim = -1;
			
			while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, flOrigin, get_pcvar_float(g_pCvarRadius))) != 0)
			{
				if (!is_user_alive(iVictim) || cs_get_user_team(iVictim) != CS_TEAM_T)
					continue
				
				static Float:flVecOrigin[3]
				pev(iVictim, pev_origin, flVecOrigin)
				
				ElectricBeam(id, flVecOrigin)
				
				ExecuteHam(Ham_TakeDamage, iVictim, id, id, get_pcvar_float(g_pCvarElecDmg) * g_iStoredEnergy[id], DMG_SLASH);
				
				fm_set_user_rendering(iVictim, kRenderFxGlowShell, 51, 51, 225, kRenderNormal, 10);
				set_task(101/30.0, "Delete_Glow", iVictim+4444);
			}
		}
	}
}

public Delete_Glow(taskid)
{
	new id = taskid - 4444;
	fm_set_user_rendering(id);
}

public OnReloadFinished(id)
{
	remove_task(id)
	set_task(get_pcvar_float(g_pCvarBarFillTime), "RechargeTask", id, _, _, "a", 6)
}

public RechargeTask(id)
{
	if (!g_bHasStunRifle[id])
		return
	
	// Increase one bar every x time
	g_iStoredEnergy[id]++
	
	new szBars[100];
	
	switch(g_iStoredEnergy[id])
	{
		case 1:
		{
			szBars = "[ |           ]";
		}
		case 2:
		{
			szBars = "[ | |         ]";
		}
		case 3:
		{
			szBars = "[ | | |       ]";
		}
		case 4:
		{
			szBars = "[ | | | |     ]";
		}
		case 5:
		{
			szBars = "[ | | | | |   ]";
		}
		case 6:
		{
			szBars = "[ | | | | | | ]";
		}
	}
	
	set_dhudmessage(51, 153, 255, -1.0, -0.16, 0, 0.0, get_pcvar_float(g_pCvarBarFillTime) - 0.2)
	show_dhudmessage(id, "Stun Rifle Battary: %s", szBars)
	
	if (g_iStoredEnergy[id] == 6)
	{
		client_print(id, print_center, "Your Stun Rifle is fully charged!")
		remove_task(id)
	}
}

public fw_Weapon_WeaponIdle(iItem)
{
	if(!CustomItem(iItem) || get_pdata_float(iItem, m_flTimeWeaponIdle, 4) > 0.0) return HAM_IGNORED;
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, 4);

	if (g_iStoredEnergy[iPlayer] == 0)
	{
		// Idle A
		UTIL_SendWeaponAnim(iPlayer, ANIM_IDLE_A);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_IDLE_TIME_A, 4);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[7], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	else if (g_iStoredEnergy[iPlayer] > 0 && g_iStoredEnergy[iPlayer] <= 3)
	{
		// Idle B
		UTIL_SendWeaponAnim(iPlayer, ANIM_IDLE_B);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_IDLE_TIME_B, 4);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[8], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	else if (g_iStoredEnergy[iPlayer] > 3 && g_iStoredEnergy[iPlayer] <= 6)
	{
		// Idle C
		UTIL_SendWeaponAnim(iPlayer, ANIM_IDLE_C);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_IDLE_TIME_C, 4);
		
		emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[9], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	
	return HAM_SUPERCEDE;
}

public fw_Weapon_PrimaryAttack(iItem)
{
	if(!CustomItem(iItem)) return HAM_IGNORED;
	static iPlayer; iPlayer = get_pdata_cbase(iItem, m_pPlayer, 4);
	static iFOV; iFOV = (get_pdata_int(iPlayer, m_iFOV, 5) != 90);
	if(get_pdata_int(iItem, m_iClip, 4) == 0) {
		ExecuteHam(Ham_Weapon_PlayEmptySound, iItem);
		set_pdata_float(iItem, m_flNextPrimaryAttack, 0.2, 4);
		return HAM_SUPERCEDE;
	}
	static fw_TraceLine; fw_TraceLine = register_forward(FM_TraceLine, "fw_TraceLine_Post", 1);
	fm_ham_hook(true);
	state FireBullets: Enabled;
	ExecuteHam(Ham_Weapon_PrimaryAttack, iItem);
	state FireBullets: Disabled;
	unregister_forward(FM_TraceLine, fw_TraceLine, 1);
	fm_ham_hook(false);
	static Float:vecPunchangle[3];

	pev(iPlayer, pev_punchangle, vecPunchangle);
	vecPunchangle[0] *= iFOV ? WEAPON_RECOIL_EX : WEAPON_RECOIL;
	vecPunchangle[1] *= iFOV ? WEAPON_RECOIL_EX : WEAPON_RECOIL;
	vecPunchangle[2] *= iFOV ? WEAPON_RECOIL_EX : WEAPON_RECOIL;
	set_pev(iPlayer, pev_punchangle, vecPunchangle);

	emit_sound(iPlayer, CHAN_WEAPON, g_szSounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	if (g_iStoredEnergy[iPlayer] == 0)
	{
		// Idle A
		UTIL_SendWeaponAnim(iPlayer, ANIM_ATTACK_A);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_SHOOT_TIME_A, 4);
	}
	else if (g_iStoredEnergy[iPlayer] > 0 && g_iStoredEnergy[iPlayer] <= 3)
	{
		// Idle B
		UTIL_SendWeaponAnim(iPlayer, ANIM_ATTACK_B);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_SHOOT_TIME_B, 4);
	}
	else if (g_iStoredEnergy[iPlayer] > 3 && g_iStoredEnergy[iPlayer] <= 6)
	{
		// Idle C
		UTIL_SendWeaponAnim(iPlayer, ANIM_ATTACK_C);
		set_pdata_float(iItem, m_flTimeWeaponIdle, ANIM_SHOOT_TIME_C, 4);
	}
	
	Make_Muzzleflash(iPlayer)

	set_pdata_float(iItem, m_flNextPrimaryAttack, iFOV ? WEAPON_RATE_EX : WEAPON_RATE, 4);

	return HAM_SUPERCEDE;
}

public fw_PlaybackEvent() <FireBullets: Enabled> { return FMRES_SUPERCEDE; }
public fw_PlaybackEvent() <FireBullets: Disabled> { return FMRES_IGNORED; }
public fw_PlaybackEvent() <> { return FMRES_IGNORED; }
public fw_TraceAttack(iVictim, iAttacker, Float:flDamage) {
	if(!is_user_connected(iAttacker)) return;
	static iItem; iItem = get_pdata_cbase(iAttacker, m_pActiveItem, 5);
	static iFOV; iFOV = (get_pdata_int(iAttacker, m_iFOV, 5) != 90);
	static Float: flWeaponDamage; flWeaponDamage = (iFOV ? WEAPON_DAMAGE_EX : WEAPON_DAMAGE);
	if(iItem <= 0 || !CustomItem(iItem)) return;
        SetHamParamFloat(3, flDamage * flWeaponDamage);
}

public fw_UpdateClientData_Post(iPlayer, SendWeapons, CD_Handle)
{
	if(get_cd(CD_Handle, CD_DeadFlag) != DEAD_NO) return;
	static iItem; iItem = get_pdata_cbase(iPlayer, m_pActiveItem, 5);
	if(iItem <= 0 || !CustomItem(iItem)) return;
	set_cd(CD_Handle, CD_flNextAttack, 999999.0);
}

public fw_SetModel(iEnt)
{
	static i, szClassname[32], iItem; 
	pev(iEnt, pev_classname, szClassname, 31);
	if(!equal(szClassname, "weaponbox")) return FMRES_IGNORED;
	for(i = 0; i < 6; i++) {
		iItem = get_pdata_cbase(iEnt, m_rgpPlayerItems_CWeaponBox + i, 4);
		if(iItem > 0 && CustomItem(iItem)) {
			engfunc(EngFunc_SetModel, iEnt, WEAPON_MODEL_W);
			set_pev(iEnt, pev_body, WEAPON_BODY);
			new iPlayer = pev(iEnt, pev_owner);
			g_bHasStunRifle[iPlayer] = false;
			remove_task(iPlayer)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public fw_TraceLine_Post(const Float:flOrigin1[3], const Float:flOrigin2[3], iFrag, iIgnore, tr)
{
	if(iFrag & IGNORE_MONSTERS) return FMRES_IGNORED;
	static pHit; pHit = get_tr2(tr, TR_pHit);
	static Float:flvecEndPos[3]; get_tr2(tr, TR_vecEndPos, flvecEndPos);
	if(pHit > 0) {
		if(pev(pHit, pev_solid) != SOLID_BSP) return FMRES_IGNORED;
	}
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, flvecEndPos, 0);
	write_byte(TE_GUNSHOTDECAL);
	engfunc(EngFunc_WriteCoord, flvecEndPos[0]);
	engfunc(EngFunc_WriteCoord, flvecEndPos[1]);
	engfunc(EngFunc_WriteCoord, flvecEndPos[2]);
	write_short(pHit > 0 ? pHit : 0);
	write_byte(random_num(41, 45));
	message_end();

	return FMRES_IGNORED;
}

public fm_ham_hook(bool:on) {
	if(on) {
		EnableHamForward(g_fw_TraceAttack[0]);
		EnableHamForward(g_fw_TraceAttack[1]);
		EnableHamForward(g_fw_TraceAttack[2]);
		EnableHamForward(g_fw_TraceAttack[3]);
	}
	else {
		DisableHamForward(g_fw_TraceAttack[0]);
		DisableHamForward(g_fw_TraceAttack[1]);
		DisableHamForward(g_fw_TraceAttack[2]);
		DisableHamForward(g_fw_TraceAttack[3]);
	}
}

stock UTIL_SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, iPlayer);
	write_byte(iAnim);
	write_byte(0);
	message_end();
}

stock UTIL_DropWeapon(iPlayer, iSlot) {
	static iEntity, iNext, szWeaponName[32]; 
	iEntity = get_pdata_cbase(iPlayer, m_rpgPlayerItems + iSlot, 5);
	if(iEntity > 0) {       
		do {
			iNext = get_pdata_cbase(iEntity, m_pNext, 4)
			if(get_weaponname(get_pdata_int(iEntity, m_iId, 4), szWeaponName, 31)) {  
				engclient_cmd(iPlayer, "drop", szWeaponName);
			}
		} while(( iEntity = iNext) > 0);
	}
}

stock s_weaponlist(iPlayer, bool:on)
{
	message_begin(MSG_ONE, g_iMsgID_Weaponlist, {0,0,0}, iPlayer);
	write_string(on ? WEAPON_NEW : WEAPON_OLD);
	write_byte(iWeaponList[0]);
	write_byte(on ? WEAPON_AMMO : iWeaponList[1]);
	write_byte(iWeaponList[2]);
	write_byte(iWeaponList[3]);
	write_byte(iWeaponList[4]);
	write_byte(iWeaponList[5]);
	write_byte(iWeaponList[6]);
	write_byte(iWeaponList[7]);
	message_end();
}

stock ElectricBeam(id, Float:flOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(id | 0x1000)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_short(g_iLigSpr)
	write_byte(1); // framestart
	write_byte(100); // framerate - 5
	write_byte(1) // life - 30
	write_byte(30); // width
	write_byte(random_num(0, 10)); // noise
	write_byte(51); // r, g, b
	write_byte(51); // r, g, b
	write_byte(255); // r, g, b
	write_byte(200); // brightness
	write_byte(200); // speed
	message_end()
	
	if (g_iAppearTimes[id] >= 2)
		return
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, flOrigin[0]);
	engfunc(EngFunc_WriteCoord, flOrigin[1]);
	engfunc(EngFunc_WriteCoord, flOrigin[2]);
	write_short(g_iEffSpr);
	write_byte(10);
	write_byte(10);
	write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES|TE_EXPLFLAG_NODLIGHTS);
	message_end();
	
	g_iAppearTimes[id]++
}

stock notEmpty(id)
{
	static Float:flOrigin[3]
	pev(id, pev_origin, flOrigin)
	new iVictim = -1;
			
	while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, flOrigin, get_pcvar_float(g_pCvarRadius))) != 0)
	{
		if (!is_user_alive(iVictim) || cs_get_user_team(iVictim) != CS_TEAM_T)
			continue
		
		return true;
	}
	
	return false;
}

public Make_Muzzleflash(id)
{
	static Float:Origin[3], TE_FLAG
	get_position(id, 32.0, 6.0, -15.0, Origin)
	
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, Origin, id)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_iEff2Spr)
	write_byte(2)
	write_byte(30)
	write_byte(TE_FLAG)
	message_end()
}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}