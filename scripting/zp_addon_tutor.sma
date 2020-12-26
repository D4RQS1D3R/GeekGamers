#include <amxmodx>
#include <hamsandwich>
#include <czerotutor>

new szSound[] = { "sound/events/tutor_msg.wav" }

public plugin_precache()
{
	precache_sound(szSound)
}

public plugin_init() 
{
	register_plugin("[INC] CzeroTutor Test", "1.0", "MMYTH")
	
	RegisterHam(Ham_Spawn, "player", "ham_playerspawn", 1)
}

public ham_playerspawn(id)
{
	switch (random_num(1, 13))	
	{
		case 1:
		{
			czerotutor_create(id, "Infinity Help^nUse the knockbackbomb to jump up on high objects!", BLUE, szSound, 5.0)
                }
                case 2:
                {
			czerotutor_create(id, "Infinity Help^nUse your knife to jump higher!", GREEN, szSound, 5.0)
                }
                case 3:
                {
			czerotutor_create(id, "Infinity Help^nLevel up to gain access to lots Of Weapons!", RED, szSound, 5.0)
                }
                case 4:
                {
			czerotutor_create(id, "Infinity Help^nGain money by shooting zombies!", YELLOW, szSound, 5.0)
                }
                case 5:
                {
			czerotutor_create(id, "Infinity Help^nUseMadness to escape from being killed as zombie!", BLUE, szSound, 5.0)
                }
                case 6:
                {
			czerotutor_create(id, "Infinity Help^nBuy Weapons/Extras or choose a knife with the button [B]!", RED, szSound, 5.0)
                }
                case 7:
                {
			czerotutor_create(id, "Infinity Help^nWork togheter as a team, and you will win!", GREEN, szSound, 5.0)
                }
                case 8:
                {
			czerotutor_create(id, "Infinity Help^nPress [M] to see the various options in the zombie menu", YELLOW, szSound, 5.0)
                }
                case 9:
                {
			czerotutor_create(id, "Infinity Help^nHumans/Zombies will get a reward if they win!", BLUE, szSound, 5.0)
                }
                case 10:
                {
			czerotutor_create(id, "Infinity Help^nKill Zombies To Level Up!", RED, szSound, 5.0)
                 }
                case 11:
                {
			czerotutor_create(id, "Infinity Help^nfind HelpBoxes!, The Contain Very Usefull Items/Weapons!", GREEN, szSound, 5.0)
                }
                case 12:
                {
			czerotutor_create(id, "Infinity Help^nFrost nades will freeze zombies.", YELLOW, szSound, 5.0)
                }
                case 13:
                {
			czerotutor_create(id, "[CSO] Infinity Help^nUse the knife will knockback zombies", BLUE, szSound, 5.0)

                }
        } 
}     

