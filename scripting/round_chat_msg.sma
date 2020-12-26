#include <amxmodx>
#include <amxmisc>

new rounds_elapsed;
new play_sound;
new chat_message;
new g_maxplayers;
new g_map[32]
new say_text;

public plugin_init()
{
	/* Register plugin and author */
	register_plugin("Vox Round Say", "1.3", "God@Dorin")

	/* Register new round events */
	register_event("HLTV", "new_round", "a", "1=0", "2=0");
	register_event("TextMsg", "restart_round", "a", "2=#Game_will_restart_in");

	/* Register language file */
	register_dictionary("round_message.txt");

	/* Register plugin cvars */
	play_sound = register_cvar("amx_playsound","1");
	chat_message = register_cvar("amx_chatmessage","1");
	g_maxplayers = get_maxplayers();
	get_mapname(g_map, 31);
	
	say_text = get_user_msgid("SayText");
}

public new_round()
{
	rounds_elapsed += 1;
	
	new p_playernum;
	p_playernum = get_playersnum(1);
	
	if(get_pcvar_num(chat_message) == 1)
	{	
		client_printc(0, "!t[!tGG!t] !yRound: !t%d !y- Map: !t%s !y| Players: !g%d!y/!g%d !y!", rounds_elapsed, g_map, p_playernum, g_maxplayers);
	}

	if(get_pcvar_num(play_sound) == 1)
	{
		new rndctstr[21];
		num_to_word(rounds_elapsed, rndctstr, 20);
		client_cmd(0, "spk ^"vox/round %s^"",rndctstr);
	}
}

public restart_round()
{
	rounds_elapsed = 0;	
}

stock client_printc(const id, const string[], {Float, Sql, Resul,_}:...) {
	
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"!g","^4");
	replace_all(msg,190,"!y","^1");
	replace_all(msg,190,"!t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	new index;
	for (new i = 0 ; i < count ; i++)
	{
		index = players[i];
		message_begin(MSG_ONE_UNRELIABLE, say_text,_, index);
		write_byte(index);
		write_string(msg);
		message_end();  
	}  
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
