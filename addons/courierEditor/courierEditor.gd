@tool
extends EditorPlugin


# I thought about having functionality for multiple roadmaps
# potentially it could be done by always searching all of them, instead of just one
# But you can't actually connect paths over multiple, so having more than one is probably bad
var roadmap: RoadMap
var courier: Courier
var nodes: Array[Intersection]

func _enter_tree():
	add_custom_type("CourierInit", "Node2D", preload("res://addons/courierEditor/courierInit.gd"), preload("res://addons/courierEditor/icon.svg"))

func _exit_tree():
	remove_custom_type("CourierInit")

func _handles(object: Object):
	if object is Courier:
		roadmap = object.get_tree().get_first_node_in_group('roadmap')
		if roadmap != null:
			courier = object
			if courier.roadmap == null:
				courier.roadmap = roadmap
			if courier.roadmap != roadmap:
				print('Somehow the Courier has the wrong RoadMap')
				return false
			return true
		else:
			print('Must have a RoadMap to edit Courier paths')
	
	return false
	
func _forward_canvas_gui_input(event):
	if roadmap != null:
		var localPosition = roadmap.get_local_mouse_position()
		if event is InputEventMouseButton :
			var selectedNode = roadmap.selectNode(localPosition)
			if selectedNode != null:
				if event.pressed == false:
					if event.button_index == MOUSE_BUTTON_LEFT:
						courier.addNode(selectedNode)
					elif event.button_index == MOUSE_BUTTON_MASK_RIGHT:
						# This will remove the node regardless, but returns false if the node wasn't present
						if !courier.removeNode(selectedNode):
							print('Selected Node not in Courier path')
				return true
	return false
