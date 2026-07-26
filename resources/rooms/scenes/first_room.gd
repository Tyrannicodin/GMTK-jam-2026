extends "res://resources/rooms/scenes/room.gd"


const UNLOCK_OBJECT = preload("res://game/room_objects/unlock/unlock.tscn")

func set_unlocks(unlocks: Array, hider: Signal) -> void:
	for unlock in unlocks:
		var obj = UNLOCK_OBJECT.instantiate()
		obj.set_unlock(unlock)
		hider.connect(obj.hide)
		%UnlockContainer.add_child(obj)
