extends "res://game/player_attacks/attack.gd"

func on_collision(body):
	super.on_collision(body)
	queue_free()
