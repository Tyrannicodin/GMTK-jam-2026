extends "res://game/player_attacks/attack.gd"

func _ready() -> void:
	%Sprite.frame = randi_range(0, 4)

func on_collision(body):
	super.on_collision(body)
	if body.is_in_group("damage_self"):
		queue_free()
