#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN		"[GG] M3 Black Dragon"
#define VERSION		"1.0"
#define AUTHOR		"KORD_12.7"


//**********************************************
//* Weapon Settings.                           *
//**********************************************

#define WPNLIST	

// Main
#define WEAPON_KEY						785442
#define WEAPON_NAME 					"gg_weapon_m3dragon"

#define WEAPON_REFERANCE				"weapon_m3"
#define WEAPON_MAX_CLIP					8
#define WEAPON_DEFAULT_AMMO				32

#define WEAPON_TIME_NEXT_IDLE 			15.0
#define WEAPON_TIME_NEXT_ATTACK 		1.0
#define WEAPON_TIME_DELAY_DEPLOY 		1.0

#define WEAPON_MULTIPLIER_DAMAGE  	  	1.5

#define WEAPON_RADIUS_DRAGON_ATTACK		200.0
#define WEAPON_DRAGON_DAMAGE_ATTACK		random_float(100.0, 200.0)

#define WEAPON_BALL_RADIUS_EXP			150.0			
#define WEAPON_DAMAGE_BALL_EXP			random_float(70.0, 100.0)

// Models
#define MODEL_WORLD						"models/[GeekGamers]/Primary/w_m3dragon.mdl"
#define MODEL_VIEW						"models/[GeekGamers]/Primary/v_m3dragon.mdl"
#define MODEL_PLAYER					"models/[GeekGamers]/Primary/p_m3dragon.mdl"
#define MODEL_DRAGON					"models/[GeekGamers]/Primary/m3dragon_effect.mdl"
#define MODEL_FIREBALL					"models/[GeekGamers]/Primary/ef_fireball2.mdl"

// Sounds
#define SOUND_FIRE						"weapons/m3dragon_shoot1.wav"
#define SOUND_FIRE_B					"weapons/m3dragon_shoot2.wav"
#define SOUND_EXPLODE					"weapons/m3dragon_exp.wav"
#define SOUND_DRAGON					"weapons/m3dragon_dragon_fx.wav"

// Sprites
#define WEAPON_HUD_TXT					"sprites/gg_weapon_m3dragon.txt"
#define WEAPON_HUD_SPR					"sprites/640hud18.spr"
#define WEAPON_HUD_SPR2					"sprites/[GeekGamers]/Weapons/640hud177.spr"
#define WEAPON_SPR_EXP					"sprites/[GeekGamers]/Weapons/fexplo.spr"
#define WEAPON_SPR_SMOKE				"sprites/[GeekGamers]/Weapons/steam1.spr"
#define WEAPON_MUZZLE					"sprites/[GeekGamers]/Weapons/m3dragon_flame.spr"
#define WEAPON_MUZZLE_B					"sprites/[GeekGamers]/Weapons/m3dragon_flame2.spr"

// Animation
#define ANIM_EXTENSION					"shotgun"

// Animation sequences
enum
{	
	ANIM_IDLE,
	ANIM_SHOOT,
	ANIM_SHOOT2,
	ANIM_INSERT,
	ANIM_AFTER_RELOAD,
	ANIM_BEFOR_RELOAD,
	ANIM_DRAW,

	ANIM_IDLE_B,
	ANIM_SHOOT_B,
	ANIM_INSERT_B,
	ANIM_AFTER_RELOAD_B,
	ANIM_BEFOR_RELOAD_B,
	ANIM_DRAW_B,
};
//**********************************************
//* Some macroses.                             *
//**********************************************

#define MDLL_Spawn(%0)				dllfunc(DLLFunc_Spawn, %0)
#define MDLL_Touch(%0,%1)			dllfunc(DLLFunc_Touch, %0, %1)
#define MDLL_USE(%0,%1)				dllfunc(DLLFunc_Use, %0, %1)

#define SET_MODEL(%0,%1)			engfunc(EngFunc_SetModel, %0, %1)
#define SET_ORIGIN(%0,%1)			engfunc(EngFunc_SetOrigin, %0, %1)

#define PRECACHE_MODEL(%0)			engfunc(EngFunc_PrecacheModel, %0)
#define PRECACHE_SOUND(%0)			engfunc(EngFunc_PrecacheSound, %0)
#define PRECACHE_GENERIC(%0)		engfunc(EngFunc_PrecacheGeneric, %0)

#define MESSAGE_BEGIN(%0,%1,%2,%3)	engfunc(EngFunc_MessageBegin, %0, %1, %2, %3)
#define MESSAGE_END()				message_end()

#define WRITE_ANGLE(%0)				engfunc(EngFunc_WriteAngle, %0)
#define WRITE_BYTE(%0)				write_byte(%0)
#define WRITE_COORD(%0)				engfunc(EngFunc_WriteCoord, %0)
#define WRITE_STRING(%0)			write_string(%0)
#define WRITE_SHORT(%0)				write_short(%0)

#define BitSet(%0,%1) 				(%0 |= (1 << (%1 - 1)))
#define BitClear(%0,%1) 			(%0 &= ~(1 << (%1 - 1)))
#define BitCheck(%0,%1) 			(%0 & (1 << (%1 - 1)))

//**********************************************
//* PvData Offsets.                            *
//**********************************************

// Linux extra offsets
#define extra_offset_weapon				4
#define extra_offset_player				5

new g_bitIsConnected;

#define m_rgpPlayerItems_CWeaponBox		34

// CBasePlayerItem
#define m_pPlayer						41
#define m_pNext							42
#define m_iId                        	43

// CBasePlayerWeapon
#define m_fInSuperBullets				30
#define m_flNextPrimaryAttack			46
#define m_flNextSecondaryAttack			47
#define m_flTimeWeaponIdle				48
#define m_iPrimaryAmmoType				49
#define m_iClip							51
#define m_fInSpecialReload  			55
#define m_fWeaponState					74
#define m_flNextAttack					83
#define m_iLastZoom 					109

// CBasePlayer
#define m_flVelocityModifier 			108 
#define m_fResumeZoom       			110
#define m_iFOV							363
#define m_rgpPlayerItems_CBasePlayer	367
#define m_pActiveItem					373
#define m_rgAmmo_CBasePlayer			376
#define m_szAnimExtention				492

#define IsValidPev(%0) 					(pev_valid(%0) == 2)

#define MUZZLE_CLASSNAME_LEFT			"MuzzleLeft"
#define MUZZLE_CLASSNAME_RIGHT			"MuzzleRight"
#define BALL_CLASSNAME					"FireBall"
#define DRAGON_CLASSNAME				"FireDragon"

//**********************************************
//* Let's code our weapon.                     *
//**********************************************

new iBlood[4];
new iSpriteleft[33];
new iSpriteright[33];

