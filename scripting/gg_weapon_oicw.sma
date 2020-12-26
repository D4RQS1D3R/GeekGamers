#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "OICW"
#define VERSION "1.0"
#define AUTHOR "~DarkSiDeRs~"

new bool:HaveOICW[33], OICWCarabineAmmo[33], bool:oicw_launcher[33], oicw_clip[33], oicw_reload[33], oicw_event, oicw_trail, oicw_explode;
new oicwdamage, oicwdamage2, oicwclip, oicwrecoil, oicwradius, oicwknockback, oicwreloadtime, oicwreloadtime2;

#define OICW_WEAPONKEY		99
#define weapon_oicw		"weapon_galil"
#define CSW_OICW		CSW_GALIL
#define OICW_CLASS		"oicw_grenade"
#define oicw_shotdelay		3.0 // Refire rate
#define DMG_HEGRENADE 		(1<<24)

new Shell;
new Float:cl_pushangle[33][3];
new BloodSpray, BloodDrop;

new OICWModel_V[] = "models/[GeekGamers]/Primary/v_oicw.mdl";
new OICWModel_P[] = "models/[GeekGamers]/Primary/p_oicw.mdl";
new OICWModel_W[] = "models/[GeekGamers]/Primary/w_oicw.mdl";
new OICWModel_S[] = "models/[GeekGamers]/Primary/s_oicwgrenade.mdl";

new OICW_Sound[][] = {
	"weapons/oicw_shoot1.wav",
	"weapons/oicw_grenade_shoot1.wav",
	//"weapons/oicw_grenade_shoot2.wav",
	"weapons/oicw_foley1.wav",
	"weapons/oicw_foley2.wav",
	"weapons/oicw_foley3.wav",
	"weapons/oicw_move_carbine.wav",
	"weapons/oicw_move_grenade.wav"
};
new OICW_Generic[][] = {
	"sprites/gg_weapon_oicw.txt",
	"sprites/[GeekGamers]/Weapons/OICW.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_oicw", "Hook_OICW");
	
	register_message(get_user_msgid("DeathMsg"), "OICW_DeathMsg");
	
	register_event("CurWeapon", "OICW_ViewModel", "be", "1=1");
	register_event("WeapPickup","OICW_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "OICW_WorldModel", 1);
	register_forward(FM_UpdateClientData, "OICW_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "OICW_PlaybackEvent");
	register_forward(FM_CmdStart, "OICW_CmdStart");	
	
	RegisterHam(Ham_TakeDamage, "player", "OICW_TakeDamage");
	RegisterHam(Ham_TraceAttack, "worldspawn", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "player", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "OICW_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "OICW_TraceAttack_Post", 1);
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_oicw, "OICW_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_oicw, "OICW_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_oicw, "OICW_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_oicw, "OICW_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_oicw, "OICW_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Weapon_Reload, weapon_oicw, "OICW_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_oicw, "OICW_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_oicw, "OICW_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	register_touch(OICW_CLASS, "*", "OICW_Touch");
	
	oicwdamage = register_cvar("furien30_oicw_bonus_damage", "4");			//| OICW Damage |//
	oicwclip = register_cvar("furien30_oicw_clip", "40");				//| OICW Clip |//
	oicwrecoil = register_cvar("furien30_oicw_recoil", "0.5");			//| OICW Recoil |//
	oicwreloadtime = register_cvar("furien30_oicw_reload_time", "3.6");		//| OICW Reload Time |//
	oicwdamage2 = register_cvar("furien30_oicw_damage2", "80");			//| OICW Grenade Damage |//
	oicwreloadtime2 = register_cvar("furien30_oicw_reload_time2", "3.0");		//| OICW Grenade Reload Time |//
	oicwradius = register_cvar("furien30_oicw_radius", "250.0");			//| OICW Grenade Radius |//
	oicwknockback = register_cvar("furien30_oicw_knockback", "2.0");		//| OICW Grenade Knockback |//
}

public HAM_Spawn_Post(id)
{
	HaveOICW[id] = false;
}

public RoundStart() remove_entity_name(OICW_CLASS);

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "OICW_PrecacheEvent_Post", 1);
	
	oicw_trail = precache_model("sprites/xbeam3.spr");
	oicw_explode = precache_model("sprites/[GeekGamers]/Weapons/explode.spr");
	
	precache_model(OICWModel_V);
	precache_model(OICWModel_P);
	precache_model(OICWModel_W);
	precache_model(OICWModel_S);
	for(new i = 0; i < sizeof(OICW_Sound); i++)
		engfunc(EngFunc_PrecacheSound, OICW_Sound[i]);	
	for(new i = 0; i < sizeof(OICW_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, OICW_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_oicw", "get_user_oicw", 1);
	register_native("gg_set_user_oicw", "set_user_oicw", 1);
}

public OICW_DeathMsg(msg_id, msg_dest, id) {
	static TruncatedWeapon[33], Attacker, Victim;
	
	get_msg_arg_string(4, TruncatedWeapon, charsmax(TruncatedWeapon));
	
	Attacker = get_msg_arg_int(1);
	Victim = get_msg_arg_int(2);
	
	if(!is_user_connected(Attacker) || Attacker == Victim)
		return PLUGIN_CONTINUE;
	
	if(equal(TruncatedWeapon, "galil") && get_user_weapon(Attacker) == CSW_OICW) {
		if(get_user_oicw(Attacker))
			set_msg_arg_string(4, "OICW");
	}
	return PLUGIN_CONTINUE;
}

public OICW_ViewModel(id) {
	if(get_user_weapon(id) == CSW_OICW && get_user_oicw(id)) {
		set_pev(id, pev_viewmodel2, OICWModel_V);
		set_pev(id, pev_weaponmodel2, OICWModel_P);
	}
	return PLUGIN_CONTINUE;
}

public OICW_WorldModel(entity, model[]) {
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new _OICW = find_ent_by_owner(-1, weapon_oicw, entity);
			
			if(get_user_oicw(Owner) && is_valid_ent(_OICW) && equal(model, "models/w_galil.mdl")) {
				entity_set_int(_OICW, EV_INT_impulse, OICW_WEAPONKEY);
				HaveOICW[Owner] = false;
				entity_set_model(entity, OICWModel_W);
			}
		}
	}
	return FMRES_IGNORED;
}

