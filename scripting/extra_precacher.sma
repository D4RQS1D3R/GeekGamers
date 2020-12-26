#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Extra Precacher"
#define VERSION "1.0"
#define AUTHOR "Alka"

#define MAX_EXT 10

new const gValidExt[] = ".wad,.mdl,.spr,.wav,.mp3";

new gExt[MAX_EXT][16];

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_precache()
{
	str_piece(gValidExt, gExt, sizeof gExt, sizeof gExt[] - 1, ',');
	
	new szConfigsDir[64], szFile[64], szMapName[32];
	get_configsdir(szConfigsDir, sizeof szConfigsDir - 1);
	get_mapname(szMapName, sizeof szMapName - 1);
	
	formatex(szFile, sizeof szFile - 1, "%s/extra_precacher_%s.ini", szConfigsDir, szMapName);
	
	if(!file_exists(szFile))
	{
		formatex(szFile, sizeof szFile - 1, "%s/extra_precacher.ini", szConfigsDir);
		
		if(!file_exists(szFile))
			write_file(szFile, ";Precache file^n;File name format : name.ext, *.ext, *.*", -1);
	}
	
	new szBuffer[128], szDir[10][16], iLen, iLine;
	
	while(read_file(szFile, iLine++, szBuffer, sizeof szBuffer - 1, iLen))
	{
		if(!iLen || szBuffer[0] == ';')
			continue;
		
		for(new i = 0 ; i < sizeof gExt ; i++)
		{
			if(!gExt[i][0])
				continue;
			
			if(equali(szBuffer[strlen(szBuffer) - 4], gExt[i]) && szBuffer[strlen(szBuffer) - 5] != '*')
			{	
				if(file_exists(szBuffer))
				{
					precache_generic(szBuffer);
					
					server_print("[ExtraPrecacher]Precached file ^"%s^"", szBuffer);
				}
				break;
			}
			else if(equali(szBuffer[strlen(szBuffer) - 4], gExt[i]) && szBuffer[strlen(szBuffer) - 5] == '*')
			{
				str_piece(szBuffer, szDir, sizeof szDir, sizeof szDir[] - 1, '/');
				precache_all(szDir, gExt[i], true);
				
				break;
			}
			else if(equali(szBuffer[strlen(szBuffer) - 2], ".*") && szBuffer[strlen(szBuffer) - 3] == '*')
			{
				str_piece(szBuffer, szDir, sizeof szDir, sizeof szDir[] - 1, '/');
				precache_all(szDir, "", false);
				
				break;
			}
		}
	}
}

public precache_all(dir[10][16], ext[], bool:checkext)
{
	new szDir[128];
	
	for(new i = 0 ; i < sizeof dir ; i++)
	{
		if(!dir[i][0] || containi(dir[i], ".") != -1)
			continue;
		
		format(szDir, sizeof szDir - 1,"%s/%s", szDir, dir[i]);
	}
	
	new iDir = open_dir(szDir, "", 0);
	
	new szBuffer[64];
	
	while(next_file(iDir, szBuffer, sizeof szBuffer))
	{
		if(szBuffer[0] == '.' || containi(szBuffer, ".ztmp") != -1)
			continue;
		
		if(checkext)
		{
			if(!equali(szBuffer[strlen(szBuffer) - 4], ext))
				continue;
		}
		
		format(szBuffer, sizeof szBuffer - 1, "%s/%s", szDir, szBuffer);
		
		if(file_exists(szBuffer))
		{
			precache_generic(szBuffer);
			
			server_print("[ExtraPrecacher]Precached file ^"%s^"", szBuffer);
		}
	}
	close_dir(iDir);
}	

stock str_piece(const input[], output[][], outputsize, piecelen, token = '|')
{
	new i = -1, pieces, len = -1 ;
	
	while ( input[++i] != 0 )
	{
		if ( input[i] != token )
		{
			if ( ++len < piecelen )
				output[pieces][len] = input[i] ;
		}
		else
		{
			output[pieces++][++len] = 0 ;
			len = -1 ;
			
			if ( pieces == outputsize )
				return pieces ;
		}
	}
	return pieces + 1;
}
