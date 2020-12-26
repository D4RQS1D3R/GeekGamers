#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <fakemeta_util>
#include <amxmisc>

new g_mode[33]
#define BLOOD_SM_NUM 8
#define ENG_NULLENT		-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define DINFINITY_WEAPONKEY	901
#define MAX_PLAYERS  			  32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4
#define BLOOD_STREAM_RED	70
#define WEAP_LINUX_XTRA_OFF			4
#define m_fKnown				44
#define m_flNextPrimaryAttack 			46
#define m_flTimeWeaponIdle			48
#define m_iClip		51
#define m_fInReload				54
#define PLAYER_LINUX_XTRA_OFF			5
#define m_flNextAttack				83

#define DINFINITY_RELOAD_TIME 4.0
#define DINFINITY_DRAW_TIME 1.2

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_USP)|(1<<CSW_DEAGLE)|(1<<CSW_GLOCK18)|(1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_sg550", "weapon_fiveseven", "weapon_ump45", "weapon_elite",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_elite", "weapon_knife", "weapon_p90" }

new const Fire_Sounds[][] = { "weapons/infi-1.wav" }
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }
new DINFINITY_V_MODEL[64] = "models/[GeekGamers]/Secondary/v_dual_infinity.mdl"
new DINFINITY_V_MODEL2[64] = "models/[GeekGamers]/Secondary/v_dual_infinity_2.mdl"
new DINFINITY_P_MODEL[64] = "models/[GeekGamers]/Secondary/p_dual_infinity.mdl"
new DINFINITY_W_MODEL[64] = "models/[GeekGamers]/Secondary/w_dual_infinity.mdl"

new Infinity_Generic[][] = {
	"sprites/gg_weapon_infinity.txt",
	"sprites/[GeekGamers]/Weapons/Infinity.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

new cvar_dmg_dinfinity/*, g_itemid_dinfinity*/, cvar_clip_dinfinity, cvar_dinfinity_ammo , cvar_recoil2_vertical , cvar_recoil2_horizontal , cvar_recoil1_vertical , cvar_recoil1_horizontal
new g_MaxPlayers, g_orig_event_dinfinity, g_clip_ammo[33] , g_attack2[33]
new m_iBlood[2] , oldweap[33] , g_DINFINITY_TmpClip[33] , g_has_dinfinity[33]

public plugin_init()
{
	register_plugin("[ZP] Weapon: DInfinity", "1.0", "--")

	register_clcmd("gg_weapon_infinity", "Hook_Infinity")

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")

	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)

	RegisterHam(Ham_Item_AddToPlayer, "weapon_elite", "fw_DINFINITY_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_DINFINITY_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_elite", "DInfinity_ItemPostFrame");
	RegisterHam(Ham_Weapon_Reload, "weapon_elite", "DInfinity_Reload");
	RegisterHam(Ham_Weapon_Reload, "weapon_elite", "DInfinity_Reload_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)

	cvar_dmg_dinfinity = register_cvar("zp_dinfinity_bonus_dmg", "0")
	cvar_clip_dinfinity = register_cvar("zp_dinfinity_clip", "20")
	cvar_dinfinity_ammo = register_cvar("zp_dinfinity_ammo", "90")
	cvar_recoil2_vertical = register_cvar("zp_dinfinity_verticalrecoilat2", "3")
	cvar_recoil2_horizontal = register_cvar("zp_dinfinity_horizontalrecoilat2", "300")
	cvar_recoil1_vertical = register_cvar("zp_dinfinity_verticalrecoilat1", "200")
	cvar_recoil1_horizontal = register_cvar("zp_dinfinity_horizontalrecoilat1", "50")

	//g_itemid_dinfinity = zp_register_extra_item("[\rPistols \wDinfinity\r]", 10, ZP_TEAM_HUMAN)
	g_MaxPlayers = get_maxplayers()

	set_task (0.1,"fire_id",_,_,_,"b");
}

public plugin_natives()
{
	register_native("gg_set_user_dualinfinity", "give_dinfinity", 1)
}

public plugin_precache()
{
	precache_model(DINFINITY_V_MODEL)
	precache_model(DINFINITY_P_MODEL)
	precache_model(DINFINITY_V_MODEL2)
	precache_model(DINFINITY_W_MODEL)

	precache_sound(Fire_Sounds[0])
	precache_sound("weapons/infi_clipin.wav")
	precache_sound("weapons/infi_clipout.wav")
	precache_sound("weapons/infi_clipon.wav")
	precache_sound("weapons/infi_draw.wav")

	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	precache_model("sprites/640hud5.spr")
	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)

	for(new i = 0; i < sizeof(Infinity_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, Infinity_Generic[i]);
}

public PlayerSpawn(id)
{
	g_has_dinfinity[id] = false;
}

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/elite_right.sc", name) || equal("events/elite_left.sc", name) )
	{
		g_orig_event_dinfinity = get_orig_retval()
		return FMRES_HANDLED
	}
	
	return FMRES_IGNORED
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, "models/w_elite.mdl"))
	{
		static iStoredSVDID
		
		iStoredSVDID = find_ent_by_owner(ENG_NULLENT, "weapon_elite", entity)
	
		if(!is_valid_ent(iStoredSVDID))
			return FMRES_IGNORED;
	
		if(g_has_dinfinity[iOwner])
		{
			entity_set_int(iStoredSVDID, EV_INT_WEAPONKEY, DINFINITY_WEAPONKEY)
			g_has_dinfinity[iOwner] = false
			
			entity_set_model(entity, DINFINITY_W_MODEL)
			
			return FMRES_SUPERCEDE;
		}
	}
	
	
	return FMRES_IGNORED;
}

