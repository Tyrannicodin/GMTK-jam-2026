extends Node2D

var rooms = [
	preload("res://resources/rooms/sample_room.tres"),
	preload("res://resources/rooms/simple_platform.tres"),
]

func _ready() -> void:
	print("Hello from game!")
	load_rooms()

func load_rooms() -> void:
	var initial_pos: Vector2 = Vector2.ZERO

	for room in rooms:
		var room_scene: Node2D = room.scene.instantiate()

		var entry: Marker2D = room_scene.get_node("EntryMarker")
		var exit: Marker2D = room_scene.get_node("ExitMarker")
		if entry == null or exit == null:
			continue

		add_child(room_scene)

		room_scene.position = initial_pos - entry.position
		initial_pos += exit.position
