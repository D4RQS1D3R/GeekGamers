#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#include "furien.inc"
#include "furien_shop.inc"

#define VERSION "0.0.2"

#define XTRA_OFS_PLAYER			5
#define m_Activity			73
#define m_IdealActivity			74
#define m_flNextAttack			83
#define m_afButtonPressed		246

#define FIRST_PLAYER_ID	1
#define MAX_PLAYERS		32

#define PLAYER_JUMP		6

#define ACT_HOP 7

//#define FBitSet(%1,%2)		(%1 & %2)

new g_iMaxPlayers
#define IsPlayer(%1)	( FIRST_PLAYER_ID <= %1 <= g_iMaxPlayers )

#define IsHidden(%1)	IsPlayer(%1)

#define KNIFE_DRAW			3

new g_bHasWallHang
#define SetUserWallHang(%1)		g_bHasWallHang |=	1<<(%1&31)
#define RemoveUserWallHang(%1)		g_bHasWallHang &=	~(1<<(%1&31))
#define HasUserWallHang(%1)		g_bHasWallHang &	1<<(%1&31)

new g_bHanged
#define SetUserHanged(%1)		g_bHanged |=	1<<(%1&31)
#define RemoveUserHanged(%1)		g_bHanged &=	~(1<<(%1&31))
#define IsUserHanged(%1)		g_bHanged &	1<<(%1&31)

new Float:g_fVecMins[MAX_PLAYERS+1][3]
new Float:g_fVecMaxs[MAX_PLAYERS+1][3]
new Float:g_fVecOrigin[MAX_PLAYERS+1][3]

new g_iCost[2]

new bool:g_bRoundEnd
new bool:g_bNoFallDamage;

native bool: is_user_frozen(id);
native assassin_mod(id);
native sniper_mod(id);
native ghost_mod(id);

new bool: falling[33];
new bool: get_old_Gravity[33];
new bool: set_old_Gravity[33];
new bool: set_gravity[33];
new bool: gravity_notset[33];

new Float: last_grav[33];
new Float: new_last_grav[33];

public plugin_init()
{
	register_plugin("Furien WallHang", VERSION, "ConnorMcLeod")

	new szConfigFile[128]
	get_localinfo("amxx_configsdir", szConfigFile, charsmax(szConfigFile))
	format(szConfigFile, charsmax(szConfigFile), "%s/furien/items/wallhang.ini", szConfigFile);

	new fp = fopen(szConfigFile, "rt")
	if( !fp )
	{
		return
	}

	new szFurienName[32], szAntiName[32]

	new szDatas[64], szKey[16], szValue[32]
	while( !feof(fp) )
	{
		fgets(fp, szDatas, charsmax(szDatas))
		trim(szDatas)
		if(!szDatas[0] || szDatas[0] == ';' || szDatas[0] == '#' || (szDatas[0] == '/' && szDatas[1] == '/'))
		{
			continue
		}

		parse(szDatas, szKey, charsmax(szKey), szValue, charsmax(szValue))

		switch( szKey[0] )
		{
			case 'A':
			{
				switch( szKey[7] )
				{
					case 'M':
					{
						if( equal(szKey, "ANTI_NAME" ) )
						{
							copy(szAntiName, charsmax(szAntiName), szValue)
						}
					}
					case 'S':
					{
						if( equal(szKey, "ANTI_COST" ) )
						{
							g_iCost[AntiFurien] = str_to_num(szValue)
						}
					}
				}
			}
			case 'F':
			{
				switch( szKey[9] )
				{
					case 'M':
					{
						if( equal(szKey, "FURIEN_NAME" ) )
						{
								copy(szFurienName, charsmax(szAntiName), szValue)
						}
					}
					case 'S':
					{
						if( equal(szKey, "FURIEN_COST" ) )
						{
							g_iCost[Furien] = str_to_num(szValue)
						}
					}
				}
			}
		}
	}
	fclose( fp )

	if( g_iCost[Furien] || g_iCost[AntiFurien] )
	{
		furien_register_item(szFurienName, g_iCost[Furien], szAntiName, g_iCost[AntiFurien], "furien_buy_wallhang")

		RegisterHam(Ham_Player_Jump, "player", "Player_Jump")
		RegisterHam(Ham_Spawn, "player", "Spawn", 1)

		RegisterHam(Ham_Touch, "func_wall", "World_Touch")
		RegisterHam(Ham_Touch, "func_breakable", "World_Touch")
		RegisterHam(Ham_Touch, "worldspawn", "World_Touch")

		g_iMaxPlayers = get_maxplayers()

		register_event("HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0")
		register_logevent("Logevent_Round_End", 2, "1=Round_End")
		register_logevent("Logevent_Round_Start", 2, "1=Round_Start");

		register_clcmd("say /removewallhang", "removewh");
		register_clcmd("say /removewh", "removewh");
	}
}

