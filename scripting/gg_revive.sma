#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <Colorchat>
#include <hamsandwich>
#include <fun>

#pragma compress 1

#define PLUGIN "[GG] Revive Menu"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

#define GOLD_LEVEL ADMIN_LEVEL_E
#define DIAMOND_LEVEL ADMIN_LEVEL_D
#define OWNER_LEVEL ADMIN_LEVEL_C
#define OWNERCMD_LEVEL ADMIN_LEVEL_B

new bool: RevivedT[33];
new bool: RevivedCT[33];
new bool: RevivedAll[33];

new g_revive[33];
new trevived;
new ctrevived;
new allrevived;

new silver_max_revives;
new diamond_max_revives;
new max_revives;

native MenuArme(id);
native MenuKnife(id);
native get_level(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_clcmd("say /revive","menurevive")
	register_clcmd("say /respawn","menurevive")
	register_clcmd("say /revivemenu","menurevive")
	register_clcmd("say /respawnmenu","menurevive")

	register_clcmd("reviveme", "Revive")
	register_clcmd("say /reviveme", "Revive")

	silver_max_revives = register_cvar("amx_silver_max_revives", "1");
	diamond_max_revives = register_cvar("amx_diamond_max_revives", "2");

	max_revives = register_cvar("amx_max_revives", "3");

	register_event("HLTV", "Round_Start", "a", "1=0", "2=0");
}

public plugin_natives()
{
	register_native("Respawn", "Revive", 1);
}

public Round_Start()
{
	new iPlayers[32], iNum;

	get_players(iPlayers, iNum);
	for (new i = 0; i < iNum; i++)
	{
		new iPlayer = iPlayers [ i ];

		g_revive[iPlayer] = 0;
		RevivedT[iPlayer] = false;
		RevivedCT[iPlayer] = false;
		RevivedAll[iPlayer] = false;
	}
}

public menurevive(id)
{
	if( !(get_user_flags(id) & ADMIN_KICK) )
		return PLUGIN_HANDLED;
	
	new InfoStatus[198], InfoStatus2[198], InfoStatus3[198];
	new Menu = menu_create("\d[\yGeek~Gamers\d] \rRevive Menu:", "menuMainHandle")
	
	menu_additem(Menu, "\wRespawn \ra \yPlayer^n" , "1", DIAMOND_LEVEL)
	
	menu_additem(Menu, "\wRespawn \rYour\ySelf \d[bind 'key' reviveme]^n" , "2", ADMIN_KICK)

	formatex(InfoStatus, charsmax(InfoStatus), "\wRespawn \rAll \yFuriens \r[\y%d\r/\y%d\r]", trevived, get_pcvar_num(max_revives))
	menu_additem(Menu, InfoStatus, "3", OWNER_LEVEL)

	formatex(InfoStatus2, charsmax(InfoStatus2), "\wRespawn \rAll \yAnti-Furiens \r[\y%d\r/\y%d\r]^n", ctrevived, get_pcvar_num(max_revives))
	menu_additem(Menu, InfoStatus2, "4", OWNER_LEVEL)

	formatex(InfoStatus3, charsmax(InfoStatus2), "\wRespawn \rAll \yPlayers \r[\y%d\r/\y%d\r]", allrevived, get_pcvar_num(max_revives))
	menu_additem(Menu, InfoStatus3, "5", OWNER_LEVEL)
	
	menu_setprop(Menu, MPROP_EXITNAME, "Exit")
	menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, Menu, 0)
	return PLUGIN_HANDLED
}

