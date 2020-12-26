////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ethereal |
//==========================================================================================================
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>

#define PLUGIN "[GG] Ethereal"
#define VERSION "1.0"
#define AUTHOR "sDs|Aragon*"

const PRIMARY_WEAPONS_BITSUM =(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
new BloodDrop, BloodSpray

#define ETHEREAL_WEAPONKEY	103
#define weapon_ethereal		"weapon_galil"
#define CSW_ETHEREAL		CSW_GALIL
#define ethereal_shotdelay	0.15 // Refire rate

new EtherealModel_V[] = "models/[GeekGamers]/Primary/v_ethereal1.mdl";
new EtherealModel_P[] = "models/[GeekGamers]/Primary/p_ethereal1.mdl";
new EtherealModel_W[] = "models/[GeekGamers]/Primary/w_ethereal1.mdl";
new const ethereal_sound[5][] = {
	"weapons/ethereal_shoot1.wav",
	"weapons/ethereal_hit.wav",
	"weapons/ethereal_idle1.wav",
	"weapons/ethereal_reload.wav",
	"weapons/ethereal_draw.wav"
};
new const ethereal_generic[3][] = {
	"sprites/weapon_ethereal",
	"sprites/Ethereal.spr",
	"sprites/640hud2.spr"
};
new bool:HasEthereal[33], ethereal_clip[33], ethereal_reload[33], Float:EtherealLastShotTime[33], ethereal_trail, ethereal_explode;
new ethereal, etherealcost, etherealdamage, etherealclip, etherealammo, etherealreloadtime, etherealknockback;

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	RegisterHam(Ham_Spawn, "player", "Spawn_Post", 1);
	
	register_clcmd("Ethereal/weapon_ethereal", "hook_ethereal");
	register_event("CurWeapon", "Ethereal_Model", "be", "1=1");	
	register_event("WeapPickup","Ethereal_Model","b","1=19");
	register_forward(FM_SetModel, "Ethereal_SetModel");
	register_forward(FM_CmdStart, "Ethereal_CmdStart");	
	register_forward(FM_UpdateClientData, "Ethereal_UpdateClientData_Post", 1);
	RegisterHam(Ham_Item_Deploy , weapon_ethereal, "Ethereal_Deploy_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, weapon_ethereal, "Ethereal_AddToPlayer");
	RegisterHam(Ham_Weapon_Reload, weapon_ethereal, "Ethereal_Reload");
	RegisterHam(Ham_Weapon_Reload, weapon_ethereal, "Ethereal_Reload_Post", 1);
	RegisterHam(Ham_Item_PostFrame, weapon_ethereal, "Ethereal_PostFrame");	
	
	ethereal = register_cvar("amx_ethereal", "1");				//| Ethereal 0 Disable -> 1 Enable |//
	etherealcost = register_cvar("amx_etherealcost", "8000");		//| Ethereal Cost |//
	etherealdamage = register_cvar("amx_ethereal_damage", "50");		//| Ethereal Damage |//
	etherealclip = register_cvar("amx_ethereal_clip", "30");		//| Ethereal Clip |//
	etherealammo = register_cvar("amx_ethereal_ammo", "90");		//| Ethereal Ammo |//
	etherealreloadtime = register_cvar("amx_ethereal_reload_time", "3.03");	//| Ethereal Reload Time |//
	etherealknockback = register_cvar("amx_ethereal_knockback", "3");	//| Ethereal KnockBack |//
	/*
	register_clcmd("ethereal", "buy_ethereal");
	register_clcmd("buy_ethereal", "buy_ethereal");
	register_clcmd("say /ethereal", "buy_ethereal");
	register_clcmd("say /buy_ethereal", "buy_ethereal");
	register_clcmd("say buy_ethereal", "buy_ethereal");
	register_clcmd("say_team /ethereal", "buy_ethereal");
	register_clcmd("say_team /buy_ethereal", "buy_ethereal");
	register_clcmd("say_team buy_ethereal", "buy_ethereal");
	register_concmd("amx_give_ethereal", "GiveEthereal", ADMIN_LEVEL_B, "Name");
	*/
}

public plugin_natives()
{
	register_native("gg_get_user_ethereal", "get_user_ethereal", 1);
	register_native("gg_set_user_ethereal", "set_user_ethereal", 1);
}

public get_user_ethereal(id) {
	return HasEthereal[id];
}

public set_user_ethereal(id, ethereal) {
	if(ethereal) {
		if(!HasEthereal[id]) {
			//drop_primary_weapons(id);
			HasEthereal[id] = true;
			message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id);
			write_string("Ethereal/weapon_ethereal");	// WeaponName
			write_byte(4);			// PrimaryAmmoID
			write_byte(90);			// PrimaryAmmoMaxAmount
			write_byte(-1);			// SecondaryAmmoID
			write_byte(-1);			// SecondaryAmmoMaxAmount
			write_byte(0);			// SlotID (0...N)
			write_byte(17);			// NumberInSlot (1...N)
			write_byte(CSW_ETHEREAL);	// WeaponID
			write_byte(0);			// Flags
			message_end();
			fm_give_item(id, weapon_ethereal)
			cs_set_user_bpammo(id, CSW_ETHEREAL, get_pcvar_num(etherealammo))
			new clip = fm_get_user_weapon_entity(id, CSW_ETHEREAL);
			cs_set_weapon_ammo(clip, get_pcvar_num(etherealclip));
			set_weapon_anim(id, 2);
		}
	}
	else {
		if(HasEthereal[id]) {
			HasEthereal[id] = false;
		}
	}
}

