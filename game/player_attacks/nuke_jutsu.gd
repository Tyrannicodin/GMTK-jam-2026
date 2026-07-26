extends RigidBody2D

var time_alive = 0

func _process(delta: float) -> void:
	time_alive += delta
	
	if time_alive >= .3:
		queue_free()
	
