#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "Ethereal"
#define VERSION "1.0"
#define AUTHOR "D4RQS1D3R"

new bool:HaveEthereal[33], ethereal_clip[33], ethereal_reload[33], ethereal_event, ethereal_beam, ethereal_explode;
new etherealdamage, etherealclip, etherealreloadtime, etherealknockback;
new BloodSpray, BloodDrop;

new PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);

#define ETHEREAL_WEAPONKEY	103
#define weapon_ethereal		"weapon_galil"
#define CSW_ETHEREAL		CSW_GALIL
#define ethereal_shotdelay	0.15 // Refire rate
/*
new EtherealModel_V[] = "models/[GeekGamers]/Primary/v_ethereal_xmas.mdl";
new EtherealModel_P[] = "models/[GeekGamers]/Primary/p_ethereal_xmas.mdl";
*/
new EtherealModel_V[] = "models/[GeekGamers]/Primary/v_ethereal.mdl";
new EtherealModel_P[] = "models/[GeekGamers]/Primary/p_ethereal.mdl";
new EtherealModel_W[] = "models/[GeekGamers]/Primary/w_ethereal.mdl";
new Ethereal_Sound[][] = {
	"weapons/ethereal_shoot1.wav",
	"weapons/ethereal_idle1.wav",
	"weapons/ethereal_reload.wav",
	"weapons/ethereal_draw.wav"
};
new Ethereal_Generic[][] = {
	"sprites/gg_weapon_ethereal.txt",
	"sprites/[GeekGamers]/Weapons/Ethereal.spr",
	"sprites/640hud2.spr"
};

public plugin_init()
{
	register_clcmd("gg_weapon_ethereal", "Hook_Ethereal");
	
	register_event("CurWeapon", "Ethereal_ViewModel", "be", "1=1");
	register_event("WeapPickup","Ethereal_ViewModel","b","1=19");
	
	register_forward(FM_SetModel, "Ethereal_WorldModel", 1);
	register_forward(FM_UpdateClientData, "Ethereal_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent, "Ethereal_PlaybackEvent");

	register_forward(FM_CmdStart, "Ethereal_CmdStart");	
	
	RegisterHam(Ham_Item_AddToPlayer, weapon_ethereal, "Ethereal_AddToPlayer");
	RegisterHam(Ham_Item_Deploy , weapon_ethereal, "Ethereal_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_ethereal, "Ethereal_WeaponIdle")
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_ethereal, "Ethereal_PrimaryAttack");
	RegisterHam(Ham_Weapon_Reload, weapon_ethereal, "Ethereal_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_ethereal, "Ethereal_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_ethereal, "Ethereal_PostFrame");
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	
	etherealdamage = register_cvar("furien30_ethereal_damage", "35");		//| Ethereal Damage |//
	etherealclip = register_cvar("furien30_ethereal_clip", "30");			//| Ethereal Clip |//
	etherealreloadtime = register_cvar("furien30_ethereal_reload_time", "3.03");	//| Ethereal Reload Time |//
	etherealknockback = register_cvar("furien3_ethereal_knockback", "0.5");		//| Ethereal KnockBack |//
}

public plugin_precache()
{	
	register_forward(FM_PrecacheEvent, "Ethereal_PrecacheEvent_Post", 1);
	
	BloodSpray = precache_model("sprites/bloodspray.spr");   // initial blood
	BloodDrop  = precache_model("sprites/blood.spr");	// splattered blood

	ethereal_beam = precache_model("sprites/zbeam4.spr");
	ethereal_explode = precache_model("sprites/xspark4.spr");
	
	precache_model(EtherealModel_V);
	precache_model(EtherealModel_P);
	precache_model(EtherealModel_W);
	for(new i = 0; i < sizeof(Ethereal_Sound); i++)
		engfunc(EngFunc_PrecacheSound, Ethereal_Sound[i]);	
	for(new i = 0; i < sizeof(Ethereal_Generic); i++)
		engfunc(EngFunc_PrecacheGeneric, Ethereal_Generic[i]);
}

public plugin_natives()
{
	register_native("gg_get_user_ethereal", "get_user_ethereal", 1);
	register_native("gg_set_user_ethereal", "set_user_ethereal", 1);
}

public Ethereal_ViewModel(id) {
	if(get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id)) {
		set_pev(id, pev_viewmodel2, EtherealModel_V);
		set_pev(id, pev_weaponmodel2, EtherealModel_P);
	}
}

public PlayerSpawn(id)
{
	HaveEthereal[id] = false;
}

