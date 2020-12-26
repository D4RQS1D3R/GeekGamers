	/*********************************************************************************
	
	*	Ambience Effects
	*	v1.0
	*	(c) 2013 by CryWolf
	*
	*	Description: Acest plugin va ajuta sa adaugati efecte pe Server
	*	Aceste efecte fiind:
	*	Ploaie, Ceata, Lumina
	*	Fulgere, :-??
		
		www.eXtreamCS.com/forum
		www.amxmodx.org
		
		Thanks to:
		MerCyleZz 	- Pentru coduri utile fulgere
		Arkshine	- Stock-ul ceata, foarte puternic
		
		Notepad :))	- Ca mi-a farmat capul cu identitatile 
		
		v1.0 Beta
		- Prima realizare
		- Adaugare cvaruri functionabile
		- Tot nucleul este activ si functionabil
		
		
	Licenta GNU
		
		This file is part of AMX Mod X.

    		Ambience Effectsis free software: you can redistribute it and/or modify
    		it under the terms of the GNU General Public License as published by
    		the Free Software Foundation, either version 3 of the License, or
    		(at your option) any later version.
		
    		Ambience Effects is distributed in the hope that it will be useful,
    		but WITHOUT ANY WARRANTY; without even the implied warranty of
    		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    		GNU General Public License for more details.
		
    		You should have received a copy of the GNU General Public License
    		along with this file.  If not, see <http://www.gnu.org/licenses/>.

	*********************************************************************************/
	
	#include < amxmodx >
	#include < amxmisc >
	#include < fakemeta >
	
	#pragma semicolon 1
	#pragma reqlib fakemeta
	
	//Plugin registration
	new const
		PLUGIN_NAME	[ ] = "Ambience Effects",
		PLUGIN_VERSION	[ ] = "1.0 Beta",
		PLUGIN_AUTHOR	[ ] = "CryWolf"; // aka. AzaZeL
	
	// pCvar Pointers
	new pCvar_rain, pCvar_fog, pCvar_lights, pCvar_density,
		pCvar_fcolor [ 3 ], pCvar_sky, pCvar_skyen, pCvar_thunder_time,
			pCvar_triggered_lights;
	
	
	// Sunetele fulgerului cu suport pentru .MP3 si .WAV
	new const sunet_fulger [ ] [ ] =
	{
		"de_torn/torn_thndrstrike.wav",
		"ambience/thunder_clap.wav"
	};
	
	// Lumina fulger
	new const lumina_fulger [ ] [ ] =
	{
		"ijklmnonmlkjihgfedcb",
		"azazazazazaz"
	};
	
	#define SOUND_MAX_LENGTH 64
	#define LIGHTS_MAX_LENGTH 32
	#define TASK_THUNDER 100
	#define TASK_THUNDER_LIGHTS 200
	
	new Array:g_thunder_lights, Array:g_sound_thunder;
	new g_ThunderLightIndex, g_ThunderLightMaxLen;
	new g_ThunderLight [ LIGHTS_MAX_LENGTH ];
	
	/**********************************************************************************/