public Spawn_Post(id) set_user_ethereal(id, 0);

//------| Buy Ethereal |------//
public buy_ethereal(id) {
	new ethcost = get_pcvar_num(etherealcost);
	if(!get_pcvar_num(ethereal)) {
		ColorChat(id, "^x04[Ethereal]^x03 Ethereal^x04 este dezactivat.");
	}
	else if(!is_user_alive(id)) {
		ColorChat(id, "^x04[Ethereal]^x03 Nu poti cumpara^x04 Ethereal^x03 cat timp esti mort.");
	}
	else if(get_user_ethereal(id)) {
		ColorChat(id, "^x04[Ethereal]^x03 Ai deja^x04 Ethereal.");
	}
	else if(cs_get_user_money(id) < ethcost) {
		ColorChat(id, "^x04[Ethereal]^x03 Nu ai suficiente fonduri pentru a cumpara^x04 Ethereal^x03. Necesari: ^x04$%d",ethcost);
	}
	else {
		cs_set_user_money(id, cs_get_user_money(id) - ethcost);
		ColorChat(id, "^x04[Ethereal]^x03 Ai cumparat^x04 Ethereal.");
		set_user_ethereal(id, true);
	}
}

public GiveEthereal(id, level, cid) {
	if(!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}
	
	new arg[23], name[32];
	get_user_name(id, name, 31);
	read_argv(1, arg, 23);	
	new player = cmd_target(id, arg, 11);
	if(!player) {
		console_print(id, "Juctorul cu acel nume nu exista.");
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(player)) {
		return PLUGIN_HANDLED;
	}
	if(!get_user_ethereal(player)) {
		set_user_ethereal(player, true);
		switch(get_cvar_num("amx_show_activity")) {
			case 1: ColorChat(player, "^x03ADMIN^x04 give you ^x03 Ethereal.");
				
			case 2: ColorChat(player, "^x03%s^x04 give you ^x03 Ethereal.", name);
			}
	}
	return PLUGIN_HANDLED;
	
}

public hook_ethereal(id) {
	engclient_cmd(id, weapon_ethereal);
}

public Ethereal_Model(id) {
	if(get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id)) {
		set_pev(id, pev_viewmodel2, EtherealModel_V);
		set_pev(id, pev_weaponmodel2, EtherealModel_P);
	}
}

public Ethereal_SetModel(entity, model[]) {
	// Entity is not valid
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
	
	// Get classname
	static szClassName[33];
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName));
	
	// Not a Weapon box
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	new iOwner = entity_get_edict(entity, EV_ENT_owner);	
	new WPN_Ethereal = find_ent_by_owner(-1, weapon_ethereal, entity);
	
	if(get_user_ethereal(iOwner) && is_valid_ent(WPN_Ethereal) && equal(model, "models/w_galil.mdl")) {
		entity_set_int(WPN_Ethereal, EV_INT_impulse, ETHEREAL_WEAPONKEY);
		HasEthereal[iOwner] = false;
		entity_set_model(entity, EtherealModel_W);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public Ethereal_CmdStart(id, uc_handle, seed) {
	if(is_user_alive(id) && is_user_connected(id)) {
		static CurButton;
		CurButton = get_uc(uc_handle, UC_Buttons);
		new Float:flNextAttack = get_pdata_float(id, 83, 5);
		if(CurButton & IN_ATTACK) {
			if(get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id)) {
				
				static ethereal;
				ethereal = fm_find_ent_by_owner(-1, weapon_ethereal, id);	
				
				if(cs_get_weapon_ammo(ethereal) > 0 && !ethereal_reload[id] && flNextAttack <= 0.0) {
					if(get_gametime() - EtherealLastShotTime[id] > ethereal_shotdelay) {
						set_weapon_anim(id, random_num(3,5));
						emit_sound(id, CHAN_WEAPON, ethereal_sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
						
						Ethereal_Fire(id);
						
						static Float:Punch_Angles[3];
						
						Punch_Angles[0] = -3.0;
						Punch_Angles[1] = 0.0;
						Punch_Angles[2] = 0.0;
						
						set_pev(id, pev_punchangle, Punch_Angles);
						cs_set_weapon_ammo(ethereal, cs_get_weapon_ammo(ethereal) - 1);
						EtherealLastShotTime[id] = get_gametime();
						
					}	
				}
				CurButton &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, CurButton);
			}			
		}
		
	}
}

