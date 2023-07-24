class_name DropOff
extends Intersection

func _enter_tree():
	texture = load("res://addons/roadBuilder/bag.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _ready():
	if not Engine.is_editor_hint():
		show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
