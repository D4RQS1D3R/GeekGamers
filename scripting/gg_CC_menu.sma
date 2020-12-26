#pragma semicolon 1

// Includes
////////////

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>  

// Defines
////////////

#define MAX_PLAYERS	32

// Arrays
////////////

new Array:g_aColourName;
new Array:g_aColourSettings;

// Integers
////////////

new g_iColour[MAX_PLAYERS+1][3];
new g_iCustomColour[MAX_PLAYERS+1][3];

new g_iTemp[MAX_PLAYERS+1];
new g_iMenuPage[MAX_PLAYERS+1];

new g_iMaxColours;

//////////////////////////////////////////////////////////////
// Plugin Forwards							//
//////////////////////////////////////////////////////////////

public plugin_init()
{
	register_plugin("Chat Colour Menu", "1.50", "shadow.hk");
	
	register_dictionary("common.txt");
	register_dictionary("colourmenu.txt");
	
	register_clcmd("say /chatcolor",	"ColourMenu");
	register_clcmd("say chatcolor",	"ColourMenu");
	
	register_clcmd("colour_value",	"cmdColourValue",	-1,	"<value>");
	
	register_menucmd(register_menuid("Chat Colour Menu"),		1023,	"ColourMenu_handler");
	register_menucmd(register_menuid("Custom Colour Menu"),	1023,	"CustomMenu_handler");
}
public plugin_cfg()
{
	g_aColourName = ArrayCreate(16);
	g_aColourSettings = ArrayCreate(3);
	
	new configsdir[32], file[64];
	get_configsdir(configsdir, 31);
	format(file, 63, "%s/colours.ini", configsdir);
	
	LoadFile(file);
}

//////////////////////////////////////////////////////////////
// Client Forwards							//
//////////////////////////////////////////////////////////////

public client_putinserver(id)
{
	g_iCustomColour[id] = { 0, 0, 0 };
	set_task(0.5, "taskColours", id);
}

//////////////////////////////////////////////////////////////
// Commands									//
//////////////////////////////////////////////////////////////

public cmdColourValue(id)
{
	new szArg[4];
	read_argv(1, szArg, 3);
	
	if( !is_str_num(szArg) )
	{
		return PLUGIN_HANDLED;
	}
	
	g_iCustomColour[id][g_iTemp[id]] = clamp(str_to_num(szArg), 0, 255);
	
	CustomMenu(id);
	return PLUGIN_HANDLED;
}

//////////////////////////////////////////////////////////////
// Menus & Menu Handlers						//
//////////////////////////////////////////////////////////////

// taken from alka's voteban source code
public ColourMenu(id, iPos)
{
	static i, iKeys, szMenu[512], iCurrPos;
	iCurrPos = 0;
	
	static iStart, iEnd;
	iStart = iPos * 6;
	
	static iPages;
	iPages = floatround(float(g_iMaxColours) / 6.0, floatround_ceil);
	
	iEnd = iStart + 6;
	iKeys = ( MENU_KEY_0 | MENU_KEY_7 | MENU_KEY_8 );
	
	if( iEnd > g_iMaxColours )
	{
		iEnd = g_iMaxColours;
	}
	
	// heading
	static iLen;
	iLen = formatex(szMenu, sizeof(szMenu) - 1, "\y%L (\w%i/%i\y):^n^n", id, "MENU_COLOUR", g_iMenuPage[id] + 1, iPages);
	
	// colour keys
	for(i = iStart; i < iEnd; i++)
	{
		iKeys |= ( 1<<iCurrPos++ );
		iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r%d. \w%a^n", iCurrPos, ArrayGetStringHandle(g_aColourName, i));
	}
	
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r7. \y%L", id, "MENU_CUSTOM");
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r8. \y%L^n", id, "COLOUR_DEFAULT");
	
	// forward key
	if( iEnd == g_iMaxColours )
	{
		iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r9. \d%L", id, "MORE");
	}
	else
	{
		iKeys |= MENU_KEY_9;
		iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r9. \w%L", id, "MORE");
	}
	
	// exit key
	if( !g_iMenuPage[id] )
	{
		iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r0. \w%L", id, "EXIT");
	}
	else
	{
		iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "^n\r0. \w%L", id, "BACK");
	}
	
	show_menu(id, iKeys, szMenu, -1, "Chat Colour Menu");
	return PLUGIN_HANDLED;
}

public ColourMenu_handler(id, key)
{
	switch( key )
	{
		case 6:
		{
			CustomMenu(id);
			return PLUGIN_HANDLED;
		}
		case 7:
		{
			client_cmd(id, "con_color ^"%i %i %i^"", g_iColour[id][0], g_iColour[id][1], g_iColour[id][2]);
			client_print(id,print_chat,"[US] %L %L", id, "COLOUR_SET", id, "COLOUR_DEFAULT");
		}
		case 8: ++g_iMenuPage[id];
		case 9:
		{
			if( !g_iMenuPage[id] )
			{
				return PLUGIN_HANDLED;
			}
			
			--g_iMenuPage[id];
		}
		default:
		{
			static colour, colours[3];
			colour = ( g_iMenuPage[id] * 6 + key );
			
			ArrayGetArray(g_aColourSettings, colour, colours);
			
			client_cmd(id, "con_color ^"%i %i %i^"", colours[0], colours[1], colours[2]);
			client_print(id,print_chat,"[US] %L %a", id, "COLOUR_SET", ArrayGetStringHandle(g_aColourName, colour));
		}
	}
	
	ColourMenu(id, g_iMenuPage[id]);
	return PLUGIN_HANDLED;
}