public Ethereal_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(is_user_alive(id) && is_user_connected(id)) {
		if(get_user_weapon(id) == CSW_ETHEREAL && get_user_ethereal(id)) {	
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001);
		}
	}
}

public Ethereal_AddToPlayer(Weapon, id) {
	if(is_valid_ent(Weapon) && is_user_connected(id) && entity_get_int(Weapon, EV_INT_impulse) == ETHEREAL_WEAPONKEY) {
		HasEthereal[id] = true;
		entity_set_int(Weapon, EV_INT_impulse, 0);
	}
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id);
	write_string(HasEthereal[id] ? "Ethereal/weapon_ethereal" : "weapon_galil");	// WeaponName
	write_byte(4);			// PrimaryAmmoID
	write_byte(90);			// PrimaryAmmoMaxAmount
	write_byte(-1);			// SecondaryAmmoID
	write_byte(-1);			// SecondaryAmmoMaxAmount
	write_byte(0);			// SlotID (0...N)
	write_byte(17);			// NumberInSlot (1...N)
	write_byte(CSW_ETHEREAL);	// WeaponID
	write_byte(0);			// Flags
	message_end();
}
public Ethereal_Deploy_Post(entity) {
	static owner;
	owner = fm_get_weapon_ent_owner(entity);
	if(get_user_ethereal(owner)) {
		set_pev(owner, pev_viewmodel2, EtherealModel_V);
		set_pev(owner, pev_weaponmodel2, EtherealModel_P);
		set_weapon_anim(owner, 2);
		set_pdata_float(owner, 83, 1.36, 5);
		static clip;
		clip = cs_get_weapon_ammo(entity);
		if(clip > 0)
			ethereal_reload[owner] = 0;
	}
}
public Ethereal_Reload(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_ethereal(id))
		return HAM_IGNORED;
	
	ethereal_clip[id] = -1;
	
	new bpammo = cs_get_user_bpammo(id, CSW_ETHEREAL);
	if(bpammo <= 0)
		return HAM_SUPERCEDE;
	
	new iClip = get_pdata_int(ent, 51, 4);
	if(iClip >= get_pcvar_num(etherealclip))
		return HAM_SUPERCEDE;
	
	ethereal_clip[id] = iClip;
	ethereal_reload[id] = 1;
	
	return HAM_IGNORED;
}
public Ethereal_Reload_Post(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_ethereal(id))
		return HAM_IGNORED;
	
	if(ethereal_clip[id] == -1)
		return HAM_IGNORED;
	
	new Float:reload_time = get_pcvar_float(etherealreloadtime);
	
	set_pdata_int(ent, 51, ethereal_clip[id], 4);
	set_pdata_float(ent, 48, reload_time, 4);
	set_pdata_float(id, 83, reload_time, 5);
	set_pdata_int(ent, 54, 1, 4);
	set_weapon_anim(id, 1);
	return HAM_IGNORED;
}
public Ethereal_PostFrame(ent) {
	if(!pev_valid(ent))
		return HAM_IGNORED;
	
	new id;
	id = pev(ent, pev_owner);
	
	if(!is_user_alive(id) || !get_user_ethereal(id))
		return HAM_IGNORED;
	
	new Float:flNextAttack = get_pdata_float(id, 83, 5);
	new bpammo = cs_get_user_bpammo(id, CSW_ETHEREAL);
	
	new iClip = get_pdata_int(ent, 51, 4);
	new fInReload = get_pdata_int(ent, 54, 4);
	
	if(fInReload && flNextAttack <= 0.0) {
		new temp = min(get_pcvar_num(etherealclip) - iClip, bpammo);
		
		set_pdata_int(ent, 51, iClip + temp, 4);
		cs_set_user_bpammo(id, CSW_ETHEREAL, bpammo - temp);		
		set_pdata_int(ent, 54, 0, 4);
		
		fInReload = 0;
		ethereal_reload[id] = 0;
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
	write_short(ethereal_trail);	// Sprite
	write_byte(1);      		// Start frame				
	write_byte(1);     		// Frame rate					
	write_byte(1);			// Life
	write_byte(25);   		// Line width				
	write_byte(0);    		// Noise
	write_byte(0); 			// Red
	write_byte(150);		// Green
	write_byte(0);			// Blue
	write_byte(150);     		// Brightness					
	write_byte(25);      		// Scroll speed					
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
	
	get_user_aiming(id, Victim, Body, 999999);
	if(is_user_connected(Victim)) {
		new Float:Damage = float(get_damage_body(Body, get_pcvar_float(etherealdamage)));
		
		new Float:VictimOrigin[3];
		VictimOrigin[0] = float(EndOrigin[0]);
		VictimOrigin[1] = float(EndOrigin[1]);
		VictimOrigin[2] = float(EndOrigin[2]);
		
		if(get_user_health(Victim) - get_pcvar_float(etherealdamage) >= 1 && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id)) {
			make_blood(VictimOrigin, get_pcvar_float(etherealdamage), Victim);
			make_knockback(Victim, VictimOrigin, get_pcvar_float(etherealknockback)*get_pcvar_float(etherealdamage));
			
			ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_NERVEGAS);
			
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
			write_byte(0);
			write_byte(255);
			write_byte(0);
			write_byte(100) ;
			message_end();
			
			message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, Victim);
			write_short(0xFFFF);
			write_short(1<<13);
			write_short(0xFFFF) ;
			message_end();
		}
		else if(get_user_health(Victim) - get_pcvar_float(etherealdamage) < 1 && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id)) {
			make_blood(VictimOrigin, get_pcvar_float(etherealdamage), Victim);
			make_knockback(Victim, VictimOrigin, get_pcvar_float(etherealknockback)*get_pcvar_float(etherealdamage));
			
			death_message(id, Victim, 1, "ethereal");
		}
	}
	else {
		static ClassName[32];
		pev(Victim, pev_classname, ClassName, charsmax(ClassName));
		if(equal(ClassName, "func_breakable")) {		
			if(entity_get_float(Victim, EV_FL_health) <= get_pcvar_num(etherealdamage)) {
				force_use(id, Victim);
			}
		}
	}
	
	emit_sound(id, CHAN_WEAPON, ethereal_sound[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

stock make_blood(const Float:vTraceEnd[3], Float:Damage, hitEnt) {
	new bloodColor = ExecuteHam(Ham_BloodColor, hitEnt);
	if(bloodColor == -1)
		return;
	
	new amount = floatround(Damage);
	
	amount *= 2; //according to HLSDK
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSPRITE);
	write_coord(floatround(vTraceEnd[0]));
	write_coord(floatround(vTraceEnd[1]));
	write_coord(floatround(vTraceEnd[2]));
	write_short(BloodSpray);
	write_short(BloodDrop);
	write_byte(bloodColor);
	write_byte(min(max(3, amount/10), 16));
	message_end();
}

// Make knockback
public make_knockback(Victim, Float:origin[3], Float:maxspeed) {
	// Get and set velocity
	new Float:fVelocity[3];
	kickback(Victim, origin, maxspeed, fVelocity);
	entity_set_vector(Victim, EV_VEC_velocity, fVelocity);
	
	return(1);
}

// Extra calulation for knockback
stock kickback(ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3]) {
	// Find origin
	new Float:fEntOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fEntOrigin);
	
	// Do some calculations
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	new Float:fTime =(vector_distance(fEntOrigin,fOrigin) / fSpeed);
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;
	
	return(fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

stock death_message(Killer, Victim, ScoreBoard, const Weapon[]) {
	// Block death msg
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
	ExecuteHamB(Ham_Killed, Victim, Killer, 2);
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);
	
	// Death
	make_deathmsg(Killer, Victim, 0, Weapon);
	cs_set_user_money(Killer, cs_get_user_money(Killer) + 300);
	
	// Update score board
	if(ScoreBoard) {
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Killer); // id
		write_short(pev(Killer, pev_frags)); // frags
		write_short(cs_get_user_deaths(Killer)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Killer)); // team
		message_end();
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Victim); // id
		write_short(pev(Victim, pev_frags)); // frags
		write_short(cs_get_user_deaths(Victim)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Victim)); // team
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
		case HIT_HEAD: damage *= 4.0;
			case HIT_STOMACH: damage *= 1.1;
			case HIT_CHEST: damage *= 1.5;
			case HIT_LEFTARM: damage *= 0.77;
			case HIT_RIGHTARM: damage *= 0.77;
			case HIT_LEFTLEG: damage *= 0.75;
			case HIT_RIGHTLEG: damage *= 0.75;
			default: damage *= 1.0;
	}
	
	return floatround(damage);
}	

