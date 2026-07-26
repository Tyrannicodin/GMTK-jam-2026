extends "res://game/player_attacks/attack.gd"

func _process(_delta: float) -> void:
	if linear_velocity.x > 0:
		$Sprite2D.rotation_degrees = 45
