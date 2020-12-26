#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "Ethereal"
#define VERSION "1.0"
#define AUTHOR "~DarkSiDeRS~"

new bool:HaveSpearGun[33], speargun_clip[33], speargun_reload[33], speargun_event, speargun_trail, speargun_explode;
new speargundamage, speargunradius, speargunknockback, speargunreloadtime;
new BloodSpray, BloodDrop;

new PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);

#define SPEARGUN_WEAPONKEY	98
#define weapon_speargun		"weapon_galil"
#define CSW_SPEARGUN		CSW_GALIL
#define SPEARGUN_CLASS		"oicw_grenade"
#define speargun_shotdelay	1.0 // Refire rate
new SpearGunModel_V[] = "models/[GeekGamers]/Primary/v_speargun.mdl";
new SpearGunModel_P[] = "models/[GeekGamers]/Primary/p_speargun.mdl";
new SpearGunModel_W[] = "models/[GeekGamers]/Primary/w_speargun.mdl";
new SpearGunModel_S[] = "models/[GeekGamers]/Primary/s_speargun.mdl";
new SpearGun_Sound[][] = {
	"weapons/speargun_shoot1.wav",
	"weapons/speargun_clipin.wav",
	"weapons/speargun_draw.wav"
};
new SpearGun_Generic[][] = {
	"sprites/weapon_speargun.txt",
	"sprites/[GeekGamers]/Weapons/SpearGun.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("furien30_speargun", "Hook_SpearGun");
	
	register_event("CurWeapon", "SpearGun_ViewModel", "be", "1=1");
	register_event("WeapPickup","SpearGun_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "SpearGun_WorldModel", 1);
	register_forward(FM_UpdateClientData, "SpearGun_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "SpearGun_PlaybackEvent");
	register_forward(FM_CmdStart, "SpearGun_CmdStart");
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_speargun, "SpearGun_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_speargun, "SpearGun_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_speargun, "SpearGun_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_speargun, "SpearGun_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_speargun, "SpearGun_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_speargun, "SpearGun_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_speargun, "SpearGun_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	register_touch(SPEARGUN_CLASS, "*", "SpearGun_Touch");
	
	speargundamage = register_cvar("furien30_speargun_damage", "100");		//| SpearGun Damage |//
	speargunreloadtime = register_cvar("furien30_speargun_reload_time", "1.8");	//| SpearGun Reload Time |//
	speargunradius = register_cvar("furien30_speargun_radius", "250.0");		//| SpearGun Bolt Radius |//
	speargunknockback = register_cvar("furien30_speargun_knockback", "3.0");	//| SpearGun Bolt Knockback |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "SpearGun_PrecacheEvent_Post", 1);
	
	speargun_trail = precache_model("sprites/xbeam3.spr");
	speargun_explode = precache_model("sprites/[GeekGamers]/Weapons/explode.spr");
	
	precache_model(SpearGunModel_V);
	precache_model(SpearGunModel_P);
	precache_model(SpearGunModel_W);
	precache_model(SpearGunModel_S);
	for(new i = 0; i < sizeof(SpearGun_Sound); i++)
		engfunc(EngFunc_PrecacheSound, SpearGun_Sound[i]);	
	for(new i = 0; i < sizeof(SpearGun_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, SpearGun_Generic[i]);
}

public plugin_natives() {
	register_native("gg_get_user_speargun", "get_user_speargun", 1);
	register_native("gg_set_user_speargun", "set_user_speargun", 1);
}

public HAM_Spawn_Post(id)
{
	HaveSpearGun[id] = false;
}

public SpearGun_ViewModel(id) {
	if(get_user_weapon(id) == CSW_SPEARGUN && get_user_speargun(id)) {
		set_pev(id, pev_viewmodel2, SpearGunModel_V);
		set_pev(id, pev_weaponmodel2, SpearGunModel_P);
	}
	return PLUGIN_CONTINUE
}

public SpearGun_WorldModel(entity, model[]) {
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new _SpearGun = find_ent_by_owner(-1, weapon_speargun, entity);
			
			if(get_user_speargun(Owner) && is_valid_ent(_SpearGun) && equal(model, "models/w_galil.mdl")) {
				entity_set_int(_SpearGun, EV_INT_impulse, SPEARGUN_WEAPONKEY);
				HaveSpearGun[Owner] = false;
				entity_set_model(entity, SpearGunModel_W);
			}
		}
	}
	return FMRES_IGNORED;
}

public SpearGun_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_SPEARGUN && get_user_speargun(id))	
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public SpearGun_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == speargun_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public SpearGun_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/galil.sc", name))
		speargun_event = get_orig_retval();
	return FMRES_IGNORED;
}

