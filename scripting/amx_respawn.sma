/* AMX Mod X script. 
* 
* (c) Copyright 2002-2003, f117bomb 
* This file is provided as is (no warranties). 
* 
*  *******************************************************************************
*   
*	Ported By KingPin( kingpin@onexfx.com ). I take no responsibility 
*	for this file in any way. Use at your own risk. No warranties of any kind. 
*
*  *******************************************************************************
*
* Set Cvar 'amx_respawn' 1 or 0 
* 
*/ 

#include <amxmodx>
#include <fun>

public TeamSelect(id)
{
	if(get_cvar_num("amx_respawn") == 1)
	{
		new sId[2]
		sId[0] = id
		set_task(10.0,"respawn", 0, sId, 2)
	}
	return PLUGIN_CONTINUE
}

public death_msg() 
{
	if(get_cvar_num("amx_respawn") == 1)
	{ 
		new vIndex = read_data(2) 
		new svIndex[2]
		svIndex[0] = vIndex
		set_task(0.5,"respawn", 0, svIndex, 2) 
	} 
	return PLUGIN_CONTINUE 
}

public respawn(svIndex[]) 
{ 
	new vIndex = svIndex[0]

	if(get_user_team(vIndex) == 3 || is_user_alive(vIndex)) 
		return PLUGIN_CONTINUE

	spawn(vIndex)
	
	return PLUGIN_CONTINUE
}

public plugin_init() 
{
   	register_plugin("amx_respawn","0.9.4","f117bomb")
	register_event("DeathMsg","death_msg","a")
	register_event("ShowMenu","TeamSelect","b","4&Team_Select")
	register_event("VGUIMenu","TeamSelect","b","1=2")
	register_cvar("amx_respawn", "0")

	return PLUGIN_CONTINUE
}