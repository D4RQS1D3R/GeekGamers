#include <amxmodx>

public plugin_init()
{
	register_plugin("[GG] Discord Connect", "1.0", "Lt.Ibrahim(Ibm)");

	register_cvar("dc_enabled", "1");
	register_cvar("dc_serverid", "pqFwH5h");
	register_cvar("dc_waittime", "3");

	register_clcmd("say /dc", "say_dc", -1, "");
	register_clcmd("say /discord", "say_dc", -1, "");
}

public say_dc(id)
{
	if(!get_cvar_num("dc_enabled"))
		return;

	static szBuffer[1440], szHeader[64];
	new svid[64];
	get_cvar_string("dc_serverid",svid,63); 
	new hostname[64];
	get_cvar_string("hostname", hostname, 63);
	new inumex = get_cvar_num("dc_waittime");
	new cmax = charsmax(szBuffer);

	new pos;
	formatex( szHeader, 63, "%s", "[Geek~Gamers] Discord Server" );
	pos += formatex(szBuffer[pos], cmax-pos, "<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'>");
	pos += formatex(szBuffer[pos], cmax-pos, "<meta http-equiv='refresh' content=^"%i; url=discord:///invite/%s^"><title>Discord Connect</title><b>%s - Discord Connect</b>", inumex, svid, hostname);
	pos += formatex(szBuffer[pos], cmax-pos, "<br><br><b>Our WebSite : </b><a href=http://geek-gamers.com>https://geek-gamers.com<a>");
	pos += formatex(szBuffer[pos], cmax-pos, "<br><b>Our Facebook Page : </b><a href=http://facebook.com/GeekGamersPage>https://facebook.com/GeekGamersPage<a><br><br>");
	pos += formatex(szBuffer[pos], cmax-pos, "Please wait until <b>%i</b> seconds (Please don't close the MOTD)<br><br>", inumex);
	pos += formatex(szBuffer[pos], cmax-pos, "If Discord is not installed on your computer, you can download it here : <br><b>https://discordapp.com/api/download?platform=win</b><br><br>");
	pos += formatex(szBuffer[pos], cmax-pos, "You can join directly our <b>discord</b> server at : <b>http://discord.gg/%s</b> (Check your console)", svid);

	console_print(id, "[Geek~Gamers] Our Discord Invite Link is : http://discord.gg/%s", svid);

	show_motd( id, szBuffer, szHeader );
}