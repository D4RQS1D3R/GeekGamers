#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("[GG] Admins Manager", "1.0", "~D4rkSiD3Rs~");

	set_task(5.0, "Manage_Admins");
	set_task(10.0, "Manage_Admins2");
	set_task(15.0, "Manage_Admins3");
}

public Manage_Admins()
{
	new configdir[200];
	get_configsdir(configdir, 199);

	format(configdir, 199, "%s/users.ini", configdir);

	new line = 0;
	new linetextlength = 0;
	new linetext[512]

	new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];

	new Year[32];
	new Month[32];
	new Day[32];
	get_time("%Y", Year, 31);
	get_time("%m", Month, 31);
	get_time("%d", Day, 31);
	new YearsNum = str_to_num(Year);
	new MonthsNum = str_to_num(Month);
	new DaysNum = str_to_num(Day);

	if(file_exists(configdir))
	{
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue
			}

			parse(linetext, login, charsmax(login),
					password, charsmax(password),
					flags, charsmax(flags),
					aflags, charsmax(aflags),
					setinfo, charsmax(setinfo),
					setinfopw, charsmax(setinfopw),
					expiration_day, charsmax(expiration_day),
					expiration_month, charsmax(expiration_month),
					expiration_year, charsmax(expiration_year) );

			new exp_day = str_to_num(expiration_day);
			new exp_month = str_to_num(expiration_month);
			new exp_year = str_to_num(expiration_year);

			if( equali(login, "") || equali(expiration_day, "") || equali(expiration_month, "") || !isdigit(exp_day) || !isdigit(exp_month) )
				continue;

			if(equali(expiration_year, ""))
			{
				exp_year = YearsNum;
			}

			if( DaysNum >= exp_day && MonthsNum >= exp_month && YearsNum >= exp_year )
			{
				formatex(linetext, charsmax(linetext), ";^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"", login, password, flags, aflags, setinfo, setinfopw, expiration_day, expiration_month, expiration_year);
				write_file(configdir, linetext, line - 1);
			}
		}
	}
}

public Manage_Admins2()
{
	new configdir[200];
	get_configsdir(configdir, 199);

	format(configdir, 199, "%s/auto-admins.ini", configdir);

	new line = 0;
	new linetextlength = 0;
	new linetext[512]

	new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];

	new Year[32];
	new Month[32];
	new Day[32];
	get_time("%Y", Year, 31);
	get_time("%m", Month, 31);
	get_time("%d", Day, 31);
	new YearsNum = str_to_num(Year);
	new MonthsNum = str_to_num(Month);
	new DaysNum = str_to_num(Day);

	if(file_exists(configdir))
	{
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue
			}

			parse(linetext, login, charsmax(login),
					password, charsmax(password),
					flags, charsmax(flags),
					aflags, charsmax(aflags),
					setinfo, charsmax(setinfo),
					setinfopw, charsmax(setinfopw),
					expiration_day, charsmax(expiration_day),
					expiration_month, charsmax(expiration_month),
					expiration_year, charsmax(expiration_year) );

			new exp_day = str_to_num(expiration_day);
			new exp_month = str_to_num(expiration_month);
			new exp_year = str_to_num(expiration_year);

			if( equali(login, "") || equali(expiration_day, "") || equali(expiration_month, "") || !isdigit(exp_day) || !isdigit(exp_month) )
				continue;

			if(equali(expiration_year, ""))
			{
				exp_year = YearsNum;
			}

			if( DaysNum >= exp_day && MonthsNum >= exp_month && YearsNum >= exp_year )
			{
				formatex(linetext, charsmax(linetext), "^"^" ^"^" ^"%s^" ^"%s^" ^"^" ^"^" ^"^" ^"^" ^"^"", flags, aflags);
				write_file(configdir, linetext, line - 1);
			}
		}
	}
}

public Manage_Admins3()
{
	new configdir[200];
	get_configsdir(configdir, 199);

	format(configdir, 199, "%s/manager/users.ini", configdir);

	new line = 0;
	new linetextlength = 0;
	new linetext[512]

	new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];

	new Year[32];
	new Month[32];
	new Day[32];
	get_time("%Y", Year, 31);
	get_time("%m", Month, 31);
	get_time("%d", Day, 31);
	new YearsNum = str_to_num(Year);
	new MonthsNum = str_to_num(Month);
	new DaysNum = str_to_num(Day);

	if(file_exists(configdir))
	{
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue
			}

			parse(linetext, login, charsmax(login),
					password, charsmax(password),
					flags, charsmax(flags),
					aflags, charsmax(aflags),
					setinfo, charsmax(setinfo),
					setinfopw, charsmax(setinfopw),
					expiration_day, charsmax(expiration_day),
					expiration_month, charsmax(expiration_month),
					expiration_year, charsmax(expiration_year) );

			new exp_day = str_to_num(expiration_day);
			new exp_month = str_to_num(expiration_month);
			new exp_year = str_to_num(expiration_year);

			if( equali(login, "") || equali(expiration_day, "") || equali(expiration_month, "") || !isdigit(exp_day) || !isdigit(exp_month) )
				continue;

			if(equali(expiration_year, ""))
			{
				exp_year = YearsNum;
			}

			if( DaysNum >= exp_day && MonthsNum >= exp_month && YearsNum >= exp_year )
			{
				formatex(linetext, charsmax(linetext), ";^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^"", login, password, flags, aflags, setinfo, setinfopw, expiration_day, expiration_month, expiration_year);
				write_file(configdir, linetext, line - 1);
			}
		}
	}
}