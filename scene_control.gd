extends Node2D

@export var game_scene: PackedScene
@export var splash_screen: PackedScene


func _ready() -> void:
	var scene: PackedScene = splash_screen
	if(Globals.debug_mode):
		scene = game_scene		
	get_tree().call_deferred("change_scene_to_packed", scene)
	
	
	
