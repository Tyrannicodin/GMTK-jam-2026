extends RigidBody2D


var player: Player

@onready var explosion_shape: CollisionShape2D = $Explosion/Shape

func explode() -> void:
	explosion_shape.shape = explosion_shape.shape.duplicate_deep()
	var tween = create_tween()
	freeze = true
	tween.tween_property(explosion_shape.shape, "radius", 250, 0.25)
	tween.tween_callback(queue_free).set_delay(0.25)


func damage_player(body):
	if body == player:
		player.deal_damage(10)
