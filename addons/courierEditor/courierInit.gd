@tool
extends Node2D

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	var courierScene = preload("res://addons/courierEditor/courier.tscn")
	var courier = courierScene.instantiate()
	self.replace_by(courier)

