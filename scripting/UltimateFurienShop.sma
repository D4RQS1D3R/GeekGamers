/*/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////                                                /////////////////////
///////////////////////////// -------  | -- > Multumiri < -- | ------------- //////////////////////
/////////////////////////////                                                /////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////                                                /////////////////////
///////////////////////////// ------- | ---> Hades Ownage <--- | ---------- ///////////////////////
/////////////////////////////                                                /////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////                                                /////////////////////
/////////////////////////////////// ------- | ---> YONTU <--- | ---------- ////////////////////////
/////////////////////////////                                                /////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
*/

#include < amxmodx >
#include < amxmisc>
#include < engine >
#include < cstrike >
#include < fun >
#include < hamsandwich >
#include < fakemeta_util >
#include < message_const >
#include < ColorChat >

#pragma tabsize 0

native set_user_pet(id);

native get_user_credits(id);
native set_user_credits(id, credits);

#define PLUGIN "[ Ultimate Shop ] Ultimate Furien Shop"
#define VERSION "1.2"
#define AUTHOR "NicutaMM | Cstrike"

#define IsPlayer(%0)    ( 1 <= %0 <= g_iMaxPlayers )

// -- | Harry Magic Wand | -- //
#define HARRY_WAND_RECOIL 	0.0			// Recoil
#define HARRY_WAND_SPEED 	0.35			// Click stanga
#define HARRY_WAND_SPEED2 	0.75			// Click dreapta
#define HARRY_WAND_FIRE	random_num( 3, 6 )	// Animatie cand trage cu click stanga
#define HARRY_WAND_FIRE2	random_num( 5, 10 )	// Animatie cand trage cu click dreapta

#define TE_BEAMENTPOINT	1
#define TE_EXPLOSION		3
#define TE_SPRITETRAIL		15
#define TE_BEAMCYLINDER		21

// -- | Shop | -- //

new const Prefix[  ] = "^x04[GG][Ultimate Shop]^x01";

// == | Super-Knife | == //

new bool:superknife2X [ 33 ];
new bool:superknife3X [ 33 ];

new v_superknife2X [ 66 ] = "models/furien[GG]/v_superknife2X.mdl";
new v_superknife3X [ 66 ] = "models/furien[GG]/v_superknife3X.mdl";

// -- | Upgrade | -- //
new bool: Upgrade[ 33 ];

// -- | He Grenade | -- //
new Hegrnd_Countdown [ 33 ];
new Float: LastMessage [ 33 ];

// -- | Take Damage | -- //
new g_iMaxPlayers;

new bool: HaveNoFlash [ 33 ];
new g_msgScreenFade;

// -- | Harry Magic Wand | -- //

new const Tag[  ] = "[Harry Magic Wand]";

new HarryFireSound[  ] = "[GG]Sounds/harry_shoot1.wav";
new HarryHitSound[  ] = "[GG]Sounds/harry_hit.wav";
new HarryHitSound2[  ] = "[GG]Sounds/harry_shoot2.wav";
new HarryModel[  ] = "models/furien[GG]/v_harry_wand.mdl";

new HarryBeam, HarryExp, HarryExp2, DeathSprite;

new bool:g_HasHarryWand[ 33 ];

new Harry_Ammo[ 33 ];
new Float:HarryLastShotTime[ 33 ];

new HarryDamageCvar, HarryDamageCvar2, HarryAmmo, HarryKillMoney, HarryDistance;



public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//Register Shop
	register_clcmd("say /shop", "FurienShop" );
	register_clcmd("say shop", "FurienShop" );
	register_clcmd("say_team /shop", "FurienShop" );
	register_clcmd("say_team shop", "FurienShop" );
	
	// -- | Harry Magic Wand | -- //
	register_event( "CurWeapon", "CurrentWeapon", "be", "1=1" );
	
	register_forward( FM_CmdStart, "Harry_CmdStart" );
	register_event("DeathMsg", "eDeath", "a")
	
	HarryDamageCvar = register_cvar( "harry_damage", "100.0" );
	HarryDamageCvar2 = register_cvar( "harry_damage2", "150.0" );
	HarryAmmo = register_cvar( "harry_ammo", "200" );
	HarryKillMoney = register_cvar( "harry_money_reward", "5000" );
	HarryDistance = register_cvar( "harry_distance", "90909" );

	register_concmd( "amx_get_harry", "GiveHarry", ADMIN_RCON, "< nume > < ammo >" );
	
	//Register Arme
	register_event ( "CurWeapon", "CurrWeapon", "be", "1=1" );
	RegisterHam ( Ham_TakeDamage, "player", "Player_TakeDamage" );
	RegisterHam ( Ham_Spawn, "player", "Spawn", true );
	
	register_event("ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199")
	
	
	g_iMaxPlayers = get_maxplayers ( 	);
	g_msgScreenFade = get_user_msgid("ScreenFade")
}

public eDeath ( ) {
	
	if ( superknife2X [ read_data ( 2 ) ] || superknife3X [ read_data ( 2 ) ] ) {
		
		superknife2X [ read_data ( 2 ) ] = false;
		superknife3X [ read_data ( 2 ) ] = false;
	}
}

