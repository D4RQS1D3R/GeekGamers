#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>
#include <fcs>

#pragma compress 1

#define PLUGIN "[GG] Bonus Box"
#define VERSION "1.0"
#define AUTHOR "Laur" // Edited By ~DarkSiDeRs~

#define ADMIN_LEVEL ADMIN_LEVEL_F

new CvarFurienSpeed, CvarAntiFurienSpeed;
new bool:HasSpeed[33], bool:HasTeleport[33];
new const ClassName[] = "BonusBox"
new const RareClassName[] = "RareBonusBox"
new Model[3][] = {
	"models/[GeekGamers]/box_furien.mdl",
	"models/[GeekGamers]/box_anti_furien.mdl",
	"models/[GeekGamers]/box_rare.mdl"
}

new Sprite, Sprite2
new Teleport_Cooldown[33]
new CvarTeleportCooldown, CvarTeleportRange, CvarFadeTime, CvarColor
new maxhealth, maxarmor
new const SOUND_BLINK[] = { "weapons/flashbang-1.wav" }
const UNIT_SEC = 0x1000
const FFADE = 0x0000

#define FFADE_IN		0x0000		// Just here so we don't pass 0 into the function
#define FFADE_OUT		0x0001		// Fade out (not in)
#define FFADE_MODULATE	0x0002		// Modulate (don't blend)
#define FFADE_STAYOUT	0x0004		// ignores the duration, stays faded out until new ScreenFade message received

enum {
	Red,
	Green,
	Blue
};

enum _:Angle_t { Float:Pitch, Float:Yaw, Float:Roll };
enum _:Coord_t { Float:x, Float:y, Float:z };

#define VectorMA(%0,%1,%2,%3) ( %3[ x ] = %0[ x ] + %1 * %2[ x ], %3[ y ] = %0[ y ] + %1 * %2[ y ], %3[ z ] = %0[ z ] + %1 * %2[ z ] )

native assassin_mod(id)
native sniper_mod(id)
native avs_mod(id)
native ghost_mod(id)
native plasma_mod(id)
native random_mod(id)

native gg_get_user_compoundbow(id)
native gg_set_user_compoundbow(id, ammo)

native is_registered(id)
native WhiteListed(const PlayerName[]);