public removewh(id) RemoveUserWallHang(id)

public Spawn(id) last_gravity(id);

public last_gravity(id)
{
	if( !is_user_alive(id) || HasUserWallHang(id) )
		return PLUGIN_CONTINUE;

	set_old_Gravity[id] = false;
	get_old_Gravity[id] = false;

	if( !is_user_frozen(id) )
		last_grav[id] = get_user_gravity(id);

	return PLUGIN_CONTINUE;
}

public Event_HLTV_New_Round()
{
	g_bRoundEnd = false
	g_bNoFallDamage = false
}

public Logevent_Round_Start()
{
	g_bNoFallDamage = true
}

public Logevent_Round_End()
{
	g_bRoundEnd = true
	g_bHanged = 0
}

public client_putinserver( id )
{
	RemoveUserWallHang( id )
	RemoveUserHanged( id )
}

public furien_team_change( /*iFurien */ )
{
	if( !g_iCost[Furien] || !g_iCost[AntiFurien] )
	{
		g_bHasWallHang = 0
		g_bHanged = 0
	}
}

public furien_round_restart()
{
	g_bHasWallHang = 0
	g_bHanged = 0
}

public furien_buy_wallhang( id )
{
	new iTeam = furien_get_user_team(id)
	if( iTeam == -1 )
	{
		return ShopCloseMenu
	}

	new iItemCost = g_iCost[iTeam]
	if( iItemCost <= 0 )
	{
		return ShopTeamNotAvail
	}

	if( ~HasUserWallHang(id) )
	{
		if( furien_try_buy(id, iItemCost) )
		{
			SetUserWallHang( id )
			ChatColor(id, "!g[GG] !nTo Remove WallHang say !t/removewallhang !nor !t/removewh !n!");
			return ShopBought
		}
		else
		{
			return ShopNotEnoughMoney
		}
	}
	else ChatColor(id, "!g[GG] !nTo Remove WallHang say !t/removewallhang !nor !t/removewh !n!");

	return ShopAlreadyHaveOne
}

public Player_Jump(id)
{
	if(	g_bRoundEnd
	||	!g_bNoFallDamage
	||	~HasUserWallHang(id)
	||	assassin_mod(id)
	||	sniper_mod(id)
	||	ghost_mod(id)
	||	~IsUserHanged(id)
	||	!is_user_alive(id)	)
	{
		return HAM_IGNORED
	}

	if( (pev(id, pev_flags) & FL_WATERJUMP) || pev(id, pev_waterlevel) >= 2 )
	{
		return HAM_IGNORED
	}

	static afButtonPressed ; afButtonPressed = get_pdata_int(id, m_afButtonPressed)

	if( ~afButtonPressed & IN_JUMP )
	{
		return HAM_IGNORED
	}

	RemoveUserHanged(id)

	new Float:fVecVelocity[3]

	velocity_by_aim(id, 600, fVecVelocity)
	set_pev(id, pev_velocity, fVecVelocity)

	set_pdata_int(id, m_Activity, ACT_HOP)
	set_pdata_int(id, m_IdealActivity, ACT_HOP)
	set_pev(id, pev_gaitsequence, PLAYER_JUMP)
	set_pev(id, pev_frame, 0.0)
	set_pdata_int(id, m_afButtonPressed, afButtonPressed & ~IN_JUMP)

	return HAM_SUPERCEDE
}

