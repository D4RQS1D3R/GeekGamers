#include <amxmodx>

#pragma compress 1

native assassin_mod(id);
native sniper_mod(id);
native ghost_mod(id);

public plugin_init() 
{ 
	register_plugin("[GG] No Kill Slay", "1.0", "~D4rkSiD3Rs~");

	register_clcmd("say ", "client_chat", -1);
	register_clcmd("say_team ", "client_chat", -1) ;
}

public client_chat(id)
{
	new say[192];
	read_args(say, 192);
	
	if( containi(say, "no") != -1 && containi(say, "ki") != -1 && containi(say, "l") != -1 )
	{
		/*
		if(is_user_alive(id) && !assassin_mod(id) && !sniper_mod(id) && !ghost_mod(id))
			user_silentkill(id);
		*/
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}