public plugin_precache ( ) {
	
	//Super-Knife
	precache_model ( v_superknife2X );
	precache_model ( v_superknife3X );
	
	// Harry Potter Wand
	precache_sound( HarryFireSound );
	precache_sound( HarryHitSound );
	precache_sound( HarryHitSound2 );

	precache_model( HarryModel );

	HarryBeam = precache_model( "sprites/harry_wand/harry_plasma_beam.spr" );
	HarryExp = precache_model( "sprites/harry_wand/harry_plasma_exp2.spr" );
	HarryExp2 = precache_model( "sprites/harry_wand/harry_plasma_exp3.spr" );
	DeathSprite = precache_model( "sprites/harry_wand/harry_skull.spr" );
}

public client_putinserver( id ) {
		
	g_HasHarryWand[ id ] = false;
	Harry_Ammo[ id ] = false;
}

public client_disconnect( id ) {
	
	g_HasHarryWand[ id ] = false;
	Harry_Ammo[ id ] = false;
}


public Spawn( id ) {
	
	Hegrnd_Countdown [ id ] = 0;
	strip_user_weapons(id)
	give_item(id, "weapon_knife" );
	
	g_HasHarryWand[ id ] = false;
	Upgrade[ id ] = false;
	HaveNoFlash [ id ] = false;
	
}
public CurrWeapon ( id ) {
	
	if ( superknife2X [ id ] && get_user_weapon ( id ) == CSW_KNIFE ) {
		
		set_pev ( id, pev_viewmodel2, v_superknife2X );
	}
	if ( superknife3X [ id ] && get_user_weapon ( id ) == CSW_KNIFE ) {
		
		set_pev ( id, pev_viewmodel2, v_superknife3X );
	}
}

public FurienShop ( id ) {
	
	if ( cs_get_user_team(id) == CS_TEAM_T ) {
		
		ShopFurien( id )
	}
	
	if ( cs_get_user_team (id ) == CS_TEAM_CT ) {
		
		ShopAntiFurien ( id )
	}
}

public ShopAntiFurien ( id ) {   
	
	new Temp[101], credits = get_user_credits(id); 
	
	
	formatex(Temp,100, "\r[GG] \yUltimate Anti-Furien Shop\y:^nYour Credits:\r %d", credits); 
	new menu = menu_create(Temp, "AntiFurien")
	menu_additem(menu, "\yPachet HP + AP - \r10 Credite", "1", 0);
	menu_additem(menu, "\yHarry Potter Wand - \r50 Credite", "2", 0);
	menu_additem(menu, "\yDefuse Kit - \r2 Credite", "3", 0);
	menu_additem(menu, "\y50 HP - \r10 Credite", "4", 0);
	menu_additem(menu, "\y100 AP - \r15 Credite", "5", 0);
	menu_additem(menu, "\yNo Flash - \r5 Credite^n", "6", 0);
	menu_additem(menu, "\yPet - \r20 Credite", "7", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	
}

public ShopFurien( id ) {    
	
	new Temp[101], credits = get_user_credits(id); 
	
	
	formatex(Temp,100, "\r[GG] \yUltimate Furien Shop\y:^nYour Credits:\r %d", credits); 
	new menu = menu_create(Temp, "Furien")
	menu_additem(menu, "\ySuperKnife \r[ 2X ]\y - \r10 Credite", "1", 0);
	menu_additem(menu, "\ySuperKnife \r[ 3X ]\y - \r15 Credite", "2", 0 );
	menu_additem(menu, "\yHE Grenade - \r5 Credite", "3", 0 );
	menu_additem(menu, "\y50 HP - \r10 Credite", "4", 0);
	menu_additem(menu, "\y100 AP - \r15 Credite", "5", 0);
	menu_additem(menu, "\yNo Flash \d( Only CT )", "6", 0);
	
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	
}

public Furien(id, menu, item) {
	
	if( item == MENU_EXIT )
	{
		return 1;
	}
	
	new data [ 6 ], szName [ 64 ];
	new access, callback;
	menu_item_getinfo ( menu, item, access, data,charsmax ( data ), szName,charsmax ( szName ), callback );
	new key = str_to_num ( data );
	
	switch ( key )
	{  
		
		case 1:
		{
			if( cs_get_user_team(id) == CS_TEAM_T)
			{
				new iCredits = get_user_credits ( id ) - 10;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix );
					return 1;
					
				}
				else
				{ 
					superknife2X[ id ] = true;
					superknife3X[ id ] = false;
					g_HasHarryWand[ id ] = false;
					
					ColorChat(id, GREEN, "%s You Buy Super-Knife [ 2x ].", Prefix );
					CurrWeapon( id );
					
					set_user_credits( id, iCredits );
					return 1;
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Furiens Have access To This Menu.", Prefix );
			}
		}
		
		case 2:
		{
			if( cs_get_user_team(id) == CS_TEAM_T)
			{
				new iCredits = get_user_credits ( id ) - 15;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "!%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					superknife2X[ id ] = false;
					superknife3X[ id ] = true;
					g_HasHarryWand[ id ] = false;
					CurrWeapon( id );
					
					ColorChat(id, GREEN, "%s You Buy Super-Knife [ 3x ].", Prefix );
					set_user_credits( id, iCredits );
					return 1;
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Furiens Have access To This Menu.", Prefix );
			}
		} 
		
		case 3:
		{
				if(Hegrnd_Countdown[id]) {
					if(LastMessage[id] < get_gametime()) {
						LastMessage[id] = get_gametime() + 1.0;
						set_hudmessage(255, 170, 0, -1.0, 0.87, 0, 6.0, 1.0)
						show_hudmessage ( id, "You Can Buy Grenade In %d Seconds%s.",Hegrnd_Countdown[id], Hegrnd_Countdown[id] > 1 ? "e" : "a");
					}
				}
			
				else if ( buyhegrnd ( id ) ) {
				
					Hegrnd_Countdown[id] = 10;
					CountDown_HeGrnd(id);
				}
		}
		
		case 4:
		{
			if( cs_get_user_team(id) == CS_TEAM_T)
			{
				new iCredits = get_user_credits ( id ) - 10;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					new Health = get_user_health ( id );
					if ( Health < 500 ) {
						fm_set_user_health( id, get_user_health ( id ) + 50 );
						ColorChat(id, GREEN, "%s You Buy 50 HP.", Prefix );
						set_user_credits ( id, iCredits );
						return 1;
					}
					
					if ( Health >= 500 ) {
						
						ColorChat( id, GREEN, "%s You Can't Buy More Than 500 HP.", Prefix);
						return 1;
					}
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Furiens Have access To This Menu.", Prefix );
			}
		}
		
		case 5:
		{
			if( cs_get_user_team(id) == CS_TEAM_T)
			{
				new iCredits = get_user_credits ( id ) - 15;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					new Armor = get_user_armor ( id );
					if ( Armor < 500 ) {
						fm_set_user_armor( id, get_user_armor ( id ) + 100 );
						ColorChat(id, GREEN, "%s You Buy 100 AP.", Prefix );
						set_user_credits ( id, iCredits );
						return 1;
					}
					
					if ( Armor >= 500 ) {
						
						ColorChat( id, GREEN, "%s You Can't Buy More Than 500 AP.", Prefix);
						return 1;
					}
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Furiens Have access To This Menu.", Prefix );
			}
		}
		case 6:
		{
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 5;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					HaveNoFlash [ id ] = true;
					
					ColorChat(id, GREEN, "%s You Buy No Flash.", Prefix );
					set_user_credits(id, iCredits);
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
		}
		
		
	}
	menu_destroy(menu);
	return 1;
}

