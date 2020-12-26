/* AMX Mod script
* 
* (c) 2013, Alicx[{DARK}((-__-))]
* 
*
*/

#define PLUGIN "Golden MP5 Navy"

#include <amxmodx>
#include <cstrike>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <engine>
#include <hamsandwich>

#define is_valid_player(%1) (1 <= %1 <= 32)

#define OLD_W_MODEL "models/w_galil.mdl"

#define EV_INT_WEAPONKEY	EV_INT_impulse
#define WEAPONKEY		93707521

new MP5_V_MODEL[64] = "models/[GeekGamers]/Primary/v_guitar_xmas.mdl"
new MP5_P_MODEL[64] = "models/[GeekGamers]/Primary/p_guitar_xmas.mdl"
new MP5_W_MODEL[64] = "models/[GeekGamers]/Primary/w_guitar_xmas.mdl"

/* Pcvars */
new cvar_dmgmultiplier, cvar_goldbullets,  cvar_custommodel, cvar_uclip, cvar_cost

new bool:g_HasMP5[33]

new g_hasZoom[ 33 ]
new bullets[ 33 ]

// Sprite
new m_spriteTexture

const Wep_mp5navy = ((1<<CSW_GALIL))

public plugin_init()
{
	// Register The Plugin
	register_plugin("Golden MP5 NAVY", "1.0", "Alicx DarK")

	/* CVARS */
	cvar_dmgmultiplier = register_cvar("goldenmp5_dmg_multiplier", "1.2")
	cvar_custommodel = register_cvar("goldenmp5_custom_model", "1")
	cvar_goldbullets = register_cvar("goldenmp5_gold_bullets", "1")
	cvar_uclip = register_cvar("goldenmp5_unlimited_clip", "1")
	cvar_cost = register_cvar("goldenmp5_cost", "0")
	
	// Register The Buy Cmd
	//register_clcmd("say /goldenmp5", "CmdBuyMP5")
	//register_clcmd("say_team /goldenmp5", "CmdBuyMP5")
	register_concmd("amx_goldenmp5", "CmdGiveMP5", ADMIN_LEVEL_B, "<name>")

	// Weapon Pick Up
	register_event("WeapPickup","checkModel","b","1=19")

	// Current Weapon Event
	register_event("CurWeapon","checkWeapon","be","1=1")
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")

	// Ham TakeDamage
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
	RegisterHam(Ham_Item_AddToPlayer, "weapon_galil", "fw_Item_AddToPlayer_Post", 1)

	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_CmdStart, "fw_CmdStart")
}

public plugin_natives()
{
	register_native("gg_set_user_goldmp5navy", "CmdBuyMP5", 1);
}

public PlayerSpawn(id)
{
	g_HasMP5[id] = false
}

public plugin_precache()
{
	precache_model(MP5_V_MODEL)
	precache_model(MP5_P_MODEL)
	precache_model(MP5_W_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
	precache_sound("weapons/zoom.wav")
}

public checkModel(id)
{
	if ( !g_HasMP5[id] )
		return PLUGIN_HANDLED
	
	new szWeapID = read_data(2)
	
	if ( szWeapID == CSW_GALIL && g_HasMP5[id] && get_pcvar_num(cvar_custommodel) )
	{
		set_pev(id, pev_viewmodel2, MP5_V_MODEL)
		set_pev(id, pev_weaponmodel2, MP5_P_MODEL)
	}
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId
	
	plrWeapId = get_user_weapon(id, plrClip , plrAmmo)
	
	if (plrWeapId == CSW_GALIL && g_HasMP5[id])
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
	if ( is_valid_player( attacker ) && get_user_weapon(attacker) == CSW_GALIL && g_HasMP5[attacker] )
	{
		SetHamParamFloat(4, damage * get_pcvar_float( cvar_dmgmultiplier ) )
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
		
		if( szWeapID == CSW_GALIL && g_HasMP5[id] == true && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 0 )
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 )
		}
		
		else if ( szWeapID == CSW_GALIL && g_HasMP5[id] == true && g_hasZoom[id])
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
		static weapon; weapon = fm_find_ent_by_owner(-1, "weapon_galil", entity)
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED;
		
		if(g_HasMP5[iOwner])
		{
			g_HasMP5[iOwner] = false
			
			set_pev(weapon, pev_impulse, WEAPONKEY)
			engfunc(EngFunc_SetModel, entity, MP5_W_MODEL)
			
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
		g_HasMP5[id] = true
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
		
		if ((bullets[id] > clip) && (wpnid == CSW_GALIL) && g_HasMP5[id]) 
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
			write_byte( 165 )     // r, g, b
			write_byte( 42 )       // r, g, b
			write_byte( 42 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
		
		bullets[id] = clip
	}
	
}

public CmdBuyMP5(id)
{
	if ( !is_user_alive(id) )
	{
		client_print(id,print_chat, "[AMXX] To buy golden MP5 Navy You need to be alive!")
		return PLUGIN_HANDLED
	}
	
	new money = cs_get_user_money(id)
	
	if (money >= get_pcvar_num(cvar_cost))
	{
		cs_set_user_money(id, money - get_pcvar_num(cvar_cost))
		give_item(id, "weapon_galil")
		g_HasMP5[id] = true
	}
	
	else
	{
		client_print(id, print_chat, "[AMXX] You dont hav enough money to buy Golden MP5 Navy. Cost $%d ", get_pcvar_num(cvar_cost))
	}
	return PLUGIN_HANDLED
}

public CmdGiveMP5(id,level,cid)
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
	
	give_item(player, "weapon_galil")
	g_HasMP5[player] = true
	
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
