#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <engine>
#include <colorchat>

#define PLUGIN "Vip System"
#define VERSION "0.2"
#define AUTHOR "Hades Ownage"

#define ACCES "ADMIN_LEVEL_G"
#define ACCES_LEVEL ADMIN_LEVEL_G

#define MAX_HEALTH 250

#define COLOR "^x04"
#define CONTACT "Numele de contact!"

#define MAX_PLAYERS 32

#define FREQUENCY 30.0

new maxplayers
new gmsgSayText
new g_ScoreAttrib;

new limita[33];

new bool:recoil[33];
new recoiltime;

new gViata, gArmura, gHE, gGodModeTime, gTeleportTime;
new gHasGodMode[32];

new checkCount[33];
new blinkSpot[33][3];
new origBlinkSpot[33][3];
new g_lastPosition[33][3];

new gHealth_add, gHealth_max;

new mpd, mkb, mhb;

new Timer;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    gHealth_add = register_cvar("vip_hp_add", "5")
    gHealth_max = register_cvar("vip_hp_max", "255")

    register_event("DeathMsg", "VIP_KILL", "ae")
    register_event("CurWeapon", "CurWeapon", "be", "1=1")
    RegisterHam(Ham_Spawn, "player", "SetSomeThing", 1)
    register_logevent("round_start", 2, "1=Round_Start")
    RegisterHam( Ham_TraceAttack, "player", "fw_TraceAttack" );
    register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")
    register_event("DeathMsg", "hook_death", "a", "1>0")

    register_clcmd ("say /vip" , "vipinfo" , -1);
    register_clcmd ("say_team /vip" , "vipinfo" , -1);
    register_clcmd("say /furienvip", "check_acces");
    register_clcmd("say /vips", "print_adminlist");

    maxplayers = get_maxplayers()
    gmsgSayText = get_user_msgid("SayText")

    register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER)

    g_ScoreAttrib = get_user_msgid("ScoreAttrib");

    gViata = register_cvar("vip_hp", "255");
    gArmura = register_cvar("vip_armour", "255");
    gHE = register_cvar("vip_he_nr", "3");

    mpd = register_cvar("money_per_damage","2")
    mkb = register_cvar("money_kill_bonus","200")
    mhb = register_cvar("money_hs_bonus","400")

    gGodModeTime = register_cvar("vip_god_time", "10.0");
    gTeleportTime = register_cvar("vip_teleport_time", "10.0");

    recoiltime = register_cvar("amx_recoil_time", "10.0")

    new iEnt = create_entity("info_target")
    entity_set_string(iEnt, EV_SZ_classname, "nade_giver")
    entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0)
    register_think("nade_giver", "task_give_nades")

    return PLUGIN_CONTINUE
}

public client_connect(id)
{
    client_cmd( id, "bind p ^"say /furienvip^"" );
}

public round_start(id)
{
    new iPlayers[32]
    new iNum
    
    get_players( iPlayers, iNum )
    
    for( new i = 0; i < iNum; i++ )
    {
        limita[iPlayers[i]] = 0;
    }
}

public Damage(id)
{
	new weapon, hitpoint, attacker = get_user_attacker(id,weapon,hitpoint)
	if(attacker<=maxplayers && is_user_alive(attacker) && attacker!=id)
	if (get_user_flags(attacker) & ACCES_LEVEL) 
	{
		new money = read_data(2) * get_pcvar_num(mpd)
		if(hitpoint==1) money += get_pcvar_num(mhb)
		cs_set_user_money(attacker,cs_get_user_money(attacker) + money)
	}
}

public death_msg()
{
	if(read_data(1)<=maxplayers && read_data(1) && read_data(1)!=read_data(2)) cs_set_user_money(read_data(1),cs_get_user_money(read_data(1)) + get_pcvar_num(mkb) - 300)
}

