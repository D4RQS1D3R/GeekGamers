#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>

#define PLUGIN "Ultimates"
#define VERSION "3.0"
#define AUTHOR "sDs|Aragon*"

// VIP
#define VIP_LEVEL		ADMIN_LEVEL_D

//------| Ultimates |------//
#define ULT_SUICIDE
#define ULT_BLINK
#define ULT_CHAINLIGHTNING
#define ULT_ENTANGLE
#define ULT_IMMOLATE
#define ULT_BIGBADVOODOO
#define ULT_VENGEANCE
#define ULT_LOCUSTSWARM
//#define ULT_ICELIGHTNING

new GlowLevel[33][4]
#define MAX_HEALTH	500
#define	TASK_GLOW	416
#define MAXGLOW		150

//------| Ultimates |------//
#define SOUND_ERROR		"[GG]Sounds/error.wav"
#define SOUND_ULTIMATEREADY	"[GG]Sounds/resurrecttarget.wav"
#define SOUND_SEARCHING		"turret/tu_ping.wav"							

#define SPAWN_DELAY		0.2

#define TASK_DELAY 		2131241
#define TASK_SEARCHING		1738
#define TASK_RESETSPAWNS	3001
#define TASK_SPAWNREMOVEGOD	128
#define TASK_SPAWN		32
#define TASK_SPAWNPLAYER	1056

new Menu, bool:RoundEnded, PlayerUltimate[33], NextUltimate[33], UltimateGlobalDelay = 0, UltimateDelay[33], UltimateIsUsed[33],
Ultimate_Is_Searching[33], SpawnReserved[64], SpawnEnt[2][32], SpawnInc = 0, Float:LastSpeed[33], Float:LastGravity[33]
new cvar_ultimate_countdown, cvar_ultimate_countdown_start;

//------| Suicide Bomb |------//
#if defined ULT_SUICIDE
new ULTIMATE_SUICIDE[][] = { "Suicide Bomber", "1", "dmg_rad" };
new SPR_SUICIDE_EXPLODE, SPR_SUICIDE_EXPLODE2, SPR_SUICIDE_BLAST

#define EXPLOSION_MAX_DAMAGE	100.0
#define EXPLOSION_KNOCKBACK	5.0
#define EXPLOSION_BLAST_RADIUS	250.0

#define TASK_EXPLOSION		160
#define TASK_BEAMCYLINDER	192

#define SOUND_SUICIDE	"ambience/particle_suck1.wav"
new SuicideBombArmed[33], BloodSpray, BloodDrop
#endif

//------| Blink |------//
#if defined ULT_BLINK
new ULTIMATE_BLINK[][] = { "Blink", "2", "item_longjump" };
new SPR_TELEPORT, SPR_TELEPORT_GIB	

#define BLINK_COUNTDOWN		1.0
#define SOUND_BLINK		"weapons/flashbang-1.wav"
new const Float:Size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}
#endif

//------| Chain Lightning |------//
#if defined ULT_CHAINLIGHTNING
new ULTIMATE_CHAINLIGHTNING[][] = { "Chain Lightning", "3", "dmg_shock" };
new SPR_LIGHTNING

#define CHAINLIGHTNING_DAMAGE		100

#define	TASK_LIGHTNING			960
#define	TASK_LIGHTNINGNEXT		1024

#define SOUND_LIGHTNING			"[GG]Sounds/lightningbolt.wav"
new LightningHit[33]
#endif

//------| Entangle |------//
#if defined ULT_ENTANGLE
new ULTIMATE_ENTANGLE[][] = { "Entangling Roots", "4", "item_healthkit" };
new SPR_TRAIL, SPR_BEAM

#define	ENTANGLE_TIME		10.0

#define	TASK_RESETSPEED		512
#define	TASK_ENTANGLEWAIT	928

#define SOUND_ENTANGLING	"[GG]Sounds/entanglingrootstarget1.wav"
new IsStunned[33];
#endif

//------| Immolate |------//
#if defined ULT_IMMOLATE
new ULTIMATE_IMMOLATE[][] = { "Immolate", "5", "dmg_heat" };
new SPR_IMMOLATE, SPR_BURNING, SPR_FIRE

#define IMMOLATE_DAMAGE			100
#define IMMOLATE_DOT_DAMAGE		10
#define IMMOLATE_DOT			6

#define TASK_BURNING			1684

#define SOUND_IMMOLATE			"[GG]Sounds/ImmolationDecay1.wav"
#define SOUND_IMMOLATE_BURNING		"ambience/flameburst1.wav"
#endif

//------| Big Bad Voodoo |------//
#if defined ULT_BIGBADVOODOO
new ULTIMATE_BIGBADVOODOO[][] = 	{ "Big Bad Voodoo", "6", "suit_full" };

#define BIGBADVOODOO_DURATION  	2

#define	TASK_RESETGOD		608

#define SOUND_VOODOO		"[GG]Sounds/divineshield.wav"
#endif

//------| Vengeance |------//
#if defined ULT_VENGEANCE
new ULTIMATE_VENGEANCE[][] = { "Vengeance", "7", "cross" };
#define VENGEANCE_HEALTH	100
#define SOUND_VENGEANCE		"[GG]Sounds/MiniSpiritPissed1.wav"
#endif

//------| Locust Swarm |------//
#if defined ULT_LOCUSTSWARM
new ULTIMATE_LOCUSTSWARM[][] = { "Locust Swarm", "8", "dmg_gas" };
new SPR_LOCUST

#define LOCUSTSWARM_DMG_MIN	60
#define LOCUSTSWARM_DMG_MAX	80

#define	TASK_FUNNELS		1354

#define SOUND_LOCUSTSWARM	"[GG]Sounds/locustswarmloop.wav"
#endif

//------| Ice Lightning |------//
#if defined ULT_ICELIGHTNING
new ULTIMATE_ICELIGHTNING[][] = { "Ice Lightning", "9", "dmg_cold" };
new SPR_ICELIGHTNING, SPR_ICE_BLAST, SPR_GLASS, SPR_ICEEXPLODE, SPR_ICEGIB

#define ICELIGHTNING_DAMAGE		100.0
#define ICELIGHTNING_RADIUS		250.0
#define ICELIGHTNING_TIME		10.0

#define TASK_REMOVEFREEZE		2524534

new const Freeze_Sound[][] = {
	"[GG]Sounds/frostnova.wav",
	"[GG]Sounds/impalehit.wav",
	"[GG]Sounds/impalelaunch1.wav"
};
new IsFreeze[33], Nova[33]
#endif

public plugin_init() {
	register_clcmd("ultimate", "CMD_Ultimate");
	register_clcmd("say /ultimate", "CMD_UltimateMenu");
	register_clcmd("say_team /ultimate", "CMD_UltimateMenu")
	register_clcmd("say ultimate", "CMD_UltimateMenu");
	register_clcmd("say_team ultimate", "CMD_UltimateMenu")
	
	register_logevent("LOGEVENT_RoundStart", 2, "1=Round_Start");
	register_logevent("LOGEVENT_RoundEnd", 2, "1=Round_End");
	register_logevent("LOGEVENT_RoundEnd", 2, "1&Restart_Round_")
	
	register_event("HLTV", "EVENT_NewRound", "a", "1=0", "2=0")
	register_event("DeathMsg", "EVENT_Death", "a");
	
	register_forward(FM_PlayerPreThink, "FWD_PlayerPreThink");
	
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1);
	
	cvar_ultimate_countdown = register_cvar("furien30_ultimate_delay", "25");			//| Ultimate CountDown |//
	cvar_ultimate_countdown_start = register_cvar("furien30_ultimate_delay_startround", "10");	//| Ultimate CountDown Start |//
	
	
	#if defined ULT_VENGEANCE
	copy(SpawnEnt[0], 31, "info_player_start");
	copy(SpawnEnt[1], 31, "info_player_deathmatch");
	#endif	
	set_task(30.0,"TASK_Messages", 0,_,_,"b");
}

public plugin_precache() {
	precache_sound(SOUND_ERROR)
	precache_sound(SOUND_ULTIMATEREADY)
	precache_sound(SOUND_SEARCHING)
	
	#if defined ULT_SUICIDE
	BloodSpray = precache_model("sprites/bloodspray.spr");
	BloodDrop  = precache_model("sprites/blood.spr");
	SPR_SUICIDE_EXPLODE = precache_model("sprites/zerogxplode.spr")
	SPR_SUICIDE_EXPLODE2 = precache_model("sprites/ef_elec.spr")
	SPR_SUICIDE_BLAST = precache_model("sprites/ef_shockwave.spr")
	precache_sound(SOUND_SUICIDE)
	#endif
	
	#if defined ULT_BLINK
	SPR_TELEPORT = precache_model("sprites/b-tele1.spr")	
	SPR_TELEPORT_GIB = precache_model("sprites/blueflare2.spr")	
	precache_sound(SOUND_BLINK)
	#endif
	
	#if defined ULT_CHAINLIGHTNING
	SPR_LIGHTNING = precache_model("sprites/blue_lightning_blizzard.spr");
	precache_sound(SOUND_LIGHTNING)
	#endif
	
	#if defined ULT_ENTANGLE
	SPR_TRAIL = precache_model("sprites/smoke.spr");
	SPR_BEAM = precache_model("sprites/ef_shockwave.spr");
	precache_sound(SOUND_ENTANGLING)
	#endif
	
	#if defined ULT_IMMOLATE
	SPR_IMMOLATE = precache_model("sprites/[GeekGamers]/ultimates/fireball.spr");
	SPR_BURNING = precache_model("sprites/xfire.spr");
	SPR_FIRE = precache_model("sprites/explode1.spr");
	precache_sound(SOUND_IMMOLATE)
	precache_sound(SOUND_IMMOLATE_BURNING)
	#endif
	
	#if defined ULT_BIGBADVOODOO
	precache_sound(SOUND_VOODOO)
	#endif
	
	#if defined ULT_VENGEANCE
	precache_sound(SOUND_VENGEANCE)
	#endif
	
	#if defined ULT_LOCUSTSWARM
	SPR_LOCUST = precache_model("sprites/ef_angrapoison.spr");
	precache_sound(SOUND_LOCUSTSWARM);
	#endif
	
	#if defined ULT_ICELIGHTNING
	SPR_ICELIGHTNING = precache_model("sprites/blue_lightning_blizzard.spr");
	SPR_ICE_BLAST = precache_model("sprites/ef_shockwave.spr");
	SPR_ICEEXPLODE = precache_model("sprites/[GeekGamers]/ultimates/frost_explode.spr")
	SPR_ICEGIB = precache_model("sprites/[GeekGamers]/ultimates/frost_gib.spr")
	SPR_GLASS = precache_model("models/glassgibs.mdl");
	precache_model("models/[GeekGamers]/frostnova.mdl")
	for(new i = 0; i < sizeof Freeze_Sound; i++)
		precache_sound(Freeze_Sound[i])
	#endif
}

