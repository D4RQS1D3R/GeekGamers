#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "Skull1"
#define VERSION "1.0"
#define AUTHOR "Aragon*" // Edited by D4RQS1D3R

new bool:HaveSkull1[33], skull1_clip[33], skull1_reload[33], skull1_event;
new skull1damage, skull1clip, skull1reloadtime, skull1recoil;
new Shell;
new Float:cl_pushangle[33][3];
new BloodSpray, BloodDrop;

new SECONDARY_WEAPONS_BITSUM = (1<<CSW_GLOCK18)|(1<<CSW_USP)|(1<<CSW_P228)|(1<<CSW_DEAGLE)|(1<<CSW_FIVESEVEN)|(1<<CSW_ELITE);
new IsInPrimaryAttack;

#define SKULL1_WEAPONKEY	205
#define weapon_skull1		"weapon_deagle"
#define CSW_SKULL1			CSW_DEAGLE
#define DMG_HEGRENADE 		(1<<24)

new Skull1Model_V[] = "models/[GeekGamers]/Secondary/v_skull1.mdl";
new Skull1Model_P[] = "models/[GeekGamers]/Secondary/p_skull1.mdl";
new Skull1Model_W[] = "models/[GeekGamers]/Secondary/w_skull1.mdl";

new Skull1_Sound[][] = {
	"weapons/skull1_shoot1.wav",
	"weapons/skull1_draw.wav",
	"weapons/skull1_clipin.wav",
	"weapons/skull1_clipout.wav"
};

