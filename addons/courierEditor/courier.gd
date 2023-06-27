@tool
class_name Courier
extends Node2D
	
@export_range(0, 1, .01) var progress_ratio: float:
	set(value):
		progress_ratio = value;
		get_node("Path/spriteFollow").progress_ratio = value;
		#notify_property_list_changed()

@export_color_no_alpha var color: Color = Color.RED

@export_range(0, 5, 0.01) var speedScale: float = 1:
	set(value):
		speedScale = value;

@export var curve: Curve2D = Curve2D.new()

@export var modelTint: Color = Color.RED:
	set(val):
		modelTint = val;
@export_range(0, 1, 0.1) var modelTintFactor:
	set(val):
		modelTintFactor = val;

var roadmap: RoadMap
var requiredNodes: Array[Intersection] = []
var totalNodes: Array[Intersection] = []
var dragging = false
var selected = false
var dropTarget
var target
var package

var should_pause = false;
var control_speed_scale = 1;

const PATH_WIGGLE = 20
const INTERACTION_DISTANCE = 10
const DROP_DISTANCE = 30

func renderedPosition():
	var childSprite = self.get_node("Path/spriteFollow/truckSprite");
	return childSprite.global_position;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('courier', true)
	self.roadmap = get_tree().get_first_node_in_group('roadmap')
	self.progress_ratio = self.progress_ratio;
	setCurve(curve)

func _process(delta):
	get_node("Path/spriteFollow/truckSprite").modelTint = modelTint;
	get_node("Path/spriteFollow/truckSprite").modelTintFactor = modelTintFactor;
	if !Engine.is_editor_hint():
		delta = delta * control_speed_scale;
		if should_pause:
			delta = 0;
		queue_redraw()
		self.progress_ratio += speedScale * 0.1 * delta;
		if dropTarget != null:
			if package == null:
				# If we're near the package, set package
				var packages = get_tree().get_nodes_in_group('packages')
				for p in packages:
					if (p.global_position - renderedPosition()).length() <= DROP_DISTANCE:
						package = p
						package.carriedBy = self
						break
			else:
				package.setPosition(renderedPosition())
				if (dropTarget - renderedPosition()).length() < DROP_DISTANCE:
					package.setPosition(dropTarget)
					package.carriedBy = null
					dropTarget = null
					package = null
		
func _input(event):
	if !Engine.is_editor_hint():
		if event is InputEventMouseButton:
			print('evt trigger')
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				print('press and mbleft')
				if (get_global_mouse_position() - renderedPosition()).length() < INTERACTION_DISTANCE:
					print('press, within int.dist')
					dragging = true
				else:
					dragging = false
			else:
				if dragging:
					var node = roadmap.selectNode(get_global_mouse_position())
					if node is DropOff:
						dropTarget = node.global_position
				dragging = false
		elif event is InputEventMouseMotion and dragging:
			target = get_global_mouse_position()
			queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		for n in requiredNodes:
			draw_circle(n.global_position, 7, color)
	else:
		# draw_line(get_global_mouse_position(), (self.get_node("Path/spriteFollow/personSprite").global_position), Color.ORANGE, 2)
		# draw_circle(renderedPosition(), INTERACTION_DISTANCE, Color.PALE_TURQUOISE)
		# var packages = get_tree().get_nodes_in_group('packages')
		# for p in packages:
		# 	draw_line(get_global_mouse_position(), p.global_position, Color.RED, 2);
		# 	draw_circle(p.global_position, 3, Color.FUCHSIA)
		if dragging and target != null:
			draw_line(renderedPosition(), target, color, 3)
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
		curve.clear_points()
		var points = []
		for n in path:
			points.append(roadmap.to_local(n.position+Vector2(PATH_WIGGLE*(randf()-.5), PATH_WIGGLE*(randf()-.5))))
		# Make the ends meet up
		points[-1] = points[0]
		for i in range(points.size()):
			# Attempt at smoothing the curve, not quite sure why it doesn't work
			# i-1 is the previous point, with wrap around due to negative index,
			var A =  points[i-1]
			var B = points[i]
			# have to % i+1 to get the "next" point to wrap
			var C = points[(i+1)%points.size()]
			var cntrl1 = (A-B)*.1
			var cntrl2 = (C-B)*.1
			curve.add_point(B, cntrl1, cntrl2)

		totalNodes = path
	else:
		totalNodes = []
		curve.clear_points()
	setCurve(curve)
	queue_redraw()
	
func setCurve(curve):
	var curveObj = self.get_node("Path")
	curveObj.curve = curve
	
