/////////////////////////////////////////
///				DESCRIPTION			  ///
/////////////////////////////////////////

/* Made by Filip Vilicic. */
/* Plugin link: http://forums.alliedmods.net/showthread.php?p=1060370 */

/* Special thanks to ConnorMcLeod (https://forums.alliedmods.net/member.php?u=18946)
   for granting source and permision to use his seconds left
   (http://forums.alliedmods.net/showpost.php?p=540426&postcount=5) plugin */

/* Description: Plugin that allows users to bet using chat. */
   
/* If you make translation to your language please give it to me as a reply to forum thread which
   link is mentioned above. Thanks! 								*/
/* List of missing tranlsations: */
/*
    * Turkish (tr)
    * French (fr)
    * Swedish (sv)
    * Danish (da) 
    * Poland (pl)
    * Spanish (es)
    * Brazil Portuguese (bp)
    * Finish (fi)
    * l33t (ls)
    * Bulgarian (bg)
    * Hungarian (hu)
    * Lithuania (lt)
    * Macedonian (mk)
			*/
/* There is no special license to this file except the following: */
/*
    * You must not use whole code, mod it a little and make it as your plugin! Rather post a
      suggestion to link mentioned above.
    * You can use part of a code for your plugin (WITH DIFFERENT PURPOSE!), this is sort of
      educational purpose, and that's the point of whole community and all plugins!
												*/



/////////////////////////////////////////
///		INCLUDES & PLUGIN INFO		  ///
/////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>

#define PLUGIN "Bet"
#define VERSION "2.2"
#define AUTHOR "Filip Vilicic"



/////////////////////////////////////////
///				CONSTANTS			  ///
/////////////////////////////////////////

//const strings for comparing
new const CT[3] = "ct"
new const T[2] = "t"
new const ALL[4] = "all"
new const HALF[5] = "half"
new const BET[4] = "bet"
new const ODDS[5] = "odds"
//const string for client_print
new const BET_PREFIX[9] = "[GG] %L"

//Lookup table
new const MessagesTable[15][] = {
     "TEAM_DEAD",
     "TEAM_DEAD_ODDS",
     "SAME_ODDS",
     "DIFF_ODDS",
     "BET_HELP",
     "NO_AMOUNT",
     "INVALID_TEAM",
     "NO_MONEY",
     "INVALID_AMOUNT",
     "BIGGER_BET",
     "PLAYER_ALIVE",
     "ALREADY_PLACED",
     "BET_PLACED",
     "BET_WIN",
     "BET_LOST"
};



/////////////////////////////////////////
///				VARIABLES			  ///
/////////////////////////////////////////

//variables for storing bet information
new pos = 0
static betTeam[32], betUserId[32], betAmount[32], betWin[32] //we use auth if some player exited and another came to his place

//ads
new gmsgSayText;
static const message[] = "^x04[GG] ^x03 Type ^x04 ^"bet^" ^x03 for help with betting! Type ^x04 ^"odds^" ^x03 for chances to win!"
new taskID = 1555
//end ads

//Advanced odds time calculation -> Thanks to ConnorMcLeod
new Float:g_newround_time, 
	Float:g_roundstart_time, 
	Float:g_bombplanted_time

new Float:g_freezetime,
	Float:g_roundtime,
	Float:g_c4timer
	
new g_playtime = 1

new pcvar_roundtime, pcvar_freezetime, pcvar_c4timer
//End of advanced odds time calculation


/////////////////////////////////////////
///			CVAR HANDLING			  ///
/////////////////////////////////////////

new cvar_chatEnabled //pointer to cvar handle
new bool:g_chatEnabled //stores last cvar value
#define GetChatEnabled() bool:get_pcvar_num(cvar_chatEnabled)

new cvar_adsEnabled
#define GetAdsEnabled() bool:get_pcvar_num(cvar_adsEnabled)

new cvar_aliveEnabled
#define GetAliveEnabled() bool:get_pcvar_num(cvar_aliveEnabled)  

new cvar_newOddsEnabled
#define GetNewOddsEnabled() bool:get_pcvar_num(cvar_newOddsEnabled)  