public OICW_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_OICW && get_user_oicw(id))
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public OICW_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == oicw_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public OICW_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/galil.sc", name))
		oicw_event = get_orig_retval();
	return FMRES_IGNORED;
}

public OICW_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		static _OICW;
		_OICW = fm_find_ent_by_owner(-1, weapon_oicw, id);	
		
		if(CurButton & IN_ATTACK && oicw_launcher[id]) {
			if(pev_valid(_OICW) && get_user_weapon(id) == CSW_OICW && get_user_oicw(id)) {
				if(cs_get_weapon_ammo(_OICW) > 0 && !oicw_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, 7);
					emit_sound(id, CHAN_WEAPON, OICW_Sound[1], 1.0, ATTN_NORM, 0, PITCH_NORM);
					OICW_Fire(id);
					new Float:PunchAngle[3]
					PunchAngle[0] = random_float(-5.0, -7.0), PunchAngle[1] = 0.0, PunchAngle[0] = 0.0
					set_pev(id, pev_punchangle, PunchAngle);
					cs_set_weapon_ammo(_OICW, cs_get_weapon_ammo(_OICW) - 1);
					if(cs_get_weapon_ammo(_OICW) > 0 && !oicw_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, oicw_shotdelay, 5);
						set_pdata_float(_OICW, 48, 3.0, 4);
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
		
		if(CurButton & IN_ATTACK2 && !(pev(id, pev_oldbuttons) & IN_ATTACK2)) {
			if(pev_valid(_OICW) && get_user_weapon(id) == CSW_OICW && get_user_oicw(id) && NextAttack <= 0.0) {
				if(oicw_launcher[id]) {
					oicw_launcher[id] = false;
					cs_set_weapon_ammo(_OICW, OICWCarabineAmmo[id]);
					set_pdata_float(_OICW, 48, 1.3, 4)
					set_pdata_float(id, 83, 1.2, 5);
					set_weapon_anim(id, 10)
				}
				else {
					oicw_launcher[id] = true;
					OICWCarabineAmmo[id] = cs_get_weapon_ammo(_OICW)
					cs_set_weapon_ammo(_OICW, 1);
					set_pdata_float(_OICW, 48, 1.3, 4)
					set_pdata_float(id, 83, 1.2, 5);
					set_weapon_anim(id, 9)
				}
				CurButton &= ~IN_ATTACK2;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
	return FMRES_IGNORED;
}

public OICW_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype) {
	if(is_user_connected(attacker) && !(damagetype & DMG_HEGRENADE) && get_user_weapon(attacker) == CSW_OICW && get_user_oicw(attacker)) {
		if(is_user_connected(victim)) {
			new Body, Target, Float:NewDamage;
			get_user_aiming(attacker, Target, Body, 999999);
			NewDamage = float(get_damage_body(Body, get_pcvar_float(oicwdamage)));
			SetHamParamFloat(4, damage + NewDamage);
		} 
		else
			SetHamParamFloat(4, damage + get_pcvar_float(oicwdamage));
	}
	return HAM_IGNORED;
}

public OICW_TraceAttack_Post(ent, attacker, Float:Damage, Float:Dir[3], ptr, DamageType) {
	if(is_user_alive(attacker) && is_user_connected(attacker) && get_user_weapon(attacker) == CSW_OICW && get_user_oicw(attacker)) {
		static Float:End[3];
		get_tr2(ptr, TR_vecEndPos, End);
		
		make_bullet(attacker, End);
	}
	return HAM_IGNORED;
}

public OICW_AddToPlayer(Weapon, id) {
	if(pev_valid(Weapon) && is_user_alive(id) && entity_get_int(Weapon, EV_INT_impulse) == OICW_WEAPONKEY) {
		HaveOICW[id] = true;
		OICWCarabineAmmo[id] = cs_get_weapon_ammo(Weapon)
		WeaponList(id)
		entity_set_int(Weapon, EV_INT_impulse, 0);
	}
	return HAM_IGNORED;
}

public OICW_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner)) {
			set_pev(Owner, pev_viewmodel2, OICWModel_V);
			set_pev(Owner, pev_weaponmodel2, OICWModel_P);
			set_weapon_anim(Owner, 5)
			
			set_pdata_float(Owner, 83, 1.2, 5);
			set_pdata_float(Weapon, 48, 1.2, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				oicw_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}

public OICW_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 2.7, 4)
			set_weapon_anim(Owner, oicw_launcher[Owner] ? 6 : 0)
		}
	}
	return HAM_IGNORED;
}