public plugin_init()
{	
	register_plugin( PLUGIN, VERSION, AUTHOR )

	register_event("HLTV", "RoundStart", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_cur_weapon", "be", "1=1")

	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	RegisterHam(Ham_Killed, "player", "Death")
	RegisterHam(Ham_Touch, "info_target", "Touch") 


	register_forward(FM_CmdStart, "CmdStart")
	// register_forward(FM_Touch, "Touch")

	CvarFurienSpeed = register_cvar("amx_bonusbox_furien_speed", "800")
	CvarAntiFurienSpeed = register_cvar("amx_bonusbox_antifurien_speed", "350")
	CvarTeleportCooldown = register_cvar("bh_teleport_cooldown", "40")
	CvarTeleportRange = register_cvar("bh_bonusbox_teleport_range", "123456789")
	CvarFadeTime = register_cvar("amx_bonusbox_teleport_fadetime", "1.5")
	CvarColor = register_cvar("amx_bonusbox_teleport_color", "255255255")
	maxhealth = register_cvar("amx_bonusbox_maxhealth", "200")
	maxarmor = register_cvar("amx_bonusbox_maxarmor", "200")

	register_clcmd("power2", "CmdTeleport")
	//register_clcmd("spawnbox", "AddBonusBoxBySide")
}

public plugin_precache() {
	for (new i = 0; i < sizeof Model; i++)
		precache_model(Model[i])
	
	Sprite = precache_model( "sprites/shockwave.spr")
	Sprite2 = precache_model( "sprites/blueflare2.spr")
}

public RoundStart()
{
	for(new id = 1; id < get_maxplayers();id++)
	{
		HasSpeed[id] = false
		HasTeleport[id] = false	
	}
}

public Spawn(id)
{
	HasSpeed[id] = false
	HasTeleport[id] = false	
}

public Death(const victim, const attacker)
{
	AddBonusBox(victim)
	return HAM_IGNORED
}

public CmdStart(id, uc_handle, seed) {
	new ent = fm_find_ent_by_class(id, ClassName)
	if(is_valid_ent(ent)) {
		new classname[32]	
		pev(ent, pev_classname, classname, 31)
		if (equal(classname, ClassName)) {
			
			if (pev(ent, pev_frame) >= 120)
				set_pev(ent, pev_frame, 0.0)
			else
				set_pev(ent, pev_frame, pev(ent, pev_frame) + 1.0)
			
			switch(pev(ent, pev_team))
			{
				case 1: 
				{ 	
				}	
				case 2: 
				{ 
				}
			}
		}
	}

	new ent_rare = fm_find_ent_by_class(id, RareClassName)
	if(is_valid_ent(ent_rare)) {
		new classname[32]	
		pev(ent_rare, pev_classname, classname, 31)
		if (equal(classname, RareClassName)) {
			
			if (pev(ent_rare, pev_frame) >= 120)
				set_pev(ent_rare, pev_frame, 0.0)
			else
				set_pev(ent_rare, pev_frame, pev(ent_rare, pev_frame) + 1.0)
			
			switch(pev(ent_rare, pev_team))
			{
				case 1: 
				{ 	
				}	
				case 2: 
				{ 
				}
			}
		}
	}
}

public AddBonusBox(id)
{
	if(is_user_connected(id) && cs_get_user_team(id) != CS_TEAM_SPECTATOR)
	{
		new ent = fm_create_entity("info_target")

		new origin[3]
		get_user_origin(id, origin, 0)
		
		new RareBoxChance = random_num(1, 50000);
		if(RareBoxChance == 666)
		{
			set_pev(ent, pev_classname, RareClassName)
			engfunc(EngFunc_SetModel, ent, Model[2])
		}
		else
		{
			set_pev(ent, pev_classname, ClassName)
			switch(cs_get_user_team(id))
			{
				case CS_TEAM_T:
				{ 
					engfunc(EngFunc_SetModel, ent, Model[1])
					set_pev(ent, pev_team, 2)
				}
				case CS_TEAM_CT:
				{
					engfunc(EngFunc_SetModel, ent, Model[0])	
					set_pev(ent, pev_team, 1)
				}
			}
		}

		set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0})
		set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0})
		set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0})
		engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0})
		
		set_pev(ent,pev_solid,SOLID_TRIGGER)
		set_pev(ent,pev_movetype,MOVETYPE_TOSS)
		
		new Float:fOrigin[3]
		IVecFVec(origin, fOrigin)
		set_pev(ent, pev_origin, fOrigin)
	}
}
/*
public AddBonusBoxBySide(id)
{
	if(is_user_connected(id) && cs_get_user_team(id) != CS_TEAM_SPECTATOR)
	{
		new ent = fm_create_entity("info_target")
		
		new Float:origin[Coord_t]
		new Float:dirForward[Coord_t]
		new Float:viewAngles[Angle_t]
		
		pev(id, pev_origin, origin)
		pev(id, pev_v_angle, viewAngles)
		
		engfunc(EngFunc_MakeVectors, viewAngles)
		global_get(glb_v_forward, dirForward)
		
		VectorMA(origin, 150.0, dirForward, origin)
		
		set_pev(ent,pev_classname, ClassName)
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_T:
			{ 
				engfunc(EngFunc_SetModel, ent, Model[1])
				set_pev(ent, pev_team, 2)
			}
			case CS_TEAM_CT:
			{
				engfunc(EngFunc_SetModel, ent, Model[0])	
				set_pev(ent, pev_team, 1)
			}
		}
		set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0})
		set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0})
		set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0})
		engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0})
		
		set_pev(ent,pev_solid,SOLID_TRIGGER)
		set_pev(ent,pev_movetype,MOVETYPE_TOSS)
		
		set_pev(ent, pev_origin, origin)
	}
}
*/
public Touch(touched, toucher)
{
	if (!is_user_alive(toucher) || !pev_valid(touched))
		return FMRES_IGNORED
	
	new classname[32]	
	pev(touched, pev_classname, classname, 31)

	if (!equal(classname, ClassName) && !equal(classname, RareClassName))
		return FMRES_IGNORED
	
	if (equal(classname, RareClassName))
	{
		static name[32]; get_user_name(toucher, name, charsmax(name) - 1);
		if(!WhiteListed(name))
		{
			GiveRareBonus(toucher)
			set_pev(touched, pev_effects, EF_NODRAW)
			set_pev(touched, pev_solid, SOLID_NOT)
			remove_entity(touched);
		}
	}
	else
	{
		if(get_user_team(toucher) == pev(touched, pev_team))
		{
			GiveBonus(toucher)
			set_pev(touched, pev_effects, EF_NODRAW)
			set_pev(touched, pev_solid, SOLID_NOT)
			remove_entity(touched);
		}
	}

	return FMRES_IGNORED
}

