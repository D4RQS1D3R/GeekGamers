#include <amxmodx>

public plugin_init()
{
	register_plugin("[GG] Show Victim HP On Damage", "1.0", "D4RQS1D3R");

	register_event("Damage", "EventDamage", "b", "2!0", "3=0", "4!0");
}

public EventDamage(victim)
{
	new killer = get_user_attacker(victim);

	if(!killer || !is_user_connected(killer))
		return;

	if(killer == victim)
		return;

	if(!is_user_alive(victim) || get_user_health(victim) <= 0)
	{
		client_print(killer, print_center, "HP: Dead");
	}
	else
	{
		client_print(killer, print_center, "HP: %i", get_user_health(victim));
	}
}