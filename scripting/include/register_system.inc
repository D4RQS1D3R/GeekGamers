#if defined _register_system_included
	#endinput
#endif
#define _register_system_included


#if AMXX_VERSION_NUM >= 175
	#pragma reqlib register_system
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib register_system
	#endif
#else
	#pragma library register_system
#endif


native is_registered(id)

native is_logged(id)

native is_autologged(id)

native get_cant_login_time(id)

native get_cant_change_pass_time(id)
