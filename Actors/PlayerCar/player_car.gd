extends CharacterBody2D


@export var wheel_base := 70  	 # Distance from front to rear wheel
@export var steer_angle := 15 # Amount that front wheel turns, in degrees

@export var engine_power := 900  # Forward acceleration force.
@export var braking := -450
@export var max_speed_reverse := 250


@export var friction := -55
@export var drag := -0.06


@export var slip_speed := 400  # Speed where traction is reduced
@export var traction_fast := 2.5 # High-speed traction
@export var traction_slow := 10 # Low-speed traction


@onready var screen_size = get_viewport_rect().size

func _physics_process(delta):
	var input = get_input()
	velocity += input["acceleration"] * delta
	var friction = apply_friction(delta, input["acceleration"],velocity)
	velocity = friction["velocity"]
	
	var steering = calculate_steering(delta,input["steer_direction"])
	
	velocity = steering["velocity"]
	rotation = steering["rotation"]
	
	# wrap character position (show player on the other size of screen)
	apply_wrap()
	
	move_and_slide()



	
func get_input():
	var _acceleration = Vector2.ZERO
	var turn = Input.get_axis("left", "right")
	var _steer_direction = turn * deg_to_rad(steer_angle)
	if Input.is_action_pressed("up"):
		_acceleration = transform.x * engine_power
	if Input.is_action_pressed("down"):
		_acceleration = transform.x * braking
	return {"acceleration": _acceleration, "steer_direction": _steer_direction}

func apply_friction(delta, acceleration, _velocity):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		_velocity = Vector2.ZERO
	var friction_force = _velocity * friction * delta
	var drag_force = _velocity * _velocity.length() * drag * delta
	var _acceleration = acceleration+ drag_force + friction_force
	return {"acceleration": _acceleration, "velocity": _velocity}




func calculate_steering(delta, steer_direction):
	var _rotation: float = 0
	var _velocity := Vector2.ZERO
	# 1. Find the wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# 2. Move the wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# 3. Find the new direction vector
	var new_heading = rear_wheel.direction_to(front_wheel)
	# 4. Choose which traction value to use - at lower speeds, slip should be low
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	# 5. Are we braking, going forward or backward
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		# using linear interpolation to add drift
		_velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		_velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	_rotation = new_heading.angle()
	
	return {"velocity": _velocity, "rotation": _rotation}
	
func apply_wrap(): 
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
