/*
*   http://games.qwerty.ru
*
*	AmxModX
*   Vampire plugin
*    by Shalfey

*
*   CVars
*   amx_vampire_hp - hp add for kill
*   amx_vampire_hp_hs - hp add for kill in head
*   amx_vampire_max_hp - max player hp
*
*   Players gets HP for kills.
*/
#include <amxmodx>
#include <fun>

#define PLUGIN_VERSION "1.0c"

new health_add
new health_hs_add

new nKiller
new nKiller_hp
new nHp_add

public plugin_init()
{
   register_plugin("Vampire", PLUGIN_VERSION, "Shalfey")

   health_add = register_cvar("amx_vampire_hp", "10")
   health_hs_add = register_cvar("amx_vampire_hs", "15")

   register_event("DeathMsg", "hook_death", "a", "1>0") 	
}

public hook_death()
{
   // Killer id
   nKiller = read_data(1)

   if ( (read_data(3) == 1) && (read_data(5) == 0) )
   {
      nHp_add = get_pcvar_num (health_hs_add)
   }
   else
      nHp_add = get_pcvar_num (health_add)

   // Updating Killer HP
   nKiller_hp = get_user_health(nKiller)
   nKiller_hp += nHp_add


   set_user_health(nKiller, nKiller_hp)

   // Hud message "Healed +15/+40 hp"
   set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1)
   show_hudmessage(nKiller, "Bonus: +%d HP", nHp_add)

   // Screen fading
   message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, nKiller)
   write_short(1<<10)
   write_short(1<<10)
   write_short(0x0000)
   write_byte(0)
   write_byte(0)
   write_byte(200)
   write_byte(75)
   message_end()
   
} 
