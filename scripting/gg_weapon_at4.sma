#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "AT4"
#define VERSION "1.0"
#define AUTHOR "~DarkSiDeRS~"

new PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);

new bool:HaveAT4[33], at4_clip[33], at4_reload[33], at4_detector[33], at4_event, at4_smoke, at4_trail, at4_explode;
new at4damage, at4radius, at4knockback, at4reloadtime;
new BloodSpray, BloodDrop;

#define AT4_WEAPONKEY		100
#define weapon_at4		"weapon_m249"
#define CSW_AT4			CSW_M249
#define AT4_CLASS		"at4ex_rocket"
#define AT4_CLASS_LASERDOT	"at4_laserdot"
#define at4_shotdelay		4.0 // Refire rate
new AT4Model_V[] = "models/[GeekGamers]/Primary/v_at4.mdl";
new AT4Model_P[] = "models/[GeekGamers]/Primary/p_at4.mdl";
new AT4Model_W[] = "models/[GeekGamers]/Primary/w_at4.mdl";
new AT4Model_S[] = "models/[GeekGamers]/Primary/s_at4rocket.mdl";
new AT4Model_LASER[] = "sprites/laserdot.spr";
new AT4_Sound[][] = {
	"weapons/at4_shoot1.wav",
	"weapons/at4_clipin1.wav",
	"weapons/at4_clipin2.wav",
	"weapons/at4_clipin3.wav",
	"weapons/at4_draw.wav"
};
new AT4_Generic[][] = {
	"sprites/gg_weapon_at4.txt",
	"sprites/[GeekGamers]/Weapons/At4.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_at4", "Hook_AT4");
	
	register_event("CurWeapon", "AT4_ViewModel", "be", "1=1");
	register_event("WeapPickup","AT4_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "AT4_WorldModel", 1);
	register_forward(FM_UpdateClientData, "AT4_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "AT4_PlaybackEvent");
	register_forward(FM_PlayerPreThink, "AT4_PreThink");
	register_forward(FM_CmdStart, "AT4_CmdStart");	
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_at4, "AT4_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_at4, "AT4_Deploy_Post", 1);
	RegisterHam(Ham_Item_Holster , weapon_at4, "AT4_Holster");
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_at4, "AT4_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_at4, "AT4_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_at4, "AT4_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_at4, "AT4_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_at4, "AT4_PostFrame");
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	
	register_think(AT4_CLASS, "AT4_Think");
	register_think(AT4_CLASS_LASERDOT, "AT4_LaserDot_Think");
	
	register_touch(AT4_CLASS, "*", "AT4_Touch");
	
	at4damage = register_cvar("furien30_at4_damage", "120.0");		//| AT4 Damage |//
	at4radius = register_cvar("furien30_at4_radius", "220.0");		//| AT4 Radius |//
	at4knockback = register_cvar("furien30_at4_knockback", "4.0");		//| At4 KnockBack |//
	at4reloadtime = register_cvar("furien30_at4_reload_time", "3.33");	//| AT4 Reload Time |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "AT4_PrecacheEvent_Post", 1);

	at4_smoke = precache_model("sprites/effects/rainsplash.spr");
	at4_trail = precache_model("sprites/xbeam3.spr");
	at4_explode = precache_model("sprites/[GeekGamers]/Weapons/explode.spr");
	
	precache_model(AT4Model_V);
	precache_model(AT4Model_P);
	precache_model(AT4Model_W);
	precache_model(AT4Model_S);
	precache_model(AT4Model_LASER);
	
	for(new i = 0; i < sizeof(AT4_Sound); i++)
		engfunc(EngFunc_PrecacheSound, AT4_Sound[i]);	
	for(new i = 0; i < sizeof(AT4_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, AT4_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_at4", "get_user_at4", 1);
	register_native("gg_set_user_at4", "set_user_at4", 1);
}

public PlayerSpawn(id)
{
	HaveAT4[id] = false;
}

public AT4_ViewModel(id) {
	if(get_user_weapon(id) == CSW_AT4 && get_user_at4(id)) {
		set_pev(id, pev_viewmodel2, AT4Model_V);
		set_pev(id, pev_weaponmodel2, AT4Model_P);
		set_pdata_int(id, 361, get_pdata_int(id, 361) | (1<<6));
	}
	return PLUGIN_CONTINUE
}

public AT4_WorldModel(entity, model[]) {
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new _AT4 = find_ent_by_owner(-1, weapon_at4, entity);
			
			if(get_user_at4(Owner) && is_valid_ent(_AT4) && equal(model, "models/w_m249.mdl")) {
				entity_set_int(_AT4, EV_INT_impulse, AT4_WEAPONKEY);
				HaveAT4[Owner] = false;
				entity_set_model(entity, AT4Model_W);
				set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
				new Laser = find_ent_by_owner(-1, AT4_CLASS_LASERDOT, Owner);
				if(is_valid_ent(Laser))
					remove_entity(Laser);
			}
		}
	}
	return FMRES_IGNORED;
}

