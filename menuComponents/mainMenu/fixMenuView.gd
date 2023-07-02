extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_parent().size)
	print(self.get_viewport().size)
	print(self.zoom)
	self.zoom = Vector2i(get_parent().size) / Vector2i(self.get_viewport().size) * 2
	print(self.zoom)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
