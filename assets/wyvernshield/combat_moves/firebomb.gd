extends DamageArea

export var gravity_up := 16.0
export var gravity_down := 24.0

var stage := 0


func _ready():
	velocity.y = 4.0


func _physics_process(delta):
	velocity.y -= delta * (gravity_up if velocity.y > 0.0 else gravity_down)


func destroy():
	stage += 1

	# Hit Ground
	if stage == 1:
		# Raycast helps align with ground.
		$"RayCast".force_raycast_update()
		if $"RayCast".is_colliding():
			global_translation = $"RayCast".get_collision_point() + Vector3(0, 0.05, 0)

		$"Shape".disabled = true
		$"ExplosionShape".disabled = false

		is_spectral = true
		velocity = Vector3.ZERO
		set_collision_layer_bit(3, true)

		$"Anim".play("explode")
		$"Sprite3D".visible = false
		destroy_timer.start(0.2)
		set_physics_process(false)
	
	# Explosion stops dealing damage
	elif stage == 2:
		$"ExplosionShape".disabled = true
		destroy_timer.start(2.0)

	else:
		queue_free()


func _on_explosion_hit_target(hit_result):
	emit_signal("hit_target", hit_result)


func _on_explosion_finish_target(hit_result):
	emit_signal("finish_target", hit_result)
