extends TriggerReactionInstance


func hero_weapon_attack(info, attacker):
	if !info[TriggerStatic.COMBAT_MOVE_IS_BASIC_ATTACK]:
		return

	var stats = attacker.stats
	info[TriggerStatic.COMBAT_MOVE_WEAPON_COOLDOWN] = 1.0 / stats.get_stat("weapon_speed")
	
	# Apply the stats to all projectiles.
	# (Because what if another trigger response turned them into three?)
	for x in info[TriggerStatic.COMBAT_MOVE_SPAWNED_OBJECTS]:
		x.damage = stats.get_stat("weapon_damage")
		x.velocity = stats.get_stat("weapon_shot_speed") * info[TriggerStatic.COMBAT_MOVE_DIRECTION_VEC]
		x.lifetime = stats.get_stat("weapon_shot_lifetime")
		x.pierce_count = stats.get_stat("weapon_pierce_count")
		x.pierce_damage_loss = stats.get_stat("weapon_pierce_damage_loss")
		x.translate(x.velocity.normalized() * x.initial_move_forward)
		if x is Spatial:
			x.rotate(Vector3.UP, -x.velocity.signed_angle_to(Vector3.FORWARD, Vector3.UP))

		else:
			x.rotate(x.velocity.angle())


func hero_special_attack(info, attacker):
	var stats = attacker.stats
	var dir_flat = info[TriggerStatic.COMBAT_MOVE_DIRECTION_VEC]
	dir_flat = Vector3(dir_flat.x, 0, dir_flat.z).normalized()
	
	for x in info[TriggerStatic.COMBAT_MOVE_SPAWNED_OBJECTS]:
		x.damage *= stats.get_stat("special_damage", 1.0)
		x.velocity += x.initial_speed * dir_flat


func apply_status_on_hit(info, defender):
	var stat_multi = (
		info[TriggerStatic.HIT_RECEIVED_HIT_BY_ACTOR].stats.get_stat(extra_vars[3], 1.0)
		if extra_vars.size() >= 4 else 1.0
	)
	defender.apply_status_effect(extra_vars[0], extra_vars[1], extra_vars[2] * stat_multi, info[TriggerStatic.HIT_RECEIVED_HIT_BY_ACTOR])


func apply_status_on_cast(info, caster):
	var stat_multi = (
		info[TriggerStatic.COMBAT_MOVE_COMBAT_MOVE].stats.get_stat(extra_vars[3], 1.0)
		if extra_vars.size() >= 4 else 1.0
	)
	caster.apply_status_effect(extra_vars[0], extra_vars[1], extra_vars[2] * stat_multi, caster)
	

func damage_numbers(info, defender):
	# DOT and normal damage have damage in different spots.
	var damage_index_in_info : int = (
		extra_vars[4] if extra_vars.size() >= 5
		else TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT
	)
	# If no damage, don't display numbers.
	if info[damage_index_in_info] < 0.01: return

	var scene : PackedScene = extra_vars[0]
	var translation_random : Vector3 = extra_vars[1] if extra_vars.size() >= 2 else Vector3.ZERO
	var rotation_random := deg2rad(extra_vars[2]) if extra_vars.size() >= 3 else 0.0
	var color : Color = extra_vars[3] if extra_vars.size() >= 4 else Color.white
	
	var nums = scene.instance()
	defender.get_node("/root").add_child(nums)
	nums.translation = defender.global_translation + Vector3(
		translation_random.x * rand_range(-1.0, 1.0),
		translation_random.y * rand_range(-1.0, 1.0),
		translation_random.z * rand_range(-1.0, 1.0)
	)
	nums.rotate(defender.transform.basis.xform(Vector3.BACK), rand_range(-1.0, 1.0) * rotation_random)
	nums.get_node("Label").text = str(floor(abs(info[damage_index_in_info])))
	nums.get_node("Label").modulate = color


func split_projectiles(info, _attacker):
	var new_objects_arr := []
	var new_node : Node
	var angle_step : float = -extra_vars[1] / extra_vars[0]
	var angle_start : float = extra_vars[1] * 0.5
	var objects_in_info = extra_vars[2] if extra_vars.size() > 2 else TriggerStatic.COMBAT_MOVE_SPAWNED_OBJECTS
	for x in info[objects_in_info]:
		for i in extra_vars[0] + 1:
			new_node = x.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SIGNALS | Node.DUPLICATE_SCRIPTS)
			new_objects_arr.append(new_node)
			new_node.velocity = x.velocity.rotated(Vector3.UP, deg2rad(angle_start + angle_step * i))
			# Not needed: the Attack object will attach these to the origin node.
			#x.get_parent().add_child(new_node)

		x.free()

	info[objects_in_info] = new_objects_arr


func spawn_on_kill(info, attacker):
	if randf() > extra_vars[1]: return
	
	var new_node = extra_vars[0].instance()
	new_node.translation = info[TriggerStatic.NPC_DEFEATED_TARGET].global_translation
	attacker.get_viewport().add_child(new_node)
