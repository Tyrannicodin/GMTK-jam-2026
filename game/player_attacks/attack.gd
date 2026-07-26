extends RigidBody2D
class_name Attack

@export var damage = 1
@export var stamina = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("attack")

func on_collision(body):
	if body.get("damage_self"):
		body.call("damage_self", damage)

func timeout() -> void:
	queue_free()
