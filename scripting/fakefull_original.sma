/* AMX Mod X script.
*
*   FakeFull (fakefull_original.sma)
*   Copyright (C) 2003-2006  Freecode/JTP10181
*
*   This program is free software; you can redistribute it and/or
*   modify it under the terms of the GNU General Public License
*   as published by the Free Software Foundation; either version 2
*   of the License, or (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*   In addition, as a special exception, the author gives permission to
*   link the code of this program with the Half-Life Game Engine ("HL
*   Engine") and Modified Game Libraries ("MODs") developed by Valve,
*   L.L.C ("Valve"). You must obey the GNU General Public License in all
*   respects for all of the code used other than the HL Engine and MODs
*   from Valve. If you modify this file, you may extend this exception
*   to your version of the file, but you are not obligated to do so. If
*   you do not wish to do so, delete this exception statement from your
*   version.
*
****************************************************************************
*
*   Version 1.7.6				Date: 08/09/2006
*
*   Original Author: Freecode		freecode@hotmail.com
*   Current Author: JTP10181		jtp@jtpage.net
*
****************************************************************************
*
*	Based on OLO's FakeFull metamod plugin. Fake clients
*	connect to the server when its empty. Everytime someone
*	joins and there is no more spots left for another person
*	one fake client is removed. When the server is empty
*	and FakeFull is on Automatic mode it will add
*	a fake client. Once the # of fake clients and real players
*	equals to ff_players it will stop.
*
*  Commands:
*
*	amx_addfake <# | @FILL>			Add # of bots or fill the server
*
*	amx_removefake <# | @ALL>		Remove # of bots or remove all
*
*
*  CVARs: Paste the following into your amxx.cfg to change defaults.
*		You must uncomment cvar lines for them to take effect
*
****************************************************************************
*  CVAR CONFIG BEGIN
****************************************************************************

// ******************  FakeFull Settings  ******************

//Turns Automatic mode on.
//ff_players must be set higher then 0.
//<1 = ON || 0 = OFF>
//ff_automode 0

//Minimal number of fake and real clients on the server.
//Fake clients will be kicked so that the total players on the
//Server equals this number.  If there are more players than this
//All the fake players will be gone. Do NOT set this at or aboive
//your max player count or no one will be able to join
//REQUIRED to be above 0 for Automatic mode.
//ff_players 2

//Delay between each fake client joins/leaves.
//REQUIRED to be above 0 for Automatic mode and regular bot add.
//ff_delay 1

****************************************************************************
*  CVAR CONFIG END
****************************************************************************
*
*  Setup for Automatic Mode:
*
*	Set ff_players to the number of fake clients you want in server at max.
*	Turn on ff_automode.
*
*  Changelog:
*
*  v1.7.6 - JTP10181 - 08/09/06
*	- Set team to UNASSIGNED for CS so they wont join teams
*
*  v1.7.5 - JTP10181 - 08/03/06
*	- Got rid of need for engine module
*	- Upgraded to pCVARS
*	- Finally put an end to fakes ending up with models and being seen as ghost players
*
*  v1.7.4 - JTP10181 - 07/01/06
*	- Fixed bug in team checking causing fakes on team "-1" to get kicked
*	- Upgraded to new file natives
*
*  v1.7.3 - JTP10181 - 4/21/06
*	- Added code to kick bots if they get on a team somehow
*
*  v1.7.2 - JTP10181
*	- Added new line of code per suggestion on a forum post, to prevent crashing
*
*  v1.7.1 - JTP10181
*	- Cleaned up massive code, hopefully no more crashing
*	- Renamed CVARS and commands
*	- Added feature to randomly add frags to the fake clients
*
*  v1.7 - JTP10181
*	- Ported fake client creation to new method using AMXX. No longer needs module.
*	- Changed bot name file to botnames.txt
*
*  v1.6.1 - JTP
*	- Fixed bug that could get server stuck in an infinite loop
*	- Fixed bug that caused dupe names sometimes
*
*  v1.6 - JTP
*	- Ported to AMXx
*	- Fixed mem leak/overflow bug caused by some of my code
*	- Fixed bugs where it was not removing the fakes automatically
*	- Rewrote a lot of the createBot function to make it more effecient
*		and less likely to cause mem overflows from looping
*	- Fixed bugs when setting the max_names higher.
*	- Must have the botnames.cfg now, no defaults are embedded in the script
*	- Fixed bug where playnames array was 1000 length for the names, made plugin huge.
*
*  v1.5
*	- Custom names and reading names from botnames.cfg
*
*  Below v1.6 was maintained by FreeCode
*
****************************************************************************/
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <fun>

