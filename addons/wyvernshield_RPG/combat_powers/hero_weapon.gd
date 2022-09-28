tool
class_name HeroWeapon
extends Weapon

export var basic_attack_move : Resource
export var basic_attack_action := "attack"
export var aim_at_ground := true
export var camera_path := NodePath("../../Camera")
export(Array, Resource) var special_powers := [] setget _set_special_powers
export(Array, String) var special_power_actions := [] setget _set_special_power_actions

onready var direction_pointer := $"Dir"
onready var ray_cast := $"Raycast"

var look_vec : Vector3


func _set_special_powers(v):
	special_powers = v
	special_power_actions.resize(v.size())


func _set_special_power_actions(v):
	special_power_actions = v
	special_powers.resize(v.size())


func _process(_delta):
	# As this is a tool script (needed to make), it would _process() in editor.
	if Engine.editor_hint: return

	var mouse_pos = get_viewport().get_mouse_position()

	# Cast to a "aimable" surface (physics layer 5)
	if aim_at_ground:
		ray_cast.global_translation = get_node(camera_path).project_ray_origin(mouse_pos)
		ray_cast.cast_to = get_node(camera_path).project_ray_normal(mouse_pos) * 1024.0
		ray_cast.set_collision_mask_bit(5, true)
		ray_cast.force_raycast_update()
	
	# If no aimable surface, cast to the PlaneShape under the character's feet (physics layer 6)
	if !aim_at_ground || !ray_cast.is_colliding():
		ray_cast.set_collision_mask_bit(5, false)
		ray_cast.set_collision_mask_bit(6, true)
		ray_cast.force_raycast_update()
		ray_cast.set_collision_mask_bit(6, false)
	
	look_vec = (ray_cast.get_collision_point() - global_translation)
	direction_pointer.look_at(ray_cast.get_collision_point(), Vector3.UP)
	direction_pointer.rotation.x = 0

	if Input.is_action_pressed(basic_attack_action):
		if next_shot_sec < time:
			use_power(basic_attack_move, Vector3(look_vec.x, 0, look_vec.z).normalized(), true)


func _unhandled_input(event):
	if event.is_pressed() && !event.is_echo() && next_special_sec < time:
		for i in special_power_actions.size():
			if event.is_action(special_power_actions[i]):
				use_power(special_powers[i], look_vec)
				break