public plugin_natives() {
	register_native("set_user_ultimate", "set_user_ultimate", 1);
	register_native("get_user_ultimate", "get_user_ultimate", 1);
}

public set_user_ultimate(id, ultimate) {
	if(is_user_connected(id))
		NextUltimate[id] = ultimate
}

public get_user_ultimate(id) {
	return is_user_connected(id) ? PlayerUltimate[id] : 0
}

public TASK_Messages(id) 
	ColorChat(id, "!t[GG]!g Say!t /ultimate!g In Chat For!t Diamond V.I.P!g Access.");	

public client_putinserver(id)
	NextUltimate[id] = false;

public LOGEVENT_RoundStart()
	RoundEnded = false

public LOGEVENT_RoundEnd() 
	RoundEnded = true

public EVENT_Death() {
	new Victim = read_data(2)
	
	Ultimate_Reset(Victim);
	
	if(is_user_connected(Victim)) {
		#if defined ULT_SUICIDE
		if(get_user_ultimate(Victim) == str_to_num(ULTIMATE_SUICIDE[1])) {
			if(!UltimateGlobalDelay && !UltimateDelay[Victim])			
				Ultimate_SuicideExplode(Victim)
		}
		#endif
		
		#if defined ULT_VENGEANCE
		if(get_user_ultimate(Victim) == str_to_num(ULTIMATE_VENGEANCE[1])) {
			if(!RoundEnded && !UltimateGlobalDelay && !UltimateDelay[Victim])				
				Ultimate_Vengeance(Victim);
		}
		#endif
	}
}

public EVENT_NewRound() {
	UltimateGlobalDelay = get_pcvar_num(cvar_ultimate_countdown_start)
	Ultimate_GlobalDelay();
	
	#if defined ULT_ICELIGHTNING
	for(new i = 0; i < get_maxplayers(); i++)
		if(is_valid_ent(Nova[i])) remove_entity(Nova[i])
	#endif
}

public FWD_PlayerPreThink(id) {	
	if(is_user_connected(id)) {
		new Target, Body;
		get_user_aiming(id, Target, Body, 9999999);
		
		if(is_user_connected(Target) && is_user_alive(Target) && is_user_connected(id) && is_user_alive(id)) {
			if(Ultimate_Is_Searching[id]) {
				if(get_user_team(id) != get_user_team(Target)) {
					#if defined ULT_CHAINLIGHTNING
					if(get_user_ultimate(id) == str_to_num(ULTIMATE_CHAINLIGHTNING[1]))
						Ultimate_ChainLightning(id, Target, Body);
					#endif
					
					#if defined ULT_ENTANGLE
					if(get_user_ultimate(id) == str_to_num(ULTIMATE_ENTANGLE[1]))
						Ultimate_Entangle(id, Target);
					#endif
					
					#if defined ULT_IMMOLATE
					if(get_user_ultimate(id) == str_to_num(ULTIMATE_IMMOLATE[1]))
						Ultimate_Immolate(id, Target);
					#endif
					
					#if defined ULT_ICELIGHTNING
					if(get_user_ultimate(id) == str_to_num(ULTIMATE_ICELIGHTNING[1]))
						Ultimate_IceLightning(id, Target);
					#endif
					
					Ultimate_Is_Searching[id] = false;
					
					UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
					Ultimate_Delay(id)
				}
			}
		}

		if(get_user_ultimate(id) && !(get_user_flags(id) & VIP_LEVEL)) {
			PlayerUltimate[id] = 0
			NextUltimate[id] = 0
		}
		
		if(is_user_alive(id)) {
			#if defined ULT_ENTANGLE
			if(IsStunned[id]) {
				set_pev(id, pev_maxspeed, 1.0);
				set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
			}
			#endif
			#if defined ULT_ICELIGHTNING
			if(IsFreeze[id]) {
				set_pev(id, pev_maxspeed, 1.0);
				set_pev(id, pev_gravity, 0.01);
				set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
			}
			#endif
		}
	}
}

public HAM_Spawn_Post(id) {
	if(is_user_connected(id)) {
		task_exists(TASK_SEARCHING + id) ? remove_task(TASK_SEARCHING + id) : 0;		
		task_exists(TASK_DELAY + id) ? remove_task(TASK_DELAY + id) : 0;	
		
		UltimateDelay[id] = 0;
		Ultimate_Is_Searching[id] = false;
		
		Ultimate_Icon(id, 0)
		
		if(NextUltimate[id] != get_user_ultimate(id))
			PlayerUltimate[id] = NextUltimate[id]
		
		if(!UltimateGlobalDelay) {
			if(!UltimateDelay[id])
				UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown_start);
			
			if(!task_exists(id+TASK_DELAY))
				Ultimate_Delay(id)
		}
	}
}

