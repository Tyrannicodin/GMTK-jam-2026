class_name Player
extends CharacterBody2D


signal take_damage(amount: int)
signal gain_time(amount: int)
signal level_up(level:int)
signal unlock_selected(unlock: UnlockResource)

@onready var detector: Area2D = %Detector

enum DIRECTIONS {UP, DOWN, FRONT, BACK}

var ShurikenJutsu = preload("res://game/player_attacks/ShurikenJutsu.tscn")
var BirdJutsu = preload("res://game/player_attacks/BirdJutsu.tscn")
var FlowerJutsu = preload("res://game/player_attacks/Flower.tscn")
var SpearJutsu = preload("res://game/player_attacks/SpearJutsu.tscn")

var facing_direction

var flight_time := 0.0
var time_on_ground := 0.0
var dashed_since_left_ground = false
var jumped_to_leave_ground = false
var invuln_time = 0

var dash_timer = -999
var jutsu_timer = 0

var parry_timer = 0
var freeze_timer = 0
var time_since_damage_taken = 0

var stamina = 100

const WALK_FORCE = 8000
const WALK_MAX_SPEED = 1000
const STOP_FORCE = 8000
const AIR_STOP_FORCE = 2000
const JUMP_SPEED = 1800
const COYOTE_TIME = 0.15
const TERMINAL_VELOCITY = 5000
const INVULN_TIME = .15

const DASH_LENGTH = .16
const DASH_SPEED = 2500
const DASH_COOLDOWN = .25
const JUTSU_COOLDOWN = .05
const ATTACK_COOLDOWN = 0.4

var MAX_STAMINA = 100
const STAMINA_LEVEL_GAIN = 10
const STAMINA_RESTORATION_PER_SECOND = 10

const MUD_FACTOR := 2.0

var dash_count = 1
var dashing = false

var diving = false

var just_jumped = false

var attack_cooldown = 0
var STAMINA_CHARGED_OUTLINE_COLOR = Color("e1eced")
var STAMINA_NOT_CHARGED_OUTLINE_COLOR = Color("0d0601")

var last_animation = "idle"

# Weapons
var SPEAR_COOLDOWN = 1
var SHURIKEN_COOLDOWN = .5
var CRAZY_BIRD_COOLDOWN = 1.5

var curr_spear_cooldown = 0
var curr_shuriken_cooldown = 0
var curr_crazy_bird_cooldown = 0

## How much does more xp do you need per level
@export var level_up_constant := 1.20

var level = 0
var threshold = 10
var xp = 0 :
	set(value):
		if xp + value >= threshold:
			xp = xp + value - threshold
			run_level_up()
		else:
			xp += value

func run_level_up() -> void:
	level += 1
	print("Levelled up.")
	threshold *= level_up_constant
	MAX_STAMINA += STAMINA_LEVEL_GAIN
	level_up.emit(level)

func _ready():
	await get_tree().physics_frame
	broadcast_player()
	
	%StaminaChargedParticles.show()
	%StaminaChargedParticlesFront.show()
	%DashParticles.show()

func broadcast_player():
	get_tree().call_group("knows_player", "set_player", self)
	
func add_rewards(rewards: Reward) -> void:
	if not rewards:
		return
	print("Got rewards: %fs, %sxp" % [rewards.time, rewards.xp])
	gain_time.emit(rewards.time)
	xp += rewards.xp

func deal_damage(weapon: Node2D, amount: int):
	if invuln_time > 0:
		return
  
	if parry_timer > 0:
		print("Parried ", amount, " damage")
		gain_time.emit(amount)
		stamina += 5 * amount
		return
	
	invuln_time = INVULN_TIME

	time_since_damage_taken = 0
	%TextureRect.set_instance_shader_parameter("intensity", 1)
	%TextureRect.queue_redraw()
  
	print("Ow! Took ", amount, " damage!")

	
	var he: Node2D = %HitEffect.spawn()
	he.global_position = self.global_position
	get_parent().add_child(he)
	
	var d: Label = %DamageTakenText.duplicate()
	d.text = "-" + str(amount) + "s"
	d.global_position = global_position
	get_parent().add_child(d)
	d.visible = true
	
	await get_tree().create_timer(0).timeout

	take_damage.emit(amount)

func get_direction():
	if facing_direction == "right":
		return 1
	return -1

