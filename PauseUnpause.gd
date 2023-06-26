extends Button

var controlledCouriers: Array[Courier];
var isPaused = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_tree().get_nodes_in_group('courier'):
		controlledCouriers.append(c);
	pass # Replace with function body.

func _toggled(button_pressed):
	self.isPaused = button_pressed
	if self.isPaused:
		self.text = "Unpause"
	else:
		self.text = "Pause"
	for c in self.controlledCouriers:
		c.should_pause = self.isPaused;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