Weapon_OnPrecache()
{
	PRECACHE_MODEL(MODEL_WORLD);
	PRECACHE_MODEL(MODEL_VIEW);
	PRECACHE_MODEL(MODEL_PLAYER);
	PRECACHE_MODEL(MODEL_DRAGON);
	PRECACHE_MODEL(MODEL_FIREBALL);
	
	PRECACHE_SOUND(SOUND_FIRE);
	PRECACHE_SOUND(SOUND_FIRE_B);
	PRECACHE_SOUND(SOUND_EXPLODE);
	PRECACHE_SOUND(SOUND_DRAGON);
	precache_sound("weapons/m3dragon_secondary_draw.wav")
	precache_sound("weapons/m3dragon_reload_insert.wav")
	precache_sound("weapons/m3dragon_fire_loop.wav")
	precache_sound("weapons/m3dragon_after_reload.wav")
	
	#if defined WPNLIST
	PRECACHE_GENERIC(WEAPON_HUD_TXT);
	PRECACHE_GENERIC(WEAPON_HUD_SPR);
	PRECACHE_GENERIC(WEAPON_HUD_SPR2);
	#endif
	
	PRECACHE_MODEL(WEAPON_MUZZLE);
	PRECACHE_MODEL(WEAPON_MUZZLE_B);
	
	iBlood[0] = PRECACHE_MODEL("sprites/bloodspray.spr");
	iBlood[1] = PRECACHE_MODEL("sprites/blood.spr");
	iBlood[2] = PRECACHE_MODEL(WEAPON_SPR_EXP);
	iBlood[3] = PRECACHE_MODEL(WEAPON_SPR_SMOKE);
}

Weapon_OnSpawn(const iItem)
{
	// Setting world model.
	SET_MODEL(iItem, MODEL_WORLD);
}

Weapon_OnDeploy(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode)
{
	#pragma unused iClip, iAmmoPrimary, iReloadMode
	static iszViewModel;
	if (iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, MODEL_VIEW)))
	{
		set_pev_string(iPlayer, pev_viewmodel2, iszViewModel);
	}
	static iszPlayerModel;
	if (iszPlayerModel || (iszPlayerModel = engfunc(EngFunc_AllocString, MODEL_PLAYER)))
	{
		set_pev_string(iPlayer, pev_weaponmodel2, iszPlayerModel);
	}

	set_pdata_int(iItem, m_fInSpecialReload, false, extra_offset_weapon);

	set_pdata_string(iPlayer, m_szAnimExtention * 4, ANIM_EXTENSION, -1, extra_offset_player * 4);
	
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_DELAY_DEPLOY, extra_offset_weapon);
	set_pdata_float(iPlayer, m_flNextAttack, WEAPON_TIME_DELAY_DEPLOY, extra_offset_player);

	Weapon_DefaultDeploy(iPlayer, MODEL_VIEW, MODEL_PLAYER, iMode ? ANIM_DRAW_B:ANIM_DRAW, ANIM_EXTENSION);
	
	Update_HUD(iItem, iPlayer, 0);
	Update_HUD(iItem, iPlayer, 1);
	
	if (iMode)
	{
		MuzzleFlash_Left(iPlayer, WEAPON_MUZZLE, 0.08, 20.0);
		MuzzleFlash_Right(iPlayer, WEAPON_MUZZLE_B, 0.08, 20.0);
	}
}

Weapon_OnHolster(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode)
{
	#pragma unused iPlayer, iClip, iAmmoPrimary, iMode, iReloadMode
	
	set_pdata_int(iItem, m_fInSpecialReload, false, extra_offset_weapon);
	
	Update_HUD(iItem, iPlayer, 0);
	
	if (pev_valid(iSpriteleft[iPlayer]) && pev_valid(iSpriteright[iPlayer]))
	{
		set_pev(iSpriteleft[iPlayer], pev_fuser1, get_gametime() + 0.0);
		set_pev(iSpriteright[iPlayer], pev_fuser2, get_gametime() + 0.0);
	}
}

