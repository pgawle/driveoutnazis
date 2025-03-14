extends Node2D

# ------------------------------------------------------------------
# Configuration Parameters
# ------------------------------------------------------------------

@export var MARK_COLOUR := Color(0,0,0)
@export var MARK_WIDTH := 2.0

var current_line1: Line2D = null
var current_line2: Line2D = null

func start_drawing(points):
	if(!current_line1):
		current_line1 = Line2D.new()
		add_child(current_line1)
		current_line1.width = MARK_WIDTH
		current_line1.default_color = MARK_COLOUR
		
		current_line2 = Line2D.new()
		add_child(current_line2)
		current_line2.width = MARK_WIDTH
		current_line2.default_color = MARK_COLOUR
	
	if(points == null):
		current_line1 = null
		current_line2 = null
	else:
		current_line1.add_point(points[0])
		current_line2.add_point(points[1])


func _on_player_car_draw_mark(point) -> void:
	start_drawing(point)
