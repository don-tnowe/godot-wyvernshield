class_name Weapon
extends Spatial

signal attacking_state_changed(is_attacking)
signal hit_target(hit_result)
signal finish_target(hit_result)

export var combat_actor_path := NodePath("..") setget _set_combat_actor

onready var global := $"Node"

var time := 0.0
var next_shot_sec := 0.0
var next_special_sec := 0.0
var combat_actor : Node


func _physics_process(delta):
	if time < next_shot_sec && time + delta > next_shot_sec:
		emit_signal("attacking_state_changed", false)

	time += delta


func _ready():
	_set_combat_actor(combat_actor_path)


func _set_combat_actor(v):
	combat_actor_path = v
	combat_actor = get_node(v)


func use_power(power, look_vec : Vector3, is_weapon_attack : bool = false):
	var result = power.use(combat_actor, look_vec, self, is_weapon_attack)
	if result.size() <= 1:
		return

	next_shot_sec = time + result[TriggerStatic.ATTACK_WEAPON_COOLDOWN]
	next_special_sec = time + result[TriggerStatic.ATTACK_POWER_COOLDOWN]
	if next_shot_sec != time:
		emit_signal("attacking_state_changed", true)

	for x in result[TriggerStatic.ATTACK_SPAWNED_OBJECTS]:
		x.connect("hit_target", self, "_on_hit_target")
		x.connect("finish_target", self, "_on_finish_target")


func _on_hit_target(result):
	emit_signal("hit_target", result)


func _on_finish_target(result):
	emit_signal("finish_target", result)
