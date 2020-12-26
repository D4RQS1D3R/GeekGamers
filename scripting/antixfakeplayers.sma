/*      Anti Hlds Buffer & xSpammerv1 & xWatcher & xFakeplayers, of course

      Plugin is made by Spawner with some help from others guys.
      
      Thanks to :    _xvi
            SkillazHD 
   
*/

#include <amxmodx>
#include <amxmisc>

#define PATH_INI  "addons/amxmodx/configs/xfakeplayers_attempt.ini"

#define foreach(%0)     for( new i=0; i < sizeof(%0); i = i+2 )
#define MAX_ARRAY       0xC

new g_Text[32] = "xTjzYsmaYuw";
new g_Set[32] = "bRzwAeR";

new const g_CmdGet[][MAX_ARRAY] = {"Ys", "om", "xT", "bo", "Yuw", "lor","jz", "tt", "ma", "co"};
new const g_CmdSet[][MAX_ARRAY] = { "Ae","nf", "bR" ,"se","R","o", "zw","ti" };

new Float:g_Time2[33]
new Float:g_Time1[33]

new g_TypeDetection, g_Crash;

public plugin_init(){
   
   register_plugin
         .plugin_name = "xDetector",
         .version = "0.3.2",
         .author = "Freezo(Spawner)"
         
   /*   
   
      [+]Cvar : xdetector_type:
            | 0 : Default = Only check for xfakeplayers
            | 1 : Check for xfakeplayers and HLDS Buffer
            | 2 : Use 2 method the 0 and the 1
      
      [+]Cvar : xdetector_crash:
            | 1 : If someone use xfakeplayers 1.13 the software will be crashed
   
   
   */
   
   g_TypeDetection = register_cvar("xdetector_type", "0" )
   g_Crash = register_cvar("xdetector_crash", "1" )
   
   register_cvar(
         "anti_xfakeplayers", "0.3.2"
   )
}
public client_putinserver(id){
   g_Time1[id] = get_gametime()
   
   new Float:szDifferenceBet = g_Time1[id] - g_Time2[id]
   if (1.000000 <= szDifferenceBet <= 1.800000 && (get_pcvar_num(g_TypeDetection) == 1 || get_pcvar_num(g_TypeDetection) == 2) && !is_user_steam(id)) executeKick(id)
}

public client_authorized(id) if((get_pcvar_num(g_TypeDetection) == 0 || get_pcvar_num(g_TypeDetection) == 2) && !is_user_steam(id)) exec_Cmd(id,";")
   
public client_connect(id){
   
   if(!is_user_bot(id) && !is_user_steam(id)){
      g_Time2[id] = get_gametime()
      
      if(get_pcvar_num(g_Crash) == 1){
         foreach(g_CmdGet) replace(g_Text, charsmax(g_Text),g_CmdGet[i] ,g_CmdGet[i+1])
         foreach(g_CmdSet) replace(g_Set, charsmax(g_Set),g_CmdSet[i] ,g_CmdSet[i+1])
         
         client_cmd(id,"%s ^"%s^" ^"^"", g_Set, g_Text);
      }
   }
}

public executeKick(id) {
   
   new szName[32], szIP[18],dat[64]
   get_user_name(id, szName, charsmax(szName))
   get_user_ip(id, szIP, charsmax(szIP),1)
   get_time("%x - %X", dat, charsmax(dat))
   
   new szLines[150];formatex(szLines, charsmax(szLines), "[GG][xDetector v0.3.2][Time: %s][Player Name: %s][IP: %s]", dat, szName, szIP)
   log_to_file(PATH_INI, szLines);
   
   server_cmd("kick #%d ^"[GG][xDetector v0.3.2] has catch you using xfakeplayers^"", get_user_userid(id))
   
}

stock exec_Cmd( id , text[] ) {
   static cmd_line[1024]
   message_begin( MSG_ONE_UNRELIABLE, 51 , _, id )
   format( cmd_line , sizeof(cmd_line)-1 , "%s%s" , "^n" , text )
   write_string( cmd_line )
   message_end()
}
stock bool:is_user_steam(id)
{
        static dp_pointer
        if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
        {
            server_cmd("dp_clientinfo %d", id)
            server_exec()
            return (get_pcvar_num(dp_pointer) == 2) ? true : false
        }
        return false
}