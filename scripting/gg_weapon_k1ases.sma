#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "K1ASES"
#define VERSION "1.0"
#define AUTHOR "D4RQS1D3R"

new bool:HaveK1ases[33], k1ases_clip[33], k1ases_reload[33], K1ases_Ability_Delay[33], k1ases_explode, k1ases_event;
new k1asesdamage, k1asesclip, k1asesreloadtime, k1asesrecoil, k1asesabilitydamage, k1asesabilitydelay, k1asesabilityradius;
new BloodSpray, BloodDrop;

new PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);

#define DMG_HEGRENADE 		(1<<24)
new Shell;
new Float:cl_pushangle[33][3];

#define K1ASES_WEAPONKEY	106
#define weapon_k1ases		"weapon_mp5navy"
#define CSW_K1ASES		CSW_MP5NAVY
new K1asesModel_V[] = "models/[GeekGamers]/Primary/v_k1ases.mdl";
new K1asesModel_P[] = "models/[GeekGamers]/Primary/p_k1ases.mdl";
new K1asesModel_W[] = "models/[GeekGamers]/Primary/w_k1ases.mdl";
new K1ases_Sound[][] = {
	"weapons/k1a_shoot1.wav",
	"weapons/k1a_ability.wav",
	"weapons/k1a_clipin.wav",
	"weapons/k1a_clipout.wav",
	"weapons/k1a_draw.wav",
	"weapons/k1a_foley1.wav"
};