public VIP_KILL()
{
    new killer = read_data(1) 
    new victim = read_data(2) 
    
    if(!killer || !victim)
        return

    if(get_user_flags(killer) & ACCES_LEVEL) {
        if(killer && is_user_alive(killer)) {
            if(cs_get_user_team(victim) == CS_TEAM_T) {
                if(get_user_health(killer) < 200 - 10) {
                    set_user_health(killer, get_user_health(killer) + 10)
                }

                if(cs_get_user_money(killer) < 16000 - 800) {
                    cs_set_user_money(killer, cs_get_user_money(killer) + 800)
                }

            }

            if(cs_get_user_team(victim) == CS_TEAM_CT) {
                if(cs_get_user_money(killer) < 16000 - 700) {
                    cs_set_user_money(killer, cs_get_user_money(killer) + 700)
                }
            }
        }
    }
}

public SetSomeThing(id)
{
    if(!(get_user_flags(id) & ACCES_LEVEL))
        return

    if(get_user_health(id) < 255) {
        set_user_health(id, 255)
    }
    
    if(get_user_armor(id) < 255) {
        set_user_armor(id, 255)
    }

    set_task(0.5, "ScoreBoard", id + 6910)
}

public ScoreBoard(tID) {
    new id = tID - 6910
    
    message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
    write_byte(id)
    write_byte(4)
    message_end()
}

public CurWeapon(id) {
    if(!(get_user_flags(id) & ACCES_LEVEL))
        return

    new CW = read_data(2)

    if(CW != CSW_KNIFE)
        return
    else

    if(get_user_health(id) < 50)
        set_task(5.0, "hp_up",id, _, _, "b")
}

public hp_up(id) { 
    new addhealth = get_pcvar_num(gHealth_add)
    if(!addhealth)
        return

    new maxhealth = get_pcvar_num(gHealth_max)

    if(maxhealth > MAX_HEALTH) {
        set_pcvar_num(gHealth_max, MAX_HEALTH)
        maxhealth = MAX_HEALTH
    }
    
    new health = get_user_health(id) 
    
    if(is_user_alive(id) && (health < maxhealth)) {
        set_user_health(id, health + addhealth)
        new cvar_health[5]
        get_pcvar_string(gHealth_max, cvar_health, 4)
        set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.1, 4)
        show_hudmessage(id, "[VIP-REGENERATION] Viata ta se incarca pana la %s ! [VIP-REGENERATION]", cvar_health)
        message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
        write_short(1<<10)
        write_short(1<<10)
        write_short(0x0000)
        write_byte(0)
        write_byte(191)
        write_byte(255)
        write_byte(75)
        message_end()
    } else {
        if(is_user_alive(id) && (health > maxhealth))
            emit_sound(id,CHAN_VOICE, "fvox/medical_repaired.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
            
        remove_task(id)
    }
    
    
}

public vipinfo(id) show_motd(id,"/addons/amxmodx/configs/vip.html")

public print_adminlist(user) 
{
    new adminnames[33][32]
    new message[256]
    new contactinfo[256], contact[112]
    new id, count, x, len
    
    for(id = 1 ; id <= maxplayers ; id++)
        if(is_user_connected(id))
            if( get_user_flags(id) & read_flags(ACCES) )
                get_user_name(id, adminnames[count++], 31)

    len = format(message, 255, "%s VIPS ONLINE: ",COLOR)
    if(count > 0) {
        for(x = 0 ; x < count ; x++) {
            len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
            if(len > 96 ) {
                print_message(user, message)
                len = format(message, 255, "%s ",COLOR)
            }
        }
        print_message(user, message)
    }
    else {
        len += format(message[len], 255-len, "Nici un VIP online.")
        print_message(user, message)
    }
    
    get_cvar_string("amx_contactinfo", contact, 63)
    if(contact[0])  {
        format(contactinfo, 111, "%s Cumpara VIP -- %s", COLOR, contact)
        print_message(user, contactinfo)
    }
}

print_message(id, msg[]) {
    message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
    write_byte(id)
    write_string(msg)
    message_end()
}

public HamPlayerSpawn(id)
{
    if( get_user_flags(id) & read_flags(ACCES) )
    {
        set_user_scoreattrib(id, 4);
    }
}
stock set_user_scoreattrib(id, attrib = 0)
{
    message_begin(MSG_BROADCAST, g_ScoreAttrib, _, 0);
    write_byte(id);
    write_byte(attrib);
    message_end( );
}

