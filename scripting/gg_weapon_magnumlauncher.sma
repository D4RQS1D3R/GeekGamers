#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>

#pragma compress 1

#define PLUGIN "[GG] Magnum Launcher"
#define VERSION "2.0"
#define AUTHOR "Dias"

#define V_MODEL "models/[GeekGamers]/Primary/v_sgmissile.mdl"
#define P_MODEL "models/[GeekGamers]/Primary/p_sgmissile_a.mdl"
#define W_MODEL "models/[GeekGamers]/Primary/w_sgmissile.mdl"

#define CSW_BALROG11 CSW_XM1014
#define weapon_sgmissile "weapon_xm1014"

#define OLD_W_MODEL "models/w_xm1014.mdl"
#define OLD_EVENT "events/xm1014.sc"
#define WEAPON_SECRETCODE 1982

// Weapon Configs

#define DRAW_TIME 1.0
#define DAMAGE 30
#define FIRE_DAMAGE 70
#define BPAMMO 90
#define RADIUS_DAMAGE 60

#define CHARGE_COND_AMMO 1
#define MAX_SPECIAL_AMMO 1
#define SPECIALSHOOT_DELAY 0.6
#define FIRE_SPEED 2100
#define SYSTEM_CLASSNAME "mlc_bidjipeler"

const Float:Sped_Atak = 0.39 // customable
//const Float:Demeg_Boom = random_float(60.0, 90.0)

// OFFSET
const PDATA_SAFE = 2
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_WEAPONOWNER = 41
const m_flNextAttack = 83
const m_flNextPrimaryAttack	= 46
const m_flNextSecondaryAttack	= 47

#define m_fKnown		44
#define m_flTimeWeaponIdle	48
#define m_iClip			51
#define m_fInReload		54

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
		
// Some Resources		

new const WeaponSounds[9][] = 
{
	"weapons/sgmissile-1.wav",
	"weapons/sgmissile-2.wav",
	"weapons/sgmissile_shoot_missile_last.wav",
	"weapons/sgmissile_missile_on.wav",
	"weapons/sgmissile_clipin.wav",
	"weapons/sgmissile_clipout.wav",
	"weapons/sgmissile_draw.wav",
	"weapons/sgmissile_draw_b.wav",
	"weapons/sgmissile_reload.wav"
}

new const WeaponResources[4][] =
{
	"sprites/ef_sgmissile_line.spr", // ball models
	"sprites/weapon_sgmissile.txt",
	"sprites/640hud173.spr",
	"sprites/640hud17.spr"
}

// Weapon Anims

enum
{
	B11_ANIM_IDLE = 0,
	B11_ANIM_RELOAD,
	B11_ANIM_DRAW,
	B11_ANIM_SHOOT,
	B11_ANIM_IDLE_B,
	B11_ANIM_RELOAD_B,
	B11_ANIM_DRAW_B,
	B11_ANIM_SHOOT_B,
	B11_ANIM_SHOOT2_B,
	B11_ANIM_SHOOTSPECIAL,
	B11_ANIM_SHOOTSPECIAL2,
	B11_ANIM_HURUNG
}

// Constant

new g_had_balrog11[33], g_holding_attack[33], g_Shoot_Count[33], g_SpecialAmmo[33], g_Boom, g_weapon_TmpClip[33]
new g_old_weapon[33], g_event_balrog11, g_Msg_StatusIcon, g_smokepuff_id, g_ham_bot/*, Float:g_Recoil[33]*/
new g_charged[33]

// Started Building the plugin below here !

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	// Engine !
	
	register_think(SYSTEM_CLASSNAME, "fw_Think")
	
	// Fuckmeta
	
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	
	// Beefsandwich
	
	RegisterHam(Ham_Weapon_Reload, weapon_sgmissile, "Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_sgmissile, "Weapon_Reload_Post", 1)
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_sgmissile, "fw_Idle", 1)
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")	
	RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1);
	RegisterHam(Ham_Item_AddToPlayer, weapon_sgmissile, "fw_Item_AddToPlayer_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_sgmissile, "fw_Item_PostFrame")
	RegisterHam(Ham_Item_Deploy, weapon_sgmissile, "fw_Item_Deploy_Post", 1)
		
	// Message
	
	g_Msg_StatusIcon = get_user_msgid("StatusIcon")
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	
	// Commands
	
	//register_clcmd("test_bl11", "Get_Balrog11", ADMIN_BAN)
	register_clcmd("weapon_sgmissile", "hook_weapon")
}

