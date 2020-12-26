#include <amxmodx>
#include <amxmisc>

/*////////// Comment this line (with "//") for logging without client's arguments after "autobuy " command. */
/*///////// Закомментируйте (2 слешами "//"), чтобы не писать в логах все, что игрок вводит в консоль после команды "fullupdate ". */
/*//////// Нежелательно комментировать, если Вы хотите отслеживать, кто из игроков пользуется crash-эксплоитом (autobuy). */
/*/////// Умышленно или нет игрок использует такую команду - вопрос десятый.. */
#define USE_AUTOBUY_ARGS_LOGGING



/* LOG Files ***************************************************************************************************
addons/amxmodx/logs/anti-crash/fullupdate.log          - log of cleitns, who used fullupdate commands;    *
addons/amxmodx/logs/anti-crash/fullupdate-BANNED.log   - who have a ban by this plugin;                   *
addons/amxmodx/logs/anti-crash/autobuy.log             - autobuy attempts.                                *
**********************************************************************************************************/


new currcount[33]
new logfile_fupd[128]
new logfile_fupd_ban[128]


#if defined USE_AUTOBUY_ARGS_LOGGING
	new logfile_autobuy[256]
#else
	new logfile_autobuy[128]
#endif


public plugin_init() {
	register_plugin("[GG] Anti-Crash With Logger", "0.1", "~D4rkSiD3Rs~")
	
	/* Client comand "fullupdate" */
	register_clcmd("fullupdate","fullupdate_block")
	
	/* Groud of client commands "AUTOBUY" */
	register_clcmd("cl_setautobuy", "autobuy_block")
	register_clcmd("cl_autobuy", "autobuy_block")
	register_clcmd("cl_setrebuy", "autobuy_block")
	register_clcmd("cl_rebuy", "autobuy_block")
	register_clcmd("autobuy", "autobuy_block")
	
	/* Translations */
	register_dictionary("anti-crash.txt")
	
	/* Log files */
	mkdir("addons/amxmodx/logs/GG_Anti-Crash")
	format(logfile_fupd,127,"addons/amxmodx/logs/anti-crash/fullupdate.log",logfile_fupd)
	format(logfile_fupd_ban,127,"addons/amxmodx/logs/anti-crash/fullupdate-BANNED.log",logfile_fupd_ban)
	format(logfile_autobuy,255,"addons/amxmodx/logs/anti-crash/autobuy.log",logfile_autobuy)
	
	
	
	/* CVARS */
	/*////////// Set the max allowed count client's fullupdate commands before he will be banned. */
	/*//////// Укажите максимальное кол-во раз ввода команды fullupdate игроком перед баном. */
	register_cvar("ac_fupdate_maxcount", "5")
	
	/*//////////  Autobuy message in chat: "Autobuy is no allowed" every time when client use an autobuy command. Set "0" to disable. */
	/*//////// Анонс в чате для игрока, использующего автобай: "Автозакупка не разрешена на сервере". Установите "0", чтобы выключить. */
	register_cvar("ac_autobuy_announce", "0")
	
	/*//////////  Autobuy message in chat: "Fullupdate is no allowed" every time when client use a fullupdate command. Set "0" to disable. */
	/*//////// Анонс в чате для игрока, использующего fullupdate: "Fullupdate не разрешен на сервере". Установите "0", чтобы выключить. */
	register_cvar("ac_fullupdate_announce", "0")
	
	/*////////// Sound announce for autobuy & fullupdate commands. Set "0" to disable. */
	/*//////// Звуковой анонс для команд autobuy & fullupdate. Установите "0", чтобы выключить. */
	register_cvar("ac_sound_announce", "0")
}


public fullupdate_block(id) {
	new name[33]
	get_user_name(id, name, 32)
	new authid[35], team[32]
	new userid = get_user_userid(id)
	new ip[33]
	get_user_ip(id, ip, 32)
	get_user_authid(id,authid,34)
	get_user_team(id,team,31)
	currcount[id] = (currcount[id] + 1)
	new maxcount = (get_cvar_num("ac_fupdate_maxcount"))
	if (currcount[id] < maxcount) {
		
		if(get_cvar_num("ac_fullupdate_announce") == 1) {
			client_print(id, print_chat, "%L", LANG_PLAYER, "FUWARN", name,currcount[id],maxcount)
		}
		if(get_cvar_num("ac_sound_announce") == 1) {
			new c_spkstr[24]
			new m_spkstr[24]
			num_to_word(currcount[id], c_spkstr, 23);
			num_to_word(maxcount, m_spkstr, 23);
			client_cmd(id, "spk ^"vox/bizwarn %s of %s^"", c_spkstr,m_spkstr)

		}

		log_to_file(logfile_fupd, "^"%s<%d><%s><%s><%s>^" use a *fullupdate* command (%i/%i)",name,userid,authid,team,ip,currcount[id],maxcount)
		return PLUGIN_HANDLED
	}
	
	else if (currcount[id] == maxcount) {
		client_print(0, print_chat, "%L", LANG_PLAYER, "FUBAN", name)		
		server_cmd("amx_addban ^"%s^" 0 ^"Attempted server crash.^"", authid)
		log_to_file(logfile_fupd_ban, "^"%s<%d><%s><%s><%s>^" got permanent ban. Reason: Attempted server crash.",name,userid,authid,team,ip)
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public autobuy_block(id){
	new name[33]
	get_user_name(id, name, 32)
	new authid[35], team[32]
	new userid = get_user_userid(id)
	new ip[33]
	get_user_ip(id, ip, 32)
	get_user_authid(id,authid,34)
	get_user_team(id,team,31)
	new CurrentDateTime[24]
	get_time("%d/%m/%YYYY - %HH:%MM:%SS",CurrentDateTime,23)

	if(get_cvar_num("ac_autobuy_announce") == 1) {
		//client_print(id, print_chat, "%L", LANG_PLAYER, "ABNA")
		//client_print(id, print_chat, "%L", LANG_PLAYER, "ABNA2")
	}
	if(get_cvar_num("ac_sound_announce") == 1) {
		client_cmd(id, "spk vox/bizwarn")
	}

	#if defined USE_AUTOBUY_ARGS_LOGGING
		new cl_args[128]
		read_args(cl_args, 127)
		log_to_file(logfile_autobuy, "^"%s<%d><%s><%s><%s>^" used AUTOBUY command. (Arguments: %s)",name,userid,authid,team,ip,cl_args)
	#else
		log_to_file(logfile_autobuy, "^"%s<%d><%s><%s><%s>^" used AUTOBUY command.",name,userid,authid,team,ip)
	#endif
	
	return PLUGIN_HANDLED
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
