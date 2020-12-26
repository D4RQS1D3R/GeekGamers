#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <colorchat>

#define SIZE    20
#define ACCESS        ADMIN_LEVEL_B

new const PLUGIN[]     = "[GG] Reset Score"
new const VERSION[]     = "4.4" 
new const AUTHOR[]     = "~D4rkSiD3Rs~"

new const RsNew1[] = "vox/access.wav"
new const RsNew2[] = "vox/denied.wav"

new pcvar_Advertise_Chat
new pcvar_Advertise_Hud
new pcvar_Show
new pcvar_Time
new pcvar_Prefix[SIZE]
new pcvar_Menu[40]

public plugin_init()
{
    register_plugin( PLUGIN, VERSION, AUTHOR )
    
    register_srvcmd("rs_prefix", "tag")

    /*Reset Score Menu*/
    register_clcmd("say /rsmenu", "mainMenu")
    register_clcmd("say_team /rsmenu", "mainMenu")
    
    /*Say commands*/
    register_clcmd("say /rs", "rs")
    register_clcmd("say /resetscore", "rs")
    register_clcmd("say /restartscore", "rs")
    register_clcmd("say /rd", "rd")
    
    /*Say_team commands*/
    register_clcmd("say_team /rs", "rs")
    register_clcmd("say_team /resetscore", "rs")
    register_clcmd("say_team /restartscore", "rs")
        
    /*Access to commands have only admin with "d" flag*/
   
    pcvar_Time = register_cvar("rs_time", "600.0", ADMIN_BAN)
    
    pcvar_Advertise_Hud = register_cvar("rs_advertise_hud", "0", ADMIN_LEVEL_C)

    pcvar_Advertise_Chat = register_cvar("rs_advertise_chat", "1", ADMIN_LEVEL_C)
    
    if(get_pcvar_num(pcvar_Advertise_Hud) == 1)
    {
        set_task(get_pcvar_float(pcvar_Time), "advertise_hud", _, _, _, "b")
    }
}

public plugin_precache()
{
    precache_sound(RsNew1)
    precache_sound(RsNew2)
}

public tag()
{    
    remove_task(123)    /* Delete old message */
    read_argv(1, pcvar_Prefix, SIZE-1)
}

public rs(id)
{
    cs_set_user_deaths(id, 0)
    set_user_frags(id, 0)
    cs_set_user_deaths(id, 0)
    set_user_frags(id, 0)

    new name[33]
    get_user_name(id, name, 32)

    //ColorChat(0, TEAM_COLOR, "^4[GG] ^3%s ^1Has Restarted ^4Score ^1!", name)
    ColorChat(id, NORMAL, "^4[GG][Reset Score] ^1You Have Restarted Your ^4Score ^1!")
}

public rd(id)
{
    if( !(get_user_flags( id ) & ACCESS ) )     /*Access to comand have only admin with "d" flag*/
    {
        return PLUGIN_CONTINUE
    }

    cs_set_user_deaths(id, 0)
    cs_set_user_deaths(id, 0)

    return PLUGIN_HANDLED
}

public client_putinserver(id)
{
    if(get_pcvar_num(pcvar_Advertise_Chat) == 1)
    {
        set_task(10.0, "advertise_chat", id, _, _, "a", 1) 
    }
}

public advertise_chat(id)
{
    if(is_user_connected(id))
    {
        /*Message show when player connect. You can turn it of with cvar "rs_advertise_chat 0"*/
        ColorChat(id, TEAM_COLOR, "^4%s[GG][Reset Score] ^1To Restart ^4Score ^1Say: ^3/rs^1, ^3/resetscore ^1or ^3/restartscore ^1!", pcvar_Prefix)
    }
}

public advertise_hud()
{
    /*Message show in Hud. You can turn it of with cvar "rs_advertise_hud 0"*/
    set_hudmessage(255, 0, 0, -1.0, 0.20, 2, 2.0, 12.0)
    show_hudmessage(0, "To Restart Score Say /rs, /resetscore or /restartscore !")
}

public noAccess(id)
{
client_cmd(id, "spk %s", RsNew2)
}

