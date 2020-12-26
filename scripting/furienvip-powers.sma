////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------| VIP Sistem |-----------------------------------------------
//==========================================================================================================
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <fakemeta_util>
#include <hamsandwich>

#pragma compress 1

#define PLUGIN "VIP Sistem"
#define VERSION "1.0"
#define AUTHOR "sDs|Aragon*"

#define VIP_LEVEL ADMIN_LEVEL_G

native get_level(id);
native red_furien(id);
native white_human(id);

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// New Plugin |
//==========================================================================================================
//--| Expiration Date |--//
new expir_day[33] = 0, expir_month[33] = 0, expir_year[33] = 0, days_remaining[33] = 0;
//--| Menu/Power |--//
new menu, HasPower[33], bool:HasChose[33];
//--| HE Grenade |--//
new HE_Cooldown[33] = 0;
//--| GodMode |--//
new GodMode_Cooldown[33] = 0;
new GodMode_DurationCooldown[33] = 0;
//--| Drop Enemy Weapon |--//
new DropSprite, DropSprite2;
new Drop_Cooldown[33] = 0;
new const DROP_HIT_SND[] = "[GeekGamers]/Powers/DropWpn_HIT.wav";
const WPN_NOT_DROP = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4));
//--| Freeze |--//
new Freeze_Cooldown[33] = 0;
new FreezeSprite, FreezeSprite3;
new Frozen[33];
new Float:TempSpeed[33], Float:TempGravity[33]
new const FreezeSprite2[] = { "models/glassgibs.mdl" };
new const FROSTBREAK_SND[][] = { "[GeekGamers]/Powers/FrostBreak.wav" };
new const FROSTPLAYER_SND[][] = { "[GeekGamers]/Powers/FrostPlayer.wav" };
const BREAK_GLASS = 0x01;
const UNIT_SECOND = (1<<12);
const FFADE_IN = 0x0000;
//--| Drag |--//
new DRAG_MISS_SND[] = "[GeekGamers]/Powers/DragMiss.wav";
new DRAG_HIT_SND[] = "[GeekGamers]/Powers/DragHit.wav";
new Hooked[33], Unable2move[33], OvrDmg[33];
new Float:LastHook[33];
new bool: BindUse[33] = false, bool: Drag_I[33] = false;
new Drag_Cooldown[33] = 0;
new bool:Not_Cooldown[33];
new DragSprite;
//--| Teleport |--//
new TeleportSprite, TeleportSprite2;
new Teleport_Cooldown[33];
new const SOUND_BLINK[] = { "weapons/flashbang-1.wav" };
const UNIT_SEC = 0x1000;
const FFADE = 0x0000;
//--| NoRecoil |--//
new Float: cl_pushangle[33][3]
const WEAPONS_BITSUM = (1<<CSW_KNIFE|1<<CSW_HEGRENADE|1<<CSW_FLASHBANG|1<<CSW_SMOKEGRENADE|1<<CSW_C4)
//--| Cvars |--//
new CvarHECooldown, CvarHPAmount, CvarAPAmount, CvarGodModeCooldown, CvarGodModeDuration, CvarDropDistance,
CvarDropCooldown, CvarFreezeDuration, CvarFreezeCooldown, CvarFreezeDistance, CvarDragSpeed, CvarDragCooldown,
CvarDragDmg2Stop, CvarDragUnb2Move, CvarTeleportCooldown, CvarTeleportRange;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Plugin Init |
//==========================================================================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say", "handle_say");
	register_clcmd("say_team", "handle_say");
	register_clcmd("+drag","DragStart");
	register_clcmd("-drag","DragEnd");
	register_clcmd("power", "Power");
	register_clcmd("furienvip","cmdMenu");
	register_clcmd("say /furienvip","cmdMenu");
	register_clcmd("say_team /furienvip","cmdMenu");
	register_clcmd("say furienvip","cmdMenu");
	register_clcmd("say_team furienvip","cmdMenu");
	register_clcmd("vmenu","cmdMenu");
	register_clcmd("say /vmenu","cmdMenu");
	register_clcmd("say_team /vmenu","cmdMenu");
	register_clcmd("say vmenu","cmdMenu");
	register_clcmd("say_team vmenu","cmdMenu");
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	register_event("DeathMsg", "Death", "a");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	
	new weapon_name[24]
	for (new i = 1; i <= 30; i++) {
		if (!(WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23)) {
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "Weapon_PrimaryAttack_Pre")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "Weapon_PrimaryAttack_Post", 1)
		}
	}
	
	CvarHECooldown = register_cvar("gg_vip_he_cooldown", "20");				// He Cooldown
	CvarHPAmount = register_cvar("gg_vip_added_health", "50");				// Health
	CvarAPAmount = register_cvar("gg_vip_added_ap", "100");					// Armor
	CvarGodModeCooldown = register_cvar("gg_vip_godmode_cooldown", "40");	// GodMode Cooldown
	CvarGodModeDuration = register_cvar("gg_vip_godmode_duration", "4");	// GodMode Duration
	CvarDropDistance = register_cvar ("gg_vip_drop_distance", "5000");		// Distanta maxima la care poate ajunge puterea
	CvarDropCooldown = register_cvar ("gg_vip_drop_cooldown" , "20.0");		// Drop Enemy WPN Cooldown
	CvarFreezeDuration = register_cvar("gg_vip_freeze_duration", "3.0");	// Freeze Duration
	CvarFreezeCooldown = register_cvar("gg_vip_freeze_cooldown", "20.0");	// Freeze Cooldown
	CvarFreezeDistance = register_cvar ("gg_vip_freeze_distance", "5000");	// Distanta maxima la care poate ajunge puterea
	CvarDragSpeed = register_cvar("gg_vip_drag_speed", "500");				// Drag Speed
	CvarDragCooldown = register_cvar("gg_vip_drag_cooldown", "15.0");		// Drag Cooldown
	CvarDragDmg2Stop = register_cvar("gg_vip_drag_dmg2stop", "50");			// Drag Damage to stop
	CvarDragUnb2Move = register_cvar("gg_vip_drag_unable_move", "1");		// Drag Unable to move
	CvarTeleportCooldown = register_cvar("gg_vip_teleport_cooldown", "30.0");// Teleport Cooldown
	CvarTeleportRange = register_cvar("gg_vip_teleport_range", "12345");	// Teleport Range
}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Plugin CFG |
//==========================================================================================================
public plugin_cfg() {
	new iCfgDir[32], iFile[192];
	
	get_configsdir(iCfgDir, charsmax(iCfgDir));
	formatex(iFile, charsmax(iFile), "%s/VIP.cfg", iCfgDir);
		
	if(!file_exists(iFile)) {
	server_print("[VIP] VIP.cfg nu exista. Se creeaza.", iFile);
	write_file(iFile, " ", -1);
	}
	
	else {		
	server_print("[VIP] VIP.cfg sa incarcat.", iFile);
	server_cmd("exec %s", iFile);
	}
	server_cmd("sv_maxspeed 99999999.0");
	server_cmd("sv_airaccelerate 99999999.0");
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VIP Menu |
//==========================================================================================================

public GetExpirationDate(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
		return;
		
	new Days[32], Months[32], Years[32];
	get_time("%m", Months, 31);
	get_time("%d", Days, 31);
	get_time("%Y", Years, 31);
	new Day = str_to_num(Days), Month = str_to_num(Months), Year = str_to_num(Years);
	
	new name[32], authid[32], ip[32];
	get_user_name(id, name, 31);
	get_user_authid(id, authid, 31);
	get_user_ip(id, ip, 31);

	new configdir[200];
	get_configsdir(configdir, 199);
	format(configdir, 199, "%s/users.ini", configdir);

	if(file_exists(configdir))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
					
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}

				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
	}

	new configdir2[200];
	get_configsdir(configdir2, 199);
	format(configdir2, 199, "%s/auto-admins.ini", configdir2);

	if(file_exists(configdir2))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir2, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
			
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}
				
				if( expir_day[id] >= str_to_num(expiration_day) && expir_month[id] >= str_to_num(expiration_month) && expir_year[id] >= str_to_num(expiration_year) )
					continue;
				
				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
	}

	new configdir3[200];
	get_configsdir(configdir3, 199);
	format(configdir3, 199, "%s/manager/users.ini", configdir3);
	
	if(file_exists(configdir3))
	{
		new line = 0, linetextlength = 0, linetext[512];
		while(read_file(configdir3, line++, linetext, charsmax(linetext), linetextlength))
		{
			if(linetext[0] == ';' || (linetext[0] == '/' && linetext[1] == '/'))
			{
				continue;
			}

			new login[32], password[32], flags[32], aflags[32], setinfo[32], setinfopw[32], expiration_day[32], expiration_month[32], expiration_year[32];
			parse(linetext, login, charsmax(login),
				password, charsmax(password),
				flags, charsmax(flags),
				aflags, charsmax(aflags),
				setinfo, charsmax(setinfo),
				setinfopw, charsmax(setinfopw),
				expiration_day, charsmax(expiration_day),
				expiration_month, charsmax(expiration_month),
				expiration_year, charsmax(expiration_year) );
			
			if(equali(login, name) || equali(login, authid) || equali(login, ip))
			{
				if(equali(expiration_year, ""))
				{
					expiration_year = Years;
				}
				
				if( expir_day[id] >= str_to_num(expiration_day) && expir_month[id] >= str_to_num(expiration_month) && expir_year[id] >= str_to_num(expiration_year) )
					continue;
				
				expir_day[id] = str_to_num(expiration_day);
				expir_month[id] = str_to_num(expiration_month);
				expir_year[id] = str_to_num(expiration_year);

				new years_in_the_middle = expir_year[id] - Year - 1;
				new months_in_the_middle = (12 - Month) + (years_in_the_middle * 12) + expir_month[id];
				new days_in_the_middle = months_in_the_middle * 30;

				days_remaining[id] = days_in_the_middle - Day + expir_day[id];
				
				break;
			}
		}
	}
}