public SpearGun_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_SPEARGUN && get_user_speargun(id)) {
				static _SpearGun;
				_SpearGun = fm_find_ent_by_owner(-1, weapon_speargun, id);	
				
				if(pev_valid(_SpearGun) && cs_get_weapon_ammo(_SpearGun) > 0 && !speargun_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, 1);
					emit_sound(id, CHAN_WEAPON, SpearGun_Sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
					SpearGun_Fire(id);
					new Float:PunchAngle[3]
					PunchAngle[0] = random_float(-5.0, -7.0), PunchAngle[1] = 0.0, PunchAngle[0] = 0.0
					set_pev(id, pev_punchangle, PunchAngle);
					cs_set_weapon_ammo(_SpearGun, cs_get_weapon_ammo(_SpearGun) - 1);
					if(cs_get_weapon_ammo(_SpearGun) > 0 && !speargun_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, speargun_shotdelay, 5);
						set_pdata_float(_SpearGun, 48, 1.0, 4)
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
	return FMRES_IGNORED;
}

public SpearGun_AddToPlayer(Weapon, id) {
	if(pev_valid(Weapon) && is_user_alive(id) && entity_get_int(Weapon, EV_INT_impulse) == SPEARGUN_WEAPONKEY) {
		HaveSpearGun[id] = true;
		WeaponList(id, SPEARGUN_WEAPONKEY)
		entity_set_int(Weapon, EV_INT_impulse, 0);
	}
	return HAM_IGNORED;
}

public SpearGun_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_speargun(Owner)) {
			set_pev(Owner, pev_viewmodel2, SpearGunModel_V);
			set_pev(Owner, pev_weaponmodel2, SpearGunModel_P);
			set_weapon_anim(Owner, 3)
			
			set_pdata_float(Owner, 83, 1.2, 5);
			set_pdata_float(Weapon, 48, 1.2, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				speargun_reload[Owner] = 0;
		}
	}
	return HAM_IGNORED;
}

public SpearGun_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_speargun(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 1.7, 4)
			set_weapon_anim(Owner, 0)
		}
	}
	return HAM_IGNORED;
}

public SpearGun_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		if(is_user_alive(Owner) && get_user_speargun(Owner))
			return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public SpearGun_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_speargun(Owner)) {		
			speargun_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_SPEARGUN) <= 0 || get_pdata_int(Weapon, 51, 4) >= 1)
				return HAM_SUPERCEDE;
			
			speargun_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			speargun_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public SpearGun_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_speargun(Owner) && speargun_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, speargun_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(speargunreloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(speargunreloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 2)
		}
	}
	return HAM_IGNORED;
}

public SpearGun_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_speargun(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min(1 - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_SPEARGUN));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_SPEARGUN, cs_get_user_bpammo(Owner, CSW_SPEARGUN) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			speargun_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}

