#include <amxmodx>
#include <amxmisc>
#include <regex>

#define IP_PATTERN "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
#define STEAMID_PATTERN "STEAM_0:[01]:\d+"
#define TIME_PATTERN "([0|1]\d|2[0-3])(:([0-5]\d)){2}\s+(0[1-9]|[1|2][0-9]|3[0|1])\/(0[1-9]|1[0-2])\/(\d{4})"

#define IsValidIP(%1) (regex_match_c(%1,ip_pattern,ret)>0)
#define IsValidAUTHID(%1) (regex_match_c(%1,steamid_pattern,ret)>0)
#define IsValidTIME(%1) (regex_match_c(%1,time_pattern,ret)>0)

enum _:BanInfo
{
	bantype[8],
	target_authid[32],
	target_ip[16],
	target_name[64],
	bantime[32],
	unbantime[32],
	banner_authid[32],
	banner_ip[32],
	banner_name[64],
	reason[128]
};

new bool:MODE_ADDBAN,bool:MODE_QUERY_CONTINUE,bool:MODE_LOADBAN,bool:MODE_UNBAN;
new cvar_Flags,msgid,cvar_Contact,cvar_CheckInterval,cvar_vote_enable,cvar_vote_ratio,cvar_vote_delay,cvar_vote_time,cvar_vote_min,total,ids,TotalBans,Float:LastAuth;
new ub_banlistfile[256],Flags[26],player[32],LastQuery[33][64],LastQueryType[33][8],bool:handle_unban_menu_call[33],bool:handle_ban_menu_call[33];
new QueryPointer[33],QueryCount[33],auth_delay[33],STR_Menu_Ban_Duration[33][128],Float:Menu_Ban_Duration[33],Float:LastBanTime,Menu_Ban_Target[33];
new Menu_Ban_Players[33][32],Menu_Ban_Total[33],Menu_Ban_BanType[33],Menu_Ban_pos[33],Menu_Unban_pos[33],Float:Menu_Unban_Time[33],Votes_Players[33][33],Float:LastVoted[33];
new Regex:steamid_pattern,Regex:ip_pattern,Regex:time_pattern,ret,error[2];
new Array:banlist_array;

public plugin_init() 
{ 
	register_plugin("Ultimate Bans","1.9","~D4rkSiD3Rs~");

	register_clcmd(	"amx_banmenu", 	"CmdBANMENU", 	ADMIN_BAN,	"(Shows Ban Menu)");
	register_clcmd(	"amx_unbanmenu","CmdUNBANMENU", ADMIN_BAN,	"(Shows Unban Menu)");

	register_concmd("amx_banggp",	"CmdBAN",	ADMIN_BAN,	"<nick, #userid, authid, ip> <minutes> [reason] <bantype>");
	register_concmd("amx_addbanggp","CmdADDBAN",	ADMIN_BAN,	"<nick, authid, ip> <minutes> [reason] <bantype>");
	register_concmd("amx_unban",	"CmdUNBAN",	ADMIN_BAN,	"<nick, authid, ip> <bantype>");
	register_concmd("amx_queryban",	"CmdQUERY",	ADMIN_BAN,	"<nick, authid, ip> <bantype>");
	register_concmd("amx_querynext","CmdQUERYNEXT",	ADMIN_BAN,	"(Shows the Next Page of QueryBan Result)");
	register_concmd("amx_queryback","CmdQUERYBACK",	ADMIN_BAN,	"(Shows the Previous Page of QueryBan Result)");
	register_concmd("amx_banlist",  "CmdBANLIST",	ADMIN_BAN,	"(Shows the List of All Banned Players)");
	
	register_srvcmd("amx_banggp",	"CmdBAN",	-1,		"<nick, #userid, authid, ip> <minutes> [reason] <bantype>");
	register_srvcmd("amx_addbanggp","CmdADDBAN",	-1,		"<nick, authid, ip> <minutes> [reason] <bantype>");
	register_srvcmd("amx_unban",	"CmdUNBAN",	-1,		"<nick, authid, ip> <bantype>");
	register_srvcmd("amx_queryban",	"CmdQUERY",	-1,		"<nick, authid, ip> <bantype>");
	register_srvcmd("amx_querynext","CmdQUERYNEXT",	-1,		"(Shows the Next Page of QueryBan Result)");
	register_srvcmd("amx_queryback","CmdQUERYBACK",	-1,		"(Shows the Previous Page of QueryBan Result)");
	register_srvcmd("amx_banlist",  "CmdBANLIST",	-1,		"(Shows the List of All Banned Players)");
	register_srvcmd("amx_reloadbans","CmdRELOAD",	-1,		"(Reloads the Bans without Restarting the Server)");
	register_srvcmd("amx_resetbans","CmdRESET",	-1,		"(Resets Bans - Clears Banlist )");
	
	steamid_pattern = regex_compile(STEAMID_PATTERN,ret,error,charsmax(error));
	ip_pattern = regex_compile(IP_PATTERN,ret,error,charsmax(error));
	time_pattern = regex_compile(TIME_PATTERN,ret,error,charsmax(error));
	cvar_CheckInterval = register_cvar("ub_checkinterval","60.0");
	cvar_Contact = register_cvar("sv_ub_contact","www.facebook.com/GeekGamersPage/");
	cvar_Flags = register_cvar("ub_flags","a");
	cvar_vote_enable = register_cvar("ub_vote_enable","1");
	cvar_vote_ratio = register_cvar("ub_vote_ratio","0.40");
	cvar_vote_delay = register_cvar("ub_vote_delay","5.0");
	cvar_vote_time = register_cvar("ub_vote_time","60.0");
	cvar_vote_min = register_cvar("ub_vote_min","5");
	msgid = get_user_msgid("SayText");
	banlist_array = ArrayCreate(BanInfo);
	
	register_menucmd(register_menuid("Ban Menu"),1023,"Menu_Ban_Keys");
	register_menucmd(register_menuid("Unban Menu"),1023,"Menu_Unban_Keys");
	register_menucmd(register_menuid("Voteban Menu"),1023,"Menu_Vote_Keys")
	register_clcmd("SetDuration","Menu_SetDuration",ADMIN_BAN,"<time> in Minute(s)");
	register_clcmd("SetReason","Menu_SetReason",ADMIN_BAN,"<reason>");
	register_clcmd("say /voteban","CmdVOTEMENU");
	register_clcmd("say_team /voteban","CmdVOTEMENU");
	
	get_datadir(ub_banlistfile,charsmax(ub_banlistfile));
	add(ub_banlistfile,charsmax(ub_banlistfile),"/UB_Banlist.txt");
	if (!file_exists(ub_banlistfile))
	{
		server_print("[Geek~Gamers] Banlist File Missing. Creating File - %s",ub_banlistfile);
		new file = fopen(ub_banlistfile,"wt");fclose(file);
		CheckTimeUP();
	}
	else
		CmdLOAD();
}

public client_connect(id)
{
	for (new i=0;i<64;i++)
		LastQuery[id][i] = 0;
	for (new i=0;i<8;i++)
		LastQueryType[id][i] = 0;
	QueryPointer[id] = 1;
	Menu_Ban_Reset(id);
	Menu_Unban_pos[id] = 0;
	LastVoted[id] = 0.0;
}

public client_disconnected(id)
{
	auth_delay[id] = false;
	new ids;
	get_players(player,total);
	for(new i=0;i<total;i++)
	{
		ids = player[i];
		if (Votes_Players[id][ids])
			Votes_Players[id][ids] = 0;
	}
}

public client_authorized(id)
{
	static Float:handle_delay;
	if (MODE_LOADBAN)
		auth_delay[id] = true;
	else
	{
		if (get_gametime()<LastAuth+1.0)
		{
			handle_delay += 1.0;
			set_task(handle_delay,"OnConnect",id);
		}
		else
		{
			OnConnect(id);
			if (handle_delay>=2.0)
				handle_delay -= 2.0;
			else
				handle_delay = 0.0;
		}
		LastAuth = get_gametime();
	}
}

public OnConnect(id)
{
	static AuthID[32],IP[16],Name[64],Timeleft[64],DATA[BanInfo],func_buffer[256],Pos;
	get_user_authid(id,AuthID,charsmax(AuthID));
	get_user_ip(id,IP,charsmax(IP),1);
	get_user_name(id,Name,charsmax(Name));
	if (equali(Name,"<null>",6))
		server_cmd("kick #%d ^"Invalid NAME^"",get_user_userid(id));
	Pos = CheckBan(AuthID,"STEAMID");
	if (Pos==-2)
	{
		Pos = CheckBan(IP,"IP");
		if (Pos==-2)
		{
			Pos = CheckBan(Name,"NAME");
			if (Pos==-2)
				return PLUGIN_CONTINUE
		}
	}
	if (Pos==-1)
	{
		server_cmd("kick #%d ^"You are BANNED from this Server^"",get_user_userid(id));
		return PLUGIN_HANDLED
	}
	else
	{
		ArrayGetArray(banlist_array,Pos,DATA);
		static Hostname[64];
		get_user_name(0,Hostname,charsmax(Hostname));
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		client_cmd(id,"echo [Geek~Gamers] --==|| BAN INFO ||==--");
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		client_cmd(id,"echo [Geek~Gamers] Server - %s",Hostname);
		if (equali(DATA[unbantime],"<null>",6))
		{
			PrintBanInfo(DATA,id);
			set_task(0.5,"JoinKick",id,"<null>",6);
			return PLUGIN_HANDLED
		}
		if (get_ban_timeleft(DATA[unbantime],Timeleft,charsmax(Timeleft)))
		{
			PrintBanInfo(DATA,id,Timeleft);
			set_task(0.5,"JoinKick",id,Timeleft,charsmax(Timeleft));
		}
		else
		{
			if (!equali(DATA[target_name],"<null>",6))	
				formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_name]);	
			else
			{
				if ((equali(DATA[bantype],"STEAMID",7))&&(!equali(DATA[target_authid],"<null>",6)))
					formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_authid]);
				else
					formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_ip]);
			}
			ChatPrint(func_buffer);
			log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","<UNBAN> BANTIME Up/Elapsed for <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^" | BanType: ^"%s^">",DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantype]);
			ArrayDeleteItem(banlist_array,Pos);
			TotalBans--;
			new file = fopen(ub_banlistfile,"wt");
			for(new i=0;i<TotalBans;i++)
			{
				ArrayGetArray(banlist_array,i,DATA);
				fprintf(file,"^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"^n",DATA[bantype],DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantime],DATA[unbantime],DATA[banner_authid],DATA[banner_ip],DATA[banner_name],DATA[reason]);
			}
			fclose(file);
		}
		return PLUGIN_HANDLED
	}
	//return PLUGIN_HANDLED
}

public client_infochanged(id)
{
	static oldName[64],newName[64];
	get_user_name(id,oldName,charsmax(oldName));
	get_user_info(id,"NAME",newName,charsmax(newName));
	if (!equal(oldName,newName))
	{
		if ((equali(newName,"<null>",6))||(CheckBan(newName,"NAME")!=-2))
		{
			set_user_info(id,"NAME",oldName);
			client_print(id,print_chat,"[Geek~Gamers] Invalid NAME");
		}
	}
}

