#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN "Plant C4 Delay"
#define VERSION "0.0.1"

#define cm(%0)    ( sizeof(%0) - 1 )

const XO_CBASEPLAYERITEM = 4;
const m_pPlayer = 41;

const XO_CBASEPLAYERWEAPON = 4;
const m_flNextPrimaryAttack = 46;

new g_pcvarPlantC4Delay;
new Float:g_flEnablePlantingTime;

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, "ConnorMcLeod" );

	g_pcvarPlantC4Delay = register_cvar("amx_plant_c4_delay", "120.0");
	register_logevent("LogEvent_Round_Start", 2, "1=Round_Start");

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_c4", "OnCC4_PrimaryAttack", false);
}

public LogEvent_Round_Start()
{
	g_flEnablePlantingTime = get_gametime() + get_pcvar_float(g_pcvarPlantC4Delay);
}

public OnCC4_PrimaryAttack( c4 )
{
	new Float:diff = g_flEnablePlantingTime - get_gametime();
	if( diff > 0.0 )
	{
		set_pdata_float(c4, m_flNextPrimaryAttack, diff > 1.0 ? 1.0 : diff, XO_CBASEPLAYERWEAPON);
		new id = get_pdata_cbase(c4, m_pPlayer, XO_CBASEPLAYERITEM);
		client_print(id, print_center, "You have to wait %.1f sec. to plant c4", diff);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}
