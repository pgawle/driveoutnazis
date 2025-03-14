extends Node2D

# ------------------------------------------------------------------
# Configuration Parameters
# ------------------------------------------------------------------

@export var MARK_COLOUR := Color(0,0,0)
@export var MARK_WIDTH := 2.0
var POINT_SEPARATION = 10

var current_line1: Line2D = null
var current_line2: Line2D = null

func start_drawing(points):
	if(!current_line1):
		
		current_line1 = get_new_line()
		current_line2 = get_new_line()

		add_child(current_line1)
		add_child(current_line2)
	
	if(points == null):
		current_line1 = null
		current_line2 = null
	else:
		current_line1.add_point(points[0])
		current_line2.add_point(points[1])


func get_new_line() -> Line2D:
	var curve = Curve.new()
	# Add points to the curve (position, value, left_tangent, right_tangent)
	curve.add_point(Vector2(0, 0.1))  # Start of line, normal width
	curve.add_point(Vector2(0.2, 1))  # Middle of line, double width
	
	var new_line = Line2D.new()
	new_line.antialiased = true
	new_line.width = MARK_WIDTH
	new_line.default_color = MARK_COLOUR
	#new_line.width_curve = curve
	
	return new_line
	

func _on_player_car_draw_mark(point) -> void:
	start_drawing(point)
