#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

enum
{
	RED = 1,
	BLUE,
	YELLOW,
	GREEN
};

new plugin_info[3][] = {
	"Native CzeroTutor",
	"1.1",
	"MMYTH"
};

new exists_tutor[33];

new g_tutortext, g_tutorclose;

public plugin_init()
{
	register_plugin(plugin_info[0], plugin_info[1], plugin_info[2]);
	
	g_tutortext = get_user_msgid("TutorText");
	g_tutorclose = get_user_msgid("TutorClose");
}

public plugin_natives()
{
	register_native("czerotutor_create", "native_czerotutor_create", 1);
	register_native("czerotutor_exists", "native_czerotutor_exists", 1);
	register_native("czerotutor_remove", "native_czerotutor_remove", 1);
}

public client_disconnect(id)
{
	exists_tutor[id] = 0;
}

public native_czerotutor_create(id, text[], color, sound[], Float:Time)
{
	if(!id || !is_user_connected(id) || equal(text, ""))
	{
		return 0;
	}
	
	if(!equal(sound, ""))
	{
		new soundlen = strlen(sound);
		
		if(sound[soundlen - 1] =='v' && sound[soundlen - 2] =='a' && sound[soundlen - 3] =='w')
		{
			client_cmd(id, "spk ^"%s^"", sound);
		}
		if(sound[soundlen - 1] =='3' && sound[soundlen - 2] =='p' && sound[soundlen - 3] =='m')
		{
			client_cmd(id, "mp3 play ^"%s^"", sound);
		}
	}
	
	message_begin(MSG_ONE, g_tutortext, _, id);
	write_string(text);
	write_byte(0);
	write_short(0);
	write_short(0);
	write_short(1<<color);
	message_end();
	
	if(Time != 0.0)
	{
		if(task_exists(id)) remove_task(id);
		
		set_task(Time, "native_czerotutor_remove", id);
	}
	
	exists_tutor[id] = 1;
	
	return 1;
}

public native_czerotutor_exists(id)
{
	if(!id || !is_user_connected(id))
	{
		return 0;
	}
	
	return exists_tutor[id];
}

public native_czerotutor_remove(id)
{
	if(!id || !is_user_connected(id))
	{
		return 0;
	}
	
	message_begin(MSG_ALL, g_tutorclose, _, id);
	message_end();
	
	exists_tutor[id] = 0;
	
	return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
