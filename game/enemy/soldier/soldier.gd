extends "res://game/enemy/basic/basic.gd"


func attack_left(body):
	if body != player:
		return
	$Weapon.right = false
	$Weapon.attack()

func attack_right(body):
	if body != player:
		return
	$Weapon.right = true
	$Weapon.attack()