public give_dinfinity(id)
{
	new iWep2 = give_item(id, "weapon_elite")
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_dinfinity))
		cs_set_user_bpammo (id, CSW_ELITE, get_pcvar_num(cvar_dinfinity_ammo))
	}
	if(get_user_weapon(id) == CSW_ELITE)
	{
		replace_weapon_models(id, CSW_ELITE)
		UTIL_PlayWeaponAnimation(id, 16)
		set_pdata_float(id, m_flNextAttack, DINFINITY_DRAW_TIME , PLAYER_LINUX_XTRA_OFF)	
	}

	g_has_dinfinity[id] = true;
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED

	if(!g_has_dinfinity[id])
		return PLUGIN_HANDLED	

	new szClip, szAmmo
	new szWeapID = get_user_weapon(id, szClip, szAmmo)

	if(szWeapID != CSW_ELITE)
		return PLUGIN_HANDLED	

	if(szClip <= 0)
		return PLUGIN_HANDLED	

	if(!(get_uc(uc_handle, UC_Buttons) & IN_ATTACK2))
		g_attack2[id] = 0
		
	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2))
		g_attack2[id] = 1


	return PLUGIN_HANDLED
}
public fire_id()
{
	for(new id;id <= 32;id++)
	{

		if(!is_user_alive(id))
			continue;
	
		new szClip, szAmmo
		new szWeapID = get_user_weapon(id, szClip, szAmmo)

		if(szWeapID != CSW_ELITE)
			continue;

		if(!g_attack2[id])
			continue;

		if(szClip <= 0)
			continue;

		g_mode[id] = 1
		replace_weapon_models(id,CSW_ELITE)
	
		if(szClip > 1)
		{
			UTIL_PlayWeaponAnimation(id, random_num(2,12))
			make_blood_and_bulletholes(id)
			new ak = find_ent_by_owner ( -1, "weapon_elite", id )
			set_pdata_int ( ak, 51, szClip - 1, 4 )
			make_punchangle(id)
		}else if(szClip == 1)
		{
			new num
			num = random_num(1,2)
			if(num == 1)  UTIL_PlayWeaponAnimation(id, 7)
			if(num == 2)  UTIL_PlayWeaponAnimation(id, 13)
			make_blood_and_bulletholes(id)
			new ak = find_ent_by_owner ( -1, "weapon_elite", id )
			set_pdata_int ( ak, 51, szClip - 1, 4 )
			make_punchangle(id)
		}else 	if(szClip == 0 ) {
			if(szAmmo > 0) UTIL_PlayWeaponAnimation(id, 14)
		}
	}
}
public fw_DINFINITY_AddToPlayer(DINFINITY, id)
{
	if(!is_valid_ent(DINFINITY) || !is_user_connected(id))
		return HAM_IGNORED;
	
	if(entity_get_int(DINFINITY, EV_INT_WEAPONKEY) == DINFINITY_WEAPONKEY)
	{
		g_has_dinfinity[id] = true
		
		entity_set_int(DINFINITY, EV_INT_WEAPONKEY, 0)
		
		WeaponList(id)
		
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	replace_weapon_models(owner, weaponid)
}

replace_weapon_models(id, weaponid)
{
	if(!is_user_alive(id))
		return;

	if(!g_has_dinfinity[id])
		return;

	if(weaponid == CSW_ELITE)
	{
		if(g_mode[id] == 0)
		{
			set_pev(id, pev_viewmodel2, DINFINITY_V_MODEL)
			set_pev(id, pev_weaponmodel2, DINFINITY_P_MODEL)
		}else{
			set_pev(id, pev_viewmodel2, DINFINITY_V_MODEL2)
			set_pev(id, pev_weaponmodel2, DINFINITY_P_MODEL)
		}
		if(oldweap[id] != CSW_ELITE) 
		{
			UTIL_PlayWeaponAnimation(id, 16)
			set_pdata_float(id, m_flNextAttack, DINFINITY_DRAW_TIME , PLAYER_LINUX_XTRA_OFF)	
		}
	}
	if(weaponid != CSW_ELITE) g_mode[id] = 0
	oldweap[id] = weaponid
}

public make_punchangle(id)
{
	if(!is_user_alive(id))
		return;

	if(!g_has_dinfinity[id])
		return;

	if(g_mode[id] == 0)
	{
		static Float:punchAngle[3];
		punchAngle[0] = float(random_num(-1 * get_pcvar_num(cvar_recoil1_vertical), get_pcvar_num(cvar_recoil1_vertical))) / 100.0;
		punchAngle[1] = float(random_num(-1 * get_pcvar_num(cvar_recoil1_horizontal), get_pcvar_num(cvar_recoil1_horizontal))) / 100.0;
		punchAngle[2] = 0.0;
		set_pev(id, pev_punchangle, punchAngle);
	}else{
		static Float:punchAngle[3];
		punchAngle[0] = float(random_num(-1 * get_pcvar_num(cvar_recoil2_vertical), get_pcvar_num(cvar_recoil2_vertical))) / 100.0;
		punchAngle[1] = float(random_num(-1 * get_pcvar_num(cvar_recoil2_horizontal), get_pcvar_num(cvar_recoil2_horizontal))) / 100.0;
		punchAngle[2] = 0.0;
		set_pev(id, pev_punchangle, punchAngle);
	}
}
public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
        if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_ELITE) || !g_has_dinfinity[Player])
        return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public fw_DINFINITY_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)

	if (!g_has_dinfinity[Player])
		return HAM_IGNORED;

	if (!is_user_alive(Player))
		return HAM_IGNORED;

	new szClip, szAmmo
	new szWeapID = get_user_weapon(Player, szClip, szAmmo)
		
	if(szClip <= 0)
		return HAM_IGNORED;

	new Float:flNextAttack = get_pdata_float(Player, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

	if(flNextAttack > 0.0)
		return PLUGIN_HANDLED

	if(get_user_weapon(Player) == CSW_ELITE)
	{
		g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)

		if(szWeapID == CSW_ELITE)
		{
			remove_task(Player)
			g_mode[Player] = 0
			replace_weapon_models(Player,CSW_ELITE)
			new num
			num = random_num(1,2)
			if(num == 1)  UTIL_PlayWeaponAnimation(Player, random_num(2,6))
			if(num == 2)  UTIL_PlayWeaponAnimation(Player,  random_num(8,12))

			make_punchangle(Player)
			make_blood_and_bulletholes(Player)
			
			set_pdata_float(Player, m_flNextAttack, 0.2, PLAYER_LINUX_XTRA_OFF)
			new ak = find_ent_by_owner ( -1, "weapon_elite", Player )
			set_pdata_int ( ak, 51, szClip - 1, 4 )
		}	
	}
	return HAM_SUPERCEDE;
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_dinfinity))
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
		return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_ELITE)
		{
			if(g_has_dinfinity[attacker])
				SetHamParamFloat(4, damage + get_pcvar_float(cvar_dmg_dinfinity))
		}
	}
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE

	set_task(1.0,"zero_values",iVictim) 
	
	if(equal(szTruncatedWeapon, "elite") && get_user_weapon(iAttacker) == CSW_ELITE)
	{
		if(g_has_dinfinity[iAttacker])
			set_msg_arg_string(4, "elite")
	}
		
	return PLUGIN_CONTINUE
}

