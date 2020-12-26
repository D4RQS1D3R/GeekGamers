#include <amxmodx>

public plugin_precache()
	register_plugin	(
					"Block Unknown Command",
					"Alpha",
					"WPMG PRoSToTeM@"
					);

public plugin_init()
	register_message(get_user_msgid("TextMsg"), "MessageTextMsg");

public MessageTextMsg()
{
	new szArg2[32];
	
	get_msg_arg_string(2, szArg2, 31);
	
	if (!equal(szArg2, "#Game_unknown_command"))
		return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}