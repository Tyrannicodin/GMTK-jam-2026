extends TestScene

# This is an example test that starts the game scene

func get_scene() -> PackedScene:
	return load("res://game/game.tscn")

# This function will be run after your scene's _on_ready
func setup(_scene: Node):
	print("This is the setup function, put your setup code here.")