/////////////////////////////////////////
///		PLUGIN INITIALIZATION	 	  ///
/////////////////////////////////////////	

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Add your code here...
	register_clcmd("say", "sayBet", ADMIN_USER, "- displays help on using bet and takes bets")
	register_concmd("amx_advertisebet", "cmdAd", ADMIN_CVAR, " - displays bet advertising to all players")
	register_clcmd("say /advertisebet", "cmdAd", ADMIN_CVAR, " - displays bet advertising to all players")
	
	register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin") 
	
	//ads
	gmsgSayText = get_user_msgid("SayText");
	register_event("DeathMsg", "hook_death", "a") //advertises script on death (only for 1 player)
	//end ads
	
	//dictionary
	register_dictionary("bet.txt")
	
	//cvars
	cvar_chatEnabled = register_cvar("bet_chatenabled", "1")
	g_chatEnabled = GetChatEnabled()
	cvar_adsEnabled = register_cvar("bet_adsenabled", "1")
	cvar_aliveEnabled = register_cvar("bet_mustbedead", "1")
	cvar_newOddsEnabled = register_cvar("bet_oddssystem", "1")
	
	//Advanced odds time calculation -> Thanks to ConnorMcLeod
	register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w")
	register_logevent("eRoundEnd", 2, "1=Round_End")

	register_event("HLTV", "eNewRound", "a", "1=0", "2=0")
	register_logevent("eRoundStart", 2, "1=Round_Start")
	register_event("SendAudio","eSendAudio","a","2=%!MRAD_BOMBPL")

	pcvar_roundtime = get_cvar_pointer("mp_roundtime")
	pcvar_freezetime = get_cvar_pointer("mp_freezetime")
	pcvar_c4timer = get_cvar_pointer("mp_c4timer")
	//End of advanced odds time calculation
}



/////////////////////////////////////////
///				ADVERTISING			  ///
/////////////////////////////////////////

public hook_death()
{
	if (!GetAdsEnabled())
		return PLUGIN_HANDLED
	new Victim[1]
	Victim[0] = read_data(2)
	set_task(1.5, "showAd", taskID, Victim, 1)
	taskID++
	if (taskID > 1655) taskID = 1555
	return PLUGIN_HANDLED
} 

public showAd(args[])
{
	new player = args[0]
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, player);
	write_byte(player);
	write_string(message);
	message_end();
}

public cmdAd(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) //check access
		return PLUGIN_HANDLED
	
	new plist[32], playernum, player;
	get_players(plist, playernum, "c");
	for(new i = 0; i < playernum; i++)
	{
		player = plist[i];
		
		message_begin(MSG_ONE, gmsgSayText, {0,0,0}, player);
		write_byte(player);
		write_string(message);
		message_end();
	}
	return PLUGIN_HANDLED
}
//end ads



/////////////////////////////////////////
///			BET FUNCTIONS			  ///
/////////////////////////////////////////

