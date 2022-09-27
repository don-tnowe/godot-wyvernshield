extends TriggerReactionInstance


func stack_reset_duration(new_effect, old_effect, new_duration_sec, _new_potency, _new_sender):
	if new_duration_sec < old_effect.duration_sec:
		new_effect.expiration_time_sec = old_effect.expiration_time_sec

	else:
		new_effect.expiration_time_sec = new_duration_sec


func burn_tick(info, _carrier):
	info[TriggerStatic.STATUS_DOT_TICK_DAMAGE_DEALT] += source_status_effect.potency


func burn_hit(info, _defender):
	source_status_effect.expiration_time_sec -= 1.0
	info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT] += source_status_effect.potency