public OICW_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner) && !oicw_launcher[Owner]) {
			pev(Owner, pev_punchangle, cl_pushangle[Owner]);
			oicw_clip[Owner] = cs_get_weapon_ammo(Weapon);
		}
	}
	return HAM_IGNORED;
}

public OICW_PrimaryAttack_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		new ActiveItem = get_pdata_cbase(Owner, 373) ;
		
		if(is_user_alive(Owner) && get_user_oicw(Owner) && oicw_clip[Owner] > 0 && pev_valid(ActiveItem) && !oicw_launcher[Owner]) {
			set_pdata_int(ActiveItem, 57, Shell, 4) ;
			set_pdata_float(Owner, 111, get_gametime());
			
			new Float:Push[3];
			pev(Owner, pev_punchangle, Push);
			xs_vec_sub(Push, cl_pushangle[Owner], Push);
			
			xs_vec_mul_scalar(Push, get_pcvar_float(oicwrecoil), Push);
			xs_vec_add(Push, cl_pushangle[Owner], Push);
			set_pev(Owner, pev_punchangle, Push);
			
			emit_sound(Owner, CHAN_WEAPON, OICW_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			set_weapon_anim(Owner, random_num(1, 3))
		}
	}
	return HAM_IGNORED;
}

public OICW_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner)) {		
			oicw_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_OICW) <= 0 || !oicw_launcher[Owner] && get_pdata_int(Weapon, 51, 4) >= get_pcvar_num(oicwclip) || oicw_launcher[Owner] && get_pdata_int(Weapon, 51, 4) >= 1)
				return HAM_SUPERCEDE;
			
			oicw_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			oicw_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public OICW_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner) && oicw_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, oicw_clip[Owner], 4);
			set_pdata_float(Weapon, 48, oicw_launcher[Owner] ? get_pcvar_float(oicwreloadtime2) : get_pcvar_float(oicwreloadtime), 4);
			set_pdata_float(Owner, 83, oicw_launcher[Owner] ? get_pcvar_float(oicwreloadtime2) : get_pcvar_float(oicwreloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			if(oicw_launcher[Owner])
				set_weapon_anim(Owner, 7)
			else
				set_weapon_anim(Owner, 4)
		}
	}
	return HAM_IGNORED;
}