stock fm_get_user_bpammo(index, weapon) {
	static offset
	switch(weapon) {
		case CSW_AWP: offset = OFFSET_AMMO_338MAGNUM
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = OFFSET_AMMO_762NATO
			case CSW_M249: offset = OFFSET_AMMO_556NATOBOX
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, 
			CSW_SG550, CSW_GALI, CSW_SG552: offset = OFFSET_AMMO_556NATO
		case CSW_M3, CSW_XM1014: offset = OFFSET_AMMO_BUCKSHOT
			case CSW_USP, CSW_UMP45, CSW_MAC10: offset = OFFSET_AMMO_45ACP
			case CSW_FIVESEVEN, CSW_P90: offset = OFFSET_AMMO_57MM
			case CSW_DEAGLE: offset = OFFSET_AMMO_50AE
			case CSW_P228: offset = OFFSET_AMMO_357SIG
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, 
			CSW_MP5NAVY: offset = OFFSET_AMMO_9MM
		default: offset = 0
	}
	return offset ? get_pdata_int(index, offset) : 0
}

stock fm_set_user_bpammo(index, weapon, amount) {
	static offset
	switch(weapon) {
		case CSW_AWP: offset = OFFSET_AMMO_338MAGNUM
			case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = OFFSET_AMMO_762NATO
			case CSW_M249: offset = OFFSET_AMMO_556NATOBOX
			case CSW_FAMAS, CSW_M4A1, CSW_AUG, 
			CSW_SG550, CSW_GALI, CSW_SG552: offset = OFFSET_AMMO_556NATO
		case CSW_M3, CSW_XM1014: offset = OFFSET_AMMO_BUCKSHOT
			case CSW_USP, CSW_UMP45, CSW_MAC10: offset = OFFSET_AMMO_45ACP
			case CSW_FIVESEVEN, CSW_P90: offset = OFFSET_AMMO_57MM
			case CSW_DEAGLE: offset = OFFSET_AMMO_50AE
			case CSW_P228: offset = OFFSET_AMMO_357SIG
			case CSW_GLOCK18, CSW_TMP, CSW_ELITE, 
			CSW_MP5NAVY: offset = OFFSET_AMMO_9MM
		default: offset = 0
	}
	
	if(offset) 
		set_pdata_int(index, offset, amount)
	
	return 1
}

