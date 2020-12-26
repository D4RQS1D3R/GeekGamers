/*
	Suicide Bomber Information Center:
	
	The 'Suicide Bomber' idea came to me from a
	somewhat old mod that Exolent made (I've
	also made a version myself). Once you've
	gotten enough cash (cvar controlled), you
	will be permitted to purchase a 'Suicide Bomb'.
	You will then be able to activate it and blow
	anyone up in a certain radius of yourself, 
	thus creating an epic death scene.
*/

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define PLUGIN	"Suicide Bomb"
#define AUTHOR	"GXLZPGX"
#define VERSION	"1.5"

#define is_player(%1)    (1 <= %1 <= g_iMaxPlayers)
#define BOMB			100

/* Self explanitory private variables */
new g_BombTimer[33];

/* Self explanitory private bools */
new bool:g_HasBomb[33];
new bool:g_BombRemoved[33];

/* Self explanitory public variables */
new pcvar_BombEnable;
new pcvar_BombPrice;
new pcvar_BombTimer;
new pcvar_BombRadius;
new pcvar_BombFF;

/* Self explanitory public bools */
new bool:g_RoundEnded;

/* Self explanitory sound path */
new const gszC4[] = "weapons/c4_beep4.wav"
new const gszC4LastWords[] = "[GeekGamers]/allahu_akbar.wav"
new const gszC4Explosion[] = "[GeekGamers]/suicide_bomb.wav"

/* Self explanitory sprites */
new gBombSprite;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	/* Player commands */
	/*
	register_clcmd( "say /buybomb", "Bomb_Buy" )
	register_clcmd( "say /bb", "Bomb_Buy" )
	register_clcmd( "say_team /buybomb", "Bomb_Buy" )
	register_clcmd( "say_team /bb", "Bomb_Buy" )
	*/
	/* Server vars */
	pcvar_BombEnable	=	register_cvar( "sb_enabled", "1" )
	pcvar_BombPrice		=	register_cvar( "sb_price", "16000" )
	pcvar_BombTimer		=	register_cvar( "sb_timer", "3" )
	pcvar_BombRadius	=	register_cvar( "sb_radius", "400" )
	pcvar_BombFF		=	register_cvar( "sb_friendlyfire", "0" )
	
	/* Hooking flashlight */
	register_impulse( 100, "Event_Flashlight" )
	
	/* Round beginning */
	register_logevent( "Event_RoundBegin", 2, "1=Round_Start" )
	
	/* Round ending */
	register_logevent( "Event_RoundEnd", 2, "1=Round_End" )

	/* Death Event */
	RegisterHam(Ham_Killed, "player", "Event_DeathMsg")
}

public plugin_natives()
{
	register_native( "gg_set_user_suicidebomb", "set_user_suicidebomb", 1 );
}

public set_user_suicidebomb(id)
{
	g_HasBomb[id] = true;
	g_BombRemoved[id] = true;
}

public client_disconnected(id)
{
	g_HasBomb[id] = false;
}

public plugin_precache()
{
	precache_sound( gszC4 )
	precache_sound( gszC4LastWords )
	precache_sound( gszC4Explosion )
	gBombSprite = precache_model("models/[GeekGamers]/fireexp.spr");
}

public Event_RoundEnd()
{
	g_RoundEnded = true;
}

public Event_RoundBegin()
{
	g_RoundEnded = false;
	
	arrayset( g_HasBomb, false, charsmax(g_HasBomb) )
	arrayset( g_BombRemoved, false, charsmax(g_BombRemoved) )
}

public Event_DeathMsg(const victim, const attacker)
{
	if( g_BombTimer[victim] > 0 )
	{
		g_BombTimer[victim] = 0
		CountDownExplode(victim)
	}
}