public CustomMenu(id)
{
	new iLen, szMenu[256], iKeys;
	iKeys = ( MENU_KEY_0 | MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_8 | MENU_KEY_9 );
	
	iLen = formatex(szMenu, sizeof(szMenu) - 1, "\y%L:^n^n", id, "MENU_CUSTOM");
	
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r1. \w%L: \y%i^n",	id,	"RED",	g_iCustomColour[id][0]);
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r2. \w%L: \y%i^n",	id,	"GREEN",	g_iCustomColour[id][1]);
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r3. \w%L: \y%i^n^n",	id,	"BLUE",	g_iCustomColour[id][2]);
	
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r8. \y%L^n",	id,	"CUSTOM_SET");
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r9. \w%L^n",	id,	"BACK");
	iLen += formatex(szMenu[iLen], sizeof(szMenu) - 1 - iLen, "\r0. \w%L",	id,	"EXIT");
	
	show_menu(id, iKeys, szMenu, -1, "Custom Colour Menu");
	return PLUGIN_HANDLED;
}

public CustomMenu_handler(id, key)
{
	switch( key )
	{
		case 0, 1, 2:
		{
			g_iTemp[id] = key;
			
			client_cmd(id, "messagemode colour_value");
			client_print(id,print_chat,"[US] %L", id, "CUSTOM_VALUE");
		}
		
		case 7:
		{
			CustomMenu(id);
			
			client_cmd(id, "con_color ^"%i %i %i^"", g_iCustomColour[id][0], g_iCustomColour[id][1], g_iCustomColour[id][2]);
			client_print(id,print_chat,"[US] %L ^"%i %i %i^"", id, "COLOUR_SET", g_iCustomColour[id][0], g_iCustomColour[id][1], g_iCustomColour[id][2]);
		}
		case 8: ColourMenu(id, g_iMenuPage[id]);
		case 9: g_iMenuPage[id] = 0;
	}
	
	return PLUGIN_HANDLED;
}

//////////////////////////////////////////////////////////////
// Tasks							//
//////////////////////////////////////////////////////////////

public taskColours(id)
{
	query_client_cvar(id, "con_color", "fwdConColour");
}

//////////////////////////////////////////////////////////////
// Miscellaneous Forwards						//
//////////////////////////////////////////////////////////////

public fwdConColour(id, const cvar[], const value[]) 
{
	new colour[12];
	copy(colour, 11, value);
	
	if( contain(colour, "+") != -1 )
	{
		replace_all(colour, 11, "+", " ");
	}
	
	new szData[3][4];
	parse(colour, szData[0], 3, szData[1], 3, szData[2], 3);
	
	g_iColour[id][0] = clamp(str_to_num(szData[0]), 0, 255);
	g_iColour[id][1] = clamp(str_to_num(szData[1]), 0, 255);
	g_iColour[id][2] = clamp(str_to_num(szData[2]), 0, 255);
}

//////////////////////////////////////////////////////////////
// File Data								//
//////////////////////////////////////////////////////////////

// Load Colour File
LoadFile(const file[])
{
	// Create a default file, if it doesn't exist
	if( !file_exists(file) )
	{
		write_file(file, "; Colours Configuration file^n; Usage: <Colourname> <red> <green> <blue>^n^"CS Default^" 255 180 30");
		
		ArrayPushString(g_aColourName, "CS Default");
		ArrayPushArray(g_aColourSettings, { 255, 180, 30 });
		
		g_iMaxColours = 1;
		
		log_amx("%L", LANG_SERVER, "LOG_ERROR");
		return;
	}
	
	new szLine[64], szData[3][4], szColourName[16], colours[3];
	
	new File = fopen(file, "r");
	
	while( !feof(File) )
	{
		fgets(File, szLine, 63);
		trim(szLine);
		
		if( !szLine[0] || szLine[0] == '^n' || szLine[0] == ';' )
		{
			continue;
		}
		
		parse(szLine, szColourName, 15, szData[0], 3, szData[1], 3, szData[2], 3);
		
		colours[0] = clamp(str_to_num(szData[0]), 0, 255);
		colours[1] = clamp(str_to_num(szData[1]), 0, 255);
		colours[2] = clamp(str_to_num(szData[2]), 0, 255);
		
		ArrayPushArray(g_aColourSettings, colours);
		ArrayPushString(g_aColourName, szColourName);
	}
	
	fclose(File);
	
	g_iMaxColours = ArraySize(g_aColourName);
	
	log_amx("%L", LANG_SERVER, "LOG_LOADED", g_iMaxColours);
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