// Get Weapon Entity's CSW_ ID
stock fm_get_weapon_ent_id(ent) {
	return get_pdata_int(ent, OFFSET_WEAPONID, 4);
}

// Get Weapon Entity's Owner
stock fm_get_weapon_ent_owner(ent) {
	return get_pdata_cbase(ent, 41, 4);
}
/*
// Drop all primary guns
stock drop_primary_weapons(Player) {
	// Get user weapons
	static weapons[32], num, i, weaponid;
	num = 0; // reset passed weapons count(bugfix)
	get_user_weapons(Player, weapons, num);
	
	// Loop through them and drop primaries
	for(i = 0; i < num; i++) {
		// Prevent re-indexing the array
		weaponid = weapons [i];
		
		// We definetely are holding primary gun
		if(((1<<weaponid) & PRIMARY_WEAPONS_BITSUM)) {
			// Get weapon entity
			static wname[32];
			get_weaponname(weaponid, wname, charsmax(wname));
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(Player, "drop", wname);
		}
	}
}
*/
stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "^x04", "^4");
	replace_all(msg, 190, "^x01", "^1");
	replace_all(msg, 190, "^x03", "^3");
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	} 
}

//------| Parecache Sounds and Models |------//
public plugin_precache() {
	BloodSpray = precache_model("sprites/bloodspray.spr");   // initial blood
	BloodDrop  = precache_model("sprites/blood.spr");	// splattered blood
	
	ethereal_trail = precache_model("sprites/ethereal_beam.spr");
	ethereal_explode = precache_model("sprites/ethereal_exp.spr");
	
	precache_model(EtherealModel_V);
	precache_model(EtherealModel_P);
	precache_model(EtherealModel_W);	
	
	new i;
	for(i = 0; i < sizeof(ethereal_sound); i++)
		engfunc(EngFunc_PrecacheSound, ethereal_sound[i]);	
	
	for(i = 0; i < sizeof(ethereal_generic); i++)
		engfunc(EngFunc_PrecacheGeneric, ethereal_generic[i]);	
	
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
