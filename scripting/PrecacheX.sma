#include < amxmodx > 
#include < fakemeta > 

new /*Array:ArModel,*/ Array:ArSound
new GTempData[64]
/*
new const UnPrecache_ModelList[ 32 ][ ] = 
{ 
	"models/w_battery.mdl", 
	"models/shield/p_shield_deagle.mdl", 
	"models/shield/p_shield_fiveseven.mdl", 
	"models/shield/p_shield_flashbang.mdl", 
	"models/shield/p_shield_glock18.mdl", 
	"models/shield/p_shield_hegrenade.mdl", 
	"models/shield/p_shield_knife.mdl", 
	"models/shield/p_shield_p228.mdl", 
	"models/shield/p_shield_smokegrenade.mdl", 
	"models/shield/p_shield_usp.mdl", 
	"models/shield/v_shield_deagle.mdl", 
	"models/shield/v_shield_fiveseven.mdl", 
	"models/shield/v_shield_flashbang.mdl", 
	"models/shield/v_shield_glock18.mdl", 
	"models/shield/v_shield_hegrenade.mdl", 
	"models/shield/v_shield_knife.mdl", 
	"models/shield/v_shield_p228.mdl", 
	"models/shield/v_shield_smokegrenade.mdl", 
	"models/shield/v_shield_usp.mdl", 
	"models/w_antidote.mdl", 
	"models/w_security.mdl", 
	"models/w_longjump.mdl", 
	"sprites/WXplo1.spr", 
	"sprites/bubble.spr", 
	"sprites/eexplo.spr", 
	"sprites/fexplo.spr", 
	"sprites/fexplo1.spr", 
	"sprites/b-tele1.spr", 
	"sprites/c-tele1.spr", 
	"sprites/ledglow.spr", 
	"sprites/laserdot.spr", 
	"sprites/explode1.spr" 
} 
*/
new const UnPrecache_SoundList[ 80 ][ ] = 
{
	"weapons/ak47_clipout.wav", 
	"weapons/ak47_clipin.wav", 
	"weapons/ak47_boltpull.wav", 
	"weapons/aug_clipout.wav", 
	"weapons/aug_clipin.wav", 
	"weapons/aug_boltpull.wav", 
	"weapons/aug_boltslap.wav", 
	"weapons/aug_forearm.wav", 
	"weapons/c4_click.wav", 
	"weapons/c4_beep1.wav", 
	"weapons/c4_beep2.wav", 
	"weapons/c4_beep3.wav", 
	"weapons/c4_beep4.wav", 
	"weapons/c4_beep5.wav", 
	"weapons/c4_explode1.wav", 
	"weapons/c4_plant.wav", 
	"weapons/c4_disarm.wav", 
	"weapons/c4_disarmed.wav", 
	"weapons/elite_reloadstart.wav", 
	"weapons/elite_leftclipin.wav", 
	"weapons/elite_clipout.wav", 
	"weapons/elite_sliderelease.wav", 
	"weapons/elite_rightclipin.wav", 
	"weapons/elite_deploy.wav", 
	"weapons/famas_clipout.wav", 
	"weapons/famas_clipin.wav", 
	"weapons/famas_boltpull.wav", 
	"weapons/famas_boltslap.wav", 
	"weapons/famas_forearm.wav", 
	"weapons/g3sg1_slide.wav", 
	"weapons/g3sg1_clipin.wav", 
	"weapons/g3sg1_clipout.wav", 
	"weapons/galil_clipout.wav", 
	"weapons/galil_clipin.wav", 
	"weapons/galil_boltpull.wav", 
	"weapons/m4a1_clipin.wav", 
	"weapons/m4a1_clipout.wav", 
	"weapons/m4a1_boltpull.wav", 
	"weapons/m4a1_deploy.wav", 
	"weapons/m4a1_silencer_on.wav", 
	"weapons/m4a1_silencer_off.wav", 
	"weapons/m249_boxout.wav", 
	"weapons/m249_boxin.wav", 
	"weapons/m249_chain.wav", 
	"weapons/m249_coverup.wav", 
	"weapons/m249_coverdown.wav", 
	"weapons/mac10_clipout.wav", 
	"weapons/mac10_clipin.wav", 
	"weapons/mac10_boltpull.wav", 
	"weapons/mp5_clipout.wav", 
	"weapons/mp5_clipin.wav", 
	"weapons/mp5_slideback.wav", 
	"weapons/p90_clipout.wav", 
	"weapons/p90_clipin.wav", 
	"weapons/p90_boltpull.wav", 
	"weapons/p90_cliprelease.wav", 
	"weapons/p228_clipout.wav", 
	"weapons/p228_clipin.wav", 
	"weapons/p228_sliderelease.wav", 
	"weapons/p228_slidepull.wav", 
	"weapons/scout_bolt.wav", 
	"weapons/scout_clipin.wav", 
	"weapons/scout_clipout.wav", 
	"weapons/sg550_boltpull.wav", 
	"weapons/sg550_clipin.wav", 
	"weapons/sg550_clipout.wav", 
	"weapons/sg552_clipout.wav", 
	"weapons/sg552_clipin.wav", 
	"weapons/sg552_boltpull.wav", 
	"weapons/ump45_clipout.wav", 
	"weapons/ump45_clipin.wav", 
	"weapons/ump45_boltslap.wav", 
	"weapons/usp_clipout.wav", 
	"weapons/usp_clipin.wav", 
	"weapons/usp_silencer_on.wav", 
	"weapons/usp_silencer_off.wav", 
	"weapons/usp_sliderelease.wav", 
	"weapons/usp_slideback.wav", 
	"weapons/fiveseven_slidepull.wav", 
	"weapons/fiveseven_sliderelease.wav"
} 

