@tool
class_name Courier
extends Path2D

@export var sprite: Texture2D:
	set(value):
		var spriteNode: Sprite2D = self.get_node("spriteFollow/personSprite");
		spriteNode.texture = value;
		sprite = value;
		#notify_property_list_changed()
	
@export_range(0, 1, .01) var progress_ratio: float:
	set(value):
		progress_ratio = value;
		self.get_node("spriteFollow").progress_ratio = value;
		#notify_property_list_changed()

@export_color_no_alpha var nodeColor: Color = Color.RED

@export var speedScale = 1;

var needsInstantiate = true
var roadmap: RoadMap
var requiredNodes: Array[Intersection] = []
var totalNodes: Array[Intersection] = []

const PATH_WIGGLE = 0

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	self.add_to_group('courier', true)
	self.roadmap = get_tree().get_first_node_in_group('roadmap')
	
	#move self to child of roadmap
	if self.get_parent() != self.roadmap and self.get_parent() != null and self.roadmap != null:
		get_parent().remove_child(self)
		self.roadmap.add_child(self)
		
	# var courierScene = preload("res://addons/courierEditor/courier.tscn")
	# var courier = courierScene.instantiate()
	# courier.needsInstantiate = false
	# self.roadmap.add_child.call_deferred(courier)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	print("readycallback")
	self.progress_ratio = self.progress_ratio;

func _process(delta):
	if !Engine.is_editor_hint():
		self.progress_ratio += speedScale * 0.05 * delta;

func _draw():
	if Engine.is_editor_hint():
		for n in requiredNodes:
			draw_circle(n.position, 10, nodeColor)

func addNode(node: Intersection):
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
	if requiredNodes.size() > 0:
		var path: Array[Intersection] = []
		var previousNode
		for n in requiredNodes:
			if previousNode != null:
				# This will return a list of nodes, exclusive on the first step, inclusive on the last
				path.append_array(roadmap.findPath(previousNode, n))
			else:
				path.append(n)
			previousNode = n
		# Connect end to start
		path.append_array(roadmap.findPath(requiredNodes[-1], requiredNodes[0]))
		self.curve.clear_points()
		for n in path:
			self.curve.add_point(self.roadmap.to_local(n.position+Vector2(PATH_WIGGLE*randf(), PATH_WIGGLE*randf())))
			
		totalNodes = path
	else:
		totalNodes = []
		self.curve.clear_points()
	queue_redraw()
