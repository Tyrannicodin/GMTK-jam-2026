extends StaticBody2D


func _ready():
	$CollisionShape2D.disabled = true

func lock():
	$CollisionShape2D.set_deferred("disabled", false)