public Ethereal_WorldModel(entity, model[]) {
	if(is_valid_ent(entity)) {
		static ClassName[33];
		entity_get_string(entity, EV_SZ_classname, ClassName, charsmax(ClassName));
		
		if(equal(ClassName, "weaponbox")) {
			new Owner = entity_get_edict(entity, EV_ENT_owner);	
			new Ethereal = find_ent_by_owner(-1, weapon_ethereal, entity);
			
			if(get_user_ethereal(Owner) && is_valid_ent(Ethereal) && equal(model, "models/w_galil.mdl")) {
				entity_set_int(Ethereal, EV_INT_impulse, ETHEREAL_WEAPONKEY);
				HaveEthereal[Owner] = false;
				entity_set_model(entity, EtherealModel_W);
			}
		}
	}
	return FMRES_IGNORED;
}

public Ethereal_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id) && get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id))
		set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
	return FMRES_IGNORED;
}

public Ethereal_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2) {
	if(is_user_connected(invoker) && eventid == ethereal_event)
		playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_IGNORED;
}

public Ethereal_PrecacheEvent_Post(type, const name[]) {
	if (equal("events/galil.sc", name))
		ethereal_event = get_orig_retval();
	return FMRES_IGNORED;
}

public Ethereal_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:NextAttack = get_pdata_float(id, 83, 5);
		
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id)) {				
				static Ethereal;
				Ethereal = fm_find_ent_by_owner(-1, weapon_ethereal, id);	
				
				if(pev_valid(Ethereal) && cs_get_weapon_ammo(Ethereal) > 0 && !ethereal_reload[id] && NextAttack <= 0.0) {
					set_weapon_anim(id, random_num(3,5));
					emit_sound(id, CHAN_WEAPON,Ethereal_Sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					Ethereal_Fire(id);
					new Float:PunchAngle[3]
					PunchAngle[0] = random_float(-3.0, -5.0), PunchAngle[1] = 0.0, PunchAngle[0] = 0.0
					cs_set_weapon_ammo(Ethereal, cs_get_weapon_ammo(Ethereal) - 1);
					if(cs_get_weapon_ammo(Ethereal) > 0 && !ethereal_reload[id] && NextAttack <= 0.0) {
						set_pdata_float(id, 83, ethereal_shotdelay, 5);
						set_pdata_float(Ethereal, 48, 1.0, 4)
						
					}
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}
		}
	}
	return FMRES_IGNORED;
}

public Ethereal_AddToPlayer(Weapon, id) {
	if(pev_valid(Weapon) && is_user_alive(id) && entity_get_int(Weapon, EV_INT_impulse) == ETHEREAL_WEAPONKEY) {
		HaveEthereal[id] = true;
		WeaponList(id)
		entity_set_int(Weapon, EV_INT_impulse, 0);
	}
	return HAM_IGNORED;
}

public Ethereal_Deploy_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_ethereal(Owner)) {
			set_pev(Owner, pev_viewmodel2, EtherealModel_V);
			set_pev(Owner, pev_weaponmodel2, EtherealModel_P);
			set_weapon_anim(Owner, 2)
			
			set_pdata_float(Owner, 83, 1.3, 5);
			set_pdata_float(Weapon, 48, 1.3, 4)
			
			if(cs_get_weapon_ammo(Weapon) > 0)
				ethereal_reload[Owner] = 0;
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public Ethereal_WeaponIdle(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_ethereal(Owner) && get_pdata_float(Weapon, 48, 4) <= 0.1)  {
			set_pdata_float(Weapon, 48, 10.0, 4)
			set_weapon_anim(Owner, 0)
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public Ethereal_PrimaryAttack(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		if(is_user_alive(Owner) && get_user_ethereal(Owner))
			return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public Ethereal_Reload(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_ethereal(Owner)) {		
			ethereal_clip[Owner] = -1;
			
			if(cs_get_user_bpammo(Owner, CSW_ETHEREAL) <= 0 || get_pdata_int(Weapon, 51, 4) >= get_pcvar_num(etherealclip))
				return HAM_SUPERCEDE;
			
			ethereal_clip[Owner] = get_pdata_int(Weapon, 51, 4);
			ethereal_reload[Owner] = true;
		}
	}
	return HAM_IGNORED;
}

public Ethereal_Reload_Post(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_ethereal(Owner) && ethereal_clip[Owner] != -1) {			
			set_pdata_int(Weapon, 51, ethereal_clip[Owner], 4);
			set_pdata_float(Weapon, 48, get_pcvar_float(etherealreloadtime), 4);
			set_pdata_float(Owner, 83, get_pcvar_float(etherealreloadtime), 5);
			set_pdata_int(Weapon, 54, 1, 4);
			set_weapon_anim(Owner, 1)
		}
	}
	return HAM_IGNORED;
}

