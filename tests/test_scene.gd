class_name TestScene

extends SceneTree

# This is a class that lets us test a setup a scene how we
# please, and test it from the command line.
# Example: godot -s tests/start_game.gd

# Overide 
func get_scene() -> PackedScene:
	return null

# This method can be overridden to do whatever you need.
# It will be run AFTER the scene's _on_ready function.
func setup(scene: Node):
	print("Override this method to setup your test!")

# Do not touch!
# This starts up the scene we are testing and runs our setup function.
func _init() -> void:
	var scene = get_scene()
	change_scene_to_packed(scene)
	setup(root)