public CmdBAN(id,level,cid) 
{
	if (!cmd_access(id,level,cid,2,false))
		return PLUGIN_HANDLED
	// ------==|| Input Data Handling ||==------
	new ARG_Target[64],ARG_Duration[32],ARG_BanType[8],ARG_Reason[128]
	static ARG_Count,ARG_STR[256],len;
	copy(ARG_Reason,charsmax(ARG_Reason),"<null>");
	ARG_Count = 0;
	read_args(ARG_STR,charsmax(ARG_STR));
	trim(ARG_STR);
	parse(ARG_STR,ARG_Target,charsmax(ARG_Target),ARG_Duration,charsmax(ARG_Duration),ARG_Reason,charsmax(ARG_Reason),ARG_BanType,charsmax(ARG_BanType));
	if (strlen(ARG_Target))
	{
		ARG_Count=1;
		trim(ARG_Target);
		if (equali(ARG_Target,"<null>",6))
		{
			bad_input(id);
			MODE_ADDBAN = false;
			return PLUGIN_HANDLED
		}
		if (strlen(ARG_Duration))
		{
			ARG_Count=2;
			trim(ARG_Duration);
			if (strlen(ARG_Reason))
			{
				ARG_Count=3;
				trim(ARG_Reason);
				if (strlen(ARG_BanType))
				{
					ARG_Count=4;
					trim(ARG_BanType);
				}
			}
			else
				copy(ARG_Reason,charsmax(ARG_Reason),"<null>")
		}		
	}
	if (ARG_Count<2)
	{
		if (id)
			client_cmd(id,"echo [Geek~Gamers] Insufficient Data/Arguments");
		else
			server_print("[Geek~Gamers] Insufficient Data/Arguments");
		MODE_ADDBAN = false
		return PLUGIN_HANDLED
	}
	// ------==|| Input Type Handling ||==------
	static tmpid,NUM_Target_Type,NUM_BanType;
	if ((ARG_STR[0]=='#')&&(!MODE_ADDBAN))
	{
		tmpid = str_to_num(ARG_Target[1]);
		NUM_Target_Type = 1;
	}
	else if (IsValidAUTHID(ARG_Target))
		NUM_Target_Type = 2;
	else if (IsValidIP(ARG_Target))
		NUM_Target_Type = 3;
	else 
		NUM_Target_Type = 4;
	if (ARG_Count==4)
	{
		if (equali(ARG_BanType,"AUTO",4))
			NUM_BanType = 1;
		else if (equali(ARG_BanType,"STEAMID",7))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
			NUM_BanType = 2;
		}
		else if (equali(ARG_BanType,"IP",2))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"IP");
			NUM_BanType = 3;
		}
		else if (equali(ARG_BanType,"NAME",4))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"NAME");
			NUM_BanType = 4;
		}
		else
		{
			bad_input(id);
			MODE_ADDBAN = false
			return PLUGIN_HANDLED
		}
	}
	else
		NUM_BanType = 1;
	// ------==|| Target ||==------
	static Target[33],ARG_TempTarget[64],Found,bool:MODE_RANGEBAN;
	MODE_RANGEBAN = false;
	Found = 0;
	get_players(player,total);
	if (!MODE_ADDBAN)
	{
		switch (NUM_Target_Type)
		{
			case 1:
			{
				for (new i=0;i<total;i++)
				{
					ids = player[i];
					if (get_user_userid(ids)!=tmpid)
						continue;
					Found = 1;
					get_user_authid(ids,ARG_TempTarget,charsmax(ARG_TempTarget));
					switch (NUM_BanType)
					{
						case 1:
						{
							if (IsValidAUTHID(ARG_TempTarget))
							{
								copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
								NUM_BanType = 2;
							}
							else
							{
								get_user_ip(ids,ARG_TempTarget,charsmax(ARG_TempTarget),1);
								copy(ARG_BanType,charsmax(ARG_BanType),"IP");
								NUM_BanType = 3;
							}
						}
						case 2:
						{
							if (IsValidAUTHID(ARG_TempTarget))
								continue;
							if (id)
								client_cmd(id,"echo [Geek~Gamers] AuthID Not Valid for Banning!!");
							else
								server_print("[Geek~Gamers] AuthID Not Valid for Banning!!");
							return PLUGIN_HANDLED
						}
					}
					Target[0] = ids;
					break;
				}
			}
			case 2:
			{
				for (new i=0;i<total;i++)
				{
					ids = player[i]
					get_user_authid(ids,ARG_TempTarget,charsmax(ARG_TempTarget))
					if (equali(ARG_TempTarget,ARG_Target))
						Target[Found++] = ids;
				}
				if ((Found)&&(NUM_BanType==1))
				{
					copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
					NUM_BanType = 2;
				}
			}
			case 3:
			{
				for (new i=0;i<total;i++)
				{
					ids = player[i]
					get_user_ip(ids,ARG_TempTarget,charsmax(ARG_TempTarget),1)
					new temp = CheckIP(ARG_Target,ARG_TempTarget);
					if (temp)
					{
						if (temp==2)
							MODE_RANGEBAN = true;
						Target[Found++] = ids;
					}
				}
				if ((Found)&&(NUM_BanType==1))
				{
					copy(ARG_BanType,charsmax(ARG_BanType),"IP");
					NUM_BanType = 3;
				}
			}
		}
		if (!Found)
		{
			for (new i=0;i<total;i++)
			{
				ids = player[i]		
				get_user_name(ids,ARG_TempTarget,charsmax(ARG_TempTarget));
				if (equali(ARG_Target,ARG_TempTarget,strlen(ARG_Target)))
					Target[Found++] = ids;		
			}
			if (Found)
			{
				if (Found>1)
				{
					if (NUM_BanType!=4)
					{
						if (id)
							client_cmd(id,"echo [Geek~Gamers] %i Players Found with Similar Names . . . Unable to Ban!!",Found);
						else
							server_print("[Geek~Gamers] %i Players Found with Similar Names . . . Unable to Ban!!",Found);
						return PLUGIN_HANDLED
					}				
				}
				else
				{
					get_user_authid(Target[0],ARG_TempTarget,charsmax(ARG_TempTarget))
					switch (NUM_BanType)
					{
					 	case 1:
					 	{
							if (IsValidAUTHID(ARG_TempTarget))
							{
								copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
								NUM_BanType = 2;
							}
							else
							{
								get_user_ip(ids,ARG_TempTarget,charsmax(ARG_TempTarget),1);
								copy(ARG_BanType,charsmax(ARG_BanType),"IP");
								NUM_BanType = 3;
							}
						}
						case 2:
						{
							if (!IsValidAUTHID(ARG_TempTarget))
							{
								if (id)
									client_cmd(id,"echo [Geek~Gamers] AuthID Not Valid for Banning!!");
								else
									server_print("[Geek~Gamers] AuthID Not Valid for Banning!!");
								return PLUGIN_HANDLED
							}
						}
					}
				}
			}	
			else
			{
				if (id)
					client_cmd(id,"echo [Geek~Gamers] Target Not Found!!");
				else
					server_print("[Geek~Gamers] Target Not Found!!");
				return PLUGIN_HANDLED
			}
		}
	}
	else
	{
		if (((NUM_Target_Type!=2)&&(NUM_BanType==2))||((NUM_Target_Type!=3)&&(NUM_BanType==3)))
		{
			if (id)
				client_cmd(id,"echo [Geek~Gamers] BanType doesn't match with TargetType");
			else
				server_print("[Geek~Gamers] BanType doesn't match with TargetType");
			MODE_ADDBAN = false
			return PLUGIN_HANDLED
		}
		if (NUM_BanType==1)
		{
			switch (NUM_Target_Type)
			{
				case 2: {copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");NUM_BanType=2;}
				case 3: {copy(ARG_BanType,charsmax(ARG_BanType),"IP");NUM_BanType=3;}
				case 4: {copy(ARG_BanType,charsmax(ARG_BanType),"NAME");NUM_BanType=4;}
			}
		}
		if (CheckBan(ARG_Target,ARG_BanType)!=-2)
		{
			if (id)
				client_cmd(id,"echo [Geek~Gamers] Player Already Banned");
			else
				server_print("[Geek~Gamers] Player Already Banned");
			MODE_ADDBAN = false
			return PLUGIN_HANDLED
		}
		for (new i=0;i<total;i++)
		{
			ids = player[i];
			switch (NUM_BanType)
			{
				case 2:
				{
					get_user_authid(ids,ARG_TempTarget,charsmax(ARG_TempTarget));
					if (equali(ARG_TempTarget,ARG_Target))
						Target[Found++] = ids;
				}
				case 3:
				{
					get_user_ip(ids,ARG_TempTarget,charsmax(ARG_TempTarget),1);
					new temp = CheckIP(ARG_Target,ARG_TempTarget);
					if (temp)
					{
						if (temp==2)
							MODE_RANGEBAN = true;
						Target[Found++] = ids;
					}
				}
				case 4:
				{
					get_user_name(ids,ARG_TempTarget,charsmax(ARG_TempTarget));
					if (equali(ARG_Target,ARG_TempTarget,strlen(ARG_Target)))
						Target[Found++] = ids;
				}
			}
		}
		if (Found)
		{
			if (id)
				client_cmd(id,"echo [Geek~Gamers] %s been FOUND Connected to the Server.",(Found==1)?"Target has":"Targets have");
			else
				server_print("[Geek~Gamers] %s been FOUND Connected to the Server.",(Found==1)?"Target has":"Targets have");
			MODE_ADDBAN = false;
		}
		else
			Found = 1;
	}
	if (!MODE_ADDBAN)
	{
		get_pcvar_string (cvar_Flags,Flags,charsmax(Flags));
		strtolower(Flags);
		for (new i=0;i<Found;i++)
			for (new j=0;j<strlen(Flags);j++)
				if ((isalpha(Flags[j]))&&(get_user_flags(Target[i]) & power(2,(Flags[j]-97))))
				{
					if (id)
						client_cmd(id,"echo [Geek~Gamers] This/These Player(s) can't be Banned because of Access Flags assgined to them by Server");
					else
						server_print("[Geek~Gamers] This/These Player(s) can't be Banned because of Access Flags assgined to them by Server");
					return PLUGIN_HANDLED
				}
	}
	// ------==|| Time ||==------
	static dot,count_digits,years,months,days,hours,minutes,seconds,Float:NUM_Duration,STR_BanTime[32],STR_Duration[128],STR_UnbanTime[32],_years[7],_months[5],_days[5],_hours[5],_minutes[5],_seconds[5],bool:is_permanent;
	years=0,months=0,days=0,hours=0,minutes=0,seconds=0,dot=0,count_digits=1,is_permanent=false;
	if (!isdigit(ARG_Duration[0]))
	{
		bad_input(id);
		MODE_ADDBAN = false
		return PLUGIN_HANDLED
	}
	for (new i=1;i<strlen(ARG_Duration);i++)
	{
		if (ARG_Duration[i]=='.')
		{
			if (++dot>1)
			{
				bad_input(id);
				MODE_ADDBAN = false
				return PLUGIN_HANDLED
			}
		}
		else if (!isdigit(ARG_Duration[i]))
		{
			bad_input(id);
			MODE_ADDBAN = false
			return PLUGIN_HANDLED
		}
		else if (!dot)
			count_digits++;
	}
	if (count_digits>8)
		NUM_Duration = 0.0;
	else
		NUM_Duration = str_to_float(ARG_Duration);
	minutes = floatround(NUM_Duration,floatround_floor);
	seconds = floatround(floatfract(NUM_Duration)*60,floatround_floor);
	while(minutes>=60)
	{
		minutes -= 60;
		hours++;
	}
	while(hours>=24)
	{
		hours -= 24;
		days++;
	}
	if (NUM_Duration)
	{
		is_permanent = false;
		len = 0;
		if (days)
			len += formatex(STR_Duration[len],charsmax(STR_Duration)-len,"%d Day(s) ",days);
		if (hours)
			len += formatex(STR_Duration[len],charsmax(STR_Duration)-len,"%i Hour(s) ",hours);
		if (minutes)
			len += formatex(STR_Duration[len],charsmax(STR_Duration)-len,"%i Minute(s) ",minutes);
		if (seconds)
			len += formatex(STR_Duration[len],charsmax(STR_Duration)-len,"%i Second(s)",seconds);
		format_time(_hours,charsmax(_hours),"%H");
		format_time(_minutes,charsmax(_minutes),"%M");
		format_time(_seconds,charsmax(_seconds),"%S");
		format_time(_days,charsmax(_days),"%d");
		format_time(_months,charsmax(_months),"%m");
		format_time(_years,charsmax(_years),"%Y");
		formatex(STR_BanTime,charsmax(STR_BanTime),"%s:%s:%s %s/%s/%s",_hours,_minutes,_seconds,_days,_months,_years);
		hours = str_to_num(_hours);
		months= str_to_num(_months);
		days = str_to_num(_days);
		years = str_to_num(_years);
		minutes = floatround(NUM_Duration,floatround_floor)+str_to_num(_minutes);
		while(minutes>=60)
		{
			minutes -= 60;
			hours++;
		}
		while(hours>=24)
		{
			hours -= 24;
			days++;
		}
		while(days>get_monthdays(months,years))
		{
			days -= get_monthdays(months,years);
			if (++months>12)
			{
				months -= 12;
				years++;
			}
		}
		seconds += str_to_num(_seconds);
		if (seconds>59)
		{
			seconds -= 60;
			if (minutes<59)
				minutes++;
			else
			{
				minutes=0;
				if (hours<23)
					hours++;
				else
				{
					hours=0;
					if (days<get_monthdays(months,years))
						days++;
					else
					{
						days=1;
						if (months<12)
							months++;
						else
						{
							months=1;
							years++;
						}
					}
				}
			}
		}	
		formatex(STR_UnbanTime,charsmax(STR_UnbanTime),"%02i:%02i:%02i %02i/%02i/%d", hours,minutes,seconds,days,months,years);
	}
	else
	{
		is_permanent = true;
		copy(STR_Duration,charsmax(STR_Duration)," from the Server");
		format_time(STR_BanTime,charsmax(STR_BanTime),"%H:%M %d/%m/%Y");
		copy(STR_UnbanTime,charsmax(STR_UnbanTime),"<null>");
	}
	// ------==|| Banner ||==------
	static Name2[64],AuthID2[32],IP2[16];
	if (id)
	{
		get_user_name(id,Name2,charsmax(Name2));
		get_user_ip(id,IP2,charsmax(IP2),1);
		get_user_authid(id,AuthID2,charsmax(AuthID2));
	}		
	// ------==|| Final Step ||==------
	static Contact[128],Name1[64],AuthID1[32],IP1[16],DATA[BanInfo],func_buffer[1024],Float:handle_delay;
	len = 0;
	len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ",ARG_BanType);
	if (MODE_ADDBAN)
	{
		switch (NUM_BanType)
		{
			case 2: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ^"<null>^" ^"<null>^" ",ARG_Target);
			case 3: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"%s^" ^"<null>^" ",ARG_Target);
			case 4: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"<null>^" ^"%s^" ",ARG_Target);
		}
	}
	else
	{
		get_user_authid(Target[0],AuthID1,charsmax(AuthID1));
		get_user_ip(Target[0],IP1,charsmax(IP1),1);
		get_user_name(Target[0],Name1,charsmax(Name1));
		if (Found==1)
		{
			if (MODE_RANGEBAN)
				len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"%s^" ^"<null>^" ",ARG_Target);
			else
				len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ^"%s^" ^"%s^" ",AuthID1,IP1,(NUM_BanType==4)?ARG_Target:Name1);
		}
		else
		{	
			switch (NUM_BanType)
			{
				case 2: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ^"<null>^" ^"<null>^" ",AuthID1);
				case 3: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"%s^" ^"<null>^" ",MODE_RANGEBAN?ARG_Target:IP1);
				case 4: len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"<null>^" ^"%s^" ",ARG_Target);
			}
		}
	}
	len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ^"%s^" ",STR_BanTime,STR_UnbanTime);
	if (id)
		len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^" ^"%s^" ^"%s^" ",AuthID2,IP2,Name2);
	else
		len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"<null>^" ^"<null>^" ^"RCON/Server^" ");
	len += formatex(func_buffer[len],charsmax(func_buffer)-len,"^"%s^"",ARG_Reason);
	new file = fopen(ub_banlistfile,"a+");
	fprintf(file,"%s^n",func_buffer);
	fclose(file);
	parse(func_buffer,DATA[bantype],charsmax(DATA[bantype]),DATA[target_authid],charsmax(DATA[target_authid]),DATA[target_ip],charsmax(DATA[target_ip]),DATA[target_name],charsmax(DATA[target_name]),DATA[bantime],charsmax(DATA[bantime]),DATA[unbantime],charsmax(DATA[unbantime]),DATA[banner_authid],charsmax(DATA[banner_authid]),DATA[banner_ip],charsmax(DATA[banner_ip]),DATA[banner_name],charsmax(DATA[banner_name]),DATA[reason],charsmax(DATA[reason]));
	ArrayPushArray(banlist_array,DATA);
	TotalBans++;
	LastBanTime = get_gametime();
	if (MODE_ADDBAN)
	{
		formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has been ADDED to BANLIST^x04 %s%s^x04 BY^x03 %s.^x01 [ Reason - ^"%s^" ]",ARG_Target,is_permanent?"Permanently":"for ",is_permanent?"":STR_Duration,id?Name2:"RCON/Server",ARG_Reason);
		ChatPrint(func_buffer);
		if (id)
			log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","<ADDBAN> < AuthID:^"%s^" , IP:^"%s^" , Name:^"%s^" > BANNED %s %s BY < AuthID:^"%s^" , IP:^"%s^" , Name:^"%s^" >. [ BanType - ^"%s^" ] [ Reason - ^"%s^" ]",DATA[target_authid],DATA[target_ip],DATA[target_name],is_permanent?"Permanently":"for",is_permanent?"from the Server":STR_Duration,AuthID2,IP2,Name2,ARG_BanType,ARG_Reason);
		else
			log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","<ADDBAN> < AuthID:^"%s^" , IP:^"%s^" , Name:^"%s^" > BANNED %s %s BY < RCON/Server >. [ BanType - ^"%s^" ] [ Reason - ^"%s^" ]",DATA[target_authid],DATA[target_ip],DATA[target_name],is_permanent?"Permanently":"for",is_permanent?"from the Server":STR_Duration,ARG_BanType,ARG_Reason);
		MODE_ADDBAN = false;
	}
	else
	{
		handle_delay = 0.0;
		static Hostname[64];
		get_user_name(0,Hostname,charsmax(Hostname));
		for ( new i=0;i<Found;i++)
		{		
			client_cmd(Target[i],"echo [Geek~Gamers] -------------------------------");
			client_cmd(Target[i],"echo [Geek~Gamers] --==|| BAN INFO ||==--");
			client_cmd(Target[i],"echo [Geek~Gamers] -------------------------------");
			client_cmd(Target[i],"echo [Geek~Gamers] Server - %s",Hostname);
			if (is_permanent)
				PrintBanInfo(DATA,Target[i]);
			else
				PrintBanInfo(DATA,Target[i],STR_Duration);
			get_pcvar_string(cvar_Contact,Contact,charsmax(Contact));
			if (!equali(Contact,"N/A"))
			{
				client_cmd(Target[i],"echo [Geek~Gamers] For Unban Request : ^"%s^"",Contact);
				client_cmd(Target[i],"echo [Geek~Gamers] -------------------------------");	
			}
			get_user_authid(Target[i],AuthID1,charsmax(AuthID1));
			get_user_ip(Target[i],IP1,charsmax(IP1),1);
			get_user_name(Target[i],Name1,charsmax(Name1));
			formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has been BANNED^x03 %s%s^x04 BY^x03 %s.^x01 [ Reason - ^"%s^" ]",Name1,is_permanent?"Permanently":"for ",STR_Duration,id?Name2:"RCON/Server",ARG_Reason);
			set_task(handle_delay,"ChatPrint",80085,func_buffer,charsmax(func_buffer));
			if (id)
				formatex(func_buffer,charsmax(func_buffer),"<BAN> <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^"> BANNED %s %s BY <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^">. [ BanType - ^"%s^" ] [ Reason - ^"%s^" ]",AuthID1,MODE_RANGEBAN?ARG_Target:IP1,Name1,is_permanent?"Permanently":"for",is_permanent?"from the Server":STR_Duration,AuthID2,IP2,Name2,ARG_BanType,ARG_Reason);
			else
				formatex(func_buffer,charsmax(func_buffer),"<BAN> <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^"> BANNED %s %s BY <RCON/Server>. [ BanType - ^"%s^" ] [ Reason - ^"%s^" ]",AuthID1,MODE_RANGEBAN?ARG_Target:IP1,Name1,is_permanent?"Permanently":"for",is_permanent?"from the Server":STR_Duration,ARG_BanType,ARG_Reason);
			set_task(handle_delay,"DelayedLog",80085,func_buffer,charsmax(func_buffer));
			handle_delay += 0.5;
			server_cmd("kick #%d ^"You have been BANNED %s%s. Check your Console for More Information.^"",get_user_userid(Target[i]),is_permanent?"Permanently":"for ",is_permanent?"from the Server":STR_Duration);
		}
	}
	if (handle_ban_menu_call[id])
	{
		Menu_Ban_Display(id,Menu_Ban_pos[id]);
		handle_ban_menu_call[id] = false;
	}
	return PLUGIN_HANDLED
}

