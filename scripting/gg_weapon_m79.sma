#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "M79"
#define VERSION "1.0"
#define AUTHOR "~DarkSiDeRs~"

new bool:HaveM79[33], m79_clip[33], m79_reload[33], m79_event, m79_trail, m79_explode;
new m79damage, m79radius, m79knockback, m79reloadtime;
new BloodSpray, BloodDrop;

new SECONDARY_WEAPONS_BITSUM = (1<<CSW_GLOCK18)|(1<<CSW_USP)|(1<<CSW_P228)|(1<<CSW_DEAGLE)|(1<<CSW_FIVESEVEN)|(1<<CSW_ELITE);

#define M79_WEAPONKEY	200
#define M79_CLASS	"m79_grenade"
#define weapon_m79	"weapon_deagle"
#define CSW_M79		CSW_DEAGLE
#define m79_shotdelay	3.0 // Refire rate
new M79Model_V[] = "models/[GeekGamers]/Secondary/v_m79.mdl";
new M79Model_P[] = "models/[GeekGamers]/Secondary/p_m79.mdl";
new M79Model_W[] = "models/[GeekGamers]/Secondary/w_m79.mdl";
new M79Model_S[] = "models/[GeekGamers]/Secondary/s_m79grenade.mdl";
new M79_Sound[][] = {
	"weapons/m79_shoot1.wav",
	//"weapons/m79_shoot2.wav",
	"weapons/m79_clipin.wav",
	"weapons/m79_clipon.wav",
	"weapons/m79_clipout.wav"
};
new M79_Generic[][] = {
	"sprites/gg_weapon_m79.txt",
	"sprites/[GeekGamers]/Weapons/M79.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_m79", "Hook_M79");
	
	register_event("CurWeapon", "M79_ViewModel", "be", "1=1");
	register_event("WeapPickup","M79_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "M79_WorldModel");
	register_forward(FM_UpdateClientData, "M79_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "M79_PlaybackEvent");
	register_forward(FM_CmdStart, "M79_CmdStart");	
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_m79, "M79_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_m79, "M79_Deploy_Post", 1);
	RegisterHam(Ham_Item_Holster , weapon_m79, "M79_Holster");
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_m79, "M79_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_m79, "M79_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_m79, "M79_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_m79, "M79_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_m79, "M79_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	register_touch(M79_CLASS, "*", "M79_Touch");
	
	m79damage = register_cvar("furien30_m79_damage", "75");			//| M79 Damage |//
	m79radius = register_cvar("furien30_m79_radius", "220.0");		//| M79 Recoil |//
	m79knockback = register_cvar("furien30_m79_knockback" ,"2.0");		//| M79 KnockBack |//
	m79reloadtime = register_cvar("furien30_m79_reload_time", "2.8");	//| M79 Reload Time |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "M79_PrecacheEvent_Post", 1);
	
	m79_trail = precache_model("sprites/xbeam3.spr");
	m79_explode = precache_model("sprites/[GeekGamers]/Weapons/explode.spr");
	
	precache_model(M79Model_V);
	precache_model(M79Model_P);
	precache_model(M79Model_W);
	precache_model(M79Model_S);
	for(new i = 0; i < sizeof(M79_Sound); i++)
		engfunc(EngFunc_PrecacheSound, M79_Sound[i]);	
	for(new i = 0; i < sizeof(M79_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, M79_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_m79", "get_user_m79", 1);
	register_native("gg_set_user_m79", "set_user_m79", 1);
}

public HAM_Spawn_Post(id)
{
	HaveM79[id] = false;
}

public M79_ViewModel(id) {
	if(get_user_weapon(id) == CSW_M79 && get_user_m79(id)) {
		set_pev(id, pev_viewmodel2, M79Model_V);
		set_pev(id, pev_weaponmodel2, M79Model_P);
	}
}

public M79_WorldModel(entity, model[]) {
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	
	static ClassName[33];
	entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
	
	if(!equal(ClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	new Owner = entity_get_edict(entity, EV_ENT_owner);	
	new _M79 = find_ent_by_owner(-1, weapon_m79, entity);
	
	if(get_user_m79(Owner) && is_valid_ent(_M79) && equal(model, "models/w_deagle.mdl")) {
		entity_set_int(_M79, EV_INT_impulse, M79_WEAPONKEY);
		HaveM79[Owner] = false;
		set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
		entity_set_model(entity, M79Model_W);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public M79_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id)) {
		if(get_user_weapon(id) == CSW_M79 && get_user_m79(id))	
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	}
}

public M79_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(!is_user_connected(invoker))
		return FMRES_IGNORED;
	if(eventid != m79_event)
		return FMRES_IGNORED;
	
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	
	return FMRES_SUPERCEDE;
}

public M79_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/deagle.sc", name)) {
		m79_event = get_orig_retval();
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public M79_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		static _M79;
		_M79 = fm_find_ent_by_owner(-1, weapon_m79, id);	
		
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_M79 && get_user_m79(id)) {
				if(cs_get_weapon_ammo(_M79) > 0 && !m79_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, 7);
					emit_sound(id, CHAN_WEAPON, M79_Sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
					M79_Fire(id);
					new Float:PunchAngle[3]
					PunchAngle[0] = random_float(-3.0, -5.0), PunchAngle[1] = 0.0, PunchAngle[0] = 0.0
					set_pev(id, pev_punchangle, PunchAngle);
					
					cs_set_weapon_ammo(_M79, cs_get_weapon_ammo(_M79) - 1);
					
					if(cs_get_weapon_ammo(_M79) > 0 && !m79_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, m79_shotdelay, 5);
						set_pdata_float(_M79, 48, 2.8, 4)
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
}

public M79_AddToPlayer(Weapon, id) {
	if(pev_valid(Weapon) && is_user_alive(id) && entity_get_int(Weapon, EV_INT_impulse) == M79_WEAPONKEY) {
		HaveM79[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
		WeaponList(id)
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public M79_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner)) {
			set_pev(Owner, pev_viewmodel2, M79Model_V);
			set_pev(Owner, pev_weaponmodel2, M79Model_P);
			
			set_weapon_anim(Owner, 6);
			
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) | (1<<6));
			set_pdata_float(Owner, 83, 1.0, 5);
			set_pdata_float(Weapon, 48, 1.0, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				m79_reload[Owner] = 0;
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public M79_Holster(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner))
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
	}
	return HAM_IGNORED;
}

public M79_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 0.125, 4)
			set_weapon_anim(Owner, 0)
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public M79_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner))
			return HAM_SUPERCEDE
	}
	return HAM_IGNORED;
}

