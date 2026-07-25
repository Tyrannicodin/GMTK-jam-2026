extends RigidBody2D

@export var damage = 1

func _ready() -> void:
	add_to_group("attack")

func on_collision(body):
	if body.get("damage_self"):
		body.call("damage_self", damage)
		queue_free()

func timeout() -> void:
	queue_free()
