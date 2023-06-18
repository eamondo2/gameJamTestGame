class_name DropOff
extends Intersection

func _enter_tree():
	texture = load("res://addons/roadBuilder/bag.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