Weapon_OnReload(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode)
{
	if(iAmmoPrimary <= 0)
	{
		return HAM_IGNORED;
	}
	
	if (iClip >=WEAPON_MAX_CLIP)
	{
		return HAM_IGNORED;
	}

	switch(iReloadMode)
	{
		case 0:
		{
			Weapon_SendAnim(iPlayer, iMode ? ANIM_BEFOR_RELOAD_B:ANIM_BEFOR_RELOAD);
			
			set_pdata_float(iItem, m_flNextPrimaryAttack, 0.5, extra_offset_weapon);
			set_pdata_float(iItem, m_flTimeWeaponIdle, 0.5, extra_offset_weapon);
			
			set_pdata_int(iItem, m_fInSpecialReload, 1, extra_offset_weapon);
			
			return HAM_IGNORED;
		}
		case 1:
		{		
			if (get_pdata_int(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
			{
				return HAM_IGNORED;
			}
				
			Weapon_SendAnim(iPlayer, iMode ? ANIM_INSERT_B : ANIM_INSERT);
					
			set_pdata_int(iItem, m_fInSpecialReload, 2, extra_offset_weapon);
			set_pdata_float(iItem, m_flTimeWeaponIdle, 0.5, extra_offset_weapon);
				
			static szAnimation[64];

			formatex(szAnimation, charsmax(szAnimation), "ref_reload_shotgun");
			Player_SetAnimation(iPlayer, szAnimation);
				
		}
		case 2:
		{
			set_pdata_int(iItem, m_iClip, iClip + 1, extra_offset_weapon);
			set_pdata_int(iPlayer, 381, iAmmoPrimary-1, extra_offset_player);
			set_pdata_int(iItem, m_fInSpecialReload, 1, extra_offset_weapon);
		}
	}
	
	switch(iReloadMode)
	{
		case 0:
		{
			Weapon_SendAnim(iPlayer, iMode ? ANIM_BEFOR_RELOAD_B : ANIM_BEFOR_RELOAD);
			
			set_pdata_float(iItem, m_flNextPrimaryAttack, 0.5, extra_offset_weapon);
			set_pdata_float(iItem, m_flTimeWeaponIdle, 0.5, extra_offset_weapon);
			
			set_pdata_int(iItem, m_fInSpecialReload, 1, extra_offset_weapon);
			
			return HAM_IGNORED;
		}
	}
	return HAM_IGNORED;
}


Weapon_OnIdle(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode)
{
	#pragma unused iClip, iAmmoPrimary
	
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iItem);

	if(iClip == WEAPON_MAX_CLIP)
	{
		if(iReloadMode == 2)
		{
			Weapon_ReloadEnd(iItem, iPlayer, iMode);
			return;
		}
	}
	
	if(iAmmoPrimary <= 0)
	{
		if(iReloadMode == 2)
		{
			Weapon_ReloadEnd(iItem, iPlayer, iMode);
			return;
		}
	}

	switch(iReloadMode)
	{
		case 1:
		{		
			if (get_pdata_int(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
			{
				return;
			}
			
			Weapon_SendAnim(iPlayer, iMode ? ANIM_INSERT_B: ANIM_INSERT);
				
			set_pdata_int(iItem, m_fInSpecialReload, 2, extra_offset_weapon);
			set_pdata_float(iItem, m_flTimeWeaponIdle, 0.5, extra_offset_weapon);
			
			static szAnimation[64];

			formatex(szAnimation, charsmax(szAnimation), "ref_reload_shotgun");
			Player_SetAnimation(iPlayer, szAnimation);
			
		}
		case 2:
		{
			set_pdata_int(iItem, m_iClip, iClip + 1, extra_offset_weapon);
			set_pdata_int(iPlayer, 381, iAmmoPrimary-1, extra_offset_player);
			set_pdata_int(iItem, m_fInSpecialReload, 1, extra_offset_weapon);
		}
	}
	
	if(!iReloadMode)
	{
		if (get_pdata_int(iItem, m_flTimeWeaponIdle, extra_offset_weapon) > 0.0)
		{
			return;
		}
	
		set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_NEXT_IDLE, extra_offset_weapon);
		Weapon_SendAnim(iPlayer, iMode ? ANIM_IDLE_B : ANIM_IDLE);
	}
}	

Weapon_OnPrimaryAttack(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode)
{
	#pragma unused iAmmoPrimary
	
	static iFlags, iAnimDesired; 
	static szAnimation[64];iFlags = pev(iPlayer, pev_flags);

	if(iReloadMode > 0 && iClip > 0)
	{
		Weapon_ReloadEnd(iItem, iPlayer, iMode);
		return;
	}
	
	CallOrigFireBullets3(iItem, iPlayer)

	if (iClip <= 0 || pev(iPlayer, pev_waterlevel) == 3)
	{
		return;
	}

	Punchangle(iPlayer, .iVecx = -2.0, .iVecy = 0.0, .iVecz = 0.0);

	Weapon_SendAnim(iPlayer, iMode ? ANIM_SHOOT_B:ANIM_SHOOT);
				
	formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", ANIM_EXTENSION);
								
	if ((iAnimDesired = lookup_sequence(iPlayer, szAnimation)) == -1)
	{
		iAnimDesired = 0;
	}
					
	set_pev(iPlayer, pev_sequence, iAnimDesired);

	set_pdata_float(iItem, m_flNextPrimaryAttack, WEAPON_TIME_NEXT_ATTACK, extra_offset_weapon);
	set_pdata_float(iItem, m_flTimeWeaponIdle, WEAPON_TIME_NEXT_ATTACK+1.0, extra_offset_weapon);
	
	engfunc(EngFunc_EmitSound, iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
}

Weapon_OnSecondaryAttack(const iItem, const iPlayer, const iClip, const iAmmoPrimary, const iMode, const iReloadMode) 
{
	#pragma unused iAmmoPrimary

	if(iReloadMode > 0 && iClip > 0)
	{
		Weapon_ReloadEnd(iItem, iPlayer, iMode);
		return;
	}

	if (get_pdata_float(iItem, m_flNextSecondaryAttack, extra_offset_weapon) > 0.0)
	{
		return;
	}
	
	if (pev(iPlayer, pev_button) & IN_ATTACK2)
	{
		if (!iMode || pev(iPlayer, pev_waterlevel) == 3)
		{
			return;
		}
	
		static iFlags; 
		static iAnimDesired; 
		static szAnimation[64];iFlags = pev(iPlayer, pev_flags);
		static pEntity;
		static Float:fOrigin[3],Float:vecEnd[3];fm_get_aim_origin(iPlayer, vecEnd);Get_Position(iPlayer, 15.0, 0.0, -5.0, fOrigin);
		static iszAllocStringCached;

		Punchangle(iPlayer, .iVecx = -4.0, .iVecy = 0.0, .iVecz = 0.0);
		
		Weapon_SendAnim(iPlayer, ANIM_SHOOT2);

		engfunc(EngFunc_EmitSound, iPlayer, CHAN_WEAPON, SOUND_FIRE_B, 0.9, ATTN_NORM, 0, PITCH_NORM);
				
		formatex(szAnimation, charsmax(szAnimation), iFlags & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", ANIM_EXTENSION);
								
		if ((iAnimDesired = lookup_sequence(iPlayer, szAnimation)) == -1)
		{
			iAnimDesired = 0;
		}
					
		set_pev(iPlayer, pev_sequence, iAnimDesired);

		set_pdata_float(iItem, m_flNextSecondaryAttack, 2.0, extra_offset_weapon);
		set_pdata_float(iItem, m_flTimeWeaponIdle, 2.0, extra_offset_weapon);

		if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "info_target")))
		{
			pEntity = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
		}
		
		if (pev_valid(pEntity))
		{
			set_pev(pEntity, pev_movetype, MOVETYPE_FLYMISSILE);
			set_pev(pEntity, pev_owner, iPlayer);
			
			SET_MODEL(pEntity,MODEL_FIREBALL)
			SET_ORIGIN(pEntity,fOrigin)
	
			set_pev(pEntity, pev_classname, BALL_CLASSNAME);
			set_pev(pEntity, pev_mins, Float:{-0.01, -0.01, -0.01});
			set_pev(pEntity, pev_maxs, Float:{0.01, 0.01, 0.01});
			set_pev(pEntity, pev_gravity, 0.01);
			set_pev(pEntity, pev_solid, SOLID_BBOX);
			set_pev(pEntity, pev_nextthink, get_gametime() + 0.1);
	
			static Float:Velocity[3];Get_Speed_Vector(fOrigin, vecEnd, 1000.0, Velocity);
			set_pev(pEntity, pev_velocity, Velocity);
				
			Sprite_SetTransparency(pEntity, kRenderTransAdd, Float:{255.255,255.0,255.0}, 150.0);
		}
		
		Update_HUD(iItem, iPlayer, 0);
		set_pdata_int(iItem, m_fWeaponState, 0, extra_offset_weapon);
		set_pdata_int(iItem, m_fInSuperBullets, 0, extra_offset_weapon);
		Update_HUD(iItem, iPlayer, 1);
		
		if (pev_valid(iSpriteleft[iPlayer]) && pev_valid(iSpriteright[iPlayer]))
		{
			set_pev(iSpriteleft[iPlayer], pev_fuser1, get_gametime() + 0.0);
			set_pev(iSpriteright[iPlayer], pev_fuser2, get_gametime() + 0.0);
		}
	}
}

Weapon_ReloadEnd(const iItem, const iPlayer, const iMode)
{
	Weapon_SendAnim(iPlayer, iMode ? ANIM_AFTER_RELOAD_B:ANIM_AFTER_RELOAD);
	
	set_pdata_float(iItem, m_flNextPrimaryAttack, 0.6, extra_offset_weapon);
	set_pdata_float(iItem, m_flTimeWeaponIdle, 1.4, extra_offset_weapon);
	
	set_pdata_int(iItem, m_fInSpecialReload, 0, extra_offset_weapon);
}

Update_HUD(const iItem, const iPlayer, UpdateMode)
{
	new iSprite[33];
	static iMode;iMode=get_pdata_int(iItem, m_fWeaponState, extra_offset_weapon);
	format(iSprite, charsmax(iSprite), "number_%d", iMode);

	if(UpdateMode && iMode > 0)
	{
		message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, iPlayer);
		write_byte(1);
		write_string(iSprite); 
		write_byte(30);
		write_byte(144); 
		write_byte(255);
		message_end();
	}
	else
	{
		message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, iPlayer);
		write_byte(0);
		write_string(iSprite); 
		write_byte(30);
		write_byte(144); 
		write_byte(255);
		message_end();
	}
}


