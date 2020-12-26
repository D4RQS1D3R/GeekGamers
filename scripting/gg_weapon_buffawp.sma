#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

new const g_ViewModel[] 	= "models/[GeekGamers]/Primary/v_sniper_awp.mdl";
new const g_WeaponModel[] 	= "models/[GeekGamers]/Primary/p_sniper_awp.mdl";
new const g_WorldModel[] 	= "models/[GeekGamers]/Primary/w_sniper_awp.mdl";

new g_Wpn[33], g_Charge[33], g_Zoomed[33], g_Clip[33], g_Cvar[5], g_SyncHud[3], bullets[33], m_spriteTexture;

new const g_TaskIDs[] = { 500 }; // You Shouldn't Use the Same TaskID on Another Plugins! ( It Can Keep Away the Bugs. )

public plugin_init()
{
	register_plugin("[CSO] Wpn: AWP Elven Ranger", "1.1.0", "JohanCorn");
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack_Post", 1);
	RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_Item_AddToPlayer");
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_PostFrame, "weapon_awp", "fw_Item_PostFrame");
	RegisterHam(Ham_Weapon_Reload, "weapon_awp", "fw_Weapon_Reload");
	RegisterHam(Ham_Weapon_Reload, "weapon_awp", "fw_Weapon_Reload_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Killed, "player", "fw_Killed");
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg");
	
	register_clcmd("weapon_buffawp", "weapon_hook");
	//register_clcmd("say /get_buffawp", "cmdAdd");
	
	g_Cvar[0] = register_cvar("wpn_buffawp_charge_hud", "0");
	g_Cvar[1] = register_cvar("wpn_buffawp_multi_damage_none", "50.0");
	g_Cvar[2] = register_cvar("wpn_buffawp_multi_damage_yellow", "100.0");
	g_Cvar[3] = register_cvar("wpn_buffawp_multi_damage_orange", "150.0");
	g_Cvar[4] = register_cvar("wpn_buffawp_multi_damage_red", "200.0");
	
	register_event("SetFOV", "fw_SetFOV", "be");
	register_event("CurWeapon", "Make_Tracer", "be", "1=1", "3>0");
	
	g_SyncHud[0] = CreateHudSyncObj();
	g_SyncHud[1] = CreateHudSyncObj();
	g_SyncHud[2] = CreateHudSyncObj();
	
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1);
}

public plugin_natives()
{
	register_native("gg_has_user_buffawp", "cmdHas", 1);
	register_native("gg_set_user_buffawp", "cmdAdd", 1);
	register_native("gg_set_user_electroawp", "cmdAdd_10Shots", 1);
}

public plugin_precache()
{
	precache_model(g_ViewModel);
	precache_model(g_WeaponModel);
	precache_model(g_WorldModel);
	
	precache_sound("weapons/awpbuff_clipin.wav");
	precache_sound("weapons/awpbuff_clipout.wav");
	precache_sound("weapons/awpbuff_idle.wav");
	precache_sound("weapons/awpbuff_reload.wav");
	precache_sound("weapons/awpbuff-1.wav");
	
	precache_generic("sprites/weapon_buffawp.txt");
	precache_generic("sprites/640hud135.spr");
	m_spriteTexture = precache_model("sprites/dot.spr");
}

public HAM_Spawn_Post(id)
{
	g_Wpn[id] = 0;
	g_Zoomed[id] = 0;
}

