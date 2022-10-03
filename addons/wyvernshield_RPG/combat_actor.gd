tool
class_name CombatActor
extends Node

signal health_changed(new_value, old_value)
signal health_depleted()
signal energy_changed(new_value, old_value, energy_type)
signal stats_changed(stat_sheet)

export var stats : Resource setget _set_stats
export var health := 20.0 setget _set_health
export var health_percent := 1.0 setget _set_health_percent
export(Array, String) var energy_types : Array setget _set_energy_types
export(Array, float) var energy_amounts : Array setget _set_energy_amounts
export var regen_suffix := "_regen"
export var max_health_stat := "health"
export(int, "Physics", "Idle", "None / Manual (via regen_tick())") var natural_regen_process_mode := 2 setget _set_process_mode
export var status_path := NodePath("StatusCarrier")

export(Array, Resource) var initial_trigger_reactions setget _set_initial_trigger_reactions

var status : Node

var regen_stats := [null]
var triggers := TriggerSheet.new()
var alive := true
var last_regen_tick := 0.0


func _set_process_mode(v):
	natural_regen_process_mode = v
	if Engine.editor_hint: return
	set_process(v == 1)
	set_physics_process(v == 0)


func _set_energy_types(v):
	energy_types = v
	energy_amounts.resize(v.size())
	for i in energy_types.size():
		if energy_types[i] == "":
			energy_types[i] = ["energy_", "magic_", "energy_", "stamina_"][randi() % 4] + str(i)
		
	_update_stat_names()


func _set_energy_amounts(v):
	energy_amounts = v
	energy_types.resize(v.size())

	_update_stat_names()


func _set_health(v):
	if Engine.editor_hint: return
	alive = true

	if v <= 0:
		v = 0
		alive = false
		emit_signal("health_depleted")

	if v > stats.get_stat(max_health_stat):
		v = stats.get_stat(max_health_stat)

	emit_signal("health_changed", v, health)
	health = v
	health_percent = v / stats.get_stat(max_health_stat)


func _set_health_percent(v):
	health_percent = v
	_set_health(v * stats.get_stat(max_health_stat))


func _set_stats(v):
	if is_instance_valid(stats):
		stats.disconnect("changed", self, "_on_stats_changed")
	
	stats = v
	# Duplicate the array - if it's not, new sheets will be added to the same array which all enemies share
	stats.subsheets = stats.subsheets.duplicate()
	stats.recalculate_recursively()
	if stats.connect("changed", self, "_on_stats_changed") != OK:
		printerr("Error! Could not connect StatSheet::changed (_set_stats in combat_actor.gd)")


func _set_initial_trigger_reactions(v):
	for x in initial_trigger_reactions:
		triggers.remove_reaction(x)

	initial_trigger_reactions = v
	for x in v:
		triggers.add_reaction(x)


func _update_stat_names():
	regen_stats.resize(energy_types.size() + 1)
	regen_stats[0] = max_health_stat + regen_suffix
	for i in energy_types.size():
		regen_stats[i + 1] = energy_types[i] + regen_suffix


func apply_status_effect(effect, duration_msec : int, potency = null, sender : CombatActor = null):
	if has_node(status_path):
		get_node(status_path).apply_effect(effect, duration_msec, potency, sender)


func apply_stat_change_status_effect(stats_and_times : String, sender : CombatActor, does_not_stack_with_id : String = ""):
	if has_node(status_path):
		get_node(status_path).apply_stat_change(stats_and_times, sender, does_not_stack_with_id)
		

func has_energy(energy_type : String, amount : float = 0.0) -> bool:
	var index = energy_types.find(energy_type)
	return index != -1 && energy_amounts[index] > amount


func subtract_energy(energy_type : String, amount : float):
	if energy_type == max_health_stat:
		_set_health(health - amount)
		return

	var index = energy_types.find(energy_type)
	if index == -1: return
	
	var old_amount = energy_amounts[index]
	energy_amounts[index] = energy_amounts[index] - amount
	emit_signal("energy_changed", energy_amounts[index], old_amount, energy_type)


func _ready():
	_set_stats(stats)
	_set_health(INF)  # Reduced to the `health` stat if sheet present
	_set_process_mode(natural_regen_process_mode)
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)


func _physics_process(delta):
	regen_tick(delta)


func _process(delta):
	regen_tick(delta)


func hit(sender : Node, combat_move : Resource, damage : float, hit_trigger_reactions : Array = []) -> Array:
	var hit_info = TriggerStatic.hit_received(self, sender, combat_move, damage)
	for x in hit_trigger_reactions:
		x.apply(hit_info, self)

	triggers.apply_reactions(TriggerStatic.TRIGGER_HIT_RECEIVED, hit_info, self)
	_set_health(health - hit_info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT])

	var hit_result = TriggerStatic.hit_landed(
		self, 
		hit_info[TriggerStatic.HIT_RECEIVED_HIT_BY_COMBAT_MOVE],
		hit_info[TriggerStatic.HIT_RECEIVED_DAMAGE_DEALT]
	)
	return hit_result


func regen_tick(delta : float = 1.0):
	if !alive: return

	var old_energy_amount = 0.0
	_set_health(health + delta * stats.get_stat(regen_stats[0]))
	for i in energy_types.size():
		old_energy_amount = energy_amounts[i]
		energy_amounts[i] = clamp(
			energy_amounts[i] + delta * stats.get_stat(regen_stats[i + 1]),
			0.0,
			stats.get_stat(energy_types[i])
		)
		emit_signal("energy_changed", energy_amounts[i], old_energy_amount, energy_types[i])


func _on_stats_changed():
	emit_signal("stats_changed", stats)


func _on_hit_target(result):
	triggers.apply_reactions(TriggerStatic.TRIGGER_HIT_LANDED, result, self)


func _on_finish_target(result):
	triggers.apply_reactions(TriggerStatic.TRIGGER_NPC_DEFEATED, result, self)