public cmdMenu(id)
{
	if(HasChose[id] && is_user_alive(id))
	{
		ColorChat(id,"^x03[GG][Furien-VIP]^x04 You Have Already Chosen a Power in This Round.");
		return PLUGIN_HANDLED;
	}

	if(get_user_flags(id) & ADMIN_LEVEL_H)
		GetExpirationDate(id);

	new temp[101];

	if(!expir_day[id] || !expir_month[id])
	{
		formatex( temp, 100, "\d[\yGeek~Gamers\d] \rFurien V.I.P \yMenu^n\rExpiration Date: \y-");
	}
	else
	{
		formatex( temp, 100, "\d[\yGeek~Gamers\d] \rFurien V.I.P \yMenu^n\rExpiration Date: \y%d\w/\y%d\w/\y%d (~\r%d day%s left\y)", expir_day[id], expir_month[id], expir_year[id], days_remaining[id], days_remaining[id] > 1 ? "s" : "");
	}

	menu = menu_create(temp, "VIPMenu");

	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dHe Grenade");
		menu_additem(menu, buffer, "1", 0);
	}
	else if(HasPower[id] == 1)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yHe Grenade");
		menu_additem(menu, buffer, "1", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wHe Grenade");
		menu_additem(menu, buffer, "1", 0);
	}

	if(((cs_get_user_team(id) == CS_TEAM_T && red_furien(id)) || (cs_get_user_team(id) == CS_TEAM_CT && white_human(id))) && get_level(id) >= 100)
	{
		if(!(get_user_flags(id) & VIP_LEVEL))
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\d+ %dAP", get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
		else if(HasPower[id] == 2)
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\y+ %dAP", get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
		else
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\w+ %dAP", get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
	}
	else
	{
		if(!(get_user_flags(id) & VIP_LEVEL))
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\d%dHP & + %dAP", get_pcvar_num(CvarHPAmount), get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
		else if(HasPower[id] == 2)
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\y%dHP & + %dAP", get_pcvar_num(CvarHPAmount), get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
		else
		{
			new buffer[256];
			formatex(buffer,sizeof(buffer)-1,"\w%dHP & + %dAP", get_pcvar_num(CvarHPAmount), get_pcvar_num(CvarAPAmount));
			menu_additem(menu, buffer, "2", 0);
		}
	}

	/*if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dGodMode");
		menu_additem(menu, buffer, "3", 0);
	}
	else if(HasPower[id] == 3)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yGodMode");
		menu_additem(menu, buffer, "3", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wGodMode");
		menu_additem(menu, buffer, "3", 0);
	}*/

	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dDrop Enemy Weapon");
		menu_additem(menu, buffer, "3", 0);
	}
	else if(HasPower[id] == 4)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yDrop Enemy Weapon");
		menu_additem(menu, buffer, "3", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wDrop Enemy Weapon");
		menu_additem(menu, buffer, "3", 0);
	}

	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dFreeze the Enemy");
		menu_additem(menu, buffer, "4", 0);
	}
	else if(HasPower[id] == 5)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yFreeze the Enemy");
		menu_additem(menu, buffer, "4", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wFreeze the Enemy");
		menu_additem(menu, buffer, "4", 0);
	}
	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dDrag the Enemy");
		menu_additem(menu, buffer, "5", 0);	
	}
	else if(HasPower[id] == 6)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yDrag the Enemy");
		menu_additem(menu, buffer, "5", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wDrag the Enemy");
		menu_additem(menu, buffer, "5", 0);
	}

	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dTeleport");
		menu_additem(menu, buffer, "6", 0);
	}
	else if(HasPower[id] == 7)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yTeleport");
		menu_additem(menu, buffer, "6", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wTeleport");
		menu_additem(menu, buffer, "6", 0);
	}
	if(!(get_user_flags(id) & VIP_LEVEL))
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\dNoRecoil");
		menu_additem(menu, buffer, "7", 0);
	}
	else if(HasPower[id] == 8)
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\yNoRecoil");
		menu_additem(menu, buffer, "7", 0);
	}
	else
	{
		new buffer[256];
		formatex(buffer,sizeof(buffer)-1,"\wNoRecoil");
		menu_additem(menu, buffer, "7", 0);
	}

	//menu_addblank(menu, 1); 
	//menu_additem(menu, "Exit", "MENU_EXIT"); 

	//menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_display(id, menu, 0);
	return PLUGIN_CONTINUE;
}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VIP Menu Case |
//==========================================================================================================
public VIPMenu(id, menu, item) {
	if (item == MENU_EXIT) {
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	}
	if(!(get_user_flags(id) & VIP_LEVEL)) {
	ColorChat(id,"^x03[GG][Furien-VIP]^x04 This Menu is Reserverd Only For^x03 V.I.P");
	return PLUGIN_HANDLED;
	}
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data);
	switch(key) {
	case 1: {
	if(HasPower[id] == 1) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 You Will Receive an HE Grenade once every 20 seconds.");
	remove_task(id);
	if(HE_Cooldown[id]) {
	HEShowHUD(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 1;
	HasChose[id] = true;
	}
	case 2: {
	if(HasPower[id] == 2) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}

	new hp;

	if((cs_get_user_team(id) == CS_TEAM_T && red_furien(id)) || (cs_get_user_team(id) == CS_TEAM_CT && white_human(id)))
	{
		if(get_level(id)%2 == 0)
			hp = get_pcvar_num(CvarHPAmount) - (get_level(id) / 2);
		else hp = get_pcvar_num(CvarHPAmount) - ((get_level(id) - 1) / 2);

		if( get_level(id) < 100 ) {
		ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 You Will Get^x04 + %d HP^x03 & ^x04%d AP.", hp, get_pcvar_num(CvarAPAmount)); }
		else if( get_level(id) >= 100 ) {
		ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 You Will Get^x04 + %d AP.", get_pcvar_num(CvarAPAmount)); }
		remove_task(id);
	}
	else
	{
		hp = 50;
		ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 You Will Get^x04 + %d HP^x03 & ^x04%d AP.", hp, get_pcvar_num(CvarAPAmount));
		remove_task(id);
	}

	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 2;
	set_task(0.1, "Give_HP_AP", id);
	HasChose[id] = true;
	}/*
	case 3: {
	if(HasPower[id] == 3) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 GodMode^x04 Duration:^x03 %d^x04 Cooldown;^x03 %d.", get_pcvar_num(CvarGodModeDuration), get_pcvar_num(CvarGodModeCooldown));
	ColorChat(id,"^x03[GG][Furien]^x04 To enable GodMode Press^x03 V ^x04(bind v power).");
	force_cmd(id, "bind v ^"power^"");
	remove_task(id);
	if(GodMode_Cooldown[id]) {
	GodModeShowHUD2(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 3;
	HasChose[id] = true;
	}*/
	case 3: {
	if(HasPower[id] == 4) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 Drop Enemy Weapon^x04 Cooldown;^x03 %d.", get_pcvar_num(CvarDropCooldown));
	ColorChat(id,"^x03[GG][Furien]^x04 To Throw The enemy Weapons Press The Key^x03 V ^x04(bind v power).");
	force_cmd(id, "bind v ^"power^"");
	remove_task(id);
	if(Drop_Cooldown[id]) {
	DropShowHUD(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 4;
	HasChose[id] = true;
	}
	case 4: {
	if(HasPower[id] == 5) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 Freeze the enemy^x04 Cooldown;^x03 %d.", get_pcvar_num(CvarFreezeCooldown));
	ColorChat(id,"^x03[GG][Furien]^x04 To Use^x03 Freeze^x04 Press^x03 V ^x04(bind v power).");
	force_cmd(id, "bind v ^"power^"");
	remove_task(id);
	if(Freeze_Cooldown[id]) {
	FreezeShowHUD(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 5;
	HasChose[id] = true;
	}
	case 5: {
	if(HasPower[id] == 6) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 Drag the Enemy^x04 Cooldown;^x03 %d.", get_pcvar_num(CvarDragCooldown));
	ColorChat(id,"^x03[GG][Furien]^x04 To shoot The enemy Press^x03 X ^x04(bind x +drag)");
	force_cmd(id, "bind x ^"+drag^"");
	remove_task(id);
	if(Drag_Cooldown[id]) {
	DragShowHUD(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 6;
	HasChose[id] = true;
	}
	case 6: {
	if(HasPower[id] == 7) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 Teleport.^x04 Cooldown;^x03 %d.", get_pcvar_num(CvarTeleportCooldown));
	ColorChat(id,"^x03[GG][Furien]^x04 To Use^x03 Teleport^x04 Press^x03 V ^x04(bind v power).");
	force_cmd(id, "bind v ^"power^"");
	remove_task(id);
	if(Teleport_Cooldown[id]) {
	TeleportShowHUD(id);
	}
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 7;
	HasChose[id] = true;
	}
	case 7: {
	if(HasPower[id] == 8) {
	ColorChat(id,"^x03[GG][Furien]^x04 You already Have This Power.");
	return PLUGIN_HANDLED;
	}
	ColorChat(id,"^x03[GG][Furien]^x04 Power:^x03 NoRecoil.");
	remove_task(id);
	if(HasPower[id] == 2 && get_user_health(id) > 100) {
	set_user_health(id, 100)
	set_user_armor(id, 0);
	}
	if(HasPower[id] == 3 && get_user_godmode(id)) {
	set_user_godmode(id, 0);
	}
	HasPower[id] = 8;
	HasChose[id] = true;
	}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// He Grenade |
//==========================================================================================================	
public CurWeapon(id) {
	if(get_user_flags(id) & VIP_LEVEL && !user_has_weapon(id, CSW_HEGRENADE) && !HE_Cooldown[id] && HasPower[id] == 1) {
	HE_Cooldown[id] = get_pcvar_num(CvarHECooldown);
	set_task(1.0, "HEShowHUD", id, _, _, "b");
	set_hudmessage(0, 100, 255, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && get_pcvar_num(CvarHECooldown) > 1) {
	show_hudmessage(id, "You Will Receive an HE Grenade in %d seconds",get_pcvar_num(CvarHECooldown));
	}
	if(is_user_alive(id) && get_pcvar_num(CvarHECooldown) == 1) {
	show_hudmessage(id, "You Will Receive an HE Grenade in %d seconds",get_pcvar_num(CvarHECooldown));
	}
	}
	if(get_user_flags(id) & VIP_LEVEL && get_user_team(id) != 1) {
	set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 50);
	}
	if (Frozen[id]) {
	set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
	set_pev(id, pev_maxspeed, 1.0) 
	}
	return PLUGIN_HANDLED;
	}
	
public HEShowHUD(id) {
	if (!is_user_alive(id) || user_has_weapon(id, CSW_HEGRENADE) || HasPower[id] != 1) {
	remove_task(id);
	HE_Cooldown[id] = 0;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && HE_Cooldown[id] == 1) {
	HE_Cooldown[id] --;
	show_hudmessage(id, "You Will Receive an HE Grenade in: %d seconds",HE_Cooldown[id]);
	}
	if(is_user_alive(id) && HE_Cooldown[id] > 1) {
	HE_Cooldown[id] --;
	show_hudmessage(id, "You Will Receive an HE Grenade in: %d seconds",HE_Cooldown[id]);
	}
	if(HE_Cooldown[id] <= 0) {
	show_hudmessage(id, "You Got a HE Grenade");
	ColorChat(id,"^x03[GG][Furien]^x04 You Got a HE Grenade.");
	remove_task(id);
	HE_Cooldown[id] = 0;
	give_item(id, "weapon_hegrenade");
	}
	return PLUGIN_HANDLED;
	}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Health and Armor |
//==========================================================================================================	
public Give_HP_AP(id)
{
	if(get_user_flags(id) & VIP_LEVEL && HasPower[id] == 2)
	{
		new hp;

		if((cs_get_user_team(id) == CS_TEAM_T && red_furien(id)) || (cs_get_user_team(id) == CS_TEAM_CT && white_human(id)))
		{
			if(get_level(id)%2 == 0)
				hp = get_pcvar_num(CvarHPAmount) - (get_level(id) / 2);
			else hp = get_pcvar_num(CvarHPAmount) - ((get_level(id) - 1) / 2);

			if( get_level(id) < 100 ) {
			fm_set_user_health(id, get_user_health(id) + (hp));
			cs_set_user_armor(id, get_user_armor(id) + get_pcvar_num(CvarAPAmount), CS_ARMOR_VESTHELM); }
			else if( get_level(id) >= 100 ) {
			cs_set_user_armor(id, get_user_armor(id) + get_pcvar_num(CvarAPAmount), CS_ARMOR_VESTHELM); }
		}
		else
		{
			hp = 50;
			fm_set_user_health(id, get_user_health(id) + hp);
			cs_set_user_armor(id, get_user_armor(id) + get_pcvar_num(CvarAPAmount), CS_ARMOR_VESTHELM);
		}
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GodMode |
//==========================================================================================================	
public GodModeShowHUD(id) {
	if (!is_user_alive(id) || HasPower[id] != 3) {
	remove_task(id);
	GodMode_DurationCooldown[id] = 0;
	set_user_godmode(id, 0);
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && GodMode_DurationCooldown[id] == 1) {
	GodMode_DurationCooldown[id] --;
	show_hudmessage(id, "You GodMode for: %d seconds",GodMode_DurationCooldown[id]);
	}
	if(is_user_alive(id) && GodMode_DurationCooldown[id] > 1) {
	GodMode_DurationCooldown[id] --;
	show_hudmessage(id, "You GodMode for: %d seconds",GodMode_DurationCooldown[id]);
	}
	if(GodMode_DurationCooldown[id] <= 0) {
	show_hudmessage(id, "No more GodMode.");
	ColorChat(id,"^x03[GG][Furien]^x04 No more GodMode.");
	remove_task(id);
	set_user_godmode(id, 0);
	GodMode_DurationCooldown[id] = 0;
	GodMode_Cooldown[id] = get_pcvar_num(CvarGodModeCooldown);
	set_task(1.0, "GodModeShowHUD2", id, _, _, "b");
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarGodModeCooldown) != 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarGodModeCooldown));
	}
	if(get_pcvar_num(CvarGodModeCooldown) == 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarGodModeCooldown));
	}
	return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
	}
	
public GodModeShowHUD2(id) {
	if (!is_user_alive(id) || HasPower[id] != 3) {
	remove_task(id);
	GodMode_Cooldown[id] = 0;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && GodMode_Cooldown[id] == 1) {
	GodMode_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",GodMode_Cooldown[id]);
	}
	if(is_user_alive(id) && GodMode_Cooldown[id] > 1) {
	GodMode_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",GodMode_Cooldown[id]);
	}
	if(GodMode_Cooldown[id] <= 0) {
	show_hudmessage(id, "Your Power is Back");
	ColorChat(id,"^x03[GG][Furien]^x04 You Can use Your Power again.");
	client_cmd(id, "spk fvox/power_restored.wav");
	remove_task(id);
	GodMode_Cooldown[id] = 0;
	}
	return PLUGIN_HANDLED;
	}

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Drop Enemy Weapon |
//==========================================================================================================	
public DropShowHUD(id) {
	if (!is_user_alive(id) || HasPower[id] != 4) {
	remove_task(id);
	Drop_Cooldown[id] = 0;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && Drop_Cooldown[id] == 1) {
	Drop_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Drop_Cooldown[id]);
	}
	if(is_user_alive(id) && Drop_Cooldown[id] > 1) {
	Drop_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Drop_Cooldown[id]);
	}
	if(Drop_Cooldown[id] <= 0) {
	show_hudmessage(id, "Your Power is Back");
	ColorChat(id,"^x03[GG][Furien]^x04 You Can use Your Power again.");
	client_cmd(id, "spk fvox/power_restored.wav");
	remove_task(id);
	Drop_Cooldown[id] = 0;
	}
	return PLUGIN_HANDLED;
	}
	
stock Drop(id)  {
	new wpn, wpnname[32];
	wpn = get_user_weapon(id);
	if(!(WPN_NOT_DROP & (1<<wpn)) && get_weaponname(wpn, wpnname, charsmax(wpnname))) {
	engclient_cmd(id, "drop", wpnname);
	}
	}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Freeze |
//==========================================================================================================
public Freeze(id) {
	if (!is_user_alive(id) || Frozen[id]) return;
	
	pev(id, pev_maxspeed, TempSpeed[id]) //get temp speed
	pev(id, pev_gravity, TempGravity[id]) //get temp speed
	fm_set_rendering(id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
	engfunc(EngFunc_EmitSound, id, CHAN_BODY, FROSTPLAYER_SND[random_num(0, sizeof FROSTPLAYER_SND - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
	write_short(UNIT_SECOND*1)
	write_short(floatround(UNIT_SECOND*get_pcvar_float(CvarFreezeDuration)))
	write_short(FFADE_IN)
	write_byte(0)
	write_byte(50) 
	write_byte(200)
	write_byte(100)
	message_end()
	if (pev(id, pev_flags) & FL_ONGROUND)
	set_pev(id, pev_gravity, 999999.9)
	else
	set_pev(id, pev_gravity, 0.000001)
	
	Frozen[id] = true;
	set_task(get_pcvar_float(CvarFreezeDuration), "remove_freeze", id)
	}
	
public remove_freeze(id) {
	if (!Frozen[id] || !is_user_alive(id)) return;
	
	Frozen[id] = false;
	set_task(0.2, "set_normal", id)
	engfunc(EngFunc_EmitSound, id, CHAN_BODY, FROSTBREAK_SND[random_num(0, sizeof FROSTBREAK_SND - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	fm_set_rendering(id)
	static Float:origin2F[3]
	pev(id, pev_origin, origin2F)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin2F, 0)
	write_byte(TE_BREAKMODEL) 
	engfunc(EngFunc_WriteCoord, origin2F[0]) 
	engfunc(EngFunc_WriteCoord, origin2F[1]) 
	engfunc(EngFunc_WriteCoord, origin2F[2]+24.0) 
	write_coord(16) 
	write_coord(16) 
	write_coord(16) 
	write_coord(random_num(-50, 50)) 
	write_coord(random_num(-50, 50)) 
	write_coord(25) 
	write_byte(10) 
	write_short(FreezeSprite) 
	write_byte(10) 
	write_byte(25) 
	write_byte(BREAK_GLASS) 
	message_end()
	}
public set_normal(id) {
	set_pev(id, pev_gravity, TempGravity[id])
	set_pev(id, pev_maxspeed, TempSpeed[id])
	}
	
public FreezeShowHUD(id) {
	if (!is_user_alive(id) || HasPower[id] != 5) {
	remove_task(id);
	Freeze_Cooldown[id] = 0;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && Freeze_Cooldown[id] == 1) {
	Freeze_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Freeze_Cooldown[id]);
	}
	if(is_user_alive(id) && Freeze_Cooldown[id] > 1) {
	Freeze_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Freeze_Cooldown[id]);
	}
	if(Freeze_Cooldown[id] <= 0) {
	show_hudmessage(id, "Your Power is Back");
	ColorChat(id,"^x03[GG][Furien]^x04 You Can use Your Power again.");
	client_cmd(id, "spk fvox/power_restored.wav");
	remove_task(id);
	Freeze_Cooldown[id] = 0;
	}
	return PLUGIN_HANDLED;
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Drag |
//==========================================================================================================
public DragStart(id) {
	if (get_user_flags(id) & VIP_LEVEL && HasPower[id] == 6 && !Drag_I[id]) {

	if (!is_user_alive(id)) {
	return PLUGIN_HANDLED;
	}
	if (Drag_Cooldown[id]) {
	ColorChat(id,"^x03[GG][Furien]^x04 Your Power Will Return in^x03 %d seconds.",Drag_Cooldown[id]);
	return PLUGIN_HANDLED;
	}
	new hooktarget, body;
	get_user_aiming(id, hooktarget, body);
		
	if (is_user_alive(hooktarget)) {
	if (get_user_team(id) != get_user_team(hooktarget)) {				
	Hooked[id] = hooktarget;
	emit_sound(hooktarget, CHAN_BODY, DRAG_HIT_SND, 1.0, ATTN_NORM, 0, PITCH_HIGH);
	}
	else {
	return PLUGIN_HANDLED;
	}

	if (get_pcvar_float(CvarDragSpeed) <= 0.0)
	CvarDragSpeed = 1;
			
	new parm[2];
	parm[0] = id;
	parm[1] = hooktarget;
			
	set_task(0.1, "DragReelin", id, parm, 2, "b");
	HarpoonTarget(parm);
	Drag_I[id] = true;
	Not_Cooldown[id] = false;
	if(get_pcvar_num(CvarDragUnb2Move) == 1)
	Unable2move[hooktarget] = true;
				
	if(get_pcvar_num(CvarDragUnb2Move) == 2)
	Unable2move[id] = true;
				
	if(get_pcvar_num(CvarDragUnb2Move) == 3) {
	Unable2move[hooktarget] = true;
	Unable2move[id] = true;
	}
	} 
	else {
	Hooked[id] = 33;
	NoTarget(id);
	Not_Cooldown[id] = false;
	set_task(1.0,"DragEnd",id);
	emit_sound(id, CHAN_BODY, DRAG_MISS_SND, 1.0, ATTN_NORM, 0, PITCH_HIGH);
	Drag_I[id] = true;
	}
	}
	else
	return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
	}
	
public DragEnd(id) { // drags end function
	LastHook[id] = get_gametime();
	Hooked[id] = 0;
	BeamRemove(id);
	Drag_I[id] = false;
	Unable2move[id] = false;
	if(get_user_flags(id) & VIP_LEVEL && !Not_Cooldown[id] && HasPower[id] == 6) {
	Drag_Cooldown[id] = get_pcvar_num(CvarDragCooldown);
	set_task(1.0, "DragShowHUD", id, _, _, "b");
	Not_Cooldown[id] = true;
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarDragCooldown) != 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarDragCooldown));
	}
	if(get_pcvar_num(CvarDragCooldown) == 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarDragCooldown));
	}
	}
	}
	
public DragShowHUD(id) {
	if (!is_user_alive(id) || HasPower[id] != 6) {
	remove_task(id);
	Drag_Cooldown[id] = 0;
	Not_Cooldown[id] = true;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && Drag_Cooldown[id] == 1) {
	Drag_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Drag_Cooldown[id]);
	}
	if(is_user_alive(id) && Drag_Cooldown[id] > 1) {
	Drag_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Drag_Cooldown[id]);
	}
	if(Drag_Cooldown[id] <= 0) {
	show_hudmessage(id, "Your Power is Back");
	ColorChat(id,"^x03[GG][Furien]^x04 You Can use Your Power again.");
	client_cmd(id, "spk fvox/power_restored.wav");
	remove_task(id);
	Drag_Cooldown[id] = 0;
	Not_Cooldown[id] = true;
	}
	return PLUGIN_HANDLED;
	}
	
public DragReelin(parm[]) {
	new id = parm[0];
	new victim = parm[1];

	if (!Hooked[id] || !is_user_alive(victim)) {
	DragEnd(id);
	return;
	}

	new Float:fl_Velocity[3];
	new idOrigin[3], vicOrigin[3];

	get_user_origin(victim, vicOrigin);
	get_user_origin(id, idOrigin);

	new distance = get_distance(idOrigin, vicOrigin);

	if (distance > 1) {
	new Float:fl_Time = distance / get_pcvar_float(CvarDragSpeed);

	fl_Velocity[0] = (idOrigin[0] - vicOrigin[0]) / fl_Time;
	fl_Velocity[1] = (idOrigin[1] - vicOrigin[1]) / fl_Time;
	fl_Velocity[2] = (idOrigin[2] - vicOrigin[2]) / fl_Time;
	}
	else {
	fl_Velocity[0] = 0.0;
	fl_Velocity[1] = 0.0;
	fl_Velocity[2] = 0.0;
	}

	entity_set_vector(victim, EV_VEC_velocity, fl_Velocity); //<- rewritten. now uses engine
	}
	
public TakeDamage(victim, inflictor, attacker, Float:damage) { // if take damage drag off
	if (is_user_alive(attacker) && (get_pcvar_num(CvarDragDmg2Stop) > 0)) {
	OvrDmg[victim] = OvrDmg[victim] + floatround(damage);
	if (OvrDmg[victim] >= get_pcvar_num(CvarDragDmg2Stop)) {
	OvrDmg[victim] = 0;
	DragEnd(victim);
	return HAM_IGNORED;
	}
	}

	return HAM_IGNORED;
	}
	
public HarpoonTarget(parm[]) { // set beam (ex. tongue:) if target is player

	new id = parm[0];
	new hooktarget = parm[1];

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(8);	// TE_BEAMENTS
	write_short(id);
	write_short(hooktarget);
	write_short(DragSprite);	// sprite index
	write_byte(0);	// start frame
	write_byte(0);	// framerate
	write_byte(200);	// life
	write_byte(8);	// width
	write_byte(1);	// noise
	write_byte(155);	// r, g, b
	write_byte(155);	// r, g, b
	write_byte(55);	// r, g, b
	write_byte(90);	// brightness
	write_byte(10);	// speed
	message_end();
	}

public NoTarget(id) { // set beam if target isn't player
	new endorigin[3];

	get_user_origin(id, endorigin, 3);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT); // TE_BEAMENTPOINT
	write_short(id);
	write_coord(endorigin[0]);
	write_coord(endorigin[1]);
	write_coord(endorigin[2]);
	write_short(DragSprite); // sprite index
	write_byte(0);	// start frame
	write_byte(0);	// framerate
	write_byte(200);	// life
	write_byte(8);	// width
	write_byte(1);	// noise
	write_byte(155);	// r, g, b
	write_byte(155);	// r, g, b
	write_byte(55);	// r, g, b
	write_byte(75);	// brightness
	write_byte(0);	// speed
	message_end();
	}