public AntiFurien(id, menu, item ) {
	
	if( item == MENU_EXIT )
	{
		return 1;
	}
	
	new data [ 6 ], szName [ 64 ];
	new access, callback;
	menu_item_getinfo ( menu, item, access, data,charsmax ( data ), szName,charsmax ( szName ), callback );
	new key = str_to_num ( data );
	
	switch ( key )
	{
		case 1:
		{
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				if( Upgrade[ id ] )
				{
					ColorChat(id, GREEN, "%s You can upgrade Your HP and AP Only Once Per Round", Prefix );
				}
				else
				{
					Pack(id);
					Upgrade[ id ] = true;
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
			
		}  
		case 2:
		{
			
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 50;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix );
					return 1;
					
				}
				else
				{ 
					
					get_harry( id )
					
					ColorChat(id, GREEN, "%s You Buy Harry Potter.", Prefix );
					set_user_credits ( id, iCredits );
					return 1;
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
		}
		case 3:
		{
			
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 2;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{ 
					fm_give_item ( id, "item_thighpack" )
					ColorChat(id, GREEN, "%s You Buy Defuse KIT.", Prefix );
					set_user_credits ( id, iCredits );
					return 1;
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
		}
		
		case 4:
		{
			
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 10;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					new Health = get_user_health ( id );
					if ( Health < 500 ) {
						fm_set_user_health( id, get_user_health ( id ) + 50 );
						ColorChat(id, GREEN, "%s You Buy 50 HP.", Prefix );
						set_user_credits ( id, iCredits );
						return 1;
					}
					
					if ( Health >= 500 ) {
						
						ColorChat( id, GREEN, "%s You Can't Buy More Than 500 HP.", Prefix );
						return 1;
					}
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
		}
		
		case 5:
		{
			
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 15;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					new Armor = get_user_armor ( id );
					if ( Armor < 500 ) {
						fm_set_user_armor( id, get_user_armor ( id ) + 100 );
						ColorChat(id, GREEN, "%s You Buy 100 AP.", Prefix );
						set_user_credits ( id, iCredits );
						return 1;
					}
					
					if ( Armor >= 500 ) {
						
						ColorChat( id, GREEN, "%s You Can't Buy More Than 500 AP." );
						return 1;
					}
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
		}
		case 6:
		{
			
			if( cs_get_user_team(id) == CS_TEAM_CT)
			{
				new iCredits = get_user_credits ( id ) - 5;
				if( iCredits < 0 )
				{
					ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
					return 1;
					
				}
				else
				{
					HaveNoFlash [ id ] = true;
					
					ColorChat(id, GREEN, "%s You Buy No Flash.", Prefix );
					set_user_credits(id, iCredits);
				}
			}
			else
			{
				ColorChat(id, GREEN, "%s Only Anti-Furiens Have access To This Menu.", Prefix );
			}
			
		}
		
		
		case 7:
		{
			set_user_pet(id)	
		}
	}
	menu_destroy(menu);
	return 1;
}

public eventFlash(id)
{
	if(is_user_connected(id) && HaveNoFlash [ id ])
	{
		message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id)
		write_short(1)
		write_short(1)
		write_short(1)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
}

public Player_TakeDamage ( iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits ) 
{
	if ( IsPlayer ( iAttacker ) ) {
		if( iInflictor == iAttacker && superknife2X [ iAttacker ] && is_user_alive( iAttacker ) && get_user_weapon( iAttacker ) == CSW_KNIFE && cs_get_user_team( iAttacker ) == CS_TEAM_T )
		{
			SetHamParamFloat( 4, fDamage * 2.0);
			return HAM_HANDLED;
		}
		if( iInflictor == iAttacker && superknife3X [ iAttacker ] && is_user_alive( iAttacker ) && get_user_weapon( iAttacker ) == CSW_KNIFE && cs_get_user_team( iAttacker ) == CS_TEAM_T )
		{
			SetHamParamFloat( 4, fDamage * 3.0);
			return HAM_HANDLED;
		}
	}
	
	return HAM_IGNORED;
}

// -- // -- // ---> | Pack HP & AP | <--- // -- // -- //

public Pack( id ) {
	
	new iCredits = get_user_credits ( id ) - 10;
	if( iCredits < 0 )
	{
		ColorChat( id, GREEN, "%s You Do Not Have enough Credits.", Prefix);
	return 1;
						
	}
	else
	{ 
		new Armor = get_user_armor ( id );
						
		if ( Armor <= 300 )
		{
			fm_set_user_armor ( id, get_user_armor ( id ) + 300 );
		}
						
		new Health = get_user_health ( id );
						
		if ( Health <= 300 )
		{
			fm_set_user_health( id, get_user_health ( id ) + 300 );
			ColorChat(id, GREEN, "%s You Buy Upgrade To Health & Armor!", Prefix );
		}
						
			set_user_credits ( id, iCredits );
		return 1;
		}
	
	return 0;
}


// -- | He Grenade | -- //

public CountDown_HeGrnd ( id ) {
	
	if(!is_user_alive(id) || get_user_team ( id ) != 1) {
		Hegrnd_Countdown[id] = 0;
	}
	else if(Hegrnd_Countdown[id] > 0) {
		set_hudmessage(255, 170, 0, -1.0, 0.87, 0, 6.0, 1.0)
		show_hudmessage(id, "You Can Buy Grenade in %d second%s", Hegrnd_Countdown[id], Hegrnd_Countdown[id] == 1 ? "a" : "e");
		Hegrnd_Countdown[id]--;
		set_task(1.0, "CountDown_HeGrnd", id);
	}
	else if(Hegrnd_Countdown[id] <= 0) {
		set_hudmessage(255, 170, 0, -1.0, 0.87, 0, 6.0, 1.0)
		show_hudmessage(id, "Now You Can Buy Grenade");
		Hegrnd_Countdown[id] = 0;
	}
	
}
	
bool: buyhegrnd ( id ) {
	
	fm_give_item ( id, "weapon_hegrenade" );
	return true;
}

//////////////////// ------------ || Hanrry Potter Wand || ----------- ///////////////////////////

public GiveHarry( id, level, cid ) {
	
	if( !cmd_access( id, level, cid, 3 ) ) 
		return PLUGIN_HANDLED;
	
	new szTtarget[ 32 ], szAmmoHarry[ 21 ];
	
	read_argv( 1, szTtarget, 31 );
	read_argv( 2, szAmmoHarry, 20 );

	new iPlayer = cmd_target( id, szTtarget, 8 );

	new szAdminName[ 32 ], szPlayerName[ 32 ];

	get_user_name( id, szAdminName, 31 );
	get_user_name( iPlayer, szPlayerName, 31 );

	if( !iPlayer )
		return PLUGIN_HANDLED;

	if( !is_user_alive( iPlayer ) ) {

		client_print( id, print_console, "The Player %s is not in The life !", szPlayerName );
		return 1;
	}

	if( g_HasHarryWand[ iPlayer ] ) {

		client_print( id, print_console, "The Player %s Already Have Wand !", szPlayerName );
		return 1;
	}

	else {
	
		new AmmoForMagic = str_to_num( szAmmoHarry );

		ColorChat( 0, GREEN, "^x04%s^x01 Admin^x03 %s Give^x03 %s^x01 Harry's Wand cu^x03 %d ammo^x01 !", Tag, szAdminName, szPlayerName, szAmmoHarry );

		get_harry( iPlayer );
		Harry_Ammo[ iPlayer ] += AmmoForMagic;
	}

	return PLUGIN_CONTINUE;
}

public get_harry( id ) {

	if( is_user_alive( id ) ) {

		superknife2X[ id ] = false;
		superknife3X[ id ] = false;
		g_HasHarryWand[ id ] = true;
		engclient_cmd( id, "weapon_knife" );

		Harry_Ammo[ id ] = get_pcvar_num( HarryAmmo );
	}

	else {

		client_print( id, print_console, "The Player is not in The life! " );
		g_HasHarryWand[ id ] = false;

		return 1;
	}

	return 1;
}

public CurrentWeapon( id )
	if( get_user_weapon( id ) == CSW_KNIFE && g_HasHarryWand[ id ] )
		set_pev( id, pev_viewmodel2, HarryModel );



public Harry_CmdStart( id, uc_handle, seed ) {
	
	if( is_user_alive( id ) && g_HasHarryWand[ id ] ) {
		
		static CurButton;
		CurButton = get_uc( uc_handle, UC_Buttons );
		new Float:flNextAttack = get_pdata_float( id, 83, 5 );

		if( CurButton & IN_ATTACK ) {

			if( get_user_weapon( id ) == CSW_KNIFE && g_HasHarryWand[ id ] ) {

				if( Harry_Ammo[ id ] > 0  && flNextAttack <= 0.0 ) {

					if( get_gametime(  ) - HarryLastShotTime[ id ] > HARRY_WAND_SPEED ) {
						
						set_weapon_anim( id, HARRY_WAND_FIRE );
						emit_sound( id, CHAN_WEAPON, HarryFireSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
						
						Harry_Fire( id );

						if( Harry_Ammo[ id ] > 0 ) {
							
							set_hudmessage( 0, 127, 255, 0.01, 0.85, 0, 6.0, 1.0 );
							show_hudmessage( id, "Remaining Ammo: %d !", Harry_Ammo[ id ] );
						}
						
						else if( Harry_Ammo[ id ] <= 0 ) {
							
							set_hudmessage( 255, 0, 0, 0.01, 0.90, 0, 6.0, 1.0 );
							show_hudmessage( id, "No Ammo !" );
							
						}
						
						static Float:Punch_Angles[ 3 ];
						
						Punch_Angles[ 0]  = -5.0;
						Punch_Angles[ 1 ] = HARRY_WAND_RECOIL;
						Punch_Angles[ 2 ] = HARRY_WAND_RECOIL;
						
						set_pev( id, pev_punchangle, Punch_Angles );

						Harry_Ammo[ id ] -= 1;
						HarryLastShotTime[ id ] = get_gametime(  );
						
					}	
				}
				
				CurButton &= ~IN_ATTACK;
				set_uc( uc_handle, UC_Buttons, CurButton );
			}		
		}
		
		else if( CurButton & IN_ATTACK2 ) {

			if( get_user_weapon( id ) == CSW_KNIFE && g_HasHarryWand[ id ] ) {

				if( Harry_Ammo[ id ] >= 5  && flNextAttack <= 0.0 ) {

					if( get_gametime(  ) - HarryLastShotTime[ id ] > HARRY_WAND_SPEED2 ) {
						
						set_weapon_anim( id, HARRY_WAND_FIRE2 );
						emit_sound( id, CHAN_WEAPON, HarryFireSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
						
						Harry_Fire2( id );

						set_hudmessage( 0, 127, 255, 0.01, 0.85, 0, 6.0, 1.0 );
						show_hudmessage( id, "Remaining Ammo: %d !", Harry_Ammo[ id ] );
						
						static Float:Punch_Angles[ 3 ];
						
						Punch_Angles[ 0 ] = -5.0;
						Punch_Angles[ 1 ] = HARRY_WAND_RECOIL;
						Punch_Angles[ 2 ] = HARRY_WAND_RECOIL;
						
						set_pev( id, pev_punchangle, Punch_Angles );

						Harry_Ammo[ id ] -= 3;
						HarryLastShotTime[ id ] = get_gametime(  );
						
					}	
				}
				
				CurButton &= ~IN_ATTACK2;
				set_uc( uc_handle, UC_Buttons, CurButton );
			}
		}
	}
	
	else if( is_user_alive ( id ) && !g_HasHarryWand[ id ] )
		return PLUGIN_CONTINUE;

	return PLUGIN_CONTINUE;
}

public Harry_Fire( id ) {
	
	static Victim, Body, EndOrigin[ 3 ], BeamOrigin[ 3 ];
	get_user_origin( id, BeamOrigin, 3 );
	get_user_origin( id, EndOrigin, 3 );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 1 );
	write_short( id | 0x1000 );
	write_coord( BeamOrigin[ 0 ] );	// Start X
	write_coord( BeamOrigin[ 1 ] );	// Start Y
	write_coord( BeamOrigin[ 2 ] );	// Start Z
	write_short( HarryBeam);		// Sprite
	write_byte( 1 );      		// Start frame				
	write_byte( 1 );     		// Frame rate					
	write_byte( 1 );			// Life
	write_byte( 40 );   		// Line width				
	write_byte( 0 );    		// Noise
	write_byte( 108 ); 		// Red
	write_byte( 236 );			// Green
	write_byte( 23 );			// Blue
	write_byte( 150 );     		// Brightness					
	write_byte( 25 );      		// Scroll speed					
	message_end(  );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 3 );
	write_coord( EndOrigin[ 0 ] );
	write_coord( EndOrigin[ 1 ] );
	write_coord( EndOrigin[ 2 ] );
	write_short( HarryExp );	// sprite
	write_byte( 10 );		// scale in 0.1's
	write_byte( 15 );		// framerate
	write_byte( 4 );		// flags
	message_end(  );
	
	get_user_aiming( id, Victim, Body, get_pcvar_num( HarryDistance ) );

	if( is_user_connected( Victim ) ) {

		new Float:Damage = float( get_damage_body( Body, get_pcvar_float( HarryDamageCvar ) ) );
		
		new Float:VictimOrigin[ 3 ];
		VictimOrigin[ 0 ] = float( EndOrigin[ 0 ] );
		VictimOrigin[ 1 ] = float( EndOrigin[ 1 ] );
		VictimOrigin[ 2 ] = float( EndOrigin[ 2 ] );
		
		if( get_user_health( Victim ) - get_pcvar_float( HarryDamageCvar ) >= 1 && is_user_alive( Victim ) && !fm_get_user_godmode( Victim ) && get_user_team( Victim ) != get_user_team( id ) ) {

			new iOrigin[ 3 ];
			get_user_origin( Victim, iOrigin, 0 );

			message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
			write_byte( 21 );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] + 60 );	// end axis + radius
			write_short( HarryExp );	// sprite
			write_byte( 0 );		// startfrate
			write_byte( 0 );		// framerate
			write_byte( 10 );		// life in 0.1 sec
			write_byte( 60 );		// width
			write_byte( 0 );		// amplitude
			write_byte( 0 );		// red
			write_byte( 200 );		// green
			write_byte( 200 );		// blue
			write_byte( 153 );		// brightness
			write_byte( 0 );		// speed
			message_end(  );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( 15 );
			write_coord( iOrigin[ 0 ] ); 	// start position (X)
			write_coord( iOrigin[ 1 ] ); 	// start position (Y)
			write_coord( iOrigin[ 2 ] + 40 ); // start position (Z)
			write_coord( iOrigin[ 0 ] ); 	// end position (X)
			write_coord( iOrigin[ 1 ] );	// end position (Y)
			write_coord( iOrigin[ 2 ] );	// end position (Z)
			write_short( DeathSprite );	// sprite index
			write_byte( 50 );		// count
			write_byte( 20 );		// life in 0.1's
			write_byte( 2 );		// scale in 0.1's
			write_byte( 50 );		// velocity along vector in 10's
			write_byte( 10 );		// randomness of velocity in 10's
			message_end(  );
			
			make_knockback( Victim, VictimOrigin, 3 * get_pcvar_float( HarryDamageCvar ) );
			
			ExecuteHam( Ham_TakeDamage, Victim, id, id, Damage, DMG_NERVEGAS );
			
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "Damage" ), _, Victim );
			write_byte( 0 );
			write_byte( 0 );
			write_long( DMG_SHOCK );
			write_coord( 0 );
			write_coord( 0 );
			write_coord( 0 );
			message_end(  );
			
			FadeScreen( Victim, 4.0, 255, 122, 122, 100 );
			ShakeScreen( Victim, 3.0 );
		}

		else if( get_user_health( Victim ) - get_pcvar_float( HarryDamageCvar ) < 1 && is_user_alive( Victim ) && !fm_get_user_godmode( Victim ) && get_user_team( Victim ) != get_user_team( id ) ) {
			
			new iOrigin[ 3 ];
			get_user_origin( Victim, iOrigin, 0 );

			message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
			write_byte( 21 );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] + 60 );	// end axis + radius
			write_short( HarryExp );	// sprite
			write_byte( 0 );		// startfrate
			write_byte( 0 );		// framerate
			write_byte( 10 );		// life in 0.1 sec
			write_byte( 60 );		// width
			write_byte( 0 );		// amplitude
			write_byte( 0 );		// red
			write_byte( 200 );		// green
			write_byte( 200 );		// blue
			write_byte( 153 );		// brightness
			write_byte( 0 );		// speed
			message_end(  );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( 15 );
			write_coord( iOrigin[ 0 ] ); 	// start position (X)
			write_coord( iOrigin[ 1 ] ); 	// start position (Y)
			write_coord( iOrigin[ 2 ] + 40 ); // start position (Z)
			write_coord( iOrigin[ 0 ] ); 	// end position (X)
			write_coord( iOrigin[ 1 ] );	// end position (Y)
			write_coord( iOrigin[ 2 ] );	// end position (Z)
			write_short( DeathSprite );	// sprite index
			write_byte( 50 );		// count
			write_byte( 20 );		// life in 0.1's
			write_byte( 2 );		// scale in 0.1's
			write_byte( 50 );		// velocity along vector in 10's
			write_byte( 10 );		// randomness of velocity in 10's
			message_end(  );
			
			make_knockback( Victim, VictimOrigin, 3 * get_pcvar_float( HarryDamageCvar ) );
			
			death_message( id, Victim, 1, "Magic Wand" );
		}
	}

	else {

		static ClassName[ 32 ];
		pev( Victim, pev_classname, ClassName, charsmax( ClassName ) );

		if( equal( ClassName, "func_breakable" ) )
			if( entity_get_float( Victim, EV_FL_health ) <= 80 )
				force_use( id, Victim );
	}
	
	emit_sound( id, CHAN_WEAPON, HarryHitSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
}