public CurrentWeapon(id) replace_weapon_models(id, read_data(2))
public zp_user_infected_post(id)	zero_values(id)
public client_connect(id) zero_values(id)
public client_disconnected(id) zero_values(id)

stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

stock make_blood_and_bulletholes(id)
{
	new aimOrigin[3], target, body
	get_user_origin(id, aimOrigin, 3)
	get_user_aiming(id, target, body)

	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:plrViewAngles[3], Float:VecEnd[3], Float:VecDir[3], Float:PlrOrigin[3];
	pev(id, pev_v_angle, plrViewAngles);

	static Float:VecSrc[3], Float:VecDst[3];
	
	//VecSrc = pev->origin + pev->view_ofs;
	pev(id, pev_origin, PlrOrigin)
	pev(id, pev_view_ofs, VecSrc)
	xs_vec_add(VecSrc, PlrOrigin, VecSrc)

	//VecDst = VecDir * 8192.0;
	angle_vector(plrViewAngles, ANGLEVECTOR_FORWARD, VecDir);
	xs_vec_mul_scalar(VecDir, 8192.0, VecDst);
	xs_vec_add(VecDst, VecSrc, VecDst);
	
	new hTrace = create_tr2()
	engfunc(EngFunc_TraceLine, VecSrc, VecDst, 0, id, hTrace)
	new hitEnt = get_tr2(hTrace, TR_pHit);
	get_tr2(hTrace, TR_vecEndPos, VecEnd);

	if(is_user_alive(target))
	{
	if (pev_valid(hitEnt)) {
		new Float:takeDamage;
		pev(hitEnt, pev_takedamage, takeDamage);

		new Float:dmg = 20.0 + get_pcvar_float(cvar_dmg_dinfinity);

		new hitGroup = get_tr2(hTrace, TR_iHitgroup);

		switch (hitGroup) {
			case HIT_HEAD: { dmg *= 3.0; }
			case HIT_LEFTARM: { dmg *= 0.9; }
			case HIT_RIGHTARM: { dmg *= 0.9; }
			case HIT_LEFTLEG: { dmg *= 0.9; }
			case HIT_RIGHTLEG: { dmg *= 0.9; }
		}
		if (is_user_connected(hitEnt)) {
			ExecuteHamB(Ham_TakeDamage, hitEnt, id, id, dmg, DMG_BULLET | DMG_NEVERGIB);
			ExecuteHamB(Ham_TraceBleed, hitEnt, dmg, VecDir, hTrace, DMG_BULLET | DMG_NEVERGIB);
			make_blood(VecEnd, dmg, hitEnt);
		}
		
	}
	} 
	else if(!is_user_connected(target))
	{
		if(target)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			write_short(target)
			message_end()
		} 
		else 
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			write_coord(aimOrigin[0])
			write_coord(aimOrigin[1])
			write_coord(aimOrigin[2])
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
			message_end()
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		write_coord(aimOrigin[0])
		write_coord(aimOrigin[1])
		write_coord(aimOrigin[2])
		write_short(id)
		write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
		message_end()
	}

}
public DInfinity_ItemPostFrame(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
	return HAM_IGNORED;

	if (!g_has_dinfinity[id])
	return HAM_IGNORED;

	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

	new iBpAmmo = cs_get_user_bpammo(id, CSW_ELITE);
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

	new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 

	if( fInReload && flNextAttack <= 0.0 )
	{
		new j = min(get_pcvar_num(cvar_clip_dinfinity) - iClip, iBpAmmo)
	
		set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
		cs_set_user_bpammo(id, CSW_ELITE, iBpAmmo-j);
		
		set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
		fInReload = 0
	}

	return HAM_IGNORED;
}