//say hook
public sayBet(id, level, cid)
{
	new argCheck[32]
	read_argv(1,argCheck,31)
	//get args
	new argCmd[5], arg1[8], arg2[8]
	new numOfArgs = 3
	parse(argCheck, argCmd, 4, arg1, 2, arg2, 5)
	//update is chat enabled
	g_chatEnabled = GetChatEnabled()
	if(!equali(argCmd,BET)) //not bet prefix
	{
		if (equali(argCmd, ODDS))
		{
			//its odds request
			//handle odds request
			new alT, alCT
			if(!FindOdds(alT, alCT))
			{
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[1])
			} else if (alT==alCT) { //same odds
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[2], alT, alCT)
			} else { //different odds
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[3], alT, alCT)
			}
			//odds request. Test should I print?
			return whatToReturn()
		}
		//normal chat
		return PLUGIN_CONTINUE
		
	}
	if (is_user_alive(id) && GetAliveEnabled())
	{
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[10])
		return whatToReturn()
	}
	if (arg2[0] == 0){ //no amount
		numOfArgs = 2
	}
	if (arg1[0] == 0) { //no team
		numOfArgs = 1
	}
	switch (numOfArgs)
	{
	case 1:
		{
		//bet help
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[4])
		}
	case 2:
		{
		//no amount
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[5])
		}
	case 3:
		{
			//all parameters accepted lets test them...
			new TeamReturnFunc = checkTeam(arg1)
			if(TeamReturnFunc > 0)
			{
				//good team
				//value is stored in TeamReturnFunc and it will be passed to Bet function
			} else {
				//Not good team
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[6], arg1)
				return whatToReturn()
			}
			new arg2Num = str_to_num(arg2)
			new AmountFuncReturn = checkAmount(arg2)
			
			new userMoney = cs_get_user_money(id)
			if(AmountFuncReturn > 0)
			{
				//good text
				//get text and bet that amount	
				if (userMoney == 0)
				{
					client_print(id, print_chat, BET_PREFIX, id, MessagesTable[7], arg2)
					return whatToReturn()
				}
				if (AmountFuncReturn == 1)
				{
					arg2Num = userMoney
				} else if (AmountFuncReturn == 2) {
					arg2Num = userMoney/2
				} else  { //note: code should never enter this code block
					client_print(id, print_chat, BET_PREFIX, id, MessagesTable[8], arg2)
					return whatToReturn()
				}
				//do the job
				Bet(id,TeamReturnFunc,arg2Num)
			} else if (arg2Num > 0 && arg2Num < 16000) { //it isn't textual
				//good num
				if (userMoney == 0)
				{
					client_print(id, print_chat, BET_PREFIX, id, MessagesTable[7], arg2)
					return whatToReturn()
				}
				if (userMoney < arg2Num)
				{
					client_print(id, print_chat, BET_PREFIX, id, MessagesTable[9], userMoney, arg2Num)
					return whatToReturn()
				}
				//do the job
				Bet(id,TeamReturnFunc,arg2Num)
			} else {
				//bad
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[8], arg2)
			} //if block
		} //case 3
	}//switch
	return whatToReturn()
}
//end of say hook

//place bet
public Bet(id, team, amount) // 1 for T and 2 for CT
{
	new alT, alCT, possWin
	if(findPos(get_user_userid(id)) != -1)
	{
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[11])
		return whatToReturn()
	}
	if(!FindOdds(alT, alCT))
	{
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[0])
		return whatToReturn()
	}
	if(team == 1) //T
	{
		possWin = amount * alCT / alT
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[12], alT,alCT,possWin,amount)
	} else { //CT
		possWin = amount * alT / alCT
		client_print(id, print_chat, BET_PREFIX, id, MessagesTable[12], alCT,alT,possWin,amount)
	}
	new money = cs_get_user_money(id) - amount
	//set to change money after end of round
	betTeam[pos] = team
	betUserId[pos] = get_user_userid(id)
	betAmount[pos] = amount
	betWin[pos] = amount + possWin + money
	pos++
	cs_set_user_money(id, cs_get_user_money(id) - amount) //take money
	return whatToReturn()
}
//end of place bet



/////////////////////////////////////////
///			PAYOFF FUNCTIONS		  ///
/////////////////////////////////////////

//hooks on terrorist win event
public t_win()
{
	giveMoney(1)
}

//hooks on ct win event
public ct_win()
{
	giveMoney(2)
}

//gives money after round end
public giveMoney(team) // 1 for T and 2 for CT
{
	new Players[32]
	new playerCount, id, userid, position
	get_players(Players, playerCount, "c")
	for (new i=0; i<playerCount; i++)
	{
		id = Players[i]
		userid = get_user_userid(id)
		//find pos for this userid
		position = findPos(userid)
		if (position != -1) //did he placed bet?
		{
			if (betTeam[position] == team) //did he won?
			{
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[13], betWin[position] - cs_get_user_money(id))
				cs_set_user_money(id, betWin[position])
			} else {
				client_print(id, print_chat, BET_PREFIX, id, MessagesTable[14], betAmount[position])
			}
		}
	}
	for(new b=0; b<pos; b++)
	{
		betAmount[b] = 0
		betTeam[b] = 0
		betUserId[b] = 0
		betWin[b] = 0
	}
	pos = 0
}