public CmdADDBAN(id,level,cid) 
{
	if (!cmd_access(id,level,cid,2,false))
		return PLUGIN_HANDLED
	MODE_ADDBAN = true;
	static command[256];
	read_args(command,charsmax(command));
	if (id)
		client_cmd(id,"amx_banggp %s",command);
	else
		server_cmd("amx_banggp %s",command);
	return PLUGIN_HANDLED
}

public CmdUNBAN(id,level,cid)
{
	if (!cmd_access(id,level,cid,2,false))
		return PLUGIN_HANDLED		
	// ------==|| Input Data Handling ||==------
	new ARG_Target[64],ARG_BanType[8];
	static ARG_Count,ARG_STR[128];
	ARG_Count = 0;
	read_args(ARG_STR,charsmax(ARG_STR));
	parse(ARG_STR,ARG_Target,charsmax(ARG_Target),ARG_BanType,charsmax(ARG_BanType));
	if (strlen(ARG_Target))
	{
		ARG_Count=1;
		trim(ARG_Target);
		if (equali(ARG_Target,"<null>",6))
		{
			bad_input(id);
			return PLUGIN_HANDLED
		}
		if (strlen(ARG_BanType))
		{
			ARG_Count=2;
			trim(ARG_BanType);
		}		
	}	
	// ------==|| Input Type Handling ||==------
	static NUM_BanType;
	if (ARG_Count==2)
	{
		if (equali(ARG_BanType,"AUTO",4))
			NUM_BanType = 1;
		else if (equali(ARG_BanType,"STEAMID",7))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
			NUM_BanType = 2;
		}
		else if (equali(ARG_BanType,"IP",2))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"IP");
			NUM_BanType = 3;
		}
		else if (equali(ARG_BanType,"NAME",4))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"NAME");
			NUM_BanType = 4;
		}
		else
		{
			bad_input(id);
			return PLUGIN_HANDLED
		}
	}
	else
		NUM_BanType = 1;	
	if (NUM_BanType==1)
	{
		if (IsValidAUTHID(ARG_Target))
		{
			copy (ARG_BanType,charsmax(ARG_BanType),"STEAMID");
			NUM_BanType = 2;
		}
		else if (IsValidIP(ARG_Target))
		{
			copy (ARG_BanType,charsmax(ARG_BanType),"IP");
			NUM_BanType = 3;
		}
		else
		{
			copy (ARG_BanType,charsmax(ARG_BanType),"NAME");
			NUM_BanType = 4;
		}
	}
	// ------==|| Final Step ||==------
	static pos,Unbanner_Name[64],DATA[BanInfo],func_buffer[256];
	MODE_UNBAN = true;
	pos = CheckBan(ARG_Target,ARG_BanType);
	if (pos==-2)
	{
		if (id)
			client_cmd(id,"echo [Geek~Gamers] Player Not Found");
		else
			server_print("[Geek~Gamers] Player Not Found");
		MODE_UNBAN = false;
		return PLUGIN_HANDLED
	}
	if (id)
		get_user_name(id,Unbanner_Name,charsmax(Unbanner_Name));
	ArrayGetArray(banlist_array,pos,DATA);		
	if (!equali(DATA[target_name],"<null>"))
		formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has been^x03 UNBANNED^x04 BY^x03 ^"%s^"",DATA[target_name],id?Unbanner_Name:"RCON/Server");
	else
	{
		if (NUM_BanType==2)
			formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has been^x03 UNBANNED^x04 BY^x03 ^"%s^"",DATA[target_authid],id?Unbanner_Name:"RCON/Server");
		else
			formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has been^x03 UNBANNED^x04 BY^x03 ^"%s^"",DATA[target_ip],id?Unbanner_Name:"RCON/Server");		
	}
	ChatPrint(func_buffer);
	if (id)
		log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","<UNBAN> <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^" | BanType: ^"%s^"> UNBANNED BY <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^">",DATA[target_authid],DATA[target_ip],DATA[target_name],ARG_BanType,DATA[banner_authid],DATA[banner_ip],DATA[banner_name]);
	else
		log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","<UNBAN> <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^" | BanType: ^"%s^"> UNBANNED BY <RCON/Server>",DATA[target_authid],DATA[target_ip],DATA[target_name],ARG_BanType);
	ArrayDeleteItem(banlist_array,pos);
	TotalBans--;
	new file = fopen(ub_banlistfile,"wt");
	for(new i=0;i<TotalBans;i++)
	{
		ArrayGetArray(banlist_array,i,DATA);
		fprintf(file,"^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"^n",DATA[bantype],DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantime],DATA[unbantime],DATA[banner_authid],DATA[banner_ip],DATA[banner_name],DATA[reason]);
	}
	fclose(file);
	if (handle_unban_menu_call[id])
	{
		Menu_Unban_Display(id,Menu_Unban_pos[id]);
		handle_unban_menu_call[id] = false;
	}
	MODE_UNBAN = false;
	return PLUGIN_HANDLED
}

