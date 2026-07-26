extends Attack

func _process(_delta: float) -> void:
	if linear_velocity.x > 0:
		$Sprite2D.rotation_degrees = 45
