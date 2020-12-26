#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define VERSION "0.0.3"

#define USE_TOGGLE 3

#define MAX_BACKWARD_UNITS	-200.0
#define MAX_FORWARD_UNITS	200.0

new g_iPlayerCamera[33], Float:g_camera_position[33];

enum vars_struct {
	annonce,
};
new g_vars[vars_struct];
new SayText;

public plugin_init()
{
	register_plugin("Camera View Menu", VERSION, "ConnorMcLeod & Natsheh")

	register_clcmd("changeview", "check_view")

	register_clcmd("say /viewmenu", "camera_menu")
	register_clcmd("say_team /viewmenu", "camera_menu")
	register_clcmd("say viewmenu", "camera_menu")
	register_clcmd("say_team viewmenu", "camera_menu")
	register_clcmd("say /camera", "camera_menu")
	register_clcmd("say_team /camera", "camera_menu")
	register_clcmd("say camera", "camera_menu")
	register_clcmd("say_team camera", "camera_menu")
	register_clcmd("say /cam", "camera_menu")
	register_clcmd("say_team /cam", "camera_menu")
	register_clcmd("say cam", "camera_menu")
	register_clcmd("say_team cam", "camera_menu")

	register_forward(FM_SetView, "SetView")
	RegisterHam(Ham_Think, "trigger_camera", "Camera_Think")

	SayText = get_user_msgid("SayText")
}

public plugin_precache()
{
	g_vars[annonce] = register_cvar("camera_annonce", "420.0");
}

public plugin_cfg() 
{
	if(get_pcvar_num(g_vars[annonce]))
		set_task(get_pcvar_float(g_vars[annonce]), "print_annonce", _, _, _, "b");
}

public print_annonce()
{
	print_col_chat(0, "^x04[GG]^x01 Press <^x04I^x01> to change the^x04 view^x01 of your camera (bind ^"i^" ^"changeview^")");
}

public camera_menu(id)
{
	if(!is_user_alive(id))
	{
		return 1;
	}

	new sText[48];
	new bool: mode = (g_iPlayerCamera[id] > 0) ? true : false;

	new menu = menu_create("\d[\yGeek~Gamers\d] \rChoose Camera View:", "cam_m_handler")
	
	formatex(sText, charsmax(sText), "3rd Person View \d[%s\d]^n", (mode) ? "\yEnable" : "\rDisable")
	menu_additem(menu, sText)
	if(mode)
	{
		menu_additem(menu, "Forward Further")
		menu_additem(menu, "Backward Further")
	}
	
	menu_display(id, menu)
	return 1;
}

public cam_m_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return 1;
	}
	
	menu_destroy(menu);
	
	if(g_iPlayerCamera[id] > 0 && item == 0)
	{
		if(is_user_alive(id))
		{
			disable_camera(id)
			engfunc(EngFunc_SetView, id, id);
		}
	}
	else
	{
		switch( item )
		{
			case 0:
			{
				g_camera_position[id] = -150.0;
				enable_camera(id)
			}
			case 1: if(g_camera_position[id] < MAX_FORWARD_UNITS) g_camera_position[id] += 50.0;
			case 2: if(g_camera_position[id] > MAX_BACKWARD_UNITS) g_camera_position[id] -= 50.0;
		}
	}
	
	camera_menu(id)
	return 1;
}

public check_view(id)
{
	if(g_iPlayerCamera[id] > 0)
	{
		if(is_user_alive(id))
		{
			disable_camera(id)
			engfunc(EngFunc_SetView, id, id);
		}
	}
	else
	{
		g_camera_position[id] = -150.0;
		enable_camera(id)
	}
}

public enable_camera(id)
{ 
	if(!is_user_alive(id)) return;
	
	new iEnt = g_iPlayerCamera[id] 
	if(!pev_valid(iEnt))
	{
		static iszTriggerCamera 
		if( !iszTriggerCamera ) 
		{ 
			iszTriggerCamera = engfunc(EngFunc_AllocString, "trigger_camera") 
		} 
		
		iEnt = engfunc(EngFunc_CreateNamedEntity, iszTriggerCamera);
		set_kvd(0, KV_ClassName, "trigger_camera") 
		set_kvd(0, KV_fHandled, 0) 
		set_kvd(0, KV_KeyName, "wait") 
		set_kvd(0, KV_Value, "999999") 
		dllfunc(DLLFunc_KeyValue, iEnt, 0) 
	
		set_pev(iEnt, pev_spawnflags, SF_CAMERA_PLAYER_TARGET|SF_CAMERA_PLAYER_POSITION) 
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_ALWAYSTHINK) 
	
		dllfunc(DLLFunc_Spawn, iEnt)
	
		g_iPlayerCamera[id] = iEnt;

		new Float:flMaxSpeed, iFlags = pev(id, pev_flags) 
		pev(id, pev_maxspeed, flMaxSpeed)
		
		ExecuteHam(Ham_Use, iEnt, id, id, USE_TOGGLE, 1.0)
		
		set_pev(id, pev_flags, iFlags)
		// depending on mod, you may have to send SetClientMaxspeed here. 
		// engfunc(EngFunc_SetClientMaxspeed, id, flMaxSpeed) 
		set_pev(id, pev_maxspeed, flMaxSpeed)
	}
}

