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

new bool:HaveSalamander[33], salamander_clip[33], salamander_reload[33], salamander_event;
new salamanderdamage, salamanderclip, salamanderreloadtime, salamanderradius;
new BloodSpray, BloodDrop;

#define SALAMANDER_WEAPONKEY		101
#define weapon_salamander		"weapon_m249"
#define CSW_SALAMANDER			CSW_M249
#define SALAMANDER_CLASS		"salamander_fire"
#define salamander_shotdelay		0.05 // Refire rate
new SalamanderModel_V[] = "models/[GeekGamers]/Primary/v_salamander.mdl";
new SalamanderModel_P[] = "models/[GeekGamers]/Primary/p_salamander.mdl";
new SalamanderModel_W[] = "models/[GeekGamers]/Primary/w_salamander.mdl";
new SalamanderModel_FIRE[] = "sprites/[GeekGamers]/Weapons/fire_salamander.spr";
new Salamander_Sound[][] = {
	"weapons/flamegun_shoot1.wav",
	//"weapons/flamegun_shoot2.wav",
	"weapons/flamegun_clipin1.wav",
	"weapons/flamegun_clipout1.wav",
	"weapons/flamegun_clipout2.wav",
	"weapons/flamegun_draw.wav"
};
new Salamander_Generic[][] = {
	"sprites/weapon_salamander.txt",
	"sprites/[GeekGamers]/Weapons/Salamander.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("furien30_salamander", "Hook_Salamander");
	
	register_event("CurWeapon", "Salamander_ViewModel", "be", "1=1");
	register_event("WeapPickup","Salamander_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "Salamander_WorldModel", 1);
	register_forward(FM_UpdateClientData, "Salamander_UpdateClientData", 1);
	register_forward(FM_PlaybackEvent, "Salamander_PlaybackEvent");
	register_forward(FM_CmdStart, "Salamander_CmdStart");	
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_salamander, "Salamander_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_salamander, "Salamander_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_salamander, "Salamander_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_salamander, "Salamander_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_salamander, "Salamander_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_salamander, "Salamander_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_salamander, "Salamander_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	register_think(SALAMANDER_CLASS, "Salamander_Think");
	
	register_touch(SALAMANDER_CLASS, "*", "Salamander_Touch");
	
	salamanderdamage = register_cvar("furien30_salamander_damage", "40.0");		//| Salamander Damage |//
	salamanderclip = register_cvar("furien_salamander_clip", "80");			//| Salamander Clip |//
	salamanderreloadtime = register_cvar("furien30_salamander_reload_time", "5.0");	//| Salamander Reload Time |//
	salamanderradius = register_cvar("furien30_salamander_radius", "50.0");		//| Salamander Radius |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "Salamander_PrecacheEvent_Post", 1);

	precache_model(SalamanderModel_V);
	precache_model(SalamanderModel_P);
	precache_model(SalamanderModel_W);
	precache_model(SalamanderModel_FIRE);
	for(new i = 0; i < sizeof(Salamander_Sound); i++)
		engfunc(EngFunc_PrecacheSound, Salamander_Sound[i]);	
	for(new i = 0; i < sizeof(Salamander_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, Salamander_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_salamander", "get_user_salamander", 1);
	register_native("gg_set_user_salamander", "set_user_salamander", 1);
}

public HAM_Spawn_Post(id)
{
	HaveSalamander[id] = false;
}

public Salamander_ViewModel(id)
{
	if(get_user_weapon(id) == CSW_SALAMANDER && get_user_salamander(id)) {
		set_pev(id, pev_viewmodel2, SalamanderModel_V);
		set_pev(id, pev_weaponmodel2, SalamanderModel_P);
	}
}

public Salamander_WorldModel(entity, model[])
{
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new Salamander = find_ent_by_owner(-1, weapon_salamander, entity);
			
			if(get_user_salamander(Owner) && is_valid_ent(Salamander) && equal(model, "models/w_m249.mdl")) {
				entity_set_int(Salamander, EV_INT_impulse, SALAMANDER_WEAPONKEY);
				HaveSalamander[Owner] = false;
				entity_set_model(entity, SalamanderModel_W);
			}
		}
	}
	return FMRES_IGNORED;
}

public Salamander_UpdateClientData(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_SALAMANDER && get_user_salamander(id))
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public Salamander_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == salamander_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public Salamander_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/m249.sc", name))
		salamander_event = get_orig_retval();
	return FMRES_IGNORED;
}

