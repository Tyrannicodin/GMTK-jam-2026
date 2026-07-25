class_name Player
extends CharacterBody2D


signal take_damage(amount: int)

@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var facing_direction

var flight_time := 0.0
var dashed_since_left_ground = false
var jumped_to_leave_ground = false
var dash_timer = -999


const WALK_FORCE = 8000
const WALK_MAX_SPEED = 700
const STOP_FORCE = 8000
const AIR_STOP_FORCE = 4000
const JUMP_SPEED = 1200
const COYOTE_TIME = 0.15
const TERMINAL_VELOCITY = 5000

const DASH_LENGTH = .15
const DASH_SPEED = 800
const DASH_COOLDOWN = .25

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
	dash_timer -= delta

	# Add the gravity.
	if dash_timer <= 0:
		if velocity.y < 0:
			# The ascent should be slower than the fall
			velocity += get_gravity() * delta * .8
		else:
			velocity += get_gravity() * delta
		if velocity.y > TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY

	if velocity.x > 0:
		facing_direction = "right"
		$AnimatedSprite2D.flip_h = true
	if velocity.x < 0:
		facing_direction = "left"
		$AnimatedSprite2D.flip_h = false

	if is_on_floor():
		flight_time = 0
		dashed_since_left_ground = false
		jumped_to_leave_ground = false
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
	# Jutsu are checked first because it has priority consuming inputs for the frame
	execute_jutsu()
	
	if flight_time < COYOTE_TIME and not jumped_to_leave_ground:
		if %InputBuffer.is_pressed("jump"):
			velocity.y -= JUMP_SPEED
			jumped_to_leave_ground = true

	if dash_timer <= 0:
		var direction = %InputBuffer.get_axis("left", "right")
		var walk = WALK_FORCE * direction
		# Slow down the player if they're not trying to move.
		if abs(walk) < WALK_FORCE * 0.2:
			# The velocity, slowed down a bit, and then reassigned.
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, AIR_STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
		# Clamp to the maximum horizontal movement speed.
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

		if (is_on_floor()):
			if direction:
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("jump")

	move_and_slide()

func execute_jutsu():
	if %InputBuffer.is_combo_pressed(["up", "special"]):
		pass
	if %InputBuffer.is_combo_pressed(["down", "special"]):
		spring_jump_jutsu()
	if %InputBuffer.is_pressed("special") or %InputBuffer.is_combo_pressed(["right", "special"]) or %InputBuffer.is_combo_pressed(["left", "special"]):
		sword_charge_jutsu()

	if %InputBuffer.is_combo_pressed(["dash"]):
		var x = %InputBuffer.get_axis("left", "right")
		var y = %InputBuffer.get_axis("up", "down")

		if x == 0 and y == 0:
			if facing_direction == "right":
				dash(Vector2(1, y))
			else:
				dash(Vector2(-1, y))
		else:
			dash(Vector2(x, y))

func dash(direction: Vector2):
	if dash_timer - DASH_LENGTH > -DASH_COOLDOWN:
		return
	if dashed_since_left_ground:
		return
	dashed_since_left_ground = true

	velocity = Vector2(DASH_SPEED, 0)
	velocity = velocity.rotated(direction.angle())
		
	if abs(velocity.x) < 1:
		velocity.x = 0
	if abs(velocity.y) < 1:
		velocity.y = 0

	dash_timer = DASH_LENGTH

func spring_jump_jutsu():
	print("spring jump!")
	velocity.y -= 5000

func sword_charge_jutsu():
	print("sword charge")
	if facing_direction == "right":
		velocity.x += 4000
	else:
		velocity.x -= 4000
