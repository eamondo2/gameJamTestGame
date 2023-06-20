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

func weightConnections(nodes: Array, connections: Array[Variant]):
	var weightedConnections = []
	var row = []
	row.resize(connections.size())
	row.fill(INF)
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

func findPath(nodes: Array, weightedConnections: Array[Variant], start: int, end: int):
	return A_Star(start, end, weightedConnections, nodes)

func reconstruct_path(cameFrom: Array, current: int):
	var total_path = [current]
	while cameFrom[current] != -1:
		current = cameFrom[current]
		total_path.push_front(current)
	return total_path

func heuristic(node: Node, goal: Node):
	return (goal.position-node.position).length()

# A* finds a path from start to goal.
# h is the heuristic function. h(n) estimates the cost to reach goal from node n.
func A_Star(start: int, goal: int, weightedConnections: Array[Variant], nodes: Array):
#    // The set of discovered nodes that may need to be (re-)expanded.
#    // Initially, only the start node is known.
#    // This is usually implemented as a min-heap or priority queue rather than a hash-set.
	var openSet = [start]

#    // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
#    // to n currently known.
	var cameFrom: Array = []
	cameFrom.resize(nodes.size())
	cameFrom.fill(-1)
#
#    // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
	var gScore: Array = []
	gScore.resize(nodes.size())
	gScore.fill(INF)
	gScore[start] = 0
#
#    // For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
#    // how cheap a path could be from start to finish if it goes through n.
	var fScore: Array = []
	fScore.resize(nodes.size())
	fScore.fill(INF)
	fScore[start] = heuristic(nodes[start], nodes[goal])
#
	while openSet.size() > 0:
#        // This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
		var current = 0 # = the node in openSet having the lowest fScore[] value
		for i in range(fScore.size()):
			if fScore[i] < fScore[current]:
				current = i
		if current == goal:
			return reconstruct_path(cameFrom, current)

		openSet.erase(current)
		for i in range(weightedConnections[current].size()): # each neighbor of current
#            // d(current,neighbor) is the weight of the edge from current to neighbor
#            // tentative_gScore is the distance from start to the neighbor through current
			var tentative_gScore = gScore[current] + weightedConnections[current][i] # d(current, neighbor)
			if tentative_gScore < gScore[i]:
#                // This path to neighbor is better than any previous one. Record it!
				cameFrom[i] = current
				gScore[i] = tentative_gScore
				fScore[i] = tentative_gScore + heuristic(nodes[i], nodes[goal])
				if openSet.find(i) == -1:
					openSet.append(i)
#
#    // Open set is empty but goal was never reached
	return []
