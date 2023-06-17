@tool
class_name RoadMap
extends Node2D

@export_range(0, 500, 10) var defaultConnectionLength: float = 100
@export var roadColor: Color = Color.REBECCA_PURPLE

@export var nodes: Array[Intersection] = []
@export var connections: Array[Array] = []

const INTERACTION_DISTANCE = 10

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
			for j in range(i):
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
	addConnections(node)
	nodes.append(node)
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
					if segmentsIntersect(node1.position, node2.position, nodes[i].position, nodes[j].position):
						return false
		# If nothing intersected, allow it
		return true
	# If it wasn't within range, don't allow it
	return false
	
# This basically just uses some math I stole
func segmentsIntersect(start1: Vector2, end1: Vector2, start2: Vector2, end2: Vector2):
	var o1 = orientation(start1, end1, start2)
	var o2 = orientation(start1, end1, end2)
	var o3 = orientation(start2, end2, start1)
	var o4 = orientation(start2, end2, end1)
	
	if ((o1 != o2) and (o3 != o4)):
		return true
	
	if (o1 == 0) and onSegment(start1, end1, start2):
		return true
		
	if (o2 == 0) and onSegment(start1, end1, end2):
		return true
		
	if (o3 == 0) and onSegment(start2, end2, start1):
		return true
		
	if (o4 == 0) and onSegment(start2, end2, end1):
		return true
	
# More math I stole
func orientation(a: Vector2, b: Vector2, c: Vector2):
	var val = (b.y-a.y)*(c.x-b.x) - (b.x-a.x)*(c.y-b.y)
	if val > 0:
		return 1
	elif val < 0:
		return 2
	else:
		return 0

# Also math I stole. Only works for colinear points
func onSegment(start: Vector2, end: Vector2, point: Vector2):
	if point.x <= max(start.x, end.x) and (point.x >= min(start.x, end.x)):
		if (point.y <= max(start.y, end.y)) and (point.y >= min(start.y, end.y)):
			return true
	return false
	
func removeNode(node: Node):
	for i in range(nodes.size()):
		if nodes[i] == node:
			nodes[i].queue_free()
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
	for i in range(connections.size()):
		for j in range(i):
			if connections[i][j]:
				if isWithinDistanceFromLineSegment(nodes[i].position, nodes[j].position, position, INTERACTION_DISTANCE):
					connections[i][j] = false
					connections[j][i] = false
					queue_redraw()
					return true
	return false
func isWithinDistanceFromLineSegment(start: Vector2, end: Vector2, point: Vector2, distance: float):
	# To check if it's a line segment, check if it's in a bounding box nearby (maybe not perfect, doesn't really matter
	if point.x >= min(start.x, end.x)-distance and point.x <= max(start.x, end.x)+distance:
		if point.y >= min(start.y, end.y)-distance and point.y <= max(start.y, end.y)+distance:
			# Stole this equation from the internet
			# abs((end.x-start.x)*(start.y-point.y)-(start.x-point.x)*(end.y-start.y))/sqrt((end.x-start.x)**2+(end.y-start.y)**2)
			# also stole the more efficient version (This doesn't seem right? shouldn't y matter?)
			return  abs((end.x-start.x)*(start.y-point.y)-(start.x-point.x)*(end.y-start.y))**2 < ((end.x-start.x)**2+(end.y-start.y)**2)*distance**2
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
		
func selectNode(position: Vector2):
	for n in nodes:
		if (n.position - position).length() < INTERACTION_DISTANCE:
			return n
	return null
		
func moveNode(node: Intersection, position: Vector2):
	node.position = position
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
