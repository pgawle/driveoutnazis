extends Button

@export var target_node: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_text()

func _pressed():
	var node = get_node(target_node)
	node.visible = !node.visible  # Toggle visibility
	update_text()

func update_text():
	var node = get_node(target_node)
	text = "Show Settings" if !node.visible else "Hide Settings"