public BeamRemove(id) { // remove beam
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99);	//TE_KILLBEAM
	write_short(id);	//entity
	message_end();
	}
	
public PlayerPreThink(id) {
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	
	if (!is_user_alive(id)) {
	return FMRES_IGNORED
	}
	
	if (Frozen[id]) {
	set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
	set_pev(id, pev_maxspeed, 1.0) 
	}
	
	if(get_user_flags(id) & VIP_LEVEL && HasPower[id] == 6 ) { 
	if (BindUse[id]) {
	if (!(oldbutton & IN_USE) && (button & IN_USE))
	DragStart(id)
		
	if ((oldbutton & IN_USE) && !(button & IN_USE))
	DragEnd(id)
	}
	
	if (!Drag_I[id]) {
	Unable2move[id] = false
	}
		
	if (Unable2move[id] && get_pcvar_num(CvarDragUnb2Move) > 0) {
	set_pev(id, pev_maxspeed, 1.0)
	}
	}
	return PLUGIN_CONTINUE
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Teleport |
//==========================================================================================================
public TeleportShowHUD(id) {
	if (!is_user_alive(id) || HasPower[id] != 7) {
	remove_task(id);
	Teleport_Cooldown[id] = 0;
	return PLUGIN_HANDLED;
	}
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(is_user_alive(id) && Teleport_Cooldown[id] == 1) {
	Teleport_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Teleport_Cooldown[id]);
	}
	if(is_user_alive(id) && Teleport_Cooldown[id] > 1) {
	Teleport_Cooldown[id] --;
	show_hudmessage(id, "Your Power Will Return in: %d seconds",Teleport_Cooldown[id]);
	}
	if(Teleport_Cooldown[id] <= 0) {
	show_hudmessage(id, "Your Power is Back");
	ColorChat(id,"^x03[GG][Furien]^x04 You Can use Your Power again.");
	client_cmd(id, "spk fvox/power_restored.wav");
	remove_task(id);
	Teleport_Cooldown[id] = 0;
	}
	return PLUGIN_HANDLED;
	}
	
