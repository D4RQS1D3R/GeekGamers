#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Admine Show Motd"
#define VERSION "1.0"
#define AUTHOR "~D4rkSiD3Rs~"

#pragma compress 1

#define CharsMax(%3) sizeof %3 - 3

#define MAX_GROUPS 5

new g_groupNames[MAX_GROUPS][] = {
"---=GG=[ Owner ]=GG=---",
"---=GG=[ Diamond V.I.P ]=GG=---",
"---=GG=[ Gold V.I.P ]=GG=---",
"---=GG=[ Silver V.I.P ]=GG=---",
"---=GG=[ V.I.P ]=GG=---"
}

new g_groupFlags[MAX_GROUPS][] = {
"abcdefghijklmnopqrstu",
"abcdefijmpqrstu",
"bcdefijqrstu",
"bceijrstu",
"st"
}

new g_groupFlagsValue[MAX_GROUPS];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for(new i = 0; i < MAX_GROUPS; i++)
		g_groupFlagsValue[i] = read_flags(g_groupFlags[i]);

	register_clcmd("say /admin", "cmdWho", -1, "");
	register_clcmd("say /who", "cmdWho", -1, "");
	register_clcmd("say admin", "cmdWho", -1, "");
	register_clcmd("say who", "cmdWho", -1, "");
}

public cmdWho(id)
{
	static sPlayers[32], iNum, iPlayer;
	static sName[32], sBuffer[1024];

	static iLen;
	iLen = formatex(sBuffer, sizeof sBuffer - 1, "<body bgcolor=#000000><font color=#7be949><pre>");
	iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen,"<center><h2>[Geek~Gamers] Admins online<font color=^"red^"><B></B></font></h2></center>^n^n");

	get_players(sPlayers, iNum, "ch");

	for(new i = 0; i < MAX_GROUPS; i++)
	{
		iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen, "<center><h5><font color=^"red^"><B>%s</B>^n</font></h5></center>", g_groupNames[i]);

		for(new x = 0; x < iNum; x++)
		{
			iPlayer = sPlayers[x];

			if(get_user_flags(iPlayer) == g_groupFlagsValue[i])
			{
				get_user_name(iPlayer, sName, sizeof sName - 1);
				iLen += formatex(sBuffer[iLen], CharsMax(sBuffer) - iLen, "<center>%s^n</center>", sName);
			}
		}
	}
	show_motd(id, sBuffer, "[Geek~Gamers] Admins Online");
	return 0;
}