new Skull1_Generic[][] = {
	"sprites/gg_weapon_skull1.txt",
	"sprites/[GeekGamers]/Weapons/Skull1.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_skull1", "Hook_Skull1");
	
	Shell = engfunc(EngFunc_PrecacheModel, "models/rshell.mdl");
	
	register_message(get_user_msgid("DeathMsg"), "Skull1_DeathMsg");
	
	register_event("CurWeapon", "Skull1_ViewModel", "be", "1=1");
	register_event("WeapPickup","Skull1_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "Skull1_WorldModel");
	register_forward(FM_UpdateClientData, "Skull1_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "Skull1_PlaybackEvent");
	
	RegisterHam(Ham_TakeDamage, "player", "Skull1_TakeDamage");
	RegisterHam(Ham_TraceAttack, "worldspawn", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "player", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "Skull1_TraceAttack_Post", 1);
	RegisterHam(Ham_Item_Deploy , weapon_skull1, "Skull1_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_skull1, "Skull1_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_skull1, "Skull1_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, weapon_skull1, "Skull1_AddToPlayer");
	RegisterHam(Ham_Weapon_Reload, weapon_skull1, "Skull1_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_skull1, "Skull1_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_skull1, "Skull1_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	skull1damage = register_cvar("furien30_skull1_bonus_damage", "0");			//| Skull1 Damage |//
	skull1clip = register_cvar("furien30_skull1_clip", "7");				//| Skull1 Clip |//
	skull1reloadtime = register_cvar("furien30_skull1_reload_time", "2.53");		//| Skull1 Reload Time |//
	skull1recoil = register_cvar("furien30_skull1_recoil", "0.8");			//| Skull1 Recoil |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "Skull1_PrecacheEvent_Post", 1);
	
	precache_model(Skull1Model_V);
	precache_model(Skull1Model_P);
	precache_model(Skull1Model_W);
	for(new i = 0; i < sizeof(Skull1_Sound); i++)
		engfunc(EngFunc_PrecacheSound, Skull1_Sound[i]);	
	for(new i = 0; i < sizeof(Skull1_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, Skull1_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_skull1", "get_user_skull1", 1);
	register_native("gg_set_user_skull1", "set_user_skull1", 1);
}

public get_user_skull1(id)
{
	return HaveSkull1[id];
}

public set_user_skull1(id)
{
	// drop_secondary_weapons(id);
	HaveSkull1[id] = true;
	skull1_reload[id] = 0;

	WeaponList(id)
	fm_give_item(id, weapon_skull1);

	new Clip = fm_get_user_weapon_entity(id, CSW_SKULL1);
	cs_set_weapon_ammo(Clip, get_pcvar_num(skull1clip));
}

public HAM_Spawn_Post(id)
{
	HaveSkull1[id] = false;
}

public Skull1_DeathMsg(msg_id, msg_dest, id) {
	static TruncatedWeapon[33], Attacker, Victim;
	
	get_msg_arg_string(4, TruncatedWeapon, charsmax(TruncatedWeapon));
	
	Attacker = get_msg_arg_int(1);
	Victim = get_msg_arg_int(2);
	
	if(!is_user_connected(Attacker) || Attacker == Victim)
		return PLUGIN_CONTINUE;
	
	if(equal(TruncatedWeapon, "deagle") && get_user_weapon(Attacker) == CSW_SKULL1) {
		if(get_user_skull1(Attacker))
			set_msg_arg_string(4, "Skull1");
	}
	return PLUGIN_CONTINUE;
}

public Skull1_ViewModel(id) {
	if(get_user_weapon(id) == CSW_SKULL1 && get_user_skull1(id)) {
		set_pev(id, pev_viewmodel2, Skull1Model_V);
		set_pev(id, pev_weaponmodel2, Skull1Model_P);
	}
}

public Skull1_WorldModel(entity, model[]) {
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	
	static ClassName[33];
	entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
	
	if(!equal(ClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	new Owner = entity_get_edict(entity, EV_ENT_owner);	
	new Skull1 = find_ent_by_owner(-1, weapon_skull1, entity);
	
	if(get_user_skull1(Owner) && is_valid_ent(Skull1) && equal(model, "models/w_deagle.mdl")) {
		entity_set_int(Skull1, EV_INT_impulse, SKULL1_WEAPONKEY);
		HaveSkull1[Owner] = false;
		entity_set_model(entity, Skull1Model_W);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public Skull1_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id)) {
		if(get_user_weapon(id) == CSW_SKULL1 && get_user_skull1(id))	
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	}
}

public Skull1_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(!is_user_connected(invoker))
		return FMRES_IGNORED;
	if(eventid != skull1_event || !IsInPrimaryAttack)
		return FMRES_IGNORED;
	
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	
	return FMRES_SUPERCEDE;
}

public Skull1_PrecacheEvent_Post(type, const name[]) {
	if(equal("events/deagle.sc", name)) {
		skull1_event = get_orig_retval();
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public Skull1_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype) {
	if(is_user_connected(attacker) && !(damagetype & DMG_HEGRENADE)) {
		new Body, Target, Float:NewDamage;
		if(get_user_weapon(attacker) == CSW_SKULL1 && get_user_skull1(attacker)) {
			if(is_user_connected(victim)) {
				get_user_aiming(attacker, Target, Body, 999999);
				NewDamage = float(get_damage_body(Body, get_pcvar_float(skull1damage)));
				SetHamParamFloat(4, damage + NewDamage);
			} 
			else {
				SetHamParamFloat(4, damage + get_pcvar_float(skull1damage));
			}
		}
	}
}

public Skull1_TraceAttack_Post(ent, attacker, Float:Damage, Float:Dir[3], ptr, DamageType) {
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return HAM_IGNORED;
	if(get_user_weapon(attacker) != CSW_SKULL1)
		return HAM_IGNORED;
	if(!get_user_skull1(attacker))
		return HAM_IGNORED;
	
	static Float:End[3];
	get_tr2(ptr, TR_vecEndPos, End);
	
	make_bullet(attacker, End);
	
	return HAM_HANDLED;
}

public Skull1_AddToPlayer(Weapon, id) {
	if(is_valid_ent(Weapon) && is_user_connected(id) && entity_get_int(Weapon, EV_INT_impulse) == SKULL1_WEAPONKEY) {
		HaveSkull1[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
		WeaponList(id)
	}
}

public Skull1_Deploy_Post(entity) {
	static Owner;
	Owner = get_pdata_cbase(entity, 41, 4);
	if(get_user_skull1(Owner)) {
		set_pev(Owner, pev_viewmodel2, Skull1Model_V);
		set_pev(Owner, pev_weaponmodel2, Skull1Model_P);
		set_pdata_float(Owner, 83, 1.01, 5);
		set_weapon_anim(Owner, 7);
		static clip;
		clip = cs_get_weapon_ammo(entity);
		if(clip > 0)
			skull1_reload[Owner] = 0;
	}
}

public Skull1_PrimaryAttack(Weapon) {
	new id = get_pdata_cbase(Weapon, 41, 4);
	
	if(get_user_skull1(id)) {
		IsInPrimaryAttack = true;
		pev(id,pev_punchangle,cl_pushangle[id]);
		skull1_clip[id] = cs_get_weapon_ammo(Weapon);
	}
}

public Skull1_PrimaryAttack_Post(Weapon) {
	new id = get_pdata_cbase(Weapon, 41, 4);
	new ActiveItem = get_pdata_cbase(id, 373);
	IsInPrimaryAttack = false;
	
	if(skull1_clip[id] > cs_get_weapon_ammo(Weapon) && skull1_clip[id] > 0 && pev_valid(ActiveItem)) {
		if(is_user_alive(id) && get_user_skull1(id)) {			
			set_pdata_int(ActiveItem, 57, Shell, 4) ;
			set_pdata_float(id, 111, get_gametime());
			
			new Float:Push[3];
			pev(id,pev_punchangle,Push);
			xs_vec_sub(Push,cl_pushangle[id],Push);
			
			xs_vec_mul_scalar(Push,get_pcvar_float(skull1recoil),Push);
			xs_vec_add(Push,cl_pushangle[id],Push);
			set_pev(id,pev_punchangle,Push);
			
			emit_sound(id, CHAN_WEAPON, Skull1_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			set_weapon_anim(id, random_num(2,3));
			return HAM_SUPERCEDE;
		}
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public Skull1_Reload(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_skull1(id))
		return HAM_IGNORED;
	
	skull1_clip[id] = -1;
	
	new Ammo = cs_get_user_bpammo(id, CSW_SKULL1);
	if(Ammo <= 0)
		return HAM_SUPERCEDE;
	
	new Clip = get_pdata_int(ent, 51, 4);
	if(Clip >= get_pcvar_num(skull1clip))
		return HAM_SUPERCEDE;
	
	skull1_clip[id] = Clip;
	skull1_reload[id] = 1;
	
	return HAM_IGNORED;
}

public Skull1_Reload_Post(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_skull1(id))
		return HAM_IGNORED;
	
	if(skull1_clip[id] == -1)
		return HAM_IGNORED;
	
	new Float:reload_time = get_pcvar_float(skull1reloadtime);
	
	set_pdata_int(ent, 51, skull1_clip[id], 4);
	set_pdata_float(ent, 48, reload_time, 4);
	set_pdata_float(id, 83, reload_time, 5);
	set_pdata_int(ent, 54, 1, 4);
	set_weapon_anim(id, 6);
	return HAM_IGNORED;
}

public Skull1_PostFrame(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_skull1(id))
		return HAM_IGNORED;
	
	new Float:NextAttack = get_pdata_float(id, 83, 5);
	new Ammo = cs_get_user_bpammo(id, CSW_SKULL1);
	
	new Clip = get_pdata_int(ent, 51, 4);
	new InReload = get_pdata_int(ent, 54, 4);
	
	if(InReload && NextAttack <= 0.0) {
		new Temp = min(get_pcvar_num(skull1clip) - Clip, Ammo);
		
		set_pdata_int(ent, 51, Clip + Temp, 4);
		cs_set_user_bpammo(id, CSW_SKULL1, Ammo - Temp);		
		set_pdata_int(ent, 54, 0, 4);
		
		InReload = 0;
		skull1_reload[id] = 0;
	}		
	
	return HAM_IGNORED;
}

public Hook_Skull1(id) {
	engclient_cmd(id, weapon_skull1);
}

public WeaponList(id)
{
	new Message_WeaponList = get_user_msgid("WeaponList")
	
	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(HaveSkull1[id] ? "gg_weapon_skull1" : "weapon_deagle");		// WeaponName
	write_byte(8);				// PrimaryAmmoID
	write_byte(35);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(1);				// SlotID (0...N)
	write_byte(1);				// NumberInSlot (1...N)
	write_byte(CSW_SKULL1);	// WeaponID
	write_byte(0);				// Flags
	message_end();
}

stock get_damage_body(body, Float:damage)
{
	switch(body)
	{
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
		default: 
		damage *= 1.0;
	}

	return floatround(damage);
}

stock make_bullet(id, Float:Origin[3])
{
	// Find target
	new target, body;
	get_user_aiming(id, target, body, 999999);
	
	if(target > 0 && target <= get_maxplayers()) {
		new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3];
		pev(id, pev_origin, fStart);
		
		velocity_by_aim(id, 64, fVel);
		
		fStart[0] = Origin[0];
		fStart[1] = Origin[1];
		fStart[2] = Origin[2];
		fEnd[0] = fStart[0]+fVel[0];
		fEnd[1] = fStart[1]+fVel[1];
		fEnd[2] = fStart[2]+fVel[2];
		
		new res;
		engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res);
		get_tr2(res, TR_vecEndPos, fRes);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) ;
		write_byte(TE_BLOODSPRITE);
		write_coord(floatround(fStart[0]));
		write_coord(floatround(fStart[1]));
		write_coord(floatround(fStart[2]));
		write_short(BloodSpray);
		write_short(BloodDrop);
		write_byte(70);
		write_byte(random_num(1,2));
		message_end();
		
		
	} 
	else {
		new decal = 41;
		
		if(target) {
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_DECAL);
			write_coord(floatround(Origin[0]));
			write_coord(floatround(Origin[1]));
			write_coord(floatround(Origin[2]));
			write_byte(decal);
			write_short(target);
			message_end();
		} 
		else {
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_WORLDDECAL);
			write_coord(floatround(Origin[0]));
			write_coord(floatround(Origin[1]));
			write_coord(floatround(Origin[2]));
			write_byte(decal);
			message_end();
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_GUNSHOTDECAL);
		write_coord(floatround(Origin[0]));
		write_coord(floatround(Origin[1]));
		write_coord(floatround(Origin[2]));
		write_short(id);
		write_byte(decal);
		message_end();
	}
}

stock set_weapon_anim(id, anim)
{
	set_pev(id, pev_weaponanim, anim);
	if(is_user_connected(id))
	{
		message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
		write_byte(anim);
		write_byte(pev(id, pev_body));
		message_end();
	}
}

stock drop_secondary_weapons(Player) {
	// Get user weapons
	static weapons [32], num, i, weaponid;
	num = 0; // reset passed weapons count(bugfix)
	get_user_weapons(Player, weapons, num);
	
	// Loop through them and drop primaries
	for(i = 0; i < num; i++) {
		// Prevent re-indexing the array
		weaponid = weapons [i];
		
		// We definetely are holding primary gun
		if(((1<<weaponid) & SECONDARY_WEAPONS_BITSUM)) {
			// Get weapon entity
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(Player, "drop", wname);
		}
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
