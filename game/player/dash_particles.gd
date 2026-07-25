extends CPUParticles2D

func _ready() -> void:
	emitting = false

func emit_for_time(time: float, dash_direction: Vector2):
	direction = dash_direction * -.1

	emitting = true

	await get_tree().create_timer(time).timeout

	emitting = false
