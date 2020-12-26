/* AMXX - amx_lights
*
* Copyright 2004, Written by Rattler
* This file is provided as is (absolutely no warranties)
*
* Change Logs
* v1.3 - Bug Fix - Light levels not constant throughout MapChanges/New Player Connects
* v1.2 - Released - Added Admin Check
* v1.1 - Added [off] or [OFF] commands
* v1.0 - Actually worked
*
* Commands
* ====================
* amx_lights <a through z>		-- Sets the light level
* amx_lights off or OFF			-- Normal light level
*
*
* Requirements
* ====================
* The following modules are required
*
* [amxmodx.inc]
* [engine.inc]
* [amxmisc.inc]
*
*
*/

// Declare Commands
//====================

#include <amxmodx>
#include <engine>
#include <amxmisc>

// Check/Set Server Light Level when Connecting
//====================
public client_putinserver(id)
{
	new cmdarg[32]
	get_vaultdata("amx_lights",cmdarg,31)
	set_lights(cmdarg)
	return PLUGIN_CONTINUE
}

// Set Light Level
//====================
public admin_lights(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	
	new cmdarg[32]
	read_argv(1,cmdarg,31)
	
	if (equal(cmdarg,"off")||equal(cmdarg,"OFF"))
	{
		set_lights("#OFF")
		set_vaultdata("amx_lights","#OFF")
		console_print(id,"[AMXX] Light Returned To Normal.")
	}
	else
	{
		set_lights(cmdarg)
		set_vaultdata("amx_lights",cmdarg)
		console_print(id,"[AMXX] Light Change Successful.")
	}
	return PLUGIN_HANDLED
}

// Declare Commands
//====================
public plugin_init()
{
	register_plugin("Ambient Light Level","1.3","Rattler")
	register_concmd("amx_lights","admin_lights",ADMIN_CVAR,"[a-z] - Light level | [off] - Normal Lights")
}