extends PathFollow2D

@export var speedScale = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.progress_ratio += speedScale * 0.05 * delta;
	pass
