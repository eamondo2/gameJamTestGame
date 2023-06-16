@tool
extends EditorPlugin


# A class member to hold the dock during the plugin life cycle.
var dock
var roadmap: RoadMap
var selectedNode: Intersection
var dragging: bool = false
var oldPosition: Vector2

func _enter_tree():
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.
	dock = preload("res://addons/roadBuilder/dock.tscn").instantiate()
	dock.plugin = self
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	add_custom_type("RoadMap", "Node2D", preload("res://addons/roadBuilder/roadMap.gd"), preload("res://addons/roadBuilder/icon.svg"))
	add_custom_type("Intersection", "Sprite2D", preload("res://addons/roadBuilder/intersection.gd"), preload("res://addons/roadBuilder/icon.svg"))
	add_custom_type("Dropoff", "Sprite2D", preload("res://addons/roadBuilder/dropoff.gd"), preload("res://addons/roadBuilder/icon.svg"))

func setRoadMap(roadMap: RoadMap):
	self.roadmap = roadMap
	
func doneEditing():
	self.roadmap = null
	self.selectedNode = null
	
func reset():
	if roadmap != null:
		roadmap.reset()
		
func _handles(object: Object):
	# Ok, this might actually be what we want, but I'm gonna hold off on doing it right for now
	return true
	
func _forward_canvas_gui_input(event):
	#### INSTRUCTIONS ####
	# Left click dragging moves a node
	# Dragging one node onto another puts the dragged node back, and adds a connection
	# Right clicking deletes nodes or connections
	# Left clicking on empty space creates a new node (and automatically attaches it to nearby nodes)
	# Double clicking converts an Intersection to a Dropoff
	if roadmap != null:
		# I hate this. It doesn't even work
		var realPosition = get_editor_interface().get_editor_main_screen().get_global_transform_with_canvas().inverse()*event.position
		if event is InputEventMouseButton:
			if event.pressed:
				print('pressed')
				if selectedNode == null:
					selectedNode = roadmap.selectNode(realPosition)
					if selectedNode != null:
						print('selected node')
						oldPosition = selectedNode.position
						if event.button_index == MOUSE_BUTTON_RIGHT:
							print('remove node')
							roadmap.removeNode(selectedNode)
							selectedNode = null
						else:
							if event.button_index == MOUSE_BUTTON_LEFT:
								if event.double_click:
									print('convert node')
									roadmap.convertToDropoff(selectedNode)
								else:
									print('dragging node')
									dragging = true
					else:
						if event.button_index == MOUSE_BUTTON_RIGHT:
							roadmap.attemptRemoveConnection(realPosition)
						else:
							print('add node')
							roadmap.addNode(realPosition)
			else:
				print('released')
				if selectedNode != null:
					print('dropped node')
					roadmap.moveNode(selectedNode, oldPosition)
					var isOnNode = roadmap.selectNode(realPosition)
					if isOnNode != null:
						print('added connection')
						roadmap.addNewConnection(selectedNode, isOnNode)
					else:
						roadmap.moveNode(selectedNode, realPosition)
					selectedNode = null
				dragging = false
		else:
			if event is InputEventMouseMotion and selectedNode != null and dragging:
				roadmap.moveNode(selectedNode, realPosition)
		return true
	else:
		return false

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
