class_name math_funcs
extends Node

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
	
func isNearLineSegment(start: Vector2, end: Vector2, point: Vector2, distance: float):
	# To check if it's a line segment, check if it's in a bounding box nearby (maybe not perfect, doesn't really matter
	if point.x >= min(start.x, end.x)-distance and point.x <= max(start.x, end.x)+distance:
		if point.y >= min(start.y, end.y)-distance and point.y <= max(start.y, end.y)+distance:
			# Stole this equation from the internet
			# abs((end.x-start.x)*(start.y-point.y)-(start.x-point.x)*(end.y-start.y))/sqrt((end.x-start.x)**2+(end.y-start.y)**2)
			# also stole the more efficient version (This doesn't seem right? shouldn't y matter?)
			return  abs((end.x-start.x)*(start.y-point.y)-(start.x-point.x)*(end.y-start.y))**2 < ((end.x-start.x)**2+(end.y-start.y)**2)*distance**2
	return false

func weightedConnections(nodes: Array[Node], connections: Array[Array]):
	var weightedConnections = []
	var row = []
	row.resize(connections.size())
	row.fill(-1)
	weightedConnections.resize(connections.size())
	for i in range(weightedConnections.size()):
		weightedConnections[i] = row.duplicate()
	for i in range(connections.size()):
		weightedConnections.append([])
		for j in range(i):
			var length = (nodes[i].position - nodes[j].position).length()
			weightedConnections[i][j] = length
			weightedConnections[j][i] = length
	return weightedConnections

func findPath(nodes: Array[Node], weightedConnections: Array[Array], start: int, end: int):
	# TODO
	# Given a start index, and an end index, find shortest path using connections
	pass

# Above will find the shortest path, these instead finds the path with the least steps
# That is, the shortest path if all paths were the same length
func simplifyGraph(connections: Array[Array]):
	var simpleConnections = []
	simpleConnections.resize(connections.size())
	simpleConnections.fill([])
	for i in range(connections.size()):
		for j in range(i):
			if connections[i][j]:
				simpleConnections[i].append(j)
				simpleConnections[j].append(i)
	return simpleConnections

func simpleFindPath(nodes: Array[Intersection], simplifiedConnections: Array[Variant], start: int, end: int):
	var pathToNodes = []
	pathToNodes.resize(simplifiedConnections.size())
	pathToNodes.fill([])
	var currentNode = start
	var closestNode
	var closestDistance = INF
	while currentNode != end:
		for i in simplifiedConnections[currentNode]:
			var distance = (nodes[i].position-nodes[end].position).length()
			if distance < closestDistance:
				closestNode = i
				closestDistance = distance
			pathToNodes[i] = pathToNodes[currentNode] + [i]
		currentNode = closestNode
	return pathToNodes[end]