public fw_TraceAttack_Post(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if ( !is_user_alive(iAttacker) )
		return;
 
	if ( !g_Wpn[iAttacker] )
		return;
	
	if ( get_user_weapon(iAttacker) != CSW_AWP )
		return;

	new Float:flEnd[3];
	get_tr2(ptr, TR_vecEndPos, flEnd);
	
	if ( iEnt )
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_DECAL);
		engfunc(EngFunc_WriteCoord, flEnd[0]);
		engfunc(EngFunc_WriteCoord, flEnd[1]);
		engfunc(EngFunc_WriteCoord, flEnd[2]);
		write_byte(random_num(41,45));
		write_short(iEnt);
		message_end();
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_WORLDDECAL);
		engfunc(EngFunc_WriteCoord, flEnd[0]);
		engfunc(EngFunc_WriteCoord, flEnd[1]);
		engfunc(EngFunc_WriteCoord, flEnd[2]);
		write_byte(random_num(41,45));
		message_end();
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_GUNSHOTDECAL);
	engfunc(EngFunc_WriteCoord, flEnd[0]);
	engfunc(EngFunc_WriteCoord, flEnd[1]);
	engfunc(EngFunc_WriteCoord, flEnd[2]);
	write_short(iAttacker);
	write_byte(random_num(41,45));
	message_end();
}

public fw_Item_AddToPlayer(entity, id)
{
	if ( !is_valid_ent(entity) )
		return HAM_IGNORED;
		
	if ( !is_user_connected(id) )
		return HAM_IGNORED;
		
	if ( !is_user_alive(id) )
		return HAM_IGNORED;
		
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id);
 
	if ( entity_get_int(entity, EV_INT_impulse) == 20160918 )
	{
		g_Wpn[id] = 1;
 
		entity_set_int(entity, EV_INT_impulse, 0);
		entity_set_int(entity, EV_INT_iuser1, 0);
 
		write_string("weapon_buffawp");
	}
	else
		write_string("weapon_awp");
	
	write_byte(1);
	write_byte(30);
	write_byte(-1);
	write_byte(-1);
	write_byte(0);
	write_byte(2);
	write_byte(CSW_AWP);
	write_byte(0);
	message_end();
 
	return HAM_IGNORED;
}

public fw_Item_Deploy_Post(entity)
{
	if ( !is_valid_ent(entity) )
		return HAM_IGNORED;
	
	new id = get_pdata_cbase(entity, 41, 4);
		
	if ( !is_user_connected(id) )
		return HAM_IGNORED;
		
	if ( !is_user_alive(id) )
		return HAM_IGNORED;
	
	if ( !g_Wpn[id] )
		return HAM_IGNORED;
	
	set_pev(id, pev_viewmodel2, g_ViewModel);
	set_pev(id, pev_weaponmodel2, g_WeaponModel);
	
	UTIL_PlayWeaponAnimation(id, 5);
	
	return HAM_IGNORED;
}

public fw_Item_PostFrame(entity) 
{
	if ( !is_valid_ent(entity) )
		return HAM_IGNORED;
	
	new id = get_pdata_cbase(entity, 41, 4);
		
	if ( !is_user_connected(id) )
		return HAM_IGNORED;
		
	if ( !is_user_alive(id) )
		return HAM_IGNORED;
	
	if ( !g_Wpn[id] )
		return HAM_IGNORED;
	
	new iBpAmmo = cs_get_user_bpammo(id, CSW_AWP);
	new iClip = get_pdata_int(entity, 51, 4);
	
	if ( get_pdata_int(entity, 54, 4) && get_pdata_float(id, 83, 5) <= 0.0 )
	{
		new j = min(20 - iClip, iBpAmmo);
		set_pdata_int(entity, 51, iClip + j, 4);
		cs_set_user_bpammo(id, CSW_AWP, iBpAmmo-j);
		set_pdata_int(entity, 54, 0, 4);
	}
	
	return HAM_IGNORED;
}

public fw_Weapon_Reload(entity) 
{
	if ( !is_valid_ent(entity) )
		return HAM_IGNORED;
	
	new id = get_pdata_cbase(entity, 41, 4);
		
	if ( !is_user_connected(id) )
		return HAM_IGNORED;
		
	if ( !is_user_alive(id) )
		return HAM_IGNORED;
	
	if ( !g_Wpn[id] )
		return HAM_IGNORED;
	
	if ( !cs_get_user_bpammo(id, CSW_AWP) )
		return HAM_SUPERCEDE;
		
	g_Clip[id] = -1;
		
	new iClip = get_pdata_int(entity, 51, 4);
	
	if ( iClip >= 20 )
		return HAM_SUPERCEDE;
		
	g_Clip[id] = iClip;

	static idd; idd = pev(entity, pev_owner)

	if( g_Wpn[idd] )
	{
		if( cs_get_user_bpammo(idd, CSW_AWP) <= 1 )
		{
			new clip2, ammo2;
			get_user_ammo(idd, CSW_AWP, clip2, ammo2);
			if(ammo2 <= 0)
			{
				engclient_cmd(idd, "drop");
				g_Wpn[idd] = 0;
			}
		}
	}
	
	return HAM_IGNORED;
}

