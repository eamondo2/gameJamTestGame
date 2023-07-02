@tool
extends Sprite2D

var truckModel;
var postProcObject;
var lastPos: Vector2;
var currentPos: Vector2;
var extend_vec: Vector2;

var controlNode;

var angle_to = 0;

var lastTick = 0

@export var modelTint: Color = Color.RED:
	set(val):
		modelTint = val;
@export_range(0, 1, 0.1) var modelTintFactor:
	set(val):
		modelTintFactor = val;
		

# Called when the node enters the scene tree for the first time.
func _ready():
	truckModel = get_node("SubViewport/testTruck")
	postProcObject = get_node("SubViewport/Camera3D/Postprocess")
	if !Engine.is_editor_hint():
		controlNode = get_tree().get_current_scene().get_node('ControlSet')
	pass # Replace with function body.

func _draw():
#	if !Engine.is_editor_hint():
		draw_line(position, position + (extend_vec), Color.RED, 2);
		draw_arc(position, 20, 0, deg_to_rad(-1 * angle_to), 20, Color.YELLOW, 2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if postProcObject:
		postProcObject.get_surface_override_material(0).set_shader_parameter("tint_color", modelTint)
		postProcObject.get_surface_override_material(0).set_shader_parameter("tint_effect_factor", modelTintFactor)
	if !Engine.is_editor_hint():
		if controlNode.get_node('VBoxContainer/PauseUnpause') and controlNode.get_node("VBoxContainer/PauseUnpause").isPaused:
			return
		if controlNode.get_node("VBoxContainer/HScrollBar") and controlNode.get_node("VBoxContainer/HScrollBar").value <= 0.01:
			return
	
	if get_tree().get_current_scene():
		if !currentPos:
			currentPos = get_parent().position

		lastPos = currentPos;
		currentPos = get_parent().global_position
		extend_vec = lastPos.direction_to(currentPos) * 20
		angle_to = rad_to_deg(-1 * get_parent().global_position.angle_to_point(currentPos + extend_vec))
		
		truckModel.global_rotation_degrees.y = angle_to

	
	queue_redraw()