public mainMenu( id )
{    
    if( !(get_user_flags( id ) & ACCESS ) )     /*Access to comand have only admin with "d" flag*/
    {
    ColorChat(id, TEAM_COLOR,"^4[%s] ^1You Have No ^4Access ^1To This ^3Command ^1!", pcvar_Prefix)
    client_cmd(id, "spk %s", RsNew1)
    set_task(0.6, "noAccess", id, _, _, "a", 1)
    return PLUGIN_CONTINUE
    }
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\r[Rs *New*] - Menu")
    new menu = menu_create( pcvar_Menu, "menuMain" )
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Show \r[\d%i\r]", get_pcvar_num(pcvar_Show))
    menu_additem( menu, pcvar_Menu, "0" )
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Time \r[\d%i\d min\r]", get_pcvar_num(pcvar_Time)/60)
    menu_additem( menu, pcvar_Menu, "1" )    
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Hud Advertise \r[\d%i\r]", get_pcvar_num(pcvar_Advertise_Hud))    
    menu_additem( menu, pcvar_Menu, "2" )
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Chat Advertise \r[\d%i\r]", get_pcvar_num(pcvar_Advertise_Chat))
    menu_additem( menu, pcvar_Menu, "3" )
        
    formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d How To Change Prefix?")
    menu_additem( menu, pcvar_Menu, "4" )
        
    menu_display( id, menu )
        
    return PLUGIN_CONTINUE
}
    
public menuMain( id, menu, item )
{
    if( item >= 0 ) 
    {
    new access, callback, actionString[ 2 ]        
    menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback )        
        
    new action = str_to_num( actionString )
    {
        switch( action )
            {
            case 0:
                {
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\r[Rs *New*] - Menu")
                new menu = menu_create( pcvar_Menu, "menu1" )
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Show Enabled")
                menu_additem( menu, pcvar_Menu, "0" )
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Show Disabled")
                menu_additem( menu, pcvar_Menu, "1" )
                
                menu_display( id, menu )
                }
                    
            case 1:
                {
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\r[Rs *New*] - Menu")
                new menu = menu_create( pcvar_Menu, "menu2" )
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 1 min")
                menu_additem( menu, pcvar_Menu, "0")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 2 min")
                menu_additem( menu, pcvar_Menu, "1")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 3 min")
                menu_additem( menu, pcvar_Menu, "2")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 4 min")
                menu_additem( menu, pcvar_Menu, "3")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 5 min")
                menu_additem( menu, pcvar_Menu, "4")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Message on 10 min")
                menu_additem( menu, pcvar_Menu, "5")
                
                menu_display( id, menu )
                }
                    
            case 2:
                {
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\r[Rs *New*] - Menu")
                new menu = menu_create( pcvar_Menu, "menu3")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Hud Advertise Enabled")
                menu_additem( menu, pcvar_Menu, "0")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Hud Advertise Disabled")
                menu_additem( menu, pcvar_Menu, "1")
                
                menu_display( id, menu ) 
                }
                    
            case 3:
                {
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\r[Rs *New*] - Menu")
                new menu = menu_create( pcvar_Menu, "menu4")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Chat Advertise Enabled")
                menu_additem( menu, pcvar_Menu, "0")
                
                formatex( pcvar_Menu, charsmax( pcvar_Menu ), "\d Chat Advertise Disabled")
                menu_additem( menu, pcvar_Menu, "1")
                
                menu_display( id, menu )
                }
                    
            case 4:
                {
                rsMotd(id)
                set_task(0.1, "mainMenu", id, _, _, "a", 1)
                }
            }
        }    
    }
    menu_destroy( menu )
    return PLUGIN_HANDLED   
   }
   public menu1( id, menu, item ) 
{ 
    if( item >= 0 )  
    { 
    new access, callback, actionString[ 2 ]         
    menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback )         
         
    new action = str_to_num( actionString ) 
    { 
        switch( action ) 
            { 
            case 0: 
                { 
                server_cmd("rs_show 1") 
                } 
                     
            case 1: 
                { 
                server_cmd("rs_show 0")  
                } 
            } 
        ColorChat(id, TEAM_COLOR,"^4[%s] ^1Changes Are ^4Saved ^1Succesfully !", pcvar_Prefix) 
        }     
    }    
    menu_destroy( menu ) 
    set_task(0.1, "mainMenu", id, _, _, "a", 1) 
    return PLUGIN_HANDLED 
} 