public AT4_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_AT4 && get_user_at4(id))
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public AT4_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == at4_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public AT4_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/m249.sc", name))
		at4_event = get_orig_retval();
	return FMRES_IGNORED;
}

public AT4_PreThink(id) {
	if(is_user_alive(id) && is_user_connected(id)) {
		if(get_user_weapon(id) == CSW_AT4 && get_user_at4(id) && at4_detector[id]) {
			new Float: origin[3];
			fm_get_aim_origin(id,origin);
			new Laser = find_ent_by_owner(-1, AT4_CLASS_LASERDOT, id);
			
			if(!is_valid_ent(Laser)) {
				new at4_laser = create_entity("info_target");	
				set_pev(at4_laser, pev_classname, AT4_CLASS_LASERDOT);
				set_pev(at4_laser, pev_owner, id);
				engfunc(EngFunc_SetModel, at4_laser, AT4Model_LASER);
				set_pev(at4_laser, pev_renderfx, kRenderFxNoDissipation);
				set_pev(at4_laser, pev_rendermode, kRenderGlow);
				set_pev(at4_laser, pev_renderamt, 255.0);
				set_pev(at4_laser, pev_light_level, 255.0);
				set_pev(at4_laser, pev_scale, 1.0);
				set_pev(at4_laser, pev_movetype, MOVETYPE_FLY);
				set_pev(at4_laser, pev_nextthink, halflife_time() + 0.001);
			}
		}
		else {
			new Laser = find_ent_by_owner(-1, AT4_CLASS_LASERDOT, id);
			if(is_valid_ent(Laser))
				remove_entity(Laser);
		}
	}
}

public AT4_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		static _AT4;
		_AT4 = fm_find_ent_by_owner(-1, weapon_at4, id);	
		
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_AT4 && get_user_at4(id)) {
				if(is_valid_ent(_AT4) && cs_get_weapon_ammo(_AT4) > 0 && !at4_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, 1);
					emit_sound(id, CHAN_WEAPON, AT4_Sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM);

					AT4_Fire(id);

					new Float:PunchAngles[3];
					PunchAngles[0] = random_float(-7.0, -10.0);
					PunchAngles[1] = 0.0;
					PunchAngles[2] = 0.0;
					
					set_pev(id, pev_punchangle, PunchAngles);
					cs_set_weapon_ammo(_AT4, cs_get_weapon_ammo(_AT4) - 1);
					if(cs_get_weapon_ammo(_AT4) > 0 && !at4_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, at4_shotdelay, 5);
						set_pdata_float(_AT4, 48, 0.3, 4)
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
		
		if(CurButton & IN_ATTACK2 && !(pev(id, pev_oldbuttons) & IN_ATTACK2)) {
			if(is_valid_ent(_AT4) && get_user_weapon(id) == CSW_AT4 && get_user_at4(id) && NextAttack <= 0.0) {
				if(at4_detector[id])
					at4_detector[id] = false;
				else
					at4_detector[id] = true;
			}
		}
	}
	return FMRES_IGNORED;
}

