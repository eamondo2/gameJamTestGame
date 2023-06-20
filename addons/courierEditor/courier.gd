@tool
class_name Courier
extends Node2D

@export var sprite: Texture2D:
	set(value):
		var spriteNode: Sprite2D = get_node("Path/spriteFollow/personSprite");
		spriteNode.texture = value;
		sprite = value;
		#notify_property_list_changed()
	
@export_range(0, 1, .01) var progress_ratio: float:
	set(value):
		progress_ratio = value;
		get_node("Path/spriteFollow").progress_ratio = value;
		#notify_property_list_changed()

@export_color_no_alpha var color: Color = Color.RED

@export var speedScale = 1;

var roadmap: RoadMap
var requiredNodes: Array[Intersection] = []
var totalNodes: Array[Intersection] = []
var dragging = false
var selected = false
var dropTarget
var target

const PATH_WIGGLE = 20
const INTERACTION_DISTANCE = 10
const DROP_DISTANCE = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('courier', true)
	self.roadmap = get_tree().get_first_node_in_group('roadmap')
	self.progress_ratio = self.progress_ratio;

func _process(delta):
	if !Engine.is_editor_hint():
		self.progress_ratio += speedScale * 0.05 * delta;
		if dropTarget != null and (dropTarget.position - position).length() < DROP_DISTANCE:
			dropTarget = null
			# Drop the package
		
func _input(event):
	if !Engine.is_editor_hint():
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if (event.position - position).length() < INTERACTION_DISTANCE:
					dragging = true
				else:
					dragging = false
			else:
				if dragging:
					var node = roadmap.selectNode(event.position)
					if node is DropOff:
						dropTarget = node.position
				dragging = false
		elif event is InputEventMouseMotion and dragging:
			target = event.position
			queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		for n in requiredNodes:
			draw_circle(n.position, 7, color)
	else:
		if dragging and target != null:
			draw_line(position, target, color, 3)
		if dropTarget != null:
			draw_circle(dropTarget, 7, color)

func addNode(node: Intersection):
	if requiredNodes.find(node) == -1:
		requiredNodes.append(node)
		redoPath(roadmap)

func removeNode(node: Intersection):
	for i in range(requiredNodes.size()):
		if requiredNodes[i] == node:
			requiredNodes.remove_at(i)
			redoPath(roadmap)
			return true
	return false
			
func redoPath(roadmap: RoadMap):
	var curveObj = self.get_node("Path")
	# Need at least 2 points, otherwise we just want an empty path
	if requiredNodes.size() > 1:
		var path: Array[Intersection] = []
		var previousNode
		for n in requiredNodes:
			if previousNode != null:
				# This will return a list of nodes, exclusive on the first step, inclusive on the last
				# Would be nice if we could make it not overlap itself, but that's tricky
				path.append_array(roadmap.findPath(previousNode, n))
			else:
				path.append(n)
			previousNode = n
		# Connect end to start
		path.append_array(roadmap.findPath(requiredNodes[-1], requiredNodes[0]))
		curveObj.curve.clear_points()
		for n in path:
			curveObj.curve.add_point(roadmap.to_local(n.position+Vector2(PATH_WIGGLE*(randf()-.5), PATH_WIGGLE*(randf()-.5))))
			
		totalNodes = path
	else:
		totalNodes = []
		curveObj.curve.clear_points()
	queue_redraw()