public disable_camera(id)
{
	new iEnt = g_iPlayerCamera[id];
	if(pev_valid(iEnt)) engfunc(EngFunc_RemoveEntity, iEnt);
	g_iPlayerCamera[id] = 0;
	g_camera_position[id] = -100.0;
}

public SetView(id, iEnt) 
{ 
	if(is_user_alive(id))
	{
		new iCamera = g_iPlayerCamera[id] 
		if( iCamera && iEnt != iCamera ) 
		{ 
			new szClassName[16] 
			pev(iEnt, pev_classname, szClassName, charsmax(szClassName)) 
			if(!equal(szClassName, "trigger_camera")) // should let real cams enabled 
			{ 
				engfunc(EngFunc_SetView, id, iCamera) // shouldn't be always needed 
				return FMRES_SUPERCEDE 
			} 
		} 
	} 
	return FMRES_IGNORED 
}

public client_disconnected(id)
{
	disable_camera(id)
}

public client_putinserver(id)
{
	force_cmd(id, "bind ^"i^" ^"changeview^"")
	g_iPlayerCamera[id] = 0
	g_camera_position[id] = -100.0;
}

get_cam_owner(iEnt) 
{ 
	new players[32], pnum;
	get_players(players, pnum, "ch");
	
	for(new id, i; i < pnum; i++)
	{ 
		id = players[i];
		
		if(g_iPlayerCamera[id] == iEnt)
		{
			return id;
		}
	}
	
	return 0;
} 

public Camera_Think(iEnt)
{
	static id;
	if(!(id = get_cam_owner(iEnt))) return ;
	
	static Float:fVecPlayerOrigin[3], Float:fVecCameraOrigin[3], Float:fVecAngles[3], Float:fVec[3];
	
	pev(id, pev_origin, fVecPlayerOrigin) 
	pev(id, pev_view_ofs, fVecAngles) 
	fVecPlayerOrigin[2] += fVecAngles[2] 
	
	pev(id, pev_v_angle, fVecAngles) 
	
	angle_vector(fVecAngles, ANGLEVECTOR_FORWARD, fVec);
	static Float:units; units = g_camera_position[id];
	
	//Move back/forward to see ourself
	fVecCameraOrigin[0] = fVecPlayerOrigin[0] + (fVec[0] * units)
	fVecCameraOrigin[1] = fVecPlayerOrigin[1] + (fVec[1] * units) 
	fVecCameraOrigin[2] = fVecPlayerOrigin[2] + (fVec[2] * units) + 15.0
	
	static tr2; tr2 = create_tr2();
	engfunc(EngFunc_TraceLine, fVecPlayerOrigin, fVecCameraOrigin, IGNORE_MONSTERS, id, tr2)
	static Float:flFraction 
	get_tr2(tr2, TR_flFraction, flFraction)
	if( flFraction != 1.0 ) // adjust camera place if close to a wall 
	{
		flFraction *= units;
		fVecCameraOrigin[0] = fVecPlayerOrigin[0] + (fVec[0] * flFraction);
		fVecCameraOrigin[1] = fVecPlayerOrigin[1] + (fVec[1] * flFraction);
		fVecCameraOrigin[2] = fVecPlayerOrigin[2] + (fVec[2] * flFraction);
	}
	
	if(units > 0.0)
	{
		fVecAngles[0] *= fVecAngles[0] > 180.0 ? 1:-1
		fVecAngles[1] += fVecAngles[1] > 180.0 ? -180.0:180.0
	}
	
	set_pev(iEnt, pev_origin, fVecCameraOrigin); 
	set_pev(iEnt, pev_angles, fVecAngles);
	
	free_tr2(tr2);
}

stock print_col_chat(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	replace_all(msg, 190, "!g", "^x04"); // Green Color
	replace_all(msg, 190, "!y", "^x01"); // Default Colo
	replace_all(msg, 190, "!t", "^x03"); // Team Color
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
		for ( new i = 0; i < count; i++ )
		{
			if ( is_user_connected(players[i]) )
			{
				message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}

stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	new szMessage[ 256 ];

	format_args( szMessage ,charsmax( szMessage ) , 1 );

	message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
	write_byte( strlen( szMessage ) + 2 )
	write_byte( 10 )
	write_string( szMessage )
	message_end()
}
