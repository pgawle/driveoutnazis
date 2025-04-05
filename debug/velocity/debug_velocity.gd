extends Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass


func get_velocity(rotation: bool = false):
	var parent = get_parent()
	var vector = parent.velocity
	
	if vector.length() > 50:
		vector = vector.normalized() * 50
	
	if(rotation):
		vector = vector.rotated(-parent.rotation)	
	return vector

func _draw() -> void:
	if(Globals.debug_mode):
		draw_line(position, get_velocity(), Color.RED, 4.0)	
		draw_line(position, get_velocity(true), Color.PINK, 2.0)