// Precaching some resources

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, V_MODEL)
	engfunc(EngFunc_PrecacheModel, P_MODEL)
	engfunc(EngFunc_PrecacheModel, W_MODEL)
	engfunc(EngFunc_PrecacheModel, "models/[GeekGamers]/Primary/p_sgmissile_b.mdl")
	
	precache_sound("weapons/sgmissile_exp.wav") // explode sounds
	g_Boom = precache_model("sprites/ef_sgmissile.spr") // explode model
	
	new i
	for(i = 0; i < sizeof(WeaponSounds); i++)
		engfunc(EngFunc_PrecacheSound, WeaponSounds[i])
	for(i = 0; i < sizeof(WeaponResources); i++)
	{
		if(i == 1) engfunc(EngFunc_PrecacheGeneric, WeaponResources[i])
		else engfunc(EngFunc_PrecacheModel, WeaponResources[i])
	}
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)	
	g_smokepuff_id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
}

public plugin_natives()
{
	register_native("gg_set_user_magnumlauncher", "native_Get_Balrog11", 1)
}

public native_Get_Balrog11(id)
{
	Get_Balrog11(id)
}

public Player_Spawn(id)
{
	Remove_Balrog11(id)
}

public client_putinserver(id)
{
	if(!g_ham_bot && is_user_bot(id))
	{
		g_ham_bot = 1
		set_task(0.1, "do_register", id)
	}
}

public do_register(id)
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal(OLD_EVENT, name))
		g_event_balrog11 = get_orig_retval()
}

public Get_Balrog11(id)
{
	if(!is_user_alive(id))
		return
		
	//drop_weapons(id, 1)
	Remove_Balrog11(id)
		
	g_had_balrog11[id] = 1
	g_old_weapon[id] = 0
	g_holding_attack[id] = 0
	g_Shoot_Count[id] = 0
	g_SpecialAmmo[id] = 0
	g_charged[id] = 0
	
	fm_give_item(id, weapon_sgmissile)
	static dor;dor = fm_get_user_weapon_entity(id, CSW_BALROG11)
	cs_set_weapon_ammo(dor, 30)
	cs_set_user_bpammo(id, CSW_BALROG11, BPAMMO)
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_BALROG11)
	write_byte(30)
	message_end()
}

public client_PostThink(id)
{	
	if(!is_user_alive(id) || get_user_weapon(id) != CSW_BALROG11 || !g_had_balrog11[id])
		return
		
	if(g_SpecialAmmo[id] == 0) set_task(4.0, "Refill", id)
}

public message_DeathMsg(msg_id, msg_dest, msg_ent)
{
	new szWeapon[64]
	get_msg_arg_string(4, szWeapon, charsmax(szWeapon))
	
	if (strcmp(szWeapon, "knife"))
		return PLUGIN_CONTINUE

	new iEntity = get_pdata_cbase(get_msg_arg_int(1), 373)
	if (!pev_valid(iEntity) || get_pdata_int(iEntity, 43, 4) != CSW_BALROG11 || !g_had_balrog11[get_msg_arg_int(1)])
		return PLUGIN_CONTINUE

	set_msg_arg_string(4, "sgmissile")
	return PLUGIN_CONTINUE
}

public Refill(id)
{
	if(g_SpecialAmmo[id] > MAX_SPECIAL_AMMO)
		return
	if(!is_user_alive(id) || get_user_weapon(id) != CSW_BALROG11 || !g_had_balrog11[id])
		return
	
	if(g_SpecialAmmo[id] == 0)
	{
		set_weapon_anim(id, B11_ANIM_HURUNG)
		Charge(id)
	}
}

public Charge(id)
{
	g_charged[id] = 1
	g_SpecialAmmo[id] = MAX_SPECIAL_AMMO
	set_pev(id, pev_weaponmodel2, "models/[GeekGamers]/Primary/p_sgmissile_b.mdl")
	client_print(id, print_center, "Special Ammo [%i]", g_SpecialAmmo[id])
}

public Remove_Balrog11(id)
{
	if(!is_user_connected(id))
		return
		
	update_specialammo(id, g_SpecialAmmo[id], 0)
		
	g_had_balrog11[id] = 0
	g_old_weapon[id] = 0
	g_holding_attack[id] = 0
	g_Shoot_Count[id] = 0
	g_charged[id] = 0
	g_SpecialAmmo[id] = 0	
}

