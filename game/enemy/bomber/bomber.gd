extends "res://game/enemy/basic/basic.gd"


const LAUNCH_FORCE = Vector2(500, -600)

var bomb = preload("res://game/enemy/bomber/bomb.tscn")

var cooldown := 5.0

func _physics_process(delta):
	super._physics_process(delta)

	if not player:
		return

	cooldown -= delta
	if cooldown > 0:
		return
	
	cooldown = 5.0

	var throw_left = true
	if player.global_position.x > global_position.x:
		throw_left = false
	
	var new_bomb: RigidBody2D = bomb.instantiate()
	new_bomb.position = position
	new_bomb.apply_central_impulse(LAUNCH_FORCE * 3 * Vector2(-1 if throw_left else 1, 1))
	
	get_parent().add_child(new_bomb)
