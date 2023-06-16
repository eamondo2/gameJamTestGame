@tool
extends Button

var plugin

func _enter_tree():
	plugin = get_parent().plugin
	pressed.connect(clicked);
	
func clicked():
	plugin.reset()
