extends Label

var lifetime = 0
var y_velocity = -10
var x_velocity = 0

func _process(delta: float) -> void:
	if visible:
		if x_velocity == 0:
			x_velocity = randf_range(-8, 8)
		lifetime += delta
		y_velocity += 40 * delta
		position.x += x_velocity
		position.y += y_velocity

	if position.y > 2000:
		queue_free()
