@tool
extends Path2D

@export var sprite: Texture2D:
	set(value):
		print("TEST");
		var spriteNode: Sprite2D = get_node("spriteFollow/personSprite");
		spriteNode.texture = value;
		sprite = value;
		#notify_property_list_changed()
	
@export_range(0, 1, .01) var progress_ratio: float:
	set(value):
		progress_ratio = value;
		get_node("spriteFollow").progress_ratio = value;
		#notify_property_list_changed()

@export var speedScale = 1;


@export var pointList: Array[Dropoff] = [];
		

func _run():
	print("EditorfnRun");
	

# Called when the node enters the scene tree for the first time.
func _ready():
	print("readycallback")
	self.progress_ratio = self.progress_ratio;
	pass # Replace with function body.

func _process(delta):
	if !Engine.is_editor_hint():
		self.progress_ratio += speedScale * 0.05 * delta;
	else:
		self.curve.clear_points()
		self.curve.add_point(Vector2(0,0))
		for d in self.pointList:
			self.curve.add_point(d.position - self.position)
		self.curve.add_point(Vector2.ZERO)
	pass



func _on_person_sprite_texture_changed():
	print("TEST, but event this time");
	pass # Replace with function body.