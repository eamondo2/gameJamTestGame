@tool
extends Button

var plugin

func _enter_tree():
	plugin = get_parent().plugin
	pressed.connect(clicked);
	
func clicked():
	plugin.doneEditing()
	get_parent().textBox.text = "[center]Create and select a RoadMap instance to edit[/center]"