public fw_Weapon_Reload_Post(entity) 
{
	if ( !is_valid_ent(entity) )
		return;
	
	new id = get_pdata_cbase(entity, 41, 4);
		
	if ( !is_user_connected(id) )
		return;
		
	if ( !is_user_alive(id) )
		return;
	
	if ( !g_Wpn[id] )
		return;
		
	if ( g_Clip[id] == -1 )
		return;

	set_pdata_float(id, 83, 3.0, 5);
	set_pdata_int(entity, 54, 1, 4);
}

public fw_Weapon_PrimaryAttack_Post(entity)
{
	if ( !is_valid_ent(entity) )
		return;
	
	new id = get_pdata_cbase(entity, 41, 4);
		
	if ( !is_user_connected(id) )
		return;
		
	if ( !is_user_alive(id) )
		return;
	
	if ( !g_Wpn[id] )
		return;
	
	new szClip, szAmmo;
	get_user_weapon(id, szClip, szAmmo);
	
	if ( !szClip )
		return;
	
	emit_sound(id, CHAN_WEAPON, "weapons/awpbuff-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	UTIL_PlayWeaponAnimation(id, random_num(1,3));
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if ( !is_user_connected(attacker) || !is_user_connected(victim) )
		return;
	
	if ( !is_user_alive(attacker) || !is_user_alive(victim) )
		return;
	
	if ( !g_Wpn[attacker] )
		return;
	
	if ( get_user_weapon(attacker) != CSW_AWP )
		return;
	
	if ( inflictor != attacker )
		return;
	
	if ( victim == attacker )
		return;
	
	if ( !g_Charge[attacker] )
		SetHamParamFloat(4, damage * get_pcvar_float(g_Cvar[1]));
	else if ( g_Charge[attacker] == 1 )
		SetHamParamFloat(4, damage * get_pcvar_float(g_Cvar[2]));
	else if ( g_Charge[attacker] == 2 )
		SetHamParamFloat(4, damage * get_pcvar_float(g_Cvar[3]));
	else if ( g_Charge[attacker] == 3 )
		SetHamParamFloat(4, damage * get_pcvar_float(g_Cvar[4]));
		
	if ( cs_get_user_team(attacker) != cs_get_user_team(victim) || get_cvar_pointer("mp_friendlyfire") )
	{
		set_hudmessage(255, 0, 0, -1.0, 0.46, 0, 0.2, 0.2);
		show_hudmessage(attacker, "\  /^n/  \");
	}
}

public fw_SetFOV(id)
{
	if ( !is_user_connected(id) )
		return;
		
	if ( !is_user_alive(id) )
		return;
	
	if ( !g_Wpn[id] )
		return;
		
	if ( get_user_weapon(id) != CSW_AWP )
		return;
		
	switch ( read_data(1) )
	{
		case 5..24:
		{
			if ( !g_Zoomed[id] )
			{
				remove_task(g_TaskIDs[0] + id);
				new Data[1]; Data[0] = id;
				set_task(1.0, "do_charge", g_TaskIDs[0] + id, Data, 1);
			}
		}
		case 25..55:
		{
			remove_task(g_TaskIDs[0] + id);
			new Data[1]; Data[0] = id;
			set_task(1.0, "do_charge", g_TaskIDs[0] + id, Data, 1);
			g_Zoomed[id] = 1;
			do_colored_display(id);
		}
		case 90:
		{
			ClearSyncHud(id, g_SyncHud[0]);
			ClearSyncHud(id, g_SyncHud[1]);
			ClearSyncHud(id, g_SyncHud[2]);
			remove_task(g_TaskIDs[0] + id);
			g_Zoomed[id] = 0;
			g_Charge[id] = 0;
		}
	}
}

public fw_Killed(id)
	set_task(0.1, "do_reset_item", id);
	
public fw_SetModel(entity, model[])
{
	if ( !is_valid_ent(entity) )
		return FMRES_IGNORED;
 
	new szClassName[33];
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName));
 
	if ( !equal(szClassName, "weaponbox") )
		return FMRES_IGNORED;
 
	new iOwner = entity_get_edict(entity, EV_ENT_owner);
 
	if ( equal(model, "models/w_awp.mdl") )
	{
		new iStoredWpnID = find_ent_by_owner(-1, "weapon_awp", entity);
 
		if ( !is_valid_ent(iStoredWpnID) )
			return FMRES_IGNORED;
 
		if ( g_Wpn[iOwner] )
		{
			entity_set_int(iStoredWpnID, EV_INT_impulse, 20160918);
			entity_set_model(entity, g_WorldModel);
 
			g_Wpn[iOwner] = 0;
 
			return FMRES_SUPERCEDE;
		}
	}
 
	return FMRES_IGNORED;
}