public CmdQUERYNEXT(id,level,cid)
{
	if (!cmd_access(id,level,cid,1,false))
		return PLUGIN_HANDLED
	if (QueryCount[id]<=QueryPointer[id]+4)
	{
		if (id)
			client_cmd(id,"echo [Geek~Gamers] Next Page of Query doesn't Exist");
		else
			server_print("[Geek~Gamers] Next Page of Query doesn't Exist");
		return PLUGIN_HANDLED
	}
	QueryPointer[id] += 5
	MODE_QUERY_CONTINUE = true;
	if (id)
		client_cmd(id,"ub_queryban %s %s",LastQuery[id],LastQueryType[id]);
	else
		server_cmd("ub_queryban %s %s",LastQuery[0],LastQueryType[0]);
	return PLUGIN_HANDLED
}

public CmdQUERYBACK(id,level,cid)
{
	if (!cmd_access(id,level,cid,1,false))
		return PLUGIN_HANDLED	
	if (QueryPointer[id]-5<=0)
	{
		if (id)
			client_cmd(id,"echo [Geek~Gamers] Previous Page of Query doesn't Exist");
		else
			server_print("[Geek~Gamers] Previous Page of Query doesn't Exist");
		return PLUGIN_HANDLED
	}
	QueryPointer[id] -= 5
	MODE_QUERY_CONTINUE = true;
	if (id)
		client_cmd(id,"ub_queryban %s %s",LastQuery[id],LastQueryType[id]);
	else
		server_cmd("ub_queryban %s %s",LastQuery[0],LastQueryType[0]);
	return PLUGIN_HANDLED
}		

public CmdQUERY(id,level,cid)
{     
	if (!cmd_access(id,level,cid,2,false))
		return PLUGIN_HANDLED		
	// ------==|| Input Data Handling ||==------
	new ARG_Target[64],ARG_BanType[8];
	static ARG_Count,ARG_STR[128];
	ARG_Count = 0;
	read_args(ARG_STR,charsmax(ARG_STR));
	trim(ARG_STR);
	parse(ARG_STR,ARG_Target,charsmax(ARG_Target),ARG_BanType,charsmax(ARG_BanType));
	if (strlen(ARG_Target))
	{
		ARG_Count=1;
		trim(ARG_Target);
		if (equali(ARG_Target,"<null>",6))
		{
			bad_input(id);
			MODE_QUERY_CONTINUE = false;
			return PLUGIN_HANDLED
		}
		if (strlen(ARG_BanType))
		{
			ARG_Count=2;
			trim(ARG_BanType);
		}		
	}	
	// ------==|| Input Type Handling ||==------
	static NUM_BanType;
	if (ARG_Count==2)
	{
		if (equali(ARG_BanType,"AUTO",4))
			NUM_BanType = 1;
		if (equali(ARG_BanType,"STEAMID",7))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"STEAMID");
			NUM_BanType = 2;
		}
		else if (equali(ARG_BanType,"IP",2))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"IP");
			NUM_BanType = 3;
		}
		else if (equali(ARG_BanType,"NAME",4))
		{
			copy(ARG_BanType,charsmax(ARG_BanType),"NAME");
			NUM_BanType = 4;
		}
		else
		{
			bad_input(id);
			MODE_QUERY_CONTINUE = false;
			return PLUGIN_HANDLED
		}
	}
	else
		NUM_BanType = 1;
	// ------==|| Final Step ||==------
	static DATA[BanInfo],bool:ShowData,bool:Found;
	Found = false;
	if (MODE_QUERY_CONTINUE)
		MODE_QUERY_CONTINUE = false;
	else
		QueryPointer[id] = 1;
	QueryCount[id] = 0;
	if (id)
	{
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		client_cmd(id,"echo [Geek~Gamers] --==|| QUERY RESULT ||==--");
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
	}
	else
	{
		server_print("[Geek~Gamers] -------------------------------");
		server_print("[Geek~Gamers] --==|| QUERY RESULT ||==--");
		server_print("[Geek~Gamers] -------------------------------");
	}
	for (new i=0;i<TotalBans;i++)
	{
		ShowData = false;
		ArrayGetArray(banlist_array,i,DATA);
		switch (NUM_BanType)
		{
			case 1: if ((containi(DATA[target_authid],ARG_Target)!=-1)||(containi(DATA[target_ip],ARG_Target)!=-1)||(containi(DATA[target_name],ARG_Target)!=-1))	ShowData = true;
			case 2: if (containi(DATA[target_authid],ARG_Target)!=-1) ShowData = true;
			case 3: if (containi(DATA[target_ip],ARG_Target)!=-1) ShowData = true;
			case 4: if (containi(DATA[target_name],ARG_Target)!=-1) ShowData = true;
		}
		if (ShowData)
		{
			QueryCount[id]++;
			if (QueryPointer[id]+4>=QueryCount[id]>=QueryPointer[id])
			{
				Found = true;
				PrintBanInfo(DATA,id);
			}
		}
	}
	if (!Found)
	{
		if (id)
		{
			client_cmd(id,"echo [Geek~Gamers] Not Found / Page doesn't Exist");
			client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		}
		else
		{
			server_print("[Geek~Gamers] Not Found / Page doesn't Exist");
			server_print("[Geek~Gamers] -------------------------------");
		}
	}
	else
	{
		copy(LastQuery[id],63,ARG_Target);
		if (ARG_Count==2)
			copy(LastQueryType[id],7,ARG_BanType);
		if (id)
		{
			if (QueryCount[id]>=QueryPointer[id]+5)
				client_cmd(id,"echo [Geek~Gamers] Type ^"ub_querynext^" to see the Next Page");
			if (QueryPointer[id]-5>=0)
				client_cmd(id,"echo [Geek~Gamers] Type ^"ub_queryback^" to see the Previous Page");
			if (QueryCount[id]>=6)
				client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		}
		else
		{
			if (QueryCount[id]>=QueryPointer[id]+5)
				server_print("[Geek~Gamers] Type ^"ub_querynext^" to See Next Page");
			if (QueryPointer[id]-5>=0)
				server_print("[Geek~Gamers] Type ^"ub_queryback^" to See Previous Page");
			if (QueryCount[id]>=6)
				server_print("[Geek~Gamers] -------------------------------");
		}
	}
	return PLUGIN_HANDLED
}