public plugin_init( ) 
{ 
	register_plugin( 
		.plugin_name = "Precache X", 
		.version = "1.0", 
		.author = "Dias Leon & DeXTeR" ) 
		
	register_cvar( 
		"PrecacheX", 
		"1.0", 
		4|64|256 ) 
		
	// server_print( "Precache X System: Model Precache Reserved Slots: %i", 512 - ArraySize( ArModel ) )
	server_print( "Precache X System: Sound Precache Reserved Slots: %i", 512 - ArraySize( ArSound ) )
}

public plugin_precache( ) 
{ 
	// ArModel = ArrayCreate( 64, 1 ) 
	ArSound = ArrayCreate( 64, 1 ) 

	// register_forward( FM_PrecacheModel, "fw_PrecacheModel" ) 
	register_forward( FM_PrecacheSound, "fw_PrecacheSound" ) 
	// register_forward( FM_PrecacheModel, "fw_PrecacheModel_Post", 1 ) 
	register_forward( FM_PrecacheSound, "fw_PrecacheSound_Post", 1 ) 
} 
/*
public fw_PrecacheModel( const Model[ ] ) 
{ 
	for( new i = 0; i < sizeof( UnPrecache_ModelList ); i++ ) 
	{ 
		if( equal( Model, UnPrecache_ModelList[ i ] ) ) 
			return FMRES_SUPERCEDE 
	} 
	
	return FMRES_IGNORED 
}

public fw_PrecacheModel_Post( const Model[ ] )
{
	for( new i = 0; i < sizeof( UnPrecache_ModelList ); i++ ) 
	{ 
		if( equal( Model, UnPrecache_ModelList[ i ] ) ) 
			return FMRES_IGNORED 
	} 
	
	new Precached = 0 
	
	for( new i = 0; i < ArraySize( ArModel ); i++ ) 
	{ 
		ArrayGetString( ArModel, i, GTempData, sizeof( GTempData ) ) 
		if( equal( GTempData, Model ) ) { Precached = 1; break; } 
	} 
	
	if( !Precached ) ArrayPushString( ArModel, Model ) 
	return FMRES_IGNORED 
}
*/
public fw_PrecacheSound( const Sound[ ] )
{
	if( Sound[ 0 ] == 'h' && Sound[1] == 'o' ) 
		return FMRES_SUPERCEDE 
	for( new i = 0; i < sizeof(UnPrecache_SoundList); i++ )
	{ 
		if( equal( Sound, UnPrecache_SoundList[ i ] ) ) 
			return FMRES_SUPERCEDE 
	} 
	 
	return FMRES_HANDLED 
} 

public fw_PrecacheSound_Post( const Sound[ ] ) 
{
	if( Sound[0] == 'h' && Sound[1] == 'o') 
		return FMRES_IGNORED 
	for( new i = 0; i < sizeof( UnPrecache_SoundList ); i++ ) 
	{
		if( equal( Sound, UnPrecache_SoundList[ i ] ) )
			return FMRES_IGNORED 
	} 
	
	new Precached = 0 
	
	for( new i = 0; i < ArraySize( ArSound ); i++ ) 
	{ 
		ArrayGetString( ArSound, i, GTempData, sizeof( GTempData ) ) 
		if( equal( GTempData, Sound ) ) { Precached = 1; break; } 
	} 
	
	static Line 
	
	if( !Precached ) 
	{ 
		ArrayPushString( ArSound, Sound )
		Line++ 
	} 
	
	return FMRES_HANDLED 
} 