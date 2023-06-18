@tool
extends EditorPlugin

var roadmap: RoadMap
var selectedNode: Intersection
var dragging: bool = false
var oldPosition: Vector2


func _enter_tree():
	add_custom_type("RoadMap", "Node2D", preload("res://addons/roadBuilder/roadMap.gd"), preload("res://addons/roadBuilder/icon.svg"))
	add_custom_type("Intersection", "Sprite2D", preload("res://addons/roadBuilder/intersection.gd"), preload("res://addons/roadBuilder/icon.svg"))
	add_custom_type("Dropoff", "Sprite2D", preload("res://addons/roadBuilder/dropoff.gd"), preload("res://addons/roadBuilder/icon.svg"))

func _exit_tree():
	remove_custom_type("RoadMap")
	remove_custom_type("Intersection")
	remove_custom_type("Dropoff")
	
func setRoadMap(roadMap: RoadMap):
	self.roadmap = roadMap
	
func doneEditing():
	self.roadmap = null
	self.selectedNode = null
	
func reset():
	if roadmap != null:
		roadmap.reset()
		
func _handles(object: Object):
	if object is RoadMap:
		roadmap = object
		return true
	if object is Intersection:
		print('intersection select event')
		self.selectedNode = object
		return true
	return false
	
func _forward_canvas_gui_input(event):
	
	if self.selectedNode != null:
		# catch interaction with child of roadMap when directly selected
		self.roadmap = self.selectedNode.get_parent()
	
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
		# Do consume input
		return true
	else:
		# Don't consume input
		return false