new K1ases_Generic[][] = {
	"sprites/gg_weapon_k1ases.txt",
	"sprites/[GeekGamers]/Weapons/K1ases.spr",
	"sprites/[GeekGamers]/Weapons/640hud7x.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_k1ases", "Hook_K1ases");
	
	register_message(get_user_msgid("DeathMsg"), "K1ases_DeathMsg");
	
	register_event("CurWeapon", "K1ases_ViewModel", "be", "1=1");
	register_event("WeapPickup","K1ases_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "K1ases_WorldModel");
	register_forward(FM_UpdateClientData, "K1ases_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "K1ases_PlaybackEvent");
	register_forward(FM_CmdStart, "K1ases_CmdStart");	
	
	RegisterHam(Ham_TakeDamage, "player", "K1ases_TakeDamage");
	RegisterHam(Ham_TraceAttack, "worldspawn", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "player", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "K1ases_TraceAttack_Post", 1);
	RegisterHam(Ham_Item_Deploy , weapon_k1ases, "K1ases_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_k1ases, "K1ases_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_k1ases, "K1ases_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, weapon_k1ases, "K1ases_AddToPlayer");
	RegisterHam(Ham_Weapon_Reload, weapon_k1ases, "K1ases_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_k1ases, "K1ases_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_k1ases, "K1ases_PostFrame");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	k1asesdamage = register_cvar("furien30_k1ases_bonus_damage", "3");				//| K1ases Damage |//
	k1asesclip = register_cvar("furien30_k1ases_clip", "35");						//| K1ases Clip |//
	k1asesreloadtime = register_cvar("furien30_k1ases_reload_time", "2.57");		//| K1ases Reload Time |//
	k1asesrecoil = register_cvar("furien30_k1ases_recoil", "0.8");					//| K1ases Recoil |//
	k1asesabilitydamage = register_cvar("furien30_k1ases_ability_damage", "50.0");	//| K1ases Ability Damage |//
	k1asesabilitydelay = register_cvar("furien30_k1ases_ability_delay", "30.0");	//| K1ases Ability Delay |//
	k1asesabilityradius = register_cvar("furien30_k1ases_ability_radius", "100.0");	//| K1ases Ability Radius |//
}

public plugin_precache()
{
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	
	register_forward(FM_PrecacheEvent, "K1ases_PrecacheEvent_Post", 1);
	
	k1ases_explode  = precache_model("sprites/[GeekGamers]/Weapons/k1ases_ability.spr");
	
	precache_model(K1asesModel_V);
	precache_model(K1asesModel_P);
	precache_model(K1asesModel_W);
	for(new i = 0; i < sizeof(K1ases_Sound); i++)
		engfunc(EngFunc_PrecacheSound, K1ases_Sound[i]);	
	for(new i = 0; i < sizeof(K1ases_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, K1ases_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_k1ases", "get_user_k1ases", 1);
	register_native("gg_set_user_k1ases", "set_user_k1ases", 1);
}

public HAM_Spawn_Post(id)
{
	HaveK1ases[id] = false;
}

public K1ases_DeathMsg(msg_id, msg_dest, id) {
	static TruncatedWeapon[33], Attacker, Victim;
	
	get_msg_arg_string(4, TruncatedWeapon, charsmax(TruncatedWeapon));
	
	Attacker = get_msg_arg_int(1);
	Victim = get_msg_arg_int(2);
	
	if(!is_user_connected(Attacker) || Attacker == Victim)
		return PLUGIN_CONTINUE;
	
	if(equal(TruncatedWeapon, "mp5navy") && get_user_weapon(Attacker) == CSW_K1ASES) {
		if(get_user_k1ases(Attacker))
			set_msg_arg_string(4, "K1ASES");
	}
	return PLUGIN_CONTINUE;
}

public K1ases_ViewModel(id) {
	if(get_user_weapon(id) == CSW_K1ASES && get_user_k1ases(id)) {
		set_pev(id, pev_viewmodel2, K1asesModel_V);
		set_pev(id, pev_weaponmodel2, K1asesModel_P);
	}
}

public K1ases_WorldModel(entity, model[]) {
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	
	static ClassName[33];
	entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
	
	if(!equal(ClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	new Owner = entity_get_edict(entity, EV_ENT_owner);	
	new K1ases = find_ent_by_owner(-1, weapon_k1ases, entity);
	
	if(get_user_k1ases(Owner) && is_valid_ent(K1ases) && equal(model, "models/w_mp5.mdl")) {
		entity_set_int(K1ases, EV_INT_impulse, K1ASES_WEAPONKEY);
		HaveK1ases[Owner] = false;
		entity_set_model(entity, K1asesModel_W);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public K1ases_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id)) {
		if(get_user_weapon(id) == CSW_K1ASES && get_user_k1ases(id))	
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	}
}

public K1ases_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(!is_user_connected(invoker))
		return FMRES_IGNORED;
	if(eventid != k1ases_event)
		return FMRES_IGNORED;
	
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	
	return FMRES_SUPERCEDE;
}

public K1ases_PrecacheEvent_Post(type, const name[]) {
	if(equal("events/mp5navy.sc", name)) {
		k1ases_event = get_orig_retval();
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public K1ases_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		if(CurButton & IN_ATTACK2) {
			if(get_user_weapon(id) == CSW_K1ASES && get_user_k1ases(id) && NextAttack <= 0.0) {
				K1ases_Ability(id);
				CurButton &= ~IN_ATTACK2;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
}

public K1ases_TakeDamage(victim, inflictor, attacker, Float:damage, damagetype) {
	if(is_user_connected(attacker) && !(damagetype & DMG_HEGRENADE)) {
		new Body, Target, Float:NewDamage;
		if(get_user_weapon(attacker) == CSW_K1ASES && get_user_k1ases(attacker)) {
			if(is_user_connected(victim)) {
				get_user_aiming(attacker, Target, Body, 999999);
				NewDamage = float(get_damage_body(Body, get_pcvar_float(k1asesdamage)));
				SetHamParamFloat(4, damage + NewDamage);
			} 
			else {
				SetHamParamFloat(4, damage + get_pcvar_float(k1asesdamage));
			}
		}
	}
}

public K1ases_TraceAttack_Post(ent, attacker, Float:Damage, Float:Dir[3], ptr, DamageType) {
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return HAM_IGNORED;
	if(get_user_weapon(attacker) != CSW_K1ASES)
		return HAM_IGNORED;
	if(!get_user_k1ases(attacker))
		return HAM_IGNORED;
	
	static Float:End[3];
	get_tr2(ptr, TR_vecEndPos, End);
	
	make_bullet(attacker, End);
	
	return HAM_HANDLED;
}

public K1ases_AddToPlayer(Weapon, id) {
	if(is_valid_ent(Weapon) && is_user_connected(id) && entity_get_int(Weapon, EV_INT_impulse) == K1ASES_WEAPONKEY) {
		HaveK1ases[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
		WeaponList(id)
	}
}

public K1ases_Deploy_Post(entity) {
	static Owner;
	Owner = get_pdata_cbase(entity, 41, 4);
	if(get_user_k1ases(Owner)) {
		set_pev(Owner, pev_viewmodel2, K1asesModel_V);
		set_pev(Owner, pev_weaponmodel2, K1asesModel_P);
		set_pdata_float(Owner, 83, 1.2, 5);
		set_weapon_anim(Owner, 2);
		static clip;
		clip = cs_get_weapon_ammo(entity);
		if(clip > 0)
			k1ases_reload[Owner] = 0;
	}
}

public K1ases_PrimaryAttack(Weapon) {
	new id = get_pdata_cbase(Weapon, 41, 4);
	
	if(get_user_k1ases(id)) {
		pev(id,pev_punchangle,cl_pushangle[id]);
		k1ases_clip[id] = cs_get_weapon_ammo(Weapon);
	}
}

public K1ases_PrimaryAttack_Post(Weapon) {
	new id = get_pdata_cbase(Weapon, 41, 4);
	new ActiveItem = get_pdata_cbase(id, 373) ;
	
	if(k1ases_clip[id] > 0 && pev_valid(ActiveItem)) {
		if(is_user_alive(id) && get_user_k1ases(id)) {
			set_pdata_int(ActiveItem, 57, Shell, 4) ;
			set_pdata_float(id, 111, get_gametime());
			
			new Float:Push[3];
			pev(id,pev_punchangle,Push);
			xs_vec_sub(Push,cl_pushangle[id],Push);
			
			xs_vec_mul_scalar(Push,get_pcvar_float(k1asesrecoil),Push);
			xs_vec_add(Push,cl_pushangle[id],Push);
			set_pev(id,pev_punchangle,Push);
			
			emit_sound(id, CHAN_WEAPON, K1ases_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			set_weapon_anim(id, random_num(3,5));
		}
	}
}

public K1ases_Reload(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_k1ases(id))
		return HAM_IGNORED;
	
	k1ases_clip[id] = -1;
	
	new Ammo = cs_get_user_bpammo(id, CSW_K1ASES);
	if(Ammo <= 0)
		return HAM_SUPERCEDE;
	
	new Clip = get_pdata_int(ent, 51, 4);
	if(Clip >= get_pcvar_num(k1asesclip))
		return HAM_SUPERCEDE;
	
	k1ases_clip[id] = Clip;
	k1ases_reload[id] = 1;
	
	return HAM_IGNORED;
}

public K1ases_Reload_Post(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_k1ases(id))
		return HAM_IGNORED;
	
	if(k1ases_clip[id] == -1)
		return HAM_IGNORED;
	
	new Float:reload_time = get_pcvar_float(k1asesreloadtime);
	
	set_pdata_int(ent, 51, k1ases_clip[id], 4);
	set_pdata_float(ent, 48, reload_time, 4);
	set_pdata_float(id, 83, reload_time, 5);
	set_pdata_int(ent, 54, 1, 4);
	set_weapon_anim(id, 1);
	return HAM_IGNORED;
}

public K1ases_PostFrame(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_k1ases(id))
		return HAM_IGNORED;
	
	new Float:NextAttack = get_pdata_float(id, 83, 5);
	new Ammo = cs_get_user_bpammo(id, CSW_K1ASES);
	
	new Clip = get_pdata_int(ent, 51, 4);
	new InReload = get_pdata_int(ent, 54, 4);
	
	if(InReload && NextAttack <= 0.0) {
		new Temp = min(get_pcvar_num(k1asesclip) - Clip, Ammo);
		
		set_pdata_int(ent, 51, Clip + Temp, 4);
		cs_set_user_bpammo(id, CSW_K1ASES, Ammo - Temp);		
		set_pdata_int(ent, 54, 0, 4);
		
		InReload = 0;
		k1ases_reload[id] = 0;
	}		
	
	return HAM_IGNORED;
}

public K1ases_Ability(id) {
	if(is_user_alive(id) && !K1ases_Ability_Delay[id]) {
		set_pdata_float(id, 83, 0.83, 5);
		set_weapon_anim(id, 6);
		
		new AimOrigin[3];
		get_user_origin(id, AimOrigin, 3);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
		write_byte(TE_EXPLOSION); // TE_EXPLOSION
		write_coord(AimOrigin[0]); // origin x
		write_coord(AimOrigin[1]); // origin y
		write_coord(AimOrigin[2]); // origin z
		write_short(k1ases_explode); // sprites
		write_byte(40); // scale in 0.1's
		write_byte(30); // framerate
		write_byte(14); // flags 
		message_end(); // message end
		
		new Float:AimOrigin2[3];
		
		static Victim;
		Victim = -1;
		
		AimOrigin2[0] = float(AimOrigin[0]);
		AimOrigin2[1] = float(AimOrigin[1]);
		AimOrigin2[2] = float(AimOrigin[2]);
		
		while((Victim = find_ent_in_sphere(Victim, AimOrigin2, get_pcvar_float(k1asesabilityradius))) != 0) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id) {			
				new BloodColor = ExecuteHam(Ham_BloodColor, Victim);
				if(BloodColor != -1) {
					new Amount = floatround(get_pcvar_float(k1asesabilitydamage));
					
					Amount *= 2; //according to HLSDK
					
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_BLOODSPRITE);
					write_coord(floatround(AimOrigin2[0]));
					write_coord(floatround(AimOrigin2[1]));
					write_coord(floatround(AimOrigin2[2]));
					write_short(BloodSpray);
					write_short(BloodDrop);
					write_byte(BloodColor);
					write_byte(min(max(3, Amount/10), 16));
					message_end();
				}
				if(get_user_health(Victim) - get_pcvar_float(k1asesabilitydamage) >= 1) {
					ExecuteHam(Ham_TakeDamage, Victim, id, id, get_pcvar_float(k1asesabilitydamage), DMG_BLAST);
					
					message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, Victim);
					write_byte(0);
					write_byte(0);
					write_long(DMG_NERVEGAS);
					write_coord(0) ;
					write_coord(0);
					write_coord(0);
					message_end();
					
					message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, Victim);
					write_short(1<<13);
					write_short(1<<14);
					write_short(0x0000);
					write_byte(200);
					write_byte(100);
					write_byte(0);
					write_byte(100) ;
					message_end();
					
					message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, Victim);
					write_short(0xFFFF);
					write_short(1<<13);
					write_short(0xFFFF) ;
					message_end();
				}
				else {
					death_message(id, Victim, "K1ASES's Ability");
				}
			}
		}
		
		K1ases_Ability_Delay[id] = get_pcvar_num(k1asesabilitydelay);
		emit_sound(id, CHAN_WEAPON, K1ases_Sound[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		if(K1ases_Ability_Delay[id]) {
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Your K1ASES's Ability will return in: %d second%s.",K1ases_Ability_Delay[id], K1ases_Ability_Delay[id] == 1 ? "" : "s");
			
			HudMessage(id, Message, 0, 0, 200, 0.05, 0.50, _, _, 1.0);
			set_task(1.0, "K1asesAbilityDelay", id);
		}
	}
}

public K1asesAbilityDelay(id) {
	if(!is_user_alive(id) || get_user_team(id) != 2) {
		K1ases_Ability_Delay[id] = 0;
	}
	else if(K1ases_Ability_Delay[id] > 1) {
		K1ases_Ability_Delay[id]--;
		new Message[64];
		formatex(Message,sizeof(Message)-1,"Your K1ASES's Ability will return in: %d second%s.",K1ases_Ability_Delay[id], K1ases_Ability_Delay[id] == 1 ? "" : "s");
		
		HudMessage(id, Message, 0, 0, 200, 0.05, 0.50, _, _, 1.0);
		set_task(1.0, "K1asesAbilityDelay", id);
	}	
	else if(K1ases_Ability_Delay[id] <= 1) {
		new Message[64];
		formatex(Message,sizeof(Message)-1,"Your K1ASES's Ability is ready.");
		
		HudMessage(id, Message, 0, 0, 200, 0.05, 0.50, _, _, 1.0);
		K1ases_Ability_Delay[id] = 0;
	}
}

public Hook_K1ases(id) {
	engclient_cmd(id, weapon_k1ases);
}

public get_user_k1ases(id) {
	return HaveK1ases[id];
}

public set_user_k1ases(id, k1ases)
{
	// drop_primary_weapons(id);
	HaveK1ases[id] = true;
	k1ases_reload[id] = 0;
	
	WeaponList(id)
	fm_give_item(id, weapon_k1ases);

	new Clip = fm_get_user_weapon_entity(id, CSW_K1ASES);
	cs_set_weapon_ammo(Clip, get_pcvar_num(k1asesclip));
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
	write_string(HaveK1ases[id] ? "gg_weapon_k1ases" : "weapon_mp5navy");		// WeaponName
	write_byte(10);				// PrimaryAmmoID
	write_byte(120);			// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(7);				// NumberInSlot (1...N)
	write_byte(CSW_K1ASES);		// WeaponID
	write_byte(0);				// Flags
	message_end();
}

#define clamp_byte(%1)       ( clamp( %1, 0, 255 ) )
#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 16 ) )

stock HudMessage(const id, const message[], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 0.01, Float:holdtime = 3.0, Float:fadeintime = 0.01, Float:fadeouttime = 0.01) {
	new count = 1, players[32];
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {	
				new color = pack_color(clamp_byte(red), clamp_byte(green), clamp_byte(blue))
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, players[i]);
				write_byte(strlen(message) + 31);
				write_byte(DRC_CMD_MESSAGE);
				write_byte(effects);
				write_long(color);
				write_long(_:x);
				write_long(_:y);
				write_long(_:fadeintime);
				write_long(_:fadeouttime);
				write_long(_:holdtime);
				write_long(_:fxtime);
				write_string(message);
				message_end();
			}
		}
	}
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
