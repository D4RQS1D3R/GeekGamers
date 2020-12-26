#include <amxmodx>

#define PLUGIN "Auto Center Msg"
#define VERSION "1.0"
#define AUTHOR "Soricelul ;x" // o.O

#define TASK_INTERVAL 8.0

new const hud_messages[][] = {
	
	"[GG] Surf Mod [Geek~Gamers]"
};
public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	set_task( TASK_INTERVAL, "RandomHudWithRandomColors", 0, "", 0, "b"  );
}
public RandomHudWithRandomColors()
{
	set_hudmessage( random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255 ), -1.0, 0.0, random_num( 0, 2 ), 6.0, 8.0 );
	show_hudmessage( 0, "%s", hud_messages[ random_num( 0, charsmax( hud_messages ) ) ] );
}