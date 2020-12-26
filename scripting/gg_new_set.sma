#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("[GG] New Setinfo", "2.0", "~D4rkSiD3Rs~");
}

public client_connect(id)
{
	set_task(0.1, "Check_Setinfo", id);
}

public Check_Setinfo(id)
{
	new name[32]
	get_user_name(id, name, 31)

	new authid[32]
	get_user_authid(id, authid, 31)

	new ip[32]
	get_user_ip(id, ip, 31)

	new line = 0
	new linetext[255], linetextlength
	new adminlogin[32], adminpassword[32], accessflags[32], flags[32], newsetinfo[32], newpassword[32]

	new configsDir[64]
	get_configsdir(configsDir, charsmax(configsDir))
	format(configsDir, 63, "%s/users.ini", configsDir)

	if(file_exists(configsDir))
	{
		while((line = read_file(configsDir, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, adminpassword, 31, accessflags, 31, flags, 31, newsetinfo, 31, newpassword, 31)

			new password[50];
			get_user_info(id, newsetinfo, password, charsmax(password));

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) && (equali(newsetinfo, "") || equali(newpassword, "")) )
			{
				return PLUGIN_HANDLED
			}

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) )
			{
				force_cmd(id, "setinfo %s ^"^"", newsetinfo);

				if( equali(newpassword, password) )
				{
					return PLUGIN_HANDLED
				}

				if( containi(accessflags, "c") != -1 && !(containi(accessflags, "o") != -1) )
				{
					kick(id);
				}
				else
				if( containi(accessflags, "o") != -1 )
				{
					kick2(id);
				}
			}
		}
	}

	new configsDir2[64]
	get_configsdir(configsDir2, charsmax(configsDir2))
	format(configsDir2, 63, "%s/auto-admins.ini", configsDir2)

	if(file_exists(configsDir2))
	{
		while((line = read_file(configsDir2, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, adminpassword, 31, accessflags, 31, flags, 31, newsetinfo, 31, newpassword, 31)

			new password[50];
			get_user_info(id, newsetinfo, password, charsmax(password));

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) && (equali(newsetinfo, "") || equali(newpassword, "")) )
			{
				return PLUGIN_HANDLED
			}

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) )
			{
				force_cmd(id, "setinfo %s ^"^"", newsetinfo);

				if( equali(newpassword, password) )
				{
					return PLUGIN_HANDLED
				}

				if( containi(accessflags, "c") != -1 && !(containi(accessflags, "o") != -1) )
				{
					kick(id);
				}
				else
				if( containi(accessflags, "o") != -1 )
				{
					kick2(id);
				}
			}
		}
	}

	new configsDir3[64]
	get_configsdir(configsDir3, charsmax(configsDir3))
	format(configsDir3, 63, "%s/manager/users.ini", configsDir3)

	if(file_exists(configsDir3))
	{
		while((line = read_file(configsDir3, line, linetext, 256, linetextlength)))
		{
			if(linetext[0] == ';')
			{
				continue
			}

			parse(linetext, adminlogin, 31, adminpassword, 31, accessflags, 31, flags, 31, newsetinfo, 31, newpassword, 31)

			new password[50];
			get_user_info(id, newsetinfo, password, charsmax(password));

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) && (equali(newsetinfo, "") || equali(newpassword, "")) )
			{
				return PLUGIN_HANDLED
			}

			if( (equali(adminlogin, ip) || equali(adminlogin, authid) || equali(adminlogin, name)) )
			{
				force_cmd(id, "setinfo %s ^"^"", newsetinfo);

				if( equali(newpassword, password) )
				{
					return PLUGIN_HANDLED
				}

				if( containi(accessflags, "c") != -1 && !(containi(accessflags, "o") != -1) )
				{
					kick(id);
				}
				else
				if( containi(accessflags, "o") != -1 )
				{
					kick2(id);
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public kick(id)
{
	server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "NO_ENTRY");
}

public kick2(id)
{
	server_cmd("kick #%d ^"Invalid NickName!^"", get_user_userid(id), id);
}

stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	new szMessage[ 256 ];

	format_args( szMessage ,charsmax( szMessage ) , 1 );

	message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
	write_byte( strlen( szMessage ) + 2 )
	write_byte( 10 )
	write_string( szMessage )
	message_end()
}