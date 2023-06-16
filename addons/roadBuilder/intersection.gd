class_name Intersection
extends Sprite2D

func _enter_tree():
	texture = load("res://addons/roadBuilder/signpost.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