//*********************************************************************
//*           Don't modify the code below this line unless            *
//*          	 you know _exactly_ what you are doing!!!             *
//*********************************************************************

#define MSGID_WEAPONLIST 78

new RoundEend;

#define IsCustomItem(%0) (pev(%0, pev_impulse) == WEAPON_KEY)

public plugin_precache()
{
	Weapon_OnPrecache();
	#if defined WPNLIST
	register_clcmd(WEAPON_NAME, "Cmd_WeaponSelect");
	register_message(MSGID_WEAPONLIST, "MsgHook_WeaponList");
	#endif
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_forward(FM_PlaybackEvent,				"FakeMeta_PlaybackEvent",	 false);
	register_forward(FM_SetModel,					"FakeMeta_SetModel",		 false);
	register_forward(FM_UpdateClientData,				"FakeMeta_UpdateClientData_Post",true);
	register_forward(FM_Touch, 					"FakeMeta_Touch",		 false);
	register_forward(FM_Think, 					"FakeMeta_Think",		 false);
	
	RegisterHam(Ham_Spawn, 				"weaponbox", 			"HamHook_Weaponbox_Spawn_Post", true);

	RegisterHam(Ham_Killed,				"player",				"HamHook_Entity_Killed");

	RegisterHam(Ham_TraceAttack,		"func_breakable",		"HamHook_Entity_TraceAttack", 	false);
	RegisterHam(Ham_TraceAttack,		"info_target", 			"HamHook_Entity_TraceAttack", 	false);
	RegisterHam(Ham_TraceAttack,		"player", 				"HamHook_Entity_TraceAttack", 	false);

	RegisterHam(Ham_Item_Deploy,		WEAPON_REFERANCE, 		"HamHook_Item_Deploy_Post",	true);
	RegisterHam(Ham_Item_Holster,		WEAPON_REFERANCE, 		"HamHook_Item_Holster",		false);
	RegisterHam(Ham_Item_AddToPlayer,	WEAPON_REFERANCE, 		"HamHook_Item_AddToPlayer",	false);
	RegisterHam(Ham_Item_PostFrame,		WEAPON_REFERANCE, 		"HamHook_Item_PostFrame",	false);
	
	RegisterHam(Ham_Weapon_Reload,		WEAPON_REFERANCE, 		"HamHook_Item_Reload",		false);
	RegisterHam(Ham_Weapon_WeaponIdle,	WEAPON_REFERANCE, 		"HamHook_Item_WeaponIdle",	false);
	RegisterHam(Ham_Weapon_PrimaryAttack,	WEAPON_REFERANCE,	"HamHook_Item_PrimaryAttack",	false);
}
/*
public zp_user_infected_post(iPlayer)
{
	if (pev_valid(iSpriteleft[iPlayer]) && pev_valid(iSpriteright[iPlayer]))
	{
		set_pev(iSpriteleft[iPlayer], pev_fuser1, get_gametime() + 0.0);
		set_pev(iSpriteright[iPlayer], pev_fuser2, get_gametime() + 0.0);
	}
}
*/
public plugin_natives()
{ 
	register_native("gg_set_user_m3bd", "NativeGiveWeapon", true) 
}

public NativeGiveWeapon(iPlayer)
{
	Weapon_Give(iPlayer);
}

public StartRound() RoundEend = false;
public EndRound() RoundEend = true;

//**********************************************
//* Block client weapon.                       *
//**********************************************

public FakeMeta_UpdateClientData_Post(const iPlayer, const iSendWeapons, const CD_Handle)
{
	static iActiveItem;iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, extra_offset_player);
	
	if (!IsValidPev(iActiveItem) || !IsCustomItem(iActiveItem))
	{
		return FMRES_IGNORED;
	}

	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001);
	return FMRES_IGNORED;
}

public FakeMeta_Touch(const iEnt, const iOther)
{
	if(!pev_valid(iEnt))
	{
		return FMRES_IGNORED;
	}
	
	static Classname[32];pev(iEnt, pev_classname, Classname, sizeof(Classname));
	static Float:Origin[3];pev(iEnt, pev_origin, Origin);
	static iAttacker; iAttacker = pev(iEnt, pev_owner);
	static pevVictim; pevVictim = -1;
	static iEntity;
	static iszAllocStringCached2;
	
	if (!equal(Classname, BALL_CLASSNAME))
	{
		return FMRES_IGNORED;
	}

	if (engfunc(EngFunc_PointContents, Origin) == CONTENTS_SKY || engfunc(EngFunc_PointContents, Origin) == CONTENTS_WATER)
	{
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
		return FMRES_SUPERCEDE;
	}
	
	if (!is_user_connected(iAttacker))
	{
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
		return FMRES_IGNORED;
	}
	
	if (iszAllocStringCached2 || (iszAllocStringCached2 = engfunc(EngFunc_AllocString, "info_target")))
	{
		iEntity = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached2);
	}
		
	if (pev_valid(iEntity))
	{	
		SET_MODEL(iEntity,MODEL_DRAGON)
		SET_ORIGIN(iEntity,Origin)
	
		set_pev(iEntity, pev_classname, DRAGON_CLASSNAME);
		set_pev(iEntity, pev_movetype, MOVETYPE_FLY);
		set_pev(iEntity, pev_solid, SOLID_NOT);
		set_pev(iEntity, pev_owner, iAttacker);
		set_pev(iEntity, pev_framerate, 0.9);
		set_pev(iEntity, pev_sequence, 0);
		set_pev(iEntity, pev_animtime, get_gametime());
		set_pev(iEntity, pev_fuser2, get_gametime() + 3.4);
		set_pev(iEntity, pev_nextthink, get_gametime() + 1.0);
		Sprite_SetTransparency(iEntity, kRenderTransAdd, Float:{255.255,255.0,255.0}, 200.0);
	}

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0);
	write_byte(TE_EXPLOSION);
	WRITE_COORD(Origin[0]); 
	WRITE_COORD(Origin[1]);
	WRITE_COORD(Origin[2] + 10.0);
	write_short(iBlood[2]);
	write_byte(20);
	write_byte(15);
	write_byte(TE_EXPLFLAG_NOSOUND);
	message_end();
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0);
	write_byte(TE_SMOKE)
	WRITE_COORD(Origin[0]); 
	WRITE_COORD(Origin[1]); 
	WRITE_COORD(Origin[2] - 20.0); 
	write_short(iBlood[3]);
	write_byte(30);
	write_byte(5);
	message_end();
	
	engfunc(EngFunc_EmitSound, iEnt, CHAN_VOICE, SOUND_DRAGON, 0.9, ATTN_NORM, 0, PITCH_NORM);
	engfunc(EngFunc_EmitSound, iEnt, CHAN_ITEM, SOUND_EXPLODE, 0.9, ATTN_NORM, 0, PITCH_NORM);
			
	while((pevVictim = engfunc(EngFunc_FindEntityInSphere, pevVictim, Origin, WEAPON_BALL_RADIUS_EXP)) != 0 )
	{
		if (!is_user_alive(pevVictim))continue;
		if (cs_get_user_team(pevVictim) != CS_TEAM_T)continue;	
		if (RoundEend)continue;
		
		static Float:vOrigin[3];pev(pevVictim, pev_origin, vOrigin);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(TE_BLOODSPRITE)
		WRITE_COORD(vOrigin[0])
		WRITE_COORD(vOrigin[1])
		WRITE_COORD(vOrigin[2])
		write_short(iBlood[0])
		write_short(iBlood[1])
		write_byte(76)
		write_byte(18)
		message_end()
		
		set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.02, 0.05);
		show_hudmessage(iAttacker, " \     /^n^n/     \");
		
		ExecuteHamB(Ham_TakeDamage, pevVictim, iEnt, iAttacker, WEAPON_DAMAGE_BALL_EXP, DMG_SONIC);
	}
	
	set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
	
	return FMRES_IGNORED;
}

