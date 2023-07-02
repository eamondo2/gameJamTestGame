extends GPUParticles2D

var frameSkip = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parentSprite = get_parent()
	var invert_extend_vec = (parentSprite.extend_vec * -1)	
	var translateToParent = get_parent().position.direction_to(position) * -1
	var distToParent = get_parent().position.distance_to(position)
	var desiredTranslatePosition = translateToParent * distToParent
	translate(desiredTranslatePosition + get_parent().position.direction_to(position).normalized() + invert_extend_vec * 1.25)
	var controlNode = get_tree().get_current_scene().get_node('ControlSet')
	if controlNode.get_node("VBoxContainer/HScrollBar"):
		self.speed_scale = controlNode.get_node("VBoxContainer/HScrollBar").value
