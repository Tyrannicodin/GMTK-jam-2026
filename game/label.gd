extends Label


func happy(duration: float):
	modulate = Color(0, 1, 0)
	await get_tree().create_timer(duration).timeout
	modulate = Color(1, 1, 1)

func sad(duration: float):
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(duration).timeout
	modulate = Color(1, 1, 1)