public menuMainHandle(id,menu,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}	
	new iPlayers[ 32 ], iNum;
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	
	new iArg[ 64 ], szName[ 32 ];
	read_argv( 1, iArg, charsmax( iArg ) );
	get_user_name( id, szName, charsmax( szName ) ); 
	get_players( iPlayers, iNum );

	new TPlayers[ 32 ], CTPlayers[ 32 ], TNum, CTNum;

	get_players( TPlayers, TNum, "ae", "TERRORIST" )
	get_players( CTPlayers, CTNum, "ae", "CT" )

	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
			if(get_user_flags(id) & OWNER_LEVEL)
			{
				ReviveMenu(id);
			}
			else
			{
				if( TNum == 1 || CTNum == 1 )
				{
					ColorChat(id, RED, "^4[GG] ^1You Can't Respawn Now ! Reason : There is a ^3Last Survivor !" );
				}
				else
				{
					ReviveMenu(id);
				}
			}
		}
		case 2: Revive(id);
		case 3:
		{
			if(get_user_flags(id) & OWNERCMD_LEVEL)
			{
				new iPlayers[ 32 ], iNum, i, players;
				get_players( iPlayers, iNum, "be", "TERRORIST" );
				for( i = 0; i < iNum; i++ )
				{
					players = iPlayers[ i ];

					if(players == id)
						continue;

					if(!is_user_alive(players))
						spawn_func(players);
				}
				ColorChat(0, RED, "^4[GG] ^1OWNER ^3%s ^1: Revived All ^4Dead Furiens", szName );
			}
			else
			{
				if(trevived < get_pcvar_num(max_revives))
				{
					if( TNum == 1 || CTNum == 1 )
					{
						ColorChat(id, RED, "^4[GG] ^1You Can't Respawn Now ! Reason : There is a ^3Last Survivor !" );
					}
					else
					{
						if(RevivedT[id]) 
						{
							ChatColor(id, "!t[GG][Respawn] !nYou Can Respawn !gAll Furiens !nOnly !t1 Time !nPer The Round");
							return PLUGIN_HANDLED;
						}

						new iPlayers[ 32 ], iNum, i, players;
						get_players( iPlayers, iNum, "be", "TERRORIST" );
						for( i = 0; i < iNum; i++ )
						{
							players = iPlayers[ i ];

							if(players == id)
								continue;

							if(!is_user_alive(players))
								spawn_func(players);
						}
						ColorChat(0, RED, "^4[GG] ^1ADMIN ^3%s ^1: Revived All ^4Dead Furiens", szName );
						RevivedT[id] = true;
						trevived ++;
						menurevive(id);
					}
				}
			}
		}
		case 4:
		{
			if(get_user_flags(id) & OWNERCMD_LEVEL)
			{
				new iPlayers[ 32 ], iNum, i, players;
				get_players( iPlayers, iNum, "be", "CT" );
				for( i = 0; i < iNum; i++ )
				{
					players = iPlayers[ i ];

					if(players == id)
						continue;


					if(!is_user_alive(players))
						spawn_func(players);
				}
				ColorChat(0, RED, "^4[GG] ^1OWNER ^3%s ^1: Revived All ^4Dead Anti-Furiens", szName );
			}
			else
			{
				if(ctrevived < get_pcvar_num(max_revives))
				{
					if( TNum == 1 || CTNum == 1 )
					{
						ColorChat(id, RED, "^4[GG] ^1You Can't Respawn Now ! Reason : There is a ^3Last Survivor !" );
					}
					else
					{
						if(RevivedCT[id]) 
						{
							ChatColor(id, "!t[GG][Respawn] !nYou Can Respawn !gAll Anti-Furiens !nOnly !t1 Time !nPer The Round");
							return PLUGIN_HANDLED;
						}

						new iPlayers[ 32 ], iNum, i, players;
						get_players( iPlayers, iNum, "be", "CT" );
						for( i = 0; i < iNum; i++ )
						{
							players = iPlayers[ i ];

							if(players == id)
								continue;

							if(!is_user_alive(players))
								spawn_func(players);
						}
						ColorChat(0, RED, "^4[GG] ^1ADMIN ^3%s ^1: Revived All ^4Dead Anti-Furiens", szName );
						RevivedCT[id] = true;
						ctrevived ++;
						menurevive(id);
					}
				}
			}
		}
		case 5:
		{
			if(get_user_flags(id) & OWNERCMD_LEVEL)
			{
				new iPlayers[ 32 ], iNum, i, players;
				get_players( iPlayers, iNum, "b" );
				for( i = 0; i < iNum; i++ )
				{
					players = iPlayers[ i ];

					if(cs_get_user_team(players) == CS_TEAM_UNASSIGNED || cs_get_user_team(players) == CS_TEAM_SPECTATOR)
						continue;

					spawn_func(players);
				}
				ColorChat(0, RED, "^4[GG] ^1OWNER ^3%s ^1: Revived All ^4Dead Players", szName );
			}
			else
			{
				if(allrevived < get_pcvar_num(max_revives))
				{
					if( TNum == 1 || CTNum == 1 )
					{
						ColorChat(id, RED, "^4[GG] ^1You Can't Respawn Now ! Reason : There is a ^3Last Survivor !" );
					}
					else
					{
						if(RevivedAll[id])
						{
							ChatColor(id, "!t[GG][Respawn] !nYou Can Respawn !gAll Players !nOnly !t1 Time !nPer The Round");
							return PLUGIN_HANDLED;
						}

						new iPlayers[ 32 ], iNum, i, players;
						get_players( iPlayers, iNum, "b" );
						for( i = 0; i < iNum; i++ )
						{
							players = iPlayers[ i ];

							if(cs_get_user_team(players) == CS_TEAM_UNASSIGNED || cs_get_user_team(players) == CS_TEAM_SPECTATOR)
								continue;

							spawn_func(players);
						}
						ColorChat(0, RED, "^4[GG] ^1ADMIN ^3%s ^1: Revived All ^4Dead Players", szName );
						RevivedAll[id] = true;
						allrevived ++;
						menurevive(id);
					}
				}
			}
		}
	}

	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public ReviveMenu(id)
{
	new RevivePlayer = menu_create ("\d[\yGeek~Gamers\d] \rRespawn Player:", "HandleRevive")
	
	new num, players[32], tempid, szTempID [10], szName [32], textmenu [64]
	get_players (players, num, "bc")
	
	for (new i = 0; i < num; i++)
	{
		tempid = players [ i ]
		
		get_user_name(tempid, szName, charsmax(szName))
		num_to_str (tempid, szTempID, 9)

		if( tempid == id )
			continue
		else
		if(cs_get_user_team(tempid) == CS_TEAM_T)
        		formatex(textmenu, 63, "%s \d- \r[Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_CT)
        		formatex(textmenu, 63, "%s \d- \y[Anti-Furien]", szName)
		else
		if(cs_get_user_team(tempid) == CS_TEAM_SPECTATOR)
			continue

		menu_additem (RevivePlayer, textmenu, szTempID, 0)
	}
	menu_display (id, RevivePlayer)
	return PLUGIN_HANDLED
}

public HandleRevive(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], name[64], szPlayerName[33], szName[33]
	new access, callback
	
	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num (data)
	
	get_user_name(id, szName, charsmax(szName))
	get_user_name(tempid, szPlayerName, charsmax(szPlayerName))

	if(g_revive[tempid] < 1)
	{
		if(get_user_flags(id) & OWNER_LEVEL)
			ColorChat(0, RED, "^4[GG] ^1OWNER ^3%s ^1: Respawn ^3%s", szName, szPlayerName)
		else
			ColorChat(0, RED, "^4[GG] ^1ADMIN ^3%s ^1: Respawn ^3%s", szName, szPlayerName)

		spawn_func(tempid)

		if(get_user_flags(tempid) & OWNERCMD_LEVEL) g_revive[tempid] = 0;
		else g_revive[tempid] ++;
	}
	else ChatColor(id, "!g[GG]!t %s !nis already respawned in This round!g.", szPlayerName)

	menu_destroy(menu);
	ReviveMenu(id);
	return PLUGIN_CONTINUE
}

