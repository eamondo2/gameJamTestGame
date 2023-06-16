@tool
extends Button

var plugin

func _enter_tree():
	plugin = get_parent().plugin
	pressed.connect(clicked);
	
func clicked():
	var node = plugin.get_editor_interface().get_selection().get_selected_nodes()[0]
	if node is RoadMap:
		plugin.setRoadMap(node)
		get_parent().textBox.text = "[center]Selected: " + node.name + "[/center]"
	else:
		print('Selected Node is not a RoadMap')
		print(node)