public CMD_UltimateMenu(id) {
	if(is_user_connected(id)) {
		new Title[64];
		formatex(Title,sizeof(Title)-1,"\d[\yGeek~Gamers\d] \rUltimate Menu^n\wTo use: \rbind\y key\r ultimate");
		Menu = menu_create(Title, "UltimateMenuCmd");
		
		#if defined ULT_SUICIDE
		new Suicide[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(Suicide,sizeof(Suicide)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_SUICIDE[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_SUICIDE[1]))
			formatex(Suicide,sizeof(Suicide)-1,"\y%s", ULTIMATE_SUICIDE[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_SUICIDE[1]))
			formatex(Suicide,sizeof(Suicide)-1,"\r%s", ULTIMATE_SUICIDE[0]);
		else
			formatex(Suicide,sizeof(Suicide)-1,"\w%s", ULTIMATE_SUICIDE[0]);
		menu_additem(Menu, Suicide, "1", 0);
		#endif
		
		#if defined ULT_BLINK
		new Blink[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(Blink,sizeof(Blink)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_BLINK[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_BLINK[1]))
			formatex(Blink,sizeof(Blink)-1,"\y%s", ULTIMATE_BLINK[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_BLINK[1]))
			formatex(Blink,sizeof(Blink)-1,"\r%s", ULTIMATE_BLINK[0]);
		else
			formatex(Blink,sizeof(Blink)-1,"\w%s", ULTIMATE_BLINK[0]);
		menu_additem(Menu, Blink, "2", 0);
		#endif
		
		#if defined ULT_CHAINLIGHTNING
		new ChainLighthing[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(ChainLighthing,sizeof(ChainLighthing)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_CHAINLIGHTNING[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_CHAINLIGHTNING[1]))
			formatex(ChainLighthing,sizeof(ChainLighthing)-1,"\y%s", ULTIMATE_CHAINLIGHTNING[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_CHAINLIGHTNING[1]))
			formatex(ChainLighthing,sizeof(ChainLighthing)-1,"\r%s", ULTIMATE_CHAINLIGHTNING[0]);
		else
			formatex(ChainLighthing,sizeof(ChainLighthing)-1,"\w%s", ULTIMATE_CHAINLIGHTNING[0]);
		menu_additem(Menu, ChainLighthing, "3", 0);
		#endif
		
		#if defined ULT_ENTANGLE
		new Entangle[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(Entangle,sizeof(Entangle)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_ENTANGLE[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_ENTANGLE[1]))
			formatex(Entangle,sizeof(Entangle)-1,"\y%s", ULTIMATE_ENTANGLE[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_ENTANGLE[1]))
			formatex(Entangle,sizeof(Entangle)-1,"\r%s", ULTIMATE_ENTANGLE[0]);
		else
			formatex(Entangle,sizeof(Entangle)-1,"\w%s", ULTIMATE_ENTANGLE[0]);
		menu_additem(Menu, Entangle, "4", 0);
		#endif
		
		#if defined ULT_IMMOLATE
		new Immolate[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(Immolate,sizeof(Immolate)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_IMMOLATE[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_IMMOLATE[1]))
			formatex(Immolate,sizeof(Immolate)-1,"\y%s", ULTIMATE_IMMOLATE[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_IMMOLATE[1]))
			formatex(Immolate,sizeof(Immolate)-1,"\r%s", ULTIMATE_IMMOLATE[0]);
		else
			formatex(Immolate,sizeof(Immolate)-1,"\w%s", ULTIMATE_IMMOLATE[0]);
		menu_additem(Menu, Immolate, "5", 0);
		#endif
		
		#if defined ULT_BIGBADVOODOO
		new BigBadVoodoo[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(BigBadVoodoo,sizeof(BigBadVoodoo)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_BIGBADVOODOO[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_BIGBADVOODOO[1]))
			formatex(BigBadVoodoo,sizeof(BigBadVoodoo)-1,"\y%s", ULTIMATE_BIGBADVOODOO[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_BIGBADVOODOO[1]))
			formatex(BigBadVoodoo,sizeof(BigBadVoodoo)-1,"\r%s", ULTIMATE_BIGBADVOODOO[0]);
		else
			formatex(BigBadVoodoo,sizeof(BigBadVoodoo)-1,"\w%s", ULTIMATE_BIGBADVOODOO[0]);
		menu_additem(Menu, BigBadVoodoo, "6", 0);
		#endif
		
		#if defined ULT_VENGEANCE
		new Vengeance[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(Vengeance,sizeof(Vengeance)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_VENGEANCE[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_VENGEANCE[1]))
			formatex(Vengeance,sizeof(Vengeance)-1,"\y%s", ULTIMATE_VENGEANCE[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_VENGEANCE[1]))
			formatex(Vengeance,sizeof(Vengeance)-1,"\r%s", ULTIMATE_VENGEANCE[0]);
		else
			formatex(Vengeance,sizeof(Vengeance)-1,"\w%s", ULTIMATE_VENGEANCE[0]);
		menu_additem(Menu, Vengeance, "7", 0);
		#endif
		
		#if defined ULT_LOCUSTSWARM
		new LocustWarm[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(LocustWarm,sizeof(LocustWarm)-1,"\d%s \w- \r(Only Diamond V.I.P)", ULTIMATE_LOCUSTSWARM[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_LOCUSTSWARM[1]))
			formatex(LocustWarm,sizeof(LocustWarm)-1,"\y%s", ULTIMATE_LOCUSTSWARM[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_LOCUSTSWARM[1]))
			formatex(LocustWarm,sizeof(LocustWarm)-1,"\r%s", ULTIMATE_LOCUSTSWARM[0]);
		else
			formatex(LocustWarm,sizeof(LocustWarm)-1,"\w%s", ULTIMATE_LOCUSTSWARM[0]);
		menu_additem(Menu, LocustWarm, "8", 0);
		#endif
		
		#if defined ULT_ICELIGHTNING
		new IceLightning[64];
		if(!(get_user_flags(id) & VIP_LEVEL))
			formatex(IceLightning,sizeof(IceLightning)-1,"\d%s \w- \rOnly (Diamond V.I.P)", ULTIMATE_ICELIGHTNING[0]);
		else if(get_user_ultimate(id) == str_to_num(ULTIMATE_ICELIGHTNING[1]))
			formatex(IceLightning,sizeof(IceLightning)-1,"\y%s", ULTIMATE_ICELIGHTNING[0]);
		else if(NextUltimate[id] == str_to_num(ULTIMATE_ICELIGHTNING[1]))
			formatex(IceLightning,sizeof(IceLightning)-1,"\r%s", ULTIMATE_ICELIGHTNING[0]);
		else
			formatex(IceLightning,sizeof(IceLightning)-1,"\w%s", ULTIMATE_ICELIGHTNING[0]);
		menu_additem(Menu, IceLightning, "9", 0);
		#endif
		
		menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, Menu, 0);
	}
	return PLUGIN_HANDLED;
}

public UltimateMenuCmd(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(!(get_user_flags(id) & VIP_LEVEL)) {
		ColorChat(id, "!t[GG]!g To Buy!t Diamond V.I.P!g Contact AuthID");
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new Data[6], Name[64];
	new Access, CallBack;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, CallBack);
	new Key = str_to_num(Data);
	switch(Key) {
		#if defined ULT_SUICIDE
		case 1: {
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_SUICIDE[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_SUICIDE[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_SUICIDE[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_SUICIDE[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_SUICIDE[1])
			}
		}
		#endif
		
		#if defined ULT_BLINK
		case 2: {
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_BLINK[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_BLINK[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_BLINK[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_BLINK[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_BLINK[1])
			}
		}
		#endif
		
		#if defined ULT_CHAINLIGHTNING
		case 3:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_CHAINLIGHTNING[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_CHAINLIGHTNING[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_CHAINLIGHTNING[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_CHAINLIGHTNING[1])	
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_CHAINLIGHTNING[1])
			}
		}
		#endif
		
		#if defined ULT_ENTANGLE
		case 4:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_ENTANGLE[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_ENTANGLE[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_ENTANGLE[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_ENTANGLE[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_ENTANGLE[1])
			}
		}
		#endif
		
		#if defined ULT_IMMOLATE
		case 5:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_IMMOLATE[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_IMMOLATE[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_IMMOLATE[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_IMMOLATE[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_IMMOLATE[1])
			}
		}
		#endif
		
		#if defined ULT_BIGBADVOODOO
		case 6:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_BIGBADVOODOO[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_BIGBADVOODOO[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_BIGBADVOODOO[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_BIGBADVOODOO[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_BIGBADVOODOO[1])
			}
		}
		#endif
		
		#if defined ULT_VENGEANCE
		case 7:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_VENGEANCE[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_VENGEANCE[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_VENGEANCE[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_VENGEANCE[1])	
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_VENGEANCE[1])
			}
		}
		#endif
		
		#if defined ULT_LOCUSTSWARM
		case 8:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_LOCUSTSWARM[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_LOCUSTSWARM[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_LOCUSTSWARM[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_LOCUSTSWARM[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_LOCUSTSWARM[1])
			}
		}
		#endif
		
		#if defined ULT_ICELIGHTNING
		case 9:{
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_ICELIGHTNING[1])) {
				ColorChat(id,"!t[GG]!g Already Have!t %s.", ULTIMATE_ICELIGHTNING[0]);
				NextUltimate[id] = str_to_num(ULTIMATE_ICELIGHTNING[1])
			}
			else {
				if(!PlayerUltimate[id]) {
					PlayerUltimate[id] = str_to_num(ULTIMATE_ICELIGHTNING[1])
					if(!UltimateGlobalDelay && !UltimateDelay[id]) 
						Ultimate_Icon(id, 1)
					else if(UltimateGlobalDelay && UltimateDelay[id])
						UltimateDelay[id] = 0;
					
					else if(!UltimateGlobalDelay && UltimateDelay[id]&& !task_exists(id+TASK_DELAY))
						Ultimate_Delay(id)
				}
				else
					ColorChat(id,"!t[GG]!g Power Will Turn On Your Next Spawn.");
				NextUltimate[id] = str_to_num(ULTIMATE_ICELIGHTNING[1])
			}
		}
		#endif
		
		default: return PLUGIN_HANDLED;
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public CMD_Ultimate(id) {
	if(is_user_connected(id) && is_user_alive(id)) {
		if(!get_user_ultimate(id)) {
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Ultimate not found.");
			
			HudMessage(id, Message, _, _, _, _, _, _, _, 1.0);
			
			emit_sound(id, CHAN_ITEM, SOUND_ERROR, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		else if(UltimateGlobalDelay > 0) {
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Ultimate not ready.^n(%d seconds remaining).", UltimateGlobalDelay);
			
			HudMessage(id, Message, _, _, _, _, _, _, _, 1.0);
			emit_sound(id, CHAN_ITEM, SOUND_ERROR, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		else if(UltimateDelay[id] > 0) {
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Ultimate not ready.^n(%d seconds remaining).", UltimateDelay[id]);
			
			HudMessage(id, Message, _, _, _, _, _, _, _, 1.0);
			emit_sound(id, CHAN_ITEM, SOUND_ERROR, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		else if(UltimateIsUsed[id]) {
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Ultimate not ready.^n(%d seconds remaining).", UltimateDelay[id]);
			
			HudMessage(id, Message, _, _, _, _, _, _, _, 1.0);
			emit_sound(id, CHAN_ITEM, SOUND_ERROR, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		else {
			#if defined ULT_SUICIDE
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_SUICIDE[1])) {				
				if(SuicideBombArmed[id]) {
					set_msg_block(get_user_msgid("DeathMsg"), BLOCK_ONCE);
					user_kill(id, 1);
					UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
					Ultimate_Delay(id)
					Ultimate_SuicideExplode(id)
					SuicideBombArmed[id] = false
				}
				else {
					SuicideBombArmed[id] = true
					Ultimate_Icon(id, 2);
					
					new Message[64];
					formatex(Message,sizeof(Message)-1,"Suicide Bomb Armed^nPress Again To Detonate");
					
					HudMessage(id, Message, 178, 14, 41, _, _, _, _, 2.0);
				}
			}
			#endif
			
			#if defined ULT_BLINK
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_BLINK[1])) {
				if(Ultimate_Blink(id)) {
					UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
					Ultimate_Delay(id)
				}
				else {
					UltimateDelay[id] = 2;
					Ultimate_Delay(id)
					client_print(id, print_center,"Pozitia de teleportare este invalida.")
				}
			}
			#endif
			
			#if defined ULT_CHAINLIGHTNING
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_CHAINLIGHTNING[1])) {
				if(!Ultimate_Is_Searching[id]) {
					Ultimate_Is_Searching[id] = true;
					
					if(!task_exists(TASK_SEARCHING + id)) {
						new Parm[2];
						Parm[0] = id;
						Parm[1] = 5;
						
						Ultimate_Searching(Parm);
					}
				}
			}
			#endif
			
			#if defined ULT_ENTANGLE
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_ENTANGLE[1])) {
				if(!Ultimate_Is_Searching[id]) {
					Ultimate_Is_Searching[id] = true;
					
					if(!task_exists(TASK_SEARCHING + id)) {
						new Parm[2];
						Parm[0] = id;
						Parm[1] = 5;
						
						Ultimate_Searching(Parm);
					}
				}
			}
			#endif
			
			#if defined ULT_IMMOLATE
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_IMMOLATE[1])) {
				if(!Ultimate_Is_Searching[id]) {
					Ultimate_Is_Searching[id] = true;
					
					if(!task_exists(TASK_SEARCHING + id)) {
						new Parm[2];
						Parm[0] = id;
						Parm[1] = 5;
						
						Ultimate_Searching(Parm);
					}
				}
			}
			#endif
			
			#if defined ULT_BIGBADVOODOO
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_BIGBADVOODOO[1]))
				Ultimate_BigBadVoodoo(id);
			#endif
			
			#if defined ULT_VENGEANCE
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_VENGEANCE[1]))
				Ultimate_Vengeance(id);
			#endif
			
			#if defined ULT_LOCUSTSWARM
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_LOCUSTSWARM[1]))
				Ultimate_LocustSwarm(id);
			#endif
			
			#if defined ULT_ICELIGHTNING
			if(get_user_ultimate(id) == str_to_num(ULTIMATE_ICELIGHTNING[1])) {
				if(!Ultimate_Is_Searching[id]) {
					Ultimate_Is_Searching[id] = true;
					
					if(!task_exists(TASK_SEARCHING + id)) {
						new Parm[2];
						Parm[0] = id;
						Parm[1] = 5;
						
						Ultimate_Searching(Parm);
					}
				}
			}
			#endif
		}
	}
	return PLUGIN_HANDLED;
}

public Ultimate_GlobalDelay() {
	if(UltimateGlobalDelay > 1) {
		UltimateGlobalDelay--;
		
		new Players[32], Num;
		get_players(Players, Num);
		
		for(new i = 0; i < Num; i++) {
			if(is_user_connected(Players[i]))
				Ultimate_Icon(Players[i], 0);
		}
		
		set_task(1.0, "Ultimate_GlobalDelay")
	}
	else if(UltimateGlobalDelay <= 1) {
		UltimateGlobalDelay = 0;
		new Players[32], Num;
		get_players(Players, Num);
		
		for(new i = 0; i < Num; i++) {
			if(is_user_connected(Players[i]) && is_user_alive(Players[i]) && get_user_ultimate(Players[i])) {
				emit_sound(Players[i], CHAN_ITEM, SOUND_ULTIMATEREADY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				Ultimate_Icon(Players[i], 1);
				new Message[64];
				formatex(Message,sizeof(Message)-1,"Ultimate is ready.");
				
				HudMessage(Players[i], Message, _, _, _, _, _, _, _, 1.0);
			}
		}
	}
}

public Ultimate_Delay(id) {
	if(id >= TASK_DELAY)
		id -= TASK_DELAY;
	
	if(is_user_connected(id) && is_user_alive(id) && get_user_ultimate(id)) {
		if(UltimateDelay[id] > 1) {
			UltimateDelay[id]--;
			Ultimate_Icon(id, 0);
			set_task(1.0, "Ultimate_Delay", id+TASK_DELAY);
		}
		else if(UltimateDelay[id] <= 1) {
			UltimateDelay[id] = 0;
			emit_sound(id, CHAN_ITEM, SOUND_ULTIMATEREADY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			new Message[64];
			formatex(Message,sizeof(Message)-1,"Ultimate is ready.");
			
			HudMessage(id, Message, _, _, _, _, _, _, _, 1.0);
			Ultimate_Icon(id, 1);
		}
	}
}

public Ultimate_Icon(id, flag) {
	if(get_user_ultimate(id)) {
		if(!is_user_alive(id))
			flag = 0
		
		new Red, Green, Blue;
		#if defined ULT_SUICIDE
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_SUICIDE[1])) {
			Red=255,	Green=0,	Blue=0;
			
			if(flag == 2 && SuicideBombArmed[id])
				Red=255, 	Green=255, 	Blue=255;
			
			Create_StatusIcon(id, flag, ULTIMATE_SUICIDE[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_BLINK
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_BLINK[1])) {
			Red=0,		Green=120,	Blue=120;
			
			Create_StatusIcon(id, flag, ULTIMATE_BLINK[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_CHAINLIGHTNING	
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_CHAINLIGHTNING[1])) {
			Red=255,	Green=255,	Blue=255;
			
			Create_StatusIcon(id, flag, ULTIMATE_CHAINLIGHTNING[2], Red, Green, Blue);
			
		}
		#endif
		
		#if defined ULT_ENTANGLE
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_ENTANGLE[1])) {
			Red=0,		Green=0,	Blue=255;
			
			Create_StatusIcon(id, flag, ULTIMATE_ENTANGLE[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_IMMOLATE
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_IMMOLATE[1])) {
			Red=255,	Green=0,	Blue=0;
			
			if(flag == 2)
				Red=255, 	Green=255, 	Blue=255;	
			
			Create_StatusIcon(id, flag, ULTIMATE_IMMOLATE[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_BIGBADVOODOO
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_BIGBADVOODOO[1])) {
			Red=0,		Green=200,	Blue=200;
			
			Create_StatusIcon(id, flag, ULTIMATE_BIGBADVOODOO[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_VENGEANCE
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_VENGEANCE[1])) {
			Red=255,	Green=0,	Blue=0;
			
			Create_StatusIcon(id, flag, ULTIMATE_VENGEANCE[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_LOCUSTSWARM
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_LOCUSTSWARM[1])) {
			Red=0,		Green=255,	Blue=0;
			
			Create_StatusIcon(id, flag, ULTIMATE_LOCUSTSWARM[2], Red, Green, Blue);
		}
		#endif
		
		#if defined ULT_ICELIGHTNING
		if(get_user_ultimate(id) == str_to_num(ULTIMATE_ICELIGHTNING[1])) {
			Red=0,		Green=200,	Blue=200;
			
			Create_StatusIcon(id, flag, ULTIMATE_ICELIGHTNING[2], Red, Green, Blue);
		}
		#endif
	}
}

public Ultimate_Searching(parm[]) {
	new id = parm[0];
	new TimeLeft = parm[1];
	
	parm[1]--;
	
	if(!is_user_connected(id) || !is_user_alive(id))
		Ultimate_Is_Searching[id] = false;
	
	if(TimeLeft == 0) {
		Ultimate_Is_Searching[id] = false;
		Ultimate_Icon(id, 1);
	}
	
	if(Ultimate_Is_Searching[id]) {
		Ultimate_Icon(id, 2);
		
		emit_sound(id, CHAN_STATIC, SOUND_SEARCHING, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		set_task(1.0, "Ultimate_Searching", TASK_SEARCHING + id, parm, 2);
	}
}

public Ultimate_Reset(id) {
	#if defined ULT_SUICIDE
	task_exists(TASK_EXPLOSION + id) ? remove_task(TASK_EXPLOSION + id) : 0;
	task_exists(TASK_BEAMCYLINDER + id) ? remove_task(TASK_BEAMCYLINDER + id) : 0;
	SuicideBombArmed[id] = false;
	#endif	
	
	#if defined ULT_CHAINLIGHTNING
	task_exists(TASK_LIGHTNINGNEXT + id) ? remove_task(TASK_LIGHTNINGNEXT + id) : 0;
	LightningHit[id] = false;
	#endif	
	
	#if defined ULT_ENTANGLE
	task_exists(TASK_ENTANGLEWAIT + id) ? remove_task(TASK_ENTANGLEWAIT + id) : 0;
	IsStunned[id] = false;
	#endif	
	
	#if defined ULT_IMMOLATE
	task_exists(TASK_BURNING + id) ? remove_task(TASK_BURNING + id) : 0;
	#endif	
	
	#if defined ULT_VENGEANCE
	task_exists(TASK_SPAWN + id) ? remove_task(TASK_SPAWN + id) : 0;
	task_exists(TASK_SPAWNPLAYER + id) ? remove_task(TASK_SPAWNPLAYER + id) : 0;
	#endif	
	
	#if defined ULT_LOCUSTSWARM
	task_exists(TASK_FUNNELS + id) ? remove_task(TASK_FUNNELS + id) : 0;
	#endif
	
	#if defined ULT_ICELIGHTNING
	IsFreeze[id] = false
	task_exists(id+TASK_REMOVEFREEZE) ? remove_task(id+TASK_REMOVEFREEZE) : 0
	if(pev_valid(Nova[id]))
		remove_entity(Nova[id])
	#endif
	
	task_exists(TASK_SEARCHING + id) ? remove_task(TASK_SEARCHING + id) : 0;		
	task_exists(TASK_DELAY + id) ? remove_task(TASK_DELAY + id) : 0;	
	
	UltimateDelay[id] = 0;
	Ultimate_Is_Searching[id] = false;
	
	Ultimate_Icon(id, 0)
}

public Create_StatusIcon(id, status, sprite[], red, green, blue){
	message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, id) 
	write_byte(status)			// status 
	write_string(sprite)			// sprite name 
	write_byte(red)				// red 
	write_byte(green)			// green 
	write_byte(blue)			// blue 
	message_end()
}

#if defined ULT_SUICIDE
// Suicide Explosion
public Ultimate_SuicideExplode(id) {
	emit_sound(id, CHAN_STATIC, SOUND_SUICIDE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	new parm[5], Origin[3];
	get_user_origin(id, Origin);
	
	parm[0] = id;
	parm[1] = 6;
	parm[2] = Origin[0];
	parm[3] = Origin[1];
	parm[4] = Origin[2];
	
	set_task(0.50, "SuicideExplode", TASK_EXPLOSION + id, parm, 5);
	set_task(0.50, "SuicideBlastCircles", TASK_BEAMCYLINDER + id, parm, 5);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_IMPLOSION)
	write_coord(Origin[0])			// position(X)
	write_coord(Origin[1])			// position(Y)
	write_coord(Origin[2])			// position(Z)
	write_byte(100)				// radius
	write_byte(20)				// count
	write_byte(5)				// life in 0.1's
	message_end()
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_EXPLOSION)
	write_coord(Origin[0])			// position(X)
	write_coord(Origin[1])			// position(Y)
	write_coord(Origin[2])			// position(Z)
	write_short(SPR_SUICIDE_EXPLODE)	// sprite index
	write_byte(5)				// scale in 0.1's
	write_byte(30)				// framerate
	write_byte(TE_EXPLFLAG_NOSOUND)			// flags
	message_end()
}

public SuicideExplode(parm[5]) {
	new id = parm[0];
	
	new Origin[3];
	Origin[0] = parm[2];
	Origin[1] = parm[3];
	Origin[2] = parm[4];
	
	new Float:Origin2[3];
	IVecFVec(Origin, Origin2);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_EXPLOSION)
	write_coord(Origin[0])			// position(X)
	write_coord(Origin[1])			// position(Y)
	write_coord(Origin[2])			// position(Z)
	write_short(SPR_SUICIDE_EXPLODE2)	// sprite index
	write_byte(5)				// scale in 0.1's
	write_byte(30)				// framerate
	write_byte(TE_EXPLFLAG_NOSOUND)		// flags
	message_end()
	
	for(new Victim = 1; Victim < get_maxplayers(); Victim++) {
		if(is_user_connected(Victim) && is_user_alive(Victim) && !fm_get_user_godmode(Victim) && get_user_team(Victim) != get_user_team(id) && Victim != id) {
			new Float:VictimOrigin[3], Float:Distance_F, Distance;
			pev(Victim, pev_origin, VictimOrigin);
			Distance_F = get_distance_f(Origin2, VictimOrigin);
			Distance = floatround(Distance_F);
			
			if(Distance <= EXPLOSION_BLAST_RADIUS) {
				new Float:DistanceRatio, Float:Damage;
				DistanceRatio = floatdiv(float(Distance), EXPLOSION_BLAST_RADIUS);
				Damage = EXPLOSION_MAX_DAMAGE - floatround(floatmul(EXPLOSION_MAX_DAMAGE, DistanceRatio));
				
				new BloodColor = ExecuteHam(Ham_BloodColor, Victim);
				if(BloodColor != -1) {
					new Amount = floatround(Damage);
					
					Amount *= 2; //according to HLSDK
					
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_BLOODSPRITE);
					write_coord(floatround(VictimOrigin[0]));
					write_coord(floatround(VictimOrigin[1]));
					write_coord(floatround(VictimOrigin[2]));
					write_short(BloodSpray);
					write_short(BloodDrop);
					write_byte(BloodColor);
					write_byte(min(max(3, Amount/10), 16));
					message_end();
				}
				
				if(parm[1] == 6)
					make_knockback(Victim, Origin2, EXPLOSION_KNOCKBACK*Damage);	
				
				if(get_user_health(Victim) - Damage >= 1) {
					ExecuteHam(Ham_TakeDamage, Victim, id, id, Damage, DMG_BLAST);
					
					Create_ScreenFade(id,(1<<13),(1<<14), 0x0000, 255, 255, 255, 100);
					Create_ScreenShake(Victim,(1<<14),(1<<13),(1<<14));
				}
				else			
					death_message(id, Victim, "Suicide Explode");
			}
		}
	}
	
	--parm[1];
	
	if(parm[1] > 0)
		set_task(0.1, "SuicideExplode", TASK_EXPLOSION + id, parm, 5);
}

public SuicideBlastCircles(parm[5]) {
	new Origin[3];
	Origin[0] = parm[2];
	Origin[1] = parm[3];
	Origin[2] = parm[4]-16;
	
	new Float:Origin2[3];
	IVecFVec(Origin, Origin2);
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y
	engfunc(EngFunc_WriteCoord, Origin2[2]) // z
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
	engfunc(EngFunc_WriteCoord, Origin2[2]+385.0) // z axis
	write_short(SPR_SUICIDE_BLAST) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(255) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y
	engfunc(EngFunc_WriteCoord, Origin2[2]) // z
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
	engfunc(EngFunc_WriteCoord, Origin2[2]+470.0) // z axis
	write_short(SPR_SUICIDE_BLAST) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(255) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y
	engfunc(EngFunc_WriteCoord, Origin2[2]) // z
	engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
	engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
	engfunc(EngFunc_WriteCoord, Origin2[2]+555.0) // z axis
	write_short(SPR_SUICIDE_BLAST) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(255) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_DLIGHT);
	write_coord(Origin[0]); // x
	write_coord(Origin[1]); // y
	write_coord(Origin[2]); // z
	write_byte(floatround(EXPLOSION_BLAST_RADIUS/10.0)); // radius
	write_byte(255) // red
	write_byte(255) // green
	write_byte(255) // blue
	write_byte(8); // life
	write_byte(60); // decay rate
	message_end();	
}
#endif


#if defined ULT_BLINK
//Blink 
public Ultimate_Blink(id) {
	new Origin[3], NewOrigin[3];
	get_user_origin(id, NewOrigin, 3);
	get_user_origin(id, Origin);
	
	Origin[2] += 15;
	NewOrigin[2] += 15;	
	
	if(pev(id, pev_maxspeed) <= 1.0) {
		new Message[64];
		formatex(Message,sizeof(Message)-1,"You can't blink when you're stunned!");
		
		HudMessage(id, Message, 255, 208, 0, -1.0, 0.85, _, _, 1.0);
		
		return false
	}
	
	if(is_restricted_area(id, NewOrigin)) {
		ColorChat(id, "!t[Teleport]!g Position Teleportation is Invalid.")
		return false
	}
	
	new Float:SpriteOrigin[3]
	pev(id, pev_origin, SpriteOrigin)
	
	set_user_origin(id, NewOrigin);
	
	new Float:SpriteOrigin2[3]
	pev(id, pev_origin, SpriteOrigin2)
	
	if(is_player_stuck(id)) {				
		if(is_user_connected(id)) {
			static Float:origin[3]
			static Float:mins[3], hull
			static Float:vec[3]
			static o
			pev(id, pev_origin, origin)
			hull = pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
			if(!is_hull_vacant(origin, hull, id) && !(pev(id, pev_solid) & SOLID_NOT)) {
				pev(id, pev_mins, mins)
				vec[2] = origin[2]
				for(o=0; o < sizeof Size; ++o) {
					vec[0] = origin[0] - mins[0] * Size[o][0]
					vec[1] = origin[1] - mins[1] * Size[o][1]
					vec[2] = origin[2] - mins[2] * Size[o][2]
					if(is_hull_vacant(vec, hull, id)) {
						engfunc(EngFunc_SetOrigin, id, vec)
						set_pev(id, pev_velocity,{0.0,0.0,0.0})
						o = sizeof Size
					}
				}
			}
		}
	}
	emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, SpriteOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, SpriteOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin[2]) // z axis
	write_short(SPR_TELEPORT)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, SpriteOrigin2, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[0]) // x axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[1]) // y axis
	engfunc(EngFunc_WriteCoord, SpriteOrigin2[2]) // z axis
	write_short(SPR_TELEPORT)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	write_coord(floatround(SpriteOrigin2[0]));
	write_coord(floatround(SpriteOrigin2[1]));
	write_coord(floatround(SpriteOrigin2[2])+40);
	write_coord(floatround(SpriteOrigin2[0]));
	write_coord(floatround(SpriteOrigin2[1]));
	write_coord(floatround(SpriteOrigin2[2]));
	write_short(SPR_TELEPORT_GIB);
	write_byte(30);
	write_byte(10);
	write_byte(1);
	write_byte(50);
	write_byte(10);
	message_end();
	
	Create_ScreenFade(id,(1<<15),(1<<10),(1<<12), 0, 0, 255, 180);
	Create_ScreenShake(id,(1<<14),(1<<13),(1<<14));
	return true;
}

public is_player_stuck(id) {
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0,(pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true
	
	return false
}

public is_restricted_area(id, Origin[3]) {	
	new MapName[32];
	get_mapname(MapName, 32);
	
	new x = Origin[0];
	new y = Origin[1];
	new z = Origin[2];
	
	if(equali(MapName, "de_dust")) {
		if(z > 220)
			return true;
	}
	
	else if(equali(MapName, "awp_assault")) {
		if(z > 520 && y > 2400 && y < 2600)
			return true;
	}
	
	else if(equali(MapName, "de_dust_cz")) {
		if(z > 220)
			return true;
	}
	
	else if(equali(MapName, "de_aztec_cz")) {
		if(z > 300)
			return true;
	}
	
	else if(equali(MapName, "cs_assault_upc")) {
		if(z > 650)
			return true;
	}
	
	else if(equali(MapName, "de_aztec")) {
		if(z > 300)
			return true;
	}
	
	else if(equali(MapName, "de_cbble") || equali(MapName, "de_cbble_cz")) {
		if(z > 315) {
			if(!((x > -1320 && x < -1150) &&(y > 2600 && y < 2900)))
				return true;
		}           
	}
	
	else if(equali(MapName, "cs_assault")) {
		if(z > 700)
			return true;
	}
	
	else if(equali(MapName, "cs_militia") || equali(MapName, "cs_militia_cz")) {
		if(z > 500)
			return true;
	}
	
	else if(equali(MapName, "cs_italy")) {
		if(z > -220 && y < -2128)
			return true;
		else if(z > 250) {
			if((x < -1000 && x > -1648) &&(y > 1900 && y < 2050))
				return true;
			else if((x < -1552 && x > -1648) &&(y > 1520 && y < 2050))
				return true;
		}
	}
	
	else if(equali(MapName, "cs_italy_cz")) {
		if(y > 2608)
			return true;
	}
	
	else if(equali(MapName, "de_dust2")) {
		if(z > 270)
			return true;
	}
	
	else if(equali(MapName, "de_dust2_cz")) {
		if(z > 270)
			return true;
	}
	
	else if(equali(MapName, "fy_dustworld")) {
		if(z > 82)
			return true;
	}
	
	else if(equali(MapName, "fy_pool_day")) {
		if(z > 190)
			return true;
	}
	
	else if(equali(MapName, "as_oilrig")) {
		if(x > 1700)
			return true;
	}
	
	return false;
}

public is_hull_vacant(const Float:origin[3], hull,id) {
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if(!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
		return true
	return false
}
#endif

#if defined ULT_CHAINLIGHTNING
//Chain Lightning
public Ultimate_ChainLightning(Caster, Target, BodyPart) {
	ChainEffect(Caster, Target, 60, CHAINLIGHTNING_DAMAGE, BodyPart);
	
	new parm[5];
	parm[0] = Target;
	parm[1] = CHAINLIGHTNING_DAMAGE;
	parm[2] = 60;
	parm[3] = Caster;
	parm[4] = BodyPart;
	
	set_task(0.2, "ChainLightning", TASK_LIGHTNING + Target, parm, 5);
}

public ChainLightning(parm[5]) {
	new Enemy = parm[0];
	
	if(is_user_connected(Enemy)) {
		
		new Caster = parm[3];
		new BodyPart = parm[4];
		new CasterTeam	= get_user_team(Caster)
		
		new Origin[3];
		get_user_origin(Enemy, Origin);
		
		new Players[32], Num;
		get_players(Players, Num, "a");
		
		
		new i, Target = 0;
		new ClosestTarget = 0, ClosestDistance = 0;
		new DistanceBetween = 0;
		new TargetOrigin[3]
		
		for(i = 0; i < Num; i++) {
			Target = Players[i];
			
			if(get_user_team(Target) != CasterTeam) {
				get_user_origin(Target, TargetOrigin)
				
				DistanceBetween = get_distance(Origin, TargetOrigin);
				
				if(DistanceBetween < 500 && !LightningHit[Target]) {
					if(DistanceBetween < ClosestDistance || ClosestTarget == 0) {
						ClosestDistance = DistanceBetween;
						ClosestTarget = Target;
					}
				}
			}
		}
		if(ClosestTarget) {
			parm[1] = floatround(float(parm[2])*2/3);
			parm[2] = floatround(float(parm[2])*2/3);
			
			ChainEffect(Caster, ClosestTarget, parm[2], parm[1], BodyPart);
			
			parm[0] = ClosestTarget;
			set_task(0.2, "ChainLightning", TASK_LIGHTNINGNEXT + Caster, parm, 5);
		}
		
		else {
			for(i = 0; i < Num; i++) {
				LightningHit[Players[i]] = false;
			}
		}
	}
}

public ChainEffect(Caster, Target, LineWidth, Damage, BodyPart) {
	LightningHit[Target] = true;
	
	if(get_user_health(Target) - Damage >= 1) {
		ExecuteHam(Ham_TakeDamage, Target, Caster, Caster, float(Damage), DMG_ENERGYBEAM);
		
		Create_ScreenFade(Target,(1<<13),(1<<14), 0x0000, 255, 255, 255, 100);
		Create_ScreenShake(Target,(1<<14),(1<<13),(1<<14));
	}
	else			
		death_message(Caster, Target, "Chain Lightning");
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)
	write_short(Caster)		// start entity
	write_short(Target)		// end entity
	write_short(SPR_LIGHTNING)	// model
	write_byte(0)			// starting frame
	write_byte(30)			// frame rate
	write_byte(10)			// life
	write_byte(LineWidth)		// line width
	write_byte(50)			// noise amplitude
	write_byte(255)			// red
	write_byte(255)			// green
	write_byte(255)			// blue
	write_byte(200)			// brightness
	write_byte(0)			// scroll speed
	message_end()
	
	new Origin[3]
	get_user_origin(Target, Origin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_ELIGHT)
	write_short(Target)			// entity
	write_coord(Origin[0])			// initial position
	write_coord(Origin[1])			// initial position
	write_coord(Origin[2])			// initial position
	write_coord(100)			// radius
	write_byte(255)				// red
	write_byte(255)				// green
	write_byte(255)				// blue
	write_byte(10)				// life
	write_coord(0)				// decay rate
	message_end()
	
	emit_sound(Caster, CHAN_STATIC, SOUND_LIGHTNING, 1.0, ATTN_NORM, 0, PITCH_NORM);
}
#endif

#if defined ULT_ENTANGLE
public Ultimate_Entangle(Caster, Enemy) {
	new Red, Green, Blue
	if(get_user_team(Enemy) == 1)
		Red = 0, Green = 0, Blue = 200
	else
		Red = 200, Green = 0, Blue = 0
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(Enemy)			// entity
	write_short(SPR_TRAIL)			// model
	write_byte(10)				// life
	write_byte(5)				// width
	write_byte(Red)				// red
	write_byte(Green)			// green
	write_byte(Blue)			// blue
	write_byte(200)				// brightness
	message_end()
	
	IsStunned[Enemy] = true;
	pev(Enemy, pev_maxspeed, LastSpeed[Enemy])
	set_pev(Enemy, pev_maxspeed, 1.0);
	set_pev(Enemy, pev_movetype, MOVETYPE_NONE);
	set_pev(Enemy, pev_velocity, Float:{0.0,0.0,0.0})
	
	new parm[4];
	parm[0] = Enemy;
	parm[1] = 0;
	parm[2] = 0;
	parm[3] = 0;
	EntangleWait(parm);
}

public EntangleWait(parm[4]) {
	new id = parm[0];
	
	if(id >= TASK_ENTANGLEWAIT)
		id -= TASK_ENTANGLEWAIT;
	
	if(is_user_connected(id)) {	
		new Origin[3];
		get_user_origin(id, Origin);
		
		if(Origin[0] == parm[1] && Origin[1] == parm[2] && Origin[2] == parm[3] && (pev(id, pev_flags) & FL_ONGROUND)) {
			set_task(ENTANGLE_TIME, "Entangle_ResetMaxSpeed", TASK_RESETSPEED + id);
			
			EntangleEffect(id)
		}
		else {
			parm[1] = Origin[0];
			parm[2] = Origin[1];
			parm[3] = Origin[2];
			
			set_task(0.001, "EntangleWait", TASK_ENTANGLEWAIT + id, parm, 4);
		}
	}
}

public EntangleEffect(id) {
	new Origin[3];
	get_user_origin(id, Origin);
	
	emit_sound(id, CHAN_STATIC, SOUND_ENTANGLING, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new Start[3], End[3], Height;
	new Radius = 20, Counter = 0;
	new x1, y1, x2, y2;
	
	while(Counter <= 7) {
		if(Counter == 0 || Counter == 8)
			x1 = -Radius;
		else if(Counter == 1 || Counter == 7)
			x1 = -Radius * 100/141;
		else if(Counter == 2 || Counter == 6)
			x1 = 0;
		else if(Counter == 3 || Counter == 5)
			x1 = Radius*100/141
		else if(Counter == 4)
			x1 = Radius
		
		if(Counter <= 4)
			y1 = sqroot(Radius*Radius-x1*x1);
		else
			y1 = -sqroot(Radius*Radius-x1*x1);
		
		++Counter;
		
		if(Counter == 0 || Counter == 8)
			x2 = -Radius;
		else if(Counter == 1 || Counter==7)
			x2 = -Radius*100/141;
		else if(Counter == 2 || Counter==6)
			x2 = 0;
		else if(Counter == 3 || Counter==5)
			x2 = Radius*100/141;
		else if(Counter == 4)
			x2 = Radius;
		
		if(Counter <= 4)
			y2 = sqroot(Radius*Radius-x2*x2);
		else
			y2 = -sqroot(Radius*Radius-x2*x2);
		
		Height = 16 + 2 * Counter;
		
		while(Height > -40) {
			Start[0]	= Origin[0] + (x1 * 2);
			Start[1]	= Origin[1] + (y1 * 2);
			Start[2]	= Origin[2] + (Height * 2);
			End[0]		= Origin[0] + (x2 * 2);
			End[1]		= Origin[1] + (y2 * 2);
			End[2]		= Origin[2] + (Height * 2);
			
			new Red, Green, Blue
			if(get_user_team(id) == 1)
				Red = 0, Green = 0, Blue = 200
			else
				Red = 200, Green = 0, Blue = 0
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMPOINTS)
			write_coord(Start[0])
			write_coord(Start[1])
			write_coord(Start[2])
			write_coord(End[0])
			write_coord(End[1])
			write_coord(End[2])
			write_short(SPR_BEAM)				// model
			write_byte(0)					// start frame
			write_byte(0)					// framerate
			write_byte((floatround(ENTANGLE_TIME) * 10));	// life
			write_byte(30)					// width
			write_byte(15)					// noise
			write_byte(Red)					// red
			write_byte(Green)				// green
			write_byte(Blue)				// blue
			write_byte(200)					// brightness
			write_byte(0)					// speed
			message_end()
			
			Height -= 16;
		}
	}
}

public Entangle_ResetMaxSpeed(id) {
	if(id >= TASK_RESETSPEED)
		id -= TASK_RESETSPEED;
	
	task_exists(TASK_ENTANGLEWAIT + id) ? remove_task(TASK_ENTANGLEWAIT + id) : 0;
	IsStunned[id] = false;
	if(is_user_alive(id))
		set_pev(id, pev_maxspeed, LastSpeed[id]);
}
#endif

#if defined ULT_IMMOLATE
//Immolate
public Ultimate_Immolate(Caster, Target) {
	emit_sound(Caster, CHAN_STATIC, SOUND_IMMOLATE, 0.5, ATTN_NORM, 0, PITCH_NORM);
	
	new TargetOrigin[3];
	get_user_origin(Target, TargetOrigin);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, TargetOrigin)
	write_byte(TE_EXPLOSION)
	write_coord(TargetOrigin[0])			// position(X)
	write_coord(TargetOrigin[1])			// position(Y)
	write_coord(TargetOrigin[2])			// position(Z)
	write_short(SPR_IMMOLATE)			// sprite index
	write_byte(20)					// scale in 0.1's
	write_byte(24)					// framerate
	write_byte(4)					// flags
	message_end()
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, TargetOrigin)
	write_byte(TE_EXPLOSION)
	write_coord(TargetOrigin[0])			// position(X)
	write_coord(TargetOrigin[1])			// position(Y)
	write_coord(TargetOrigin[2])			// position(Z)
	write_short(SPR_BURNING)			// sprite index
	write_byte(30)					// scale in 0.1's
	write_byte(24)					// framerate
	write_byte(4)					// flags
	message_end()
	
	if(get_user_health(Target) - float(IMMOLATE_DAMAGE) >= 1) {
		ExecuteHam(Ham_TakeDamage, Target, Caster, Caster, float(IMMOLATE_DAMAGE), DMG_BURN);
		
		Create_ScreenFade(Target,(1<<13),(1<<14), 0x0000, 255, 108, 0, 160);
		Create_ScreenShake(Target, 0xFFFF,(1<<13), 0xFFFF);
		
	}
	else			
		death_message(Caster, Target, "Immolate");
	
	new parm[3];
	parm[0] = Caster;
	parm[1] = Target;
	parm[2] = 1;
	
	set_task(1.0, "Immolate_DoT", TASK_BURNING + Target, parm, 3);
}

public Immolate_DoT(parm[3]) {
	new Caster = parm[0];
	new Target = parm[1];
	new Counter = parm[2];
	
	if(Counter > IMMOLATE_DOT || !is_user_alive(Target) || !is_user_connected(Target))  {
		Immolate_Remove(Target);
		return
	}
	
	new TargetOrigin[3];
	get_user_origin(Target, TargetOrigin);
	
	emit_sound(Target, CHAN_STATIC, SOUND_IMMOLATE_BURNING, 0.5, ATTN_NORM, 0, PITCH_NORM);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(TE_SPRITE) 
	write_coord(TargetOrigin[0])		// position
	write_coord(TargetOrigin[1]) 
	write_coord(TargetOrigin[2]) 
	write_short(SPR_FIRE)			// sprite index
	write_byte(3)				// scale in 0.1's
	write_byte(200)				// brightness
	message_end() 
	
	if(get_user_health(Target) - float(IMMOLATE_DOT_DAMAGE) >= 1) {
		ExecuteHam(Ham_TakeDamage, Target, Caster, Caster, float(IMMOLATE_DOT_DAMAGE), DMG_BURN);
		
		Create_ScreenFade(Target,(1<<13),(1<<14), 0x0000, 255, 108, 0, 160);
		Create_ScreenShake(Target, 0xFFFF,(1<<13), 0xFFFF);
	}
	else
		death_message(Caster, Target, "Immolate Burn");
	
	parm[2]++;
	
	set_task(1.0, "Immolate_DoT", TASK_BURNING + Target, parm, 3);
	return
}

public Immolate_Remove(Target) {	
	remove_task(TASK_BURNING + Target);
	return PLUGIN_HANDLED;
}
#endif

#if defined ULT_BIGBADVOODOO
//Chain Big Bad Voodoo
public Ultimate_BigBadVoodoo(id) {
	if(is_user_connected(id)) {
		set_user_godmode(id, true)
		
		UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown) + BIGBADVOODOO_DURATION;
		Ultimate_Delay(id)
		
		Ultimate_Icon(id, 2);
		
		message_begin(MSG_ONE, get_user_msgid("BarTime"), {0,0,0}, id)
		write_byte(BIGBADVOODOO_DURATION) 	// duration 
		write_byte(0)
		message_end() 
		
		emit_sound(id, CHAN_STATIC, SOUND_VOODOO, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		set_user_rendering(id, kRenderFxGlowShell, 255, 245, 50, kRenderNormal, 16);
		
		new Origin[3];
		get_user_origin(id, Origin);
		Origin[2] += 75;
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_ELIGHT)
		write_short(id)				// entity
		write_coord(Origin[0])			// initial position
		write_coord(Origin[1])			// initial position
		write_coord(Origin[2])			// initial position
		write_coord(100)			// radius
		write_byte(255)				// red
		write_byte(245)				// green
		write_byte(200)				// blue
		write_byte(BIGBADVOODOO_DURATION)	// life
		write_coord(0)				// decay rate
		message_end()
		
		set_task(float(BIGBADVOODOO_DURATION), "BigBadVoodoo_Remove", TASK_RESETGOD + id);
	}
}

public BigBadVoodoo_Remove(id) {
	if(id >= TASK_RESETGOD)
		id -= TASK_RESETGOD;
	
	set_user_rendering(id);
	set_user_godmode(id, false)
}
#endif

#if defined ULT_VENGEANCE
public Ultimate_Vengeance(id) {
	if(!RoundEnded && !UltimateDelay[id] && !UltimateGlobalDelay) {
		if(!is_user_alive(id))  {
			if(task_exists(TASK_SPAWN + id))
				remove_task(TASK_SPAWN + id);
			
			UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
			Ultimate_Delay(id)
			
			set_task(SPAWN_DELAY, "Spawn", TASK_SPAWN + id);
		}
		
		else {		
			new ent = FindFreeSpawn(id);
			
			if(ent) {
				new Origin[3], NewOrigin[3], Float:SpawnOrigin[3];
				
				get_user_origin(id, Origin);
				
				entity_get_vector(ent, EV_VEC_origin, SpawnOrigin);
				
				FVecIVec(SpawnOrigin, NewOrigin);
				
				set_user_origin(id, NewOrigin);
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
				write_byte(TE_TELEPORT) 
				write_coord(Origin[0]) 
				write_coord(Origin[1]) 
				write_coord(Origin[2]) 
				message_end()
				
				fm_set_user_health(id, VENGEANCE_HEALTH);
				
				emit_sound(id, CHAN_STATIC, SOUND_VENGEANCE, 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
				Ultimate_Delay(id)
			}
		}
	}
}
#endif

#if defined ULT_LOCUSTSWARM
public Ultimate_LocustSwarm(id) {
	new Victim = LocustGetTarget(id);
	
	if(Victim == -1) {
		new Message[64];
		formatex(Message,sizeof(Message)-1, "No valid targets found");
		
		HudMessage(id, Message, _, _, _, _, _, _, _, 2.0);
	}
	else {
		new CasterOrigin[3];
		get_user_origin(id, CasterOrigin);
		
		Ultimate_Icon(id, 2);
		
		UltimateDelay[id] = get_pcvar_num(cvar_ultimate_countdown);
		
		new parm[10];
		parm[0] = id;	// caster
		parm[1] = Victim;		// victim
		parm[2] = CasterOrigin[0];
		parm[3] = CasterOrigin[1];
		parm[4] = CasterOrigin[2];
		
		LocustEffect(parm);
	}
}

public LocustGetTarget(id) {
	new Team = get_user_team(id);
	new Players[32], Num, TargetID;
	new Targets[33], TotalTargets = 0;
	
	get_players(Players, Num, "a");
	
	for(new i = 0; i < Num; i++) {
		TargetID = Players[i];
		
		if(get_user_team(TargetID) != Team) {
			Targets[TotalTargets++] = TargetID;
		}
	}
	
	if(TotalTargets == 0) {
		return -1;
	}
	
	new Victim = 0, RandomSpot;
	while(Victim == 0) {
		RandomSpot = random_num(0, TotalTargets);
		
		Victim = Targets[RandomSpot];
	}
	return Victim;
}


public LocustEffect(parm[]) {
	new Attacker = parm[0];
	new Victim = parm[1];
	if(Attacker >= TASK_FUNNELS) {
		Attacker -= TASK_FUNNELS;
	}
	
	if(!is_user_alive(Victim) || !is_user_connected(Victim)) {
		ColorChat(Attacker, "!tVictim is no longer targetable for Locust Swarm, finding new target!");
		
		new Victim = LocustGetTarget(Attacker);
		
		if(Victim == -1) {
			new Message[64];
			formatex(Message,sizeof(Message)-1, "No valid targets found");
			
			HudMessage(Attacker, Message, _, _, _, _, _, _, _, 2.0);
			
			UltimateDelay[Attacker] = 2;
			Ultimate_Delay(Attacker)
		}
		else {
			new CasterOrigin[3];
			get_user_origin(Attacker, CasterOrigin);
			parm[1] = Victim;	// victim
			parm[2] = CasterOrigin[0];
			parm[3] = CasterOrigin[1];
			parm[4] = CasterOrigin[2];
			
			ColorChat(Attacker, "!tVictim is no longer targetable, try casting again!");
			
			UltimateDelay[Attacker] = 2;
			Ultimate_Delay(Attacker)
		}
	}
	
	new MULTIPLIER = 150
	
	new VictimOrigin[3], Funnel[3];
	get_user_origin(Victim, VictimOrigin);
	
	Funnel[0] = parm[2];
	Funnel[1] = parm[3];
	Funnel[2] = parm[4];
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)	
	write_byte(TE_LARGEFUNNEL)
	write_coord(Funnel[0])		// origin, x
	write_coord(Funnel[1])		// origin, y
	write_coord(Funnel[2])		// origin, z
	write_short(SPR_LOCUST)		// sprite(0 for none)
	write_short(0)			// 0 for collapsing, 1 for sending outward
	message_end() 
	
	new Dist[3];
	Dist[0] = HLP_Diff(VictimOrigin[0], Funnel[0]);
	Dist[1] = HLP_Diff(VictimOrigin[1], Funnel[1]);
	Dist[2] = HLP_Diff(VictimOrigin[2], Funnel[2]);	
	
	for(new i = 0; i < 3; i++) {
		if(HLP_Diff(VictimOrigin[i], Funnel[i] - MULTIPLIER) < Dist[i]) {
			Funnel[i] -= MULTIPLIER;
		}
		else if(HLP_Diff(VictimOrigin[i], Funnel[0] + MULTIPLIER) < Dist[i]) {
			Funnel[i] += MULTIPLIER;
		}
		else {
			Funnel[i] = VictimOrigin[i];
		}
	}
	
	parm[2] = Funnel[0];
	parm[3] = Funnel[1];
	parm[4] = Funnel[2];
	
	
	if(!(Dist[0] < 50 && Dist[1] < 50 && Dist[2] < 50)) {
		
		new Float:Time = 0.2;
		set_task(Time, "LocustEffect", Attacker + TASK_FUNNELS, parm, 5);
	}
	else {
		new Damage = random_num(LOCUSTSWARM_DMG_MIN, LOCUSTSWARM_DMG_MAX);
		
		new Float:FDamage = float(Damage);
		
		if(get_user_health(Victim) - Damage >= 1) {
			ExecuteHam(Ham_TakeDamage, Victim, Attacker, Attacker, FDamage, DMG_POISON);
			
			Create_ScreenFade(Victim,(1<<13),(1<<14), 0x0000, 0, 200, 0, 100);
			Create_ScreenShake(Victim, 0xFFFF,(1<<13), 0xFFFF);
		}
		else			
			death_message(Attacker, Victim, "Locust Swarm");
		
		Ultimate_Icon(Attacker, 0);
		
		Ultimate_Delay(Attacker)
		
		emit_sound(Victim, CHAN_STATIC, SOUND_LOCUSTSWARM, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		new Name[32];
		get_user_name(Victim, Name, 31);
		
		ColorChat(Attacker, "!t[Furien]!g Locust Swarm hit!t %s!g for!t %d!g damage!", Name, Damage);
	}
}

public HLP_Diff(iNum, iNum2) {
	if(iNum > iNum2) {
		return(iNum-iNum2);
	}
	else {
		return(iNum2-iNum);
	}
	
	return 0;
}
#endif

#if defined ULT_ICELIGHTNING
//Ice Lightning
public Ultimate_IceLightning(Caster, Target) {
	if(is_user_alive(Target)) {
		emit_sound(Caster, CHAN_STATIC, Freeze_Sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
		new Origin[3];
		get_user_origin(Target, Origin) ;
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_BEAMENTPOINT);
		write_short(Target | 0x1000);
		write_coord(Origin[0]);	// Start X
		write_coord(Origin[1]);	// Start Y
		write_coord(Origin[2]+1000);// Start Z
		write_short(SPR_ICELIGHTNING);	// Sprite
		write_byte(1);      		// Start frame				
		write_byte(2);     		// Frame rate					
		write_byte(10);			// Life
		write_byte(105);   		// Line width				
		write_byte(0);    		// Noise
		write_byte(0); 			// Red
		write_byte(100);		// Green
		write_byte(200);		// Blue
		write_byte(150);     		// Brightness					
		write_byte(25);      		// Scroll speed					
		message_end();
		
		if(get_user_health(Target) > ICELIGHTNING_DAMAGE)
			ExecuteHam(Ham_TakeDamage, Target, Caster, Caster, ICELIGHTNING_DAMAGE, DMG_FREEZE);
		else			
			death_message(Caster, Target, "Ice Lightning");
		
		new Float:Origin2[3];
		IVecFVec(Origin, Origin2);
		
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, Origin2, 0)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]+75) // z axis
		write_short(SPR_ICEEXPLODE)
		write_byte(22)
		write_byte(35)
		write_byte(TE_EXPLFLAG_NOSOUND)
		message_end()
		
		engfunc(EngFunc_MessageBegin, MSG_BROADCAST ,SVC_TEMPENTITY, Origin2, 0)
		write_byte(TE_SPRITETRAIL) // TE ID
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]+70) // z axis
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]) // z axis
		write_short(SPR_ICEGIB) // Sprite Index
		write_byte(100) // Count
		write_byte(15) // Life
		write_byte(1) // Scale
		write_byte(50) // Velocity Along Vector
		write_byte(10) // Rendomness of Velocity
		message_end();	
	
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
		write_byte(TE_BEAMCYLINDER) // TE id
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y
		engfunc(EngFunc_WriteCoord, Origin2[2]) // z
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]+385.0) // z axis
		write_short(SPR_ICE_BLAST) // sprite
		write_byte(0) // startframe
		write_byte(0) // framerate
		write_byte(10) // life
		write_byte(60) // width
		write_byte(0) // noise
		write_byte(0) // red
		write_byte(100) // green
		write_byte(200) // blue
		write_byte(200) // brightness
		write_byte(0) // speed
		message_end()
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
		write_byte(TE_BEAMCYLINDER) // TE id
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y
		engfunc(EngFunc_WriteCoord, Origin2[2]) // z
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]+470.0) // z axis
		write_short(SPR_ICE_BLAST) // sprite
		write_byte(0) // startframe
		write_byte(0) // framerate
		write_byte(10) // life
		write_byte(60) // width
		write_byte(0) // noise
		write_byte(0) // red
		write_byte(100) // green
		write_byte(200) // blue
		write_byte(200) // brightness
		write_byte(0) // speed
		message_end()
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin2, 0)
		write_byte(TE_BEAMCYLINDER) // TE id
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y
		engfunc(EngFunc_WriteCoord, Origin2[2]) // z
		engfunc(EngFunc_WriteCoord, Origin2[0]) // x axis
		engfunc(EngFunc_WriteCoord, Origin2[1]) // y axis
		engfunc(EngFunc_WriteCoord, Origin2[2]+555.0) // z axis
		write_short(SPR_ICE_BLAST) // sprite
		write_byte(0) // startframe
		write_byte(0) // framerate
		write_byte(10) // life
		write_byte(60) // width
		write_byte(0) // noise
		write_byte(0) // red
		write_byte(100) // green
		write_byte(200) // blue
		write_byte(200) // brightness
		write_byte(0) // speed
		message_end()
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_DLIGHT);
		write_coord(Origin[0]); // x
		write_coord(Origin[1]); // y
		write_coord(Origin[2]); // z
		write_byte(floatround(ICELIGHTNING_RADIUS/10.0)); // radius
		write_byte(0) // red
		write_byte(100) // green
		write_byte(200) // blue
		write_byte(10); // life
		write_byte(60); // decay rate
		message_end();	
				
		new Victim = -1
		
		while((Victim = find_ent_in_sphere(Victim, Origin2, ICELIGHTNING_RADIUS)) != 0) {
			if(is_user_connected(Victim) && is_user_alive(Victim) && get_user_team(Caster) != get_user_team(Victim)) {
				pev(Victim, pev_maxspeed, LastSpeed[Victim]);
				pev(Victim, pev_gravity, LastGravity[Victim]);
					
				set_pev(Victim, pev_maxspeed, 1.0);
				set_pev(Victim, pev_movetype, MOVETYPE_NONE);
				set_pev(Victim, pev_velocity, Float:{0.0,0.0,0.0})
	
				IsFreeze[Victim] = true
				emit_sound(Victim, CHAN_BODY, Freeze_Sound[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				
				Create_ScreenFade(Victim,(1<<13),(1<<14), 0x0000, 255, 0, 0, 250);
				Create_ScreenShake(Victim,(1<<14),(1<<13),(1<<14));

				if(!is_valid_ent(Nova[Victim])) {
					new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"));
					
					if(pev_valid(ent)) {
						engfunc(EngFunc_SetSize, ent, Float:{-8.0,-8.0,-4.0}, Float:{8.0,8.0,4.0});
						engfunc(EngFunc_SetModel, ent, "models/frostnova.mdl");
						
						new Float:Angles[3], Float:PlayerMins[3], Float:NovaOrigin[3];
						Angles[1] = random_float(0.0,360.0);
						pev(Victim, pev_mins, PlayerMins);
						pev(Victim, pev_origin, NovaOrigin);
						NovaOrigin[2] += PlayerMins[2];
						
						set_pev(ent, pev_angles, Angles);
						engfunc(EngFunc_SetOrigin, ent, NovaOrigin);
						
						static Float:Color[3];
						Color[0] = 0.0, Color[1] = 0.0, Color[2] = 150.0;
						
						set_pev(ent, pev_rendermode, kRenderTransColor);
						set_pev(ent, pev_rendercolor, Color);
						set_pev(ent, pev_renderamt, 100.0);
						Nova[Victim] = ent;
					}
				}
				if(task_exists(Victim+TASK_REMOVEFREEZE))
					remove_task(Victim+TASK_REMOVEFREEZE)
				set_task(ICELIGHTNING_TIME, "RemoveFreeze", Victim+TASK_REMOVEFREEZE);
			}
		}
	}
}

