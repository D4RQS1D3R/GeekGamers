#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "CrossBow"
#define VERSION "1.0"
#define AUTHOR "~DarkSiDeRs~"

new PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);

new bool:HaveCrossBow[33], crossbow_clip[33], crossbow_reload[33], crossbow_event, crossbow_trail, crossbow_explode;
new crossbowdamage, crossbowclip, crossbowreloadtime, crossbowradius, crossbowknockback;	
new BloodSpray, BloodDrop;

#define CROSSBOW_WEAPONKEY	102
#define weapon_crossbow		"weapon_sg552"
#define CSW_CROSSBOW		CSW_SG552
#define CROSSBOW_CLASS		"crossbow_bolt"
#define crossbow_shotdelay	1.0 // Refire rate
new CrossBowModel_V[] = "models/[GeekGamers]/Primary/v_crossbow.mdl";
new CrossBowModel_P[] = "models/[GeekGamers]/Primary/p_crossbow.mdl";
new CrossBowModel_W[] = "models/[GeekGamers]/Primary/w_crossbow.mdl";
new CrossBowModel_S[] = "models/[GeekGamers]/Primary/s_crossbowbolt.mdl";
new CrossBow_Sound[][] = {
	"weapons/crossbow_shoot1.wav",
	"weapons/crbow_fl4.wav",
	"weapons/crbow_fl111.wav",
	"weapons/crbow_foley2.wav",
	"weapons/crbow_foley33.wav",
	"weapons/crbow_drw.wav"	
};
new CrossBow_Generic[][] = {
	"sprites/gg_weapon_crossbow.txt",
	"sprites/[GeekGamers]/Weapons/Crossbow.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_crossbow", "Hook_CrossBow");
	
	register_event("CurWeapon", "CrossBow_ViewModel", "be", "1=1");
	register_event("WeapPickup","CrossBow_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "CrossBow_WorldModel", 1);
	register_forward(FM_UpdateClientData, "CrossBow_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "CrossBow_PlaybackEvent");
	register_forward(FM_CmdStart, "CrossBow_CmdStart");	
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_crossbow, "CrossBow_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_crossbow, "CrossBow_Deploy_Post", 1);
	RegisterHam(Ham_Item_Holster , weapon_crossbow, "CrossBow_Holster");
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_crossbow, "CrossBow_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_crossbow, "CrossBow_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_crossbow, "CrossBow_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_crossbow, "CrossBow_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_crossbow, "CrossBow_PostFrame");
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	
	register_touch(CROSSBOW_CLASS, "*", "CrossBow_Touch");
	
	crossbowdamage = register_cvar("furien30_crossbow_damage", "99");				//| CrossBow Damage |//
	crossbowclip = register_cvar("furien30_crossbow_clip", "10");					//| CrossBow Clip |//
	crossbowreloadtime = register_cvar("furien30_crossbow_reload_time", "3.33");	//| CrossBow Reload Time |//
	crossbowradius = register_cvar("furien30_crossbow_radius", "200");				//| CrossBow Radius |//
	crossbowknockback = register_cvar("furien30_crossbow_knockback", "2.0");		//| CrossBow KnockBack |//

	// register_clcmd("say /cross", "set_user_crossbow");
}

public plugin_precache() {
	register_forward(FM_PrecacheEvent, "CrossBow_PrecacheEvent_Post", 1);
	
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	crossbow_trail = precache_model("sprites/xbeam3.spr");
	crossbow_explode = precache_model("sprites/[GeekGamers]/Weapons/explode.spr");
	
	precache_model(CrossBowModel_V);
	precache_model(CrossBowModel_P);
	precache_model(CrossBowModel_W);
	precache_model(CrossBowModel_S);
	for(new i = 0; i < sizeof(CrossBow_Sound); i++)
		engfunc(EngFunc_PrecacheSound, CrossBow_Sound[i]);	
	for(new i = 0; i < sizeof(CrossBow_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, CrossBow_Generic[i]);
}

public plugin_natives() {
	register_native("gg_get_user_crossbow", "get_user_crossbow", 1);
	register_native("gg_set_user_crossbow", "set_user_crossbow", 1);
}

public PlayerSpawn(id)
{
	HaveCrossBow[id] = false;
}

public CrossBow_ViewModel(id) {
	if(get_user_weapon(id) == CSW_CROSSBOW && get_user_crossbow(id)) {
		set_pev(id, pev_viewmodel2, CrossBowModel_V);
		set_pev(id, pev_weaponmodel2, CrossBowModel_P);
		set_pdata_int(id, 361, get_pdata_int(id, 361) | (1<<6));
	}
	return PLUGIN_CONTINUE
}

public CrossBow_WorldModel(entity, model[]) {
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new CrossBow = find_ent_by_owner(-1, weapon_crossbow, entity);
			
			if(get_user_crossbow(Owner) && is_valid_ent(CrossBow) && equal(model, "models/w_sg552.mdl")) {
				entity_set_int(CrossBow, EV_INT_impulse, CROSSBOW_WEAPONKEY);
				HaveCrossBow[Owner] = false;
				entity_set_model(entity, CrossBowModel_W);
				set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
			}
		}
	}
	return FMRES_IGNORED;
}