/////////////////////////////////////////
///			ODDS FUNCTIONS			  ///
/////////////////////////////////////////

bool:FindOdds(&One, &Two)
{
	if (GetNewOddsEnabled()) return FindOddsNew(One, Two)
	
	return FindOddsOld(One, Two)
}

bool:FindOddsOld(&One, &Two)
{
	new Players[32]
	new playerCount
	new aliveT, aliveCT
	aliveT = 0
	aliveCT = 0
	get_players(Players, playerCount, "a") //get all alive players
	for (new i=0; i<playerCount; i++)
	{
		switch(cs_get_user_team(Players[i]))
		{
			case CS_TEAM_T:
			{
				aliveT++
			}
			case CS_TEAM_CT:
			{
				aliveCT++
			}
		}
	}

	One = aliveT
	Two = aliveCT
	if(aliveT == 0 || aliveCT == 0) {
		return false //one (or more) team is dead
	}
	return true //both teams are alive
}

bool:FindOddsNew(&One, &Two)
{
	new Players[32]
	new playerCount
	new Float:aliveT, Float:aliveCT
	aliveT = 0.0
	aliveCT = 0.0
	get_players(Players, playerCount, "a") //get all alive players
	for (new i=0; i<playerCount; i++)
	{
		new player = Players[i]
		new CsTeams:team = cs_get_user_team(player)
		if (team == CS_TEAM_SPECTATOR) continue
		new Float:addToOdd
		new frags, deaths
		frags = get_user_frags(player)
		deaths = get_user_deaths(player)
		if (frags > 0) {
			if (frags + deaths > 4) {
				addToOdd = floatdiv(Float:frags, Float:(deaths+1))
			} else {
				addToOdd = 1.0
			}
		} else {
			addToOdd = 0.0
		}
		new health = get_user_health(player)
		if (health < 11) {
			addToOdd = floatmul(addToOdd, 0.25)
			goto next
		}
		if (health < 21) {
			addToOdd = floatmul(addToOdd, 0.35)
			goto next
		}
		if (health < 41) {
			addToOdd = floatmul(addToOdd, 0.5)
			goto next
		}
		if (health < 61) {
			addToOdd = floatmul(addToOdd, 0.75)
			goto next
		}
		//60 < health < 81 - multiplies by 1 - do nothing
		if (health > 80) {
			addToOdd = floatmul(addToOdd, 1.25)
		}
		next:
		if (floatcmp(addToOdd, 0.5) == -1) addToOdd = 0.5
		if (floatcmp(addToOdd, 2.0) == 1) addToOdd = 2.0
		switch(team)
		{
			case CS_TEAM_T:
			{
				aliveT += addToOdd
			}
			case CS_TEAM_CT:
			{
				aliveCT += addToOdd
			}
		}//switch(team)
	}//for

	One = floatround(aliveT)
	Two = floatround(aliveCT)
	if(One == 0 || Two == 0) {
		return false //one (or more) team is dead
	}
	
	//passes floats!
	AdvancedOdds(aliveT, aliveCT)
	
	One = floatround(aliveT)
	Two = floatround(aliveCT)
	//test again since advanced odds may set this to zeros
	if(One == 0 || Two == 0) {
		return false //one (or more) team is dead
	}
	
	//If odds have common divisor (other than 1)
	new divisor = gcd(One, Two)
	if (divisor > 1) {
		One /= divisor
		Two /= divisor
	}
	
	return true //both teams are alive
}

