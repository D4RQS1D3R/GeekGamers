#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

const XO_WEAPON = 4
const m_pPlayer = 41
const m_flNextPrimaryAttack = 46
const m_flNextSecondaryAttack = 47

public plugin_init()
{
	register_plugin("SpeedHack Shield", "1.1 (2nd Mthd)", "TheWhitesmith")

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife" , "FwdKnifePrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife" , "FwdKnifeSecondaryAttack")
}

public FwdKnifePrimaryAttack( knifeIndex )
	set_task(0.01, "set_nextattacktime", knifeIndex)

public FwdKnifeSecondaryAttack( knifeIndex )
	set_task(0.01, "set_nextattacktime", knifeIndex+9999)

public set_nextattacktime( knifeIndex )
{
	if(knifeIndex > 9999)
	{
		knifeIndex -= 9999
		set_pdata_float(knifeIndex, m_flNextSecondaryAttack, 1.08, XO_WEAPON)
		set_pdata_float(knifeIndex, m_flNextPrimaryAttack, 1.08, XO_WEAPON)
	}
	else
	{
		set_pdata_float(knifeIndex, m_flNextPrimaryAttack, 0.38, XO_WEAPON)
		set_pdata_float(knifeIndex, m_flNextSecondaryAttack, 0.38, XO_WEAPON)
	}

	return PLUGIN_HANDLED
}