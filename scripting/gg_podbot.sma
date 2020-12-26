#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <engine>
#include <Colorchat>

#pragma compress 1

new maxbots;
new minbots;
new bots_manager;
new botson;
new ChatMessage[33];

native bool: FreeVIP(id);
native bool: dont_show_weaponsmenu(id);
native get_level(id);

native gg_set_user_goldak47(id);
native gg_set_user_goldm4a1(id);
native gg_set_user_goldmp5navy(id);
native gg_set_user_goldxm1014(id);
native gg_set_user_gatling(id);
native gg_set_user_k1ases(id);
native gg_set_user_m4a1darkknight(id);
native gg_set_user_m3bd(id);
native gg_set_user_crossbow(id);
native gg_set_user_dualberetta(id);

public plugin_init()
{
	register_plugin("[GG] Bots Manager", "1.0", "~D4rkSiD3Rs~");

	register_impulse(100, "FlashLight");

	maxbots = register_cvar("amx_maxbots", "0");
	minbots = register_cvar("amx_minbots", "0");

	bots_manager = register_cvar("amx_bots_manager", "4");

	RegisterHam(Ham_Spawn, "player", "Ham_CBasePlayer_Spawn_Post", 1);

	// set_task(random_float(120.0, 300.0), "Remove_Bot", _, _, _, "b");
}
/*
public client_command(id)
{
	new command[512];
	read_argv(0, command, 511);
	
	if(equali(command, "status"))
	{
		force_cmd(id, "clear");
	}
}
*/
public client_putinserver(id)
{
	new ip[32];
	get_user_ip(id, ip, 31);

	if( equali(ip, "127.0.0.1") )
	{
		switch( random_num(1,3) )
		{
			case 1: ChatMessage[id] = 1;
			case 2: ChatMessage[id] = 2;
			case 3: ChatMessage[id] = 3;
		}
	}

	set_task(1.0, "Manage_Bots");
}

public client_disconnected(id)
{
	set_task(1.0, "Manage_Bots");
}

public Manage_Bots()
{
	new heure[3];
	get_time("%H",heure,2);
	new n_heure = str_to_num(heure);

	switch( get_pcvar_num(bots_manager) )
	{
		case 0:
		{
			server_cmd("amx_unban 127.0.0.1");
			server_cmd("pb_maxbots 0");
			server_cmd("pb_minbots 0");
			server_cmd("amx_maxbots 0");
			server_cmd("amx_minbots 0");
			server_cmd("pb removebots");
			botson = false;
		}
		case 1:
		{
			server_cmd("amx_unban 127.0.0.1");
			server_cmd("pb_maxbots 6");
			server_cmd("pb_minbots 6");
			server_cmd("amx_maxbots 6");
			server_cmd("amx_minbots 6");
			botson = true;
		}
		case 2:
		{
			if( 03 <= n_heure <= 09 )
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots 0");
				server_cmd("pb_minbots 0");
				server_cmd("amx_maxbots 0");
				server_cmd("amx_minbots 0");
				server_cmd("pb removebots");
				botson = false;
			}

			if( 00 <= n_heure <= 02 )
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots 4");
				server_cmd("pb_minbots 4");
				server_cmd("amx_maxbots 4");
				server_cmd("amx_minbots 4");
				botson = true;
			}

			if( 10 <= n_heure <= 23 )
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots 6");
				server_cmd("pb_minbots 6");
				server_cmd("amx_maxbots 6");
				server_cmd("amx_minbots 6");
				botson = true;
			}
		}
		case 3:
		{
			new iPlayers[32], iNum;
			get_players(iPlayers, iNum, "c")

			if(iNum >= 3)
			{
				if(iNum >= 23)
				{
					server_cmd("amx_unban 127.0.0.1");
					server_cmd("pb_maxbots %d", 28 - iNum);
					server_cmd("pb_minbots %d", 28 - iNum);
					server_cmd("amx_maxbots %d", 28 - iNum);
					server_cmd("amx_minbots %d", 28 - iNum);
					botson = true;
				}
				else
				{
					server_cmd("amx_unban 127.0.0.1");
					server_cmd("pb_maxbots 6");
					server_cmd("pb_minbots 6");
					server_cmd("amx_maxbots 6");
					server_cmd("amx_minbots 6");
					botson = true;
				}
			}
			else
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots 0");
				server_cmd("pb_minbots 0");
				server_cmd("amx_maxbots 0");
				server_cmd("amx_minbots 0");
				server_cmd("pb removebots");
				botson = false;
			}
		}
		case 4:
		{
			new iPlayers[32], iNum;
			get_players(iPlayers, iNum, "c")
			
			if(0 < iNum < 4)
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots %d", 4 - iNum);
				server_cmd("pb_minbots %d", 4 - iNum);
				server_cmd("amx_maxbots %d", 4 - iNum);
				server_cmd("amx_minbots %d", 4 - iNum);
				botson = true;
			}
			else
			{
				server_cmd("amx_unban 127.0.0.1");
				server_cmd("pb_maxbots 0");
				server_cmd("pb_minbots 0");
				server_cmd("amx_maxbots 0");
				server_cmd("amx_minbots 0");
				server_cmd("pb removebots");
				botson = false;
			}
		}
	}
}

