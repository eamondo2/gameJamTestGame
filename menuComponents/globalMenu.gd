@tool
extends Node


class LevelEntry:
	var icon: Texture2D
	var levelName: String
	var levelDir: String
	var scenePath: String
	var loadedPackedScene: PackedScene
	var isLoaded: bool
	var instantiatedUnloadedScene: Node


var loadedLevels: Array[LevelEntry] = []

var currentScene = null;

var mainMenuScene = null;

var currentSceneisMenu = true

var currentLevelEntry = null;

var currentLevelIndex;

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


func swapToScene(entry: LevelEntry, shouldResetScene = false):
	call_deferred("_deferredSwapToScene", entry, shouldResetScene)

func swapToMenu():
	call_deferred("_deferredSwapToMenu")

func _deferredSwapToMenu():

	currentLevelEntry.instantiatedUnloadedScene = currentScene
	
	get_tree().root.remove_child(currentScene)

	get_tree().root.add_child(mainMenuScene)


func _deferredSwapToScene(entry: LevelEntry, shouldResetScene: bool):
	#assuming we're at the menu
	get_tree().root.remove_child(mainMenuScene)

	currentLevelEntry = entry

	if !entry.isLoaded or shouldResetScene:
		print("instantiating")
		entry.loadedPackedScene = ResourceLoader.load(entry.scenePath)
		entry.isLoaded = true
		currentScene = entry.loadedPackedScene.instantiate()
	else:
		currentScene = entry.instantiatedUnloadedScene
	get_tree().root.add_child(currentScene)
	get_tree().current_scene = currentScene;

func _ready():
	print('ready call in globalMenu')
	var root = get_tree().root
	mainMenuScene = root.get_child(root.get_child_count() - 1)
	self.enumerateLevels()