public fw_UpdateClientData_Post(id, SendWeapons, CD_Handle)
{
	if ( !is_user_alive(id) )
		return FMRES_IGNORED;
 
	if ( !g_Wpn[id] )
		return FMRES_IGNORED;
	
	if ( get_user_weapon(id) != CSW_AWP )
		return FMRES_IGNORED;
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001);
	
	return FMRES_HANDLED;
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	new szTruncatedWeapon[33], iAttacker, iVictim;
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon));
 
	iAttacker = get_msg_arg_int(1);
	iVictim = get_msg_arg_int(2);
 
	if ( !is_user_connected(iAttacker) || iAttacker == iVictim )
		return PLUGIN_CONTINUE;
 
	if ( equal(szTruncatedWeapon, "awp") && get_user_weapon(iAttacker) == CSW_AWP )
		if ( g_Wpn[iAttacker] )
			set_msg_arg_string(4, "AWP Elven Ranger");
 
	return PLUGIN_CONTINUE;
}

public weapon_hook(id)
{
	engclient_cmd(id, "weapon_awp");
	
	return PLUGIN_HANDLED;
}

public cmdHas(id)
{
	return g_Wpn[id];
}

public cmdAdd(id)
{
	//UTIL_DropWeapon(id, 1);
	
	new iWep = give_item(id,"weapon_awp");
	
	if ( iWep )
	{
		cs_set_weapon_ammo(iWep, 10);
		cs_set_user_bpammo(id, CSW_AWP, 90);
		set_pdata_float(id, 83, 1.0, 5);
		
		g_Wpn[id] = 1;
		
		message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id);
		write_string("weapon_buffawp");
		write_byte(1);
		write_byte(30);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(2);
		write_byte(CSW_AWP);
		write_byte(0);
		message_end();
		
		set_pev(id, pev_viewmodel2, g_ViewModel);
		set_pev(id, pev_weaponmodel2, g_WeaponModel);
		
		UTIL_PlayWeaponAnimation(id, 5);
	}
}

public cmdAdd_10Shots(id)
{
	//UTIL_DropWeapon(id, 1);
	
	new iWep = give_item(id,"weapon_awp");
	
	if ( iWep )
	{
		cs_set_weapon_ammo(iWep, 10);
		cs_set_user_bpammo(id, CSW_AWP, 0);
		set_pdata_float(id, 83, 1.0, 5);
		
		g_Wpn[id] = 1;
		
		message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id);
		write_string("weapon_buffawp");
		write_byte(1);
		write_byte(30);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(2);
		write_byte(CSW_AWP);
		write_byte(0);
		message_end();
		
		set_pev(id, pev_viewmodel2, g_ViewModel);
		set_pev(id, pev_weaponmodel2, g_WeaponModel);
		
		UTIL_PlayWeaponAnimation(id, 5);
	}
}

