class_name WeaponScript
extends Node2D

@export var damage: int = 1

var player: Player
var attacking = false

func set_player(object: Player):
	player = object

func attack():
	pass

func body_collision(body):
	if body == player:
		player.deal_damage(damage)
