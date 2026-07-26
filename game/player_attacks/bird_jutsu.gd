@tool

extends RigidBody2D

var lifetime = 0

func _ready() -> void:
	$Sprite2D.position.y = 0

func _process(delta: float) -> void:
	lifetime += delta
	
	$Sprite2D.position.y += sin(10 * lifetime) * 2

	if linear_velocity.x > 0:
		$Sprite2D.scale.x = abs($Sprite2D.scale.x) * -1