public Harry_Fire2( id ) {
	
	static Victim, Body, EndOrigin[3], BeamOrigin[3];
	get_user_origin( id, BeamOrigin, 3 ) ;
	get_user_origin( id, EndOrigin, 3 );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 1 );
	write_short( id | 0x1000 );
	write_coord( BeamOrigin[ 0 ] );	// Start X
	write_coord( BeamOrigin[ 1 ] );	// Start Y
	write_coord( BeamOrigin[ 2 ] );	// Start Z
	write_short( HarryBeam );	// Sprite
	write_byte( 1 );      		// Start frame				
	write_byte( 1 );     		// Frame rate					
	write_byte( 1 );			// Life
	write_byte( 40 );   		// Line width				
	write_byte( 0 );    		// Noise
	write_byte( 150 ); 		// Red
	write_byte( 22 );			// Green
	write_byte( 235 );			// Blue
	write_byte( 150 );     		// Brightness					
	write_byte( 25 );      		// Scroll speed					
	message_end(  );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 3 );
	write_coord( EndOrigin[ 0 ] );
	write_coord( EndOrigin[ 1 ] );
	write_coord( EndOrigin[ 2 ] );
	write_short( HarryExp2 );
	write_byte( 10 );
	write_byte( 15 );
	write_byte( 4 );
	message_end(  );
	
	get_user_aiming( id, Victim, Body, get_pcvar_num( HarryDistance ) );

	if( is_user_alive( Victim ) ) {

		new Float:Damage = float( get_damage_body( Body, get_pcvar_float( HarryDamageCvar ) ) );

		new Float:VictimOrigin[ 3 ];
		VictimOrigin[ 0 ] = float( EndOrigin[ 0 ] );
		VictimOrigin[ 1 ] = float( EndOrigin[ 1 ] );
		VictimOrigin[ 2 ] = float( EndOrigin[ 2 ] );
		
		if( get_user_health( Victim ) - get_pcvar_float( HarryDamageCvar2 ) >= 1 && is_user_alive( Victim ) && !fm_get_user_godmode( Victim ) && get_user_team( Victim ) != get_user_team( id ) ) {
			
			new iOrigin[ 3 ];
			get_user_origin( Victim, iOrigin, 0 );

			message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
			write_byte( 21 );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] + 60 );	// end axis + radius
			write_short( HarryExp2 );	// sprite
			write_byte( 0 );		// startfrate
			write_byte( 0 );		// framerate
			write_byte( 10 );		// life in 0.1 sec
			write_byte( 60 );		// width
			write_byte( 0 );		// amplitude
			write_byte( 217 );		// red
			write_byte( 132 );		// green
			write_byte( 47 );		// blue
			write_byte( 153 );		// brightness
			write_byte( 0 );		// speed
			message_end(  );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( 15 );
			write_coord( iOrigin[ 0 ] ); 	// start position (X)
			write_coord( iOrigin[ 1 ] ); 	// start position (Y)
			write_coord( iOrigin[ 2 ] + 40 ); // start position (Z)
			write_coord( iOrigin[ 0 ] ); 	// end position (X)
			write_coord( iOrigin[ 1 ] );	// end position (Y)
			write_coord( iOrigin[ 2 ] );	// end position (Z)
			write_short( DeathSprite );	// sprite index
			write_byte( 50 );		// count
			write_byte( 20 );		// life in 0.1's
			write_byte( 2 );		// scale in 0.1's
			write_byte( 50 );		// velocity along vector in 10's
			write_byte( 10 );		// randomness of velocity in 10's
			message_end(  );
			
			make_knockback( Victim, VictimOrigin, 3 * get_pcvar_float( HarryDamageCvar2 ) );
			
			ExecuteHam( Ham_TakeDamage, Victim, id, id, Damage, DMG_NERVEGAS );
			
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "Damage" ), _, Victim );
			write_byte( 0 );
			write_byte( 0 );
			write_long( DMG_NERVEGAS );
			write_coord( 0 ) ;
			write_coord( 0 );
			write_coord( 0 );
			message_end(  );
			
			FadeScreen( Victim, 4.0, 0, 255, 0, 100 );
			ShakeScreen( Victim, 3.0 );
		}

		else if( get_user_health( Victim ) - get_pcvar_float( HarryDamageCvar2 ) < 1 && is_user_alive( Victim ) && !fm_get_user_godmode( Victim ) && get_user_team( Victim ) != get_user_team( id ) ) {
			
			new iOrigin[ 3 ];
			get_user_origin( Victim, iOrigin, 0 );

			message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
			write_byte( 21 );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] );
			write_coord( iOrigin[ 0 ] );
			write_coord( iOrigin[ 1 ] );
			write_coord( iOrigin[ 2 ] + 60 );	// end axis + radius
			write_short( HarryExp2 );	// sprite
			write_byte( 0 );		// startfrate
			write_byte( 0 );		// framerate
			write_byte( 10 );		// life in 0.1 sec
			write_byte( 60 );		// width
			write_byte( 0 );		// amplitude
			write_byte( 217 );		// red
			write_byte( 132 );		// green
			write_byte( 47 );		// blue
			write_byte( 153 );		// brightness
			write_byte( 0 );		// speed
			message_end(  );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( 15 );
			write_coord( iOrigin[ 0 ] ); 	// start position (X)
			write_coord( iOrigin[ 1 ] ); 	// start position (Y)
			write_coord( iOrigin[ 2 ] + 40 ); // start position (Z)
			write_coord( iOrigin[ 0 ] ); 	// end position (X)
			write_coord( iOrigin[ 1 ] );	// end position (Y)
			write_coord( iOrigin[ 2 ] );	// end position (Z)
			write_short( DeathSprite );	// sprite index
			write_byte( 50 );		// count
			write_byte( 20 );		// life in 0.1's
			write_byte( 2 );		// scale in 0.1's
			write_byte( 50 );		// velocity along vector in 10's
			write_byte( 10 );		// randomness of velocity in 10's
			message_end(  );
			
			make_knockback( Victim, VictimOrigin, 3 * get_pcvar_float( HarryDamageCvar2 ) );
			
			death_message( id, Victim, 1, "Double Magic Wand" );
		}
	}

	else {

		static ClassName[ 32 ];
		pev( Victim, pev_classname, ClassName, charsmax( ClassName ) );

		if( equal( ClassName, "func_breakable" ) )
			if( entity_get_float( Victim, EV_FL_health ) <= 80 )
				force_use( id, Victim );
	}

	emit_sound( id, CHAN_WEAPON, HarryHitSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
}

