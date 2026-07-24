extends WeaponScript


var right := false

func attack():
	if attacking:
		return
	attacking = true
	var swing = get_tree().create_tween()
	swing.tween_property(self, "rotation_degrees", 135 * (1 if right else -1), .25)
	swing.tween_property(self, "attacking", false, 0)
	swing.tween_property(self, "rotation_degrees", 0, 0)
