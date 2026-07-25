# https://shaggydev.com/2022/02/23/screen-shake-godot/

extends Camera2D

# The starting range of possible offsets using random values
@export var MAX_POWER: float = 20
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake(power: float) -> void:
	shake_strength = max(shake_strength, MAX_POWER * min(power, 1.))

func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0., SHAKE_DECAY_RATE * delta)

	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	self.offset = get_random_offset()

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