public CmdBANLIST(id,level,cid)
{
	if (!cmd_access(id,level,cid,1,false))
		return PLUGIN_HANDLED

	if (!TotalBans)
	{
		if (id)
			client_cmd(id,"echo [Geek~Gamers] Banlist is Empty");
		else
			server_print("[Geek~Gamers] Banlist is Empty");
		return PLUGIN_HANDLED
	}
	new ARG_STR[128],ARG_Start[8],Start,End;
	read_args(ARG_STR,charsmax(ARG_STR));
	parse(ARG_STR,ARG_Start,charsmax(ARG_Start));
	if (strlen(ARG_Start))
	{
		trim(ARG_Start);
		Start = str_to_num(ARG_Start);
		if (!Start)
		{
			bad_input(id);
			return PLUGIN_HANDLED
		}
		if (TotalBans>=5)
		{
			if (Start>TotalBans)
			{
				Start = TotalBans-4;
				End = TotalBans;
			}
			else
			{
				if (Start+4<=TotalBans)
					End = Start+4;
				else
					End = TotalBans;
			}
		}
		else
		{
			if (Start>TotalBans)
				Start = 1;
			End = TotalBans;
		}
	}		
	else
	{
		Start = 1;
		if (TotalBans>=5)
			End = 5;
		else
			End = TotalBans;
	}
	if (id)
	{
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		client_cmd(id,"echo [Geek~Gamers] --==|| BAN LIST ||==--");
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		client_cmd(id,"echo [Geek~Gamers] Entries %d-%d of %d",Start,End,TotalBans);
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
	}
	else
	{
		server_print("[Geek~Gamers] -------------------------------");
		server_print("[Geek~Gamers] --==|| BAN LIST ||==--");
		server_print("[Geek~Gamers] -------------------------------");
		server_print("[Geek~Gamers] Entries %d-%d of %d",Start,End,TotalBans);
		server_print("[Geek~Gamers] -------------------------------");	
	}
	static DATA[BanInfo];
	for (new i=0;i<TotalBans;i++)
	{
		if (Start<=i+1<=End)
		{
			ArrayGetArray(banlist_array,i,DATA);
			PrintBanInfo(DATA,id);
		}
		else if (i+1>End)
			break;
	}
	if (id)
	{
		if (End<TotalBans)
		{
			if (End+5<=TotalBans)
				client_cmd(id,"echo [Geek~Gamers] Type ^"ub_banlistfile %d^" to see next 5 Entry/Entries",End+1);
			else
				client_cmd(id,"echo [Geek~Gamers] Type ^"ub_banlistfile %d^" to see next %d Entry/Entries",End+1,TotalBans-End);
			client_cmd(id,"echo [Geek~Gamers] -------------------------------");
		}
	}
	else
	{
		if (End<TotalBans)
		{
			if (End+5<=TotalBans)
				server_print("[Geek~Gamers] Type ^"ub_banlistfile %d^" to see next 5 Entry/Entries",End+1);
			else
				server_print("[Geek~Gamers] Type ^"ub_banlistfile %d^" to see next %d Entry/Entries",End+1,TotalBans-End);
			server_print("[Geek~Gamers] -------------------------------");
		}
	}
	return PLUGIN_HANDLED
}

public CmdRELOAD()
{
	server_print("[Geek~Gamers] All Bans Reloaded!");
	CmdLOAD();
}

CmdLOAD()
{
	ArrayClear(banlist_array);
	TotalBans = 0;
	new file,func_buffer[1024],DATA[BanInfo],bool:filter_file,NUM_BanType;
	filter_file = false;
	MODE_LOADBAN = true;
	file = fopen(ub_banlistfile, "rt");
	while(!feof(file))
	{
		fgets(file,func_buffer,charsmax(func_buffer));
		trim(func_buffer);
		if (!func_buffer[0])
			continue;
		parse(func_buffer,DATA[bantype],charsmax(DATA[bantype]),DATA[target_authid],charsmax(DATA[target_authid]),DATA[target_ip],charsmax(DATA[target_ip]),DATA[target_name],charsmax(DATA[target_name]),DATA[bantime],charsmax(DATA[bantime]),DATA[unbantime],charsmax(DATA[unbantime]),DATA[banner_authid],charsmax(DATA[banner_authid]),DATA[banner_ip],charsmax(DATA[banner_ip]),DATA[banner_name],charsmax(DATA[banner_name]),DATA[reason],charsmax(DATA[reason]));
		trim(DATA[bantype]);
		if (!(DATA[bantype][0]))
			copy(DATA[bantype],charsmax(DATA[bantype]),"<null>");
		trim(DATA[target_authid]);
		if (!(DATA[target_authid][0]))
			copy(DATA[target_authid],charsmax(DATA[target_authid]),"<null>");
		trim(DATA[target_ip]);
		if (!(DATA[target_ip][0]))
			copy(DATA[target_ip],charsmax(DATA[target_ip]),"<null>");
		trim(DATA[target_name]);
		if (!(DATA[target_name][0]))
			copy(DATA[target_name],charsmax(DATA[target_name]),"<null>");
		trim(DATA[bantime]);
		if (!(DATA[bantime][0]))
			copy(DATA[bantime],charsmax(DATA[bantime]),"<null>");
		trim(DATA[unbantime]);
		if (!(DATA[unbantime][0]))
			copy(DATA[unbantime],charsmax(DATA[unbantime]),"<null>");
		trim(DATA[banner_authid]);
		if (!(DATA[banner_authid][0]))
			copy(DATA[banner_authid],charsmax(DATA[banner_authid]),"<null>");
		trim(DATA[banner_ip]);
		if (!(DATA[banner_ip][0]))
			copy(DATA[banner_ip],charsmax(DATA[banner_ip]),"<null>");
		trim(DATA[banner_name]);
		if (!(DATA[banner_name][0]))
			copy(DATA[banner_name],charsmax(DATA[banner_name]),"<null>");
		trim(DATA[reason]);
		if (!(DATA[reason][0]))
			copy(DATA[reason],charsmax(DATA[reason]),"<null>");
		if (equali(DATA[bantype],"STEAMID",7))
			NUM_BanType = 2;
		else if (equali(DATA[bantype],"IP",2))
			NUM_BanType = 3;
		else if (equali(DATA[bantype],"NAME",4))
			NUM_BanType = 4;
		else
		{
			filter_file = true;
			continue;
		}
		switch (NUM_BanType)
		{
			case 2:
			{
				if (!IsValidAUTHID(DATA[target_authid]))
				{
					filter_file = true;
					continue;
				}
				if (CheckBan(DATA[target_authid],"STEAMID")!=-2)
				{
					filter_file = true;
					continue;
				}
			}
			case 3:
			{
				if (!IsValidIP(DATA[target_ip]))
				{
					filter_file = true;
					continue;
				}
				if (CheckBan(DATA[target_ip],"IP")!=-2)
				{
					filter_file = true;
					continue;
				}
			}
			case 4:
			{
				if (equali(DATA[target_name],"<null>",6))
				{
					filter_file = true;
					continue;
				}
				if (CheckBan(DATA[target_name],"NAME")!=-2)
				{
					filter_file = true;
					continue;
				}
			}
		}
		if ((!equali(DATA[unbantime],"<null>",6))&&(!IsValidTIME(DATA[unbantime])))
		{
			filter_file = true;
			continue;
		}
		ArrayPushArray(banlist_array,DATA);
		TotalBans++;
	}
	fclose(file);
	MODE_LOADBAN = false;
	for (new i=0;i<33;i++)
		if (auth_delay[i])
		{
			client_authorized(i, "");
			auth_delay[i] = false;
		}
	if (task_exists(1337))
		remove_task(1337);
	set_task(1.0,"CheckTimeUP",1337);
	if (!filter_file)
		return;
	file = fopen(ub_banlistfile, "wt");
	for(new i=0;i<TotalBans;i++)
	{
		ArrayGetArray(banlist_array,i,DATA);
		fprintf(file,"^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"^n",DATA[bantype],DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantime],DATA[unbantime],DATA[banner_authid],DATA[banner_ip],DATA[banner_name],DATA[reason]);
	}
	fclose(file);
}

public CmdRESET()
{
	new file = fopen(ub_banlistfile,"wt");fclose(file);
	ArrayClear(banlist_array);
	TotalBans=0;
	log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log","< - - - - - ALL BANS RESET - - - - - >");
}

public CheckTimeUP()
{
	static Float:temp_interval;
	temp_interval = get_pcvar_float(cvar_CheckInterval);
	if (temp_interval<1.0)
	{
		set_task(1.0,"CheckTimeUP",1337);
		return PLUGIN_HANDLED
	}
	if (!TotalBans)
	{
		set_task(temp_interval,"CheckTimeUP",1337);
		return PLUGIN_HANDLED
	}
	static DATA[BanInfo],func_buffer[256],bool:filter_file,Float:handle_delay;
	handle_delay = 0.0;
	filter_file = false;
	for(new i=0;i<TotalBans;i++)
	{
		ArrayGetArray(banlist_array,i,DATA);
		if (equali(DATA[unbantime],"<null>",6))
			continue;
		if (!get_ban_timeleft(DATA[unbantime]))
		{
			if (!equali(DATA[target_name],"<null>",6))	
				formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_name]);	
			else
			{
				if ((equali(DATA[bantype],"STEAMID",7))&&(!equali(DATA[target_authid],"<null>",6)))
					formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_authid]);
				else
					formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x04 BANTIME Up/Elaped for^x03 %s",DATA[target_ip]);
			}
			set_task(handle_delay,"ChatPrint",80085,func_buffer,charsmax(func_buffer));
			formatex(func_buffer,charsmax(func_buffer),"<UNBAN> BANTIME Up/Elapsed for <AuthID: ^"%s^" | IP: ^"%s^" | Name: ^"%s^" | BanType: ^"%s^">",DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantype]);
			set_task(handle_delay,"DelayedLog",80085,func_buffer,charsmax(func_buffer));
			handle_delay += 0.5;
			ArrayDeleteItem(banlist_array,i);
			TotalBans--;
			i--;
			filter_file = true;
		}
	}
	if (!filter_file)
	{
		set_task(temp_interval,"CheckTimeUP",1337);
		return PLUGIN_HANDLED
	}
	new file = fopen(ub_banlistfile,"wt");
	for(new i=0;i<TotalBans;i++)
	{
		ArrayGetArray(banlist_array,i,DATA);
		fprintf(file,"^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"^n",DATA[bantype],DATA[target_authid],DATA[target_ip],DATA[target_name],DATA[bantime],DATA[unbantime],DATA[banner_authid],DATA[banner_ip],DATA[banner_name],DATA[reason]);
	}
	fclose(file);
	set_task(temp_interval,"CheckTimeUP",1337);
	return PLUGIN_HANDLED
}

public CmdBANMENU(id,level,cid)
{
	if (!cmd_access(id,level,cid,1,false))
		return PLUGIN_HANDLED
	Menu_Ban_pos[id] = 0;
	Menu_Ban_Display(id,Menu_Ban_pos[id]);
	return PLUGIN_HANDLED
}

public Menu_Ban_Keys(id,key)
{
	switch (key)
	{
		case 9:	
		{
			if (Menu_Ban_pos[id])
				Menu_Ban_Display(id,--Menu_Ban_pos[id])
			else
				Menu_Ban_pos[id] = 0;
			return PLUGIN_HANDLED
		}
		case 8: Menu_Ban_Display(id,++Menu_Ban_pos[id]);
		case 7:
		{
			client_print(id,print_chat,"[Geek~Gamers] Type in the Duration of BAN in Minute(s)");
			client_cmd(id,"messagemode SetDuration");
		}			
		case 6:
		{
			if(Menu_Ban_BanType[id]<3)
				Menu_Ban_BanType[id]++;
			else
				Menu_Ban_BanType[id]=0;
			Menu_Ban_Display(id,Menu_Ban_pos[id]);
		}
		default:
		{
			Menu_Ban_Target[id] = Menu_Ban_Players[id][Menu_Ban_pos[id]*6+key];
			if(!is_user_connected(Menu_Ban_Target[id]))
			{
				client_print(id,print_chat,"[Geek~Gamers] Sorry, but the Player has already Disconnected from the Server");
				Menu_Ban_pos[id] = 0;
				Menu_Ban_Display(id,Menu_Ban_pos[id]);
				return PLUGIN_HANDLED
			}
			client_print(id,print_chat,"[Geek~Gamers] Type in the reason for banning this player");
			client_cmd(id,"messagemode SetReason");
		}
	}
	return PLUGIN_HANDLED
}