public FakeMeta_Think(const iSprite)
{
	if (!pev_valid(iSprite))
	{
		return FMRES_IGNORED;
	}
	
	static Classname[32];pev(iSprite, pev_classname, Classname, sizeof(Classname));

	static iAttacker; iAttacker = pev(iSprite, pev_owner);
	
	if (equal(Classname,  DRAGON_CLASSNAME))
	{
		static Float:Origin[3];pev(iSprite, pev_origin, Origin);
		static Float:iTime;pev(iSprite, pev_fuser2, iTime);
		static iVictim;iVictim = -1
		
		if (iTime <= get_gametime())
		{
			engfunc(EngFunc_RemoveEntity, iSprite);
			return FMRES_SUPERCEDE;
		}
		
		while((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, Origin, WEAPON_RADIUS_DRAGON_ATTACK)) != 0)
		{
			static Float:iVelo[3];pev(iVictim, pev_velocity, iVelo);
			
			if (!is_user_alive(iVictim))continue;
			if (cs_get_user_team(iVictim) != CS_TEAM_T)continue;	
			if (RoundEend)continue;
			
			iVelo[0] = 0.0;
			iVelo[1] = 0.0;
			iVelo[2] = 250.0;
			
			set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.02, 0.05);
			show_hudmessage(iAttacker, " \     /^n^n/     \");
			
			ExecuteHamB(Ham_TakeDamage, iVictim, iSprite, iAttacker, WEAPON_DRAGON_DAMAGE_ATTACK, DMG_SONIC);
			
			set_pdata_float(iVictim, m_flVelocityModifier, 1.0,  extra_offset_player);
			set_pev(iVictim, pev_velocity, iVelo);
		}
	
		set_pev(iSprite, pev_nextthink, get_gametime() + 0.08);
	}
	
	if (equal(Classname, MUZZLE_CLASSNAME_LEFT))
	{	
		static Float:flFrame;
		static Float:iTime;pev(iSprite, pev_fuser1, iTime);
		
		flFrame+=1.0
		
		if (iTime <= get_gametime() || pev(iAttacker, pev_deadflag) == DAMAGE_YES)
		{
			set_pev(iSprite, pev_flags, pev(iSprite, pev_flags) | FL_KILLME);
			return FMRES_SUPERCEDE;
		}
	
		set_pev(iSprite, pev_frame, flFrame);	
		set_pev(iSprite, pev_nextthink, get_gametime() + 0.01);
	}
	
	if (equal(Classname, MUZZLE_CLASSNAME_RIGHT))
	{	
		static Float:flFrame;
		static Float:iTime2;pev(iSprite, pev_fuser2, iTime2);
		
		flFrame+=1.0
		
		if (iTime2 <= get_gametime() || pev(iAttacker, pev_deadflag) == DAMAGE_YES)
		{
			set_pev(iSprite, pev_flags, pev(iSprite, pev_flags) | FL_KILLME);
			return FMRES_SUPERCEDE;
		}
	
		set_pev(iSprite, pev_frame, flFrame);	
		set_pev(iSprite, pev_nextthink, get_gametime() + 0.01);
	}
	
	
	return FMRES_IGNORED;
}

//**********************************************
//* Item (weapon) hooks.                       *
//**********************************************

	#define _call.%0(%1,%2) \
									\
	Weapon_On%0							\
	(								\
		%1, 							\
		%2,							\
									\
		get_pdata_int(%1, m_iClip, extra_offset_weapon),	\
		GetAmmoInventory(%2, PrimaryAmmoIndex(%1)),		\
		get_pdata_int(%1, m_fWeaponState, extra_offset_weapon),	\
		get_pdata_int(%1, m_fInSpecialReload, extra_offset_weapon) \
	) 

public HamHook_Item_Deploy_Post(const iItem)
{
	new iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.Deploy(iItem, iPlayer);
	return HAM_IGNORED;
}