public plugin_precache ( )
{
	pCvar_rain	= register_cvar ( "amx_rainsnowy", 	"2" );
	
	pCvar_fog	= register_cvar ( "amx_fog", 		"0" );
	pCvar_density	= register_cvar ( "amx_fdensity", 	"0.0008" );
	
	pCvar_fcolor [ 0 ]	= register_cvar ( "amx_fcolor_r", 	"128" );
	pCvar_fcolor [ 1 ]	= register_cvar ( "amx_fcolor_g", 	"128" );
	pCvar_fcolor [ 2 ]	= register_cvar ( "amx_fcolor_b", 	"128" );
	
	pCvar_skyen	= register_cvar ( "amx_sky", 		"1" );
	pCvar_sky	= register_cvar ( "amx_skyname",	"blood_" );
	
	switch ( get_pcvar_num ( pCvar_rain ) )
	{
		case 1: engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "env_snow" ) );
		case 2: engfunc ( EngFunc_CreateNamedEntity, engfunc ( EngFunc_AllocString, "env_rain" ) );
		case 3: return;
	}
	
	if ( get_pcvar_num ( pCvar_skyen ) )
	{
		new dir [ 160 ], skyname [ 33 ];
		get_pcvar_string ( pCvar_sky, skyname, charsmax ( skyname ) );
		
		formatex ( dir, charsmax ( dir ), "gfx/env/%sbk.tga", skyname );
		precache_generic ( dir );
		formatex ( dir, charsmax ( dir ), "gfx/env/%sdn.tga", skyname );
		precache_generic ( dir );
		formatex ( dir, charsmax ( dir ), "gfx/env/%sft.tga", skyname );
		precache_generic ( dir );
		formatex ( dir, charsmax ( dir ), "gfx/env/%slf.tga", skyname );
		precache_generic ( dir );
		formatex ( dir, charsmax ( dir ), "gfx/env/%srt.tga", skyname );
		precache_generic ( dir );
		formatex ( dir, charsmax ( dir ), "gfx/env/%sup.tga", skyname );
		precache_generic ( dir );
		
		set_cvar_string ( "sv_skyname", skyname );
	}
	
	g_thunder_lights = ArrayCreate ( LIGHTS_MAX_LENGTH, 1 );
	g_sound_thunder  = ArrayCreate ( SOUND_MAX_LENGTH, 1 );
	
	new i;
	if ( ArraySize ( g_thunder_lights ) == 0 )
	{
		for ( i = 0; i < sizeof lumina_fulger; i++ )
			ArrayPushString ( g_thunder_lights, lumina_fulger [ i ] );
	}
	
	if ( ArraySize ( g_sound_thunder ) == 0 )
	{
		for ( i = 0; i < sizeof sunet_fulger; i++ )
			ArrayPushString ( g_sound_thunder, sunet_fulger [ i ] );
	}
	
	for ( i = 0; i < sizeof sunet_fulger; i++ )
		precache_sound ( sunet_fulger [ i ] );
	
	exec_cfg ( );
}

public exec_cfg ( )
{
	new confdir [ 67 ];
	get_configsdir ( confdir, charsmax ( confdir ) );
	format ( confdir, charsmax ( confdir ), "%s/ae_effects.cfg", confdir );
	if ( file_exists ( confdir ) )
		server_cmd ( "exec %s", confdir );
	else
		log_amx ( "Fisierul ae_effects.cfg nu a fost gasit, se vor folosi setarile implicite" );
}

public update_fog ( )
{
	CreateFog ( 0, .clear = false );
	
	CreateFog ( 0, get_pcvar_num ( pCvar_fcolor [ 0 ] ), get_pcvar_num ( pCvar_fcolor [ 1 ] ), get_pcvar_num ( pCvar_fcolor [ 2 ] ), get_pcvar_float ( pCvar_density ) );
}

public plugin_cfg ( )
{
	set_cvar_string ( "mp_playerid", "1" );
	set_task ( 5.0, "lighting_task", _, _, _, "b", _ );
	FunC_RoundStart ( );
}

public plugin_init ( )
{
	register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
	register_event ( "HLTV", "FunC_RoundStart", "a", "1=0", "2=0" );
	
	pCvar_lights		= register_cvar ( "amx_lights", "d" );
	pCvar_thunder_time 	= register_cvar ( "amx_thunder_time", "32" );
	pCvar_triggered_lights 	= register_cvar ( "amx_triggered_lights", "1" );
	
	set_cvar_num ( "sv_skycolor_r", 0 );
	set_cvar_num ( "sv_skycolor_g", 0 );
	set_cvar_num ( "sv_skycolor_b", 0 );
}

