extends CharacterBody2D


@onready var ray: RayCast2D = $RayCast2D

@export var damage: int = 1
@export var avoid_falls: bool = true

@export var speed = 200.0

@export var health = 10
@export var reward: Reward

var flash_time = 0
var is_dead = false

var right := true

var player: Player

func _ready() -> void:
	add_to_group("damage_self")

func set_player(object: Player):
	player = object

func attack_left(_body):
	pass

func attack_right(_body):
	pass

func can_move():
	return true

func _physics_process(delta):
	if not is_dead:
		%Sprite.set_instance_shader_parameter("intensity", max(flash_time / .1, 0))
		flash_time -= delta
	
	if is_dead:
		%Sprite.scale.x -= 5 * delta
		%Sprite.scale.y = %Sprite.scale.x
		%Sprite.rotation += 20 * delta

		if %Sprite.scale.x <= 0:
			queue_free()

		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not ray.is_colliding() and avoid_falls:
		right = not right

	for idx in get_slide_collision_count():
		# Swap on wall collision
		if abs(get_slide_collision(idx).get_normal().x) == 1:
			right = not right

	velocity.x = speed * (1 if right else -1) * (1 if can_move() else 0)

	move_and_slide()

func damage_self(amount: int) -> void:
	health -= amount
	flash_time = .1

	if health <= 0:
		player.add_rewards(reward)
		is_dead = true
		%Sprite.set_instance_shader_parameter("intensity", 1.0)
		
		collision_layer = 100