public Ham_CBasePlayer_Spawn_Post(id)
{
	if( dont_show_weaponsmenu(id) || !is_user_alive(id) )
		return;

	new ip[32]
	get_user_ip(id, ip, 31)

	if( equali(ip, "127.0.0.1") && (cs_get_user_team(id) != CS_TEAM_SPECTATOR) && (cs_get_user_team(id) != CS_TEAM_UNASSIGNED) )
	{
		// set_task(random_float(1.0, 20.0), "BotChat", id);
		set_task(0.5, "SetWeapons", id);
	}
}

public SetWeapons(id)
{
	if( !is_user_alive(id) )
		return;

	strip_user_weapons(id);
	give_item(id, "weapon_knife");

	if( cs_get_user_team(id) == CS_TEAM_CT )
		set_task(random_float(1.0, 8.0), "SetRandomPrimaryWeapon", id);
}

public SetRandomPrimaryWeapon(id)
{
	if( !is_user_alive(id) )
		return;

	switch( random_num(1,17) )
	{
		case 1:
		{
			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id, CSW_M4A1, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 2:
		{
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id, CSW_AK47, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 3:
		{
			give_item(id, "weapon_aug");
			cs_set_user_bpammo(id, CSW_AUG, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 4:
		{
			give_item(id, "weapon_awp");
			cs_set_user_bpammo(id, CSW_AWP, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 5:
		{
			give_item(id, "weapon_ump45");
			cs_set_user_bpammo(id, CSW_UMP45, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 6:
		{
			give_item(id, "weapon_mp5navy");
			cs_set_user_bpammo(id, CSW_MP5NAVY, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 7:
		{
			give_item(id, "weapon_m3");
			cs_set_user_bpammo(id, CSW_M3, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 8:
		{
			give_item(id, "weapon_xm1014");
			cs_set_user_bpammo(id, CSW_XM1014, 90);
			SetRandomSecondaryWeapon(id);
		}
		case 9:
		{
			gg_set_user_gatling(id);
			SetRandomSecondaryWeapon(id);
		}
		case 10:
		{
			gg_set_user_k1ases(id);
			SetRandomSecondaryWeapon(id);
		}
		case 11:
		{
			gg_set_user_m4a1darkknight(id);
			SetRandomSecondaryWeapon(id);
		}
		case 12:
		{
			gg_set_user_m3bd(id);
			SetRandomSecondaryWeapon(id);
		}
		case 13:
		{
			gg_set_user_crossbow(id);
			SetRandomSecondaryWeapon(id);
		}
		case 14:
		{
			if(FreeVIP(id))
			{
				gg_set_user_goldm4a1(id);
				SetRandomSecondaryWeapon(id);
			}
			else SetRandomPrimaryWeapon(id);
		}
		case 15:
		{
			if(FreeVIP(id))
			{
				gg_set_user_goldak47(id);
				SetRandomSecondaryWeapon(id);
			}
			else SetRandomPrimaryWeapon(id);
		}
		case 16:
		{
			if(FreeVIP(id))
			{
				gg_set_user_goldmp5navy(id);
				SetRandomSecondaryWeapon(id);
			}
			else SetRandomPrimaryWeapon(id);
		}
		case 17:
		{
			if(FreeVIP(id))
			{
				gg_set_user_goldxm1014(id);
				SetRandomSecondaryWeapon(id);
			}
			else SetRandomPrimaryWeapon(id);
		}
	}
}

public SetRandomSecondaryWeapon(id)
{
	if( !is_user_alive(id) )
		return;

	switch( random_num(1,7) )
	{
		case 1:
		{
			give_item(id, "weapon_usp");
			cs_set_user_bpammo(id, CSW_USP, 90);
		}
		case 2:
		{
			give_item(id, "weapon_glock18");
			cs_set_user_bpammo(id, CSW_GLOCK18, 90);
		}
		case 3:
		{
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id, CSW_DEAGLE, 90);
		}
		case 4:
		{
			give_item(id, "weapon_p228");
			cs_set_user_bpammo(id, CSW_P228, 90);
		}
		case 5:
		{
			give_item(id, "weapon_elite");
			cs_set_user_bpammo(id, CSW_ELITE, 90);
		}
		case 6:
		{
			give_item(id, "weapon_fiveseven");
			cs_set_user_bpammo(id, CSW_FIVESEVEN, 90);
		}
		case 7:
		{
			gg_set_user_dualberetta(id);
		}
	}
}

public BotChat(id)
{
	if(!is_user_connected(id))
		return;

	new alive[11], vip[11], vip2[11], szName[33];
	get_user_name(id, szName, charsmax(szName));

	if(is_user_alive(id))
	{
		alive = "^1"
	}
	else
	{
		alive = "^1*DEAD* "
	}

	if(FreeVIP(id))
	{
		vip = "^4[^3VIP^4] "
	}
	else
	{
		vip = "^1"
	}

	if(FreeVIP(id))
	{
		vip2 = "^4"
	}
	else
	{
		vip2 = "^1"
	}

	switch(ChatMessage[id])
	{
		case 1:
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
				ColorChat(0, RED, "%s%s^4[LEVEL %i]^3 %s ^1:%s Shop By [Geek~Gamers]", alive, vip, get_level(id), szName, vip2)
			else
			if(cs_get_user_team(id) == CS_TEAM_CT)
				ColorChat(0, BLUE, "%s%s^4[LEVEL %i]^3 %s ^1:%s Shop By [Geek~Gamers]", alive, vip, get_level(id), szName, vip2)
		}
		case 2:
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
				ColorChat(0, RED, "%s%s^4[LEVEL %i]^3 %s ^1:%s shop", alive, vip, get_level(id), szName, vip2)
			else
			if(cs_get_user_team(id) == CS_TEAM_CT)
				ColorChat(0, BLUE, "%s%s^4[LEVEL %i]^3 %s ^1:%s shop", alive, vip, get_level(id), szName, vip2)
		}
		case 3:
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
				ColorChat(0, RED, "%s%s^4[LEVEL %i]^3 %s ^1:%s Shop", alive, vip, get_level(id), szName, vip2)
			else
			if(cs_get_user_team(id) == CS_TEAM_CT)
				ColorChat(0, BLUE, "%s%s^4[LEVEL %i]^3 %s ^1:%s Shop", alive, vip, get_level(id), szName, vip2)
		}
	}
}
/*
public Remove_Bot()
{
	if(!botson)
		return;

	new iPlayers[32], iNum;
	get_players (iPlayers, iNum);
	if( iNum )
	{
		new iRandomIndex = random( iNum );
		new RandomBot = iPlayers[ iRandomIndex ];

		new userid = get_user_userid(RandomBot);

		new ip[32];
		get_user_ip(RandomBot, ip, 31);

		if( !equali(ip, "127.0.0.1") || cs_get_user_team(RandomBot) == CS_TEAM_SPECTATOR || cs_get_user_team(RandomBot) == CS_TEAM_UNASSIGNED )
		{
			Remove_Bot();
			return;
		}

		server_cmd("kick #%i", userid);
	}
}
*/
public Remove_Bot()
{
	if(!botson)
		return;

	server_cmd("amx_maxbots %d", get_pcvar_num(maxbots) - 1);
	server_cmd("amx_minbots %d", get_pcvar_num(minbots) - 1);
	server_cmd("pb_maxbots %d", get_pcvar_num(maxbots));
	server_cmd("pb_minbots %d", get_pcvar_num(minbots));

	set_task(random_float(3.0, 10.0), "Add_Bot");
}

public Add_Bot()
{
	if(!botson)
		return;

	server_cmd("amx_maxbots %d", get_pcvar_num(maxbots) + 1);
	server_cmd("amx_minbots %d", get_pcvar_num(minbots) + 1);
	server_cmd("pb_maxbots %d", get_pcvar_num(maxbots));
	server_cmd("pb_minbots %d", get_pcvar_num(minbots));
}

public FlashLight(id)
{
	return is_user_bot(id) ? PLUGIN_HANDLED : PLUGIN_CONTINUE
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
