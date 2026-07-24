class_name Player
extends CharacterBody2D


@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var input_history: Array = []
var time_since_last_action = 0

var jutsu_time_frame = .1
var tick = 0

var facing_direction
# While the player is dashing, we dont want their velocity to be affected
# by movement keys or gravity
var lock_velocity = 0

const SPEED = 2000.0
const JUMP_VELOCITY = -2400.0

func _ready():
	await get_tree().physics_frame
	get_tree().call_group("knows_player", "set_player", self)

func add_rewards(rewards: Reward) -> void:
	print("Gained rewards ", rewards.time, "s ", rewards.xp)

func deal_damage(amount: int):
	print("Ow! Took ", amount, " damage!")

func _physics_process(delta):
	tick += delta

	var input_history_index = 0
	while input_history_index < len(input_history):
		var input = input_history[input_history_index]
		
		if tick - input[1] > jutsu_time_frame:
			input_history.pop_at(input_history_index)
		else:
			input_history_index += 1

	# Add the gravity.
	if lock_velocity <= 0:
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	lock_velocity -= delta
		
	if velocity.x > 0:
		facing_direction = "right"
	if velocity.x < 0:
		facing_direction = "left"

	# Handle interactions.
	if Input.is_action_just_pressed("interact"):
		for area in detector.get_overlapping_areas():
			var parent = area.get_parent()
			if parent.get("rewards"):
				add_rewards(parent.get("rewards"))
				parent.queue_free()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Jutsu
	time_since_last_action += delta
	# Make sure that the keys are pressed at the same time
	if time_since_last_action > jutsu_time_frame:
		input_history = []

	# Handle Input History
	if Input.is_action_just_pressed("special"):
		time_since_last_action = 0
		input_history.push_back(["special", tick])
	if Input.is_action_just_pressed("up"):
		time_since_last_action = 0
		input_history.push_back(["up", tick])
	if Input.is_action_just_pressed("down"):
		time_since_last_action = 0
		input_history.push_back(["down", tick])
	if Input.is_action_just_pressed("left"):
		time_since_last_action = 0
		input_history.push_back(["side", tick])
	if Input.is_action_just_pressed("right"):
		time_since_last_action = 0
		input_history.push_back(["side", tick])

	execute_jutsu()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if lock_velocity <= 0:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = max(velocity.x, SPEED) * direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func input_history_includes_key(key):
	for ih in input_history:
		if ih[0] == key and tick - ih[1] < jutsu_time_frame:
			return true
	return false
	
func execute_jutsu():
	if not input_history_includes_key("special"):
		return
	
	if input_history_includes_key("up"):
		spring_jump_jutsu()
		input_history.clear()

	if input_history_includes_key("side"):
		sword_charge_jutsu()
		input_history.clear()

func spring_jump_jutsu():
	print("spring jump!")
	velocity.y -= 5000

func sword_charge_jutsu():
	if facing_direction == "right":
		velocity.x += 4000
	else:
		velocity.x -= 4000
	lock_velocity = .1
