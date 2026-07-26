extends Node2D

signal round_start
signal hide_unlocks

const FIRST_ROOM = preload("res://resources/rooms/first_room.tres")
const LAST_ROOM = preload("res://resources/rooms/last_room.tres")

var rooms = [FIRST_ROOM]

var possible_rooms: Array[RoomResource] = []
var possible_unlocks: Array[UnlockResource] = []

@onready var cameraNode = $Camera
@onready var player = $Player
@onready var roomContainer = $Rooms

var time: float = 60.0
var time_before_taking_damage: float = 60.0
var time_since_taking_damage: float = 0.0
var game_paused_for_damage_frames: bool = false

var countdown := false

var PAUSE_FOR_S_WHEN_TAKING_DAMAGE = .2

var rng = RandomNumberGenerator.new()

func play_ambience():
	%Ambience.play()
	await get_tree().create_timer(%Ambience.stream.get_length()).timeout
	play_ambience()
	
func play_bgm():
	%Bgm.play()
	await get_tree().create_timer(%Bgm.stream.get_length()).timeout
	play_bgm()
	
func _ready() -> void:
	print("Hello from game!")
	load_resources()
	set_time(time, 0)
	
	play_ambience()
	play_bgm()

	pick_room(0)
	build_rooms()
	round_start.emit()

func pick_room(at: int):
	var chances = possible_rooms.map(
		func(room: RoomResource): return (room.probability.sample(max(at / 25.0, 1)) if room.probability else 1.) * room.max_probability
	)
	rooms.push_back(possible_rooms[rng.rand_weighted(chances)])

func load_resources():
	for file in DirAccess.open("res://resources/rooms").get_files():
		possible_rooms.push_back(load("res://resources/rooms/%s" % file))
	for file in DirAccess.open("res://resources/unlocks").get_files():
		possible_unlocks.push_back(load("res://resources/unlocks/%s" % file))

func build_rooms() -> void:
	for child in roomContainer.get_children():
		child.queue_free()

	var unlocks = roll_unlocks()

	var initial_pos: Vector2 = Vector2.ZERO
	var first_room = true
	var index = 0

	for room in rooms + [LAST_ROOM]:
		var room_scene: Node2D = room.scene.instantiate()
		#room_scene.done.connect(_finished_stage)

		var entry: Marker2D = room_scene.get_node("EntryMarker")
		var exit: Marker2D = room_scene.get_node("ExitMarker")
		var camera: Marker2D = room_scene.get_node("CameraMarker")
		if entry == null or exit == null or camera == null:
			continue

		room_scene.object_entered.connect(func(node): object_entered_room(node, room_scene, index))
		room_scene.object_exited.connect(func(node): object_left_room(node, room_scene, index))
		round_start.connect(room_scene.round_started)

		room_scene.position = initial_pos - entry.position
		if first_room:
			room_scene.position = Vector2.ZERO
			player.position = entry.global_position
			player.reset_physics_interpolation()
			first_room = false
			
			room_scene.set_unlocks(unlocks, hide_unlocks)
			if len(unlocks) == 0:
				room_scene.call_deferred("unlock")
			room_scene.run = len(rooms) - 1
		elif room_scene.get("run_over"):
			room_scene.run_over.connect(_finished_stage)
			if len(rooms) - 1 == 20:
				room_scene.last_run = true
		initial_pos = exit.global_position
		
		roomContainer.add_child(room_scene)

		index += 1
	
	player.broadcast_player()

func set_time(time: float, delta: float):
	var s = str(float(time)).split(".")

	if game_paused_for_damage_frames:
		var t = time_before_taking_damage - (time_before_taking_damage - time) * (time_since_taking_damage / PAUSE_FOR_S_WHEN_TAKING_DAMAGE) 
		s = str(float(t)).split(".")

	if s[0].length() > 1:
		$Camera/BigText/Countdown/Character1.text = s[0][0]
		$Camera/BigText/Countdown/Character2.text = s[0][1]
	else:
		$Camera/BigText/Countdown/Character2.text = s[0][0]
		$Camera/BigText/Countdown/Character1.text = "0"

	$Camera/BigText/Countdown/Character3.text = s[1][0]
	
func _finished_stage():
	if len(rooms) - 1 == 20:
		%Win.show()
		return
	pick_room(len(rooms) - 1)
	build_rooms()
	time = 60

func object_entered_room(object: Area2D, room: Node2D, index: int):
	if object.get_parent() != player:
		return
	
	room.unlock()

	if index == len(rooms):
		countdown = false
		var reward = Reward.new()
		reward.xp = time / 10.0
	elif index != 0:
		countdown = true
	
	var cameraTarget = room.get_node("CameraMarker")
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

func object_left_room(object: Area2D, room: Node2D, index: int):
	if object.get_parent() != player or index == len(rooms) or index == 0 or not countdown:
		return
	
	var reward = Reward.new()
	reward.time = 3
	$Player.add_rewards(reward)

	room.lock()

func _process(delta: float) -> void:
	%StaminaBar.value = %Player.stamina
	%XpBar.value = %Player.xp
	%PlayerLevel.text = "LV%s" % %Player.level
	
func _physics_process(delta: float) -> void:
	time_since_taking_damage += delta
	set_time(time, delta)

	if countdown:
		time -= delta
	
	if time <= 0:
		countdown = false
		time = 0
		%Lose.show()

func on_player_damage(amount: int):
	time_since_taking_damage = 0
	time_before_taking_damage = time
	time -= amount
	
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	$Rooms.process_mode = Node.PROCESS_MODE_DISABLED

	game_paused_for_damage_frames = true

	await get_tree().create_timer(PAUSE_FOR_S_WHEN_TAKING_DAMAGE).timeout

	game_paused_for_damage_frames = false

	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	$Rooms.process_mode = Node.PROCESS_MODE_INHERIT

	%Camera.apply_shake(1)

func on_gain_time(amount: float) -> void:
	time += amount

func player_level_up(_lvl: int) -> void:
	%XpBar.max_value = %Player.threshold
	%StaminaBar.max_value = %Player.MAX_STAMINA

func roll_unlocks() -> Array[UnlockResource]:
	var probs = possible_unlocks.map(func(value: UnlockResource): return value.probability)
	var selections = []
	while len(selections) < 2 and len(selections) != len(possible_unlocks):
		var selected = rng.rand_weighted(probs)
		if selected in selections:
			continue
		selections.push_back(selected)
	return selections.map(func(value: int): return possible_unlocks[value])

func unlock_chosen(unlock: UnlockResource) -> void:
	possible_unlocks.remove_at(possible_unlocks.find(unlock))
	if get(unlock.id) != null:
		set(unlock.id, true)
	elif %Player.get(unlock.id) != null:
		%Player.set(unlock.id, true)
	else:
		print(unlock.id)
		%Player.unlocked_weapons.push_back(unlock.id)
	hide_unlocks.emit()
	roomContainer.get_child(0).call("unlock")

func endless_mode() -> void:
	time = 60
	pick_room(len(rooms) - 1)
	build_rooms()

func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")

func try_again() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")
