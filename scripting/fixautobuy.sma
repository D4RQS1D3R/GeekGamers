#include <amxmodx>
#include <amxmisc>

public plugin_init()
{
	register_plugin("autobuy fix", "1.3", "201724");
	register_clcmd("cl_autobuy","cmd_check");
	register_clcmd("cl_rebuy","cmd_check");
	register_clcmd("cl_setautobuy","cmd_check");
	register_clcmd("cl_setrebuy","cmd_check");
}
public cmd_check(id)
{
	new szCommand[512];
	new dwCount = read_argc();
	for(new i=1;i<dwCount;i++)
	{
		read_argv(i,szCommand,charsmax(szCommand));
		if(check_long(szCommand,charsmax(szCommand)))
		{
			server_cmd("kick #%d ^"[GG] You use Autobuy Bug Kick!!!^"",get_user_userid(id));
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
public check_long(c_szCommand[],c_dwLen)
{
	new m_szCommand[512]
	while(strlen(m_szCommand))
	{
		 strtok( c_szCommand, m_szCommand, charsmax( m_szCommand ), c_szCommand, c_dwLen , ' ', 1 );
		 if( strlen( m_szCommand ) > 31) return true;
	}
	return false;
}