bool:teleport(id) {
	new Float:vOrigin[3], Float:vNewOrigin[3],
	Float:vNormal[3], Float:vTraceDirection[3],
	Float:vTraceEnd[3];
	
	pev(id, pev_origin, vOrigin);
	
	velocity_by_aim(id, get_pcvar_num(CvarTeleportRange), vTraceDirection);
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd);
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0);
	
	new Float:flFraction;
	get_tr2(0, TR_flFraction, flFraction);
	if (flFraction < 1.0) {
	get_tr2(0, TR_vecEndPos, vTraceEnd);
	get_tr2(0, TR_vecPlaneNormal, vNormal);
	}
	
	xs_vec_mul_scalar(vNormal, 40.0, vNormal); // do not decrease the 40.0
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin);
	
	if (is_player_stuck(id, vNewOrigin))
	return false;
	
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM);
	tele_effect(vOrigin);
	
	engfunc(EngFunc_SetOrigin, id, vNewOrigin);
	
	tele_effect2(vNewOrigin);
	
	return true;
	}

stock is_player_stuck(id, Float:originF[3]) {
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
	return true;
	
	return false;
	}

stock tele_effect(const Float:torigin[3]) {
	new origin[3];
	origin[0] = floatround(torigin[0]);
	origin[1] = floatround(torigin[1]);
	origin[2] = floatround(torigin[2]);
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+10);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+60);
	write_short(TeleportSprite);
	write_byte(0);
	write_byte(0);
	write_byte(3);
	write_byte(60);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
	}

