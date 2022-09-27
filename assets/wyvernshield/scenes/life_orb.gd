extends KinematicBody

export var heal_percentage :=	0.33

export var initial_h_speed := 2.0
export var initial_v_speed :=	4.0
export var gravity :=	16.0

var velocity := Vector3.ZERO


func _ready():
	velocity = (
		Vector3.FORWARD.rotated(Vector3.UP, randf() * PI * 2.0)
		* initial_h_speed
		+ Vector3(0.0, initial_v_speed, 0.0)
	)


func _physics_process(delta):
	if get_slide_count() > 0:
		velocity = Vector3.ZERO
		set_physics_process(false)

	velocity -= Vector3(0, gravity * delta, 0)
	velocity = move_and_slide(velocity)


func can_collect(who : CombatActor):
	return who.health_percent < 1.0


func collect(by : CombatActor):
	by.health_percent += 0.33
