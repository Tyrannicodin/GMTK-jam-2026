extends "res://game/enemy/basic/basic.gd"

func can_move():
	return not $Weapon.attacking

func attack_left(body):
	if body == player:
		$Weapon.attack()

func attack_right(body):
	if body == player:
		$Weapon.attack()
