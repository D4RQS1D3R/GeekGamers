#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

new g_eff_spr_lightning, g_eff_spr_smoke
public plugin_precache()
{
    g_eff_spr_lightning = precache_model("sprites/lgtning.spr")
    g_eff_spr_smoke = precache_model("sprites/black_smoke3.spr")
    
    precache_sound("ambience/thunder_clap.wav")
}

public plugin_init()
{
    register_plugin("Thunder on Death Terrorist","1.4","<VeCo>")
    
    RegisterHam(Ham_Killed,"player","Ham_Player_Killed")
}

public Ham_Player_Killed(id,i_killer, i_shouldgib)
{
    emit_sound(id, CHAN_AUTO, "ambience/thunder_clap.wav", VOL_NORM,ATTN_NORM, 0, PITCH_NORM)
    
    static Float:v_f_origin_start[3], Float:v_f_origin_real_start[3],
    Float:v_f_origin_cache[3], Float:v_f_origin_real_end[3],
    h_trace
    
    entity_get_vector(id,EV_VEC_origin,v_f_origin_start)
    
    v_f_origin_cache[0] = v_f_origin_start[0]
    v_f_origin_cache[1] = v_f_origin_start[1]
    v_f_origin_cache[2] = v_f_origin_start[2] + 8192.0
    
    engfunc(EngFunc_TraceLine, v_f_origin_start,v_f_origin_cache, IGNORE_MONSTERS, 0,h_trace)
    
    get_tr2(h_trace,TR_vecEndPos,v_f_origin_real_end)
    
    v_f_origin_cache[0] = v_f_origin_start[0]
    v_f_origin_cache[1] = v_f_origin_start[1]
    v_f_origin_cache[2] = v_f_origin_start[2] - 8192.0
    
    engfunc(EngFunc_TraceLine, v_f_origin_start,v_f_origin_cache, IGNORE_MONSTERS, 0,h_trace)
    
    get_tr2(h_trace,TR_vecEndPos,v_f_origin_real_start)
    
    engfunc(EngFunc_MessageBegin, MSG_PVS,SVC_TEMPENTITY, v_f_origin_start, 0)
    write_byte(TE_BEAMPOINTS)
    engfunc(EngFunc_WriteCoord,v_f_origin_start[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[2])
    engfunc(EngFunc_WriteCoord,v_f_origin_real_end[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_real_end[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_real_end[2])
    write_short(g_eff_spr_lightning)
    write_byte(0)
    write_byte(0)
    write_byte(6)
    write_byte(30)
    write_byte(10)
    write_byte(0)
    write_byte(200)
    write_byte(255)
    write_byte(220)
    write_byte(0)
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_PVS,SVC_TEMPENTITY, v_f_origin_start, 0)
    write_byte(TE_BEAMCYLINDER)
    engfunc(EngFunc_WriteCoord,v_f_origin_start[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[2] - 16.0)
    engfunc(EngFunc_WriteCoord,v_f_origin_start[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[2] + 32.0)
    write_short(g_eff_spr_lightning)
    write_byte(0)
    write_byte(0)
    write_byte(5)
    write_byte(32)
    write_byte(0)
    write_byte(0)
    write_byte(200)
    write_byte(255)
    write_byte(220)
    write_byte(0)
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_PVS,SVC_TEMPENTITY, v_f_origin_start, 0)
    write_byte(TE_SMOKE)
    engfunc(EngFunc_WriteCoord,v_f_origin_start[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_start[2] - 16.0)
    write_short(g_eff_spr_smoke)
    write_byte(7)
    write_byte(30)
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_PVS,SVC_TEMPENTITY, v_f_origin_start, 0)
    write_byte(TE_WORLDDECAL)
    engfunc(EngFunc_WriteCoord,v_f_origin_real_start[0])
    engfunc(EngFunc_WriteCoord,v_f_origin_real_start[1])
    engfunc(EngFunc_WriteCoord,v_f_origin_real_start[2])
    write_byte(46)
    message_end()
    
    SetHamParamInteger(3,2)
    
    return HAM_IGNORED
}