extends Node2D


signal object_entered(area: Area2D)
signal object_exited(area: Area2D)

func on_area_entered(area):
	if is_ancestor_of(area):
		return
	object_entered.emit(area)

func on_area_exited(area):
	if is_ancestor_of(area):
		return
	object_exited.emit(area)

func lock():
	for door in get_tree().get_nodes_in_group("border_doors"):
		if is_ancestor_of(door):
			door.call("lock")