public HamHook_Item_Holster(const iItem)
{
	new iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	set_pev(iPlayer, pev_viewmodel, 0);
	set_pev(iPlayer, pev_weaponmodel, 0);
	
	_call.Holster(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_WeaponIdle(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}

	_call.Idle(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_Reload(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.Reload(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_PrimaryAttack(const iItem)
{
	static iPlayer; 
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	_call.PrimaryAttack(iItem, iPlayer);
	return HAM_SUPERCEDE;
}

public HamHook_Item_PostFrame(const iItem)
{
	static iPlayer;
	
	if (!CheckItem(iItem, iPlayer))
	{
		return HAM_IGNORED;
	}
	
	if (get_pdata_float(iItem, m_flNextPrimaryAttack, extra_offset_weapon) <= 0.0 && get_pdata_int(iItem, m_fInSpecialReload, extra_offset_weapon) <= 0)
	{
		_call.SecondaryAttack(iItem, iPlayer);
	}
	
	return HAM_IGNORED;
}	

//**********************************************
//* Fire Bullets.                              *
//**********************************************

CallOrigFireBullets3(const iItem, const iPlayer)
{
	static FakeMetaTraceLine;FakeMetaTraceLine=register_forward(FM_TraceLine,"FakeMeta_TraceLine",true)
	state FireBullets: Enabled;
	static Float: vecPuncheAngle[3];pev(iPlayer, pev_punchangle, vecPuncheAngle);
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, iItem);
	set_pev(iPlayer, pev_punchangle, vecPuncheAngle);
	
	state FireBullets: Disabled;
	unregister_forward(FM_TraceLine,FakeMetaTraceLine,true)
}

public FakeMeta_PlaybackEvent() <FireBullets: Enabled>
{
	return FMRES_SUPERCEDE;
}

public FakeMeta_TraceLine(Float:vecStart[3], Float:vecEnd[3], iFlag, iIgnore, iTrase)
{
	if (iFlag & IGNORE_MONSTERS)
	{
		return FMRES_IGNORED;
	}
	
	static Float:vecfEnd[3],iHit,iDecal,glassdecal;
	
	if(!glassdecal)
	{	
		glassdecal=engfunc( EngFunc_DecalIndex, "{bproof1" )
	}
	
	iHit=get_tr2(iTrase,TR_pHit)
	
	if(iHit>0 && pev_valid(iHit))
		if(pev(iHit,pev_solid)!=SOLID_BSP)return FMRES_IGNORED
		else if(pev(iHit,pev_rendermode)!=0)iDecal=glassdecal
		else iDecal=random_num(41,45)
	else iDecal=random_num(41,45)

	get_tr2(iTrase, TR_vecEndPos, vecfEnd)
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecfEnd, 0)
	write_byte(TE_GUNSHOTDECAL)
	WRITE_COORD(vecfEnd[0])
	WRITE_COORD(vecfEnd[1])
	WRITE_COORD(vecfEnd[2])
	write_short(iHit > 0 ? iHit : 0)
	write_byte(iDecal)
	message_end()

	return FMRES_IGNORED
}

public HamHook_Entity_TraceAttack(const iEntity, const iAttacker, const Float: flDamage) <FireBullets: Enabled>
{
	static iItem;iItem = get_pdata_cbase(iAttacker, m_pActiveItem, extra_offset_player);

	if (!BitCheck(g_bitIsConnected, iAttacker) || !IsValidPev(iAttacker))
	{
		return;
	}
	
	if (!IsValidPev(iItem))
	{
		return;
	}
	/*
	if (get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon) == 31)
	{
		MuzzleFlash_Left(iAttacker, WEAPON_MUZZLE, 0.08, 20.0);
		MuzzleFlash_Right(iAttacker, WEAPON_MUZZLE_B, 0.08, 20.0);
		Update_HUD(iItem, iAttacker, 0);
		set_pdata_int(iItem, m_fWeaponState, 1, extra_offset_weapon);
		Update_HUD(iItem, iAttacker, 1);
	}
	
	if (is_user_alive(iEntity) && get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon) < 32 && cs_get_user_team(iEntity) == CS_TEAM_T)
	{
		set_pdata_int(iItem, m_fInSuperBullets, (get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon)+1), extra_offset_weapon);
	}
	*/
	set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.2, 0.05);
	show_hudmessage(iAttacker, " \     /^n^n/     \");
	
	SetHamParamFloat(3, flDamage * WEAPON_MULTIPLIER_DAMAGE);
}

public HamHook_Entity_Killed(const iEntity, const iAttacker)
{
	if(!iAttacker || !is_user_connected(iAttacker))
		return;
		
	static iItem;iItem = get_pdata_cbase(iAttacker, m_pActiveItem, extra_offset_player);

	if (!BitCheck(g_bitIsConnected, iAttacker) || !IsValidPev(iAttacker))
	{
		return;
	}
	
	if (!IsValidPev(iItem))
	{
		return;
	}
	
	if (get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon) == 31)
	{
		MuzzleFlash_Left(iAttacker, WEAPON_MUZZLE, 0.08, 20.0);
		MuzzleFlash_Right(iAttacker, WEAPON_MUZZLE_B, 0.08, 20.0);
		Update_HUD(iItem, iAttacker, 0);
		set_pdata_int(iItem, m_fWeaponState, 1, extra_offset_weapon);
		Update_HUD(iItem, iAttacker, 1);
	}
	
	if (get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon) < 32 && cs_get_user_team(iEntity) == CS_TEAM_T)
	{
		if(get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon)+8 > 31)
			set_pdata_int(iItem, m_fInSuperBullets, 31, extra_offset_weapon);
		else set_pdata_int(iItem, m_fInSuperBullets, (get_pdata_int(iItem, m_fInSuperBullets, extra_offset_weapon)+11), extra_offset_weapon);
	}
}

public MsgHook_Death()			</* Empty statement */>		{ /* Fallback */ }
public MsgHook_Death()			<FireBullets: Disabled>		{ /* Do notning */ }

public FakeMeta_PlaybackEvent() 	</* Empty statement */>		{ return FMRES_IGNORED; }
public FakeMeta_PlaybackEvent() 	<FireBullets: Disabled>		{ return FMRES_IGNORED; }

public HamHook_Entity_TraceAttack() 	</* Empty statement */>		{ /* Fallback */ }
public HamHook_Entity_TraceAttack() 	<FireBullets: Disabled>		{ /* Do notning */ }


Weapon_Create(const Float: vecOrigin[3] = {0.0, 0.0, 0.0}, const Float: vecAngles[3] = {0.0, 0.0, 0.0})
{
	new iWeapon;

	static iszAllocStringCached;
	if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, WEAPON_REFERANCE)))
	{
		iWeapon = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
	}
	
	if (!IsValidPev(iWeapon))
	{
		return FM_NULLENT;
	}
	
	MDLL_Spawn(iWeapon);
	SET_ORIGIN(iWeapon, vecOrigin);
	
	set_pdata_int(iWeapon, m_iClip, WEAPON_MAX_CLIP, extra_offset_weapon);
	set_pdata_int(iWeapon, m_fWeaponState, 0, extra_offset_weapon);
	set_pdata_int(iWeapon, m_fInSuperBullets, 0, extra_offset_weapon);

	set_pev(iWeapon, pev_impulse, WEAPON_KEY);
	set_pev(iWeapon, pev_angles, vecAngles);
	
	Weapon_OnSpawn(iWeapon);
	
	return iWeapon;
}

