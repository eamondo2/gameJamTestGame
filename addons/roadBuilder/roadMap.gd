@tool
class_name RoadMap
extends Node2D

@export_range(0, 500, 10) var defaultConnectionLength: float = 100;
@export var roadColor: Color = Color.REBECCA_PURPLE;

@export var nodes: Array[Intersection] = [];
@export var connections: Array[Array] = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	if Engine.is_editor_hint():
		for i in range(connections.size()):
			for j in range(connections[i].size()):
				if connections[i][j]:
					draw_line(nodes[i].position, nodes[j].position, roadColor)
					
func reset():
	for n in nodes:
		n.queue_free();
	nodes = []
	connections = []
	queue_redraw()

func addNode(position: Vector2):
	var node = Intersection.new()
	node.position = position
	add_child(node)
	node.owner = get_parent()
	addConnections(node, nodes.size())
	nodes.append(node)
	queue_redraw()

func addConnections(node: Intersection, index: int):
	var newConnections = []
	for i in range(nodes.size()):
		# Replace this with a smarter "should this be connected" check
		if (node.position - nodes[i].position).length() <= defaultConnectionLength:
			newConnections.append(true)
			connections[i].append(true)
		else:
			newConnections.append(false)
			connections[i].append(false)
	connections.append(newConnections)
	
func removeNode(node: Node):
	for i in range(nodes.size()):
		if nodes[i] == node:
			nodes.remove_at(i)
			removeConnections(i)
			break
	queue_redraw()

func removeConnections(index: int):
	connections.remove_at(index)
	for i in range(connections.size()):
		connections[i].remove_at(index)
	queue_redraw()
	
func attemptRemoveConnection(position: Vector2):
	# This should check through the list of connections, and see if this position is close to the line between, 
	# if so, remove it, queue redraw and return true. If none found, return false
	
	# queue_redraw()
	return false

func addNewConnection(node1: Intersection, node2: Intersection):
	var index1 = -1
	var index2 = -1
	for i in range(nodes.size()):
		if nodes[i] == node1:
			index1 = i
		if nodes[i] == node2:
			index2 = i
	if index1 >= 0 and index2 >= 0 and index1 != index2:
		connections[index1][index2] = true
		connections[index2][index1] = true
		queue_redraw()
	else:
		print('At least one of those nodes seems to not be part of this roadmap')
		
func selectNode(position: Vector2):
	for n in nodes:
		if (n.position - position).length() < 10:
			return n
	return null
		
func moveNode(node: Intersection, position: Vector2):
	node.position = position
	queue_redraw()
	
func switchType(node: Intersection):
	if typeof(node) == typeof(Dropoff):
		var newNode = Intersection.new()
		newNode.position = node.position
		node.replace_by(newNode)
	else:
		var newNode = Dropoff.new()
		newNode.position = node.position
		node.replace_by(newNode)