new const Plugin[] = "FakeFull Original"
new const Version[] = "1.7.6"
new const Author[] = "JTP10181/Freecode/AssKicR"

#define MAX_NAMES 256

new bool:is_user_ffbot[33]
new bool:checkingStatus = false
new bool:changingBots = false
new botCount = 0, namesread = 0
new namesToUse[MAX_NAMES][33]
new pDelay, pAuto, pPlayers

public plugin_init()
{
	register_plugin(Plugin,Version,Author)
	pAuto = register_cvar("ff_automode","0")
	pPlayers = register_cvar("ff_players","2")
	pDelay = register_cvar("ff_delay","1")
	register_concmd("amx_addfake","botadd",ADMIN_BAN,"<# | @FILL> - add this many bots")
	register_concmd("amx_removefake","botremove",ADMIN_BAN,"<# | @ALL> - remove this many bots")
	set_task(10.0,"ServerStatus",0,_,_,"b")
	ReadNames()

	//Setup jtp10181 CVAR
	new cvarString[256], shortName[16]
	copy(shortName,15,"ff")

	register_cvar("jtp10181","",FCVAR_SERVER|FCVAR_SPONLY)
	get_cvar_string("jtp10181",cvarString,255)

	if (strlen(cvarString) == 0) {
		formatex(cvarString,255,shortName)
		set_cvar_string("jtp10181",cvarString)
	}
	else if (contain(cvarString,shortName) == -1) {
		format(cvarString,255,"%s,%s",cvarString, shortName)
		set_cvar_string("jtp10181",cvarString)
	}
}

public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}