public hook_weapon(id)
{
	engclient_cmd(id, weapon_sgmissile)
	return PLUGIN_HANDLED
}

public Event_CurWeapon(id)
{
	if(!is_user_alive(id))
		return	
	
	if(g_had_balrog11[id] && (get_user_weapon(id) == CSW_BALROG11 && g_old_weapon[id] != CSW_BALROG11))
	{ // Balrog Draw
		if(g_SpecialAmmo[id] == 0) set_weapon_anim(id, B11_ANIM_DRAW)
		else if(g_SpecialAmmo[id] >= 1) set_weapon_anim(id, B11_ANIM_DRAW_B)
		set_player_nextattack(id, DRAW_TIME)
		
	}
	
	static Float:Speed
	Speed = Sped_Atak
		
	static weapon[32], Ent
	get_weaponname(read_data(2), weapon, 31)
	Ent = find_ent_by_owner(-1, weapon, id)
	if(pev_valid(Ent))
	{
		static Float:Delay
		Delay = get_pdata_float(Ent, 46, 4) * Speed
		if(Delay > 0.0) set_pdata_float(Ent, 46, Delay, 4)
	}
	
	g_old_weapon[id] = get_user_weapon(id)
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id))
		return
	if(get_user_weapon(id) != CSW_BALROG11 || !g_had_balrog11[id])
		return
		
	static NewButton; NewButton = get_uc(uc_handle, UC_Buttons)
	
	if(NewButton & IN_ATTACK2)
	{
		SpecialShoot_Handle(id)
	}
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static Classname[64]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static id
	id = pev(entity, pev_owner)
	
	if(equal(model, OLD_W_MODEL))
	{
		static weapon
		weapon = fm_get_user_weapon_entity(entity, CSW_BALROG11)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED
		
		if(g_had_balrog11[id])
		{
			set_pev(weapon, pev_impulse, WEAPON_SECRETCODE)
			set_pev(weapon, pev_iuser4, g_SpecialAmmo[id])
			engfunc(EngFunc_SetModel, entity, W_MODEL)
			
			Remove_Balrog11(id)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}

public fw_Idle(iEnt)
{
	if(pev_valid(iEnt) != 2)
		return
	static Id; Id = get_pdata_cbase(iEnt, 41, 4)
	if(get_pdata_cbase(Id, 373) != iEnt)
		return
	if(!g_had_balrog11[Id])
		return
		
	if(get_pdata_float(iEnt, 48, 4) <= 0.25)
	{
		if(g_SpecialAmmo[Id] == 0) set_weapon_anim(Id, B11_ANIM_IDLE)
		else if(g_SpecialAmmo[Id] > 1) set_weapon_anim(Id, B11_ANIM_IDLE_B)
		
		set_pdata_float(iEnt, 48, 20.0, 4)
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED	
	if(get_user_weapon(id) == CSW_BALROG11 && g_had_balrog11[id])
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED		
	if(get_user_weapon(invoker) == CSW_BALROG11 && g_had_balrog11[invoker] && eventid == g_event_balrog11)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)	
		
		if(g_SpecialAmmo[invoker] == 0) set_weapon_anim(invoker, B11_ANIM_SHOOT)
		else if(g_SpecialAmmo[invoker] >= 1) set_weapon_anim(invoker, B11_ANIM_SHOOT_B)
		emit_sound(invoker, CHAN_WEAPON, WeaponSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)	

		return FMRES_SUPERCEDE
	}
	
	return FMRES_HANDLED
}

public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
	if(!is_user_alive(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != CSW_BALROG11 || !g_had_balrog11[Attacker])
		return HAM_IGNORED

	static Float:flEnd[3], Float:vecPlane[3]
	
	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
		
	if(!is_user_alive(Ent))
	{
		make_bullet(Attacker, flEnd)
		fake_smoke(Attacker, ptr)
	}
		
	SetHamParamFloat(3, float(DAMAGE) / random_float(1.5, 2.5))	

	return HAM_HANDLED		
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if(pev(ent, pev_impulse) == WEAPON_SECRETCODE)
	{
		g_had_balrog11[id] = 1
		
		set_pev(ent, pev_impulse, 0)
		g_SpecialAmmo[id] = pev(ent, pev_iuser4)
	}			
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("WeaponList"), _, id)
	write_string((g_had_balrog11[id] == 1 ? "weapon_sgmissile" : "weapon_xm1014"))
	write_byte(5)
	write_byte(105)
	write_byte(-1)
	write_byte(-1)
	write_byte(0)
	write_byte(12)
	write_byte(CSW_BALROG11)
	write_byte(0)
	message_end()
}

