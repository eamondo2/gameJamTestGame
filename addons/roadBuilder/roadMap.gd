@tool
class_name RoadMap
extends Node2D

@export_range(0, 500, 10) var defaultConnectionLength: float = 100
@export var roadColor: Color = Color.REBECCA_PURPLE

@export var nodes: Array[Intersection] = []
@export var connections: Array[Array] = []
var math
var changed = false
var simpleConnections: Array[Variant] = []

const INTERACTION_DISTANCE = 10

func _enter_tree():
	if get_tree().has_group("roadmap"):
		if get_tree().get_nodes_in_group('roadmap').any(func(v): return v != self):
			print('Please only use 1 roadmap per scene')
			self.queue_free()
	self.add_to_group('roadmap', true)

# Called when the node enters the scene tree for the first time.
func _ready():
	math = math_funcs.new()
	set_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	if Engine.is_editor_hint():
		for i in range(connections.size()):
			for j in range(i):
				if connections[i][j]:
					draw_line(nodes[i].position, nodes[j].position, roadColor)
					
func reset():
	for n in nodes:
		n.queue_free();
	nodes = []
	connections = []
	changed = true
	queue_redraw()

func addNode(position: Vector2):
	var node = Intersection.new()
	node.position = position
	add_child(node)
	node.owner = get_parent()
	addConnections(node)
	nodes.append(node)
	changed = true
	queue_redraw()

func addConnections(node: Intersection):
	var newConnections = []
	for i in range(nodes.size()):
		if shouldAddConnection(node, nodes[i]):
			newConnections.append(true)
			connections[i].append(true)
		else:
			newConnections.append(false)
			connections[i].append(false)
	# index for itself
	newConnections.append(false)
	connections.append(newConnections)
	
func shouldAddConnection(node1: Intersection, node2: Intersection):
	# If it's within the normal default range
	if (node1.position - node2.position).length() <= defaultConnectionLength:
		# For every connection O(n^2)
		for i in range(connections.size()):
			# We don't care if the segments connect end to end like this
			if nodes[i] == node1 or nodes[i] == node2:
				continue
			for j in range(i):
				# Or here either
				if nodes[j] == node1 or nodes[j] == node2:
					continue
				# If it is a connection
				if connections[i][j]:
					# If it would intersect with this new connection, do not allow the new connection
					if math.segmentsIntersect(node1.position, node2.position, nodes[i].position, nodes[j].position):
						return false
		# If nothing intersected, allow it
		return true
	# If it wasn't within range, don't allow it
	return false
	
func removeNode(node: Node):
	for i in range(nodes.size()):
		if nodes[i] == node:
			nodes[i].queue_free()
			nodes.remove_at(i)
			removeConnections(i)
			break
	changed = true
	queue_redraw()

func removeConnections(index: int):
	connections.remove_at(index)
	for i in range(connections.size()):
		connections[i].remove_at(index)
	changed = true
	queue_redraw()
	
func attemptRemoveConnection(position: Vector2):
	# This should check through the list of connections, and see if this position is close to the line between, 
	# if so, remove it, queue redraw and return true. If none found, return false
	for i in range(connections.size()):
		for j in range(i):
			if connections[i][j]:
				if math.isNearLineSegment(nodes[i].position, nodes[j].position, position, INTERACTION_DISTANCE):
					connections[i][j] = false
					connections[j][i] = false
					changed = true
					queue_redraw()
					return true
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
		changed = true
		queue_redraw()
		
func selectNode(position: Vector2):
	for n in nodes:
		if (n.position - position).length() < INTERACTION_DISTANCE:
			return n
	return null
		
func moveNode(node: Intersection, position: Vector2):
	node.position = position
	changed = true
	queue_redraw()
	
func switchType(node: Intersection):
	var newNode
	if node is DropOff:
		newNode = Intersection.new()
	else:
		newNode = DropOff.new()
	newNode.position = node.position
	for i in range(nodes.size()):
		if nodes[i] == node:
			nodes[i] = newNode
	node.replace_by(newNode)
	
# This will return a list of nodes, exclusive on the first step, inclusive on the last
func findPath(node1: Intersection, node2: Intersection):
	
	if changed:
		
		simpleConnections = math.simplifyGraph(connections)
		changed = false
	var index1 = -1
	var index2 = -1
	for i in range(nodes.size()):
		if nodes[i] == node1:
			index1 = i
		if nodes[i] == node2:
			index2 = i
	if index1 >= 0 and index2 >= 0 and index1 != index2:
		var path = math.simpleFindPath(nodes, simpleConnections, index1, index2)
		return path.map(func(index: int): return nodes[index])
	return []
