extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent = get_parent()
	if abs(parent.rotation_degrees) <90:
		self.flip_v = true;
	else:
		self.flip_v = false;
	
	pass