public event_cur_weapon(id)
{
	if(HasSpeed[id] && cs_get_user_team(id) == CS_TEAM_T && get_user_maxspeed(id) < get_pcvar_float(CvarFurienSpeed))
		set_user_maxspeed(id, get_pcvar_float(CvarFurienSpeed));

	if(HasSpeed[id] && cs_get_user_team(id) == CS_TEAM_CT && get_user_maxspeed(id) < get_pcvar_float(CvarAntiFurienSpeed))
		set_user_maxspeed(id, get_pcvar_float(CvarAntiFurienSpeed));
}

public ScreenFade(id)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<12);
	write_short(1);
	write_short(0x0000)
	write_byte(255)
	write_byte(215)
	write_byte(0)
	write_byte(75)
	message_end()
}

public GiveRareBonus(id)
{
	new iCredits = random_num(15000, 50000)
	fcs_set_user_credits( id, fcs_get_user_credits(id) + iCredits )
	ColorChat(id, "!t[GG][ Rare Bonus ]!y You Get!g %d Credits!y. !tWOOW HOW LUCKY!!!!!!", iCredits)

	if(!is_registered(id))
		ColorChat(id, "!t[GG][ IMPORTANT ]!y Please Register your UserName !gRIGHT AWAY !yBefore you lose your Credits!!!!!")

	ScreenFade(id)
}

