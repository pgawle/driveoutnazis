extends Control

#signal on_start
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Globals.debug_mode):
		visible = false




func _on_button_pressed() -> void:
	visible = false