public make_knockback( Victim, Float:origin[ 3 ], Float:maxspeed ) {

	new Float:fVelocity[ 3 ];
	
	kickback( Victim, origin, maxspeed, fVelocity );
	entity_set_vector( Victim, EV_VEC_velocity, fVelocity );
	
	return( 1 );
}

stock ShakeScreen( id, const Float:iSeconds ) {

	message_begin( MSG_ONE, get_user_msgid( "ScreenShake" ), { 0, 0, 0 }, id );
	write_short( floatround( 4096.0 * iSeconds, floatround_round ) );
	write_short( floatround( 4096.0 * iSeconds, floatround_round ) );
	write_short( 1<<13 );
	message_end(  );
}

stock FadeScreen( id, const Float:iSeconds, const iRed, const iGreen, const iBlue, const iAlpha ) {
      
	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
	write_short( floatround( 4096.0 * iSeconds, floatround_round ) );
	write_short( floatround( 4096.0 * iSeconds, floatround_round ) );
	write_short( 0x0000 );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iAlpha );
	message_end(  );
}		

stock kickback( ent, Float:fOrigin[ 3 ], Float:fSpeed, Float:fVelocity[ 3 ] ) {

	new Float:fEntOrigin[ 3 ];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );
	
	new Float:fDistance[ 3 ];
	fDistance[ 0 ] = fEntOrigin[ 0 ] - fOrigin[ 0 ];
	fDistance[ 1 ] = fEntOrigin[ 1 ] - fOrigin[ 1 ];
	fDistance[ 2 ] = fEntOrigin[ 2 ] - fOrigin[ 2 ];

	new Float:fTime =( vector_distance( fEntOrigin, fOrigin ) / fSpeed );
	fVelocity[ 0 ] = fDistance[ 0 ] / fTime;
	fVelocity[ 1 ] = fDistance[ 1 ] / fTime;
	fVelocity[ 2 ] = fDistance[ 2 ] / fTime;
	
	return( fVelocity[ 0 ] && fVelocity[ 1 ] && fVelocity[ 2 ] );
}