public GiveBonus(id)
{
	switch (random_num(1, 18)) 
	{
		case 1: 
		{
			if( get_user_health(id) < get_pcvar_num(maxhealth) )
			{
				if( cs_get_user_team(id) == CS_TEAM_T )
				{
					new Health = 50
					fm_set_user_health(id, get_user_health(id) + Health)
					ColorChat(id, "!t[GG][ Bonus ]!y You Get !g%d Health!y.", Health)
					check_max_health(id)
				}
				else
				if( cs_get_user_team(id) == CS_TEAM_CT )
				{
					new Health = 65
					fm_set_user_health(id, get_user_health(id) + Health)
					ColorChat(id, "!t[GG][ Bonus ]!y You Get !g%d Health!y.", Health)
					check_max_health(id)
				}
			}
			else GiveBonus(id)
		}
		case 2: 
		{
			if(get_user_health(id) <= 50)
			{
				new Health = 100
				fm_set_user_health(id, get_user_health(id) + Health)
				ColorChat(id, "!t[GG][ Bonus ]!y You Get !g%d Health!y.", Health)
				check_max_health(id)
			}
			else GiveBonus(id);
		}
		case 3: 
		{
			new Armor = random_num(25, 100)
			fm_set_user_armor(id, get_user_armor(id) + Armor)
			ColorChat(id, "!t[GG][ Bonus ]!y You Get !g%d Armor!y.", Armor)
			check_max_armor(id)
		}
		case 4..5:
		{
			if(!user_has_weapon(id, CSW_HEGRENADE)) {
				fm_give_item(id, "weapon_hegrenade")
			}
			else {
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1);
			}
			ColorChat(id, "!t[GG][ Bonus ]!y You Get a !gFireNade!y.")
		}
		case 6:
		{
			if(!user_has_weapon(id, CSW_SMOKEGRENADE)) {
				fm_give_item(id, "weapon_smokegrenade")
			}
			else {
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1);
			}
			ColorChat(id, "!t[GG][ Bonus ]!y You Get a !gFrostNade!y.")
		}
		case 7:
		{
			if(!HasSpeed[id])
			{
				if( cs_get_user_team(id) == CS_TEAM_T )
				{
					HasSpeed[id] = true;
					client_cmd(id, "cl_sidespeed %d",get_pcvar_float(CvarFurienSpeed))
					client_cmd(id, "cl_forwardspeed %d",get_pcvar_float(CvarFurienSpeed))
					client_cmd(id, "cl_backspeed %d",get_pcvar_float(CvarFurienSpeed))
					set_user_maxspeed(id, get_pcvar_float(CvarFurienSpeed));
					ColorChat(id, "!t[GG][ Bonus ]!y You Get !gSpeed Boost!y.")
				}
				else
				if( cs_get_user_team(id) == CS_TEAM_CT )
				{
					HasSpeed[id] = true;
					client_cmd(id, "cl_sidespeed %d",get_pcvar_float(CvarAntiFurienSpeed))
					client_cmd(id, "cl_forwardspeed %d",get_pcvar_float(CvarAntiFurienSpeed))
					client_cmd(id, "cl_backspeed %d",get_pcvar_float(CvarAntiFurienSpeed))
					set_user_maxspeed(id, get_pcvar_float(CvarAntiFurienSpeed));
					ColorChat(id, "!t[GG][ Bonus ]!y You Get !gSpeed Boost!y.")
				}
			}
			else GiveBonus(id)
		}
		case 8:
		{
			if(!HasTeleport[id])
			{
				HasTeleport[id] = true;
				force_cmd(id, "bind alt ^"power2^"");
				ColorChat(id, "!t[GG][ Bonus ]!y You Get !gTeleport Power !t- !yPress ALT !g(bind alt power2)")
			}
			else GiveBonus(id)
		}
		case 9..11:
		{
			new Money = random_num(1, 1500)
			cs_set_user_money(id, cs_get_user_money(id) + Money)
			ColorChat(id, "!t[GG][ Bonus ]!y You Get Money !g$%d!y.", Money)
		}
		case 12:
		{
			if( gg_get_user_compoundbow(id) || assassin_mod(id) || sniper_mod(id) || avs_mod(id) || ghost_mod(id) || plasma_mod(id) )
			{
				GiveBonus(id)
				return
			}

			if( cs_get_user_team(id) == CS_TEAM_T && get_user_flags(id) & ADMIN_LEVEL )
			{
				new Arrows = random_num(2, 10);
				gg_set_user_compoundbow(id, Arrows)
				ColorChat(id, "!t[GG][ Bonus ]!y You Get a !gCompound Bow !ywith !g%d Arrows!y.", Arrows)
			}
			else GiveBonus(id)
		}
		case 13..14:
		{
			new iCredits = random_num(1, 10)
			fcs_set_user_credits( id, fcs_get_user_credits(id) + iCredits )
			ColorChat(id, "!t[GG][ Bonus ]!y You Get!g %d Credits!y.", iCredits)
		}
		case 15:
		{
			new iCredits = random_num(10, 25)
			fcs_set_user_credits( id, fcs_get_user_credits(id) + iCredits )
			ColorChat(id, "!t[GG][ Bonus ]!y You Get!g %d Credits!y.", iCredits)
		}
		case 16..18:
		{
			ColorChat(id, "!t[GG][ Bonus ]!y YIKES, You Get !gNothing!y.")
		}
	}
}

public check_max_health(id)
{
	if(assassin_mod(id) || sniper_mod(id) || ghost_mod(id) || random_mod(id))
		return;

	if( get_user_health(id) > get_pcvar_num(maxhealth) )
		fm_set_user_health(id, get_pcvar_num(maxhealth))
}