public fw_Item_PostFrame(ent)
{
	static id; id = fm_cs_get_weapon_ent_owner(ent)
	if (!pev_valid(id))
		return HAM_IGNORED

	if(!g_had_balrog11[id])
		return HAM_IGNORED
		
	static iClipExtra
     
	iClipExtra = 30
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)

	new iBpAmmo = cs_get_user_bpammo(id, CSW_BALROG11)
	new iClip = get_pdata_int(ent, m_iClip, 4)

	new fInReload = get_pdata_int(ent, m_fInReload, 4) 
	if(fInReload && flNextAttack <= 0.0)
	{
		new j = min(iClipExtra - iClip, iBpAmmo)
	
		set_pdata_int(ent, m_iClip, iClip + j, 4)
		cs_set_user_bpammo(id, CSW_BALROG11, iBpAmmo-j)
		
		set_pdata_int(ent, m_fInReload, 0, 4)
		fInReload = 0
	}
	
	return HAM_IGNORED
}

public fw_Item_Deploy_Post(ent)
{
	static id; id = fm_cs_get_weapon_ent_owner(ent)
	if (!pev_valid(id))
		return

	if(!g_had_balrog11[id])
		return
		
	set_pev(id, pev_viewmodel2, V_MODEL)
	if(g_SpecialAmmo[id] == 0) set_pev(id, pev_weaponmodel2, P_MODEL)
	else set_pev(id, pev_weaponmodel2, "models/[GeekGamers]/Primary/p_sgmissile_b.mdl")
}

public update_ammo(id)
{
	if(!is_user_alive(id))
		return
	
	static weapon_ent; weapon_ent = fm_get_user_weapon_entity(id, CSW_BALROG11)
	if(!pev_valid(weapon_ent)) return
	
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0, 0, 0}, id)
	write_byte(1)
	write_byte(CSW_BALROG11)
	write_byte(cs_get_weapon_ammo(weapon_ent))
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), _, id)
	write_byte(1)
	write_byte(cs_get_user_bpammo(id, CSW_BALROG11))
	message_end()
}

public update_specialammo(id, Ammo, On)
{
	static AmmoSprites[33]
	format(AmmoSprites, sizeof(AmmoSprites), "number_%d", Ammo)
  	
	message_begin(MSG_ONE_UNRELIABLE, g_Msg_StatusIcon, {0,0,0}, id)
	write_byte(On)
	write_string(AmmoSprites)
	write_byte(42) // red
	write_byte(212) // green
	write_byte(255) // blue
	message_end()
}

