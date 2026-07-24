extends Node2D

var rooms = [
	preload("res://resources/rooms/first_room.tres"),
	preload("res://resources/rooms/sample_room.tres"),
	preload("res://resources/rooms/platformer.tres"),
]

@onready var cameraNode = $Camera
@onready var player = $Player

var time = 60.0
var countdown = false

func _ready() -> void:
	print("Hello from game!")
	load_rooms()
	$Camera/BigText/Countdown/Label.text = "%.3f"%(time)

func load_rooms() -> void:
	var initial_pos: Vector2 = Vector2.ZERO
	var first_room = true

	for room in rooms:
		var room_scene: Node2D = room.scene.instantiate()

		var entry: Marker2D = room_scene.get_node("EntryMarker")
		var exit: Marker2D = room_scene.get_node("ExitMarker")
		var camera: Marker2D = room_scene.get_node("CameraMarker")
		if entry == null or exit == null or camera == null:
			continue

		add_child(room_scene)

		room_scene.object_entered.connect(func(node): object_entered_room(node, camera))
		room_scene.object_exited.connect(func(node): object_left_room(node, room_scene))

		room_scene.position = initial_pos - entry.position
		if first_room:
			room_scene.position = Vector2.ZERO
			player.position = entry.global_position
			first_room = false
		initial_pos = exit.global_position

func object_entered_room(object: Area2D, cameraTarget: Node2D):
	if object.get_parent() != player:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(
		cameraNode,
		"global_position",
		cameraTarget.global_position,
		0.5
	).set_trans(Tween.TRANS_CUBIC)
	tween.parallel(
	).tween_property(
		cameraNode.get_node("BigText"),
		"global_position",
		cameraTarget.global_position - Vector2(1280, 720),
		0.7
	).set_trans(Tween.TRANS_CUBIC)

func object_left_room(object: Area2D, room: Node2D):
	if object.get_parent() != player:
		return
	else:
		countdown = true

	#room.lock()

func _physics_process(delta: float) -> void:
	if countdown:
		time -= delta
		$Camera/BigText/Countdown/Label.text = "%.3f"%(time)
	
	if time <= 0:
		pass # Game Over