public AT4_AddToPlayer(Weapon, id) {
	if(is_valid_ent(Weapon) && is_user_connected(id) && entity_get_int(Weapon, EV_INT_impulse) == AT4_WEAPONKEY) {
		HaveAT4[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
		WeaponList(id)
	}
	return HAM_IGNORED;
}

public AT4_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner)) {
			set_pev(Owner, pev_viewmodel2, AT4Model_V);
			set_pev(Owner, pev_weaponmodel2, AT4Model_P);
			set_weapon_anim(Owner, 4)
			
			set_pdata_float(Owner, 83, 1.2, 5);
			set_pdata_float(Weapon, 48, 1.2, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				at4_reload[Owner] = 0;
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) | (1<<6));
		}
	}
	return HAM_IGNORED;
}

public AT4_Holster(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner))
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
	}
	return HAM_IGNORED;
}

public AT4_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 4.0, 4)
			set_weapon_anim(Owner, 0)
		}
	}
	return HAM_IGNORED;
}

public AT4_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		if(is_user_alive(Owner) && get_user_at4(Owner))
			return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public AT4_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner)) {		
			at4_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_AT4) <= 0 || get_pdata_int(Weapon, 51, 4) >= 1)
				return HAM_SUPERCEDE;
			
			at4_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			at4_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public AT4_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner) && at4_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, at4_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(at4reloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(at4reloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 3)
		}
	}
	return HAM_IGNORED;
}

public AT4_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_at4(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min(1 - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_AT4));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_AT4, cs_get_user_bpammo(Owner, CSW_AT4) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			at4_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}

public AT4_Fire(id) {
	new Rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if(is_valid_ent(Rocket)) {
		new Float:Origin[3], Float:Angles[3], Float:Velocity[3];
		engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
		pev(id, pev_angles, Angles);
		
		set_pev(Rocket, pev_origin, Origin);
		set_pev(Rocket, pev_angles, Angles);
		set_pev(Rocket, pev_solid, SOLID_BBOX);
		set_pev(Rocket, pev_movetype, MOVETYPE_FLY);
		set_pev(Rocket, pev_classname, AT4_CLASS);
		
		if(at4_detector[id])
			set_pev(Rocket, pev_iuser3, 1);		
		else
			set_pev(Rocket, pev_iuser3, 0);		
		
		set_pev(Rocket, pev_owner, id);
		engfunc(EngFunc_SetModel, Rocket, AT4Model_S);
		
		set_pev(Rocket, pev_mins, {-3.0, -3.0, -3.0});
		set_pev(Rocket, pev_maxs, {3.0, 3.0, 3.0});
		
		velocity_by_aim(id, 2000, Velocity);
		set_pev(Rocket, pev_velocity, Velocity);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE id
		write_short(Rocket); // entity:attachment to follow
		write_short(at4_trail); // sprite index
		write_byte(3); // life in 0.1's
		write_byte(2); // line width in 0.1's
		write_byte(255); // r
		write_byte(255); // g
		write_byte(255); // b
		write_byte(200); // brightness
		message_end();
	}
	
	set_pev(Rocket, pev_iuser4, 0);		
	set_pev(Rocket, pev_nextthink, halflife_time() + 0.1);
}

public AT4_Think(Rocket) {
	if(is_valid_ent(Rocket)) {
		static Float:Origin[3];
		pev(Rocket, pev_origin, Origin);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITE);
		engfunc(EngFunc_WriteCoord, Origin[0]);
		engfunc(EngFunc_WriteCoord, Origin[1]);
		engfunc(EngFunc_WriteCoord, Origin[2]);
		write_short(at4_smoke);
		write_byte(2);
		write_byte(200);
		message_end();
		if(pev(Rocket, pev_iuser3) == 1) {
			if(pev(Rocket, pev_iuser4) == 0) {
				static Victim;
				Victim = FindClosesEnemy(Rocket);
				
				if(is_user_alive(Victim))
					set_pev(Rocket, pev_iuser4, Victim);
			}
			else {
				static Victim;
				Victim = pev(Rocket, pev_iuser4);
				
				if(is_user_alive(Victim)) {
					static Float:VicOrigin[3];
					pev(Victim, pev_origin, VicOrigin);
					
					hook_ent(Rocket, Victim, 2000.0);
				}
				else
					set_pev(Rocket, pev_iuser4, 0);
			} 
		}
		set_pev(Rocket, pev_nextthink, halflife_time() + 0.075);
	}
}