public Salamander_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		static Salamander;
		Salamander = fm_find_ent_by_owner(-1, weapon_salamander, id);
		
		if(CurButton & IN_ATTACK) {	
			if(pev_valid(Salamander) && get_user_weapon(id) == CSW_SALAMANDER && get_user_salamander(id) && pev(id, pev_waterlevel) <= 1) {
				if(cs_get_weapon_ammo(Salamander) > 0 && !salamander_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, 1);
					emit_sound(id, CHAN_WEAPON, Salamander_Sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
					Salamander_Fire(id);
					new Float:PunchAngle[3]
					PunchAngle[0] = random_float(-3.0, -5.0), PunchAngle[1] = 0.0, PunchAngle[0] = 0.0
					set_pev(id, pev_punchangle, PunchAngle);
					cs_set_weapon_ammo(Salamander, cs_get_weapon_ammo(Salamander) - 1);
					if(cs_get_weapon_ammo(Salamander) > 0 && !salamander_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, salamander_shotdelay, 5);
						set_pdata_float(Salamander, 48, 2.0, 4)
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
		if(!(CurButton & IN_ATTACK) &&(pev(id, pev_oldbuttons) & IN_ATTACK) && pev(id, pev_weaponanim) == 1) {
			if(pev_valid(Salamander) && get_user_weapon(id) == CSW_SALAMANDER && get_user_salamander(id) && cs_get_weapon_ammo(Salamander) > 0 && !salamander_reload[id])
				set_weapon_anim(id, 2);
		}
		
	}
	return FMRES_IGNORED;
}

public Salamander_AddToPlayer(Weapon, id) {
	if(pev_valid(Weapon) && is_user_alive(id) && entity_get_int(Weapon, EV_INT_impulse) == SALAMANDER_WEAPONKEY) {
		HaveSalamander[id] = true;
		WeaponList(id, SALAMANDER_WEAPONKEY)
		entity_set_int(Weapon, EV_INT_impulse, 0);
	}
	return FMRES_IGNORED;
}

public Salamander_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_salamander(Owner)) {
			set_pev(Owner, pev_viewmodel2, SalamanderModel_V);
			set_pev(Owner, pev_weaponmodel2, SalamanderModel_P);
			set_weapon_anim(Owner, 4)
			
			set_pdata_float(Owner, 83, 1.1, 5);
			set_pdata_float(Weapon, 48, 1.1, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				salamander_reload[Owner] = 0;
		}
	}
	return HAM_IGNORED;
}

public Salamander_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_salamander(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 9.4, 4)
			set_weapon_anim(Owner, 0)
		}
	}
	return HAM_IGNORED;
}

public Salamander_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		if(is_user_alive(Owner) && get_user_salamander(Owner))
			return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public Salamander_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_salamander(Owner)) {		
			salamander_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_SALAMANDER) <= 0 || get_pdata_int(Weapon, 51, 4) >= get_pcvar_num(salamanderclip))
				return HAM_SUPERCEDE;
			
			salamander_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			salamander_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public Salamander_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_salamander(Owner) && salamander_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, salamander_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(salamanderreloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(salamanderreloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 3)
		}
	}
	return HAM_IGNORED;
}

public Salamander_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_salamander(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min(get_pcvar_num(salamanderclip) - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_SALAMANDER));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_SALAMANDER, cs_get_user_bpammo(Owner, CSW_SALAMANDER) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			salamander_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}
public Salamander_Fire(id) {
	new Fire = create_entity("env_sprite");
	
	if(pev_valid(Fire)) {
		new Float:Origin[3], Float:Angles[3], Float:Velocity[3];
		engfunc(EngFunc_GetAttachment, id, 0, Origin, Angles);
		pev(id, pev_angles, Angles);
		
		set_pev(Fire, pev_solid, SOLID_TRIGGER);
		set_pev(Fire, pev_movetype, MOVETYPE_FLY);
		set_pev(Fire, pev_rendermode, kRenderTransAdd);
		set_pev(Fire, pev_renderamt, 250.0);
		set_pev(Fire, pev_scale, 0.5);
		
		entity_set_string(Fire, EV_SZ_classname, SALAMANDER_CLASS);
		engfunc(EngFunc_SetModel, Fire, SalamanderModel_FIRE);
		set_pev(Fire, pev_mins, Float:{-1.0, -1.0, -1.0});
		set_pev(Fire, pev_maxs, Float:{1.0, 1.0, 1.0});
		set_pev(Fire, pev_origin, Origin);
		set_pev(Fire, pev_angles, Angles);
		set_pev(Fire, pev_owner, id)
		set_pev(Fire, pev_frame, 0.0);
		
		velocity_by_aim(id, 1000, Velocity);
		set_pev(Fire, pev_velocity, Velocity);
		
		set_pev(Fire, pev_nextthink, halflife_time() + 0.02);
	}
}