public check_max_armor(id)
{
	if(assassin_mod(id) || sniper_mod(id) || ghost_mod(id) || random_mod(id))
		return;

	if( get_user_armor(id) > get_pcvar_num(maxarmor) )
		fm_set_user_armor(id, get_pcvar_num(maxarmor))
}

public CmdTeleport(id)
{
	if (!is_user_alive(id) || !HasTeleport[id]) return PLUGIN_CONTINUE
	
	if (Teleport_Cooldown[id])
	{
		ColorChat(id,"!t[GG][ Bonus ]!g Your Power Will return in:!t %d seconds.",Teleport_Cooldown[id]);
		return PLUGIN_CONTINUE
	}
	else
	if (teleport(id))
	{
		emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
		remove_task(id)
		Teleport_Cooldown[id] = get_pcvar_num(CvarTeleportCooldown);
		set_task(1.0, "ShowHUD", id, _, _, "b");
		set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
		if(get_pcvar_num(CvarTeleportCooldown) != 1)
		{
			show_hudmessage(id, "Your Power Will return in %d seconds.",get_pcvar_num(CvarTeleportCooldown));
		}

		if(get_pcvar_num(CvarTeleportCooldown) == 1)
		{
			show_hudmessage(id, "Your Power Will return in %d seconds.",get_pcvar_num(CvarTeleportCooldown));
		}
	}
	else
	{
		ColorChat(id, "!t[GG][ Bonus ]!g Position Teleportation is Invalid.")
	}

	return PLUGIN_CONTINUE
}

public ShowHUD(id)
{
	if (!is_user_alive(id) || !HasTeleport[id])
	{
		remove_task(id);
		Teleport_Cooldown[id] = 0;
		return PLUGIN_HANDLED;
	}

	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);

	if(is_user_alive(id) && Teleport_Cooldown[id] == 1)
	{
		Teleport_Cooldown[id] --;
		show_hudmessage(id, "Your Power Will return in %d seconds.",Teleport_Cooldown[id]);
	}
	if(is_user_alive(id) && Teleport_Cooldown[id] > 1)
	{
		Teleport_Cooldown[id] --;
		show_hudmessage(id, "Your Power Will return in %d seconds.",Teleport_Cooldown[id]);
	}
	if(Teleport_Cooldown[id] <= 0)
	{
		show_hudmessage(id, "You can use The Power again");
		ColorChat(id,"!t[GG][Furien]!g You can use The Power again.");
		remove_task(id);
		Teleport_Cooldown[id] = 0;
	}
	return PLUGIN_HANDLED;
}


bool:teleport(id)
{
	new Float:vOrigin[3], Float:vNewOrigin[3],
	Float:vNormal[3], Float:vTraceDirection[3],
	Float:vTraceEnd[3];
	
	pev(id, pev_origin, vOrigin);
	
	velocity_by_aim(id, get_pcvar_num(CvarTeleportRange), vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0);
	
	new Float:flFraction;
	get_tr2(0, TR_flFraction, flFraction);
	if (flFraction < 1.0) {
		get_tr2(0, TR_vecEndPos, vTraceEnd);
		get_tr2(0, TR_vecPlaneNormal, vNormal);
	}
	
	xs_vec_mul_scalar(vNormal, 40.0, vNormal); // do not decrease the 40.0
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin);
	
	if (is_player_stuck(id, vNewOrigin))
		return false;

	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM);
	tele_effect(vOrigin);
	
	engfunc(EngFunc_SetOrigin, id, vNewOrigin);
	
	tele_effect2(vNewOrigin);
	
	if(is_user_connected(id)) {
		UTIL_ScreenFade(id, get_color(CvarColor), get_pcvar_float(CvarFadeTime), get_pcvar_float(CvarFadeTime), 75)
	}
	return true;
}

stock is_player_stuck(id, Float:originF[3]) {
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock tele_effect(const Float:torigin[3]) {
	new origin[3];
	origin[0] = floatround(torigin[0]);
	origin[1] = floatround(torigin[1]);
	origin[2] = floatround(torigin[2]);
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+10);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+60);
	write_short(Sprite);
	write_byte(0);
	write_byte(0);
	write_byte(3);
	write_byte(60);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
}

