extends CharacterBody2D


@export_group("Engine")
@export var ENGINE_POWER := 500     # Forward acceleration force
@export var BRAKING_FORCE := -450         # Braking force
@export var MAX_SPEED_FORWARD := 300
@export var MAX_SPEED_REVERSE := 100

@export_group("Steering")
@export var WHEEL_BASE := 20 
@export var MAX_STEER_ANGLE := 15       # Amount that front wheel turns, in degrees
@export var STEERING_RESPONSE_SPEED := 5.0   # How quickly steering responds

@export_group("Physics")
@export var GROUND_FRICTION := -55
@export var DRAG := -0.06
@export var DRIFT_START_SPEED := 200       # Speed where traction is reduced
@export var TRACTION_WHEN_FAST := 2.5    # High-speed traction
@export var TRACTION_WHEN_SLOW := 10     # Low-speed traction
@export var STOPPING_SPEED_LIMIT := 20.0   # Speed below which car stops when no input


# ------------------------------------------------------------------
# Internal State Variables
# ------------------------------------------------------------------
var steer_direction := 0.0 


@export var wheel_base := 20  	 # Distance from front to rear wheel
@export var steer_angle := 15 # Amount that front wheel turns, in degrees

@export var engine_power := 500  # Forward acceleration force.
@export var braking := -450
@export var max_speed_forward := 300
@export var max_speed_reverse := 100


@export var friction := -55
@export var drag := -0.06


@export var slip_speed := 200  # Speed where traction is reduced
@export var traction_fast := 2.5 # High-speed traction
@export var traction_slow := 10 # Low-speed traction

@export var scale_rate_x: float=0.02
@export var scale_rate_y: float=0.03
@export var scale_up = false

@export var wheeel_skew :float= 3




# ON READY

@onready var screen_size = get_viewport_rect().size
@onready var idle_animation = $IdleAnimTimer
@onready var front_wheel_animation = $WheelAnimation
@onready var front_wheel_sprite = $FrontWheelsSprite

	
func get_steer_direction(_steer_direction: float) -> float:
	var turn = Input.get_axis("ui_left", "ui_right")
	var _steer_direction2 = turn * deg_to_rad(MAX_STEER_ANGLE)
	#current_steer = lerp(current_steer, target_steer, steering_speed * delta)
	return _steer_direction2

func apply_speed(acceleration: Vector2, delta):
	velocity += acceleration * delta
	if acceleration == Vector2.ZERO and velocity.length() < STOPPING_SPEED_LIMIT:
		velocity =  Vector2.ZERO
	else:
		var friction_force = velocity * GROUND_FRICTION * delta
		var drag_force = velocity * velocity.length() * DRAG * delta
		velocity+= acceleration+ drag_force + friction_force


func apply_speed2(acceleration: Vector2, delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	#var friction_force = velocity * friction * delta
	#var drag_force = velocity * velocity.length() * drag * delta
	#var _acceleration = acceleration+ drag_force + friction_force
	


func _physics_process(delta):
	#idle_scale()
	#var input = get_input()
	
	var acceleratrion = get_acceleration()
	velocity += acceleratrion * delta
	steer_direction = get_steer_direction(steer_direction)

	#apply_speed2(acceleratrion,delta)	
	#
	#var _friction = apply_friction(delta, acceleratrion,velocity)
	#velocity = _friction["velocity"]
	
	var steering = calculate_steering(delta,steer_direction)
	
	#print(input["steer_direction"])
	#front_twheel_sprite.skew = wheeel_skew	
	

	

	
	
	velocity = steering["velocity"]
	rotation = steering["rotation"]
	

			
	
	
	move_and_slide()
	# wrap character position (show player on the other size of screen)
	apply_wrap()


func get_acceleration() -> Vector2:
	var acceleration : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * ENGINE_POWER
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * BRAKING_FORCE
	return acceleration

	
func get_input():
	var _acceleration = Vector2.ZERO
	var turn = Input.get_axis("ui_left", "ui_right")
	var _steer_direction = turn * deg_to_rad(steer_angle)
	if Input.is_action_pressed("ui_up"):
		_acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
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
		_velocity = lerp(velocity, new_heading * min(velocity.length(), max_speed_forward), traction * delta)
	if d < 0:
		_velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	_rotation = new_heading.angle()
	
	return {"velocity": _velocity, "rotation": _rotation}


		
	
func apply_wrap(): 
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