public Make_Tracer(id)
{
	if( g_Wpn[id] )
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)

		if ( (bullets[id] > clip) && (wpnid == CSW_AWP) )
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)

			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0) //TE_BEAMENTPOINTS 0
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
			write_byte( 230 ) // r, g, b
			write_byte( 232 ) // r, g, b
			write_byte( 250 ) // r, g, b
			write_byte(200) // brightness
			write_byte(50) // speed 150
			message_end()
		}
		bullets[id] = clip
	}
}

public client_disconnected(id)
{
	g_Wpn[id] = 0;
	g_Zoomed[id] = 0;
}

public do_reset_item(id)
{
	g_Wpn[id] = 0;
	g_Zoomed[id] = 0;
}

public do_charge(Data[])
{
	new id = Data[0];
	
	if ( !is_user_connected(id) )
		return;
		
	if ( !g_Wpn[id] )
		return;
		
	if ( get_user_weapon(id) != CSW_AWP )
		return;
	
	if ( g_Charge[id] < 3 )
		g_Charge[id] ++
		
	do_colored_display(id);

	Data[0] = id;
	set_task(1.0, "do_charge", g_TaskIDs[0] + id, Data, 1);
}

public do_colored_display(id)
{
	if ( get_pcvar_num(g_Cvar[0]) == 1 )
	{
		if ( g_Charge[id] == 1 )
		{
			set_hudmessage(250, 250, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "-----              ");
		}
		else if ( g_Charge[id] == 2 )
		{
			set_hudmessage(250, 100, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "----- -----       ");
		}
		else if ( g_Charge[id] == 3 )
		{
			set_hudmessage(250, 0, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "----- ----- -----");
		}
		else
			ClearSyncHud(id, g_SyncHud[0]);
	}
	else if ( get_pcvar_num(g_Cvar[0]) == 2 )
	{
		if ( g_Charge[id] == 1 )
		{
			set_hudmessage(150, 150, 150, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "       ----- -----");
			
			set_hudmessage(250, 250, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[1], "-----              ");
			
			ClearSyncHud(id, g_SyncHud[2]);
		}
		else if ( g_Charge[id] == 2 )
		{
			set_hudmessage(150, 150, 150, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "              -----");
			
			set_hudmessage(250, 250, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[1], "-----              ");
			
			set_hudmessage(250, 100, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[2], "       -----       ");
		}
		else if ( g_Charge[id] == 3 )
		{
			set_hudmessage(250, 0, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "              -----");
			
			set_hudmessage(250, 250, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[1], "-----              ");
			
			set_hudmessage(250, 100, 0, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[2], "       -----       ");
		}
		else
		{
			set_hudmessage(150, 150, 150, -1.0, 0.75, 0, 1.0, 1.0);
			ShowSyncHudMsg(id, g_SyncHud[0], "----- ----- -----");
			
			ClearSyncHud(id, g_SyncHud[1]);
			ClearSyncHud(id, g_SyncHud[2]);
		}
	}
}

stock UTIL_PlayWeaponAnimation(id, sequence)
{
	set_pev(id, pev_weaponanim, sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = id);
	write_byte(sequence);
	write_byte(0);
	message_end();
}

stock UTIL_DropWeapon(id, slot)
{
	if(!(1 <= slot <= 2))
		return 0;
	
	static iCount; iCount = 0;
	static iEntity; iEntity = get_pdata_cbase(id, (367 + slot), 5);
	
	if(iEntity > 0)
	{
		static iNext;
		static szWeaponName[32];
		
		do {
			iNext = get_pdata_cbase(iEntity, 42, 4);
			
			if(get_weaponname(cs_get_weapon_id(iEntity), szWeaponName, charsmax(szWeaponName)))
			{  
				engclient_cmd(id, "drop", szWeaponName);
				iCount++;
			}
		}
		
		while(( iEntity = iNext) > 0);
	}
	
	return iCount;
}
