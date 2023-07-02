extends HScrollBar


var controlledCouriers: Array[Courier];
var defaultValue = 1;


# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_tree().get_nodes_in_group('courier'):
		controlledCouriers.append(c);
	
	pass # Replace with function body.


func _on_scrolling():
	print(self.value)
	for c in self.controlledCouriers:
		c.control_speed_scale = self.value;
	pass # Replace with function body.
