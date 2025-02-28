extends CharacterBody2D


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
@onready var car_animation = $CarAnimation
@onready var front_wheel_animation = $WheelAnimation
@onready var front_wheel_sprite = $FrontWheelsSprite
func _ready() -> void:
	idle_animation.timeout.connect(idle_scale)
	


func _physics_process(delta):
	#idle_scale()
	var input = get_input()
	velocity += input["acceleration"] * delta
	var _friction = apply_friction(delta, input["acceleration"],velocity)
	velocity = _friction["velocity"]
	
	var steering = calculate_steering(delta,input["steer_direction"])
	
	#print(input["steer_direction"])
	#front_twheel_sprite.skew = wheeel_skew	
	

	
	if input["steer_direction"] > 0:
		front_wheel_sprite.skew = wheeel_skew * 0.1
	elif input["steer_direction"] < 0:
		front_wheel_sprite.skew = - wheeel_skew * 0.1
	else:
		front_wheel_sprite.skew = 0
	
	
	velocity = steering["velocity"]
	rotation = steering["rotation"]
	
	if(velocity != Vector2.ZERO):
		front_wheel_animation.play("drive")
	else:
		front_wheel_animation.pause()
			
	
	
	move_and_slide()
	# wrap character position (show player on the other size of screen)
	apply_wrap()
	
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
		_velocity = lerp(velocity, new_heading * min(velocity.length(), max_speed_forward), traction * delta)
	if d < 0:
		_velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	_rotation = new_heading.angle()
	
	return {"velocity": _velocity, "rotation": _rotation}

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
