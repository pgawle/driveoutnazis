extends RigidBody2D

func _ready():
	add_to_group(Globals.groups.enemy)

func _physics_process(delta):
	pass

func on_hit(velocity: Vector2): 
	print("hit", velocity)
	queue_free()