Menu_Ban_Display(id,pos)
{
	static Keys,len,Start,End,temp_pos,Name[64],bool:is_flagged,func_Buffer[512];
	temp_pos=0,Keys=MENU_KEY_0|MENU_KEY_7|MENU_KEY_8;
	get_players(Menu_Ban_Players[id],Menu_Ban_Total[id], "c");
	Start = pos*6;
	if (Start>Menu_Ban_Total[id])
		return PLUGIN_HANDLED
	if (Start<0)
		Start=0;
	End = Start+6;
	if (End>Menu_Ban_Total[id])
		End=Menu_Ban_Total[id];
	get_pcvar_string (cvar_Flags,Flags,charsmax(Flags));
	strtolower(Flags);
	is_flagged = false;
	len = formatex(func_Buffer,charsmax(func_Buffer),"\d[\yGeek~Gamers\d] \rBan Menu:^n^n");
	for (new i=Start;i<End;i++)
	{
		ids = Menu_Ban_Players[id][i];
		temp_pos++;
		get_user_name(ids,Name,charsmax(Name));
		if (id==ids)
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \d%s^t\r(Self)^n",temp_pos,Name);
			continue;
		}
		for (new j=0;j<strlen(Flags);j++)
			if ((isalpha(Flags[j]))&&(get_user_flags(ids) & power(2,(Flags[j]-97))))
			{
				is_flagged = true;
				break;
			}
		if (is_flagged)
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \d%s^t\r(Flagged)^n",temp_pos,Name);
			is_flagged = false;
		}
		else
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \w%s^n",temp_pos,Name);
			Keys |= (1<<temp_pos-1);
		}
	}
	switch (Menu_Ban_BanType[id])
	{
		case 0: len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n\y7. \rBanType: \dAUTO^n");
		case 1: len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n\y7. \rBanType: \wSTEAMID^n");
		case 2: len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n\y7. \rBanType: \wIP^n");
		case 3: len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n\y7. \rBanType: \wNAME^n");
	}
	if (!Menu_Ban_Duration[id])
		len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y8. \rDuration: \dPermanent^n^n");
	else
		len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y8. \rDuration: \w%s^n^n",STR_Menu_Ban_Duration[id]);
	if (End!=Menu_Ban_Total[id])
	{
		len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y9. \wNext^n");
		Keys |= MENU_KEY_9;
	}
	len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y0. \w%s^n",Start?"Back":"Exit");
	show_menu(id,Keys,func_Buffer,-1,"Ban Menu");
	return PLUGIN_HANDLED
}

public CmdUNBANMENU(id,level,cid)
{
	if (!cmd_access(id,level,cid,1,false))
		return PLUGIN_HANDLED
	Menu_Unban_pos[id] = 0;
	Menu_Unban_Display(id,Menu_Unban_pos[id]);
	return PLUGIN_HANDLED
}

public Menu_Unban_Keys(id,key)
{
	switch (key)
	{
		case 9:	
		{
			if (Menu_Unban_pos[id])
				Menu_Unban_Display(id,--Menu_Unban_pos[id])
			else
				Menu_Unban_pos[id] = 0;
			return PLUGIN_HANDLED
		}
		case 8: Menu_Unban_Display(id,++Menu_Unban_pos[id]);
		default:
		{
			if(Menu_Unban_Time[id]<LastBanTime<=get_gametime())
			{
				client_print(id,print_chat,"[Geek~Gamers] Sorry, but the BanList was Updated since Last Time. Please Try Again.");
				Menu_Unban_pos[id] = 0;
				Menu_Unban_Display(id,Menu_Unban_pos[id]);
				return PLUGIN_HANDLED
			}
			static DATA[BanInfo];
			handle_unban_menu_call[id] = true;
			ArrayGetArray(banlist_array,TotalBans-1-Menu_Unban_pos[id]*6-key,DATA);
			if (equali(DATA[bantype],"STEAMID",7))
				client_cmd(id,"amx_unban ^"%s^" ^"STEAMID^"",DATA[target_authid]);
			else if (equali(DATA[bantype],"IP",2))
				client_cmd(id,"amx_unban ^"%s^" ^"IP^"",DATA[target_ip]);
			else if (equali(DATA[bantype],"NAME",4))
				client_cmd(id,"amx_unban ^"%s^" ^"NAME^"",DATA[target_name]);
		}
	}
	return PLUGIN_HANDLED
}

Menu_Unban_Display(id,pos)
{
	if (!TotalBans)
	{
		client_print(id,print_chat,"[Geek~Gamers] No Ban Entries found in the Server");
		return PLUGIN_HANDLED
	}
	static Keys,len,Start,End,temp_pos,func_Buffer[512],DATA[BanInfo];
	temp_pos=0,Keys=MENU_KEY_0;
	Start = TotalBans-1-pos*6;
	if (Start<0)
		return PLUGIN_HANDLED
	if (0<=Start<=5)	
		End = 0;
	else
		End = Start-5;
	len = formatex(func_Buffer,charsmax(func_Buffer),"\d[\yGeek~Gamers\d] \rUnBan Menu::^n^n\yNote: \wFor More Information about the^n         Banned Player, Type in Console:^n         \yamx_queryban \w<target> \r<type>^n^n");
	for (new i=Start;i>=End;i--)
	{
		ArrayGetArray(banlist_array,i,DATA);
		temp_pos++;
		if (equali(DATA[target_name],"<null>"))
		{
			if (equali(DATA[bantype],"STEAMID",7))
				len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i.^t\w%s^t\r[STEAMID]^n",temp_pos,DATA[target_authid]);
			else
				len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i.^t\w%s^t\r[IP]^n",temp_pos,DATA[target_ip]);
		}
		else
		{
			if (equali(DATA[bantype],"STEAMID",7))
				len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i.^t\w%s^t\r[STEAMID]^t\d( %s )^n",temp_pos,DATA[target_authid],DATA[target_name]);
			else if (equali(DATA[bantype],"IP",2))
				len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i.^t\w%s^t\r[IP]^t\d( %s )^n",temp_pos,DATA[target_ip],DATA[target_name]);
			else
				len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i.^t\w%s^t\r[NAME]^n",temp_pos,DATA[target_name]);
		}
		Keys |= (1<<temp_pos-1);
	}
	len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n");
	if (End>0)
	{
		len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y9. \wNext^n");
		Keys |= MENU_KEY_9;
	}
	len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y0. \w%s^n",(Start==TotalBans-1)?"Exit":"Back");
	show_menu(id,Keys,func_Buffer,-1,"Unban Menu");
	Menu_Unban_Time[id] = get_gametime();
	return PLUGIN_HANDLED
}

public CmdVOTEMENU(id)
{
	if (!get_pcvar_num(cvar_vote_enable))
	{
		client_print(id,print_chat,"[Geek~Gamers] Voteban Menu feature has been disabled by Server");
		return PLUGIN_HANDLED
	}
	Menu_Ban_pos[id] = 0;
	Menu_Vote_Display(id,Menu_Ban_pos[id]);
	return PLUGIN_HANDLED
}

public Menu_Vote_Keys(id,key)
{
	switch (key)
	{
		case 9:	
		{
			if (Menu_Ban_pos[id])
				Menu_Vote_Display(id,--Menu_Ban_pos[id])
			else
				Menu_Ban_pos[id] = 0;
			return PLUGIN_HANDLED
		}
		case 8: Menu_Vote_Display(id,++Menu_Ban_pos[id]);
		default:
		{
			static ids,Float:duration,Req_Votes_Percent,szName[2][64],func_buffer[128];
			if (get_gametime()-LastVoted[id]<get_pcvar_float(cvar_vote_delay))
			{
				client_print(id,print_chat,"[Geek~Gamers] Wait for Sometime before using Voteban again");
				return PLUGIN_HANDLED
			}
			ids = Menu_Ban_Players[id][Menu_Ban_pos[id]*6+key];
			if(!is_user_connected(ids))
			{
				client_print(id,print_chat,"[Geek~Gamers] Sorry, but the Player has already Disconnected from the Server");
				Menu_Ban_pos[id] = 0;
				Menu_Vote_Display(id,Menu_Ban_pos[id]);
				return PLUGIN_HANDLED
			}
			if (Votes_Players[id][ids])
			{
				client_print(id,print_chat,"[Geek~Gamers] You have already voted against this Player");
				Menu_Vote_Display(id,Menu_Ban_pos[id]);	
				return PLUGIN_HANDLED
			}
			Votes_Players[id][ids] = 1;	
			get_user_name(id,szName[0],charsmax(szName[]));
			get_user_name(ids,szName[1],charsmax(szName[]));
			formatex(func_buffer,charsmax(func_buffer),"^x01[Geek~Gamers]^x03 %s^x04 has Voted to Ban^x03 %s",szName[0],szName[1]);
			get_players(player,total);
			for(new i=0;i<total;i++)
			{	
				message_begin(MSG_ONE,msgid,{0,0,0},player[i]);
				write_byte(player[i]);
				write_string(func_buffer);
				message_end();
			}
			LastVoted[id] = get_gametime();
			Req_Votes_Percent = floatround(floatmul(get_pcvar_float(cvar_vote_ratio),100.0))-eval_votes(ids);
			if (Req_Votes_Percent<=0)
			{
				duration = get_pcvar_float(cvar_vote_time);
				if (duration<0.0)
					server_cmd("amx_banggp #%d ^"60.0^" ^"Banned by VOTE^" ^"AUTO^"",get_user_userid(ids));
				else if (duration==0.0||duration>9999999.0)
					server_cmd("amx_banggp #%d ^"0.0^" ^"Banned by VOTE^" ^"AUTO^"",get_user_userid(ids));
				else
					server_cmd("amx_banggp #%d ^"%f^" ^"Banned by VOTE^" ^"AUTO^"",get_user_userid(ids),duration);
			}
			else
				client_print(id,print_chat,"[Geek~Gamers] %i more Vote(s) are required to BAN %s",floatround(floatmul(float(Req_Votes_Percent)/100.0,float(total)),floatround_ceil),szName[1]);
			Menu_Vote_Display(id,Menu_Ban_pos[id]);
		}
	}
	return PLUGIN_HANDLED
}

