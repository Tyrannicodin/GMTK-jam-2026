extends WeaponScript


func attack():
	if attacking:
		return
	attacking = true

	var tween = get_tree().create_tween()
	tween.tween_property($LeftWing, "rotation_degrees", -30, 0.2)
	tween.parallel().tween_property($RightWing, "rotation_degrees", 30, 0.2)
	
	tween.tween_interval(0.2)

	tween.tween_property($LeftWing, "rotation_degrees", 60, 1)
	tween.parallel().tween_property($RightWing, "rotation_degrees", -60, 1)
	tween.tween_property(self, "attacking", false, 0)
