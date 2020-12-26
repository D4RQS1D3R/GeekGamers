#include <amxmodx>

#define VIP ADMIN_LEVEL_G

#pragma tabsize 0

enum
{
	SCOREATTRIB_ARG_PLAYERID = 1,
	SCOREATTRIB_ARG_FLAGS
};

enum ( <<= 1 )
{
	SCOREATTRIB_FLAG_NONE = 0,
	SCOREATTRIB_FLAG_DEAD = 1,
	SCOREATTRIB_FLAG_BOMB,
	SCOREATTRIB_FLAG_VIP
};

public plugin_init()
{
	register_plugin("Vip Score Tab", "2.3", "~D4rkSiD3Rs~")
	
	register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" );
}

public MessageScoreAttrib( iMsgID, iDest, iReceiver )
{
	new iPlayer = get_msg_arg_int( 1 );

	if(is_user_connected(iPlayer) && (get_user_flags(iPlayer) & VIP))
	{
		set_msg_arg_int( 2, ARG_BYTE, is_user_alive( iPlayer ) ? SCOREATTRIB_FLAG_VIP : SCOREATTRIB_FLAG_DEAD );
	}
}
