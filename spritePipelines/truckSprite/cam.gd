@tool
extends Camera3D

@export var postProcess = true :	
	set(p):
		if p:
			$Postprocess.show()
			postProcess = p
			var a = Vector3(-1, 1, 0).normalized()
			var b = Vector3(1, 0, 0).normalized()
			print("dot: ", a.dot(b))
		else:
			$Postprocess.hide()
			postProcess = p
