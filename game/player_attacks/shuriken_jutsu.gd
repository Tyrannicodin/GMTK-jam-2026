extends "res://game/player_attacks/attack.gd"

func _ready() -> void:
	$Sprite2D.frame = randi_range(0, 4)

func on_collision(body: PhysicsBody2D):
	super.on_collision(body)
	if body.is_in_group("damage_self"):
		queue_free()
