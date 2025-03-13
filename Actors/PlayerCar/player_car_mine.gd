extends CharacterBody2D

# Vehicle Properties
@export_group("Steering")
@export var wheel_base := 20.0       # Distance from front to rear wheel
@export var steer_angle := 15.0      # Maximum steering angle in degrees
@export var steering_speed := 5.0    # How quickly steering responds

@export_group("Engine")
@export var engine_power := 500.0    # Forward acceleration force
@export var braking := -450.0        # Braking force
@export var max_speed_forward := 300.0
@export var max_speed_reverse := 100.0
@export var acceleration_curve := 1.0 # Higher values make acceleration more responsive

@export_group("Physics")
@export var friction := -55.0        # Base friction force
@export var drag := -0.06            # Air resistance (increases with speed)
@export var slip_speed := 200.0      # Speed where traction is reduced
@export var traction_fast := 2.5     # High-speed traction
@export var traction_slow := 10.0    # Low-speed traction
@export var drift_threshold := 0.8   # How much steering triggers drift (0-1)
@export var drift_factor := 0.95     # How pronounced the drift is (0-1)

@export_group("Visual Effects")
@export var idle_scale_rate_x := 0.02
@export var idle_scale_rate_y := 0.03
@export var wheel_skew := 3.0
@export var smoke_threshold := 250.0  # Speed threshold for tire smoke

# Internal state variables
var current_steer := 0.0
var scale_up := false
var drifting := false
var engine_sound_pitch := 1.0

# Nodes
@onready var screen_size = get_viewport_rect().size
@onready var idle_animation = $IdleAnimTimer
@onready var front_wheel_animation = $WheelAnimation
@onready var front_wheel_sprite = $FrontWheelsSprite
@onready var engine_sound = $EngineSound if has_node("EngineSound") else null
@onready var tire_smoke = $TireSmoke if has_node("TireSmoke") else null

func _ready() -> void:
	idle_animation.timeout.connect(idle_scale)
	
	# Initialize components that might not exist to avoid errors
	if not has_node("WheelAnimation"):
		push_warning("WheelAnimation node not found. Wheel animations disabled.")
	
	if not has_node("FrontWheelsSprite"):
		push_warning("FrontWheelsSprite node not found. Wheel steering visuals disabled.")

func _physics_process(delta: float) -> void:
	# Get player input
	var input = get_input()
	
	# Smoothly interpolate steering for more realistic feel
	current_steer = lerp(current_steer, input.steer_direction, steering_speed * delta)
	
	# Apply acceleration based on input
	velocity += input.acceleration * delta
	
	# Apply physics forces
	apply_physics_forces(delta, input.acceleration)
	
	# Calculate steering and update velocity/rotation
	var steering = calculate_steering(delta, current_steer)
	velocity = steering.velocity
	rotation = steering.rotation
	
	# Update visuals
	update_visuals(input.steer_direction, input.acceleration)
	
	# Apply movement
	move_and_slide()
	
	# Handle screen wrapping
	apply_wrap()

func get_input() -> Dictionary:
	var acceleration = Vector2.ZERO
	var turn = Input.get_axis("ui_left", "ui_right")
	var steer_direction = turn * deg_to_rad(steer_angle)
	
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power * pow(Input.get_action_strength("ui_up"), acceleration_curve)
	elif Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking * pow(Input.get_action_strength("ui_down"), acceleration_curve)
	
	return {"acceleration": acceleration, "steer_direction": steer_direction}




func apply_physics_forces(delta: float, acceleration: Vector2) -> void:
	# Stop completely if we're very slow and not accelerating
	if acceleration == Vector2.ZERO and velocity.length() < 20:
		velocity = Vector2.ZERO
		return
		
	# Apply friction and drag forces
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	velocity += friction_force + drag_force

func calculate_steering(delta: float, steer_direction: float) -> Dictionary:
	# Calculate wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	# Move wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	# Calculate new heading
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	# Determine traction based on speed
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
		
		# Check if we're drifting
		var steering_factor = abs(steer_direction) / deg_to_rad(steer_angle)
		drifting = steering_factor > drift_threshold && velocity.length() > slip_speed
		
		if drifting:
			traction *= drift_factor
	else:
		drifting = false
	
	# Calculate new velocity based on direction of travel
	var new_velocity = velocity
	var d = new_heading.dot(velocity.normalized())
	
	if d > 0:
		# Going forward - use linear interpolation for smooth steering
		new_velocity = lerp(velocity, new_heading * min(velocity.length(), max_speed_forward), traction * delta)
	elif d < 0:
		# Going backward
		new_velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	return {"velocity": new_velocity, "rotation": new_heading.angle()}

func update_visuals(steer_direction: float, acceleration: Vector2) -> void:
	# Handle wheel animation
	if front_wheel_animation:
		if velocity.length() > 5:
			front_wheel_animation.play("drive")
		else:
			front_wheel_animation.pause()
	
	# Handle wheel steering visuals
	if front_wheel_sprite:
		if steer_direction > 0:
			front_wheel_sprite.skew = wheel_skew * 0.1
		elif steer_direction < 0:
			front_wheel_sprite.skew = -wheel_skew * 0.1
		else:
			front_wheel_sprite.skew = 0
	
	# Handle tire smoke effect if we have the particle system
	if tire_smoke and velocity.length() > smoke_threshold and drifting:
		tire_smoke.emitting = true
	elif tire_smoke:
		tire_smoke.emitting = false
	
	# Handle engine sound if we have the audio player
	if engine_sound:
		# Calculate engine pitch based on speed
		var target_pitch = remap(velocity.length(), 0, max_speed_forward, 0.8, 1.5)
		engine_sound_pitch = lerp(engine_sound_pitch, target_pitch, 0.05)
		engine_sound.pitch_scale = engine_sound_pitch
		
		if not engine_sound.playing:
			engine_sound.playing = true

func idle_scale() -> void:
	if scale_up:
		scale.x -= idle_scale_rate_x
		scale.y -= idle_scale_rate_y
	else:
		scale.x += idle_scale_rate_x
		scale.y += idle_scale_rate_y
	
	scale_up = !scale_up

func apply_wrap() -> void:
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
