extends "res://resources/rooms/scenes/room.gd"


signal run_over

var last_run: bool = false

func dog_attacked(_body) -> void:
	%DogGuyBox.show()
	if last_run:
		%Text.text = "Noooooo!\nYou may have stopped me today, but I'll be back, stronger than ever!"
	else:
		%Text.text = "You think I am defeated so easily? You are mistaken!"
	await get_tree().create_timer(2.5).timeout
	run_over.emit()
