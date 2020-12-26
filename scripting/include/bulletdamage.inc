#if defined _bulletdamage_included
	#endinput
#endif
#define _bulletdamage_included


/*
*	style :
*		0 = Show Director HudMessage
*		1 = Show HudMessage
*	Attacker :
*		0 = Index isn't the attacker ( Default = Show red color at the left )
*		1 = Index is the attacker ( Default = Show green color at the right )
*/
native bd_show_damage( index, damage, style, Attacker )

/*
*	Attacker :
*		0 = Index isn't the attacker ( Default = Show red color at the left )
*		1 = Index is the attacker ( Default = Show green color at the right )
*	Size :
*		0 = DIRECTOR HUD MESSAGE SIZE
*		1 = HUD MESSAGE SIZE
*/
native bd_show_text( index, Attacker, text[], Size )



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
