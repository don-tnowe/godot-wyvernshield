class_name TriggerSheet
extends Resource

export var initial_reactions := [] setget _set_initial_reactions

var reactions := []


func _set_initial_reactions(v):
	for x in initial_reactions:
		remove_reaction(x)
	
	initial_reactions = v
	for x in v:
		add_reaction(x)


func _init():
	reactions.resize(TriggerStatic.TRIGGER_MAX)
	for i in TriggerStatic.TRIGGER_MAX:
		reactions[i] = []


func apply_reactions(action_id : int, result : Array, subject : Node = null):
	for x in reactions[action_id]:
		x.apply_function.call_func(result, subject)
	
	return result


func add_reaction(reaction : TriggerReaction, extra_vars = null) -> Reference:
	var arr = reactions[reaction.trigger]

	if !reaction.allow_duplicates:
		for x in arr:
			if reaction.reaction_class.instance_has(x):
				# Duplicate found! Stop function execution.
				return x

	var inst = reaction.reaction_class.new()
	inst.apply_function = funcref(inst, reaction.reaction_func)
	inst.priority = reaction.priority

	if extra_vars == null:
		inst.extra_vars = reaction.extra_vars

	else:
		inst.extra_vars = extra_vars
	
	# While inserting, consider Priority. Biggest Priority is applied first.
	for i in arr.size():
		if arr[i].priority <= inst.priority:
			arr.insert(i, inst)
			return inst

	# If didn't Return in the loop right above, put the reaction at the end.	
	arr.append(inst)
	return inst


func remove_reaction(reaction : TriggerReaction):
	var trigger_idx = reaction.trigger
	for i in reactions[trigger_idx].size():
		if reaction.reaction_class.instance_has(reactions[trigger_idx][i]):
			reactions[trigger_idx].remove(i)
			break


func sort_reactions(a, b):
	return a.priority >= b.priority