public SpecialShoot_Handle(id)
{
	if(get_pdata_float(id, 83, 5) > 0.0)
		return
	if(g_SpecialAmmo[id] <= 0)
		return		

	create_fake_attack(id)	
	
	// Shoot Handle
	if(g_SpecialAmmo[id] == 1)
	{
		set_player_nextattack(id, SPECIALSHOOT_DELAY + 0.4)
		set_weapons_timeidle(id, CSW_BALROG11, SPECIALSHOOT_DELAY + 0.4)
	
		g_SpecialAmmo[id]--
		client_print(id, print_center, "Special Ammo [%i]", g_SpecialAmmo[id])
		
		set_weapon_anim(id, B11_ANIM_SHOOTSPECIAL2)
		set_pev(id, pev_weaponmodel2, "models/[GeekGamers]/Primary/p_sgmissile_b.mdl")
		emit_sound(id, CHAN_WEAPON, WeaponSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(0.2, "Next", id)
	} else if(g_SpecialAmmo[id] > 1)
	{
		set_player_nextattack(id, SPECIALSHOOT_DELAY)
		set_weapons_timeidle(id, CSW_BALROG11, SPECIALSHOOT_DELAY)
	
		g_SpecialAmmo[id]--
		client_print(id, print_center, "Special Ammo [%i]", g_SpecialAmmo[id])
		set_pev(id, pev_weaponmodel2, P_MODEL)
		set_weapon_anim(id, B11_ANIM_SHOOTSPECIAL)
		emit_sound(id, CHAN_WEAPON, WeaponSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	Create_FireSystem(id)
	//check_radius_damage(id)
}

public Next(id) emit_sound(id, CHAN_WEAPON, WeaponSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)

public create_fake_attack(id)
{
	static weapon
	weapon = fm_find_ent_by_owner(-1, "weapon_xm1014", id)
	
	new weaponX, szClip, szAmmo, Player
	
	if(!is_user_alive(Player))
		return
	
	Player = get_pdata_cbase(weaponX, 41, 4)
	
	get_user_weapon(Player, szClip, szAmmo)
	
	if(pev_valid(weapon)) ExecuteHamB(Ham_Weapon_PrimaryAttack, weapon)
	fm_set_weapon_ammo(weaponX, szClip++)
}

public Weapon_Reload(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if(!is_user_connected(id))
		return HAM_IGNORED
	if(!g_had_balrog11[id])
		return HAM_IGNORED

	static iClipExtra
	if(g_had_balrog11[id])
		iClipExtra = 30

	g_weapon_TmpClip[id] = -1

	new iBpAmmo = cs_get_user_bpammo(id, CSW_BALROG11)
	new iClip = get_pdata_int(weapon_entity, m_iClip, 4)

	if(iBpAmmo <= 0)
		return HAM_SUPERCEDE

	if(iClip >= iClipExtra)
		return HAM_SUPERCEDE

	g_weapon_TmpClip[id] = iClip

	return HAM_IGNORED
}

public Weapon_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED

	if(!g_had_balrog11[id])
		return HAM_IGNORED
	if(g_weapon_TmpClip[id] == -1)
		return HAM_IGNORED
	
	set_pdata_int(weapon_entity, m_iClip, g_weapon_TmpClip[id], 4)
	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, 2.2, 4)
	set_pdata_float(id, m_flNextAttack, 2.2, 5)
	set_pdata_int(weapon_entity, m_fInReload, 1, 4)
	
	if(g_SpecialAmmo[id] == 0) set_weapon_anim(id, B11_ANIM_RELOAD)
	else if(g_SpecialAmmo[id] >= 1) set_weapon_anim(id, B11_ANIM_RELOAD_B)
	
	return HAM_IGNORED
}

public Create_FireSystem(id)
{
	static Float:StartOrigin[3], Float:EndOrigin[9][3]
	get_weapon_attachment(id, StartOrigin, 10.0)
	
	// Left
	get_position(id, 70.0, -20.0, 0.0, EndOrigin[0])
	get_position(id, 70.0, -15.0, 0.0, EndOrigin[1])
	get_position(id, 70.0, -10.0, 0.0, EndOrigin[2])
	get_position(id, 70.0, -5.0, 0.0, EndOrigin[3])
	
	// Center
	get_position(id, 70.0, 0.0, 0.0, EndOrigin[4])
	
	// Right
	get_position(id, 70.0, 5.0, 0.0, EndOrigin[5])
	get_position(id, 70.0, 10.0, 0.0, EndOrigin[6])
	get_position(id, 70.0, 15.0, 0.0, EndOrigin[7])
	get_position(id, 70.0, 20.0, 0.0, EndOrigin[8])
	
	for(new i = 0; i < 9; i++) Create_System(id, StartOrigin, EndOrigin[i], 1300.0)
}

public Create_System(id, Float:StartOrigin[3], Float:EndOrigin[3], Float:Speed)
{
	new ent = create_entity("env_sprite")
	static Float:vfAngle[3], Float:MyOrigin[3], Float:Velocity[3]
	
	pev(id, pev_angles, vfAngle)
	pev(id, pev_origin, MyOrigin)
	
	vfAngle[2] = float(random(18) * 20)
	
	// set info for ent
	set_pev(ent, pev_movetype, MOVETYPE_FLY)
	set_pev(ent, pev_rendermode, kRenderTransAdd)
	set_pev(ent, pev_renderamt, 225.0)
	set_pev(ent, pev_fuser1, get_gametime() + 0.7)	// time remove
	set_pev(ent, pev_scale, 0.35)
	set_pev(ent, pev_nextthink, halflife_time() + 0.05)
	
	entity_set_string(ent, EV_SZ_classname, SYSTEM_CLASSNAME)
	engfunc(EngFunc_SetModel, ent, WeaponResources[0])
	set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(ent, pev_origin, StartOrigin)
	set_pev(ent, pev_gravity, 0.01)
	set_pev(ent, pev_angles, vfAngle)
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_owner, id)	
	set_pev(ent, pev_frame, 0.0)
	
	get_speed_vector(StartOrigin, EndOrigin, Speed, Velocity)
	set_pev(ent, pev_velocity, Velocity)
}