public FunC_RoundStart ( )
{
	if ( get_pcvar_num ( pCvar_fog ) ) {
		exec_cfg ( );
		update_fog ( );
	}
	else {
		CreateFog ( 0, .clear = false );
	}
	
	if ( !get_pcvar_num ( pCvar_triggered_lights ) )
		set_task ( 0.2, "remove_lights", _, _, _, _ );
}

public remove_lights ( )
{
	new ent;
	ent = -1;

	while ( ( ent = engfunc ( EngFunc_FindEntityByString, ent, "classname", "light" ) ) != 0 )
	{
		dllfunc ( DLLFunc_Use, ent, 0 );
		set_pev ( ent, pev_targetname, 0 );
	}
}

public client_connect ( id ) {
	if ( get_pcvar_num ( pCvar_rain ) ) {
		client_cmd ( id, "cl_weather 1" );
	}
	
	if ( get_pcvar_num ( pCvar_fog ) ) {
		client_cmd ( id, "gl_fog 1" );
	}
}

public lighting_task ( )
{
	new lighting [ 2 ];
	get_pcvar_string ( pCvar_lights, lighting, charsmax ( lighting ) );
	
	if ( lighting [ 0 ] == '0' )
		return;
	
	if ( get_pcvar_float ( pCvar_thunder_time ) > 0.0 && !task_exists ( TASK_THUNDER ) && !task_exists ( TASK_THUNDER_LIGHTS ) )
	{
		g_ThunderLightIndex = 0;
		ArrayGetString ( g_thunder_lights, random_num ( 0, ArraySize ( g_thunder_lights ) - 1 ), g_ThunderLight, charsmax ( g_ThunderLight ) );
		g_ThunderLightMaxLen = strlen ( g_ThunderLight );
		set_task ( get_pcvar_float ( pCvar_thunder_time ), "thunder_task", TASK_THUNDER );
	}
	
	if ( !task_exists ( TASK_THUNDER_LIGHTS ) ) engfunc ( EngFunc_LightStyle, 0, lighting );
}

public thunder_task ( )
{
	if ( g_ThunderLightIndex == 0 )
	{	
		static sound [ SOUND_MAX_LENGTH ];
		ArrayGetString ( g_sound_thunder, random_num ( 0, ArraySize ( g_sound_thunder ) - 1 ), sound, charsmax ( sound ) );
		PlaySoundToClients ( sound );
		
		set_task ( 0.1, "thunder_task", TASK_THUNDER_LIGHTS, _, _, "b", _ );
	}
	
	new lighting [ 2 ];
	lighting [ 0 ] = g_ThunderLight [ g_ThunderLightIndex ];
	engfunc ( EngFunc_LightStyle, 0, lighting );
	
	g_ThunderLightIndex++;
	
	if ( g_ThunderLightIndex >= g_ThunderLightMaxLen )
	{
		remove_task ( TASK_THUNDER_LIGHTS );
		lighting_task ( );
	}
}

PlaySoundToClients ( const sound [ ] )
{
	if ( equal ( sound [ strlen ( sound ) -4 ], ".mp3" ) )
		client_cmd ( 0, "mp3 play ^"sound/%s^"", sound );
	else
		client_cmd ( 0, "spk ^"%s^"", sound );
}

stock CreateFog ( const index = 0, const red = 127, const green = 127, const blue = 127, const Float:density_f = 0.001, bool:clear = false )
{
	static msgFog;
	
	if ( msgFog || ( msgFog = get_user_msgid( "Fog" ) ) )
    	{
        	new density = _:floatclamp( density_f, 0.0001, 0.25 ) * _:!clear;
        	
        	message_begin( index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgFog, .player = index );
        	write_byte( clamp( red  , 0, 255 ) );
        	write_byte( clamp( green, 0, 255 ) );
        	write_byte( clamp( blue , 0, 255 ) );
        	write_long( _:density );
        	message_end ( );
    	}
}