public AT4_LaserDot_Think(LaserDot) { 
	if(is_valid_ent(LaserDot)) {
		new Owner, Float:Origin[3];
		Owner = pev(LaserDot, pev_owner);
		pev(Owner, pev_origin, Origin);
		fm_get_aim_origin(Owner, Origin);
		
		set_pev(LaserDot, pev_origin, Origin);
		set_pev(LaserDot, pev_nextthink, halflife_time() + 0.001);
	}
}

public AT4_Touch(Rocket, touch) {
	if(is_valid_ent(Rocket)) {
		new Float:RocketOrigin[3];
		pev(Rocket, pev_origin, RocketOrigin);	
		new id = pev(Rocket, pev_owner);
		
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, RocketOrigin[0]);
		engfunc(EngFunc_WriteCoord, RocketOrigin[1]);
		engfunc(EngFunc_WriteCoord, RocketOrigin[2]);
		write_short(at4_explode);	// sprite index
		write_byte(40);			// scale in 0.1's
		write_byte(30);			// framerate
		write_byte(0);			// flags
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, RocketOrigin[0])
		engfunc(EngFunc_WriteCoord, RocketOrigin[1])
		engfunc(EngFunc_WriteCoord, RocketOrigin[2])
		write_byte(random_num(46, 48))
		message_end()	
		
		static ClassName[32];
		pev(touch, pev_classname, ClassName, charsmax(ClassName));
		if(equal(ClassName, "player") && is_user_connected(touch) && is_user_alive(touch)) {
			if(!fm_get_user_godmode(touch) && get_user_team(touch) != get_user_team(id) && touch != id) {
				new Float:Damage
				pev(Rocket, pev_iuser3) == 1 ? (Damage = (get_pcvar_float(at4damage) / 2.0)) : (Damage = get_pcvar_float(at4damage))
				//make_blood(touch, get_pcvar_num(at4damage))
				make_knockback(touch, RocketOrigin, get_pcvar_float(at4knockback) * Damage);	
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BLAST);
				else		
					death_message(id, touch, "AT4");
			}	
		}
		else if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(touch, EV_FL_health) <= get_pcvar_num(at4damage))
				force_use(id, touch);
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(RocketOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				if(Distance <= get_pcvar_float(at4radius)) {								
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(at4radius));
					Damage = get_pcvar_float(at4damage) - floatround(floatmul(get_pcvar_float(at4damage), DistanceRatio));
					//make_blood(Victim, get_pcvar_num(at4damage))
					make_knockback(Victim, RocketOrigin, get_pcvar_float(at4knockback)*Damage);	
					if(get_user_health(Victim) - Damage >= 1)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					else		
						death_message(id, Victim, "AT4");
				}
			}
		}		
		engfunc(EngFunc_RemoveEntity, Rocket);
	}
}

public Hook_AT4(id) {
	engclient_cmd(id, weapon_at4);
	return PLUGIN_HANDLED
}

public get_user_at4(id)
	return HaveAT4[id];

public set_user_at4(id, at4)
{
	//drop_primary_weapons(id);
	HaveAT4[id] = true;
	at4_reload[id] = false;
			
	WeaponList(id)
	fm_give_item(id, weapon_at4);
			
	new Clip = fm_get_user_weapon_entity(id, CSW_AT4);
	cs_set_weapon_ammo(Clip, 1);
}

