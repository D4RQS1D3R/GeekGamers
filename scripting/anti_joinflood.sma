#include <amxmodx>

#pragma semicolon 1

#pragma compress 1

#define	PLUGIN	"[GG] Anti Flood"
#define	AUTHOR	"~D4rkSiD3Rs~"
#define	VERSION	"1.0"

#define	MAX_PLAYERS	32

new iJoinIP[MAX_PLAYERS][33], iCount[MAX_PLAYERS];
new iCvarEnable, iCvarBanLength, iCvarMaxConnect;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	iCvarEnable	= register_cvar("amx_join_flood", "1");
	iCvarBanLength	= register_cvar("amx_join_flood_banlength", "60"); 
	iCvarMaxConnect	= register_cvar("amx_join_flood_attemptss", "10");
}

public client_authorized(id)
{
	if(!(is_user_bot(id)) && (get_pcvar_num(iCvarEnable))) 
	{
		new iUserIp[33], i; get_user_ip(id, iUserIp, sizeof iUserIp - 1, 1);
		new iMaxConnect = get_pcvar_num(iCvarMaxConnect);
        
		for(i = 0; i < MAX_PLAYERS; i++)
		{
			if (equal(iUserIp, iJoinIP[i], 32)) 
			{
				if (iCount[i] >= iMaxConnect)
				{
					new uID[1], aID[1]; uID[0] = id; aID[0] = i;
					set_task(0.1, "BanUserFlood", 77, uID[0], 1);
					set_task(1.0, "ClearUserID", (id + MAX_PLAYERS), aID[0], 1);
				}
				else
				{
					iCount[i]++;
				}
				break;
			}
		}

		if (i == MAX_PLAYERS)
		{
			new a;

			for(a = 0; a < MAX_PLAYERS; a++)
			{
				if (iJoinIP[a][0] == 0) 
				{
					get_user_ip(id, iJoinIP[a], 32, 1);
					iCount[a]++;
					break;
				}
			}
                
			if (a == MAX_PLAYERS)
			{
				for(new a = 0; a < MAX_PLAYERS; a++)
				{
					iJoinIP[a][0] = 0;
					iCount[a] = 0;
				}
			}
		}          
	}
}

public BanUserFlood(id[]) 
{
	new iUserIp[17]; get_user_ip(id[0], iUserIp, sizeof iUserIp - 1,1);
	new iUserIpPort[33]; get_user_ip(id[0], iUserIpPort, sizeof iUserIpPort - 1);
	server_cmd("addip %f %s", get_pcvar_float(iCvarBanLength), iUserIp);
	log_to_file("new_test.log", "Player Tried to Flood the Server | IP: %s", iUserIpPort);
}

public ClearUserID(i[]) 
{
	iJoinIP[i[0]][0] = 0;
	iCount[i[0]] = 0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1036\\ f0\\ fs16 \n\\ par }
*/