public menu2( id, menu, item ) 
{ 
    if( item >= 0 )  
    { 
    new access, callback, actionString[ 2 ]         
    menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback )         
         
    new action = str_to_num( actionString ) 
    { 
        switch( action ) 
            { 
            case 0: 
                { 
                server_cmd("rs_time 60") 
                } 
                     
            case 1: 
                { 
                server_cmd("rs_time 120")  
                } 
                     
            case 2: 
                { 
                server_cmd("rs_time 180")  
                } 
                     
            case 3: 
                { 
                server_cmd("rs_time 240")  
                } 
                     
            case 4: 
                { 
                server_cmd("rs_time 300")  
                } 
                     
            case 5: 
                { 
                server_cmd("rs_time 600") 
                } 
            } 
        ColorChat(id, TEAM_COLOR,"^4[%s] ^1Changes Are ^4Saved ^1Succesfully !", pcvar_Prefix) 
        }     
    } 
    menu_destroy( menu ) 
    set_task(0.1, "mainMenu", id, _, _, "a", 1) 
    return PLUGIN_HANDLED     
} 
  
public menu3( id, menu, item ) 
{ 
    if( item >= 0 )  
    { 
    new access, callback, actionString[ 2 ]         
    menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback )         
         
    new action = str_to_num( actionString ) 
    { 
        switch( action ) 
            { 
            case 0: 
                { 
                server_cmd("rs_advertise_hud 1") 
                } 
                     
            case 1: 
                { 
                server_cmd("rs_advertise_hud 0")  
                } 
            } 
        ColorChat(id, TEAM_COLOR,"^4[%s] ^1Changes Are ^4Saved ^1Succesdully !", pcvar_Prefix) 
        }     
    } 
         
    menu_destroy( menu ) 
    set_task(0.1, "mainMenu", id, _, _, "a", 1) 
    return PLUGIN_HANDLED     
} 

public menu4( id, menu, item ) 
{ 
    if( item >= 0 )  
    { 
    new access, callback, actionString[ 2 ]         
    menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback )         
         
    new action = str_to_num( actionString ) 
    { 
        switch( action ) 
            { 
            case 0: 
                { 
                server_cmd("rs_advertise_chat 1") 
                } 
                     
            case 1: 
                { 
                server_cmd("rs_advertise_chat 0")  
                } 
            } 
        ColorChat(id, TEAM_COLOR,"^4[%s] ^1Changes Are ^4Saved ^1Succesfully !", pcvar_Prefix) 
        }     
    } 
    menu_destroy( menu ) 
    set_task(0.1, "mainMenu", id, _, _, "a", 1) 
    return PLUGIN_HANDLED     
} 
   
public rsMotd(id) 
{ 
    static motd[1501], len 
     
    len = format(motd, 1500,"<body bgcolor=#000000><font color=#87cefa><pre>") 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"green^"><B>How to change prefix?</B> </font></h4></center>", PLUGIN, VERSION) 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"white^"><B></B> </font></h4></center>") 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"white^">Open amxmodx/configs/amxx.cfg</font></h4></center>") 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"white^">In the end of file type:</font></h4></center>")     
    len += format(motd[len], 1500-len,"<center><h4><font color=^"green^">rs_prefix ^"Your Text^"</font></h4></center>") 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"white^"><B></B> </font></h4></center>") 
    len += format(motd[len], 1500-len,"<center><h4><font color=^"white^">In gam you have this result:</font></h4></center>") 
    len += format(motd[len], 1500-len,"<center><font color=^"white^"><font color=^"green^">[Your Text]</font> You Have Restarted Score!</font></center>") 
     
    show_motd(id, motd, "[Rs *New*] - Info") 
     
    return 0 
} 
/*End*/ 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
