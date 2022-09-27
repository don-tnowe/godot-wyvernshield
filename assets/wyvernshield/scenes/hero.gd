class_name Hero
extends KinematicBody

signal health_changed(value, old_value)
signal health_depleted()

export var move_max_speed := 4.0
export var move_gravity := 12.0

onready var combat := $"CombatActor"

var velocity := Vector3.ZERO
var move_locked := false
var is_attacking := false


func _physics_process(delta):
	if !move_locked:
		_process_movement_input(delta)

	velocity = move_and_slide(velocity - Vector3(0, move_gravity * delta, 0), Vector3.UP, true)


func _process_movement_input(delta):
	var input_vec := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)
	var horizontal_velocity = move_max_speed * (0.5 if is_attacking else 1.0) * input_vec
	velocity = Vector3(
		horizontal_velocity.x, 
		velocity.y, 
		horizontal_velocity.y
	)


func _on_combat_health_changed(v : float, old_v : float):
	emit_signal("health_changed", v, old_v)
	$"HUD/Control/ResourceBars/Life".value = v


func _on_combat_health_depleted():
	emit_signal("health_depleted")
	#	Write "on defeated" code here
	#combat.triggers.apply_reactions(TriggerStatic.TRIGGER_LIFE_LOST, [self, null], combat)


func _on_combat_energy_changed(v, _old_v, energy_type):
	if energy_type == "magic":
		$"HUD/Control/ResourceBars/Magic".value = v


func _on_combat_stats_changed(stat_sheet):
	move_max_speed = stat_sheet.get_stat("move_speed")
	$"HUD/Control/ResourceBars/Life".max_value = stat_sheet.get_stat("health")
	$"HUD/Control/ResourceBars/Magic".max_value = stat_sheet.get_stat("magic")
	move_locked = stat_sheet.get_stat("move_locked", 0) != 0


func _on_Hurtbox_body_entered(body : Node):
	if body.get_collision_layer_bit(7):
		if !body.has_method("can_collect") || body.can_collect(combat):
			body.collect(combat)
			body.queue_free()


func _on_Weapon_attacking_state_changed(attacking_state):
	is_attacking = attacking_state