//changes odds acording to round time, c4 time etc.
//Point of this odds changing is to prevent "cheating". Eg:
//10 Ts vs 2 CTs and 2 sec to end of round and bomb isn't even near the site
//So if you bet for CTs you get 5 times your money for nothing :)
public AdvancedOdds(&Float:TOdd, &Float:CTOdd)
{
	if (g_playtime <= 1) return //no changes if end of round or freeze time
	new remaining = get_remaining_seconds() //Thanks to ConnorMcLeod
	if (remaining <= 0) return //0 or less remaining -> no changes
	if (fm_find_ent_by_class(-1, "func_bomb_target") || fm_find_ent_by_class(-1, "info_bomb_target"))
	{
		//map has c4 site(s)
		if (g_playtime == 3)
		{
			//bomb planted
			//TODO: test how many Ts and CTs on site and if defusing started
			if (remaining < 6) //bomb is defused in 6secs with defuse kit
			{
				//Very little time (it can be defused if already started def process)
				TOdd = floatmul(TOdd, 2.0)
				return
			}
			if (remaining < 11)
			{
				//Little time -> give T more chances
				TOdd = floatmul(TOdd, 1.5)
			}
			if (remaining > 25)
			{
				//plenty of time -> give CT more chances
				CTOdd = floatmul(CTOdd, 1.2)
			}
		} else {
			//bomb not planted
			//TODO: test if bomb on site
			if (remaining < 6)
			{
				CTOdd = floatmul(CTOdd, 5.0)
				goto next
			}
			if (remaining < 11)
			{
				CTOdd = floatmul(CTOdd, 2.0)
				goto next
			}
			if (remaining < 16)
			{
				CTOdd = floatmul(CTOdd, 1.5)
				goto next
			}
			if (remaining < 31)
			{
				CTOdd = floatmul(CTOdd, 1.15)
			}
			next:
		}
	} else {
		//map doesn't have c4 site(s)
		//TODO: Make tests for hostages and other map types
		if (remaining < 6)
		{
			CTOdd = floatmul(CTOdd, 5.0)
			goto next2
		}
		if (remaining < 11)
		{
			CTOdd = floatmul(CTOdd, 2.0)
			goto next2
		}
		if (remaining < 16)
		{
			CTOdd = floatmul(CTOdd, 1.5)
			goto next2
		}
		if (remaining < 31)
		{
			CTOdd = floatmul(CTOdd, 1.15)
		}
		next2:
	}
}



/////////////////////////////////////////
///			HELPER FUNCTIONS		  ///
/////////////////////////////////////////

//checks if string represents a team (t or ct)
checkTeam(input[])
{
	if (equali(input,T))
	{
		return 1
	} else if (equali(input,CT)) {
		return 2
	}
	return 0
}

//checks if string represents textual amount (all or half)
checkAmount(input[])
{
	if (equali(input,ALL))
	{
		return 1
	} else if (equali(input, HALF)) {
		return 2
	}
	return 0
}

findPos(userid)
{
	for(new b=0; b<32; b++)
	{
		if (betUserId[b] == userid)
		{
			return b
		}
	}
	return -1
}

public whatToReturn()
{
	if(g_chatEnabled)
		return PLUGIN_CONTINUE
	
	return PLUGIN_HANDLED
}

public gcd(a, b)
{
	if (b==0)
		return a;
	
	return gcd(b, a % b)
}
//end of misc functions



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///			REMAINING TIME CALCULATION - Whole code written by: ConnorMcLeod (https://forums.alliedmods.net/member.php?u=18946)		  ///
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public eRestart() {
	g_playtime = 0
}

public eRoundEnd() {
	g_playtime = 0
}

public eNewRound() {
	g_playtime = 1

	new Float:freezetime = get_pcvar_float(pcvar_freezetime)
	if(freezetime)
	{
		g_newround_time = get_gametime()
		g_freezetime = freezetime
	}
	g_c4timer = get_pcvar_float(pcvar_c4timer)
	g_roundtime = floatmul(get_pcvar_float(pcvar_roundtime), 60.0) - 1.0
}

public eRoundStart() {
	g_playtime = 2

	g_roundstart_time = get_gametime()
}

public eSendAudio() {
	g_playtime = 3

	g_bombplanted_time = get_gametime()
}

public get_remaining_seconds() {
	switch(g_playtime)
	{
		case 0: return 0
		case 1: return floatround( ( get_gametime() - g_newround_time ) - g_freezetime , floatround_ceil )
		case 2: return floatround( g_roundtime - ( get_gametime() - g_roundstart_time ) , floatround_ceil )
		case 3: return floatround( g_c4timer - ( get_gametime() - g_bombplanted_time ) , floatround_ceil )
	}
	return 0
}