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
@export var MAX_SPEED_FORWARD := 400
@export var MAX_SPEED_REVERSE := 100

@export_group("Drift & Handbrake")
@export var HANDBRAKE_FRICTION := 0.04  # Lower = more slide (0-1)
@export var HANDBRAKE_STOPPING_POWER := 80.0  # How quickly handbrake stops the car (higher = faster)
@export var DRIFT_RECOVERY_RATE := 0.5  # How quickly car regains traction (higher = faster)
@export var DRIFT_DURATION := 5  # Minimum drift duration after handbrake release

@export_group("Physics")
@export var GROUND_FRICTION := 0
@export var DRAG := -0.06
@export var SLIP_START_SPEED := 300       # Speed where traction is reduced
@export var TRACTION_WHEN_FAST := 6    # High-speed traction
@export var TRACTION_WHEN_SLOW := 10     # Low-speed traction
@export var STOPPING_SPEED_LIMIT := 20.0   # Speed below which car stops when no input

@export_group("Visual Effects")
@export var SCALE_RATE_X := 0.02
@export var SCALE_RATE_Y := 0.03
@export var WHEEL_SKEW := 3


# ------------------------------------------------------------------
# Internal State Variables
# ------------------------------------------------------------------
var steer_direction := 0.0
var scale_up := false 
var handbrake_active = false
var drift_timer = 0.0

# ------------------------------------------------------------------
# Node References
# ------------------------------------------------------------------
@onready var screen_size = get_viewport_rect().size
@onready var idle_animation = %IdleAnimTimer
@onready var front_wheel_animation = %WheelAnimation
@onready var front_wheel_sprite = %FrontWheelsSprite


func update_handbrake_and_drift(delta):
	handbrake_active = Input.is_action_pressed("handbrake")
	if(handbrake_active):
		drift_timer = DRIFT_DURATION
	elif drift_timer > 0: 
		drift_timer -= delta

func _ready() -> void:
	idle_animation.timeout.connect(idle_scale)



func _physics_process(delta):
	var acceleration = get_acceleration()
	steer_direction = get_steer_direction(steer_direction, delta)
	
	update_handbrake_and_drift(delta)
	
	var movement = calculate_movement(steer_direction, delta)
	velocity = movement["velocity"]
	rotation = movement["rotation"]
	
	apply_speed(acceleration,delta)
	
	update_visuals(steer_direction)
	
	move_and_slide()
	apply_screen_wrap()



	

func calculate_movement(_steer_direction: float, delta) -> Dictionary: 
	var _rotation: float = 0
	var _velocity := Vector2.ZERO
	
	# Find the wheel positions
	var rear_wheel = position - transform.x * WHEEL_BASE / 2.0
	var front_wheel = position + transform.x * WHEEL_BASE / 2.0
	
	# Move the wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(_steer_direction) * delta
	
	# Find the new direction vector
	var new_direction = rear_wheel.direction_to(front_wheel)
	# Choose which traction value to use - at lower speeds, slip should be low
	var traction = TRACTION_WHEN_SLOW
	if velocity.length() > SLIP_START_SPEED:
		traction = TRACTION_WHEN_FAST
	
		# Reduce traction significantly when handbrake is active (DRIFT)
	if(handbrake_active):
		traction *= HANDBRAKE_FRICTION
	elif(drift_timer > 0):
		# Gradual recovery after handbrake release
		var recovery_factor = (DRIFT_DURATION - drift_timer) / DRIFT_DURATION
		traction *= lerp(HANDBRAKE_FRICTION, 1.0, recovery_factor)
	
	# Are we braking, going forward or backward
	var d = new_direction.dot(velocity.normalized())
	if d > 0:
		# using linear interpolation to add drift
		_velocity = lerp(velocity, new_direction * min(velocity.length(), MAX_SPEED_FORWARD), traction * delta)
	if d < 0:
		_velocity = -new_direction * min(velocity.length(), MAX_SPEED_REVERSE)
	
	_rotation = new_direction.angle()
	
	return {
		"velocity": _velocity,
		 "rotation": _rotation
		}


func apply_speed(acceleration: Vector2, delta):
	if acceleration == Vector2.ZERO and velocity.length() < STOPPING_SPEED_LIMIT:
		velocity =  Vector2.ZERO
	else:
		print(handbrake_active)
		var friction_force = velocity * GROUND_FRICTION * delta
		var drag_force = velocity * velocity.length() * DRAG * delta
		
		# slow down with handbrake
		if(handbrake_active):
			var handbrake_force = velocity.normalized() * -1.0 * velocity.length() * HANDBRAKE_STOPPING_POWER * delta
			friction_force += handbrake_force
			
		var acceleration_with_forces = acceleration + drag_force + friction_force
		velocity += acceleration_with_forces * delta
		


func get_steer_direction(_steer_direction: float, delta) -> float:
	var turn = Input.get_axis("ui_left", "ui_right")
	var target_steer = turn * deg_to_rad(MAX_STEER_ANGLE)
	
	## Smoothly interpolate steering for more realistic feel	
	return lerp(_steer_direction, target_steer, STEERING_RESPONSE_SPEED * delta)
	
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
	
func update_visuals(_steer_direction):
	if _steer_direction > 0:
		front_wheel_sprite.skew = WHEEL_SKEW * 0.1
	elif _steer_direction < 0:
		front_wheel_sprite.skew = - WHEEL_SKEW * 0.1
	else:
		front_wheel_sprite.skew = 0

	if(velocity != Vector2.ZERO):
		front_wheel_animation.play("drive")
	else:
		front_wheel_animation.pause()
		
func idle_scale():
	if(scale_up == false):
		scale.x -= SCALE_RATE_X
		scale.y -= SCALE_RATE_Y
		scale_up = true
	else:
		scale.x += SCALE_RATE_X
		scale.y += SCALE_RATE_Y
		scale_up = false
		
