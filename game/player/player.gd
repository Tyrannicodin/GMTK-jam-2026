class_name Player
extends CharacterBody2D


@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var direction_history: Array = []
var jutsu_storage # Stores casted jutsu when special is held.
var time_since_last_action = 0

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
	# Max time between each input for a jutsu is .3s
	if time_since_last_action > .3:
		direction_history = []
	
	if Input.is_action_just_pressed("special"):
		execute_jutsu()

	# Handle Input History
	if Input.is_action_just_pressed("up"):
		time_since_last_action = 0
		direction_history.push_back("up")
	elif Input.is_action_just_pressed("down"):
		time_since_last_action = 0
		direction_history.push_back("down")
	elif Input.is_action_just_pressed("left"):
		time_since_last_action = 0
		direction_history.push_back("side")
	elif Input.is_action_just_pressed("right"):
		time_since_last_action = 0
		direction_history.push_back("side")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if lock_velocity <= 0:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = max(velocity.x, SPEED) * direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func execute_jutsu():
	var combo = direction_history.slice(max(len(direction_history) - 5, 0))
	direction_history = []
	print(combo)

	if combo.slice(-2) == ["down", "up"]:
		spring_jump_jutsu()
	if combo.slice(-1) == ["side"]:
		sword_charge_jutsu()


func spring_jump_jutsu():
	print("spring jump!")
	velocity.y -= 5000

func sword_charge_jutsu():
	print("sword charge")
	if facing_direction == "right":
		velocity.x += 4000
	else:
		velocity.x -= 4000
	lock_velocity = .2
