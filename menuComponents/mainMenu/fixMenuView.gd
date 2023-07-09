extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_parent().size)
	print(self.get_viewport().size)
	print(self.zoom)
	self.zoom =  Vector2(1,1) / (Vector2(self.get_viewport().size) / Vector2(get_parent().size))
	print(self.zoom)
	print(self.get_viewport().size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
