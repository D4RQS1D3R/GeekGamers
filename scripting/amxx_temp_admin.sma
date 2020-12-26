/* AMXMOD X script.
*
* Scripted by GHW.Chronic
*
*   v1.2 - Admin Automatically Gets Admin, No Name Changing Or Map Change To Get His Admin
*        - Permanent Admin Capabilities Added
*        - User's Name Is Added To The Users.ini File
*        - Temp-Admin Removal Is Logged
*
*   v1.0 - Initial Release
*
*/

#include <amxmodx>
#include <amxmisc>

new tempname[33][32]

public plugin_init()
{
	register_plugin("Temporary Admin", "1.2", "GHW_Chronic")
        register_concmd("amx_tempadmin","amx_tempadmin",ADMIN_RCON," <NAME> <Days to have admin (0=infinate)> <Flags(find out flags in users.ini file)> ")
	register_cvar("days","0")
	register_cvar("months","0")
	register_cvar("years","0")
	register_cvar("tempid","0")
	register_cvar("cvar_i_ta","0")
	register_cvar("flags","bcdefghijklmnopqrstu")
	set_task(5.0,"check_date",0)
	return PLUGIN_CONTINUE
}

public check_date()
{
	new todaysmonth[32]
	new todaysday[32]
	new todaysyear[32]
	get_time("%m",todaysmonth,31)
	get_time("%d",todaysday,31)
	get_time("%Y",todaysyear,31)
	new todaysdaynum = str_to_num(todaysday)
	new todaysmonthnum = str_to_num(todaysmonth)
	new todaysyearnum = str_to_num(todaysyear)
	new alltogether[200]
	format(alltogether,199,"m%dd%dy%d",todaysmonthnum,todaysdaynum,todaysyearnum)

	new configdir[200]
	get_configsdir(configdir,199)
	new configfile1[200]
	format(configfile1,199,"%s/bought_admins.ini",configdir)

	new filelen1
	new filesays1[32]
	new i = get_cvar_num("cvar_i_ta")

	new configfile2[200]
	format(configfile2,199,"%s/users.ini",configdir)

	read_file(configfile1,i,filesays1,31,filelen1)
	new filesays3[200]
	format(filesays3,199,"%s",filesays1)
	new i2 = i + 1
	if(i>401)
	{
		set_cvar_num("cvar_i_ta",0)
		return PLUGIN_HANDLED
	}

	if(equal(filesays3,alltogether))
	{
		new filesays2[5]
		new txtLen
		read_file(configfile1,i2,filesays2,4,txtLen)
		new filesays5 = str_to_num(filesays2)

		write_file(configfile2,";Temp-Admin's Name Use To Be here. Do not remove this line unless it is the last line in the users.ini file.",filesays5)
		write_file(configfile1,";Old Date Use To Be Here.",i)
		new aaa = filesays5 - 1
		new aaaa[32]
		read_file(configfile2,aaa,aaaa,31,txtLen)
		new holder769[200]
		format(holder769,199,"say Temp-Admin ^"%s^"Has Been Removed From Administration.",aaaa)
		log_amx("Temp-Admin ^"%s^"Has Been Removed From Administration.",aaaa)
		server_cmd(holder769)
	}
	set_cvar_num("cvar_i_ta",i2)
	set_task(0.0, "check_date")
	return PLUGIN_HANDLED
}