public fw_Think(ent)
{
	if(!pev_valid(ent)) 
		return
	
	static Classname[32]; pev(ent, pev_classname, Classname, sizeof(Classname))
	if(equal(Classname, SYSTEM_CLASSNAME))
	{	
		static Float:fFrame; pev(ent, pev_frame, fFrame)
	
		fFrame += 1.5
		fFrame = floatmin(21.0, fFrame)
	
		set_pev(ent, pev_frame, fFrame)
		set_pev(ent, pev_nextthink, get_gametime() + 0.05)
		
		// time remove
		static Float:fTimeRemove
		pev(ent, pev_fuser1, fTimeRemove)
		
		if (get_gametime() < fTimeRemove)
		{
			new Float:fade_out
			pev(ent, pev_renderamt, fade_out)
			fade_out -= 15.0
			fade_out = floatmax(fade_out, 0.0)
			set_pev(ent, pev_renderamt, fade_out)
		}
		
		if(get_gametime() >= fTimeRemove) 
		{
			engfunc(EngFunc_RemoveEntity, ent)
		}
	} else if(equal(Classname, "taikburik")) {
		
		static Float:Origin[3], Float:Scale
		
		pev(ent, pev_origin, Origin)
		pev(ent, pev_scale, Scale)

		Create_Fire2(pev(ent, pev_owner), Origin, 0.25, 0.0)
		
		set_pev(ent, pev_nextthink, get_gametime() + 0.05)
		
		// time remove
		static Float:fTimeRemove
		pev(ent, pev_fuser1, fTimeRemove)
		if(get_gametime() >= fTimeRemove) engfunc(EngFunc_RemoveEntity, ent)
	}
}

public fw_Touch(ent, id)
{
	if(!pev_valid(ent))
		return
		
	static Classname[32]
	pev(ent, pev_classname, Classname, sizeof(Classname))
		
	if(!equal(Classname, SYSTEM_CLASSNAME))
		return
		
	if(pev_valid(id))
	{
		static Classname2[32]
		pev(id, pev_classname, Classname2, sizeof(Classname2))
		
		if(equal(Classname2, SYSTEM_CLASSNAME)) return
		else if(is_user_alive(id) && is_user_connected(id))
		{
			boom_madafaka(ent, id)
			
			return
		}
	}
		
	if(!is_user_alive(id))
	{
		boom_madafaka(ent, id)
	}
}

public boom_madafaka(Ent, id)
{
	static Float:Origin[3]; pev(Ent, pev_origin, Origin)
	
	// Exp Sprite
	new Float: vOrigin[3]
	static TE_FLAG
	pev(Ent, pev_origin, vOrigin)
	
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_Boom)
	write_byte(10)
	write_byte(15)
	write_byte(TE_FLAG)
	message_end()	
	
	// Exp Sound
	emit_sound(Ent, CHAN_ITEM, "weapons/sgmissile_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Damage
	Stock_DamageRadius(Ent, Origin, 90.0, random_float(60.0, 90.0))
	
	// Remove Ent
	set_pev(Ent, pev_movetype, MOVETYPE_NONE)
	
	set_pev(Ent, pev_flags, FL_KILLME)
	remove_entity(Ent)
}

public Create_Fire2(id, Float:Origin[3], Float:Scale, Float:Frame)
{
	static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	// set info for ent
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	set_pev(Ent, pev_rendermode, kRenderTransAdd)
	set_pev(Ent, pev_renderamt, 255.0)
	set_pev(Ent, pev_fuser1, get_gametime() + 0.1)	// time remove
	set_pev(Ent, pev_scale, Scale)
	set_pev(Ent, pev_nextthink, get_gametime() + 0.05)
	
	set_pev(Ent, pev_classname, "taikburik")
	engfunc(EngFunc_SetModel, Ent, WeaponResources[0])
	set_pev(Ent, pev_mins, Float:{-10.0, -10.0, -10.0})
	set_pev(Ent, pev_maxs, Float:{10.0, 10.0, 10.0})
	set_pev(Ent, pev_origin, Origin)
	set_pev(Ent, pev_gravity, 0.01)
	set_pev(Ent, pev_solid, SOLID_TRIGGER)
	set_pev(Ent, pev_owner, id)	
	set_pev(Ent, pev_frame, Frame)
}

