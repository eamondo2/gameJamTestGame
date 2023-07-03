@tool

extends ItemList

		
# Called when the node enters the scene tree for the first time.
func _ready():
	self.clear()
	for i in GlobalMenu.loadedLevels:
		self.add_item(i.levelName, i.icon, true);
	self.sort_items_by_text()


	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_activated(index):
	pass # Replace with function body.
	print(index)
	for loadedScene in GlobalMenu.loadedLevels:
		if loadedScene.levelName == self.get_item_text(index):
			GlobalMenu.swapToScene(loadedScene, true)
			break