stock tele_effect2(const Float:torigin[3]) {
	new origin[3];
	origin[0] = floatround(torigin[0]);
	origin[1] = floatround(torigin[1]);
	origin[2] = floatround(torigin[2]);
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+10);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+60);
	write_short(TeleportSprite);
	write_byte(0);
	write_byte(0);
	write_byte(3);
	write_byte(60);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+40);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(TeleportSprite2);
	write_byte(30);
	write_byte(10);
	write_byte(1);
	write_byte(50);
	write_byte(10);
	message_end();
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NoRecoil |
//==========================================================================================================
public Weapon_PrimaryAttack_Pre(entity) {
	new id = pev(entity, pev_owner)

	if (get_user_flags(id) & VIP_LEVEL && HasPower[id] == 8) {
	pev(id, pev_punchangle, cl_pushangle[id])
	return HAM_IGNORED;
	}
	return HAM_IGNORED;
	}

public Weapon_PrimaryAttack_Post(entity) {
	new id = pev(entity, pev_owner)

	if (get_user_flags(id) & VIP_LEVEL && HasPower[id] == 8) {
	new Float: push[3]
	pev(id, pev_punchangle, push)
	xs_vec_sub(push, cl_pushangle[id], push)
	xs_vec_mul_scalar(push, 0.0, push)
	xs_vec_add(push, cl_pushangle[id], push)
	set_pev(id, pev_punchangle, push)
	return HAM_IGNORED;
	}
	return HAM_IGNORED;
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Client |
//==========================================================================================================
//------| Client PutinServer |------//
public client_putinserver(id) {
	HasChose[id] = false;
	HasPower[id] = 0;
	HE_Cooldown[id] = 0;
	GodMode_Cooldown[id] = 0;
	GodMode_DurationCooldown[id] = 0;
	Drop_Cooldown[id] = 0;
	Freeze_Cooldown[id] = 0;
	Drag_Cooldown[id] = 0;
	Not_Cooldown[id] = false;
	Teleport_Cooldown[id] = 0;
	}
//------| Client Disconnect |------//
public client_disconnected(id) {  
	HasChose[id] = false;
	HasPower[id] = 0;
	HE_Cooldown[id] = 0;
	GodMode_Cooldown[id] = 0;
	GodMode_DurationCooldown[id] = 0;
	Drop_Cooldown[id] = 0;
	Freeze_Cooldown[id] = 0;
	Drag_Cooldown[id] = 0;
	Not_Cooldown[id] = false;
	Teleport_Cooldown[id] = 0;
	}
//------| Client Spawn |------//	
public Spawn(id) {
	remove_task(id);
	HasChose[id] = false;
	HE_Cooldown[id] = 0;
	GodMode_Cooldown[id] = 0;
	GodMode_DurationCooldown[id] = 0;
	Drop_Cooldown[id] = 0;
	Freeze_Cooldown[id] = 0;
	remove_freeze(id);
	DragEnd(id);
	Drag_Cooldown[id] = 0;
	Not_Cooldown[id] = false;
	Teleport_Cooldown[id] = 0;
	set_task(1.0,"Give_HP_AP",id);
	if(get_user_flags(id) & VIP_LEVEL && get_user_team(id) != 1) {
	set_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 50);
	}
	}
