class_name Player
extends CharacterBody2D


signal take_damage(amount: int)

@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var facing_direction
# While the player is dashing, we dont want their velocity to be affected
# by movement keys or gravity
var lock_velocity = 0

var flight_time := 0.0

const SPEED = 1000.0
const JUMP_VELOCITY = -2400.0
const COYOTE_TIME = 0.1

func _ready():
	await get_tree().physics_frame
	broadcast_player()

func broadcast_player():
	get_tree().call_group("knows_player", "set_player", self)
	
func add_rewards(rewards: Reward) -> void:
	print("Gained rewards ", rewards.time, "s ", rewards.xp)

func deal_damage(amount: int):
	print("Ow! Took ", amount, " damage!")
	take_damage.emit(amount)

func _physics_process(delta):
	# Add the gravity.
	if lock_velocity <= 0:
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
	lock_velocity -= delta
		
	if velocity.x > 0:
		facing_direction = "right"
		$AnimatedSprite2D.flip_h = true
	if velocity.x < 0:
		facing_direction = "left"
		$AnimatedSprite2D.flip_h = false

	if is_on_floor():
		flight_time = 0
	else:
		flight_time += delta

	# Handle interactions.
	if Input.is_action_just_pressed("interact"):
		for area in detector.get_overlapping_areas():
			var parent = area.get_parent()
			if parent.get("rewards"):
				add_rewards(parent.get("rewards"))
				parent.queue_free()

	# Handle jump.
	if flight_time < COYOTE_TIME:
		if %InputBuffer.is_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if lock_velocity <= 0:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = max(velocity.x, SPEED) * direction
			if (is_on_floor()):
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("jump")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if (is_on_floor()):
				$AnimatedSprite2D.play("idle")
			else:
				$AnimatedSprite2D.play("jump")

	move_and_slide()

	execute_jutsu()

func execute_jutsu():
	if %InputBuffer.is_combo_pressed(["up", "special"]):
		pass
	if %InputBuffer.is_combo_pressed(["down", "special"]):
		spring_jump_jutsu()
	if %InputBuffer.is_pressed("special") or %InputBuffer.is_combo_pressed(["right", "special"]) or %InputBuffer.is_combo_pressed(["left", "special"]):
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
