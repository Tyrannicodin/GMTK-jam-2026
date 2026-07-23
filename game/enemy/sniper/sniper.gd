extends "res://game/enemy/basic/basic.gd"


@onready var line: Line2D = $Line2D

var illuminating: Tween
var attacking: bool

func attack():
	if attacking:
		return
	attacking = true
	line.modulate = Color(1, 0, 0, 0)
	illuminating = get_tree().create_tween()
	illuminating.tween_property(line, "modulate", Color(1, 0, 0, 1), 0.5)
	illuminating.tween_callback(func(): player.deal_damage(damage)).set_delay(0.25)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		ray.target_position = ray.to_local(player.global_position)
		if ray.get_collider() and ray.get_collider() == player:
			attack()
		else:
			if illuminating:
				attacking = false
				illuminating.kill()
				line.modulate = Color(1, 0, 0, 0)
		line.points = [Vector2.ZERO, line.to_local(ray.get_collision_point())]

	move_and_slide()