Menu_Vote_Display(id,pos)
{
	static Keys,len,Start,End,temp_pos,Name[64],bool:is_flagged,func_Buffer[512];
	temp_pos=0,Keys=MENU_KEY_0;
	get_players(Menu_Ban_Players[id],Menu_Ban_Total[id]);
	if (Menu_Ban_Total[id]<get_pcvar_num(cvar_vote_min))
	{
		client_print(id,print_chat,"[Geek~Gamers] Too Less Players for Voteban Process");
		return PLUGIN_HANDLED
	}
	Start = pos*8;
	if (Start>Menu_Ban_Total[id])
		return PLUGIN_HANDLED
	if (Start<0)
		Start=0;
	End = Start+8;
	if (End>Menu_Ban_Total[id])
		End=Menu_Ban_Total[id];
	get_pcvar_string (cvar_Flags,Flags,charsmax(Flags));
	strtolower(Flags);
	is_flagged = false;
	len = formatex(func_Buffer,charsmax(func_Buffer),"\d[\yGeek~Gamers\d] \rVoteBan Menu:^n^n");
	for (new i=Start;i<End;i++)
	{
		ids = Menu_Ban_Players[id][i];
		temp_pos++;
		get_user_name(ids,Name,charsmax(Name));
		if (id==ids)
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \d%s^t\y(\rSelf\y)^n",temp_pos,Name);
			continue;
		}
		for (new j=0;j<strlen(Flags);j++)
			if ((isalpha(Flags[j]))&&(get_user_flags(ids) & power(2,(Flags[j]-97))))
			{
				is_flagged = true;
				break;
			}
		if (is_flagged)
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \d%s^t\y(\rFlagged\y)^n",temp_pos,Name);
			is_flagged = false;
		}
		else
		{
			len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y%i. \w%s^t\y(\r%i%%\y)^n",temp_pos,Name,eval_votes(ids));
			Keys |= (1<<temp_pos-1);
		}
	}
	len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"^n");
	if (End!=Menu_Ban_Total[id])
	{
		len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y9. \wNext^n");
		Keys |= MENU_KEY_9;
	}
	len += formatex(func_Buffer[len],charsmax(func_Buffer)-len,"\y0. \w%s^n",Start?"Back":"Exit");
	show_menu(id,Keys,func_Buffer,-1,"Voteban Menu");
	return PLUGIN_HANDLED
}

public bad_input(id)
{
	if (id)
		client_cmd(id,"echo [Geek~Gamers] Bad Input");
	else
		server_print("[Geek~Gamers] Bad Input");
}

public JoinKick(Timeleft[],id)
{
	if (!equali(Timeleft,"<null>"))
		server_cmd("kick #%d ^"You are BANNED from this Server. Timeleft: %s. Check your Console for More Information.^"",get_user_userid(id),Timeleft);
	else
		server_cmd("kick #%d ^"You are Permanently BANNED from this Server. Check your Console for More Information.^"",get_user_userid(id));
}

get_monthdays (months,years=0)
{
	switch(months)
	{
		case 1:		return 31;
		case 2:		return ((years%4)?28:29);
		case 3:		return 31;
		case 4:		return 30;
		case 5:		return 31;
		case 6:		return 30;
		case 7:		return 31;
		case 8:		return 31;
		case 9:		return 30;
		case 10:	return 31;
		case 11:	return 30;
		case 12:	return 31;
	}
	return 30;
}

CheckBan (const input[],const input_type[])
{
	static DATA[BanInfo],pos,Found,bool:tmp;
	tmp=true,Found=0;
	for (new i=0;i<TotalBans;i++)
	{
		ArrayGetArray(banlist_array,i,DATA);
		if (!equali(DATA[bantype],input_type))
			continue;
		if (equali(input_type,"STEAMID",7))
		{	
			if (equali(DATA[target_authid],input))
			{
				if (MODE_LOADBAN)
					Found++;
				else
					return i;
			}
		}
		else if (equali(input_type,"IP",2))
		{
			if (MODE_LOADBAN)
			{
				if (equal(DATA[target_ip],input))
					Found++;
			}
			else if (MODE_UNBAN)
			{
				if (equal(DATA[target_ip],input))
					return i;
			}		
			else
			{
				if (CheckIP(DATA[target_ip],input))
				{
					if (MODE_ADDBAN)
						return i;
					else
						Found++;
				}
			}
		}
		else if (equali(input_type,"NAME",4))
		{
			if (MODE_LOADBAN)
			{
				if (equal(DATA[target_name],input))
					Found++;
			}			
			else if (MODE_UNBAN)
			{
				if (equal(DATA[target_name],input))
					return i;
			}
			else
			{
				if (equali(DATA[target_name],input,strlen(DATA[target_name])))
				{
					if (MODE_ADDBAN)
						return i;
					else
						Found++;
				}
			}
		}
		if ((Found==1)&&(tmp))
		{
			pos = i;
			tmp = false;
		}
		if (Found>1)
			return -1;
	}
	if (Found==1)
		return pos;
	return -2;
}

CheckIP (const param1[],const param2[])
{
	if (equal(param1,param2))
		return 1;
	static Range[16],IP[16],p1[3],p2[3],p3[3],p4[3],r1[3],r2[3],r3[3],r4[3];
	copy(Range,charsmax(Range),param1);
	copy(IP,charsmax(IP),param2);
	replace_all(Range,charsmax(Range),"."," ");
	replace_all(IP,charsmax(IP),"."," ");
	parse(Range,r1,charsmax(r1),r2,charsmax(r2),r3,charsmax(r3),r4,charsmax(r4));
	parse(IP,p1,charsmax(p1),p2,charsmax(p2),p3,charsmax(p3),p4,charsmax(p4));
	if (!str_to_num(r4))
	{
		if (equal(p1,r1)&&equal(p2,r2)&&equal(p3,r3))
			return 2;
		if (!str_to_num(r3))
		{
			if (equal(p1,r1)&&equal(p2,r2))
				return 2;
			if (!str_to_num(r2))
				if (equal(p1,r1))
					return 2;
		}
	}
	return 0;
}

get_ban_timeleft (const raw_input[],output[]="<null>",len2=-1)
{
	static NUM_NOW_hours,input[32],NUM_NOW_minutes,NUM_NOW_seconds,NUM_NOW_days,NUM_NOW_months,NUM_NOW_years,NOW_totalminutes,NUM_UNBAN_hours,NUM_UNBAN_minutes,NUM_UNBAN_seconds,NUM_UNBAN_days,NUM_UNBAN_months,NUM_UNBAN_years;
	static STR_NOW_hours[5],STR_NOW_minutes[5],STR_NOW_seconds[5],STR_NOW_days[5],STR_NOW_months[5],STR_NOW_years[7],STR_UNBAN_hours[5],STR_UNBAN_minutes[5],STR_UNBAN_seconds[5],STR_UNBAN_days[5],STR_UNBAN_months[5],STR_UNBAN_years[7];
	static UNBAN_totalminutes,days_left,hours_left,minutes_left,seconds_left,REM_totalminutes,len;			
	copy(input,charsmax(input),raw_input);
	replace_all(input,charsmax(input),":"," ");
	replace_all(input,charsmax(input),"/"," ");
	format_time(STR_NOW_hours,charsmax(STR_NOW_hours),"%H");
	format_time(STR_NOW_minutes,charsmax(STR_NOW_minutes),"%M");
	format_time(STR_NOW_seconds,charsmax(STR_NOW_seconds),"%S");
	format_time(STR_NOW_days,charsmax(STR_NOW_days),"%d");
	format_time(STR_NOW_months,charsmax(STR_NOW_months),"%m");
	format_time(STR_NOW_years,charsmax(STR_NOW_years),"%Y");
	NUM_NOW_hours = str_to_num(STR_NOW_hours);
	NUM_NOW_minutes = str_to_num(STR_NOW_minutes);
	NUM_NOW_seconds = str_to_num(STR_NOW_seconds);
	NUM_NOW_days = str_to_num(STR_NOW_days);
	NUM_NOW_months = str_to_num(STR_NOW_months);
	NUM_NOW_years = str_to_num(STR_NOW_years);
	parse(input,STR_UNBAN_hours,charsmax(STR_UNBAN_hours),STR_UNBAN_minutes,charsmax(STR_UNBAN_minutes),STR_UNBAN_seconds,charsmax(STR_UNBAN_seconds),STR_UNBAN_days,charsmax(STR_UNBAN_days),STR_UNBAN_months,charsmax(STR_UNBAN_months),STR_UNBAN_years,charsmax(STR_UNBAN_years));
	NUM_UNBAN_hours = str_to_num(STR_UNBAN_hours);
	NUM_UNBAN_minutes = str_to_num(STR_UNBAN_minutes);
	NUM_UNBAN_seconds = str_to_num(STR_UNBAN_seconds);
	NUM_UNBAN_days = str_to_num(STR_UNBAN_days);
	NUM_UNBAN_months = str_to_num(STR_UNBAN_months);
	NUM_UNBAN_years = str_to_num(STR_UNBAN_years);
	if (NUM_UNBAN_years<NUM_NOW_years
	||NUM_UNBAN_years==NUM_NOW_years&&NUM_UNBAN_months<NUM_NOW_months
	||NUM_UNBAN_years==NUM_NOW_years&&NUM_UNBAN_months==NUM_NOW_months&&NUM_UNBAN_days<NUM_NOW_days
	||NUM_UNBAN_years==NUM_NOW_years&&NUM_UNBAN_months==NUM_NOW_months&&NUM_UNBAN_days==NUM_NOW_days&&NUM_UNBAN_hours<NUM_NOW_hours
	||NUM_UNBAN_years==NUM_NOW_years&&NUM_UNBAN_months==NUM_NOW_months&&NUM_UNBAN_days==NUM_NOW_days&&NUM_UNBAN_hours==NUM_NOW_hours&&NUM_UNBAN_minutes<NUM_NOW_minutes
	||NUM_UNBAN_years==NUM_NOW_years&&NUM_UNBAN_months==NUM_NOW_months&&NUM_UNBAN_days==NUM_NOW_days&&NUM_UNBAN_hours==NUM_NOW_hours&&NUM_UNBAN_minutes==NUM_NOW_minutes&&NUM_UNBAN_seconds<=NUM_NOW_seconds)
		return 0;
	if (len2==-1)
		return 1;
	for (new z=0;z<=len2;z++)
		output[z] = 0;
	if (NUM_NOW_months==1||NUM_NOW_months==2)
	{
		NUM_NOW_months += 12;
		NUM_NOW_years--;
	}
	if (NUM_UNBAN_months==1||NUM_UNBAN_months==2)
	{
		NUM_UNBAN_months += 12;
		NUM_UNBAN_years--;
	}
	days_left	=(floatround(365.0*NUM_UNBAN_years,floatround_floor)-floatround(365.0*NUM_NOW_years,floatround_floor))
			+(floatround(NUM_UNBAN_years/4.0,floatround_floor)-floatround(NUM_NOW_years/4.0,floatround_floor))
			-(floatround(NUM_UNBAN_years/100.0,floatround_floor)-floatround(NUM_NOW_years/100.0,floatround_floor))
			+(floatround(NUM_UNBAN_years/400.0,floatround_floor)-floatround(NUM_NOW_years/400.0,floatround_floor))
			+(NUM_UNBAN_days-NUM_NOW_days)
			+(floatround(((153.0*NUM_UNBAN_months)+8.0)/5.0,floatround_floor)-floatround(((153.0*NUM_NOW_months)+8.0)/5.0,floatround_floor));
	NOW_totalminutes = (60*NUM_NOW_hours)+NUM_NOW_minutes;
	UNBAN_totalminutes = (60*NUM_UNBAN_hours)+NUM_UNBAN_minutes;
	if (UNBAN_totalminutes>=NOW_totalminutes)
		REM_totalminutes = UNBAN_totalminutes-NOW_totalminutes;
	else
	{
		REM_totalminutes = 1440-(NOW_totalminutes-UNBAN_totalminutes);
		days_left--;
	}
	hours_left = REM_totalminutes/60;
	minutes_left = REM_totalminutes-(hours_left*60);
	if (NUM_UNBAN_seconds-NUM_NOW_seconds>0)
		seconds_left = NUM_UNBAN_seconds-NUM_NOW_seconds;
	else
	{
		seconds_left = 60-(NUM_NOW_seconds-NUM_UNBAN_seconds);
		if (minutes_left)
			minutes_left--;
		else
		{
			minutes_left = 59;
			if (hours_left)
				hours_left--;
			else
			{
				hours_left = 23;
				days_left--;
			}
		}
	}
	len = 0;
	if (days_left)
		len += formatex(output[len],len2-len,"%d Day(s) ",days_left);
	if (hours_left)
		len += formatex(output[len],len2-len,"%i Hour(s) ",hours_left);
	if (minutes_left)
		len += formatex(output[len],len2-len,"%i Minute(s) ",minutes_left);
	if (seconds_left)
		len += formatex(output[len],len2-len,"%i Second(s)",seconds_left);	
	return 1;
}