public OICW_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_oicw(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min((oicw_launcher[Owner] ? 1 : get_pcvar_num(oicwclip)) - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_OICW));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_OICW, cs_get_user_bpammo(Owner, CSW_OICW) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			oicw_reload[Owner] = false;
			
			if(!oicw_launcher[Owner])
				OICWCarabineAmmo[Owner] = get_pdata_int(Weapon, 51, 4) + Temp
		}
	}
	return HAM_IGNORED;
}

public OICW_Fire(id) {
	new Grenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if(pev_valid(Grenade)) {
		new Float:Origin[3], Float:Angles[3], Float:Velocity[3]
		engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
		pev(id, pev_angles, Angles);
		
		set_pev(Grenade, pev_origin, Origin);
		set_pev(Grenade, pev_angles, Angles);
		set_pev(Grenade, pev_solid, SOLID_BBOX);
		set_pev(Grenade, pev_movetype, MOVETYPE_PUSHSTEP);
		
		set_pev(Grenade, pev_classname, OICW_CLASS);		
		
		set_pev(Grenade, pev_owner, id);
		engfunc(EngFunc_SetModel, Grenade, OICWModel_S);
		
		set_pev(Grenade, pev_mins, {-2.0, -2.0, -2.0});
		set_pev(Grenade, pev_maxs, {2.0, 2.0, 2.0});
		
		velocity_by_aim(id, 2000, Velocity);
		set_pev(Grenade, pev_velocity, Velocity);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE id
		write_short(Grenade); // entity:attachment to follow
		write_short(oicw_trail); // sprite index
		write_byte(1); // life in 0.1's
		write_byte(1); // line width in 0.1's
		write_byte(255); // r
		write_byte(0); // g
		write_byte(0); // b
		write_byte(200); // brightness
		message_end();
	}
}