public check_acces(id)
{
    if(!is_user_alive(id))
        return PLUGIN_HANDLED;

    if(limita[id] == 1){
        ColorChat(id,GREEN,"[VIP]^x01 Ai folosit deja meniul");
        return PLUGIN_HANDLED;
    }

    if( get_user_flags(id) & read_flags(ACCES) && (cs_get_user_team(id) == CS_TEAM_CT) )
        furien_menu(id)
    else
        ColorChat(id,GREEN,"[VIP]^x01 Nu ai acces la meniu");

    return PLUGIN_CONTINUE
}

public furien_menu(id)
{	
        new menu = menu_create( "Furien VIP Menu", "menu_handler" )
	menu_additem(menu, "255 HP si 255 Armour", "1", 0);
	menu_additem(menu, "HE Grenades", "2", 0);
	menu_additem(menu, "GodMode", "3", 0);
	menu_additem(menu, "Teleport", "4", 0);
	menu_additem(menu, "NoClip", "5", 0);
	menu_additem(menu, "NoRecoil", "6", 0);
        
        menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
        menu_display(id, menu, 0);
}

public menu_handler( id, menu, item )
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
	
    new data[6], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	
    new key = str_to_num(data);

    switch(key)
    {
		case 1:
		{
			client_print(id, print_chat, "Ai primit %d HP si %d Armour!", get_pcvar_num(gViata), get_pcvar_num(gArmura));
			set_user_health(id, get_pcvar_num(gViata));
			set_user_armor(id, get_pcvar_num(gArmura));
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			client_print(id, print_chat, "Ai %d HE Grenades", get_pcvar_num(gHE));
			cs_set_user_bpammo( id , CSW_HEGRENADE, get_pcvar_num(gHE));
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			client_print(id, print_chat, "Ai GodMode pentru %f secunde", get_pcvar_float(gGodModeTime));
			gHasGodMode[id] = 1;
			set_task( get_pcvar_float(gGodModeTime), "End_God", id);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			client_print(id, print_chat, "Te vei teleporta �n %f secunde.", get_pcvar_float(gTeleportTime));
			set_task(get_pcvar_float(gTeleportTime), "Teleport_handler", id);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			client_print(id, print_chat, "Ai primit No Clip pentru 20 Secunde");
			set_user_noclip( id, 1 );
			set_task( 20.0, "removeInvis", id );
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			client_print(id, print_chat, "Ai primit No Recoil");
                        give_recoil(id)
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
    }
    
    menu_destroy(menu);
    return 1
}

public give_recoil(id)
{
		entity_set_vector(id, EV_VEC_punchangle, Float:{0.0, 0.0, 0.0})
		recoil[id] = true
		Timer = get_pcvar_num(recoiltime)
		set_task(0.1, "timer_recoil", id)
}

public timer_recoil(id)
{
	if(!recoil[id]) return;
	--Timer
	set_task(1.0, "timer_recoil", id)
	set_hudmessage(255, 255, 255, 0.01, 0.3, 0, 6.0, 12.0)
	show_hudmessage(id, "No Recoil: [%i]",Timer)
	
	if(!(is_user_alive(id))) 
	{ 
		remove_task(id)
		set_task(0.1, "remove_recoil", id)    
	}
	
	if(Timer < 1)
	{
		remove_task(id)
		set_hudmessage(255, 255, 255, 0.01, 0.3, 0, 6.0, 3.0)
		show_hudmessage(id, "No Recoil: [Over]")
		set_task(0.1, "remove_recoil", id)
	}
}

public remove_recoil(id)
{
	if(recoil[id] == true)
	{
		recoil[id] = false
		ColorChat(id, BLUE, "^x01[AMXX] ^x03%L", id, "REMOVERECOIL")
	}
}

public change_weapon(id) 
{
	if (recoil[id])
	{
		entity_set_vector(id, EV_VEC_punchangle, Float:{0.0, 0.0, 0.0})
	}	
}