public Salamander_Think(Fire) {
	if(is_valid_ent(Fire)) {
		static Float:FireOrigin[3];
		pev(Fire, pev_origin, FireOrigin);		
		
		new Float:Frame, Float:Scale
		pev(Fire, pev_frame, Frame);
		pev(Fire, pev_scale, Scale);
		
		Frame += 1.0;
		Scale += 0.1;
		
		set_pev(Fire, pev_frame, Frame);
		set_pev(Fire, pev_scale, Scale);
		set_pev(Fire, pev_nextthink, halflife_time() + 0.02);
		
		if(Frame >= 21.0)
			set_pev(Fire, pev_flags, pev(Fire, pev_flags) | FL_KILLME);
	}
}

public Salamander_Touch(Fire, touch) {
	if(is_valid_ent(Fire)) {
		static Float:FireOrigin[3];
		pev(Fire, pev_origin, FireOrigin);	
		new id = pev(Fire, pev_owner);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, FireOrigin[0])
		engfunc(EngFunc_WriteCoord, FireOrigin[1])
		engfunc(EngFunc_WriteCoord, FireOrigin[2])
		write_byte(random_num(46, 48))
		message_end()	
		
		static ClassName[32];
		pev(touch, pev_classname, ClassName, charsmax(ClassName));
		if(equal(ClassName, "player") && is_user_connected(touch) && is_user_alive(touch)) {
			if(!fm_get_user_godmode(touch) && get_user_team(touch) != get_user_team(id) && touch != id) {			
				new Float:Damage = get_pcvar_float(salamanderdamage)
				//make_blood(touch, get_pcvar_num(salamanderdamage))
				if(get_user_health(touch) > Damage)
					ExecuteHam(Ham_TakeDamage, touch, id, id, Damage, DMG_BURN);
				else
					death_message(id, touch, "Salamander");
			}
		}
		else if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(touch, EV_FL_health) <= get_pcvar_float(salamanderdamage))
				force_use(id, touch);
		}
		
		for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id && Victim != touch) {
				new Float:VictimOrigin[3], Float:Distance_F, Distance;
				pev(Victim, pev_origin, VictimOrigin);
				Distance_F = get_distance_f(FireOrigin, VictimOrigin);
				Distance = floatround(Distance_F);
				
				if(Distance <= get_pcvar_float(salamanderradius)) {				
					new Float:DistanceRatio, Float:Damage;
					DistanceRatio = floatdiv(float(Distance), get_pcvar_float(salamanderdamage));
					Damage = get_pcvar_float(salamanderdamage) - floatround(floatmul(get_pcvar_float(salamanderdamage), DistanceRatio));
					//make_blood(touch, floatround(Damage))
					if(get_user_health(Victim) > Damage)
						ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BURN);
					else			
						death_message(id, Victim, "Salamander");
				}
			}
		}
		
		if(id != touch && !equal(ClassName, SALAMANDER_CLASS)) {
			set_pev(Fire, pev_movetype, MOVETYPE_NONE);
			set_pev(Fire, pev_solid, SOLID_NOT);
		}
	}
}

public Hook_Salamander(id) {
	engclient_cmd(id, weapon_salamander);
	return PLUGIN_HANDLED
}

public get_user_salamander(id)
	return HaveSalamander[id];

public set_user_salamander(id, salamander)
{
	drop_primary_weapons(id);
	HaveSalamander[id] = true;
	salamander_reload[id] = 0;
			
	WeaponList(id, SALAMANDER_WEAPONKEY)
	fm_give_item(id, weapon_salamander);
			
	new Clip = fm_get_user_weapon_entity(id, CSW_SALAMANDER);
	cs_set_weapon_ammo(Clip, get_pcvar_num(salamanderclip));
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

public WeaponList(id, WEAPONKEY)
{
	new Message_WeaponList = get_user_msgid("WeaponList")

	message_begin(MSG_ONE, Message_WeaponList, _, id);
	write_string(HaveSalamander[id] ? "furien30_salamander" : "weapon_m249");	// WeaponName
	write_byte(3);				// PrimaryAmmoID
	write_byte(200);			// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(4);				// NumberInSlot (1...N)
	write_byte(CSW_SALAMANDER);		// WeaponID
	write_byte(0);				// Flags
	message_end();
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
