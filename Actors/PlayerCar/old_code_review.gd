extends CharacterBody2D





































@export var wheel_base := 70 # Distance from front to rear wheel
@export var steering_angle := 15 # Amount that front wheel turns, in degrees
var engine_power := 800  # Forward acceleration force.
var braking_power := -450



var steer_direction : float
var acceleration := Vector2.ZERO

#@export var max_speed := 300
#@export_range(0,10,0.1) var drag_factor := 0.1
# var wheel_base = 70  # Distance from front to rear wheel
# var steering_angle = 15  # Amount that front wheel turns, in degrees

#var desired_velocity = Vector2.ZERO
#var steering_velocity = Vector2.ZERO
# var steer_angle


func _physics_process(delta: float) -> void:
	#acceleration = Vector2.ZERO
	#velocity = get_input()
	var changes = get_input(steering_angle, engine_power, braking_power)
	#print(get_input(steering_angle, engine_power))
	#calculate_steering(delta)
	velocity += changes.acceleration * delta
	#rotation = velocity.angle()
	move_and_slide()


func calculate_steering(delta):
	# 1. Find the wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# 2. Move the wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# 3. Find the new direction vector
	var new_heading = rear_wheel.direction_to(front_wheel)
	# 4. Set the velocity and rotation to the new direction
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()


func get_input(angle, power, breaking):
	#new_velocity = Vector2.ZERO
	var turn = 0
	if Input.is_action_pressed("right"):
		turn +=1
		print("right", turn)
	if Input.is_action_pressed("left"):
		turn -=1	
		print("left", turn)
	print("after", turn)
	var steer_angle = turn * deg_to_rad(angle)
	#_angle = turn * deg_to_rad(steering_angle)
	#print(steer_angle)
	if Input.is_action_pressed("up"):
		acceleration = transform.x * power
	if Input.is_action_pressed("down"):
		acceleration = transform.x * breaking	
	return {'steer_angle': steer_angle, 'acceleration': acceleration}

	#return new_velocity	
	#var direction = Input.get_vector("left", "right", "up", "down")
	#print(direction)
	#turn = turn + direction
	
	#desired_velocity = direction * max_speed
	#steering_velocity = desired_velocity - velocity
	#velocity += steering_velocity * drag_factor
	#rotation = velocity.angle()


	
