extends Node2D

@export var game_scene: PackedScene
@export var splash_screen: PackedScene
@export var debug: bool = false

func _ready() -> void:
	var scene: PackedScene = splash_screen
	if(debug):
		scene = game_scene		
	get_tree().change_scene_to_packed(scene)	
	
