extends "res://resources/rooms/scenes/room.gd"


const UNLOCK_OBJECT = preload("res://game/room_objects/unlock/unlock.tscn")

var run: int
var first_lock: bool = true

func _ready() -> void:
	if run == 20:
		%DogDude.hide()
		%DogGuyBox.hide()
		%CrabGuyText.text = "I've broken his spell, the true path is revealed!\nNow is your chance to stop him!"
		%NodeTutorital.stopped = true
	elif run != 1:
		%NodeTutorital.stopped = true
		%DogDude.hide()
		%CrabGuyBox.hide()
		%DogGuyBox.hide()

func unlock() -> void:
	if first_lock:
		first_lock = false
		return
	super.unlock()

func set_unlocks(unlocks: Array, hider: Signal) -> void:
	for unlocker in unlocks:
		var obj = UNLOCK_OBJECT.instantiate()
		obj.set_unlock(unlocker)
		hider.connect(obj.hide)
		%UnlockContainer.add_child(obj)
