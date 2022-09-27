extends TriggerReactionInstance


func defense_a(info, defender):
	var dmg = info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT]
	var defense_left = defender.stats.get_stat("defense")
	var max_effective_percent = 1.0 - defender.stats.get_stat("defense_falloff", 0.5)
	var damage_deduced = 0

	# If Defense exceeds half the damage, cut half the damage and defense
	# and check again for the rest of Defense.
	# This algorithm prevents defenses blocking ALL the incoming damage, 
	# applying diminishing returns.
	for i in 16:
		if defense_left > dmg * max_effective_percent:
			damage_deduced = dmg * max_effective_percent
			dmg -= damage_deduced
			defense_left = (defense_left - damage_deduced) * 0.5

		else:
			dmg -= defense_left
			break

	info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] = dmg


func defense_b(info, defender):
	# Alternatively, here are some simpler ways to calculate it.
	var atk = info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT]
	info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] = (
		atk * atk
		/ (atk + defender.stats.get_stat("defense", 1.0))
	)


func defense_c(info, defender):
	info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] *= (
		100.0 / (100.0 + defender.stats.get_stat("defense", 1.0))
	)


func defense_d(info, defender):
	info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] -= defender.stats.get_stat("defense") * 0.5
	if info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] <= 1:
		info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] = 1
