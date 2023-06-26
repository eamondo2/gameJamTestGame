@tool
class_name Package
extends Node2D

var carriedBy
var targetLocation

var markerSprite: Sprite2D;

@export var texture: Texture2D:
	set(value):
		if !self.markerSprite:
			print('markerSprite uninitialized')
			self.markerSprite = Sprite2D.new()
			self.markerSprite.texture = value;
			self.add_child(self.markerSprite);
		else:
			print('markerSprite valid')
			self.markerSprite.texture = value;
		texture = value

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group('packages')



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	pass

func setPosition(position: Vector2):
	self.position = position;
	# Also do any checks like "are we in the target zone" or whatever
