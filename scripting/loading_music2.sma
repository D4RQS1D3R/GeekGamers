/*  AMX Mod X script.
    
    Loading Music II plugin

    (c) Copyright 2006-2007, Simon Logic 'slspam@land.ru'
    This file is provided AS IS (no warranties).
    
    Original idea by White Panther (plugin ConnectSound).

    Preamble:
	    * this plugin is intended to completely replace all the following
    	plugins: Loading Song (by Torch), Loading Song Advanced (by eFrigid) &
	    Loading Sound (by [OSA]Odin). This plugin will never replace 
    	Loading Music (by Andrax2000) cause i don't like that concept.

    Info:
    	* plugin for playing sound file or music track during connection to the
	    server, first team selection (under CS only) or during spectator mode.
    
    Features:
	    * support for mp3/wav files
    	* playlist support ($AMXMODX/config/loading_music.ini or hardcoded by 
	    g_sDefaultPlaylist array)
    	* support for separate playlist for each map (usage: just create 
    	a playlist $AMXMODX/config/loading_music/<mapname>.ini)
		* support for separate playlist for each group of maps (usage: just 
		create a playlist $AMXMODX/config/loading_music/<prefix>_.ini)
    	* up to 30 filenames (can be changed by MAX_TRACKS macro in the script)
    	* playlist-random/playlist-single-file/single-file playback modes
	    * precaching of any file within $AMXMODX/sound/ folder (in playlist 
    	playback mode only)
	    * fadeout effect for mp3 tracks
    	* and more...

    Notes:
	    * mp3/wav files can be placed anywhere within $MODDIR/, but only under
    	$MODDIR/sound/ folder they will be precached
	    * external playlist editing rules see inside .ini file supplied 
	    with plugin
    
    Requirements:
    	* any mod (preferably HLDM/CS/CZ)
    	* AMX/X 1.7x (or higher)
    	* Fakemeta module

    New cvars:
    * amx_loading_track <number|filename> (default=-1)
        sets playback mode:
        -1 - random order
         0 - play nothing (disable plugin)
         N - play single file from playlist (N=1..30)
         filename - name of file to play ignoring the playlist (it's 
         a single-file playback mode); if this file is under precache dir 
         it won't be precached yet
    * amx_loading_loop <0|1|2> (default=0)
        customizes loop mode playback:
        0 - play mp3/wav until a player starts to play
        1 - play mp3 once till the end; play wav as described above
        2 - play mp3/wav forever (strongly do not recommend 
        if 'amx_loading_flags' cvar has no flag 'a')
    * amx_loading_delay <float> (default=0.0)
        if your clients often complain about silence while connecting to your
        server try to set this cvar to non-zero number to delay (in sec)
        playback after connection event has been triggered
	* amx_loading_flags <flags> (default=abc)
        a - play mp3 files only on player connection/spectating; otherwise
        wav files are possible (strongly do not recommend to turn this flag 
        OFF because you may get an unstoppable ambient cyclic sound during 
        the game)
        b - play mp3 on spectate; otherwise stop playing track when player 
        goes to spectator
        c - (CS specific) play wav files only on team select; otherwise
        connection track will continue playing (under CS it can be turned off
        by the game; try using flag 'd' to fix this issue)
		d - (CS specific) restart a track on team select to fix a CS bug;
		has minor priority than flag 'c'
		e - don't play a spectator track on dead players (consider to use it
		if you enabled flag 'b')

    Known issues:
   		* mp3 track will continue playing if player disconnects before 
	    he is spawned for the first time; in such a case client should manually 
   		execute 'mp3 stop' or 'stopsound' command in console to stop playing a 
	    track (impossible to fix)
   		* on loading you may notice a short gap while music is playing;
	    it's a client related problem (impossible to fix)

    TODO:
    	* apply fadeout effect for wav files

    Credits:
		* White Panther for the idea

    History:
    1.2.9 [2007-05-05]
	! fixed a bug when the last player in team was dead after new round a track
	was played on him till the end; this bug occasionally occured under CS 
	when flag 'b' was active
	+ added new flag 'e' to not play a track on dead players when they 
	temporarily become a spectators
    1.2.8 [2007-03-31]
    ! fixed improper storing of file extension
	! fixed a potential bug when mp3 files under 'sound' folder were not been
	precached 
    1.2.7 [2007-03-23]
	+ added support for separate config files for maps by prefix 
	(again req. by arkshine)
    1.2.6 [2007-03-06]
    + added support for separate config files for each map (req. by arkshine)
    1.2.5 [2007-02-15]
    + added public cvar 'version_loading_music2'
    1.2.4 [2007-01-26]
	! fixed a bug when wav samples were heard by every player on team
	selection
    1.2.3 [2007-01-04]
    * made a comprehensive revision of sound system
    ! fixed wav samples (now they are played as loops by the game)
    ! numerous fixes
    + new cvar 'amx_loading_flags'
    - removed cvar 'amx_loading_fix'
    1.2.2 [2006-12-13]
    * renamed plugin again because of existence of 'Loading Music'
    + new cvar 'amx_loading_loop'
    + new cvar 'amx_loading_fix'
    + precaching of any file within $MODDIR/sound/ folder
    1.2.1 [2006-12-11]
    * plugin converted for AMX/X (originally was for AMX 0.9.9 and higher)
    * use pcvar instead of cvar
    * no more hardcoded config dir (actually for AMX 0.9.9 there is no method
    to detect this)
    1.2.0 [2006-12-10]
    * plugin is renamed from 'Loading Sound' to 'Loading Music'
    * strip GoGoGo voice feature for non-CS mods; it's gone to separate
    plugin called 'GoGoGo Voice'
    * plugin now uses engine's fadeout system
    ! client mp3* cvars no more controlled by server
    - cvar 'sv_mp3volume' removed
    - FADEOUT, FADEOUT_TIME, FADEOUT_INTERVAL are removed
    + support for .wav files
    + custom playlist support
    + 'amx_loading_track' cvar
    1.1.0 [2006-11-29]
    * code is totally rewritten
    ! music now stops/fades out on player spawn
    + play voice 'gogogo' on player spawn (non-CS mod only); 
    you need to put (copy from CS sound folder) com_go.wav into 
    $MODDIR\sound\radio\ folder ($MODDIR can be valve, tfc
    + cvar 'sv_mp3volume'
    + added other customization params within script: FADEOUT, FADEOUT_TIME,
    FADEOUT_INTERVAL (need to recompile the plugin after one has changed 
    them); they are not cvars yet because i'm unable to think out real good
    cvar names for them right now
    1.0.0 [?] by White Panther
    * initial release
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#pragma tabsize 4

#define MY_PLUGIN_NAME    "Loading Music II"
#define MY_PLUGIN_VERSION "1.2.9"
#define MY_PLUGIN_AUTHOR  "Simon Logic"

#define MAX_PLAYERS 32
    // max available players on server
#define MAX_TRACKS 30
    // max tracks in playlist
#define MAX_TRACKNAME_LENGTH 64
    // max track filename

// loop modes...
#define LOOP_NO       0
#define LOOP_MP3_SPEC 1
#define LOOP_4EVER    2

#define FORCE_NONE    0
#define FORCE_MP3     1
#define FORCE_WAV     2

#define FL_FORCE_MP3_ON_CONNECT (1 << 0)
#define FL_PLAY_ON_SPECTATE     (1 << 1)
#define FL_FORCE_WAV_ON_SELECT  (1 << 2)
#define FL_RESTART_ON_SELECT    (1 << 3)
#define FL_DONT_PLAY_ON_DEAD    (1 << 4)

// delay to start a track on team select (experimental values)...
#define ON_TEAMSELECT_DELAY_WAV 0.2
#define ON_TEAMSELECT_DELAY_MP3 0.3

#define EMIT_WAV_CHANNEL CHAN_STATIC
	// do not change until you know what you're doing!

//#define _DEBUG
    // debug mode

enum e_sound_engine {
	seNone = 0,
	seMp3,     // mp3: client cmd 'mp3 play'
	seSpk,     // wav: client cmd 'spk'
	seEmit     // wav: EmitSound()
}

// track struct
enum t_track {
	bool:b_wav,    // flag: file is wav
	bool:b_cached, // flag: file is cached
	bool:b_exists, // flag: file exists on server
	s_filename[MAX_TRACKNAME_LENGTH+1]
}

// player struct
enum t_player {
	i_track,     // track number playing on player
	e_sound_engine:t_engine
}

new const 
	g_sConfFileName[] = "loading_music.ini",
	g_sAuxConfDir[] = "loading_music",
	g_sWavDir[] = "sound", // it's also a precache dir
	g_sWavExt[] = "wav"
new const g_iWavDirLen = sizeof(g_sWavDir) - 1

// hardcoded playlist
new const g_sDefaultPlaylist[][] = {
    "media/Half-Life17"
}

new bool:g_bUnderCS
new g_iTrackCount // number of registered tracks
new g_iWavCount   // number of wav tracks (for better randomization)
new g_iMp3Count   // number of mp3 tracks (for better randomization)
new g_iTrackPlay = -1 // -1 - random, 0 - depends on custom track data
new g_arrMusicFiles[MAX_TRACKS+1][t_track]
new g_arrPlayer[MAX_PLAYERS+1][t_player]
new g_cvarAmxLoadingTrack
new g_cvarAmxLoadingLoop
new g_cvarAmxLoadingDelay
new g_cvarAmxLoadingFlags

// speedup parsing a little...
forward bool:isNumber(const var[])
forward bool:addTrack(const index, const filename[], bool:can_precache=true)
//-----------------------------------------------------------------------------
public plugin_precache()
{
    readConfigFile()
    if(!g_iTrackCount) {
        // try to use hardcoded default playlist
        for(new i=0; i<sizeof(g_sDefaultPlaylist); i++)
            if(addTrack(g_iTrackCount+1, g_sDefaultPlaylist[i], true))
                g_iTrackCount++
    }
}
//-----------------------------------------------------------------------------
public plugin_init()
{
	g_bUnderCS = bool:cstrike_running()

	for(new i=0; i<sizeof(g_arrPlayer); i++)
		g_arrPlayer[i][i_track] = -1
    
	register_plugin(MY_PLUGIN_NAME, MY_PLUGIN_VERSION, MY_PLUGIN_AUTHOR)
	
	if(g_bUnderCS) {
		// NOTE: this event can be called on MOTD also, but only once till
		// player spawn; this is a perfect behaviour for current plugin
		register_event("TeamInfo", "onTeamSelecting", "a", "2&UNASSIGNED")
	}

	register_event("ResetHUD", "onPlayerSpawn", "be")
	register_event("Spectator", "onSpectate", "a")

	register_cvar("version_loading_music2", MY_PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)

	g_cvarAmxLoadingTrack = register_cvar("amx_loading_track", "-1")
	g_cvarAmxLoadingLoop = register_cvar("amx_loading_loop", "0", FCVAR_SERVER)
	g_cvarAmxLoadingDelay = register_cvar("amx_loading_delay", "0.0")
	g_cvarAmxLoadingFlags = register_cvar("amx_loading_flags", "abc")

	server_print("[AMXX] Plugin %s initialized for %s mod", MY_PLUGIN_NAME, g_bUnderCS ? "CS": "HLDM")

	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------
public plugin_cfg()
{
    new sVal[MAX_TRACKNAME_LENGTH+1]
    
    get_pcvar_string(g_cvarAmxLoadingTrack, sVal, MAX_TRACKNAME_LENGTH)
    if(isNumber(sVal)) {
        g_iTrackPlay = str_to_num(sVal)
    } else {
        g_iTrackPlay = 0
        addTrack(0, sVal, false)
    }
    
    return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------
stock musicStart(id, track_to_continue=-1, can_emit=true, force_mode=FORCE_NONE)
{
	new i = -1
    
#if defined _DEBUG
	log_amx("musicStart(id=%d, track_to_continue=%d, can_emit=%d, force=%d)", id, track_to_continue, can_emit, force_mode)
#endif

	if(track_to_continue >= 0)
		i = track_to_continue // we're forced to restart a track
	else {
		if(g_arrPlayer[id][i_track] >= 0) {
#if defined _DEBUG
			log_amx("already playing on %d track %d", id, g_arrPlayer[id][i_track])
#endif
			return // already playing
		}		
        
        if(g_iTrackPlay < 0) {
            // play random track
            if(g_iTrackCount)
                i = random_num(1, g_iTrackCount)
            else
            	return
				
			if(force_mode != FORCE_NONE) {
				new iStart; iStart = i
				new iSkip
				if(force_mode == FORCE_MP3)
				{
					if(!g_iMp3Count)
						i = -1 // there is no mp3 file in playlist
					else {
						iSkip = random_num(1, g_iMp3Count)
						
						for(;;) {
							if(!g_arrMusicFiles[i][b_wav]) {
								if(!--iSkip) break
							}
							
							if(++i > g_iTrackCount)
								i = 1
							if(i == iStart) {
								i = -1 // there is no mp3 file in playlist
								break
							}
						}
					}
				}
				else
				{
					if(!g_iWavCount)
						i = -1 // there is no wav file in playlist
					else {
						iSkip = random_num(1, g_iWavCount)
					
						for(;;) {
							if(g_arrMusicFiles[i][b_wav]) {
								if(!--iSkip) break
							}							
							if(++i > g_iTrackCount)
								i = 1
							if(i == iStart)  {
								i = -1 // there is no wav file in playlist
								break
							}
						}
					}
				}
			}
        } else if(!g_iTrackPlay) {
            // play custom track
            i = 0
        } else if(g_iTrackPlay <= g_iTrackCount) {
            // play track by its index
            i = g_iTrackPlay
        }
    }

    if(i < 0 || (force_mode == FORCE_MP3 && g_arrMusicFiles[i][b_wav]) 
    || (force_mode == FORCE_WAV && !g_arrMusicFiles[i][b_wav])) {
        g_arrPlayer[id][i_track] = -1
        return
    }
 
#if defined _DEBUG
    assert 0 <= i < sizeof(g_arrMusicFiles)
    log_amx("play on player[%d] track %d: '%s'", id, i, g_arrMusicFiles[i][s_filename])
#endif
    
    // NOTE: 'play' command inserts ambient sound with attenuation
    // NOTE: 'spk' command plays on STATIC channel

    if(g_arrMusicFiles[i][b_wav])
    {
		// NOTE: just leave as is because it can be useful in future,
		// so 'can_emit' is not used right now
		
		/*
		if(can_emit && g_arrMusicFiles[i][b_cached] && is_user_connected(id)) 
		{
        	// NOTE: emit_sound is heard by ALL players
        	emit_sound(id, EMIT_WAV_CHANNEL, g_arrMusicFiles[i][s_filename], VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
        	g_arrPlayer[id][t_engine] = seEmit
#if defined _DEBUG
        	log_amx("emit_sound(id=%d, chan=%d, file='%s')", id, EMIT_WAV_CHANNEL, g_arrMusicFiles[i][s_filename])
#endif
		}
		else 
		{
#if defined _DEBUG
			g_arrPlayer[id][t_engine] = seSpk
			log_amx("spk/play %s", g_arrMusicFiles[i][s_filename])
#endif
		}
		*/

		// HACK: set seEmit in honour to stop wav playback by emit_sound()
		// (see musicStop() for reference)
		g_arrPlayer[id][t_engine] = seEmit
		client_cmd(id, "spk %s", g_arrMusicFiles[i][s_filename])
    }
    else 
    {
        if(get_pcvar_num(g_cvarAmxLoadingLoop) == LOOP_4EVER)
            client_cmd(id, "mp3 loop %s", g_arrMusicFiles[i][s_filename])
        else
            client_cmd(id, "mp3 play %s", g_arrMusicFiles[i][s_filename])
		g_arrPlayer[id][t_engine] = seMp3
	}

	g_arrPlayer[id][i_track] = i
}
//-----------------------------------------------------------------------------
public taskStartMusic(params[4]) // params = {player_id, restart_track, can_emit, force_mode}
{
	new id = params[0]
    
	if(params[1])
		// restore playback under CS
		musicStart(id, g_arrPlayer[id][i_track], .can_emit=params[2], .force_mode=params[3])
	else {
		if(g_arrPlayer[id][i_track] < 0)
		musicStart(id, .force_mode=params[3])
	}
}
//-----------------------------------------------------------------------------
public client_connect(id)
{
    g_arrPlayer[id][i_track] = -1

    if(is_user_bot(id))
        return PLUGIN_CONTINUE

    new iForceMode
    iForceMode = getPCvarAsFlags(g_cvarAmxLoadingFlags) & FL_FORCE_MP3_ON_CONNECT ? FORCE_MP3 : FORCE_NONE

    new Float:fDelay
	fDelay = get_pcvar_float(g_cvarAmxLoadingDelay)
    if(fDelay >= 0.1) {
        new arr[4]; arr[0] = id; arr[1] = -1; arr[2] = false; arr[3] = iForceMode
        set_task(fDelay, "taskStartMusic", id, arr, sizeof(arr))
    } else
        musicStart(id, .can_emit=false, .force_mode=iForceMode)

    return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------
public client_disconnect(id)
{
#if defined _DEBUG
	log_amx("client_disconnect(%d)", id)
#endif
	if(is_user_bot(id))
		return PLUGIN_CONTINUE

	if(task_exists(id))
		remove_task(id)

	musicStop(id) // has no effect on client but reinit plugin structures
    
	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------
public onSpectate()
{
	new id = read_data(1)

    if(is_user_bot(id))
        return
#if defined _DEBUG
	log_amx("onSpectate(%d)", id)
#endif	
	new bool:bDontPlay = true
	new iFlags = getPCvarAsFlags(g_cvarAmxLoadingFlags)
		
	if(iFlags & FL_PLAY_ON_SPECTATE) {
		if(iFlags & FL_DONT_PLAY_ON_DEAD) {
			// check if player a real spectator
			if(pev_valid(id) && (pev(id, pev_flags) & FL_SPECTATOR))
				bDontPlay = false
		}
		else
			bDontPlay = false
	}

	if(bDontPlay)
	{
		if(task_exists(id))
			remove_task(id)
		musicStop(id)
	}
	else
	{
		if(task_exists(id))
			return // already launched a track
		new arr[4]; arr[0] = id; arr[1] = -1; arr[2] = true; arr[3] = FORCE_MP3
		set_task(0.1, "taskStartMusic", id, arr, sizeof(arr))
		musicStop(id, true)
	}
}
//-----------------------------------------------------------------------------
public onTeamSelecting() // CS only
{
    new id; id = read_data(1)
    
    if(is_user_bot(id))
        return
#if defined _DEBUG
    log_amx("onTeamSelecting(%d)", id)
#endif
	if(task_exists(id))
		remove_task(id)

	new iFlags; iFlags = getPCvarAsFlags(g_cvarAmxLoadingFlags)
	if(iFlags & FL_FORCE_WAV_ON_SELECT) {
		new arr[4]; 
		arr[0] = id; arr[1] = -1; 
		arr[2] = true; arr[3] = FORCE_WAV
		set_task(ON_TEAMSELECT_DELAY_WAV, "taskStartMusic", id, arr, sizeof(arr))

		musicStop(id, true)
	}
	else if(iFlags & FL_RESTART_ON_SELECT) {
		new arr[4]
		arr[0] = id; arr[1] = g_arrPlayer[id][i_track];
		arr[2] = true; arr[3] = FORCE_NONE
		set_task(ON_TEAMSELECT_DELAY_MP3, "taskStartMusic", id, arr, sizeof(arr))
	}
}
//-----------------------------------------------------------------------------
public onPlayerSpawn(id)
{
	if(is_user_bot(id))
		return PLUGIN_CONTINUE
#if defined _DEBUG
	log_amx("onPlayerSpawn(%d)", id)
#endif
	if(task_exists(id))
		remove_task(id)
	musicStop(id)

	return PLUGIN_CONTINUE
}
//-----------------------------------------------------------------------------
musicStop(id, ignore_loop = false)
{
#if defined _DEBUG
    log_amx("musicStop(id=%d, ignore_loop=%d)", id, ignore_loop)
#endif
    static i; i = g_arrPlayer[id][i_track]
    if(i >= 0 && !is_user_connected(id)) {
        g_arrPlayer[id][i_track] = -1
        g_arrPlayer[id][t_engine] = seNone
        return
    }
    
    if(i < 0) {
    	g_arrPlayer[id][t_engine] = seNone
    	return
	}

    static iLoopMode
    
    if(ignore_loop)
    	iLoopMode = LOOP_NO
    else
    	iLoopMode = get_pcvar_num(g_cvarAmxLoadingLoop)
    
    if(iLoopMode != LOOP_4EVER) {
        if(g_arrMusicFiles[i][b_wav])
        {   
        	// TODO: discover how to use 'soundfade' command
			if(g_arrPlayer[id][t_engine] == seEmit) {
				emit_sound(id, EMIT_WAV_CHANNEL, g_arrMusicFiles[i][s_filename], 0.0, 0.0, SND_STOP, PITCH_NORM)
#if defined _DEBUG
				log_amx("emit_sound(%d, SND_STOP)", id)
#endif
			}
			else {
				// this should never be called in current release
				client_cmd(id, "stopsound")
#if defined _DEBUG
				log_amx("stopsound")
#endif
			}
            g_arrPlayer[id][i_track] = -1
        }
        else
            if(iLoopMode != LOOP_MP3_SPEC) {
#if defined _DEBUG
				log_amx("cd fadeout on player[%d]", id)
#endif
				client_cmd(id, "cd fadeout")
				g_arrPlayer[id][i_track] = -1
		}
	} 

	if(g_arrPlayer[id][i_track] < 0)
		g_arrPlayer[id][t_engine] = seNone
}
//-----------------------------------------------------------------------------
readConfigFile()
{
    new bool:bCustom
    new i, iRetLength
    new sConfigDir[64], sPath[255], sBuffer[MAX_TRACKNAME_LENGTH+1]
    
    g_iTrackCount = 0

    get_configsdir(sConfigDir , sizeof(sConfigDir)-1)
    get_mapname(sBuffer, MAX_TRACKNAME_LENGTH)

    formatex(sPath, sizeof(sPath)-1, "%s/%s/%s.ini", sConfigDir, g_sAuxConfDir, sBuffer)
	if(!file_exists(sPath)) {
		// get map prefix...
		i = contain(sBuffer, "_")
		if(i >= 0) {
			sBuffer[i+1] = 0
			formatex(sPath, sizeof(sPath)-1, "%s/%s/%s.ini", sConfigDir, g_sAuxConfDir, sBuffer)
			bCustom = bool:file_exists(sPath)
		}

	    if(!bCustom) {
	    	formatex(sPath, sizeof(sPath)-1, "%s/%s", sConfigDir, g_sConfFileName)
	    	if(!file_exists(sPath)) {
    	    	log_amx("File not found: ^"%s^"", sPath)
	    	    return
	    	}
		}
	} else
		bCustom = true
	
	if(bCustom)
		log_amx("Using custom playlist: ^"%s^"", sPath)

    i = 0
    while(read_file(sPath, i, sBuffer, MAX_TRACKNAME_LENGTH, iRetLength))
    {
        i++
        if(sBuffer[0] == ';' || !iRetLength) continue
        if(addTrack(g_iTrackCount + 1, sBuffer))
        {            
            g_iTrackCount++
            if(g_iTrackCount >= MAX_TRACKS) break
        }
    }
}
//-----------------------------------------------------------------------------
stock bool:isNumber(const var[])
{
    new i = var[0] == '-' ? 1 : 0

    for(; var[i]; i++)
        if(!('0' <= var[i] <= '9'))
            return false
    return true
}
//-----------------------------------------------------------------------------
stock getFileExt(const filename[], ext[], len)
{
    new i

    for(i=strlen(filename)-1; (i >= 0) && (filename[i] != '/') && (filename[i] != '\'); i--) 
    {
        if(filename[i] == '.') {
            new j;
            for(++i,j=0; filename[i] && j<len; i++,j++)
                ext[j] = filename[i]
            ext[j] = 0
            return true
        }
    }

    ext[0] = 0

    return false
}
//-----------------------------------------------------------------------------
// index - track id
// filename - relative to $moddir path
// can_precache - allow precaching
stock bool:addTrack(const index, const filename[], bool:can_precache=true)
{
#if defined _DEBUG
    log_amx("addTrack(index=%d, file=%s, can=%d)", index, filename, can_precache)
#endif
    new bPrecache = false
    static sExt[sizeof(g_sWavExt)]
#if defined _DEBUG
    assert 0 <= index < sizeof(g_arrMusicFiles)
#endif
    getFileExt(filename, sExt, sizeof(sExt)-1)
    g_arrMusicFiles[index][b_wav] = bool:equali(sExt, g_sWavExt)
    
    if(can_precache && (strlen(filename) > g_iWavDirLen) 
    && (filename[g_iWavDirLen] == '\' || filename[g_iWavDirLen] == '/'))
    {   // it's possible that file is placed within precache dir = > check it...
        bPrecache = bool:equali(filename, g_sWavDir, g_iWavDirLen)
        // NOTE: short filename is required for wav files only
        if(bPrecache && g_arrMusicFiles[index][b_wav])
            cutLeftStr(g_arrMusicFiles[index][s_filename], filename, g_iWavDirLen + 1)
		else
			copy(g_arrMusicFiles[index][s_filename], MAX_TRACKNAME_LENGTH, filename)
    }
	else
	   	copy(g_arrMusicFiles[index][s_filename], MAX_TRACKNAME_LENGTH, filename)
	
	// normalize path
	replaceChars(g_arrMusicFiles[index][s_filename], '\', '/')
#if defined _DEBUG
    log_amx("g_arrMusicFiles[%d][s_filename] = %s", index, g_arrMusicFiles[index][s_filename])
#endif
    /* NOTE: if sound file does not exist in current $MODDIR it can 
       be still searched in other mods when playing by client side, 
       thus i do not block adding a track to playlist
    */
    if(bPrecache) {
        if(file_exists(filename)) {
            if(g_arrMusicFiles[index][b_wav]) {
            	precache_sound(g_arrMusicFiles[index][s_filename])
			} else {
				precache_generic(g_arrMusicFiles[index][s_filename])
			}
            g_arrMusicFiles[index][b_cached] = true
        } else {
            log_amx("File not found: ^"%s^"", filename)
            g_arrMusicFiles[index][b_exists] = false
            g_arrMusicFiles[index][b_cached] = false
        }
    } else {
        g_arrMusicFiles[index][b_exists] = true // assume client has this file
        g_arrMusicFiles[index][b_cached] = false
    }
	
	if(g_arrMusicFiles[index][b_wav])
		g_iWavCount++
	else
		g_iMp3Count++
    
    return true
}
//-----------------------------------------------------------------------------
stock replaceChars(str[], what, with)
{
    for(new i=0; str[i]; i++)
        if(str[i] == what)
            str[i] = with
}
//-----------------------------------------------------------------------------
stock cutLeftStr(dest[], const src[], start=0)
{
    // NOTE: make sure strlen(dest) >= strlen(src)
    new z = 0
    for(new i=start; src[i]; i++) {
        dest[z] = src[i]
        z++
    }
    dest[z] = 0
}
//-----------------------------------------------------------------------------
stock getPCvarAsFlags(pcvar)
{
    new sValue[27]
    
    get_pcvar_string(pcvar, sValue, sizeof(sValue) - 1)
    
    return read_flags(sValue)
}
//-----------------------------------------------------------------------------