func _process(delta: float) -> void:
	stamina += STAMINA_RESTORATION_PER_SECOND * delta
	
	invuln_time -= delta

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
	parry_timer -= delta
	freeze_timer -= delta
	attack_cooldown -= delta
	jutsu_timer -= delta
	if (jutsu_timer < 0):
		jutsu_timer = 0;
	time_since_damage_taken += delta
	
	var damage_taken_intensity = max((.1 - time_since_damage_taken) / .1, 0)
	var dash_intensity = max(dash_timer / DASH_LENGTH, 0)
	
	# Make the dash look pretty
	%TextureRect.set_instance_shader_parameter("intensity", max(damage_taken_intensity, dash_intensity))

	# Weapon cooldown
	curr_spear_cooldown -= delta
	curr_shuriken_cooldown -= delta
	curr_crazy_bird_cooldown -= delta

	%WeaponRing.spear_ready = curr_spear_cooldown < 0
	%WeaponRing.shuriken_ready = curr_shuriken_cooldown < 0
	%WeaponRing.crazy_bird_ready = curr_crazy_bird_cooldown < 0


	# Add the gravity.
	if dash_timer <= 0:
		if dashing:
			dashing = false
			if velocity.y <= 0:
				velocity /= 2
	if not dashing and freeze_timer <= 0:
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
		just_jumped = false
		time_on_ground += delta
		if diving:
			diving = false
			# Spawn Shockwave
	else:
		flight_time += delta
		time_on_ground = 0
		if flight_time > COYOTE_TIME:
			just_jumped = false

	# Handle interactions.
	if Input.is_action_just_pressed("interact"):
		for area in detector.get_overlapping_areas():
			var parent = area.get_parent()
			if parent.get("rewards"):
				add_rewards(parent.get("rewards"))
				parent.queue_free()
			elif parent.get("unlock"):
				unlock_selected.emit(parent.get("unlock"))

	# Handle jump.
	# Jutsu are checked first because it has priority consuming inputs for the frame
	execute_jutsu()
	
	var muddiness := 1.0
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_normal() != Vector2.UP:
			continue
		
		var collider = collision.get_collider()
		if collider is not TileMapLayer:
			continue
			
		var map_coords = collider.local_to_map(collider.to_local(collision.get_position()))
		var cell = collider.get_cell_tile_data(map_coords)
		if cell and cell.get_custom_data("muddy"):
			muddiness = MUD_FACTOR
	
	# Handle jump.
	if flight_time < COYOTE_TIME and not jumped_to_leave_ground and not diving and freeze_timer <= 0:
		# Check for Jump Dash Upgrade
		if %InputBuffer.is_just_pressed("jump") or %InputBuffer.is_pressed("jump"):
			velocity.y -= JUMP_SPEED / muddiness
			jumped_to_leave_ground = true
			just_jumped = true
			if dash_count < 1:
				dash_count += 1
			if not dashing:
				velocity.x += 800 * sign(Input.get_axis("left", "right"))
			if -velocity.y <= abs(velocity.x):
				dashing = false
			elif dashing:
				velocity.y += JUMP_SPEED / 2.0
	
	# Handle "Basic" Attacks
	if not diving:
		# Add attack upgrade checks later
		if dashing and %InputBuffer.is_just_pressed("attack"):
			dash_attack()
		elif just_jumped and (%InputBuffer.is_combo_just_pressed(["left", "attack"], "attack") or %InputBuffer.is_combo_just_pressed(["right", "attack"], "attack")):
			if flight_time < COYOTE_TIME:
				pounce()
			pounce()
		elif attack_cooldown <= 0 and %InputBuffer.is_just_pressed("attack"):
			attack()

	if dash_timer <= 0 and not diving and freeze_timer <= 0:
		var direction = %InputBuffer.get_axis("left", "right")
		var walk = WALK_FORCE * direction
		# Slow down the player if they're not trying to move.
		if abs(walk) < WALK_FORCE * 0.2:
			friction(delta, muddiness)
		else:
			var INITIAL_SPEED = velocity.x
			if abs(velocity.x) < WALK_MAX_SPEED / muddiness:
				velocity.x += walk * delta / muddiness
			elif sign(velocity.x) != sign(walk):
				velocity.x += walk * delta
				friction(delta, muddiness)
			else:
				friction(delta, muddiness)
				if abs(velocity.x) < WALK_MAX_SPEED and abs(INITIAL_SPEED) > WALK_MAX_SPEED:
					velocity.x = WALK_MAX_SPEED * sign(velocity.x)
		
		if (is_on_floor()):
			if dash_count == 0:
				dash_count = 1
				
		if %AnimatedSprite2D.animation != "jutsu":
			if is_on_floor():
				if direction:
					%AnimatedSprite2D.play("walk")
					last_animation = "walk"
				else:
					%AnimatedSprite2D.play("idle")
					last_animation = "idle"
			elif %AnimatedSprite2D.animation != "dash":
				%AnimatedSprite2D.play("jump")
				last_animation = "jump"

	move_and_slide()

