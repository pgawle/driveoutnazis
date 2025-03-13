extends CharacterBody2D

# ------------------------------------------------------------------
# Configuration Parameters
# ------------------------------------------------------------------

@export_group("Steering")
@export var WHEEL_BASE := 20 
@export var MAX_STEER_ANGLE := 15       # Amount that front wheel turns, in degrees
@export var STEERING_RESPONSE_SPEED := 5.0   # How quickly steering responds



@export_group("Engine")
@export var ENGINE_POWER := 500     # Forward acceleration force
@export var BRAKING_FORCE := -450         # Braking force
@export var MAX_SPEED_FORWARD := 300
@export var MAX_SPEED_REVERSE := 100

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

# ------------------------------------------------------------------
# Node References
# ------------------------------------------------------------------
@onready var screen_size = get_viewport_rect().size



func _ready() -> void:
	pass



func _physics_process(delta):
	
	
	var acceleration = get_acceleration()
	
	steer_direction = get_steer_direction(steer_direction, delta)
	
	
	apply_speed(acceleration,delta)
	
	var movement = calculate_movement(steer_direction, delta)
	
	
	velocity = movement["velocity"]
	rotation = movement["rotation"]
	
	move_and_slide()
	apply_screen_wrap()



	

func calculate_movement(_steer_direction: float, delta) -> Dictionary: 
	var _rotation: float = 0
	var _velocity := Vector2.ZERO
	
	# 1. Find the wheel positions
	var rear_wheel = position - transform.x * WHEEL_BASE / 2.0
	var front_wheel = position + transform.x * WHEEL_BASE / 2.0
	
	# 2. Move the wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(_steer_direction) * delta
	
	# 3. Find the new direction vector
	var new_direction = rear_wheel.direction_to(front_wheel)
	# 4. Choose which traction value to use - at lower speeds, slip should be low
	var traction = TRACTION_WHEN_SLOW
	if velocity.length() > DRIFT_START_SPEED:
		traction = TRACTION_WHEN_FAST
	
	# 5. Are we braking, going forward or backward
	var d = new_direction.dot(velocity.normalized())
	if d > 0:
		# using linear interpolation to add drift
		print("d>0")
		_velocity = lerp(velocity, new_direction * min(velocity.length(), MAX_SPEED_FORWARD), traction * delta)
	if d < 0:
		print("d<0")
		_velocity = -new_direction * min(velocity.length(), MAX_SPEED_REVERSE)
	
	_rotation = new_direction.angle()
	
	return {
		"velocity": _velocity,
		 "rotation": _rotation
		}


func apply_speed(acceleration: Vector2, delta):
	velocity += acceleration * delta
	if acceleration == Vector2.ZERO and velocity.length() < STOPPING_SPEED_LIMIT:
		velocity =  Vector2.ZERO
	else:
		var friction_force = velocity * GROUND_FRICTION * delta
		var drag_force = velocity * velocity.length() * DRAG * delta
		velocity= acceleration+ drag_force + friction_force
		


func get_steer_direction(_steer_direction: float, delta) -> float:
	var turn = Input.get_axis("ui_left", "ui_right")
	var _steer_direction2 = turn * deg_to_rad(MAX_STEER_ANGLE)
	
	return _steer_direction2
	
	
	## Smoothly interpolate steering for more realistic feel	
	#return lerp(_steer_direction2, target_steer, STEERING_RESPONSE_SPEED * delta)
	
func get_acceleration() -> Vector2:
	var acceleration : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * ENGINE_POWER
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * BRAKING_FORCE
	return acceleration
	
func apply_screen_wrap(): 
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
