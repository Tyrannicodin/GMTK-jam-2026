extends Node2D


signal object_entered(area: Area2D)
signal object_exited(area: Area2D)
signal completed_stage()

@onready var tilemap = $TileMapLayer

func on_area_entered(area):
	if is_ancestor_of(area):
		return
	object_entered.emit(area)

func on_area_exited(area):
	if is_ancestor_of(area):
		return
	object_exited.emit(area)

func unlock() -> void:
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(6, 3)):
		tilemap.set_cell(cell, 3, Vector2i(7, 3))
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(6, 4)):
		tilemap.set_cell(cell, 3, Vector2i(7, 4))
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(6, 5)):
		tilemap.set_cell(cell, 3, Vector2i(7, 5))

func lock() -> void:
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(7, 3)):
		tilemap.set_cell(cell, 3, Vector2i(6, 3))
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(7, 4)):
		tilemap.set_cell(cell, 3, Vector2i(6, 4))
	for cell in tilemap.get_used_cells_by_id(3, Vector2i(7, 5)):
		tilemap.set_cell(cell, 3, Vector2i(6, 5))

func round_started():
	for door in get_tree().get_nodes_in_group("border_doors"):
		if is_ancestor_of(door):
			door.call("unlock")
