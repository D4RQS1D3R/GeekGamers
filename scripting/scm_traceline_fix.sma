/*
	----------------------
	-*- Licensing Info -*-
	----------------------
	
	Semiclip Mod: Traceline Fix
	by schmurgel1983(@msn.com)
	Copyright (C) 2014-2017 Stefan "schmurgel1983" Focke
	
	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.
	
	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
	Public License for more details.
	
	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
	
	In addition, as a special exception, the author gives permission to
	link the code of this program with the Half-Life Game Engine ("HL
	Engine") and Modified Game Libraries ("MODs") developed by Valve,
	L.L.C ("Valve"). You must obey the GNU General Public License in all
	respects for all of the code used other than the HL Engine and MODs
	from Valve. If you modify this file, you may extend this exception
	to your version of the file, but you are not obligated to do so. If
	you do not wish to do so, delete this exception statement from your
	version.
	
	No warranties of any kind. Use at your own risk.
	
*/

#include <amxmodx>
#include <fakemeta>

/*================================================================================
 [Constants, Offsets and Defines]
=================================================================================*/

const NO_WALL_WEAPONS =  (1<<CSW_P228)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_UMP45)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_MP5NAVY)|(1<<CSW_M3)|(1<<CSW_TMP)|(1<<CSW_KNIFE)|(1<<CSW_P90)

/*================================================================================
 [Natives, Init and Cfg]
=================================================================================*/

public plugin_init()
{
	register_plugin("[SCM] Traceline Fix", "1.0.0", "schmurgel1983")
	
	register_forward(FM_TraceLine, "fw_TraceLine_Post", true)
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public fw_TraceLine_Post(Float:vStart[3], Float:vEnd[3], iNoMonsters, id, iTrace)
{
	if (!is_user_alive(id) || !get_tr2(iTrace, TR_StartSolid))
		return FMRES_IGNORED
	
	if ((1<<get_user_weapon(id)) & NO_WALL_WEAPONS)
	{
		engfunc(EngFunc_TraceLine, vStart, vEnd, IGNORE_MONSTERS, id, 0)
		static iHit
		iHit = get_tr2(0, TR_pHit)
		
		if (iHit >= 1 && iHit != get_tr2(iTrace, TR_pHit))
			return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}
