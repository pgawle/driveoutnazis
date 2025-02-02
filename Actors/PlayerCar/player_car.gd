extends CharacterBody2D

@export var max_speed := 300
@export_range(0,10,0.1) var drag_factor := 0.1
# var wheel_base = 70  # Distance from front to rear wheel
# var steering_angle = 15  # Amount that front wheel turns, in degrees

var desired_velocity = Vector2.ZERO
var steering_velocity = Vector2.ZERO
# var steer_angle


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	desired_velocity = direction * max_speed
	steering_velocity = desired_velocity - velocity
	velocity += steering_velocity * drag_factor
	rotation = velocity.angle()


	
