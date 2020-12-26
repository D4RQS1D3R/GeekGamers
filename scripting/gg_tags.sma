#include <amxmodx>
#include <amxmisc>

#pragma compress 1

#define PLUGIN "[GG] Tags"
#define VERSION "2.0"
#define AUTHOR "~D4rkSiD3Rs~"

#define ACCESS_LEVEL ADMIN_LEVEL_B
#define ADMIN_LISTEN ADMIN_LEVEL_B

new message[192]
new sayText
new teamInfo
new maxPlayers

new g_MessageColor
new g_NameColor
new g_AdminListen

new strName[191]
new strText[191]
new alive[11]

new const g_szTag[][] = {
    "", // DO NOT REMOVE
    "OWNER",
    "CO-OWNER",
    "DIAMOND-VIP",
    "GOLD-VIP",
    "SILVER-VIP",
    "VIP"
}

new const g_iTagFlag[sizeof(g_szTag)] = {
    ADMIN_ALL, // DO NOT REMOVE
    ADMIN_LEVEL_B,
    ADMIN_LEVEL_C,
    ADMIN_LEVEL_D,
    ADMIN_LEVEL_E,
    ADMIN_LEVEL_F,
    ADMIN_LEVEL_G
}

native get_level(id)

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    g_MessageColor = register_cvar("amx_color", "2") // Message colors: [1] Default Yellow, [2] Green, [3] White, [4] Blue, [5] Red
    g_NameColor = register_cvar("amx_namecolor", "6") // Name colors: [1] Default Yellow, [2] Green, [3] White, [4] Blue, [5] Red, [6] Team-color
    g_AdminListen = register_cvar("amx_listen", "1") // Set whether admins see or not all messages(Alive, dead and team-only)


    sayText = get_user_msgid("SayText")
    teamInfo = get_user_msgid("TeamInfo")
    maxPlayers = get_maxplayers()


    register_message(sayText, "avoid_duplicated")

    register_concmd("amx_color", "set_color", ACCESS_LEVEL, "<color>")
    register_concmd("amx_namecolor", "set_name_color", ACCESS_LEVEL, "<color>")
    register_concmd("amx_listen", "set_listen", ACCESS_LEVEL, "<1 | 0>")
    register_clcmd("say", "hook_say")
    register_clcmd("say_team", "hook_teamsay")
}


public avoid_duplicated(msgId, msgDest, receiver)
{
    return PLUGIN_HANDLED
}

get_tag_index(id)
{
    new flags = get_user_flags(id)
    
    for(new i = 1; i < sizeof(g_iTagFlag); i++)
    {
        if(check_admin_flag(flags, g_iTagFlag[i]))
        {
            return i
        }
    }
    
    return 0
}

check_admin_flag(flags, flag)
{
    if(flag == ADMIN_ADMIN)
    {
        return ((flags & ~ADMIN_USER) > 0)
    }
    else if(flag == ADMIN_ALL)
    {
        return 1
    }
    
    return (flags & flag)
}

public hook_say(id)
{
    read_args(message, 191)
    remove_quotes(message)

    // Gungame commands and empty messages
    if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
        return PLUGIN_CONTINUE

    new name[32]
    get_user_name(id, name, 31)

    new admin = get_tag_index(id)

    new isAlive

    if(is_user_alive(id))
    {
        isAlive = 1
        alive = "^x01"
    }
    else
    {
        isAlive = 0
        alive = "^x01*DEAD* "
    }

    static color[10]

    if(admin)
    {
        // Name
        switch(get_pcvar_num(g_NameColor))
        {
            case 1:
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] %s", alive, g_szTag[admin], get_level(id), name)
            case 2:
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] ^x04%s ", alive, g_szTag[admin], get_level(id), name)
            case 3:
            {
                color = "SPECTATOR"
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] ^x03%s ", alive, g_szTag[admin], get_level(id), name)
            }
            case 4:
            {
                color = "CT"
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, g_szTag[admin], get_level(id), name)
            }
            case 5:
            {
                color = "TERRORIST"
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, g_szTag[admin], get_level(id), name)
            }
            case 6:
            {
                get_user_team(id, color, 9)
                format(strName, 191, "%s^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, g_szTag[admin], get_level(id), name)
            }
        }

        // Message
        switch(get_pcvar_num(g_MessageColor))
        {
            case 1:    // Yellow
                format(strText, 191, "%s", message)
            case 2:    // Green
                format(strText, 191, "^x04%s", message)
            case 3:    // White
            {
                copy(color, 9, "SPECTATOR")
                format(strText, 191, "^x03%s", message)
            }
            case 4:    // Blue
            {
                copy(color, 9, "CT")
                format(strText, 191, "^x03%s", message)
            }
            case 5:    // Red
            {
                copy(color, 9, "TERRORIST")
                format(strText, 191, "^x03%s", message)
            }
        }
    }
    else     // Player is not admin. Team-color name : Yellow message
    {
        get_user_team(id, color, 9)
        format(strName, 191, "%s^x04[LEVEL %i] ^x03%s", alive, get_level(id), name)
        format(strText, 191, "%s", message)
    }

    format(message, 191, "%s^x01 : %s", strName, strText)

    sendMessage(color, isAlive)    // Sends the colored message

    return PLUGIN_CONTINUE
}

