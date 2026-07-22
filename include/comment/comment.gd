@tool
extends Label

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		return

	var scene_root = EditorInterface.get_edited_scene_root()
	
	if scene_root == self:
		return
	if scene_root == get_parent():
		return
	
	queue_free()
