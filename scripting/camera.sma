#include <amxmodx>
#include <engine>
#include <amxmisc>

public plugin_init()
{
    register_plugin("Camera Changer", "1.0", "~DarkSiDeRs~")
    register_menucmd(register_menuid("Choose Camera View"), 1023, "setview") 

    register_clcmd("say /camera", "chooseview")
    register_clcmd("say_team /camera", "chooseview")

    register_clcmd("say /cam", "chooseview")
    register_clcmd("say_team /cam", "chooseview")    
}

public plugin_modules()
{
    require_module("engine")
}

public plugin_precache()
{
    precache_model("models/rpgrocket.mdl")
}

public chooseview(id)
{
    new menu[192] 
    new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3 
    format(menu, 191, "\d[\yGeek~Gamers\d] \rChoose Camera View:^n^n\r1. \w3rd Person View^n\r2. \wNormall View^n^n\r0. \wExit") 
    show_menu(id, keys, menu)      
    return PLUGIN_CONTINUE
}

public setview(id, key, menu)
{
    if(key == 0)
    {
	 if(is_user_alive(id))
	 {
         	set_view(id, CAMERA_3RDPERSON)
		chooseview(id)
	 }
	 else
	 {
	 	set_view(id, CAMERA_NONE)
	 	chooseview(id)
	 }
         return PLUGIN_HANDLED
    }

    if(key == 1) {
         set_view(id, CAMERA_NONE)
	 chooseview(id)
         return PLUGIN_HANDLED
    }

    return PLUGIN_HANDLED
}