public RemoveFreeze(id) {
	if(id >= TASK_REMOVEFREEZE)
		id -= TASK_REMOVEFREEZE
	
	if(IsFreeze[id]) {
		if(pev_valid(Nova[id])) {
			new Origin[3], Float:OriginF[3];
			pev(Nova[id],pev_origin,OriginF);
			FVecIVec(OriginF, Origin);
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
			write_byte(TE_IMPLOSION);
			write_coord(Origin[0]); // x
			write_coord(Origin[1]); // y
			write_coord(Origin[2] + 8); // z
			write_byte(64); // radius
			write_byte(10); // count
			write_byte(3); // duration
			message_end();
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
			write_byte(TE_SPARKS);
			write_coord(Origin[0]); // x
			write_coord(Origin[1]); // y
			write_coord(Origin[2]); // z
			message_end();
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
			write_byte(TE_BREAKMODEL);
			write_coord(Origin[0]); // x
			write_coord(Origin[1]); // y
			write_coord(Origin[2] + 24); // z
			write_coord(16); // size x
			write_coord(16); // size y
			write_coord(16); // size z
			write_coord(random_num(-50,50)); // velocity x
			write_coord(random_num(-50,50)); // velocity y
			write_coord(25); // velocity z
			write_byte(10); // random velocity
			write_short(SPR_GLASS); // model
			write_byte(10); // count
			write_byte(25); // life
			write_byte(0x01); // flags
			message_end();
			
			set_pev(Nova[id],pev_flags,pev(Nova[id],pev_flags)|FL_KILLME);
			remove_entity(Nova[id])
		}

		if(is_user_connected(id) && is_user_alive(id)) {
			IsFreeze[id] = false
			
			set_pev(id, pev_maxspeed, LastSpeed[id])
			set_pev(id, pev_gravity, LastGravity[id])

			Nova[id] = 0
			emit_sound(id, CHAN_BODY, Freeze_Sound[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);	
		}
	}
}
#endif

public FindFreeSpawn(id) {
	new PlayersInVicinity, SpawnID, EntList[1], Origin[3];
	new ent = -1;
	new Float:SpawnOrigin[3];
	new Float:Vicinity = 96.0;
	new bool:Found = false;	
	new Team = get_user_team(id);
	
	SpawnID = ((Team == 2) ? 0 : 1);
	
	do {	
		ent = find_ent_by_class(ent, SpawnEnt[SpawnID]);
		
		if(ent) {
			entity_get_vector(ent, EV_VEC_origin, SpawnOrigin);
			
			FVecIVec(SpawnOrigin, Origin);
			
			PlayersInVicinity = find_sphere_class(0, "player", Vicinity, EntList, 1, SpawnOrigin);
			
			if(PlayersInVicinity == 0) {				
				SpawnReserved[SpawnInc++] = ent;
				
				Found = true;
			}
		}
	}
	while(ent && !Found)
		
	if(!task_exists(TASK_RESETSPAWNS))
		set_task(0.3, "SpawnReset", TASK_RESETSPAWNS);
	
	if(!Found) {
		return -1;
	}
	
	return ent;
}

public SpawnReset() {
	new i;
	
	SpawnInc = 0;
	for(i = 0; i < 64; i++) {
		SpawnReserved[i] = 0;
	}
}

public Spawn(id) {
	if(!RoundEnded) {
		if(id >= TASK_SPAWN)
			id -= TASK_SPAWN;
		
		if(!is_user_alive(id)) {
			set_user_godmode(id, 1);
			
			ExecuteHamB(Ham_CS_RoundRespawn,id);
			
			set_task(0.2, "Spawn_Final", TASK_SPAWNPLAYER + id);
			set_task(1.0, "SpawnRemoveGod", TASK_SPAWNREMOVEGOD + id);
		}
	}
}

public Spawn_Final(id) {
	if(id >= TASK_SPAWNPLAYER)
		id -= TASK_SPAWNPLAYER;
	
	give_item(id, "item_suit");
	fm_set_user_health(id, 100);	
}

public SpawnRemoveGod(id) {
	if(id >= TASK_SPAWNREMOVEGOD)
		id -= TASK_SPAWNREMOVEGOD;
	
	set_user_godmode(id, 0);
}

public Glow(id, Red, Green, Blue, All) {	
	if(!task_exists(TASK_GLOW + id)) {
		if(All) {
			GlowLevel[id][0]	= 0;
			GlowLevel[id][1]	= 0;
			GlowLevel[id][2]	= 0;
			GlowLevel[id][3]	+= All;
		}
		else if(Red) {
			GlowLevel[id][0]	+= Red;
			GlowLevel[id][1]	= 0;
			GlowLevel[id][2]	= 0;
			GlowLevel[id][3]	= 0;
		}
		else if(Green) {
			GlowLevel[id][0]	= 0;
			GlowLevel[id][1]	+= Green;
			GlowLevel[id][2]	= 0;
			GlowLevel[id][3]	= 0;
		}
		else if(Blue) {
			GlowLevel[id][0]	= 0;
			GlowLevel[id][1]	= 0;
			GlowLevel[id][2]	+= Blue;
			GlowLevel[id][3]	= 0;
		}
		
		GlowLevel[id][0] = ((GlowLevel[id][0] > MAXGLOW) ? MAXGLOW : GlowLevel[id][0]);
		GlowLevel[id][1] = ((GlowLevel[id][1] > MAXGLOW) ? MAXGLOW : GlowLevel[id][1]);
		GlowLevel[id][2] = ((GlowLevel[id][2] > MAXGLOW) ? MAXGLOW : GlowLevel[id][2]);
		GlowLevel[id][3] = ((GlowLevel[id][3] > MAXGLOW) ? MAXGLOW : GlowLevel[id][3]);
		
		_Glow(id);
	}
}

public _Glow(id) {
	if(id >= TASK_GLOW)
		id -= TASK_GLOW;
	
	if(is_user_connected(id)) {
		new Red	= GlowLevel[id][0];
		new Green = GlowLevel[id][1];
		new Blue = GlowLevel[id][2];
		new All	= GlowLevel[id][3];
		
		if(Red || Green || Blue) {
			
			GlowLevel[id][0] = ((Red > 5) ? Red - 5 : 0);
			GlowLevel[id][1] = ((Green > 5) ? Green - 5 : 0);
			GlowLevel[id][2] = ((Blue > 5) ? Blue - 5	: 0);
			
			set_user_rendering(id, kRenderFxGlowShell, Red, Green, Blue, kRenderNormal, 16);
			set_task(0.2, "_Glow", TASK_GLOW + id);
			
		}
		
		else if(All) {
			GlowLevel[id][3] = ((All > 5)		? All - 5		: 0);
			
			set_user_rendering(id, kRenderFxGlowShell, All, All, All, kRenderNormal, 16);
			set_task(0.2, "_Glow", TASK_GLOW + id);
			
		}
		
		else {
			set_user_rendering(id);
		}
		
	}
}

stock Create_ScreenFade(id, duration, holdtime, fadetype, red, green, blue, alpha){
	if(is_user_connected(id)) {
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id)			
		write_short(duration)			// fade lasts this long duration
		write_short(holdtime)			// fade lasts this long hold time
		write_short(fadetype)			// fade type(in / out)
		write_byte(red)				// fade red
		write_byte(green)				// fade green
		write_byte(blue)				// fade blue
		write_byte(alpha)				// fade alpha
		message_end()
	}
}

