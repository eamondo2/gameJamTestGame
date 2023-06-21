class_name Package
extends Node2D

var carriedBy

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group('packages')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setPosition(position: Vector2):
	self.position = position
	# Also do any checks like "are we in the target zone" or whatever
