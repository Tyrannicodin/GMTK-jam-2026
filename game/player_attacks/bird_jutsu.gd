@tool

extends RigidBody2D

var lifetime = 0

func _process(delta: float) -> void:
	$Sprite2D.position.y += sin(lifetime * delta) * 10