public Ethereal_PostFrame(Weapon) {
	if(pev_valid(Weapon)) {
		new Owner = get_pdata_cbase(Weapon, 41, 4);
		
		if(is_user_alive(Owner) && get_user_ethereal(Owner) && get_pdata_int(Weapon, 54, 4) && get_pdata_float(Owner, 83, 5) <= 0.0) {
			new Temp = min((get_pcvar_num(etherealclip)) - get_pdata_int(Weapon, 51, 4), cs_get_user_bpammo(Owner, CSW_ETHEREAL));
			
			set_pdata_int(Weapon, 51, get_pdata_int(Weapon, 51, 4) + Temp, 4);
			cs_set_user_bpammo(Owner, CSW_ETHEREAL, cs_get_user_bpammo(Owner, CSW_ETHEREAL) - Temp);		
			set_pdata_int(Weapon, 54, 0, 4);
			
			ethereal_reload[Owner] = false;
		}
	}
	return HAM_IGNORED;
}

public Ethereal_Fire(id) {	
	static Victim, Body, EndOrigin[3], BeamOrigin[3];
	get_user_origin(id, BeamOrigin, 3) ;
	get_user_origin(id, EndOrigin, 3);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(id | 0x1000);
	write_coord(BeamOrigin[0]);	// Start X
	write_coord(BeamOrigin[1]);	// Start Y
	write_coord(BeamOrigin[2]);	// Start Z
	write_short(ethereal_beam);	// Sprite
	write_byte(0);      		// Start frame				
	write_byte(1);     		// Frame rate					
	write_byte(1);			// Life
	write_byte(25);   		// Line width				
	write_byte(0);    		// Noise
	write_byte(150); 		// Red
	write_byte(0);			// Green
	write_byte(0);			// Blue
	write_byte(150);     		// Brightness					
	write_byte(0);      		// Scroll speed					
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(3);
	write_coord(EndOrigin[0]);
	write_coord(EndOrigin[1]);
	write_coord(EndOrigin[2]);
	write_short(ethereal_explode);
	write_byte(10);
	write_byte(15);
	write_byte(4);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_WORLDDECAL)
	write_coord(EndOrigin[0])
	write_coord(EndOrigin[1])
	write_coord(EndOrigin[2])
	write_byte(random_num(46, 48))
	message_end()
	
	get_user_aiming(id, Victim, Body, 999999);
	static ClassName[32];
	pev(Victim, pev_classname, ClassName, charsmax(ClassName));
	if(equal(ClassName, "player") && is_user_connected(Victim) && is_user_alive(Victim)) {
		if(!fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id) {
			new Float:Damage = float(get_damage_body(Body, get_pcvar_float(etherealdamage)));
			new Float:Origin[3];
			pev(id, pev_origin, Origin);
			make_blood(Victim, floatround(Damage))
			make_knockback(Victim, Origin, get_pcvar_float(etherealknockback)*get_pcvar_float(etherealdamage));
			if(get_user_health(Victim) > Damage)
				ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_NERVEGAS);
			else 
				death_message(id, Victim, "Ethereal");
		}
	}
	else if(equal(ClassName, "func_breakable")) {		
		if(entity_get_float(Victim, EV_FL_health) <= get_pcvar_num(etherealdamage))
			force_use(id, Victim);
	}
}

public Hook_Ethereal(id) {
	engclient_cmd(id, weapon_ethereal);
	return PLUGIN_HANDLED
}

public get_user_ethereal(id)
{
	return HaveEthereal[id];
}

public set_user_ethereal(id) {
	//drop_primary_weapons(id);
	HaveEthereal[id] = true;
	ethereal_reload[id] = false;
	
	WeaponList(id)
	fm_give_item(id, weapon_ethereal);
	
	new Clip = fm_get_user_weapon_entity(id, CSW_ETHEREAL);
	cs_set_weapon_ammo(Clip, get_pcvar_num(etherealclip));
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
	write_string(HaveEthereal[id] ? "gg_weapon_ethereal" : "weapon_galil");		// WeaponName
	write_byte(4);				// PrimaryAmmoID
	write_byte(90);				// PrimaryAmmoMaxAmount
	write_byte(-1);				// SecondaryAmmoID
	write_byte(-1);				// SecondaryAmmoMaxAmount
	write_byte(0);				// SlotID (0...N)
	write_byte(17);				// NumberInSlot (1...N)
	write_byte(CSW_ETHEREAL);	// WeaponID
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
