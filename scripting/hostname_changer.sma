#include <amxmodx>
#include <amxmisc>

#pragma compress 1

#define Plugin "Server Name Changer"
#define Version "1.0"
#define Author "~D4rkSiD3Rs~"

new const name_file[] = "hostname.ini"

new server_names[100][180], num_of_names, current_name
public plugin_init()
{
	register_plugin(Plugin, Version, Author)
	
	read_names()
	set_task(0.1, "change_name",_,_,_, "b")
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
		server_names[num_of_names] = text
		
		server_print("%s", server_names[num_of_names])
	}
	
	fclose(file)
	server_print("Successfully added %d server names", num_of_names)
	
	return PLUGIN_CONTINUE
}

public change_name()
{
	if(current_name + 1 > num_of_names)
		current_name = 0
	
	current_name++
	server_cmd("hostname ^"%s^"", server_names[current_name])
}