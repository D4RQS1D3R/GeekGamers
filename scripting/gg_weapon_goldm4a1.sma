

/* AMX Mod script
* 
* (c) 2013, Alicx[{DARK}((-__-))]
* 
*
*/

#define PLUGIN "Golden M4a1"

#include <amxmodx>
#include <cstrike>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <engine>
#include <hamsandwich>

#define is_valid_player(%1) (1 <= %1 <= 32)

#define OLD_W_MODEL "models/w_m4a1.mdl"

#define EV_INT_WEAPONKEY	EV_INT_impulse
#define WEAPONKEY		37285041

new M4_V_MODEL[64] = "models/[GeekGamers]/Primary/v_golden_m4a1.mdl"
new M4_P_MODEL[64] = "models/[GeekGamers]/Primary/p_golden_m4a1.mdl"
new M4_W_MODEL[64] = "models/[GeekGamers]/Primary/w_golden_m4a1.mdl"

/* Pcvars */
new cvar_bonusdmg, cvar_goldbullets,  cvar_custommodel, cvar_uclip, cvar_cost

new bool:g_HasM4[33]

new g_hasZoom[ 33 ]
new bullets[ 33 ]

// Sprite
new m_spriteTexture

const Wep_m4a1 = ((1<<CSW_M4A1))

public plugin_init()
{
	// Register The Plugin
	register_plugin("Golden M4A1", "1.0", "Alicx DarK")

	/* CVARS */
	cvar_bonusdmg = register_cvar("goldenm4_bonus_dmg", "2.0")
	cvar_custommodel = register_cvar("goldenm4_custom_model", "1")
	cvar_goldbullets = register_cvar("goldenm4_gold_bullets", "1")
	cvar_uclip = register_cvar("goldenm4_unlimited_clip", "1")
	cvar_cost = register_cvar("goldenm4_cost", "0")
	
	// Register The Buy Cmd
	//register_clcmd("say /goldenm4", "CmdBuyM4")
	//register_clcmd("say_team /goldenm4", "CmdBuyM4")
	register_concmd("amx_goldenm4", "CmdGiveM4", ADMIN_LEVEL_B, "<name>")

	// Weapon Pick Up
	register_event("WeapPickup","checkModel","b","1=19")

	// Current Weapon Event
	register_event("CurWeapon","checkWeapon","be","1=1")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")

	// Ham TakeDamage
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m4a1", "fw_Item_AddToPlayer_Post", 1)

	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
}

public plugin_natives()
{
	register_native("gg_set_user_goldm4a1", "CmdBuyM4", 1);
}

public PlayerSpawn(id)
{
	g_HasM4[id] = false
}

public plugin_precache()
{
	precache_model(M4_V_MODEL)
	precache_model(M4_P_MODEL)
	precache_model(M4_W_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
	precache_sound("weapons/zoom.wav")
}

public checkModel(id)
{
	if ( !g_HasM4[id] )
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	
	if ( szWeapID == CSW_M4A1 && g_HasM4[id] && get_pcvar_num(cvar_custommodel) )
	{
		set_pev(id, pev_viewmodel2, M4_V_MODEL)
		set_pev(id, pev_weaponmodel2, M4_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_M4A1 && g_HasM4[id])
	{
		checkModel(id)
	}
	else 
	{
		return PLUGIN_CONTINUE
	}
	
	if (plrClip == 0 && get_pcvar_num(cvar_uclip))
	{
		// If the user is out of ammo..
		get_weaponname(plrWeapId, plrWeap, 31)
		// Get the name of their weapon
		give_item(id, plrWeap)
		engclient_cmd(id, plrWeap) 
		engclient_cmd(id, plrWeap)
		engclient_cmd(id, plrWeap)
	}
	return PLUGIN_HANDLED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if ( is_valid_player( attacker ) && get_user_weapon(attacker) == CSW_M4A1 && g_HasM4[attacker] )
	{
		SetHamParamFloat(4, damage + get_pcvar_float( cvar_bonusdmg ) )
	}
}

public fw_CmdStart( id, uc_handle, seed )
{
	if( !is_user_alive( id ) ) 
		return PLUGIN_HANDLED
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) )
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon( id, szClip, szAmmo )
		
		if( szWeapID == CSW_M4A1 && g_HasM4[id] == true && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 0 )
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 )
		}
		
		else if ( szWeapID == CSW_M4A1 && g_HasM4[id] == true && g_hasZoom[id])
		{
			g_hasZoom[ id ] = false
			cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
			
		}
		
	}
	return PLUGIN_HANDLED
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED
	
	static Classname[32]
	pev(entity, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	iOwner = pev(entity, pev_owner)
	
	if(equal(model, OLD_W_MODEL))
	{
		static weapon; weapon = fm_find_ent_by_owner(-1, "weapon_m4a1", entity)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED;
		
		if(g_HasM4[iOwner])
		{
			g_HasM4[iOwner] = false
			
			set_pev(weapon, pev_impulse, WEAPONKEY)
			engfunc(EngFunc_SetModel, entity, M4_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}

public fw_Item_AddToPlayer_Post(ent, id)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
		
	if(entity_get_int(ent, EV_INT_WEAPONKEY) == WEAPONKEY)
	{
		g_HasM4[id] = true
		set_pev(ent, pev_impulse, 0)
		
		entity_set_int(ent, EV_INT_WEAPONKEY, 0)

		return HAM_HANDLED
	}

	return HAM_HANDLED	
}

public make_tracer(id)
{
	if (get_pcvar_num(cvar_goldbullets))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		new pteam[16]
		
		get_user_team(id, pteam, 15)
		
		if ((bullets[id] > clip) && (wpnid == CSW_M4A1) && g_HasM4[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			
			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short( m_spriteTexture )
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte( 255 )     // r, g, b
			write_byte( 215 )       // r, g, b
			write_byte( 0 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
		
		bullets[id] = clip
	}
	
}

public CmdBuyM4(id)
{
	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "[AMXX] To buy golden M4a1 You need to be alive!")
		return PLUGIN_HANDLED
	}
	
	new money = cs_get_user_money(id)
	
	if (money >= get_pcvar_num(cvar_cost))
	{
		cs_set_user_money(id, money - get_pcvar_num(cvar_cost))
		give_item(id, "weapon_m4a1")
		g_HasM4[id] = true
	}
	
	else
	{
		client_print(id, print_chat, "[AMXX] You dont hav enough money to buy Golden M4a1. Cost $%d ", get_pcvar_num(cvar_cost))
	}
	return PLUGIN_HANDLED
}

public CmdGiveM4(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED;
	new arg[32];
	read_argv(1,arg,31);
	
	new player = cmd_target(id,arg,7);
	if (!player) 
		return PLUGIN_HANDLED;
	
	new name[32];
	get_user_name(player,name,31);
	
	give_item(player, "weapon_m4a1")
	g_HasM4[player] = true
	
	return PLUGIN_HANDLED
}

stock drop_prim(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (Wep_m4a1 & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
