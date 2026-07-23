extends Node2D


signal object_entered(area: Area2D)

func on_area_entered(area):
	#@TODO: Add checks here to see if it's a child of this room
	object_entered.emit(area)
