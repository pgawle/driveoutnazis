extends CharacterBody2D

# ------------------------------------------------------------------
# Configuration Parameters
# ------------------------------------------------------------------

@export_group("Steering")
@export var wheel_base := 20        # Distance from front to rear wheel
@export var steer_angle := 15       # Amount that front wheel turns, in degrees
@export var steering_speed := 5.0   # How quickly steering responds

@export_group("Engine")
@export var engine_power := 500     # Forward acceleration force
@export var braking_force := -450         # Braking force
@export var max_speed_forward := 300
@export var max_speed_reverse := 100
@export var acceleration_curve := 1.0    # Higher values make acceleration more responsive
@export var stopping_threshold := 20.0   # Speed below which car stops when no input

@export_group("Physics")
@export var FRICTION := -55
@export var drag := -0.06
@export var slip_speed := 200       # Speed where traction is reduced
@export var traction_fast := 2.5    # High-speed traction
@export var traction_slow := 10     # Low-speed traction

@export_group("Drift & Handbrake")
@export var handbrake_friction := 0.15   # Lower = more slide (0-1)
@export var handbrake_turn_effect := 2.5 # Higher = more rotation during drift
@export var drift_recovery_rate := 2.0   # How quickly car regains traction (higher = faster)
@export var drift_threshold := 50.0      # Minimum speed for drift effects
@export var DRIFT_DURATION := 0.7        # Minimum drift duration after handbrake release
@export var handbrake_brake_force := 600 # Force applied when handbrake is active
@export var drift_trail_speed := 100.0   # Speed threshold for drift trails/effects

@export_group("Visual Effects")
@export var scale_rate_x := 0.02
@export var scale_rate_y := 0.03
@export var wheel_skew := 3

# ------------------------------------------------------------------
# Internal State Variables
# ------------------------------------------------------------------
var current_steer := 0.0
var scale_up := false
var drifting := false
var handbrake_active := false
var drift_timer := 0.0
var tire_grip := 1.0       # Dynamic grip value (1.0 = full grip, lower = less grip)

# ------------------------------------------------------------------
# Node References
# ------------------------------------------------------------------
@onready var screen_size = get_viewport_rect().size
@onready var idle_animation = %IdleAnimTimer
@onready var front_wheel_animation = %WheelAnimation
@onready var front_wheel_sprite = %FrontWheelsSprite


func _ready() -> void:
	idle_animation.timeout.connect(idle_scale)
	

func is_drift_active(is_handbrake_active: bool, drift_timer: float, delta: float) -> bool:
	# Handle drift timer for continued drift after handbrake release
	if is_handbrake_active:
		drift_timer = DRIFT_DURATION
	elif drift_timer > 0:
		drift_timer -= delta
	return true


func _physics_process(delta):
	#idle_scale()
	var input = get_input() # Understood
	
	
	#is_drift_active()
	
	#get_handbrakestate(input.handbrake, delta)
	
	#var target_steer = input.steer_direction
	#if handbrake_active or drift_timer > 0:
		## Enhanced steering during drift
		#target_steer *= handbrake_turn_effect
	#
	#
	## Smoothly interpolate steering for more realistic feel
	#current_steer = lerp(current_steer, target_steer, steering_speed * delta)
	#
	## Apply acceleration forces
	##print("handbrak=",handbrake_active, "drifting=",!drifting)
	#if handbrake_active && !drifting:
		#
		## Apply strong braking force when handbrake is active
		#velocity += -velocity.normalized() * handbrake_brake_force * delta
	#else:
		## Normal acceleration when handbrake is not active
		#velocity += input.acceleration * delta
	
	var friction = apply_friction(delta, input.acceleration,velocity)
	velocity = friction.velocity
	
	
	var steering = calculate_steering(delta,current_steer)
	
	velocity = steering["velocity"]
	rotation = steering["rotation"]
	
	
	update_visuals(input.steer_direction)
	# Apply movement
	move_and_slide()
	# Handle screen wrapping
	apply_wrap()
	
func get_input() -> Dictionary:
	var acceleration = Vector2.ZERO
	var turn = Input.get_axis("ui_left", "ui_right")
	var steer_direction = turn * deg_to_rad(steer_angle)
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking_force
	
	var handbrake = Input.is_action_pressed("handbrake")
	
	
	return {"acceleration": acceleration, "steer_direction": steer_direction, "handbrake": handbrake}

func apply_friction(delta, acceleration, _velocity):
	if acceleration == Vector2.ZERO and velocity.length() < stopping_threshold:
		_velocity = Vector2.ZERO
	var friction_force = _velocity * FRICTION * delta
	var drag_force = _velocity * _velocity.length() * drag * delta
	var _acceleration = acceleration+ drag_force + friction_force
	return {"acceleration": _acceleration, "velocity": _velocity}




func calculate_steering(delta, steer_direction: float) -> Dictionary:
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


	



func update_visuals(steer_direction):
	if steer_direction > 0:
		front_wheel_sprite.skew = wheel_skew * 0.1
	elif steer_direction < 0:
		front_wheel_sprite.skew = - wheel_skew * 0.1
	else:
		front_wheel_sprite.skew = 0

	if(velocity != Vector2.ZERO):
		front_wheel_animation.play("drive")
	else:
		front_wheel_animation.pause()

func idle_scale():
		
	if(scale_up == false):
		scale.x -= scale_rate_x
		scale.y -= scale_rate_y
		scale_up = true
	else:
		scale.x += scale_rate_x
		scale.y += scale_rate_y
		scale_up = false
		
	
func apply_wrap(): 
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
