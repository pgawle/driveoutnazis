extends RigidBody2D

func _ready():
	add_to_group(Globals.groups.enemy)
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