public SpearGun_Fire(id) {
	new Bolt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if(pev_valid(Bolt)) {
		new Float:Origin[3], Float:Angles[3], Float:Velocity[3];
		engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
		pev(id, pev_angles, Angles);
		
		set_pev(Bolt, pev_origin, Origin);
		set_pev(Bolt, pev_angles, Angles);
		set_pev(Bolt, pev_solid, SOLID_BBOX);
		set_pev(Bolt, pev_movetype, MOVETYPE_FLY);
		
		set_pev(Bolt, pev_classname, SPEARGUN_CLASS);		
		
		set_pev(Bolt, pev_owner, id);
		engfunc(EngFunc_SetModel, Bolt, SpearGunModel_S);
		
		set_pev(Bolt, pev_mins, {-1.0, -1.0, -1.0});
		set_pev(Bolt, pev_maxs, {1.0, 1.0, 1.0});
		
		velocity_by_aim(id, 2000, Velocity);
		set_pev(Bolt, pev_velocity, Velocity);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE id
		write_short(Bolt); // entity:attachment to follow
		write_short(speargun_trail); // sprite index
		write_byte(1); // life in 0.1's
		write_byte(1); // line width in 0.1's
		write_byte(255); // r
		write_byte(255); // g
		write_byte(255); // b
		write_byte(200); // brightness
		message_end();
	}
}

public SpearGun_Touch(Bolt, touch) {
	if(is_valid_ent(Bolt)) {
		static Float:BoltOrigin[3];
		pev(Bolt, pev_origin, BoltOrigin);	
		new id = pev(Bolt, pev_owner);
		
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, BoltOrigin[0]);
		engfunc(EngFunc_WriteCoord, BoltOrigin[1]);
		engfunc(EngFunc_WriteCoord, BoltOrigin[2]);
		write_short(speargun_explode);	// sprite index
		write_byte(20);			// scale in 0.1's
		write_byte(30);			// framerate
		write_byte(0);			// flags
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, BoltOrigin[0])
		engfunc(EngFunc_WriteCoord, BoltOrigin[1])
		engfunc(EngFunc_WriteCoord, BoltOrigin[2])
		write_byte(random_num(46, 48))
		message_end()	
		
		static ClassName[32];
		pev(touch, pev_classname, ClassName, charsmax(ClassName));
		if(equal(ClassName, "player") && is_user_connected(touch) && is_user_alive(touch)) {
			if(!fm_get_user_godmode(touch) && get_user_team(touch) != get_user_team(id) && touch != id) {
				new Float:Damage = get_pcvar_float(speargundamage);			
				//make_blood(touch, get_pcvar_num(speargundamage))
				make_knockback(touch, BoltOrigin, get_pcvar_float(speargunknockback) * Damage);	
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BLAST);
				else
					death_message(id, touch, "SpearGun");
				
			}
		}
		else if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(touch, EV_FL_health) <= get_pcvar_num(speargundamage))
				force_use(id, touch);
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(BoltOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				if(Distance <= get_pcvar_float(speargunradius)) {								
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(speargunradius));
					Damage = get_pcvar_float(speargundamage) - floatround(floatmul(get_pcvar_float(speargundamage), DistanceRatio));
					//make_blood(Victim, floatround(Damage))
					make_knockback(Victim, BoltOrigin, get_pcvar_float(speargunknockback)*Damage);	
					if(get_user_health(Victim) - Damage >= 1)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					else		
						death_message(id, Victim, "SpearGun");
				}
			}
		}
		engfunc(EngFunc_RemoveEntity, Bolt);
	}
}

public Hook_SpearGun(id) {
	engclient_cmd(id, weapon_speargun);
	return PLUGIN_HANDLED
}

public get_user_speargun(id)
	return HaveSpearGun[id];

public set_user_speargun(id, speargun)
{
	drop_primary_weapons(id);
	HaveSpearGun[id] = true;
	speargun_reload[id] = 0;
			
	WeaponList(id, SPEARGUN_WEAPONKEY)
	fm_give_item(id, weapon_speargun);
			
	new Clip = fm_get_user_weapon_entity(id, CSW_SPEARGUN);
	cs_set_weapon_ammo(Clip, 1);
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

public WeaponList(id, WEAPONKEY)
{
	new Message_WeaponList = get_user_msgid("WeaponList")

	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(HaveSpearGun[id] ? "furien30_speargun" : "weapon_galil");		// WeaponName
	write_byte(4);				// PrimaryAmmoID
	write_byte(90);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(17);				// NumberInSlot (1...N)
	write_byte(CSW_SPEARGUN);			// WeaponID
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
