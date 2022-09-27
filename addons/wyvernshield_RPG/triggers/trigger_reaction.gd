class_name TriggerReaction, "./trigger_reaction.svg"
extends Resource

export(int,
	"Tick",
	"Attack",
	"Attack Get Cost",
	"Hit Landed",
	"Hit Received",
	"Status Dot Tick",
	"Status Get Properties",
	"Status Applied",
	"Status Received",
	"Npc Defeated",
	"Item Pickup"
) var trigger := 0
export var priority := 100
export var reaction_class : Script = GDScript.new()
export var reaction_func := "apply_to"
export var allow_duplicates := true
export(String, MULTILINE) var editor_extra
export var extra_vars := []


func apply(result : Array, actor):
	var inst = reaction_class.new()
	inst.extra_vars = extra_vars
	inst.call(reaction_func, result, actor)