//------| Client Death |------//
public Death() {
	remove_task(read_data(2));
	HE_Cooldown[read_data(2)] = 0;
	GodMode_Cooldown[read_data(2)] = 0;
	GodMode_DurationCooldown[read_data(2)] = 0;
	Drop_Cooldown[read_data(2)] = 0;
	Freeze_Cooldown[read_data(2)] = 0;
	Freeze_Cooldown[read_data(2)] = 0;
	remove_freeze(read_data(2));
	
	BeamRemove(read_data(2));
	Drag_Cooldown[read_data(2)] = 0;
	if (Hooked[read_data(2)])
	DragEnd(read_data(2));
	
	
	Not_Cooldown[read_data(2)] = false;
	Teleport_Cooldown[read_data(2)] = 0;
	}
//------| Client Power |------//
public Power(id)  {
	new target, body;
	static Float:start[3];
	static Float:aim[3];

	pev(id, pev_origin, start);
	fm_get_aim_origin(id, aim);

	start[2] += 16.0; // raise
	aim[2] += 16.0; // raise
	
	if (get_user_flags(id) & VIP_LEVEL && is_user_alive(id) && HasPower[id] == 3 && !GodMode_DurationCooldown[id]) {

	if (GodMode_Cooldown[id]) {
	ColorChat(id,"^x03[GG][Furien]^x04 Your Power Will Return in^x03 %d seconds.",GodMode_Cooldown[id]);
	return PLUGIN_CONTINUE;
	}
	set_user_godmode(id, 1);
	GodMode_DurationCooldown[id] = get_pcvar_num(CvarGodModeDuration)
	set_task(1.0, "GodModeShowHUD", id, _, _, "b");
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarGodModeDuration) != 1) {
	show_hudmessage(id, "You GodMode for: %d seconds",get_pcvar_num(CvarGodModeDuration));
	}
	if(get_pcvar_num(CvarGodModeDuration) == 1) {
	show_hudmessage(id, "You GodMode for: %d seconds",get_pcvar_num(CvarGodModeDuration));
	}
	return PLUGIN_HANDLED;
	}

	
	if (get_user_flags(id) & VIP_LEVEL && is_user_alive(id) && HasPower[id] == 4) {
	
	if (Drop_Cooldown[id]) {
	ColorChat(id,"^x03[GG][Furien]^x04 Your Power Will Return in^x03 %d seconds.",Drop_Cooldown[id]);
	return PLUGIN_CONTINUE;
	}
	get_user_aiming (id, target, body, CvarDropDistance);
	if(is_user_alive(target) && get_user_team(id) != get_user_team(target)) {
	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, aim[0]);
	engfunc(EngFunc_WriteCoord, aim[1]);
	engfunc(EngFunc_WriteCoord, aim[2]);
	write_short(DropSprite2);
	write_byte(10);
	write_byte(30);
	write_byte(4);
	message_end();
		
	emit_sound(id, CHAN_WEAPON, DROP_HIT_SND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	Drop(target);
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(230);
	write_byte(0);
	write_byte(0);
	write_byte(50);
	message_end();
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, target);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(230);
	write_byte(0);
	write_byte(0);
	write_byte(50);
	message_end();
	}	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0);
	engfunc(EngFunc_WriteCoord,start[0]);
	engfunc(EngFunc_WriteCoord,start[1]);
	engfunc(EngFunc_WriteCoord,start[2]);
	engfunc(EngFunc_WriteCoord,aim[0]);
	engfunc(EngFunc_WriteCoord,aim[1]);
	engfunc(EngFunc_WriteCoord,aim[2]);
	write_short(DropSprite); // sprite index
	write_byte(0); // start frame
	write_byte(30); // frame rate in 0.1's
	write_byte(20); // life in 0.1's
	write_byte(50); // line width in 0.1's
	write_byte(50); // noise amplititude in 0.01's
	write_byte(0); // red
	write_byte(100); // green
	write_byte(0); // blue
	write_byte(100); // brightness
	write_byte(50); // scroll speed in 0.1's
	message_end();
	Drop_Cooldown[id] = get_pcvar_num(CvarDropCooldown);
	set_task(1.0, "DropShowHUD", id, _, _, "b");
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarDropCooldown) != 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarDropCooldown));
	}
	if(get_pcvar_num(CvarDropCooldown) == 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarDropCooldown));
	}
	return PLUGIN_HANDLED;
	}

	else if (get_user_flags(id) & VIP_LEVEL && is_user_alive(id) && HasPower[id] == 5) {
	if (Freeze_Cooldown[id]) {
	ColorChat(id,"^x03[GG][Furien]^x04 Your Power Will Return in^x03 %d seconds.",Freeze_Cooldown[id]);
	return PLUGIN_CONTINUE;
	}
	get_user_aiming (id, target, body, CvarFreezeDistance);
	if(is_user_alive(target) && get_user_team(id) != get_user_team(target)) {	
	Freeze(target);
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(0);
	write_byte(100);
	write_byte(200);
	write_byte(50);
	message_end();
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, target);
	write_short(1<<10);
	write_short(1<<10);
	write_short(0x0000);
	write_byte(0);
	write_byte(100);
	write_byte(200);
	write_byte(50);
	message_end();
	}	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0);
	engfunc(EngFunc_WriteCoord,start[0]);
	engfunc(EngFunc_WriteCoord,start[1]);
	engfunc(EngFunc_WriteCoord,start[2]);
	engfunc(EngFunc_WriteCoord,aim[0]);
	engfunc(EngFunc_WriteCoord,aim[1]);
	engfunc(EngFunc_WriteCoord,aim[2]);
	write_short(FreezeSprite3); // sprite index
	write_byte(0); // start frame
	write_byte(30); // frame rate in 0.1's
	write_byte(20); // life in 0.1's
	write_byte(50); // line width in 0.1's
	write_byte(50); // noise amplititude in 0.01's
	write_byte(0); // red
	write_byte(100); // green
	write_byte(200); // blue
	write_byte(100); // brightness
	write_byte(50); // scroll speed in 0.1's
	message_end();
	Freeze_Cooldown[id] = get_pcvar_num(CvarFreezeCooldown);
	set_task(1.0, "FreezeShowHUD", id, _, _, "b");
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarFreezeCooldown) != 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarFreezeCooldown));
	}
	if(get_pcvar_num(CvarFreezeCooldown) == 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarFreezeCooldown));
	}
	return PLUGIN_HANDLED;
	}
	else if  (get_user_flags(id) & VIP_LEVEL && is_user_alive(id) && HasPower[id] == 7) {	
	if (Teleport_Cooldown[id]) {
	ColorChat(id,"^x03[GG][Furien]^x04 Your Power Will Return in^x03 %d seconds.",Teleport_Cooldown[id]);
	return PLUGIN_CONTINUE;
	}
	if (teleport(id)) {
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM);
	remove_task(id);
	Teleport_Cooldown[id] = get_pcvar_num(CvarTeleportCooldown);
	set_task(1.0, "TeleportShowHUD", id, _, _, "b");
	set_hudmessage(0, 100, 200, 0.05, 0.60, 0, 1.0, 1.1, 0.0, 0.0, -11);
	if(get_pcvar_num(CvarTeleportCooldown) != 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarTeleportCooldown));
	}
	if(get_pcvar_num(CvarTeleportCooldown) == 1) {
	show_hudmessage(id, "Your Power Will Return in: %d seconds",get_pcvar_num(CvarTeleportCooldown));
	}
	return PLUGIN_HANDLED;
	}
	else {
	Teleport_Cooldown[id] = 0;
	ColorChat(id, "^x03[GG][Furien]^x04 Position Teleportation is Invalid.");
	return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VIP's Online |
//==========================================================================================================
public print_adminlist(user) {
	new adminnames[33][32];
	new message[256];
	new id, count, x, len;
	
	for(id = 1 ; id <= get_maxplayers() ; id++)
	if(is_user_connected(id))
	if(get_user_flags(id) & VIP_LEVEL)
	get_user_name(id, adminnames[count++], 31);

	len = format(message, 255, "^x04[GG] VIP ONLINE: ");
	if(count > 0) {
	for(x = 0 ; x < count ; x++) {
	len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"");
	if(len > 96) {
	print_message(user, message);
	len = format(message, 255, "^x04 ");
	}
	}
	print_message(user, message);
	}
	else {
	len += format(message[len], 255-len, "No VIP online.");
	print_message(user, message);
	}
	}