stock Create_ScreenShake(id, amount, duration, frequency){
	if(is_user_connected(id)) {
		message_begin(MSG_ONE,get_user_msgid("ScreenShake"),{0,0,0},id) 
		write_short(amount)				// ammount 
		write_short(duration)				// lasts this long 
		write_short(frequency)			// frequency
		message_end()
	}
}

stock death_message(Killer, Victim, const Weapon[]) {
	if(is_user_connected(Killer) && is_user_connected(Victim)) {
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
		ExecuteHamB(Ham_Killed, Victim, Killer, 2);
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);
		
		make_deathmsg(Killer, Victim, 0, Weapon);
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Killer); // id
		write_short(pev(Killer, pev_frags)); // frags
		write_short(cs_get_user_deaths(Killer)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Killer)); // team
		message_end();
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
		write_byte(Victim); // id
		write_short(pev(Victim, pev_frags)); // frags
		write_short(cs_get_user_deaths(Victim)); // deaths
		write_short(0); // class?
		write_short(get_user_team(Victim)); // team
		message_end();
	}
}

public make_knockback(Victim, Float:origin[3], Float:maxspeed) {
	new Float:fVelocity[3];
	kickback(Victim, origin, maxspeed, fVelocity);
	entity_set_vector(Victim, EV_VEC_velocity, fVelocity);
	
	return(1);
}

stock kickback(ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3]) {
	new Float:fEntOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fEntOrigin);
	
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	new Float:fTime = (vector_distance(fEntOrigin,fOrigin) / fSpeed);
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;
	
	return(fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

#define clamp_byte(%1)       ( clamp( %1, 0, 255 ) )
#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 16 ) )

stock HudMessage(const id, const message[], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 0.01, Float:holdtime = 3.0, Float:fadeintime = 0.01, Float:fadeouttime = 0.01) {
	new count = 1, players[32];
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {	
				new color = pack_color(clamp_byte(red), clamp_byte(green), clamp_byte(blue))
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, players[i]);
				write_byte(strlen(message) + 31);
				write_byte(DRC_CMD_MESSAGE);
				write_byte(effects);
				write_long(color);
				write_long(_:x);
				write_long(_:y);
				write_long(_:fadeintime);
				write_long(_:fadeouttime);
				write_long(_:holdtime);
				write_long(_:fxtime);
				write_string(message);
				message_end();
			}
		}
	}
}

stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!t", "^3");
	
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