public CrossBow_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_CROSSBOW && get_user_crossbow(id))
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public CrossBow_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == crossbow_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public CrossBow_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/sg552.sc", name))
		crossbow_event = get_orig_retval();
	return FMRES_IGNORED;
}

public CrossBow_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_CROSSBOW && get_user_crossbow(id)) {				
				static CrossBow;
				CrossBow = fm_find_ent_by_owner(-1, weapon_crossbow, id);	
				
				if(is_valid_ent(CrossBow) && cs_get_weapon_ammo(CrossBow) > 0 && !crossbow_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, random_num(1,2));
					emit_sound(id, CHAN_WEAPON,CrossBow_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					
					CrossBow_Fire(id);
					
					static Float:PunchAngles[3];
					PunchAngles[0] = random_float(-4.0, -6.0);
					PunchAngles[1] = 0.0;
					PunchAngles[2] = 0.0;
					
					set_pev(id, pev_punchangle, PunchAngles);
					cs_set_weapon_ammo(CrossBow, cs_get_weapon_ammo(CrossBow) - 1);
					if(cs_get_weapon_ammo(CrossBow) > 0 && !crossbow_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, crossbow_shotdelay, 5);
						set_pdata_float(CrossBow, 48, 1.0, 4)
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
	return FMRES_IGNORED;
}

public CrossBow_AddToPlayer(Weapon, id) {
	if(is_valid_ent(Weapon) && is_user_connected(id) && entity_get_int(Weapon, EV_INT_impulse) == CROSSBOW_WEAPONKEY) {
		HaveCrossBow[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
		WeaponList(id)
	}
	return HAM_IGNORED;
}

public CrossBow_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner)) {
			set_pev(Owner, pev_viewmodel2, CrossBowModel_V);
			set_pev(Owner, pev_weaponmodel2, CrossBowModel_P);
			set_weapon_anim(Owner, 4)
			
			set_pdata_float(Owner, 83, 1.0, 5);
			set_pdata_float(Weapon, 48, 1.0, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				crossbow_reload[Owner] = 0;
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) | (1<<6));
		}
	}
	return HAM_IGNORED;
}

public CrossBow_Holster(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner))
			set_pdata_int(Owner, 361, get_pdata_int(Owner, 361) & ~ (1<<6));
	}
	return HAM_IGNORED;
}

public CrossBow_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 2.0, 4)
			set_weapon_anim(Owner, 0)
		}
	}
	return HAM_IGNORED;
}

public CrossBow_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		if(is_user_alive(Owner) && get_user_crossbow(Owner))
			return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public CrossBow_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner)) {		
			crossbow_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_CROSSBOW) <= 0 || get_pdata_int(Weapon, 51, 4) >= 1)
				return HAM_SUPERCEDE;
			
			crossbow_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			crossbow_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public CrossBow_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner) && crossbow_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, crossbow_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(crossbowreloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(crossbowreloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 3)
		}
	}
	return HAM_IGNORED;
}

public CrossBow_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_crossbow(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min(1 - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_CROSSBOW));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_CROSSBOW, cs_get_user_bpammo(Owner, CSW_CROSSBOW) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			crossbow_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}

public CrossBow_Fire(id) {	
	new Bolt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if(is_valid_ent(Bolt)) {
		new Float:Origin[3], Float:Angles[3], Float:Velocity[3];
		engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
		pev(id, pev_angles, Angles);
		
		set_pev(Bolt, pev_origin, Origin);
		set_pev(Bolt, pev_angles, Angles);
		set_pev(Bolt, pev_solid, SOLID_BBOX);
		set_pev(Bolt, pev_movetype, MOVETYPE_FLY);
		set_pev(Bolt, pev_classname, CROSSBOW_CLASS);
		
		set_pev(Bolt, pev_owner, id);
		engfunc(EngFunc_SetModel, Bolt, CrossBowModel_S);
		
		set_pev(Bolt, pev_mins, {-1.0, -1.0, -1.0});
		set_pev(Bolt, pev_maxs, {1.0, 1.0, 1.0});
		
		velocity_by_aim(id, 2000, Velocity);
		set_pev(Bolt, pev_velocity, Velocity);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE id
		write_short(Bolt); // entity:attachment to follow
		write_short(crossbow_trail); // sprite index
		write_byte(1); // life in 0.1's
		write_byte(1); // line width in 0.1's
		write_byte(255); // r
		write_byte(0); // g
		write_byte(0); // b
		write_byte(200); // brightness
		message_end();	
	}
}

