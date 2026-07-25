class_name Player
extends CharacterBody2D


signal take_damage(amount: int)

@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var ShurikenJutsu = preload("res://game/player_attacks/ShurikenJutsu.tscn")
var FlowerJutsu = preload("res://game/player_attacks/Flower.tscn")

var facing_direction

var flight_time := 0.0
var dashed_since_left_ground = false
var jumped_to_leave_ground = false
var dash_timer = -999
var dash_count = 1
var dashing = false


const WALK_FORCE = 8000
const WALK_MAX_SPEED = 1000
const STOP_FORCE = 8000
const AIR_STOP_FORCE = 2000
const JUMP_SPEED = 1800
const COYOTE_TIME = 0.15
const TERMINAL_VELOCITY = 5000

const DASH_LENGTH = .16
const DASH_SPEED = 2500
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

func get_direction():
	if facing_direction == "right":
		return 1
	return -1

func _physics_process(delta):
	dash_timer -= delta

	# Add the gravity.
	if dash_timer <= 0:
		if dashing:
			dashing = false
			if velocity.y <= 0:
				velocity /= 2
	if not dashing:
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
	if flight_time < COYOTE_TIME and not jumped_to_leave_ground:
		if %InputBuffer.is_pressed("jump"):
			velocity.y -= JUMP_SPEED
			jumped_to_leave_ground = true
			if not dashing:
				velocity.x += 800 * sign(Input.get_axis("left", "right"))
			if -velocity.y <= abs(velocity.x):
				dashing = false
			elif dashing:
				velocity.y += JUMP_SPEED/2

	if dash_timer <= 0:
		var direction = Input.get_axis("left", "right")
		var walk = WALK_FORCE * direction
		# Slow down the player if they're not trying to move.
		if abs(walk) < WALK_FORCE * 0.2:
			friction(delta)
		else:
			var INITIAL_SPEED = velocity.x
			if abs(velocity.x) < WALK_MAX_SPEED:
				velocity.x += walk * delta
			elif sign(velocity.x) != sign(walk):
				velocity.x += walk * delta
				friction(delta)
			else:
				friction(delta)
				if abs(velocity.x) < WALK_MAX_SPEED and abs(INITIAL_SPEED) > WALK_MAX_SPEED:
					velocity.x = WALK_MAX_SPEED * sign(velocity.x)

		if (is_on_floor()):
			if dash_count == 0:
				dash_count = 1
			if direction:
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("jump")

	move_and_slide()
	execute_jutsu()

func friction(delta):
	# The velocity, slowed down a bit, and then reassigned.
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_STOP_FORCE * delta)

func execute_jutsu():
	if %InputBuffer.is_combo_pressed(["up", "special"]):
		flower_jutsu()

	if %InputBuffer.is_pressed("special") or %InputBuffer.is_combo_pressed(["right", "special"]) or %InputBuffer.is_combo_pressed(["left", "special"]):
		shuriken_jutsu()

	if %InputBuffer.is_combo_pressed(["dash"]):
		var x = Input.get_axis("left", "right")
		var y = Input.get_axis("up", "down")

		if x == 0 and y == 0:
			if facing_direction == "right":
				dash(Vector2(1, y))
			else:
				dash(Vector2(-1, y))
		else:
			var nf = sqrt(pow(x,2) + pow(y,2)) # Normalization Factor
			dash(Vector2(x/nf, y/nf))
			

func dash(direction: Vector2):
	if dash_count < 1:
		return
	if dash_timer - DASH_LENGTH > -DASH_COOLDOWN:
		return
	if dashed_since_left_ground:
		return
	dashed_since_left_ground = true

	velocity = direction * DASH_SPEED
	
	dash_timer = DASH_LENGTH
	dash_count -= 1
	dashing = true

func shuriken_jutsu():
	for i in range(3):
		var s: RigidBody2D = ShurikenJutsu.instantiate()
		s.global_position = self.global_position
		get_parent().add_child(s)

		s.linear_velocity.x = get_direction() * 2000
		await get_tree().create_timer(.1).timeout
		
func flower_jutsu():
	var f = FlowerJutsu.instantiate()
	f.global_position = self.global_position - Vector2(0, 100)
	get_parent().add_child(f)
