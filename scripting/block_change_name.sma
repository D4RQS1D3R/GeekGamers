#include <amxmodx>
#include <fakemeta>

#define VERSION "0.1.0"

public plugin_init()
{
    register_plugin("One Name", VERSION, "ConnorMcLeod")
    register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
}

public ClientUserInfoChanged(id)
{
    static const name[] = "name"
    static szOldName[32], szNewName[32]
    pev(id, pev_netname, szOldName, charsmax(szOldName))
    if( szOldName[0] )
    {
        get_user_info(id, name, szNewName, charsmax(szNewName))
        if( !equal(szOldName, szNewName) )
        {
            set_user_info(id, name, szOldName)
            return FMRES_HANDLED
        }
    }
    return FMRES_IGNORED
}