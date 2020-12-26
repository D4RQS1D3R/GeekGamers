#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#pragma compress 1

new const PLUGIN[] = "VIP Knife (CT)";
new const VERSION[] = "1.0";
new const AUTHOR[] = "~D4rkSiD3Rs~";

native HasSuperKnife(id);

#define VIP_FLAG ADMIN_LEVEL_G

new const VIPKnifeVModel[66] = "models/[GeekGamers]/v_vip_knife_human.mdl";
new const VIPKnifePModel[66] = "models/[GeekGamers]/p_vip_knife_human.mdl";

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_event("CurWeapon", "CurentWeapon", "be", "1=1");
	RegisterHam(Ham_TakeDamage, "player", "DamageArme");
}

public plugin_precache()
{
	precache_model(VIPKnifeVModel);
	precache_model(VIPKnifePModel);
}

public CurentWeapon(id)
{
	if( get_user_flags(id) & VIP_FLAG && get_user_weapon(id) == CSW_KNIFE && cs_get_user_team(id) == CS_TEAM_CT && !HasSuperKnife(id) )
	{
      		set_pev(id, pev_viewmodel2, VIPKnifeVModel);
		set_pev(id, pev_weaponmodel2, VIPKnifePModel);
	}
	return PLUGIN_HANDLED;
}

public DamageArme(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(iInflictor == iAttacker && is_user_alive(iAttacker) && (get_user_flags( iAttacker ) & VIP_FLAG) && get_user_weapon(iAttacker) == CSW_KNIFE && cs_get_user_team(iAttacker) == CS_TEAM_CT && !HasSuperKnife(iAttacker))
	{
		SetHamParamFloat(4, fDamage * 1.538461538461538);
 		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}