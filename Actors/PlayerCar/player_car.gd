extends CharacterBody2D


@export var wheel_base := 70  	 # Distance from front to rear wheel
@export var steer_angle := 15 # Amount that front wheel turns, in degrees

@export var engine_power := 900  # Forward acceleration force.
@export var braking := -450
@export var max_speed_reverse := 250

func _physics_process(delta):
	var input = get_input()
	velocity += input["acceleration"] * delta
	print(input["steer_direction"])
	var steering = calculate_steering(delta)
	
	velocity = steering["velocity"]
	rotation = steering["rotation"]
	
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

func calculate_steering(delta):
	var _rotation: float = 0
	var _velocity := Vector2.ZERO
	
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		_velocity = new_heading * velocity.length()
	if d < 0:
		_velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	_rotation = new_heading.angle()
	
	return {"velocity": _velocity, "rotation": _rotation}
	