stock tele_effect2(const Float:torigin[3]) {
	new origin[3];
	origin[0] = floatround(torigin[0]);
	origin[1] = floatround(torigin[1]);
	origin[2] = floatround(torigin[2]);
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+10);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+60);
	write_short(Sprite);
	write_byte(0);
	write_byte(0);
	write_byte(3);
	write_byte(60);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+40);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(Sprite2);
	write_byte(30);
	write_byte(10);
	write_byte(1);
	write_byte(50);
	write_byte(10);
	message_end();
}	

get_color(pcvar)
{
	new iColor[3], szColor[10]
	get_pcvar_string(pcvar, szColor, charsmax(szColor))
	new c = str_to_num(szColor)
	
	iColor[Red] = c / 1000000
	c %= 1000000
	iColor[Green] = c / 1000
	iColor[Blue] = c % 1000
	
	return iColor
}

stock FixedUnsigned16(Float:flValue, iScale)
{
	new iOutput;
	
	iOutput = floatround(flValue * iScale);
	if ( iOutput < 0 )
		iOutput = 0;
	
	if ( iOutput > 0xFFFF )
		iOutput = 0xFFFF;
	return iOutput;
}

stock UTIL_ScreenFade(id=0,iColor[3]={0,0,0},Float:flFxTime=-1.0,Float:flHoldTime=0.0,iAlpha=0,iFlags=FFADE_IN,bool:bReliable=false,bool:bExternal=false)
{
	if( id && !is_user_connected(id))
		return;
	
	new iFadeTime;
	if( flFxTime == -1.0 ) {
		iFadeTime = 4;
	}
	else {
		iFadeTime = FixedUnsigned16( flFxTime , 1<<12 );
	}
	
	static gmsgScreenFade;
	if( !gmsgScreenFade ) {
		gmsgScreenFade = get_user_msgid("ScreenFade");
	}
	
	new MSG_DEST;
	if( bReliable ) {
		MSG_DEST = id ? MSG_ONE : MSG_ALL;
	}
	else {
		MSG_DEST = id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST;
	}
	
	if( bExternal ) {
		emessage_begin( MSG_DEST, gmsgScreenFade, _, id );
		ewrite_short( iFadeTime );
		ewrite_short( FixedUnsigned16( flHoldTime , 1<<12 ) );
		ewrite_short( iFlags );
		ewrite_byte( iColor[Red] );
		ewrite_byte( iColor[Green] );
		ewrite_byte( iColor[Blue] );
		ewrite_byte( iAlpha );
		emessage_end();
	}
	else {
		message_begin( MSG_DEST, gmsgScreenFade, _, id );
		write_short( iFadeTime );
		write_short( FixedUnsigned16( flHoldTime , 1<<12 ) );
		write_short( iFlags );
		write_byte( iColor[Red] );
		write_byte( iColor[Green] );
		write_byte( iColor[Blue] );
		write_byte( iAlpha );
		message_end();
	}
}

stock UTIL_FadeToBlack(id,Float:fxtime=3.0,bool:bReliable=false,bool:bExternal=false)
{
	UTIL_ScreenFade(id, _, fxtime, fxtime, 255, FFADE_OUT|FFADE_STAYOUT,bReliable,bExternal);
}

public Light(entity, red, green, blue)
{	
	if(is_valid_ent(entity))
	{
		static Float:origin[3]
		pev(entity, pev_origin, origin)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, _, entity);
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, origin[0])
		engfunc(EngFunc_WriteCoord, origin[1])
		engfunc(EngFunc_WriteCoord, origin[2])
		write_byte(7) 
		write_byte(red)
		write_byte(green)
		write_byte(blue)
		write_byte(2)
		write_byte(0)
		message_end();
	}
}

stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	if( id == 0 || is_user_connected( id ) )
	{
		new szMessage[ 256 ];

		format_args( szMessage ,charsmax( szMessage ) , 1 );

		message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
		write_byte( strlen( szMessage ) + 2 )
		write_byte( 10 )
		write_string( szMessage )
		message_end()
	}
}

stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!t", "^3");
	
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