public M79_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner)) {
			m79_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_M79) <= 0 || get_pdata_int(Weapon, 51, 4) >= 1)
				return HAM_SUPERCEDE;
			
			m79_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			m79_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public M79_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner) && m79_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, m79_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(m79reloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(m79reloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 7)
		}
	}
	return HAM_IGNORED;
}

public M79_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_m79(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min(1 - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_M79));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_M79, cs_get_user_bpammo(Owner, CSW_M79) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			m79_reload[Owner] = false;		
		}			
	}
	return HAM_IGNORED;
}

public M79_Fire(id) {
	new Grenade, Float:Origin[3], Float:Angles[3], Float:Velocity[3];
	
	Grenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
	pev(id, pev_angles, Angles);
	
	set_pev(Grenade, pev_origin, Origin);
	set_pev(Grenade, pev_angles, Angles);
	set_pev(Grenade, pev_solid, SOLID_SLIDEBOX);
	set_pev(Grenade, pev_movetype, MOVETYPE_BOUNCE);
	
	set_pev(Grenade, pev_classname, M79_CLASS);
	
	set_pev(Grenade, pev_owner, id);
	engfunc(EngFunc_SetModel, Grenade, M79Model_S);
	
	set_pev(Grenade, pev_mins, {-1.0, -1.0, -1.0});
	set_pev(Grenade, pev_maxs, {1.0, 1.0, 1.0});
	
	velocity_by_aim(id, 2000, Velocity);
	set_pev(Grenade, pev_velocity, Velocity);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW); // TE id
	write_short(Grenade); // entity:attachment to follow
	write_short(m79_trail); // sprite index
	write_byte(1); // life in 0.1's
	write_byte(1); // line width in 0.1's
	write_byte(255); // r
	write_byte(255); // g
	write_byte(255); // b
	write_byte(200); // brightness
	message_end();
}

public M79_Touch(Grenade, touch) {
	if(pev_valid(Grenade)) {
		static Float:GrenadeOrigin[3];
		pev(Grenade, pev_origin, GrenadeOrigin);
		new id = pev(Grenade, pev_owner);
		
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[0]);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[1]);
		engfunc(EngFunc_WriteCoord, GrenadeOrigin[2]);
		write_short(m79_explode);	// sprite index
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
		
		if(is_user_connected(touch) && is_user_alive(touch)) {
			if(!fm_get_user_godmode(touch) && get_user_team(touch) != get_user_team(id) && touch != id) {
				new Float:Damage = get_pcvar_float(m79damage);
				//make_blood(touch, get_pcvar_num(m79damage))
				make_knockback(touch, GrenadeOrigin, get_pcvar_float(m79knockback) * Damage);	
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BLAST);
				else			
					death_message(id, touch, "M79");			
			}
		}
		else {
			static ClassName[32];
			pev(touch, pev_classname, ClassName, charsmax(ClassName));
			if(equal(ClassName, "func_breakable")) {		
				if(entity_get_float(touch, EV_FL_health) <= get_pcvar_num(m79damage))
					force_use(id, touch);
			}
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(GrenadeOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				if(Distance <= get_pcvar_float(m79radius)) {								
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(m79radius));
					Damage = get_pcvar_float(m79damage) - floatround(floatmul(get_pcvar_float(m79damage), DistanceRatio));
					
					//make_blood(Victim, floatround(Damage));
					make_knockback(Victim, GrenadeOrigin, get_pcvar_float(m79knockback)*Damage);	
					if(get_user_health(Victim) > Damage)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					else		
						death_message(id, Victim, "M79");
				}
			}
		}
		engfunc(EngFunc_RemoveEntity, Grenade);
	}
}

public Hook_M79(id) {
	engclient_cmd(id, weapon_m79);
	return PLUGIN_HANDLED
}

public get_user_m79(id)
	return HaveM79[id];

public set_user_m79(id, m79)
{
	// drop_secondary_weapons(id);
	HaveM79[id] = true;
	m79_reload[id] = false;
			
	fm_give_item(id, weapon_m79);
	WeaponList(id)
			
	new Weapon = fm_get_user_weapon_entity(id, CSW_M79);
	cs_set_weapon_ammo(Weapon, 1);
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
	write_string(HaveM79[id] ? "gg_weapon_m79" : "weapon_deagle");		// WeaponName
	write_byte(8);				// PrimaryAmmoID
	write_byte(35);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(1);				// SlotID (0...N)
	write_byte(1);				// NumberInSlot (1...N)
	write_byte(CSW_M79);		// WeaponID
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