public hook_teamsay(id)
{
    new playerTeam = get_user_team(id)
    new playerTeamName[19]

    switch(playerTeam) // Team names which appear on team-only messages
    {
        case 1:
            copy(playerTeamName, 11, "Furiens")

        case 2:
            copy(playerTeamName, 18, "Anti-Furiens")

        default:
            copy(playerTeamName, 9, "SPECTATOR")
    }

    read_args(message, 191)
    remove_quotes(message)

    // Gungame commands and empty messages
    if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
        return PLUGIN_CONTINUE

    new name[32]
    get_user_name(id, name, 31)

    new admin = get_tag_index(id)

    new isAlive

    if(is_user_alive(id))
    {
        isAlive = 1
        alive = "^x01"
    }
    else
    {
        isAlive = 0
        alive = "^x01*DEAD* "
    }

    static color[10]

    if(admin)
    {
        // Name
        switch(get_pcvar_num(g_NameColor))
        {
            case 1:
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] %s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            case 2:
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] ^x04%s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            case 3:
            {
                color = "SPECTATOR"
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            }
            case 4:
            {
                color = "CT"
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            }
            case 5:
            {
                color = "TERRORIST"
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            }
            case 6:
            {
                get_user_team(id, color, 9)
                format(strName, 191, "%s(%s) ^x04[^x03%s^x04] [LEVEL %i] ^x03%s", alive, playerTeamName, g_szTag[admin], get_level(id), name)
            }
        }

        // Message
        switch(get_pcvar_num(g_MessageColor))
        {
            case 1:    // Yellow
                format(strText, 191, "%s", message)
            case 2:    // Green
                format(strText, 191, "^x04%s", message)
            case 3:    // White
            {
                copy(color, 9, "SPECTATOR")
                format(strText, 191, "^x03%s", message)
            }
            case 4:    // Blue
            {
                copy(color, 9, "CT")
                format(strText, 191, "^x03%s", message)
            }
            case 5:    // Red
            {
                copy(color, 9, "TERRORIST")
                format(strText, 191, "^x03%s", message)
            }
        }
    }
    else     // Player is not admin. Team-color name : Yellow message
    {
        get_user_team(id, color, 9)
        format(strName, 191, "%s(%s) ^x04[LEVEL %i] ^x03%s", alive, playerTeamName, get_level(id), name)
        format(strText, 191, "%s", message)
    }

    format(message, 191, "%s ^x01: %s", strName, strText)

    sendTeamMessage(color, isAlive, playerTeam)    // Sends the colored message

    return PLUGIN_CONTINUE
}


public set_color(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newColor
    read_argv(1, arg, 1)

    newColor = str_to_num(arg)

    if(newColor >= 1 && newColor <= 5)
    {
        set_pcvar_num(g_MessageColor, newColor)

        if(get_pcvar_num(g_NameColor) != 1 &&
            ((newColor == 3 &&  get_pcvar_num(g_NameColor) != 3)
            ||(newColor == 4 &&  get_pcvar_num(g_NameColor) != 4)
            ||(newColor == 5 &&  get_pcvar_num(g_NameColor) != 5)))
        {
            set_pcvar_num(g_NameColor, 2)
        }
    }

    return PLUGIN_HANDLED
}


public set_name_color(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newColor
    read_argv(1, arg, 1)

    newColor = str_to_num(arg)

    if(newColor >= 1 && newColor <= 6)
    {
        set_pcvar_num(g_NameColor, newColor)

        if((get_pcvar_num(g_MessageColor) != 1
            &&((newColor == 3 &&  get_pcvar_num(g_MessageColor) != 3)
            ||(newColor == 4 &&  get_pcvar_num(g_MessageColor) != 4)
            ||(newColor == 5 &&  get_pcvar_num(g_MessageColor) != 5)))
            || get_pcvar_num(g_NameColor) == 6)
        {
            set_pcvar_num(g_MessageColor, 2)
        }
    }

    return PLUGIN_HANDLED
}


public set_listen(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newListen
    read_argv(1, arg, 1)

    newListen = str_to_num(arg)

    set_pcvar_num(g_AdminListen, newListen)

    return PLUGIN_HANDLED
}


public sendMessage(color[], alive)
{
    new teamName[10]

    for(new player = 1; player < maxPlayers; player++)
    {
        if(!is_user_connected(player))
            continue

        get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
        changeTeamInfo(player, color)        // Changes user's team according to color choosen
        writeMessage(player, message)        // Writes the message on player's chat
        changeTeamInfo(player, teamName)    // Changes user's team back to original
    }
}


public sendTeamMessage(color[], alive, playerTeam)
{
    new teamName[10]

    for(new player = 1; player < maxPlayers; player++)
    {
        if(!is_user_connected(player))
            continue

        if(get_user_team(player) == playerTeam || (get_pcvar_num(g_AdminListen) && get_user_flags(player) & ADMIN_LISTEN))
        {
            get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
            changeTeamInfo(player, color)        // Changes user's team according to color choosen
            writeMessage(player, message)        // Writes the message on player's chat
            changeTeamInfo(player, teamName)    // Changes user's team back to original
        }
    }
}


public changeTeamInfo(player, team[])
{
    message_begin(MSG_ONE, teamInfo, _, player)    // Tells to to modify teamInfo(Which is responsable for which time player is)
    write_byte(player)                // Write byte needed
    write_string(team)                // Changes player's team
    message_end()                    // Also Needed
}


public writeMessage(player, message[])
{
    message_begin(MSG_ONE, sayText, {0, 0, 0}, player)    // Tells to modify sayText(Which is responsable for writing colored messages)
    write_byte(player)                    // Write byte needed
    write_string(message)                    // Effectively write the message, finally, afterall
    message_end()                        // Needed as always
}  