public DInfinity_Reload(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED;

	if (!g_has_dinfinity[id])
		return HAM_IGNORED;

	g_DINFINITY_TmpClip[id] = -1;
	new iBpAmmo = cs_get_user_bpammo(id, CSW_ELITE);
	new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

	if (iBpAmmo <= 0)
		return HAM_SUPERCEDE;

	if (iClip >= get_pcvar_num(cvar_clip_dinfinity))
		return HAM_SUPERCEDE;


	g_DINFINITY_TmpClip[id] = iClip;

	return HAM_IGNORED;
}

public DInfinity_Reload_Post(weapon_entity) {
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED;

	if (!g_has_dinfinity[id])
		return HAM_IGNORED;

	if (g_DINFINITY_TmpClip[id] == -1)
		return HAM_IGNORED;

	new iBpAmmo = cs_get_user_bpammo(id, CSW_ELITE);

	if (iBpAmmo <= 0)
		return HAM_IGNORED;

	set_pdata_int(weapon_entity, m_iClip, g_DINFINITY_TmpClip[id], WEAP_LINUX_XTRA_OFF)

	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, DINFINITY_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)

	set_pdata_float(id, m_flNextAttack, DINFINITY_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)

	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

	// relaod animation
	UTIL_PlayWeaponAnimation(id, 14)
	remove_task(id)
	g_mode[id] = 0

	return HAM_IGNORED;
}

