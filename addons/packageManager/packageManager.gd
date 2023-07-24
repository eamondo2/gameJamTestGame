@tool
extends EditorPlugin

var packages: Array[Variant]
var roadmap: RoadMap
var dragging: Package

const INTERACTION_DISTANCE = 5

func _enter_tree():
	getPackages(null)
	scene_changed.connect(getPackages)

func getPackages(scene):
		packages = get_tree().get_nodes_in_group('packages')
		roadmap = get_tree().get_first_node_in_group('roadmap')

func _handles(object: Object):
	if object is Package:
		print('select')
		dragging = object
		roadmap = object.get_tree().get_first_node_in_group('roadmap')
		return true
	return false
	
func _forward_canvas_gui_input(event):
	if event is InputEventMouseButton:
		print('button')
		if event.pressed:
			print('click')
			if event.button_index == MOUSE_BUTTON_LEFT:
				if !event.double_click:
					for node in packages:
						if (node.get_global_mouse_position()-node.position).length() < INTERACTION_DISTANCE:
							print('dragging')
							dragging = node
							roadmap = dragging.get_tree().get_first_node_in_group('roadmap')
							# Do consume input
							return true
					print('deselect')
					dragging = null
					get_editor_interface().get_selection().clear()
					# Don't consume input
					return false
		elif  event.button_index == MOUSE_BUTTON_LEFT:
			print('unclick')
			# Find nearest intersection:
			if dragging and roadmap and roadmap.nodes.size() > 0:
				print('trying to find closest')
				var closest = roadmap.nodes[0]
				var dist = (dragging.position - closest.position).length()
				for node in roadmap.nodes:
					var newDist = (dragging.position - node.position).length()
					if newDist < dist:
						closest = node
						dist = newDist
				dragging.position = closest.position
				dragging.homeNode = closest
			else:
				print(dragging)
				print(roadmap)
				print(roadmap.nodes.size())
			print('dropping')
			dragging = null
			# Do consume input
			return false
	elif event is InputEventMouseMotion and dragging:
		dragging.position = dragging.get_global_mouse_position()
		# Do consume input
		return true

