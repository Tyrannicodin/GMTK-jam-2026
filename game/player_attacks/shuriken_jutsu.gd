extends RigidBody2D

@export var knockback = 10
@export var damage = 3

func _ready() -> void:
	add_to_group("attack")

func on_collision(body):
	if body.get("damage_self"):
		print("hello")
		body.call("damage_self", damage)
		queue_free()

func timeout() -> void:
	queue_free()
