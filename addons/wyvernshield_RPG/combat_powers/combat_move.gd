tool
class_name CombatMove, "./combat_move.svg"
extends Resource

export var base_power := 1.0
export(Array, float) var energy_costs := [1.0] setget _set_energy_costs
export(Array, String) var energy_types := ["magic"] setget _set_energy_types
export var weapon_cooldown : float
export var all_specials_cooldown : float
export var spawn_scene : PackedScene
export(int, "Root Node", "Child Local Coords") var spawn_mode := 0
export(String, MULTILINE) var stats_on_use := ""
export(String, MULTILINE) var stats_on_hit := ""
export(Array, Resource) var trigger_reactions : Array setget _set_trigger_reactions
export(Array, Resource) var projectile_trigger_reactions : Array

var trigger_sheet : TriggerSheet


func _set_energy_costs(v):
	energy_costs = v
	energy_types.resize(v.size())


func _set_energy_types(v):
	energy_types = v
	energy_costs.resize(v.size())


func _set_trigger_reactions(v):
	trigger_reactions = v
	trigger_sheet = TriggerSheet.new()
	for x in trigger_reactions:
		trigger_sheet.add_reaction(x)


func get_cost(actor : CombatActor) -> bool:
	var dict : Dictionary
	for i in energy_types.size():
		dict[energy_types[i]] = energy_costs[i]

	var result = TriggerStatic.combat_move_get_cost(actor, self, true, dict)
	actor.triggers.apply_reactions(TriggerStatic.TRIGGER_COMBAT_MOVE_GET_COST, result, actor)
	trigger_sheet.apply_reactions(TriggerStatic.TRIGGER_COMBAT_MOVE_GET_COST, result, actor)

	return result


func use(actor : CombatActor, aim_relative, origin_node : Node, is_weapon_attack : bool = false) -> Array:
	var cost_check = get_cost(actor)
	if !cost_check[TriggerStatic.COMBAT_MOVE_GET_COST_CAN_CAST]: return []

	var cost_dict = cost_check[TriggerStatic.COMBAT_MOVE_GET_COST_COST_DICT]
	for k in cost_dict:
		if !actor.has_energy(k, cost_dict[k]):
			return []

		actor.subtract_energy(k, cost_dict[k])
	
	if stats_on_use != "":
		actor.apply_stat_change_status_effect(stats_on_use, actor, resource_path)

	var spawned_node : Node
	if spawn_scene != null:
		spawned_node = spawn_scene.instance()
		spawned_node.damage = base_power
		spawned_node.sender = actor
		spawned_node.hit_stat_changes = stats_on_hit
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
	trigger_sheet.apply_reactions(TriggerStatic.TRIGGER_COMBAT_MOVE, result, actor)
	actor.triggers.apply_reactions(TriggerStatic.TRIGGER_COMBAT_MOVE, result, actor)
	
	for x in result[TriggerStatic.COMBAT_MOVE_SPAWNED_OBJECTS]:
		x.connect("hit_target", actor, "_on_hit_target", [is_weapon_attack])
		x.connect("finish_target", actor, "_on_finish_target", [is_weapon_attack])
		if spawn_mode == 0:
			origin_node.get_viewport().add_child(x)
			if x is Spatial:
				x.translation += origin_node.global_translation
	
			else:
				x.position += origin_node.global_position
		
		else:
			origin_node.add_child(x)
	
	return result
