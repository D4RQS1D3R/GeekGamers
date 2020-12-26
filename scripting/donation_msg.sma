#include <amxmodx>

public plugin_init()
{
	set_task(780.0, "ChatMsg", _, _, _, "b");
}

public ChatMsg()
{
	new iPlayers[32], iNum;
	get_players( iPlayers, iNum, "ch" );

	for( new i = 0 ; i < iNum ; i++ )
	{
		new id = iPlayers[i];
		
		ChatColor(id, "!g[!tGG!g][!tDonate!g] !nHelp fund !gGeekGamers !nto keep it alive and performing well,");
		ChatColor(id, "!nas well as earning some exclusive access in the server. !gPaypal: !nhttps://paypal.me/GeekGamersHosting");
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