func friction(delta, multiplier: float):
	# The velocity, slowed down a bit, and then reassigned.
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta * multiplier)
	else:
		# air has less friction
		velocity.x = move_toward(velocity.x, 0, AIR_STOP_FORCE * delta * multiplier)

func execute_jutsu():
	if jutsu_timer > 0:
		return

	jutsu_timer = JUTSU_COOLDOWN

	if %InputBuffer.is_combo_just_pressed(["up", "special"], "special"):
		%AnimatedSprite2D.play("jutsu")
		# flower_jutsu()
		scug_jutsu()
	
	elif %InputBuffer.is_combo_just_pressed(["down", "special"], "special"):
		%AnimatedSprite2D.play("jutsu")
		if is_on_floor():
			missiles_jutsu()
		else:
			dive_jutsu()
	
	elif %InputBuffer.is_combo_just_pressed(["left", "right", "special"], "special"):
		%AnimatedSprite2D.play("jutsu")
		spin_jutsu()
		burst_jutsu()
	
	elif %InputBuffer.is_combo_just_pressed(["left", "special"], "special") or %InputBuffer.is_combo_just_pressed(["right", "special"], "special") or %InputBuffer.is_just_pressed("special"):
		%AnimatedSprite2D.play("jutsu")
		shuriken_jutsu()
		bird_jutsu()

	if %InputBuffer.is_combo_pressed(["dash"]):
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
	if diving:
		return
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
	%AnimatedSprite2D.play("dash")

func shuriken_jutsu():
	if curr_shuriken_cooldown > 0:
		return
	curr_shuriken_cooldown = SHURIKEN_COOLDOWN

	for i in range(3):
		var s: RigidBody2D = ShurikenJutsu.instantiate()
		s.global_position = self.global_position
		get_parent().add_child(s)

		s.linear_velocity.x = get_direction() * 4000
		s.linear_velocity.y = -400
		await get_tree().create_timer(.1).timeout
		
func flower_jutsu():
	if stamina < 30:
		return
	var f = FlowerJutsu.instantiate()
	f.global_position = self.global_position - Vector2(0, 100)
	get_parent().add_child(f)
	stamina -= 30

func dive_jutsu():
	if stamina < 30:
		return
	if diving:
		return
	velocity.x = 0
	velocity.y = 5000
	diving = true
	stamina -= 30

func bird_jutsu():
	if curr_crazy_bird_cooldown > 0:
		return
	curr_crazy_bird_cooldown = CRAZY_BIRD_COOLDOWN

	var s: RigidBody2D = BirdJutsu.instantiate()
	s.global_position = self.global_position
	get_parent().add_child(s)

	s.linear_velocity.x = get_direction() * 500
	s.linear_velocity.y = 0

	stamina -= 30

func spin_jutsu():
	if stamina < 30:
		return
	# Storm of Steel
	stamina -= 30

func burst_jutsu():
	if stamina < 30:
		return
	parry_timer = 0.1
	freeze_timer = 0.1
	# Maybe also deal damage in a small radius.
	stamina -= 30

func missiles_jutsu():
	if stamina < 30:
		return
	for i in range(5):
		pass # Summon Homing (Magic) Missiles in an overhead arc.
	stamina -= 30

func scug_jutsu():
	if curr_spear_cooldown > 0:
		return
	curr_spear_cooldown = SPEAR_COOLDOWN

	var s: RigidBody2D = SpearJutsu.instantiate()
	s.global_position = self.global_position
	get_parent().add_child(s)

	s.linear_velocity.y -= 2000


func attack():
	attack_cooldown = ATTACK_COOLDOWN # Basic Attack

func dash_attack():
	pass # No extra stamina cost

func pounce():
	if stamina < 10:
		return
	velocity *= 1.1
	# Single Target Melee, 10 damage on hit.
	stamina -= 10
	

func _on_animated_sprite_2d_animation_finished():
	%AnimatedSprite2D.play(last_animation)

var tmp: bool = false :
	set(value):
		print("Tried to make tmp trueitive!")