public client_PreThink(id)
{
	if( assassin_mod(id) || sniper_mod(id) || ghost_mod(id) || !is_user_alive(id) || HasUserWallHang(id) || !g_bNoFallDamage )
		return PLUGIN_CONTINUE;

	if( get_user_button(id) & IN_USE && !is_user_frozen(id) )
	{
		if( !get_old_Gravity[id] )
		{
			new_last_grav[id] = get_user_gravity(id);
			get_old_Gravity[id] = true;
		}

		set_user_gravity(id, 5.5);
		entity_set_int(id, EV_INT_watertype, -3);
		falling[id] = true;
		set_old_Gravity[id] = true;
		set_gravity[id] = false;
		gravity_notset[id] = true;
	}
	else
	if( get_entity_flags(id) & FL_ONGROUND && gravity_notset[id] )
	{
		if( !set_gravity[id] )
		{
			set_gravity[id] = true;

			if( !is_user_frozen(id) )
			{
				if( set_old_Gravity[id] )
				{
					set_user_gravity(id, new_last_grav[id]);
				}
				else
				{
					set_user_gravity(id, last_grav[id]);
				}
			}
		}

		gravity_notset[id] = false;
		get_old_Gravity[id] = false;
		falling[id] = false;
	}

	if( falling[id] && !is_user_frozen(id) )
	{
		if( !get_old_Gravity[id] )
		{
			new_last_grav[id] = get_user_gravity(id);
			get_old_Gravity[id] = true;
		}

		set_user_gravity(id, 5.5);
		entity_set_int(id, EV_INT_watertype, -3);
		falling[id] = true;
		set_old_Gravity[id] = true;
		gravity_notset[id] = true;
	}
	else
	if( !falling[id] && gravity_notset[id] )
	{
		if( !set_gravity[id] )
		{
			set_gravity[id] = true;

			if( !is_user_frozen(id) )
			{
				if( set_old_Gravity[id] )
				{
					set_user_gravity(id, new_last_grav[id]);
				}
				else
				{
					set_user_gravity(id, last_grav[id]);
				}
			}
		}

		gravity_notset[id] = false;
		get_old_Gravity[id] = false;
		falling[id] = false;
	}

	return PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
	if( g_bNoFallDamage && !assassin_mod(id) && !sniper_mod(id) && !ghost_mod(id) && HasUserWallHang(id) && IsUserHanged(id) )
	{
		engfunc(EngFunc_SetSize, id, g_fVecMins[ id ], g_fVecMaxs[ id ])
		engfunc(EngFunc_SetOrigin, id, g_fVecOrigin[ id ])
		set_pev(id, pev_velocity, 0)

		if(cs_get_user_team(id) == CS_TEAM_CT) 
			set_pdata_float(id, m_flNextAttack, 1.0, XTRA_OFS_PLAYER)
	}

	if( g_bNoFallDamage && !assassin_mod(id) && !sniper_mod(id) && !ghost_mod(id) && ~HasUserWallHang(id) )
	{
		if( falling[id] )
		{
			entity_set_int(id, EV_INT_watertype, -3);
		}
	}
}

public World_Touch(iEnt, id)
{
	if(	!g_bRoundEnd
	&&	g_bNoFallDamage
	&&	IsPlayer(id)
	&&	HasUserWallHang(id)
	&&	!assassin_mod(id)
	&&	!sniper_mod(id)
	&&	!ghost_mod(id)
	&&	~IsUserHanged(id)
	&&	is_user_alive(id)
	&&	pev(id, pev_button) & IN_USE
	&&	~pev(id, pev_flags) & FL_ONGROUND	)
	{
		SetUserHanged(id)
		pev(id, pev_mins, g_fVecMins[id])
		pev(id, pev_maxs, g_fVecMaxs[id])
		pev(id, pev_origin, g_fVecOrigin[id])
	}
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!t2", "^0");
	
	if (id) players[0] = id; else get_players(players, count, "ch");
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}