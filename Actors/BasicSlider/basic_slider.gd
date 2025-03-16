class_name BasicSlider
extends Node2D

# SIGNALS

signal  value_changed(value: float)

# Configuration Parameters

@export var Variable_Name :String= "Variable_Name"
@export var Value :float = 0
@export var Min_Value :float
@export var Max_Value :float = 10000
@export var Step :float = 1
@export var player_path: NodePath
@export var player: CharacterBody2D = null

# Connected Nodes

@onready var decription_label = %Description
@onready var value_label = %Value
@onready var slider = %HSlider

#internal

var property_present = null

func _ready() -> void:
	
	decription_label.text = Variable_Name
	property_present = player.get(Variable_Name)
	
	if(property_present != null):
		#player[Variable_Name] = Value
		Value = property_present
		decription_label.text = Variable_Name + ", default:" + str(property_present)
		value_label.text = str(property_present)
		
		slider.value = Value
		slider.min_value = Min_Value
		slider.max_value = Max_Value
		slider.step = Step
		
		
	else:
		decription_label.text = Variable_Name + " not propery present, not connected"

func _on_h_slider_value_changed(slider_value: float) -> void:
	value_label.text = str(slider_value)
	value_changed.emit(slider_value)
	if(property_present != null):
		player[Variable_Name] = slider_value

func _on_h_slider_init_done() -> void:
	#bad example, fixing race problem just for testing
	await get_tree().process_frame
	slider.value = Value
	
	
	
	
	