public amx_tempadmin(id,level,cid)
{
	if ( !cmd_access(id,level,cid,4) )
	{
		return PLUGIN_HANDLED
	}
	new arg1[63]
	new arg2[63]
	new arg3[63]
	read_argv(1,arg1,63)
	read_argv(2,arg2,63)
	read_argv(3,arg3,63)
	set_cvar_string("flags",arg3)
	new arg22 = str_to_num(arg2)
	new plist[32]
	new pnum
	get_players(plist,pnum,"c")
	new tempid2 = find_player("bl",arg1)
	set_cvar_num("tempid",tempid2)
	set_cvar_num("findays",arg22)
	new temp_connected = is_user_connected(tempid2)
	if(temp_connected==1)
	{
		if(str_to_num(arg2)==0 || str_to_num(arg2)>=900)
		{
			new instertintousers[200]
			new instertintousersname[200]
			get_user_name(tempid2,tempname[tempid2],31)
			new tempsauthid[32]
			get_user_authid(tempid2,tempsauthid,31)
			format(instertintousers,199,"^"%s^" ^"^" ^"%s^" ^"ce^"",tempsauthid,arg3)
			new configdir[200]
			get_configsdir(configdir,199)
			new configfile1[200]
			format(configfile1,199,"%s/users.ini",configdir)
			write_file(configfile1,"",-1)
			format(instertintousersname,199,";%s",tempname[tempid2])
			write_file(configfile1,instertintousersname,-1)
			write_file(configfile1,instertintousers,-1)
			server_cmd("amx_reloadadmins")
			client_cmd(tempid2,"name PermanentAdmin")
			set_task(5.0,"changename",tempid2)
			console_print(id,"Permanent-Admin Has Been Added. He Now Has Admin.")
			return PLUGIN_HANDLED
		}
		set_cvar_num("tempid",tempid2)
		new todaysmonth[32]
		new todaysday[32]
		new todaysyear[32]
		get_time("%m",todaysmonth,31)
		get_time("%d",todaysday,31)
		get_time("%Y",todaysyear,31)
		new todaysdaynum = str_to_num(todaysday)
		new todaysmonthnum = str_to_num(todaysmonth)
		new todaysyearnum = str_to_num(todaysyear)
		new newday = todaysdaynum + arg22
		set_cvar_num("days",newday)
		set_cvar_num("months",todaysmonthnum)
		set_cvar_num("years",todaysyearnum)
		if(todaysmonthnum==1)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==2)
		{
			if(newday>28)
			{
				set_task(0.0, "february")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==3)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==4)
		{
			if(newday>30)
			{
				set_task(0.0, "thirty")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==5)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==6)
		{
			if(newday>30)
			{
				set_task(0.0, "thirty")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==7)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==8)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==9)
		{
			if(newday>30)
			{
				set_task(0.0, "thirty")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==10)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==11)
		{
			if(newday>30)
			{
				set_task(0.0, "thirty")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		if(todaysmonthnum==12)
		{
			if(newday>31)
			{
				set_task(0.0, "thirtyone")
				return PLUGIN_HANDLED
			}
			else
			{
				set_task(0.0, "makenewdate")
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	else
	{
		console_print(id,"No Player With That Name Exists")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public makenewdate()
{
	new endday = get_cvar_num("days")
	new endmonth = get_cvar_num("months")
	new endyear = get_cvar_num("years")
	new alltogether[200]
	format(alltogether,199,"m%dd%dy%d",endmonth,endday,endyear)
	new arg3[64]
	get_cvar_string("flags",arg3,63)
	new instertintousers[200]
	new instertintousersname[200]
	new tempsid2 = get_cvar_num("tempid")
	get_user_name(tempsid2,tempname[tempsid2],31)
	new tempsauthid[32]
	get_user_authid(tempsid2,tempsauthid,31)
	format(instertintousers,199,"^"%s^" ^"^" ^"%s^" ^"ce^"",tempsauthid,arg3)
	new configdir[200]
	get_configsdir(configdir,199)
	new configfile1[200]
	format(configfile1,199,"%s/users.ini",configdir)
	write_file(configfile1,"",-1)
	format(instertintousersname,199,";%s",tempname[tempsid2])
	write_file(configfile1,instertintousersname,-1)
	write_file(configfile1,instertintousers,-1)
	new line = file_size(configfile1,1)
	new line2 = line - 2
	new line3[200]
	format(line3,199,"%d",line2)
	new configfile2[200]
	format(configfile2,199,"%s/bought_admins.ini",configdir)
	write_file(configfile2,alltogether,-1)
	write_file(configfile2,line3,-1)
	server_cmd("amx_reloadadmins")
	client_cmd(tempsid2,"name TempAdmin")
	set_task(5.0,"changename",tempsid2)
	console_print(0,"Temp-Admin Has Been Added. He Now Has Admin.")
	return PLUGIN_HANDLED
}

public changename(id)
{
	new holder444[200]
	format(holder444,199,"name ^"%s^"",tempname[id])
	client_cmd(id,holder444)
	return PLUGIN_HANDLED
}
public thirtyone()
{
	new ndays = get_cvar_num("days")
	new nmonths = get_cvar_num("months")
	if(ndays>31)
	{
		new ndays2 = ndays - 31
		new nmonths2 = nmonths + 1
		set_cvar_num("days",ndays2)
		set_cvar_num("months",nmonths2)
		set_task(0.0, "select_days")
	}
	else
	{
		set_task(0.0, "makenewdate")
	}
	return PLUGIN_HANDLED
}

public thirty()
{
	new ndays = get_cvar_num("days")
	new nmonths = get_cvar_num("months")
	if(ndays>30)
	{
		new ndays2 = ndays - 30
		new nmonths2 = nmonths + 1
		set_cvar_num("days",ndays2)
		set_cvar_num("months",nmonths2)
		set_task(0.0, "select_days")
	}
	else
	{
		set_task(0.0, "makenewdate")
	}
	return PLUGIN_HANDLED
}

public february()
{
	new ndays = get_cvar_num("days")
	if(ndays>28)
	{
		new ndays2 = ndays - 28
		set_cvar_num("days",ndays2)
		set_cvar_num("months",3)
		set_task(0.0, "select_days")
	}
	else
	{
		set_task(0.0, "makenewdate")
	}
	return PLUGIN_HANDLED
}

public newyear()
{
	new ndays = get_cvar_num("days")
	new nyears = get_cvar_num("years")
	if(ndays>31)
	{
		new ndays2 = ndays - 31
		new nyears2 = nyears + 1
		set_cvar_num("days",ndays2)
		set_cvar_num("months",1)
		set_cvar_num("years",nyears2)
		set_task(0.0, "select_days")
	}
	else
	{
		set_task(0.0, "makenewdate")
	}
	return PLUGIN_HANDLED
}

public select_days()
{
	new nmonths = get_cvar_num("months")
	if(nmonths==1)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==2)
	{
		set_task(0.0, "february")
	}
	if(nmonths==3)
	{
		set_task(0.0, "thirty")
	}
	if(nmonths==4)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==5)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==6)
	{
		set_task(0.0, "thirty")
	}
	if(nmonths==7)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==8)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==9)
	{
		set_task(0.0, "thirty")
	}
	if(nmonths==10)
	{
		set_task(0.0, "thirtyone")
	}
	if(nmonths==11)
	{
		set_task(0.0, "thirty")
	}
	if(nmonths==12)
	{
		set_task(0.0, "newyear")
	}
	return PLUGIN_HANDLED
}