public OICW_Touch(Grenade, touch) {
	if(is_valid_ent(Grenade)) {
		static Float:GrenadeOrigin[3];
		pev(Grenade, pev_origin, GrenadeOrigin);	
		new id = pev(Grenade, pev_owner);
		
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[0]);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[1]);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[2]);
		write_short(oicw_explode);	// sprite index
		write_byte(20);			// scale in 0.1's
		write_byte(30);			// framerate
		write_byte(0);			// flags
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[0])
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[1])
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[2])
		write_byte(random_num(46, 48))
		message_end()	
		
		static ClassName[32];
		pev(touch, pev_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "player") && is_user_connected(touch) && is_user_alive(touch)) {
			if(!fm_get_user_godmode(touch) && get_user_team(touch) != get_user_team(id) && touch != id) {
				new Float:Damage = get_pcvar_float(oicwdamage2);
				make_blood(touch, get_pcvar_num(oicwdamage2))
				make_knockback(touch, GrenadeOrigin, get_pcvar_float(oicwknockback) * Damage);	
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BLAST);
				else			
					death_message(id, touch, "OICW");			
			}
		}
		else if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(touch, EV_FL_health) <= get_pcvar_num(oicwdamage2))
				force_use(id, touch);
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(GrenadeOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				if(Distance <= get_pcvar_float(oicwradius)) {								
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(oicwradius));
					Damage = get_pcvar_float(oicwdamage2) - floatround(floatmul(get_pcvar_float(oicwdamage2), DistanceRatio));
					make_blood(Victim, floatround(Damage));
					make_knockback(Victim, GrenadeOrigin, get_pcvar_float(oicwknockback)*Damage);
					if(get_user_health(Victim) > Damage)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					else		
						death_message(id, Victim, "OICW");
				}
			}
		}
		engfunc(EngFunc_RemoveEntity, Grenade);
	}
}

public Hook_OICW(id) {
	engclient_cmd(id, weapon_oicw);
	return PLUGIN_HANDLED
}

public get_user_oicw(id)
	return HaveOICW[id];

public set_user_oicw(id, oicw)
{
	HaveOICW[id] = true;
	oicw_launcher[id] = false;
	oicw_reload[id] = false;
			
	fm_give_item(id, weapon_oicw);
	WeaponList(id)
			
	new Weapon = fm_get_user_weapon_entity(id, CSW_OICW);
	cs_set_weapon_ammo(Weapon, get_pcvar_num(oicwclip));
	OICWCarabineAmmo[id] = get_pcvar_num(oicwclip);
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
public WeaponList(id)
{
	new Message_WeaponList = get_user_msgid("WeaponList")

	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(HaveOICW[id] ? "gg_weapon_oicw" : "weapon_galil");		// WeaponName
	write_byte(4);				// PrimaryAmmoID
	write_byte(90);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(17);				// NumberInSlot (1...N)
	write_byte(CSW_OICW);		// WeaponID
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

stock make_bullet(id, Float:Origin[3]) {
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

stock death_message(Killer, Victim, const Weapon[]) {
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
	ExecuteHamB(Ham_Killed, Victim, Killer, 2);
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);
	
	make_deathmsg(Killer, Victim, 0, Weapon);
	cs_set_user_money(Killer, cs_get_user_money(Killer) + 300);
	
	if(is_user_connected(Killer)) {
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Killer); // id
		write_short(pev(Killer, pev_frags)); // frags
		write_short(cs_get_user_deaths(Killer)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Killer)); // team
		message_end();
	}
	if(is_user_connected(Victim)) {
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Victim); // id
		write_short(pev(Victim, pev_frags)); // frags
		write_short(cs_get_user_deaths(Victim)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Victim)); // team
		message_end();
	}
}

public make_knockback(Victim, Float:origin[3], Float:maxspeed) {
	new Float:fVelocity[3];
	kickback(Victim, origin, maxspeed, fVelocity);
	entity_set_vector(Victim, EV_VEC_velocity, fVelocity);
	
	return(1);
}

stock kickback(ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3]) {
	new Float:fEntOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fEntOrigin);
	
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	new Float:fTime = (vector_distance(fEntOrigin,fOrigin) / fSpeed);
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;
	
	return(fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

public make_blood(id, Amount) {
	new BloodColor = ExecuteHam(Ham_BloodColor, id);
	if(is_user_alive(id) && BloodColor != -1) {
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
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