public CrossBow_Touch(Bolt, touch) {
	if(is_valid_ent(Bolt)) {		
		new Float:BoltOrigin[3];
		pev(Bolt, pev_origin, BoltOrigin);
		new id = pev(Bolt, pev_owner);
		
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, BoltOrigin[0]);
		engfunc(EngFunc_WriteCoord, BoltOrigin[1]);
		engfunc(EngFunc_WriteCoord, BoltOrigin[2]);
		write_short(crossbow_explode);	// sprite index
		write_byte(30);			// scale in 0.1's
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
				new Float:Damage = get_pcvar_float(crossbowdamage)
				//make_blood(touch, get_pcvar_num(crossbowdamage))
				make_knockback(touch, BoltOrigin, get_pcvar_float(crossbowknockback) * Damage);	
				
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BLAST);
				else		
					death_message(id, touch, "CrossBow");
			}	
		}
		else if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(touch, EV_FL_health) <= get_pcvar_num(crossbowdamage))
				force_use(id, touch);
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(BoltOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				if(Distance <= get_pcvar_float(crossbowradius)) {								
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(crossbowradius));
					Damage = get_pcvar_float(crossbowdamage) - floatround(floatmul(get_pcvar_float(crossbowdamage), DistanceRatio));
					//make_blood(Victim, get_pcvar_num(crossbowdamage))
					make_knockback(Victim, BoltOrigin, get_pcvar_float(crossbowknockback)*Damage);
					if(get_user_health(Victim) - Damage >= 1)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					else		
						death_message(id, Victim, "CrossBow");
				}
			}
		}		
		engfunc(EngFunc_RemoveEntity, Bolt);
	}
}

public Hook_CrossBow(id) {
	engclient_cmd(id, weapon_crossbow);
	return PLUGIN_HANDLED
}

public get_user_crossbow(id)
	return HaveCrossBow[id];

public set_user_crossbow(id, crossbow)
{
	//drop_primary_weapons(id);
	HaveCrossBow[id] = true;
	crossbow_reload[id] = false;
			
	WeaponList(id)
	fm_give_item(id, weapon_crossbow);
			
	new Clip = fm_get_user_weapon_entity(id, CSW_CROSSBOW);
	cs_set_weapon_ammo(Clip, get_pcvar_num(crossbowclip));
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
	write_string(HaveCrossBow[id] ? "gg_weapon_crossbow" : "weapon_sg552");		// WeaponName
	write_byte(4);				// PrimaryAmmoID
	write_byte(90);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(10);				// NumberInSlot (1...N)
	write_byte(CSW_CROSSBOW);	// WeaponID
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

stock fm_get_user_bpammo(index, weapon) {
	static offset
	switch(weapon) {
		case CSW_AWP: offset = 377
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = 378
			case CSW_M249: offset = 379
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, 
			CSW_SG550, CSW_GALI, CSW_SG552: offset = 380
		case CSW_M3, CSW_XM1014: offset = 381
			case CSW_USP, CSW_UMP45, CSW_MAC10: offset = 382
			case CSW_FIVESEVEN, CSW_P90: offset = 383
			case CSW_DEAGLE: offset = 384
			case CSW_P228: offset = 385
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, 
			CSW_MP5NAVY: offset = 386
		default: offset = 0
	}
	return offset ? get_pdata_int(index, offset) : 0
}

stock fm_set_user_bpammo(index, weapon, amount) {
	static offset
	switch(weapon) {
		case CSW_AWP: offset = 377
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = 378
			case CSW_M249: offset = 379
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, 
			CSW_SG550, CSW_GALI, CSW_SG552: offset = 380
		case CSW_M3, CSW_XM1014: offset = 381
			case CSW_USP, CSW_UMP45, CSW_MAC10: offset = 382
			case CSW_FIVESEVEN, CSW_P90: offset = 383
			case CSW_DEAGLE: offset = 384
			case CSW_P228: offset = 385
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, 
			CSW_MP5NAVY: offset = 386
		default: offset = 0
	}
	
	if(offset) 
		set_pdata_int(index, offset, amount)
	
	return 1
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