Weapon_Give(const iPlayer)
{
	if (!IsValidPev(iPlayer))
	{
		return FM_NULLENT;
	}
	
	new iWeapon, Float: vecOrigin[3];
	pev(iPlayer, pev_origin, vecOrigin);
	
	if ((iWeapon = Weapon_Create(vecOrigin)) != FM_NULLENT)
	{
		//Player_DropWeapons(iPlayer, ExecuteHamB(Ham_Item_ItemSlot, iWeapon));
		set_pev(iWeapon, pev_spawnflags, pev(iWeapon, pev_spawnflags) | SF_NORESPAWN);
		MDLL_Touch(iWeapon, iPlayer);
		SetAmmoInventory(iPlayer, PrimaryAmmoIndex(iWeapon), WEAPON_DEFAULT_AMMO);
		
		return iWeapon;
	}
	
	return FM_NULLENT;
}
/*
Player_DropWeapons(const iPlayer, const iSlot)
{
	new szWeaponName[32], iItem = get_pdata_cbase(iPlayer, m_rgpPlayerItems_CBasePlayer + iSlot, extra_offset_player);

	while (IsValidPev(iItem))
	{
		pev(iItem, pev_classname, szWeaponName, charsmax(szWeaponName));
		engclient_cmd(iPlayer, "drop", szWeaponName);

		iItem = get_pdata_cbase(iItem, m_pNext, extra_offset_weapon);
	}
}
*/
Weapon_SendAnim(const iPlayer, const iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim);

	MESSAGE_BEGIN(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, iPlayer);
	WRITE_BYTE(iAnim);
	WRITE_BYTE(0);
	MESSAGE_END();
}

stock Weapon_DefaultDeploy(const iPlayer, const szViewModel[], const szWeaponModel[], const iAnim, const szAnimExt[])
{
	set_pev(iPlayer, pev_viewmodel2, szViewModel);
	set_pev(iPlayer, pev_weaponmodel2, szWeaponModel);
	set_pev(iPlayer, pev_fov, 90.0);
	
	set_pdata_int(iPlayer, m_iFOV, 90, extra_offset_player);
	set_pdata_int(iPlayer, m_fResumeZoom, 0, extra_offset_player);
	set_pdata_int(iPlayer, m_iLastZoom, 90, extra_offset_player);
	
	set_pdata_string(iPlayer, m_szAnimExtention * 4, szAnimExt, -1, extra_offset_player * 4);
	
	Weapon_SendAnim(iPlayer, iAnim);
}

stock Punchangle(iPlayer, Float:iVecx = 0.0, Float:iVecy = 0.0, Float:iVecz = 0.0)
{
	static Float:iVec[3];pev(iPlayer, pev_punchangle,iVec);
	iVec[0] = iVecx;iVec[1] = iVecy;iVec[2] = iVecz
	set_pev(iPlayer, pev_punchangle, iVec);
}

stock Get_Position(id,Float:forw, Float:right, Float:up, Float:vStart[]) 
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3];
	
	pev(id, pev_origin, vOrigin);
	pev(id, pev_view_ofs, vUp);
	
	xs_vec_add(vOrigin, vUp, vOrigin);
	
	pev(id, pev_v_angle, vAngle);
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward);
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight);
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp);
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up;
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up;
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up;
}

stock Get_Speed_Vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
}

#define BitSet(%0,%1) (%0 |= (1 << (%1 - 1)))
#define BitClear(%0,%1) (%0 &= ~(1 << (%1 - 1)))
#define BitCheck(%0,%1) (%0 & (1 << (%1 - 1)))

public client_putinserver(id)
{
	BitSet(g_bitIsConnected, id);
}

public client_disconnected(id)
{
	BitClear(g_bitIsConnected, id);
}

bool: CheckItem(const iItem, &iPlayer)
{
	if (!IsValidPev(iItem) || !IsCustomItem(iItem))
	{
		return false;
	}
	
	iPlayer = get_pdata_cbase(iItem, m_pPlayer, extra_offset_weapon);
	
	if (!IsValidPev(iPlayer) || !BitCheck(g_bitIsConnected, iPlayer))
	{
		return false;
	}
	
	return true;
}

//**********************************************
//* Weapon list update.                        *
//**********************************************
#if defined WPNLIST
public Cmd_WeaponSelect(const iPlayer)
{
	engclient_cmd(iPlayer, WEAPON_REFERANCE);
	return PLUGIN_HANDLED;
}
#endif
public HamHook_Item_AddToPlayer(const iItem, const iPlayer)
{
	switch(pev(iItem, pev_impulse))
	{
		case 0: MsgHook_WeaponList(MSGID_WEAPONLIST, iItem, iPlayer);
		case WEAPON_KEY: 
		{
			#if defined WPNLIST
			MsgHook_WeaponList(MSGID_WEAPONLIST, iItem, iPlayer);
			#endif
			SetAmmoInventory(iPlayer, PrimaryAmmoIndex(iItem), pev(iItem, pev_iuser2));
		}
	}
	
	return HAM_IGNORED;
}

public MsgHook_WeaponList(const iMsgID, const iMsgDest, const iMsgEntity)
{
	static arrWeaponListData[8];
	
	if (!iMsgEntity)
	{
		new szWeaponName[32];
		get_msg_arg_string(1, szWeaponName, charsmax(szWeaponName));
		
		if (!strcmp(szWeaponName, WEAPON_REFERANCE))
		{
			for (new i, a = sizeof arrWeaponListData; i < a; i++)
			{
				arrWeaponListData[i] = get_msg_arg_int(i + 2);
			}
		}
	}
	else
	{
		if (!IsCustomItem(iMsgDest) && pev(iMsgDest, pev_impulse))
		{
			return;
		}
		
		MESSAGE_BEGIN(MSG_ONE, iMsgID, {0.0, 0.0, 0.0}, iMsgEntity);
		WRITE_STRING(IsCustomItem(iMsgDest) ? WEAPON_NAME : WEAPON_REFERANCE);
		
		for (new i, a = sizeof arrWeaponListData; i < a; i++)
		{
			WRITE_BYTE(arrWeaponListData[i]);
		}
		
		MESSAGE_END();
	}
}

//**********************************************
//* Muzzleflash stuff.                *
//**********************************************

stock Sprite_SetTransparency(const iSprite, const iRendermode, const Float: vecColor[3], const Float: flAmt, const iFx = kRenderFxNone)
{
	set_pev(iSprite, pev_rendermode, iRendermode);
	set_pev(iSprite, pev_rendercolor, vecColor);
	set_pev(iSprite, pev_renderamt, flAmt);
	set_pev(iSprite, pev_renderfx, iFx);
}

stock MuzzleFlash_Right(const iPlayer, const szMuzzleSprite[], const Float: flScale, const Float: flFramerate)
{
	if (global_get(glb_maxEntities) - engfunc(EngFunc_NumberOfEntities) < 100)
	{
		return FM_NULLENT;
	}
	
	static iszAllocStringCached;
	if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "env_sprite")))
	{
		iSpriteright[iPlayer] = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
	}
	
	if (!IsValidPev(iSpriteright[iPlayer]))
	{
		
		return FM_NULLENT;
	}
	
	set_pev(iSpriteright[iPlayer], pev_model, szMuzzleSprite);
	
	set_pev(iSpriteright[iPlayer], pev_classname, MUZZLE_CLASSNAME_RIGHT);
	set_pev(iSpriteright[iPlayer], pev_owner, iPlayer);
	set_pev(iSpriteright[iPlayer], pev_aiment, iPlayer);
	set_pev(iSpriteright[iPlayer], pev_body, 4);
	set_pev(iSpriteright[iPlayer], pev_frame, 0.0);
	
	Sprite_SetTransparency(iSpriteright[iPlayer], kRenderTransAdd, Float:{0.0,0.0,0.0}, 255.0);
	
	set_pev(iSpriteright[iPlayer], pev_framerate, flFramerate);
	set_pev(iSpriteright[iPlayer], pev_scale, flScale);
	
	set_pev(iSpriteright[iPlayer], pev_fuser2, get_gametime() + 40.0);
	set_pev(iSpriteright[iPlayer], pev_nextthink, get_gametime() + 0.01);
	
	MDLL_Spawn(iSpriteright[iPlayer]);

	return iSpriteright[iPlayer];
}

