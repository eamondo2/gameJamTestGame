@tool

extends ItemList

class LevelEntry:
	var icon: Texture2D
	var levelName: String
	var levelDir: String
	var scenePath: String


var loadedLevels: Array[LevelEntry] = [];


func enumerateLevels():
	var dir = DirAccess.open("res://levels");
	var levelDirsToLoad = [];
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if dir.current_is_dir():
				print("Found dir " + fname)
				levelDirsToLoad.append(fname)
			else:
				print("Found file " + fname)
			fname = dir.get_next()
	else:
		print("no path access")
	
	for levelDir in levelDirsToLoad:
		print("loading " + levelDir);
		var sceneDetails = FileAccess.open("res://levels/" + levelDir + "/" + levelDir + ".txt", FileAccess.READ).get_as_text()
		if self.loadedLevels.any(func(v): v.levelName == sceneDetails.split("\n")[0]):
			continue
		var entryObject = LevelEntry.new();
		entryObject.levelDir = "res://levels/" + levelDir;
		entryObject.scenePath = "res://levels/" + levelDir + "/" + levelDir + ".tscn"
		entryObject.icon = ResourceLoader.load("res://levels/" + levelDir + "/" + levelDir + ".svg");
		entryObject.levelName = sceneDetails.split("\n")[0];
		loadedLevels.append(entryObject);
		
	print(loadedLevels)

		
# Called when the node enters the scene tree for the first time.
func _ready():
	self.clear()
	self.enumerateLevels()
	for i in self.loadedLevels:
		self.add_item(i.levelName, i.icon, true);
	self.sort_items_by_text()


	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_activated(index):
	pass # Replace with function body.
	print(index)
	for loadedScene in self.loadedLevels:
		if loadedScene.levelName == self.get_item_text(index):
			var pScene = ResourceLoader.load(loadedScene.scenePath);
			get_tree().change_scene_to_packed(pScene);
			break
