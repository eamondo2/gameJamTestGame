@tool
class_name Package
extends Node2D

var carriedBy
@export var targetLocation: DropOff

var markerSprite: Sprite2D;

const REQUIRED_DISTANCE = 20

var delivered = false
var active = true
var homeNode: Intersection

@export var texture: Texture2D:
	set(value):
		if !self.markerSprite:
			self.markerSprite = Sprite2D.new()
			self.markerSprite.texture = value;
			self.add_child(self.markerSprite);
		else:
			self.markerSprite.texture = value;
		texture = value

# Package will spawn after this many seconds
@export_range(0, 100, 1) var spawnTime: float = 0
var spawnTimer = 0
# Package timer will not start until this package has been delivered
@export var prereqPackage: Package

# Magnetic packages cannot be too far from their pair
@export var magnetic: bool = false:
	set(value):
		magnetic = value
		if value:
			if !pairedPackage:
				if !savedPairedPackage:
					pairedPackage = Package.new()
					add_sibling(pairedPackage, true)
					pairedPackage.name = name+"Pair"
					pairedPackage.owner = get_parent()
					pairedPackage.position = position
				else:
					pairedPackage = savedPairedPackage
			pairedPackage.pairedPackage = self
			if !pairedPackage.magnetic:
				pairedPackage.magnetic = true
			pairedPackage.magneticRange = magneticRange
		elif pairedPackage and pairedPackage.magnetic:
			pairedPackage.magnetic = false
			if !radioactive:
				pairedPackage = null
			

var magneticRange: int = 100:
	set(value):
		magneticRange = value
		if pairedPackage and pairedPackage.magneticRange != magneticRange:
			pairedPackage.magneticRange = magneticRange
			
const MAGNET_THICKNESS = 5

# Radioactive packages cannot be too close to their pair
@export var radioactive: bool = false:
	set(value):
		radioactive = value
		if value:
			if !pairedPackage:
				if !savedPairedPackage:
					pairedPackage = Package.new()
					add_sibling(pairedPackage, true)
					pairedPackage.name = name+"Pair"
					pairedPackage.owner = get_parent()
					pairedPackage.position = position
				else:
					pairedPackage = savedPairedPackage
			pairedPackage.pairedPackage = self
			if !pairedPackage.radioactive:
				pairedPackage.radioactive = true
			pairedPackage.radiationRange = radiationRange
		elif pairedPackage and pairedPackage.radioactive:
			pairedPackage.radioactive = false
			if !magnetic:
				pairedPackage = null
		
var radiationRange: int = 100:
	set(value):
		radiationRange = value
		if pairedPackage and pairedPackage.radiationRange != radiationRange:
			pairedPackage.radiationRange = radiationRange

@export var pairedPackage: Package:
	set(value):
		pairedPackage = value
		if (value != null):
			savedPairedPackage = value
			add_sibling(savedPairedPackage, true)
			savedPairedPackage.owner = get_parent()
		else:
			get_parent().remove_child(savedPairedPackage)
			savedPairedPackage.owner = null
			savedPairedPackage.queue_free()
# This gets saved, in case one of the settings with a pair is turned off on accident.
# It's not exported, since it doesn't need to be saved through reloads
var savedPairedPackage: Package

func _get_property_list():
	var properties = []
	properties.append({
		"name": "magneticRange",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT if magnetic else PROPERTY_USAGE_NO_EDITOR,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1000,10,or_greater"
	})
	properties.append({
		"name": "radiationRange",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT if radioactive else PROPERTY_USAGE_NO_EDITOR, 
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1000,10,or_greater"
	})
	properties.append({
		"name": "homeNode",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_NO_EDITOR, 
	})
	return properties
		
func _set(property, value):
	if property == 'position':
		if !Engine.is_editor_hint():
			position = value
			if targetLocation and position.distance_to(targetLocation.position) < REQUIRED_DISTANCE:
				deliver()
			if pairedPackage:
				var distance = position.distance_to(pairedPackage.position)
				if magnetic and distance > magneticRange:
					pairedPackage.destroy()
					destroy()
				if radioactive and distance < radiationRange:
					pairedPackage.destroy()
					destroy()
		else:
			# This doesn't trigger on dragging it around, we'll have to use a plugin for it
			position = value
		return true
	return false
	
#func _get_property_list():
	
func transparencyFunction(x):
	const c = .95
	const a = 1.84
	const k = 20
	const e = 2.71828
	const b = pow(e, -k)
	return c/(1+a*pow(b, x-.6))+(1-c)

func _draw():
	if targetLocation:
		draw_circle(targetLocation.global_position-position, 10, Color.GREEN)
	if pairedPackage and pairedPackage.active:
		var distance = position.distance_to(pairedPackage.position)
		if magnetic:
			var transparency = transparencyFunction(distance/magneticRange)
			var thickness = MAGNET_THICKNESS*(1-transparency)
			draw_line(Vector2.ZERO, pairedPackage.position-position, Color(0, 0, 1, transparency), thickness)
		if radioactive:
			var angle = Vector2.LEFT.angle_to(position-pairedPackage.position)
			var transparency = transparencyFunction(radiationRange/distance)
			# Render at half range, so that the curves overlap at the correct distance
			draw_arc(Vector2.ZERO, radiationRange/2, angle - PI/16, angle + PI/16, 10,  Color(0, 1, 0, transparency), 3)
		


# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.is_editor_hint():
		deactivate()
		spawnTimer=0
	queue_redraw()

func _enter_tree():
	if Engine.is_editor_hint():
		savedPairedPackage = pairedPackage
		activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if !Engine.is_editor_hint():
		if !prereqPackage or (prereqPackage and prereqPackage.delivered):
			if spawnTimer >= 0:
				spawnTimer += delta
				if spawnTimer >= spawnTime:
					activate()
					spawnTimer = -1
	
func activate():
	print('activating')
	add_to_group('packages', true)
	active = true
	show()
	
func deactivate():
	print('deactivating')
	remove_from_group('packages')
	active = false
	hide()
	
func deliver():
	# TODO: this should talk to whatever level manager to mark as delivered
	# Plus whatever other indicators (animations, etc.)
	print('Success!!')
	delivered = true
	deactivate()
	
func destroy():
	# TODO: this should talk to whatever level manager to mark as failed
	# Plus whatever other indicators (animations, etc.)
	print('Failure!!')
	if carriedBy:
		# Force self to drop
		carriedBy.dropTarget = null
		carriedBy.package = null
		carriedBy = null
	var audio = get_tree().get_first_node_in_group('audio')
	audio.stream = preload("res://assets/explosion.wav")
	audio.play()
	position = homeNode.position
