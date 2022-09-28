class_name CombatMove
extends Resource

export var base_multiplier := 1.0
export var energy_cost := 1.0
export var energy_type := "magic"
export var weapon_cooldown : float
export var all_specials_cooldown : float
export var spawn_scene : PackedScene
export(int, "Root Node", "Child Local Coords") var spawn_mode := 0
export(Array, Resource) var trigger_reactions : Array setget _set_trigger_reactions
export(Array, Resource) var projectile_trigger_reactions : Array
export(String, MULTILINE) var stats_on_use := ""
export(String, MULTILINE) var stats_on_hit := ""

var trigger_sheet : TriggerSheet


func _set_trigger_reactions(v):
	trigger_reactions = v
	trigger_sheet = TriggerSheet.new()
	for x in trigger_reactions:
		trigger_sheet.add_reaction(x)


func get_cost(actor : CombatActor) -> bool:
	var result = TriggerStatic.combat_move_get_cost(actor, self, true, {energy_type : energy_cost})
	actor.triggers.apply_reactions(TriggerStatic.TRIGGER_ATTACK_GET_COST, result, actor)
	trigger_sheet.apply_reactions(TriggerStatic.TRIGGER_ATTACK_GET_COST, result, actor)

	return result


func use(actor : CombatActor, aim_relative, origin_node : Node, is_weapon_attack : bool = false) -> Array:
	var cost_check = get_cost(actor)
	if !cost_check[TriggerStatic.ATTACK_GET_COST_CAN_CAST]: return []

	var cost_dict = cost_check[TriggerStatic.ATTACK_GET_COST_COST_DICT]
	for k in cost_dict:
		if !actor.has_energy(k, cost_dict[k]):
			return []

		actor.subtract_energy(k, cost_dict[k])

	var spawned_node : Node
	if spawn_scene != null:
		spawned_node = spawn_scene.instance()
		spawned_node.damage = base_multiplier
		spawned_node.sender = actor
		spawned_node.hit_trigger_reactions.append_array(projectile_trigger_reactions)

	var result := TriggerStatic.combat_move(
		actor,
		[spawned_node] if spawn_scene != null else [],
		aim_relative,
		self,
		weapon_cooldown,
		all_specials_cooldown,
		is_weapon_attack
	)
	trigger_sheet.apply_reactions(TriggerStatic.TRIGGER_ATTACK, result, actor)
	actor.triggers.apply_reactions(TriggerStatic.TRIGGER_ATTACK, result, actor)
	
	for x in result[TriggerStatic.ATTACK_SPAWNED_OBJECTS]:
		x.connect("hit_target", actor, "_on_hit_target")
		x.connect("finish_target", actor, "_on_finish_target")
		if spawn_mode == 0:
			origin_node.get_viewport().add_child(x)
			if x is Spatial:
				x.translation += origin_node.global_translation
	
			else:
				x.position += origin_node.global_position
		
		else:
			origin_node.add_child(x)

	return result
