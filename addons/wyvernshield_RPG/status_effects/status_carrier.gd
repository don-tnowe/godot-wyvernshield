class_name StatusCarrier
extends Node

signal status_effect_applied(effect, insert_pos)
signal status_effect_removed(effect, insert_pos)

export var combat_actor_path := NodePath("..") setget _set_combat_actor_path
export(int, "Physics", "Idle") var process_mode setget _set_process_mode

var list := []
var status_stat_sheet : StatSheet
var status_trigger_sheet : TriggerSheet
var combat_actor : CombatActor
var dot_tick_progress : float
var time := 0.0


func _set_combat_actor_path(v):
	combat_actor_path = v
	if !is_inside_tree(): return
	
	if !combat_actor_path.is_empty():
		combat_actor = get_node(v)

	else: combat_actor = null


func _set_process_mode(v):
	set_process(v == 1)
	set_physics_process(v == 0)


func apply_effect(effect : StatusEffect, duration_sec : float, potency = null, sender : CombatActor = null):
	# Prevent stacking for non-stacking effects - reset duration instead. Leave property as "" to allow stacking
	effect = effect.duplicate()
	if effect.does_not_stack_with_id != "":
		for i in list.size():
			if list[i].does_not_stack_with_id == effect.does_not_stack_with_id:
				var old_effect = list[i]
				old_effect.stack_with(effect, duration_sec, potency, sender)
				reinsert_effect_into_list(old_effect)
				return

	effect.apply(self, duration_sec, potency, sender)
	emit_signal("status_effect_applied", effect, insert_effect_into_list(effect))


func apply_stat_change(stats_and_times : String, sender, does_not_stack_with_id : String = ""):
	var snt_split := stats_and_times.split("\n", false)
	var sheet_time := 1.0
	var sheet_text := ""
	for i in snt_split.size():
		if snt_split[i].ends_with("s:"):
			sheet_time = float(snt_split[i].left(snt_split[i].length() - 2))
			if sheet_text != "":
				_apply_effect_from_text(sheet_text, sheet_time, sender, does_not_stack_with_id + str(i))
				sheet_text = ""

		else:
			sheet_text += snt_split[i]
			
	_apply_effect_from_text(sheet_text, sheet_time, sender, does_not_stack_with_id)


func _apply_effect_from_text(sheet_text : String, time_sec : float, sender, does_not_stack_with_id : String = ""):
	var sheet := StatSheet.new()
	sheet.stats_as_text = sheet_text
	var effect := StatusEffect.new()
	effect.does_not_stack_with_id = does_not_stack_with_id
	effect.stat_sheets_to_add = [sheet]
	apply_effect(effect, time_sec, 1.0, sender)


func pop_effect():
	var f = list.pop_front()
	f.remove()
	emit_signal("status_effect_removed", f, 0)


func insert_effect_into_list(effect : StatusEffect) -> int:
	for i in list.size():
		if list[i].expiration_time_sec >= effect.expiration_time_sec:
			list.insert(i, effect)
			return i
	
	list.append(effect)
	return list.size() - 1


func reinsert_effect_into_list(effect : StatusEffect) -> int:
	var pos = list.find(effect)
	emit_signal("status_effect_removed", effect, pos)
	list.remove(pos)
	pos = insert_effect_into_list(effect)
	emit_signal("status_effect_applied", effect, pos)
	return pos


func _ready():
	_set_process_mode(process_mode)
	_set_combat_actor_path(combat_actor_path)
	status_trigger_sheet = combat_actor.triggers
	status_stat_sheet = StatSheet.new()
	combat_actor.stats.add_subsheet(status_stat_sheet)

	
func _physics_process(delta):
	_tick(delta)


func _process(delta):
	_tick(delta)


func _tick(delta):
	time += delta
	if list.size() == 0: return
		
	dot_tick_progress += delta
	if dot_tick_progress > 1.0:
		dot_tick_progress -= 1.0
		var result = TriggerStatic.status_dot_tick(0)
		combat_actor.triggers.apply_reactions(TriggerStatic.TRIGGER_STATUS_DOT_TICK, result, combat_actor)
		combat_actor.health -= result[TriggerStatic.STATUS_DOT_TICK_DAMAGE_DEALT]
	
	# Pop all the expired effects from the start - they're all sorted by expiration time.
	while list.size() > 0 && time > list[0].expiration_time_sec:
		pop_effect()
