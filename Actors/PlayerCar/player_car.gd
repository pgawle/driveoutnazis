extends CharacterBody2D

@export var speed := 400
@export var rotation_speed := 1.5

#var rotation_direction := 0

func get_input():
	return {
		"rotation_direction": Input.get_axis("left", "right"),
		"_velocity": Input.get_axis("up", "down")
		}

func _physics_process(delta: float) -> void:
	var input = get_input()
	velocity = transform.x * input["_velocity"] * speed
	rotation += input["rotation_direction"] * rotation_speed * delta
	move_and_slide()
	
