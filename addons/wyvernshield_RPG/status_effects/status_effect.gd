class_name StatusEffect, "./status_effect.svg"
extends Resource

# Leave blank to allow stacking.
export var does_not_stack_with_id := ""
export var function_class : Script setget _set_function_class
export var function_on_applied : String
export var function_on_expired : String
export var function_on_stacked : String
export var icon : Texture
export(Array, Resource) var trigger_reactions_to_add := []
export(Array, Resource) var stat_sheets_to_add := []
export var extra_vars := []

var potency
var sender
var carrier
var expiration_time_sec := 0.0 setget _set_expiration_time
var duration_sec setget _set_duration, _get_duration
var function_class_instance


func _set_expiration_time(v):
	if is_instance_valid(carrier):
		expiration_time_sec = v
		carrier.reinsert_effect_into_list(self)
		
	expiration_time_sec = v


func _set_duration(v):
	expiration_time_sec = carrier.time + v


func _get_duration():
	return expiration_time_sec - carrier.time


func _set_function_class(v):
	function_class = v
	if is_instance_valid(v):
		function_class_instance = v.new()


func apply(target_carrier : Node, new_duration_msec : int, effect_potency = null, effect_sender = null):
	carrier = target_carrier
	sender = effect_sender
	
	var props_result = TriggerStatic.status_get_properties(
		effect_sender,
		self,
		target_carrier,
		new_duration_msec,
		effect_potency
	)

	expiration_time_sec = carrier.time + props_result[TriggerStatic.STATUS_GET_PROPERTIES_RESULT_DURATION]
	potency = props_result[TriggerStatic.STATUS_GET_PROPERTIES_RESULT_POTENCY]

	var apply_result = TriggerStatic.status_applied(
		effect_sender,
		self,
		target_carrier.combat_actor,
		new_duration_msec,
		potency if effect_potency == null else effect_potency
	)
	if effect_sender != null:
		effect_sender.triggers.apply_reactions(
			TriggerStatic.TRIGGER_STATUS_APPLIED,
			apply_result,
			effect_sender
		)

	target_carrier.combat_actor.triggers.apply_reactions(
		TriggerStatic.TRIGGER_STATUS_RECEIVED,
		apply_result,
		target_carrier.combat_actor
	)

	for i in stat_sheets_to_add.size():
		stat_sheets_to_add[i] = target_carrier.status_stat_sheet.add_subsheet(stat_sheets_to_add[i], potency)

	for x in trigger_reactions_to_add:
		var x_inst = target_carrier.status_trigger_sheet.add_reaction(x)
		x_inst.source_status_effect = self
	
	if is_instance_valid(function_class_instance) && function_class_instance.has_method(function_on_applied):
		function_class_instance.call(function_on_applied, target_carrier)


func remove():
	for x in stat_sheets_to_add:
		carrier.status_stat_sheet.remove_subsheet(x)
		
	for x in trigger_reactions_to_add:
		carrier.status_trigger_sheet.remove_reaction(x)
	
	if is_instance_valid(function_class_instance) && function_class_instance.has_method(function_on_expired):
		function_class_instance.call(function_on_expired, carrier)
		

func stack_with(new_effect : StatusEffect, new_duration_msec : int, new_potency = null, new_sender = null):
	var props_result = TriggerStatic.status_get_properties(
		new_sender, 
		self, 
		carrier, 
		new_duration_msec, 
		new_potency
	)

	expiration_time_sec = carrier.time + props_result[TriggerStatic.STATUS_GET_PROPERTIES_RESULT_DURATION]
	potency = props_result[TriggerStatic.STATUS_GET_PROPERTIES_RESULT_POTENCY]

	if is_instance_valid(function_class_instance) && function_class_instance.has_method(function_on_stacked):
		function_class_instance.call(function_on_stacked, new_effect, self, new_duration_msec, new_potency, new_sender)