stock Stock_DamageRadius(iEnt, Float:vOrigin[3], Float:fRadius, Float:fDamage, iDamageType = DMG_BULLET)
{
	new id = pev(iEnt, pev_owner)
	new iCount, iVictim = FM_NULLENT
	while((iVictim = find_ent_in_sphere(iVictim, vOrigin, fRadius)) != 0) 
	{
		if(iVictim == id) continue
		if(pev(iVictim, pev_takedamage) == DAMAGE_NO) continue
		if(pev(iVictim, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY) continue
		if(is_user_alive(iVictim))
			if(get_user_team(iVictim) == get_user_team(id)) continue
		
		iCount ++
		ExecuteHamB(Ham_TakeDamage, iVictim, iEnt, id, fDamage, iDamageType)
	}
	set_pev(iEnt, pev_owner, id)
	return iCount
}

stock make_bullet(id, Float:Origin[3])
{
	// Find target
	new decal = random_num(41, 45)
	const loop_time = 2
	
	static Body, Target
	get_user_aiming(id, Target, Body, 999999)
	
	if(is_user_connected(Target))
		return
	
	for(new i = 0; i < loop_time; i++)
	{
		// Put decal on "world" (a wall)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(decal)
		message_end()
	}
}

stock fake_smoke(id, trace_result)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(trace_result, TR_vecEndPos, vecSrc)
	get_tr2(trace_result, TR_vecPlaneNormal, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
	write_short(g_smokepuff_id)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock set_weapon_anim(id, anim)
{
	if(!is_user_alive(id))
		return
		
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(0)
	message_end()	
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != PDATA_SAFE)
		return -1
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock set_player_nextattack(id, Float:nexttime)
{
	if(!is_user_alive(id))
		return
		
	set_pdata_float(id, m_flNextAttack, nexttime, 5)
}

stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
	if(!is_user_alive(id))
		return
		
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, OFFSET_LINUX_WEAPONS)
	set_pdata_float(entwpn, 47, TimeIdle, OFFSET_LINUX_WEAPONS)
	set_pdata_float(entwpn, 48, TimeIdle + 0.5, OFFSET_LINUX_WEAPONS)
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

stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, 51, amount, 4);
}

stock is_wall_between_points(Float:start[3], Float:end[3], ignore_ent)
{
	static ptr
	ptr = create_tr2()

	engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ignore_ent, ptr)
	
	static Float:EndPos[3]
	get_tr2(ptr, TR_vecEndPos, EndPos)

	free_tr2(ptr)
	return floatround(get_distance_f(end, EndPos))
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}
/*
// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
     
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
          
		if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		{
			static wname[32]
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
*/
stock HamRadiusDamage(id, ent, Float:radius, Float:damage, bits) 
{ 
	static target, Float:origin[3] 
	
	target = -1
	pev(ent, pev_origin, origin) 
	
	while((target = find_ent_in_sphere(target, origin, radius) )) 
	{ 
		static Float:o[3] 
		pev(target, pev_origin, o) 
		
		xs_vec_sub(origin, o, o) 
		
		// Recheck if the entity is in radius 
		if (xs_vec_len(o) > radius) 
			continue 
		
		if(is_user_alive(target))
		{
			if(id == target)
				continue
		}
		
		Ham_ExecDamageB(target, ent, id, damage * (xs_vec_len(o) / radius), HIT_GENERIC, bits) 
	} 
}  

stock Ham_ExecDamageB(victim, inflictor, attacker, Float:damage, hitgroup, bits)
{
	static const Float:hitgroup_multi[] =
	{
		1.0,  // HIT_GENERIC
		4.0,  // HIT_HEAD
		1.0,  // HIT_CHEST
		1.25, // HIT_STOMACH
		1.0,  // HIT_LEFTARM
		1.0,  // HIT_RIGHTARM
		0.75, // HIT_LEFTLEG
		0.75,  // HIT_RIGHTLEG
		0.0   // HIT_SHIELD
	} 

	set_pdata_int(victim, 75, hitgroup, 5)
	ExecuteHamB(Ham_TakeDamage, victim, inflictor, attacker, damage * hitgroup_multi[hitgroup], bits)
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