stock MuzzleFlash_Left(const iPlayer, const szMuzzleSprite[], const Float: flScale, const Float: flFramerate)
{
	if (global_get(glb_maxEntities) - engfunc(EngFunc_NumberOfEntities) < 100)
	{
		return FM_NULLENT;
	}
	
	static iszAllocStringCached;
	if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "env_sprite")))
	{
		iSpriteleft[iPlayer] = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
	}
	
	if (!IsValidPev(iSpriteleft[iPlayer]))
	{
		
		return FM_NULLENT;
	}
	
	set_pev(iSpriteleft[iPlayer], pev_model, szMuzzleSprite);
	
	set_pev(iSpriteleft[iPlayer], pev_classname, MUZZLE_CLASSNAME_LEFT);
	set_pev(iSpriteleft[iPlayer], pev_owner, iPlayer);
	set_pev(iSpriteleft[iPlayer], pev_aiment, iPlayer);
	set_pev(iSpriteleft[iPlayer], pev_body, 3);
	set_pev(iSpriteleft[iPlayer], pev_frame, 0.0);
	
	Sprite_SetTransparency(iSpriteleft[iPlayer], kRenderTransAdd, Float:{0.0,0.0,0.0}, 255.0);
	
	set_pev(iSpriteleft[iPlayer], pev_framerate, flFramerate);
	set_pev(iSpriteleft[iPlayer], pev_scale, flScale);
	
	set_pev(iSpriteleft[iPlayer], pev_fuser1, get_gametime() + 40.0);
	set_pev(iSpriteleft[iPlayer], pev_nextthink, get_gametime() + 0.01);
	
	MDLL_Spawn(iSpriteleft[iPlayer]);

	return iSpriteleft[iPlayer];
}

//**********************************************
//* Weaponbox world model.                     *
//**********************************************

public HamHook_Weaponbox_Spawn_Post(const iWeaponBox)
{
	if (IsValidPev(iWeaponBox))
	{
		state (IsValidPev(pev(iWeaponBox, pev_owner))) WeaponBox: Enabled;
	}
	
	return HAM_IGNORED;
}

public FakeMeta_SetModel(const iEntity) <WeaponBox: Enabled>
{
	state WeaponBox: Disabled;
	
	if (!IsValidPev(iEntity))
	{
		return FMRES_IGNORED;
	}
	
	#define MAX_ITEM_TYPES	6
	
	for (new i, iItem; i < MAX_ITEM_TYPES; i++)
	{
		iItem = get_pdata_cbase(iEntity, m_rgpPlayerItems_CWeaponBox + i, extra_offset_weapon);
		
		if (IsValidPev(iItem) && IsCustomItem(iItem))
		{
			SET_MODEL(iEntity, MODEL_WORLD);	
			set_pev(iItem, pev_iuser2, GetAmmoInventory(pev(iEntity,pev_owner), PrimaryAmmoIndex(iItem)))
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public FakeMeta_SetModel()	</* Empty statement */>	{ /*  Fallback  */ return FMRES_IGNORED; }
public FakeMeta_SetModel() 	< WeaponBox: Disabled >	{ /* Do nothing */ return FMRES_IGNORED; }

//**********************************************
//* Ammo Inventory.                            *
//**********************************************

PrimaryAmmoIndex(const iItem)
{
	return get_pdata_int(iItem, m_iPrimaryAmmoType, extra_offset_weapon);
}

GetAmmoInventory(const iPlayer, const iAmmoIndex)
{
	if (iAmmoIndex == -1)
	{
		return -1;
	}

	return get_pdata_int(iPlayer, m_rgAmmo_CBasePlayer + iAmmoIndex, extra_offset_player);
}

SetAmmoInventory(const iPlayer, const iAmmoIndex, const iAmount)
{
	if (iAmmoIndex == -1)
	{
		return 0;
	}

	set_pdata_int(iPlayer, m_rgAmmo_CBasePlayer + iAmmoIndex, iAmount, extra_offset_player);
	return 1;
}
//vk.com/l.shvendik0
stock Player_SetAnimation(const iPlayer, const szAnim[])
{
	   if(!is_user_alive(iPlayer))return;
		
	   #define ACT_RANGE_ATTACK1   28
	   
	   // Linux extra offsets
	   #define extra_offset_animating   4
	   
	   // CBaseAnimating
	   #define m_flFrameRate      36
	   #define m_flGroundSpeed      37
	   #define m_flLastEventCheck   38
	   #define m_fSequenceFinished   39
	   #define m_fSequenceLoops   40
	   
	   // CBaseMonster
	   #define m_Activity      73
	   #define m_IdealActivity      74
	   
	   // CBasePlayer
	   #define m_flLastAttackTime   220
	   
	   new iAnimDesired, Float: flFrameRate, Float: flGroundSpeed, bool: bLoops;
	      
	   if ((iAnimDesired = lookup_sequence(iPlayer, szAnim, flFrameRate, bLoops, flGroundSpeed)) == -1)
	   {
	      iAnimDesired = 0;
	   }
   
	   new Float: flGametime = get_gametime();
	
	   set_pev(iPlayer, pev_frame, 0.0);
	   set_pev(iPlayer, pev_framerate, 1.0);
	   set_pev(iPlayer, pev_animtime, flGametime );
	   set_pev(iPlayer, pev_sequence, iAnimDesired);
	   
	   set_pdata_int(iPlayer, m_fSequenceLoops, bLoops, extra_offset_animating);
	   set_pdata_int(iPlayer, m_fSequenceFinished, 0, extra_offset_animating);
	   
	   set_pdata_float(iPlayer, m_flFrameRate, flFrameRate, extra_offset_animating);
	   set_pdata_float(iPlayer, m_flGroundSpeed, flGroundSpeed, extra_offset_animating);
	   set_pdata_float(iPlayer, m_flLastEventCheck, flGametime , extra_offset_animating);
	   
	   set_pdata_int(iPlayer, m_Activity, ACT_RANGE_ATTACK1, extra_offset_player);
	   set_pdata_int(iPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, extra_offset_player);   
	   set_pdata_float(iPlayer, m_flLastAttackTime, flGametime , extra_offset_player);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
