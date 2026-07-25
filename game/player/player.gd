class_name Player
extends CharacterBody2D


signal take_damage(amount: int)
signal gain_time(amount: int)

@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var ShurikenJutsu = preload("res://game/player_attacks/ShurikenJutsu.tscn")
var FlowerJutsu = preload("res://game/player_attacks/Flower.tscn")

var facing_direction

var flight_time := 0.0
var time_on_ground := 0.0
var dashed_since_left_ground = false
var jumped_to_leave_ground = false

var dash_timer = -999
var jutsu_timer = 0

var stamina = 100


const WALK_MAX_SPEED = 1000
const AIR_STOP_FORCE = 4000
const JUMP_SPEED = 1800
const COYOTE_TIME = 0.15
const TERMINAL_VELOCITY = 5000

const LANDING_INPUT_DELAY = .05

const DASH_LENGTH = .16
const DASH_SPEED = 2500
const DASH_COOLDOWN = .25
const JUTSU_COOLDOWN = .05

const MAX_STAMINA = 100
const STAMINA_RESTORATION_PER_SECOND = 10

var dash_count = 1
var dashing = false

var STAMINA_CHARGED_OUTLINE_COLOR = Color("e1eced")
var STAMINA_NOT_CHARGED_OUTLINE_COLOR = Color("0d0601")

## How much does more xp do you need per level
@export var level_up_constant := 1.20

var level = 0
var threshold = 10
var xp = 0 :
	set(value):
		if xp + value >= threshold:
			level += 1
			threshold *= level_up_constant
			xp = xp + value - threshold
		else:
			xp += value

func _ready():
	await get_tree().physics_frame
	broadcast_player()

func broadcast_player():
	get_tree().call_group("knows_player", "set_player", self)
	
func add_rewards(rewards: Reward) -> void:
	if not rewards:
		print("Rewards is NIL")
		return
	print("Got rewards: %fs, %sxp" % [rewards.time, rewards.xp])
	gain_time.emit(rewards.time)
	xp += rewards.xp

func deal_damage(amount: int):
	print("Ow! Took ", amount, " damage!")
	take_damage.emit(amount)

func get_direction():
	if facing_direction == "right":
		return 1
	return -1

func _process(delta: float) -> void:
	stamina += STAMINA_RESTORATION_PER_SECOND * delta
	
	if stamina > MAX_STAMINA:
		stamina = MAX_STAMINA

	if stamina > 30:
		var color = STAMINA_CHARGED_OUTLINE_COLOR
		if stamina < 35:
			color = STAMINA_CHARGED_OUTLINE_COLOR * ((stamina - 30) / 5) + STAMINA_NOT_CHARGED_OUTLINE_COLOR * (1 - ((stamina - 30) / 5))
		%TextureRect.set_instance_shader_parameter("outline_color", color)
	else:
		%TextureRect.set_instance_shader_parameter("outline_color", STAMINA_NOT_CHARGED_OUTLINE_COLOR)

	if stamina > 35:
		%StaminaChargedParticles.emitting = true
		%StaminaChargedParticlesFront.emitting = true
	else:
		%StaminaChargedParticles.emitting = false
		%StaminaChargedParticlesFront.emitting = false

func _physics_process(delta):
	%InputBuffer.check_inputs()
	
	dash_timer -= delta
	jutsu_timer -= delta
	
	# Make the dash look pretty
	%TextureRect.set_instance_shader_parameter("intensity", max(dash_timer / DASH_LENGTH, 0))

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
		%AnimatedSprite2D.flip_h = true
	if velocity.x < 0:
		facing_direction = "left"
		%AnimatedSprite2D.flip_h = false

	if is_on_floor():
		flight_time = 0
		dashed_since_left_ground = false
		jumped_to_leave_ground = false
		time_on_ground += delta
	else:
		flight_time += delta
		time_on_ground = 0

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
		if %InputBuffer.is_just_pressed("jump") or (%InputBuffer.is_pressed("jump") and time_on_ground > LANDING_INPUT_DELAY):
			velocity.y = -JUMP_SPEED
			jumped_to_leave_ground = true
			if not dashing:
				velocity.x += 800 * sign(Input.get_axis("left", "right"))
			if -velocity.y <= abs(velocity.x):
				dashing = false
			elif dashing:
				velocity.y += JUMP_SPEED/2

	if dash_timer <= 0:
		var direction = %InputBuffer.get_axis("left", "right")
		var walk = WALK_MAX_SPEED * direction

		friction(delta)

		if direction != 0:
			velocity.x = walk
			

		if (is_on_floor()):
			if dash_count == 0:
				dash_count = 1
			if direction:
				%AnimatedSprite2D.play("walk")
			else:
				%AnimatedSprite2D.play("idle")
		else:
			%AnimatedSprite2D.play("jump")

	move_and_slide()

func friction(delta):
	# The velocity, slowed down a bit, and then reassigned.
	if is_on_floor():
		# 100% friction on ground
		velocity.x = 0
	else:
		# air has less friction
		velocity.x = move_toward(velocity.x, 0, AIR_STOP_FORCE * delta)

func execute_jutsu():
	if jutsu_timer > 0:
		return

	jutsu_timer = JUTSU_COOLDOWN

	if stamina < 30:
		return
	
	if %InputBuffer.is_combo_just_pressed(["up", "special"], "special"):
		flower_jutsu()
		stamina -= 30

	elif %InputBuffer.is_just_pressed("special"):
		shuriken_jutsu()
		stamina -= 30

	if %InputBuffer.is_combo_pressed(["dash"]):
		stamina -= 30
		
		var x = %InputBuffer.get_axis("left", "right")
		var y = %InputBuffer.get_axis("up", "down")

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
		
	if abs(velocity.x) < 1:
		velocity.x = 0
	if abs(velocity.y) < 1:
		velocity.y = 0

	velocity = direction * DASH_SPEED
	
	dash_timer = DASH_LENGTH
	dash_count -= 1
	dashing = true
	
	%DashParticles.emit_for_time(DASH_LENGTH, direction)

func shuriken_jutsu():
	for i in range(3):
		var s: RigidBody2D = ShurikenJutsu.instantiate()
		s.global_position = self.global_position
		get_parent().add_child(s)

		s.linear_velocity.x = get_direction() * 4000
		s.linear_velocity.y = -400
		await get_tree().create_timer(.1).timeout
		
func flower_jutsu():
	var f = FlowerJutsu.instantiate()
	f.global_position = self.global_position - Vector2(0, 100)
	get_parent().add_child(f)