public module_filter(const module[])
{
	if (!cstrike_running() && equali(module, "cstrike")) {
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public native_filter(const name[], index, trap)
{
	if (!trap) return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public botadd(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED

	new arg[10], botNum

	if (read_argc() == 1) botNum = 1
	else {
		read_argv(1,arg,9)
		if (equali(arg,"@FILL")) botNum = get_maxplayers() - get_playersnum(1)
		else botNum = str_to_num(arg)
	}

	if (botNum <=0 || botNum > get_maxplayers() - get_playersnum(1)) {
		console_print(id,"[AMXX] Invalid number of bots to add")
		return PLUGIN_HANDLED
	}

	new Float:botDelay = get_pcvar_float(pDelay)
	console_print(id,"[AMXX] Adding %d bots with %.1f second delay for each",botNum,botDelay)
	set_task(botDelay,"createBot",0,_,_,"a",botNum)
	set_task(botDelay * (botNum + 1),"doneChanging")
	changingBots = true

	return PLUGIN_HANDLED
}

public botremove(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) return PLUGIN_HANDLED

	new arg[10], botNum

	if (read_argc() == 1) botNum = 1

	else {
		read_argv(1,arg,9)
		if (equali(arg,"@ALL")) botNum = botCount
		else botNum = str_to_num(arg)
	}

	if (botNum <=0 || botNum > botCount) {
		console_print(id,"[AMXX] Invalid number of bots to remove")
		return PLUGIN_HANDLED
	}

	new Float:botDelay = get_pcvar_float(pDelay)
	console_print(id,"[AMXX] Removing %d bots with %.1f second delay for each",botNum,botDelay)
	set_task(botDelay,"removeBot",0,_,_,"a",botNum)
	set_task(botDelay * (botNum + 1),"doneChanging")
	changingBots = true

	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	//Don't want anyone going invisible on us
	set_pev(id, pev_rendermode, kRenderNormal)

	is_user_ffbot[id] = false
	ServerStatus()
}

public client_disconnect(id)
{
	is_user_ffbot[id] = false
	ServerStatus()
}

public createBot()
{
	new bool:UseAnotherName
	new BotName[33], UserNames[33][33]
	new name_rand = random_num(0,namesread - 1)
	new endLoop = name_rand - 1
	if (endLoop < 0) endLoop = namesread - 1

	//Save all the usernames so we dont have to keep getting them all
	for (new x = 1; x <= 32; x++) {
		if (!is_user_connected(x)) continue
		get_user_name(x,UserNames[x],32)
	}

	do {
		UseAnotherName = false
		copy(BotName,32,namesToUse[name_rand])

		for (new id = 1; id <= 32; id++) {

			if (!is_user_connected(id)) continue

			if (equali(BotName,UserNames[id])) {
				UseAnotherName = true

				if (name_rand == endLoop) {
					UseAnotherName = false
					log_amx("ERROR: Ran out of names to use, please add more to botnames.ini")
				}

				name_rand++
				if (name_rand > namesread - 1) {
					name_rand = 0
				}
				break
			}
		}
	} while(UseAnotherName)

	new Bot = engfunc(EngFunc_CreateFakeClient, BotName)

	if (Bot > 0) {
		//Supposed to prevent crashes?
		dllfunc(MetaFunc_CallGameEntity, "player", Bot)
		set_pev(Bot, pev_flags, FL_FAKECLIENT)

		//Make Sure they have no model
		set_pev(Bot, pev_model, "")
		set_pev(Bot, pev_viewmodel2, "")
		set_pev(Bot, pev_modelindex, 0)

		//Make them invisible for good measure
		set_pev(Bot, pev_renderfx, kRenderFxNone)
		set_pev(Bot, pev_rendermode, kRenderTransAlpha)
		set_pev(Bot, pev_renderamt, 0.0)

		//Set the team if we need to for this mod
		set_team(Bot)

		is_user_ffbot[Bot] = true
		botCount++
	}
}

public removeBot()
{
	for(new id = 1; id <= 32; id++) {
		if (is_user_ffbot[id]) {
			server_cmd("kick #%d",get_user_userid(id))
			is_user_ffbot[id] = false
			botCount--
			return
		}
	}
}

public doneChanging()
{
	changingBots = false
}

public ServerStatus()
{
	if ( !get_pcvar_num(pAuto) ) return
	if ( checkingStatus || changingBots ) return

	checkingStatus = true
	new rnd

	if (botCount > 0) {
		for (new id = 1; id <= 32; id++) {

			if (!is_user_connected(id)) continue
			if (!is_user_ffbot[id]) continue
			rnd = random_num(1,100)
			if (rnd <= 10) {
				set_user_frags(id,get_user_frags(id) + 1)
			}

			//Set the team if we need to for this mod
			set_team(id)

			if (get_user_team(id) > 0) {
				server_cmd("kick #%d",get_user_userid(id))
				is_user_ffbot[id] = false
				botCount--
			}
		}
	}

	new pnum = get_playersnum(1)
	new maxplayers = get_maxplayers()
	new ff_players = get_pcvar_num(pPlayers)
	new Float:botDelay = get_pcvar_float(pDelay)

	if (ff_players > maxplayers - 2) {
		ff_players = maxplayers - 2
		set_pcvar_num(pPlayers, ff_players)
	}

	if (botDelay <= 0.0 ) {
		log_amx("ERROR: Please set ff_delay to a number higher than 0")
	}

	else if (ff_players > pnum) {
		new addnum = ff_players - pnum
		set_task(botDelay,"createBot",0,_,_,"a",addnum)
		set_task(botDelay * (addnum + 1),"doneChanging")
		changingBots = true
	}

	else if (ff_players < pnum) {
		new removenum = pnum - ff_players
		removenum = min(removenum, botCount)

		if (removenum > 0) {
			set_task(botDelay,"removeBot",0,_,_,"a",removenum)
			set_task(botDelay * (removenum + 1),"doneChanging")
			changingBots = true
		}
	}

	checkingStatus = false
}

public set_team(BotID)
{
	if (cstrike_running()) {
		cs_set_user_team(BotID, CS_TEAM_UNASSIGNED)
	}
}

public ReadNames() {

	new botnames_file[128]
	get_configsdir(botnames_file, 63)
	format(botnames_file,127,"%s/botnames.txt",botnames_file)

	new botnames = fopen(botnames_file,"r")

	if (botnames) {
		new data[35]

		while(!feof(botnames)) {

			if (namesread >= MAX_NAMES) {
				log_amx("MAX_NAMES exceeded, not all fake client names were able to load")
				break
			}

			fgets(botnames, data, 34)
			trim(data)

			new len = strlen(data)
			if (len <= 0) return
			if (data[len]-1 == '^n') data[--len] = 0

			if (equal(data,"") || equal(data,"#",1)) continue

			copy(namesToUse[namesread],32,data)
			namesread++
		}

		fclose(botnames)
	}
	else {
		new failmsg[128]
		formatex(failmsg,128,"Unable to read file ^"%s^", it is required to load bot names from", botnames_file)
		log_amx(failmsg)
		set_fail_state(failmsg)
	}
}