stock FindClosesEnemy(entid) {
	new Float:Dist;
	new Float:maxdistance=300.0;
	new indexid=0;
	for(new i=1;i<=get_maxplayers();i++){
		if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i)
		&& pev(entid, pev_owner) != i && cs_get_user_team(pev(entid, pev_owner)) != cs_get_user_team(i)) {
			Dist = entity_range(entid, i);
			if(Dist <= maxdistance) {
				maxdistance=Dist;
				indexid=i;
				
				return indexid;
			}
		}	
	}	
	return 0;
}
stock bool:can_see_fm(entindex1, entindex2) {
	if(!entindex1 || !entindex2)
		return false;
	
	if(pev_valid(entindex1) && pev_valid(entindex1)) {
		new flags = pev(entindex1, pev_flags);
		if(flags & EF_NODRAW || flags & FL_NOTARGET) {
			return false;
		}
		
		new Float:lookerOrig[3];
		new Float:targetBaseOrig[3];
		new Float:targetOrig[3];
		new Float:temp[3];
		
		pev(entindex1, pev_origin, lookerOrig);
		pev(entindex1, pev_view_ofs, temp);
		lookerOrig[0] += temp[0];
		lookerOrig[1] += temp[1];
		lookerOrig[2] += temp[2];
		
		pev(entindex2, pev_origin, targetBaseOrig);
		pev(entindex2, pev_view_ofs, temp);
		targetOrig[0] = targetBaseOrig[0] + temp[0];
		targetOrig[1] = targetBaseOrig[1] + temp[1];
		targetOrig[2] = targetBaseOrig[2] + temp[2];
		
		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0); //  checks the had of seen player
		if(get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater)) {
			return false;
		} 
		else {
			new Float:flFraction;
			get_tr2(0, TraceResult:TR_flFraction, flFraction);
			if(flFraction == 1.0 ||(get_tr2(0, TraceResult:TR_pHit) == entindex2)) {
				return true;
			}
			else {
				targetOrig[0] = targetBaseOrig[0];
				targetOrig[1] = targetBaseOrig[1];
				targetOrig[2] = targetBaseOrig[2];
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0); //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction);
				if(flFraction == 1.0 ||(get_tr2(0, TraceResult:TR_pHit) == entindex2)) {
					return true;
				}
				else {
					targetOrig[0] = targetBaseOrig[0];
					targetOrig[1] = targetBaseOrig[1];
					targetOrig[2] = targetBaseOrig[2] - 17.0;
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0); //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction);
					if(flFraction == 1.0 ||(get_tr2(0, TraceResult:TR_pHit) == entindex2)) {
						return true;
					}
				}
			}
		}
	}
	return false;
}
stock hook_ent(ent, victim, Float:speed) {
	static Float:fl_Velocity[3];
	static Float:VicOrigin[3], Float:EntOrigin[3];
	
	pev(ent, pev_origin, EntOrigin);
	pev(victim, pev_origin, VicOrigin);
	
	static Float:distance_f;
	distance_f = get_distance_f(EntOrigin, VicOrigin);
	
	if(distance_f > 10.0) {
		new Float:fl_Time = distance_f / speed;
		
		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time;
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time;
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time;
	}
	else {
		fl_Velocity[0] = 0.0;
		fl_Velocity[1] = 0.0;
		fl_Velocity[2] = 0.0;
	}
	
	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity);
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

stock set_weapon_anim(id, anim) {
	set_pev(id, pev_weaponanim, anim);
	if(is_user_connected(id)) {
		message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
		write_byte(anim);
		write_byte(pev(id, pev_body));
		message_end();
	}
}

stock get_damage_body(body, Float:damage) {
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
		default: 
		damage *= 1.0;
	}
	
	return floatround(damage);
}

public WeaponList(id)
{
	new Message_WeaponList = get_user_msgid("WeaponList")

	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(HaveAT4[id] ? "gg_weapon_at4" : "weapon_m249");			// WeaponName
	write_byte(3);				// PrimaryAmmoID
	write_byte(200);			// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(4);				// NumberInSlot (1...N)
	write_byte(CSW_AT4);		// WeaponID
	write_byte(0);				// Flags
	message_end();
}

stock drop_primary_weapons(Player) {
	static weapons[32], num, i, weaponid;
	num = 0;
	get_user_weapons(Player, weapons, num);
	
	for(i = 0; i < num; i++) {
		weaponid = weapons [i];
		
		if(((1<<weaponid) & PRIMARY_WEAPONS_BITSUM)) {
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			engclient_cmd(Player, "drop", wname);
		}
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