// stock from "m79"
stock death_message( Killer, Victim, ScoreBoard, const Weapon[  ] ) {
	
	set_msg_block( get_user_msgid( "DeathMsg" ), BLOCK_SET );

	ExecuteHamB( Ham_Killed, Victim, Killer, 2 );

	set_msg_block( get_user_msgid( "DeathMsg" ), BLOCK_NOT );

	make_deathmsg( Killer, Victim, 0, Weapon );
	cs_set_user_money( Killer, cs_get_user_money( Killer ) + get_pcvar_num( HarryKillMoney ) );
	
	if( ScoreBoard ) {

		message_begin( MSG_BROADCAST, get_user_msgid( "ScoreInfo" ) );
		write_byte( Killer );
		write_short( pev( Killer, pev_frags ) );
		write_short( cs_get_user_deaths( Killer ) );
		write_short( 0 );
		write_short( get_user_team( Killer ) );
		message_end(  );
		
		message_begin( MSG_BROADCAST, get_user_msgid( "ScoreInfo" ) );
		write_byte( Victim );
		write_short( pev( Victim, pev_frags ) );
		write_short( cs_get_user_deaths( Victim ) );
		write_short( 0 );
		write_short( get_user_team( Victim ) );
		message_end(  );
	}
}

stock set_weapon_anim( id, anim ) {

	set_pev( id, pev_weaponanim, anim );

	if( is_user_alive( id ) ) {

		message_begin( MSG_ONE, SVC_WEAPONANIM, _, id );
		write_byte( anim );
		write_byte( pev( id, pev_body ) );
		message_end(  );
	}
}

stock get_damage_body( body, Float:fDamage ) {

	switch( body ) {

		case HIT_HEAD: fDamage *= 4.0;

		case HIT_STOMACH: fDamage *= 1.1;

		case HIT_CHEST: fDamage *= 1.5;

		case HIT_LEFTARM: fDamage *= 0.77;

		case HIT_RIGHTARM: fDamage *= 0.77;

		case HIT_LEFTLEG: fDamage *= 0.75;

		case HIT_RIGHTLEG: fDamage *= 0.75;

		default: fDamage *= 1.0;
	}
	
	return floatround( fDamage );
}