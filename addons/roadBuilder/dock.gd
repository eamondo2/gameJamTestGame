@tool
extends VBoxContainer

var plugin
var textBox

func _ready():
	self.textBox = find_child("Text Box")
