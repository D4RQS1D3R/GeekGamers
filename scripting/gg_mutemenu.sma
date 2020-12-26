#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#pragma compress 1

#define PLUGIN 	"mute menu"
#define VERSION "1.0"
#define AUTHOR 	"cheap_suit"

#define MAX_PLAYERS 32

new bool:g_mute[MAX_PLAYERS+1][MAX_PLAYERS+1]
new g_menuposition[MAX_PLAYERS+1]
new g_menuplayers[MAX_PLAYERS+1][32]
new g_menuplayersnum[MAX_PLAYERS+1]

new cvar_alltalk
new g_maxclients

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SPONLY|FCVAR_SERVER)

	register_clcmd("say", "clcmd_say")
	register_clcmd("say_team", "clcmd_say")

	register_forward(FM_Voice_SetClientListening, "fwd_voice_setclientlistening")
	register_menucmd(register_menuid("mute menu"), 1023, "action_mutemenu")
	
	cvar_alltalk = get_cvar_pointer("sv_alltalk")
	g_maxclients = global_get(glb_maxClients)
}

public client_putinserver(id)
	clear_list(id)
	
public client_disconnect(id)
	clear_list(id)

clear_list(id)
{
	for(new i = 0; i <= g_maxclients; ++i) 
		g_mute[id][i] = false
}

public clcmd_say(id)
{
	static say_args[10]
	read_args(say_args, 9)
	remove_quotes(say_args)
	
	if(say_args[0] == '/' && containi(say_args, "mute") != -1)
	{
		display_mutemenu(id, g_menuposition[id] = 0)
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}

public fwd_voice_setclientlistening(receiver, sender, listen) 
{
	if(receiver == sender)
		return FMRES_IGNORED
		
	if(g_mute[receiver][sender])
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

display_mutemenu(id, pos) 
{
	if(pos < 0)  
		return
		
	static team[11]
	get_user_team(id, team, 10)
	
	new at = get_pcvar_num(cvar_alltalk)
	get_players(g_menuplayers[id], g_menuplayersnum[id], 
	at ? "c" : "ce", at ? "" : team)

  	new start = pos * 8
  	if(start >= g_menuplayersnum[id])
    		start = pos = g_menuposition[id]

  	new end = start + 8
	if(end > g_menuplayersnum[id])
    		end = g_menuplayersnum[id]
	
	static menubody[512]	
  	new len = format(menubody, 511, "\d[\yGeek~Gamers\d] \rMute Menu:^n^n")

	static name[32]
	
	new b = 0, i
	new keys = MENU_KEY_0
	
  	for(new a = start; a < end; ++a)
	{
    		i = g_menuplayers[id][a]
    		get_user_name(i, name, 31)
		
		if(i == id)
		{
			continue
			//++b
			//len += format(menubody[len], 511 - len, "\d%s %s\w^n", name, g_mute[id][i] ? "\r(Self)" : "\r(Self)")
		}
		else
		{
			keys |= (1<<b)
			len += format(menubody[len], 511 - len, "%s%d. %s %s\w^n", g_mute[id][i] ? "\w" : "\w", ++b, name, g_mute[id][i] ? "\r[Muted]" : "\d[Not Muted]")
		}
	}

  	if(end != g_menuplayersnum[id]) 
	{
    		format(menubody[len], 511 - len, "^n9. %s...^n0. %s", "More", pos ? "Back" : "Exit")
    		keys |= MENU_KEY_9
  	}
  	else
		format(menubody[len], 511-len, "^n0. %s", pos ? "Back" : "Exit")
	
  	show_menu(id, keys, menubody, -1, "mute menu")
}


public action_mutemenu(id, key)
{
	switch(key) 
	{
    		case 8: display_mutemenu(id, ++g_menuposition[id])
		case 9: display_mutemenu(id, --g_menuposition[id])
    		default: 
		{
			new player = g_menuplayers[id][g_menuposition[id] * 8 + key]
			
			g_mute[id][player] = g_mute[id][player] ? false : true
			display_mutemenu(id, g_menuposition[id])
			
			static name[32]
			get_user_name(player, name, 31)
			client_print(id, print_chat, "You have %smuted %s", g_mute[id][player] ? "" : "un", name)
    		}
  	}
	return PLUGIN_HANDLED
}
