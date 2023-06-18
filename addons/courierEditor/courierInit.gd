@tool
class_name CourierInit
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var courierScene = load("res://addons/courierEditor/courier.tscn")
	# TODO: Not sure about this 1, if problems,
	var courier = courierScene.instantiate(1)
	get_parent().add_child(courier)
	courier.owner = get_parent()
	self.queue_free()
