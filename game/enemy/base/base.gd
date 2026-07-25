class_name BaseEnemy
extends CharacterBody2D

@export var damage: int = 1
@export var health = 10
@export var reward: Reward

var flash_time = 0
var is_dead = false

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

func _process(delta):
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

func damage_self(amount: int) -> void:
	health -= amount
	flash_time = .1

	if health <= 0:
		player.add_rewards(reward)
		is_dead = true
		%Sprite.set_instance_shader_parameter("intensity", 1.0)
		%Collision.disabled = true
		
		collision_layer = 100
