@tool
class_name CourierInit
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var courierScene = load("res://addons/courierEditor/courier.tscn")
	# TODO: Not sure about this 1, if problems,
	var courier = courierScene.instantiate(0)
	get_parent().add_child(courier)
	courier.owner = get_parent()
	get_parent().set_editable_instance(courier, true)
	
	self.queue_free()