public Bomb_Buy(id)
{
	if( get_pcvar_num(pcvar_BombEnable) == 0 )
	{
		client_print( id, print_chat, "[Suicide Bomb] Suicide bombs are currently disabled." )
		return PLUGIN_HANDLED;
	}
	
	new szBombMenu[104];
	formatex( szBombMenu, charsmax(szBombMenu), "\ySuicide Bomb Shop^n\rCurrent Price:\w %d^n^n\w Are you sure you want to buy a suicide bomb?", get_pcvar_num(pcvar_BombPrice) )
	new menu = menu_create( szBombMenu, "BombMenu_Handler" )
	
	menu_additem( menu, "Yes", "1", 0 )
	menu_additem( menu, "No", "2", 0 )
	
	menu_display( id, menu, 0 )
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL )
	
	return PLUGIN_HANDLED
}

public BombMenu_Handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item )
	{
		case 1:
		{
			new money = cs_get_user_money(id)
			
			if( (money >= get_pcvar_num(pcvar_BombPrice)) && g_BombRemoved[id] == false )
			{
				cs_set_user_money( id, money - get_pcvar_num(pcvar_BombPrice) )
				client_print( id, print_chat, "[Suicide Bomb] You're now armed with a suicide bomb. Use your flashlight to activate it." )
				g_HasBomb[id] = true;
				g_BombRemoved[id] = true;
			} else {
				client_print( id, print_chat, "[Suicide Bomb] You're not permitted to use that!" )
			}
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Event_Flashlight(id)
{
	if( g_HasBomb[id] == true && g_RoundEnded == false && is_user_alive(id) )
	{
		if( task_exists( BOMB + id ) )
		{
			return PLUGIN_HANDLED;
		}
		
		g_BombTimer[id] = get_pcvar_num(pcvar_BombTimer);
		set_task( 1.0, "CountDownExplode", BOMB + id, _, _, "b" )
		ChatColor(id, "!g[GG][Level-Menu] !nBomb exploding in !t3 seconds!n, get near to enemies !");
	}
	
	return PLUGIN_CONTINUE;
}

public CountDownExplode(id)
{
	id -= BOMB
	
	if( /* !is_user_alive(id) || */ g_RoundEnded == true )
	{
		remove_task( id + BOMB )
		return PLUGIN_HANDLED;
	}
	
	if( g_BombTimer[id] > 0 )
	{
		if( g_BombTimer[id] == 1 )
		{
			emit_sound(id, CHAN_AUTO, gszC4LastWords, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}

		if( g_BombTimer[id] > 2 )
		{
			emit_sound(id, CHAN_AUTO, gszC4, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		
		g_BombTimer[id] -= 1
	} else {
		Explode(id)
		
		remove_task( id + BOMB )
	}

	return PLUGIN_CONTINUE;
}

Explode(id)
{
	emit_sound(id, CHAN_AUTO, gszC4Explosion, 1.0, ATTN_NORM, 0, PITCH_NORM)

	new origin[3]
	get_user_origin(id, origin, 0)
	
	message_begin( MSG_PVS, SVC_TEMPENTITY )
	write_byte(TE_TAREXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	message_end()

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(gBombSprite)
	write_byte(30)
	write_byte(15)
	write_byte(0)
	message_end()
		
	new iPlayers[32], iNum, plr;
	get_players(iPlayers, iNum, "ah" )
	
	for( new i = 0; i < iNum; i++ )
	{
		plr = iPlayers[i]
		
		new origin2[3];
		get_user_origin( plr, origin2, 0 )
		
		if( get_distance( origin, origin2 ) <= get_pcvar_num(pcvar_BombRadius) && is_user_alive(plr) )
		{
			if( get_pcvar_num(pcvar_BombFF) == 1 )
			{
				user_silentkill(plr)
				
				Create_DeathMsg( plr, id )
			} else {
				if( (cs_get_user_team(id) != cs_get_user_team(plr)) )
				{
					user_silentkill(plr)
					
					Create_DeathMsg( plr, id )
				}
			}
		}
	}
	
	user_silentkill(id)
}

public Create_DeathMsg( Victim, Attacker )
{
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"), {0,0,0});
	write_byte(Attacker);
	write_byte(Victim);
	write_byte(1)
	write_string("hegrenade");
	message_end();
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