extends Node2D

var splochy = preload("res://resources/pets/splochy.tres")

func _ready() -> void:
	var cat = splochy.new()
	print(cat.behavior.get_sound())
