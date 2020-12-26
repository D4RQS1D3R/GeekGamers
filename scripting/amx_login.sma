/* AMX-X Login Script v1.01

To set up this plugin please read the documentation located at: -

	http://www.amxmodx.org/forums/viewtopic.php?p=26760#26760
	
	or
	
	The readme.txt :)

Commands: -
	amx_login <user> <password> - Logs in as administrator
	amx_logout
	
Version History: -
	1.00 - 1st Release
	1.01 - Added the amx_logout command

To Do: -
	Maybe add a function to allow admins add new admins through console

I decided to make this plugin because it was requested by ThantiK
Also because I have always wanted it, but never thought of it LOL.

MUCH Thanks to Johnny got his gun

Get the latest version from: -
	http://www.amxmodx.org/forums/viewtopic.php?p=26760#26760

(c) 2003, James "rompom7" Romeril
This file is provided as is (no warranties).

*/

#include <amxmodx>
#include <amxmisc>

public login(id)
{
	new usercfg[64]
	new arguser[32], argpass[32], username[32], password[32]
	new line = 0
	new flags
	new strflags[32]
	new linetext[255], linetextlength 
	
	read_argv(1,arguser,31)
	read_argv(2,argpass,31)
	
	if((arguser[0] > 0)&&(argpass[0] > 0))
	{	
		get_customdir(usercfg, 63)
		format(usercfg, 63, "%s/amx_login/loginusers.ini", usercfg)

		if (file_exists(usercfg))
		{
			while ((line = read_file(usercfg, line, linetext, 256, linetextlength)))
			{
				if(linetext[0] == ';')
				{
					continue
				}		
				parse(linetext, username, 31, password, 31, strflags, 31)
				flags = read_flags(strflags)

				if((equal(username, arguser))&&(equal(password, argpass)))
				{
					set_user_flags(id, flags)
					new text[128]
					format(text, 128, "[AMXX AUTH] You are now logged in, with the flags: %s.", strflags)	
					client_print(id, print_console, text)
					return PLUGIN_HANDLED
				}
			}
			client_print(id, print_console, "[AMXX AUTH] Incorrect username and/or password.")
		}
	}
	return PLUGIN_HANDLED
}
public logout(id)
{
	remove_user_flags(id, -1)
	client_print(id, print_console, "[AMXX AUTH] You are now logged out of administrator status")
	return PLUGIN_HANDLED
}
public plugin_init()
{
	register_plugin("Admin Login","1.0","James Romeril")
	register_clcmd("amx_login","login",-1,"amx_login <username> <password> - Logs a player in as admin")
	register_clcmd("amx_logout","logout",-1,"amx_logout - Logs a player out of admin")
}