public Hook_Infinity(id)
{
	engclient_cmd(id, "weapon_elite");
}

public WeaponList(id)
{
	new Message_WeaponList = get_user_msgid("WeaponList")
	
	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(g_has_dinfinity[id] ? "gg_weapon_infinity" : "weapon_elite");		// WeaponName
	write_byte(10);				// PrimaryAmmoID
	write_byte(120);			// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(1);				// SlotID (0...N)
	write_byte(5);				// NumberInSlot (1...N)
	write_byte(CSW_ELITE);		// WeaponID
	write_byte(0);				// Flags
	message_end();
}

public get_origin_int(index, origin[3])
{
	new Float:FVec[3]

	pev(index,pev_origin,FVec)

	origin[0] = floatround(FVec[0])
	origin[1] = floatround(FVec[1])
	origin[2] = floatround(FVec[2])

	return 1
}

public zero_values(id)
{
	g_attack2[id] = 0
	g_has_dinfinity[id] = false
}

stock make_blood(const Float:vTraceEnd[3], Float:Damage, hitEnt) {
	new bloodColor = ExecuteHam(Ham_BloodColor, hitEnt);
	if (bloodColor == -1)
		return;

	new amount = floatround(Damage);

	amount *= 2; //according to HLSDK

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSPRITE);
	write_coord(floatround(vTraceEnd[0]));
	write_coord(floatround(vTraceEnd[1]));
	write_coord(floatround(vTraceEnd[2]));
	write_short(m_iBlood[1]);
	write_short(m_iBlood[0]);
	write_byte(bloodColor);
	write_byte(min(max(3, amount/10), 16));
	message_end();
}

stock client_printc(index, const text[], any:...)
{
	new szMsg[128];
	vformat(szMsg, sizeof(szMsg) - 1, text, 3);

	replace_all(szMsg, sizeof(szMsg) - 1, "!g", "^x04");
	replace_all(szMsg, sizeof(szMsg) - 1, "!n", "^x01");
	replace_all(szMsg, sizeof(szMsg) - 1, "!t", "^x03");

	if(index == 0)
	{
		for(new i = 0; i < get_maxplayers(); i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, i);
				write_byte(i);
				write_string(szMsg);
				message_end();	
			}
		}		
	} else {
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, index);
		write_byte(index);
		write_string(szMsg);
		message_end();
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
