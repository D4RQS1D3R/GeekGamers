#include <amxmodx>
#include <fakemeta>

#pragma semicolon 1

#define RED	235
#define GREEN	10
#define BLUE 	227

#define UPDATEINTERVAL	0.1

// Comment below if you do not want /speclist showing up on chat
#define ECHOCMD

// Admin flag used for immunity
#define FLAG ADMIN_KICK

#define DELAY_COUNT	1.0	//Delay between frame counts, adjust this according to server ticrate. MUST BE FLOAT

#define DELAY_COMMAND	5.0	//Delay between user /fps command. MUST BE FLOAT
#define COLOR		0x03	//0x01 normal, 0x04 green, 0x03 other. MUST BE CHAR

//#define MAX_PLAYERS	32 + 1
new g_iUserFPS[MAX_PLAYERS+1];

new const PLUGIN[] = "SpecList";
new const VERSION[] = "1.2a";
new const AUTHOR[] = "FatalisDK";

new gMaxPlayers;
new gCvarOn;
new gCvarImmunity;
new bool:gOnOff[33] = { true, ... };

native bool: HC_SpecList(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	gCvarOn = register_cvar("amx_speclist", "1", 0, 0.0);
	gCvarImmunity = register_cvar("amx_speclist_immunity", "1", 0, 0.0);
	
	register_clcmd("say /speclist", "cmdSpecList", -1, "");
	
	gMaxPlayers = get_maxplayers();

	register_forward(FM_PlayerPreThink, "fwdPlayerPreThink");

	set_task( UPDATEINTERVAL, "tskShowSpec", _, _, _, "b");
}

public cmdSpecList(id)
{
	if( gOnOff[id] )
	{
		client_print(id, print_chat, "[GG] You will no longer see who's spectating you.");
		gOnOff[id] = false;
	}
	else
	{
		client_print(id, print_chat, "[GG] You will now see who's spectating you.");
		gOnOff[id] = true;
	}
	
	#if defined ECHOCMD
	return PLUGIN_CONTINUE;
	#else
	return PLUGIN_HANDLED;
	#endif
}

public tskShowSpec()
{
	if( !get_pcvar_num(gCvarOn) )
	{
		return PLUGIN_CONTINUE;
	}
	
	static szHud[1102];//32*33+45
	static szName[34];
	static bool:send;
	
	// FRUITLOOOOOOOOOOOOPS!
	for( new alive = 1; alive <= gMaxPlayers; alive++ )
	{
		new bool:sendTo[33];
		send = false;
		
		if( !is_user_alive(alive) )
		{
			continue;
		}
		
		sendTo[alive] = true;
		
		get_user_name(alive, szName, 32);
		format(szHud, 45, "Spectating %s: [FPS: %d]^n", szName, g_iUserFPS[alive]);
		
		for( new dead = 1; dead <= gMaxPlayers; dead++ )
		{
			if( is_user_connected(dead) )
			{
				if( is_user_alive(dead)
				|| is_user_bot(dead) )
				{
					continue;
				}
				
				if( pev(dead, pev_iuser2) == alive )
				{
					if( !(get_pcvar_num(gCvarImmunity)&&get_user_flags(dead, 0)&FLAG) )
					{
						get_user_name(dead, szName, 32);
						add(szName, 33, "^n", 0);
						add(szHud, 1101, szName, 0);
						send = true;
					}

					sendTo[dead] = true;
				}
			}
		}
		
		if( send == true )
		{
			for( new i = 1; i <= gMaxPlayers; i++ )
			{
				if( sendTo[i] == true
				&& gOnOff[i] == true
				&& HC_SpecList(i) )
				{
					//set_hudmessage( RED, GREEN, BLUE, 0.75, 0.15, 0, 0.0, UPDATEINTERVAL + 0.1, 0.0, 0.0, 2);
					set_hudmessage( RED, GREEN, BLUE, 0.75, 0.15, _, _, 4.0, _, _, 2 );
					show_hudmessage(i, szHud);
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public client_connect(id)
{
	gOnOff[id] = true;
}

public client_disconnect(id)
{
	gOnOff[id] = true;
}

public fwdPlayerPreThink(id)
{
    
    static Float:fGameTime, Float:fCountNext[MAX_PLAYERS+1], iCountFrames[MAX_PLAYERS+1];
    
    if ( fCountNext[id] >= (fGameTime = get_gametime()) )
    {
        iCountFrames[id]++;
        
        return FMRES_IGNORED;
    }
    
    g_iUserFPS[id]        = iCountFrames[id];
    iCountFrames[id]    = 0;
    
    fCountNext[id]        = fGameTime + DELAY_COUNT;
    
    return FMRES_IGNORED;
}