public ChatPrint(const message[])
{
	get_players(player,total);
	for(new i=0;i<total;i++)
	{
		ids = player[i];
		message_begin(MSG_ONE,msgid,{0,0,0},ids);
		write_byte(ids);
		write_string(message);
		message_end();
	}
}

public DelayedLog(const message[])
	log_to_file("addons/amxmodx/logs/GG_Logs/UB_Logs.log",message);

PrintBanInfo(DATA[],id=0,Timeleft[]="<null>")
{
	if (id)
	{	
		client_cmd(id,"echo [Geek~Gamers] BanType - %s",DATA[bantype]);
		if (!equali(DATA[target_authid],"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] TargetID - %s",DATA[target_authid]);
		if (!equali(DATA[target_ip],"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] TargetIP - %s",DATA[target_ip]);
		if (!equali(DATA[target_name],"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] TargetName - %s",DATA[target_name]);
		client_cmd(id,"echo [Geek~Gamers] BanTime - %s",DATA[bantime]);
		if (!equali(DATA[unbantime],"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] UnbanTime - %s",DATA[unbantime]);
		else
			client_cmd(id,"echo [Geek~Gamers] UnbanTime - Never ( Permanent Ban )");
		if (!equali(Timeleft,"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] Timeleft - %s",Timeleft);
		if (!equali(DATA[banner_name],"<null>",6))
		{
			if (!equali(DATA[banner_name],"RCON/Server",11))
			{
				client_cmd(id,"echo [Geek~Gamers] BannerID - %s",DATA[banner_authid]);
				client_cmd(id,"echo [Geek~Gamers] BannerIP - %s",DATA[banner_ip]);
			}
			client_cmd(id,"echo [Geek~Gamers] BannerName - %s",DATA[banner_name]);
		}
		if (!equali(DATA[reason],"<null>",6))
			client_cmd(id,"echo [Geek~Gamers] Reason - %s",DATA[reason]);
		client_cmd(id,"echo [Geek~Gamers] -------------------------------");
	}
	else
	{
		server_print("[Geek~Gamers] BanType - %s",DATA[bantype]);
		if (!equali(DATA[target_authid],"<null>",6))
			server_print("[Geek~Gamers] TargetID - %s",DATA[target_authid]);
		if (!equali(DATA[target_ip],"<null>",6))
			server_print("[Geek~Gamers] TargetIP - %s",DATA[target_ip]);
		if (!equali(DATA[target_name],"<null>",6))
			server_print("[Geek~Gamers] TargetName - %s",DATA[target_name]);
		server_print("[Geek~Gamers] BanTime - %s",DATA[bantime]);
		if (!equali(DATA[unbantime],"<null>",6))
			server_print("[Geek~Gamers] UnbanTime - %s",DATA[unbantime]);
		if (!equali(DATA[banner_name],"<null>",6))
		{
			if (!equali(DATA[banner_name],"RCON/Server",11))
			{
				server_print("[Geek~Gamers] BannerID - %s",DATA[banner_authid]);
				server_print("[Geek~Gamers] BannerIP - %s",DATA[banner_ip]);
			}
			server_print("[Geek~Gamers] BannerName - %s",DATA[banner_name]);
		}
		if (!equali(DATA[reason],"<null>",6))
			server_print("[Geek~Gamers] Reason - %s",DATA[reason]);
		server_print("[Geek~Gamers] -------------------------------");
	}
}

public Menu_SetDuration(id)
{
	static len,dot,count_digits,seconds,minutes,hours,days,ARG_Menu_Duration[128];
	len=0,dot=0,count_digits=1,minutes=0,seconds=0,hours=0,days=0;
	read_args(ARG_Menu_Duration,charsmax(ARG_Menu_Duration));
	remove_quotes(ARG_Menu_Duration);
	trim(ARG_Menu_Duration);
	if (!strlen(ARG_Menu_Duration))
	{
		Menu_Ban_Display(id,Menu_Ban_pos[id]);
		return PLUGIN_HANDLED
	}
	if (!isdigit(ARG_Menu_Duration[0]))
	{
		client_print(id,print_chat,"[Geek~Gamers] Bad Input");
		Menu_Ban_Display(id,Menu_Ban_pos[id]);
		return PLUGIN_HANDLED
	}
	for (new i=1;i<strlen(ARG_Menu_Duration);i++)
	{
		if (ARG_Menu_Duration[i]=='.')
		{
			if (++dot>1)
			{
				client_print(id,print_chat,"[Geek~Gamers] Bad Input");
				Menu_Ban_Display(id,Menu_Ban_pos[id]);
				return PLUGIN_HANDLED
			}
		}
		else if (!isdigit(ARG_Menu_Duration[i]))
		{
			client_print(id,print_chat,"[Geek~Gamers] Bad Input");
			Menu_Ban_Display(id,Menu_Ban_pos[id]);
			return PLUGIN_HANDLED
		}
		else if (!dot)
			count_digits++;
	}
	if (count_digits>8)
	{
		Menu_Ban_Duration[id] = 0.0;
		copy(STR_Menu_Ban_Duration[id],127,"Permanent");
		return PLUGIN_HANDLED		
	}
	else
		Menu_Ban_Duration[id] = str_to_float(ARG_Menu_Duration);
	minutes = floatround(Menu_Ban_Duration[id],floatround_floor);
	seconds = floatround(floatfract(Menu_Ban_Duration[id])*60,floatround_floor);
	while(minutes>=60)
	{
		minutes -= 60;
		hours++;
	}
	while(hours>=24)
	{
		hours -= 24;
		days++;
	}
	if (Menu_Ban_Duration[id])
	{
		if (days)
			len += formatex(STR_Menu_Ban_Duration[id][len],127-len,"%d Day(s) ",days);
		if (hours)
			len += formatex(STR_Menu_Ban_Duration[id][len],127-len,"%i Hour(s) ",hours);
		if (minutes)
			len += formatex(STR_Menu_Ban_Duration[id][len],127-len,"%i Minute(s) ",minutes);
		if (seconds)
			len += formatex(STR_Menu_Ban_Duration[id][len],127-len,"%i Second(s)",seconds);
	}
	else
	{
		Menu_Ban_Duration[id] = 0.0;
		copy(STR_Menu_Ban_Duration[id],127,"Permanent");
	}
	Menu_Ban_Display(id,Menu_Ban_pos[id]);
	return PLUGIN_HANDLED
}

public Menu_SetReason(id)
{
	static ARG_Menu_Reason[128], AuthID[32];
	ids = Menu_Ban_Target[id];
	if(!is_user_connected(ids))
	{
		client_print(id, print_chat, "[Geek~Gamers] Sorry, but the Player has already Disconnected from the Server.");
		Menu_Ban_Display(id,Menu_Ban_pos[id]);
		return PLUGIN_HANDLED
	}	
	read_args(ARG_Menu_Reason,charsmax(ARG_Menu_Reason));
	remove_quotes(ARG_Menu_Reason);
	trim(ARG_Menu_Reason);

	if( CountNumbers(ARG_Menu_Reason) >= 8 || containi(ARG_Menu_Reason, "%") != -1 )
	{
		client_print(id, print_chat, "[Geek~Gamers] Please type a valid reason!");
		client_cmd(id,"messagemode SetReason");
		return PLUGIN_HANDLED
	}

	handle_ban_menu_call[id] = true;
	switch (Menu_Ban_BanType[id])
	{
		case 0: client_cmd(id, "amx_banggp #%i ^"%f^" ^"%s^" ^"AUTO^"", get_user_userid(ids), Menu_Ban_Duration[id], ARG_Menu_Reason);
		case 1: 
		{
			get_user_authid(ids,AuthID,charsmax(AuthID));
			if (IsValidAUTHID(AuthID))
				client_cmd(id,"amx_banggp #%i ^"%f^" ^"%s^" ^"STEAMID^"", get_user_userid(ids), Menu_Ban_Duration[id], ARG_Menu_Reason);
			else
			{
				client_print(id,print_chat,"[Geek~Gamers] AuthID Not Valid for Banning");
				handle_ban_menu_call[id] = false;
				Menu_Ban_Display(id,Menu_Ban_pos[id]);
				return PLUGIN_HANDLED
			}
		}	
		case 2: client_cmd(id,"amx_banggp #%i ^"%f^" ^"%s^" ^"IP^"", get_user_userid(ids), Menu_Ban_Duration[id], ARG_Menu_Reason);
		case 3: client_cmd(id,"amx_banggp #%i ^"%f^" ^"%s^" ^"NAME^"", get_user_userid(ids), Menu_Ban_Duration[id], ARG_Menu_Reason);
	}
	Menu_Ban_Reset(id);
	Menu_Ban_Display(id,Menu_Ban_pos[id]);
	return PLUGIN_HANDLED
}

public Menu_Ban_Reset(id)
{
	Menu_Ban_pos[id] = 0;
	Menu_Ban_Duration[id] = 0.0;
	for (new i=0;i<128;i++)
		STR_Menu_Ban_Duration[id][i]=0;
	Menu_Ban_BanType[id] = 0;
}

stock eval_votes(ids)
{
	new id,tmp_count;
	get_players(player,total);
	for (new i=0;i<total;i++)
	{
		id = player[i];
		if (Votes_Players[id][ids])
			tmp_count++;
	}
	return floatround(floatmul(float(tmp_count)/float(total),100.0));
}

stock CountNumbers( const String[] )
{
	new Count;
	new Len = strlen( String );

	for ( new i = 0 ; i < Len; i++ )
	{
		if ( isdigit( String[ i ] ) )
		{
			Count++;
		}
	}

	return Count;
}