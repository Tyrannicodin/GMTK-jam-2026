extends CharacterBody2D


@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var direction_history: Array = ["", "", "", "", ""]
var hist_tracker: int = 0
var jutsu_storage # Stores casted jutsu when special is held.


const SPEED = 2000.0
const JUMP_VELOCITY = -2400.0

func add_rewards(rewards: Reward) -> void:
	print("Gained rewards ", rewards.time, "s ", rewards.xp)

func _physics_process(delta):
	# Add the gravity.
	velocity += get_gravity() * delta

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
	if Input.is_action_just_pressed("special"):
		var front = "special" # Track front/back for horizontal input.
		var tracker_pointer = hist_tracker # Read history backwards.
		# Make a decision tree.
		
	# Release Jutsu
	if Input.is_action_just_released("special"):
		pass
	
	# Handle Input History
	if Input.is_action_just_pressed("up"):
		direction_history[hist_tracker] = "up"
		tracker_increment()
	elif Input.is_action_just_pressed("down"):
		direction_history[hist_tracker] = "down"
		tracker_increment()
	elif Input.is_action_just_pressed("left"):
		if Input.is_action_just_pressed("right"):
			direction_history[hist_tracker] = special_decision()
		else:
			direction_history[hist_tracker] = "left"
		tracker_increment()
	elif Input.is_action_just_pressed("right"):
		if Input.is_action_just_pressed("left"):
			direction_history[hist_tracker] = special_decision()
		else:
			direction_history[hist_tracker] = "right"
		tracker_increment()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func tracker_increment():
	hist_tracker += 1
	hist_tracker %= 5

# Yes.
func special_decision():
	if randf() >= 0.5:
		return "right"
	else:
		return "left"
