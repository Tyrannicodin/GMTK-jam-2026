extends StaticBody2D


@export var locked = false

func _ready():
	$CollisionShape2D.disabled = not locked

func lock():
	$CollisionShape2D.set_deferred("disabled", false)

func unlock():
	$CollisionShape2D.set_deferred("disabled", true)