print_message(id, msg[]) {
	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id);
	write_byte(id);
	write_string(msg);
	message_end();
	}
	
public handle_say(id) {
	new said[192];
	read_args(said,192);
	if(contain(said, "/vips") != -1)
	set_task(0.1,"print_adminlist",id);
	return PLUGIN_CONTINUE;
	}
	
stock force_cmd( id , const szText[] , any:... )
{
	#pragma unused szText

	if( id == 0 || is_user_connected( id ) )
	{
		new szMessage[ 256 ];

		format_args( szMessage ,charsmax( szMessage ) , 1 );

		message_begin( id == 0 ? MSG_ALL : MSG_ONE, 51, _, id )
		write_byte( strlen( szMessage ) + 2 )
		write_byte( 10 )
		write_string( szMessage )
		message_end()
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Color Chat |
//==========================================================================================================
stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
 
	replace_all(msg, 190, "^x04", "^4");
	replace_all(msg, 190, "^x01", "^1");
	replace_all(msg, 190, "^x03", "^3");
 
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
	for(new i = 0; i < count; i++) {
	if(is_user_connected(players[i])) {
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
	write_byte(players[i]);
	write_string(msg);
	message_end();
	}
	}
	}
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Plugin Precache |
//==========================================================================================================
public plugin_precache() { 
	precache_sound(DROP_HIT_SND);
	
	DropSprite = precache_model("sprites/lgtning.spr");
	DropSprite2 = precache_model("sprites/dropwpnexp.spr");
	
	precache_sound(DRAG_HIT_SND);
	precache_sound(DRAG_MISS_SND);
	DragSprite = precache_model("sprites/zbeam4.spr");
	
	
	new i;
	for (i = 0; i < sizeof FROSTBREAK_SND; i++)
	engfunc(EngFunc_PrecacheSound, FROSTBREAK_SND[i]);
	for (i = 0; i < sizeof FROSTPLAYER_SND; i++)
	engfunc(EngFunc_PrecacheSound, FROSTPLAYER_SND[i]);
	FreezeSprite = engfunc(EngFunc_PrecacheModel, FreezeSprite2);
	FreezeSprite3 = precache_model("sprites/laserbeam.spr");
	
	TeleportSprite = precache_model( "sprites/shockwave.spr");
	TeleportSprite2 = precache_model( "sprites/blueflare2.spr");
	}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