public Revive(id)
{
	if( get_user_flags(id) & ADMIN_KICK || get_level(id) >= 80 )
	{
		new TPlayers[ 32 ], CTPlayers[ 32 ], TNum, CTNum;

		get_players( TPlayers, TNum, "ae", "TERRORIST" )
		get_players( CTPlayers, CTNum, "ae", "CT" )

		if(get_user_flags(id) & OWNERCMD_LEVEL)
		{
			spawn_func(id);
		}
		else
		{
			if( TNum == 1 || CTNum == 1 )
			{
				ColorChat(id, RED, "^4[GG] ^1You Can't Respawn Now ! Reason : There is a ^3Last Survivor !" );
			}
			else
			{
				if( (get_user_flags(id) & GOLD_LEVEL) && (get_user_flags(id) & DIAMOND_LEVEL) )
				{
					if(g_revive[id] >= get_pcvar_num(diamond_max_revives)) 
					{
						ChatColor(id, "!t[GG][Respawn] !nYou Can Respawn !gYourSelf !nOnly!t %d Time%s !nPer Round.", get_pcvar_num(diamond_max_revives), get_pcvar_num(diamond_max_revives) > 1 ? "s" : "");
						return;
					}
				}
				else
				{
					if(g_revive[id] >= get_pcvar_num(silver_max_revives)) 
					{
						ChatColor(id, "!t[GG][Respawn] !nYou Can Respawn !gYourSelf !nOnly!t %d Time%s !nPer Round.", get_pcvar_num(silver_max_revives), get_pcvar_num(silver_max_revives) > 1 ? "s" : "");
						return;
					}
				}

				if(!is_user_alive(id))
				{
					if(cs_get_user_team(id) != CS_TEAM_SPECTATOR)
					{
						spawn_func(id);
						g_revive[id] ++;
					}
				}
				else
				{
					ChatColor(id, "!g[GG] !nYou can't respawn yourself if You're alive !");
					menurevive(id);
				}
			}
		}
	}
}

public spawn_func(id) 
{
	ExecuteHamB(Ham_CS_RoundRespawn, id);

	if(cs_get_user_team(id) == CS_TEAM_CT)
		client_cmd(id, "weapons");
	else if(cs_get_user_team(id) == CS_TEAM_T)
		client_cmd(id, "knife");
}
/*
public spawn_func(id) 
{
	new svIndex[2];
	svIndex[0] = id;
	set_task(0.2, "respawn", 0, svIndex, 2);
}

public respawn(svIndex[]) 
{ 
	new vIndex = svIndex[0]
	spawn(vIndex)
}
*/
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
