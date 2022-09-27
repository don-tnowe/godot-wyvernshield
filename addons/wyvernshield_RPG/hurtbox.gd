class_name Hurtbox
extends Area

export var combat_actor_path := NodePath("..") setget _set_combat_actor

var combat_actor : Node
var alive : bool setget , _is_alive


func _is_alive():
	return combat_actor.alive


func _ready():
	_set_combat_actor(combat_actor_path)


func _set_combat_actor(v):
	combat_actor_path = v
	if !is_inside_tree():
		return

	combat_actor = get_node(v)
