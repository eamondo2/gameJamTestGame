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
	if object is RoadMap:
		roadmap = object
		return true
	return false
	
func _forward_canvas_gui_input(event):
	#### INSTRUCTIONS ####
	# Left click dragging moves a node
	# Dragging one node onto another puts the dragged node back, and adds a connection
	# Right clicking deletes nodes or connections
	# Left clicking on empty space creates a new node (and automatically attaches it to nearby nodes)
	# Double clicking converts an Intersection to a Dropoff
	if roadmap != null:
		var localPosition = roadmap.get_local_mouse_position()
		if event is InputEventMouseButton:
			if event.pressed:
				if selectedNode == null:
					selectedNode = roadmap.selectNode(localPosition)
					if selectedNode != null:
						oldPosition = selectedNode.position
						if event.button_index == MOUSE_BUTTON_RIGHT:
							roadmap.removeNode(selectedNode)
							selectedNode = null
						elif event.button_index == MOUSE_BUTTON_LEFT:
							if event.double_click:
								roadmap.switchType(selectedNode)
							else:
								dragging = true
					else:
						if event.button_index == MOUSE_BUTTON_RIGHT:
							roadmap.attemptRemoveConnection(localPosition)
						elif event.button_index == MOUSE_BUTTON_LEFT:
							roadmap.addNode(localPosition)
			elif  event.button_index == MOUSE_BUTTON_LEFT:
				if selectedNode != null:
					roadmap.moveNode(selectedNode, oldPosition)
					var isOnNode = roadmap.selectNode(localPosition)
					if isOnNode != null:
						roadmap.addNewConnection(selectedNode, isOnNode)
					else:
						roadmap.moveNode(selectedNode, localPosition)
					selectedNode = null
				dragging = false
		elif event is InputEventMouseMotion and selectedNode != null and dragging:
			roadmap.moveNode(selectedNode, localPosition)
		return true
	else:
		return false

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
