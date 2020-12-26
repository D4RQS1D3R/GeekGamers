#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#pragma compress 1

#define Plugin "Game Name Changer"
#define Version "1.0"
#define Author "~D4rkSiD3Rs~"

new const name_file[] = "gamenames.ini"

new game_names[100][180], num_of_names, current_name
new amx_gamename

public plugin_init()
{
	register_plugin(Plugin, Version, Author)
	
	read_names()
	set_task(1.0, "change_gamename",_,_,_, "b")

	amx_gamename = register_cvar( "amx_gamename", "Counter-Strike" );
	register_forward( FM_GetGameDescription, "GameDesc" );
}

public read_names()
{
	new configsdir[64], dir[132]
	get_configsdir(configsdir, 63)
	
	format(dir, 131, "%s/%s", configsdir, name_file)
	new file = fopen(dir, "rt")
	
	if(!file)
	{
		server_print("Could not find the %s file", name_file)
		return PLUGIN_CONTINUE
	}
	
	new text[180]
	
	while(!feof(file))
	{
		fgets(file, text, 179)
		
		if( (strlen(text) < 2) || (equal(text, "//", 2)) )
		continue;
		
		num_of_names++
		game_names[num_of_names] = text
		
		server_print("%s", game_names[num_of_names])
	}
	
	fclose(file)
	server_print("Successfully added %d game names", num_of_names)
	
	return PLUGIN_CONTINUE
}

public change_gamename()
{
	if(current_name + 1 > num_of_names)
		current_name = 0
	
	current_name++
	server_cmd("amx_gamename ^"%s^"", game_names[current_name])
}

public GameDesc()
{
	static gamename[32];

	get_pcvar_string(amx_gamename, gamename, 31);
	forward_return(FMV_STRING, gamename);

	return FMRES_SUPERCEDE;
}