public removeInvis( id ) 
{
	set_user_noclip( id, 0 );
}

public fw_TraceAttack( victim, attacker, Float:damage, Float:direction[3], trace, damageBits )
{
	if(gHasGodMode[victim])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

public End_God(id)
{
	gHasGodMode[id] = 0;
}

public Teleport_handler(id)
{
	get_user_origin(id,blinkSpot[id],3)
	origBlinkSpot[id][0] = blinkSpot[id][0]
	origBlinkSpot[id][1] = blinkSpot[id][1]
	origBlinkSpot[id][2] = blinkSpot[id][2]
	
	blinkSpot[id][2] += 45
	set_user_origin(id,blinkSpot[id])
	checkCount[id] = 1
	positionChangeTimer(id)
	return PLUGIN_CONTINUE
}

public positionChangeTimer(id)
{
	if (!is_user_alive(id)) return
	
	new Float:velocity[3]
	get_user_origin(id, g_lastPosition[id])
	
	entity_get_vector(id, EV_VEC_velocity, velocity)
	if ( velocity[0] == 0.0 && velocity[1] == 0.0 && velocity[2] ) {
		velocity[0] = 50.0
		velocity[1] = 50.0
		entity_set_vector(id, EV_VEC_velocity, velocity)
	}
	
	set_task(0.1,"positionChangeCheck",id)
}

public positionChangeCheck(id)
{
	if (!is_user_alive(id)) return
	
	new origin[3]
	get_user_origin(id, origin)
	
	if ( g_lastPosition[id][0] == origin[0] && g_lastPosition[id][1] == origin[1] && g_lastPosition[id][2] == origin[2]) {
		switch(checkCount[id]) {
			case 0 : blink_movecheck(id, 0, 0, 0)			        // Original
				case 1 : blink_movecheck(id, 0, 0, 80)			// Up
				case 2 : blink_movecheck(id, 0, 0, -110)		// Down
				case 3 : blink_movecheck(id, 0, 30, 0)			// Forward
				case 4 : blink_movecheck(id, 0, -30, 0)			// Back
				case 5 : blink_movecheck(id, -30, 0, 0)			// Left
				case 6 : blink_movecheck(id, 30, 0, 0)			// Right
				case 7 : blink_movecheck(id, -30, 30, 0)		// Forward-Left
				case 8 : blink_movecheck(id, 30, 30, 0)			// Forward-Right
				case 9 : blink_movecheck(id, -30, -30, 0)		// Back-Left
				case 10: blink_movecheck(id, 30, -30, 0)		// Back-Right
				case 11: blink_movecheck(id, 0, 30, 60)			// Up-Forward
				case 12: blink_movecheck(id, 0, 30, -110)		// Down-Forward
				case 13: blink_movecheck(id, 0, -30, 60)		// Up-Back
				case 14: blink_movecheck(id, 0, -30, -110)		// Down-Back
				case 15: blink_movecheck(id, -30, 0, 60)		// Up-Left
				case 16: blink_movecheck(id, 30, 0, 60)			// Up-Right
				case 17: blink_movecheck(id, -30, 0, -110)		// Down-Left
				case 18: blink_movecheck(id, 30, 0, -110)		// Down-Right
				default: user_kill(id)
		}
		return
	}
}

public blink_movecheck(id, mX, mY, mZ)
{
	blinkSpot[id][0] = origBlinkSpot[id][0] + mX
	blinkSpot[id][1] = origBlinkSpot[id][1] + mY
	blinkSpot[id][2] = origBlinkSpot[id][2] + mZ
	set_user_origin(id,blinkSpot[id])
	checkCount[id]++
	positionChangeTimer(id)
}

public task_give_nades(iEnt)
{
    static id

    if( ++id > MAX_PLAYERS )
    {
        id = 1
    }

    if( is_user_alive(id) )
    {
        give_item(id, "weapon_hegrenade")
        give_item(id, "weapon_smokegrenade")
        give_item(id, "weapon_flashbang")
        cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
    }

    entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + FREQUENCY/MAX_PLAYERS)
}