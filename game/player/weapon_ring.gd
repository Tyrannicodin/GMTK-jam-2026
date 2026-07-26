@tool
extends Node2D

@export var unlocked_weapons: Array[String]:
	set(value):
		unlocked_weapons = value
		check_unlocks()
	get():
		return unlocked_weapons

@export var spear_ready = true
@export var shuriken_ready = true
@export var crazy_bird_ready = true
@export var shield_ready = true
@export var hatchet_ready = true
@export var dagger_ready = true
@export var spin_ready = true

var time = 0.0

@export var TIME_FOR_ROTATION = 1.0
@export var RING_RADIUS: int = 0

@export var READY_BORDER_COLOR: Color = Color("bae0c9")
@export var NOT_READY_BORDER_COLOR: Color = Color("222222")

func _process(delta: float) -> void:
	time += delta
	display_weapons()
	ready_check()

func _ready() -> void:
	unlocked_weapons = []

func display_weapons():
	var visible_weapons = get_children().filter(func(x): return x.visible)
	var number_of_weapons = len(visible_weapons)
	
	for i in range(number_of_weapons):
		var weapon: Sprite2D = visible_weapons[i]

		var percent = 0 
		if number_of_weapons > 1:
			percent += .55 + (float(i) / float(number_of_weapons - 1)) * .4
		else:
			percent = .75
		weapon.position = percent_to_pos(percent)

		weapon.rotation = sin(time * 2 + percent * 10) * .1

func percent_to_pos(percent: float):
	var x = cos(percent * PI * 2) * RING_RADIUS
	var y = sin(percent * PI * 2) * RING_RADIUS
	
	y += sin(time * 2 + percent * 10) * 3
	
	return Vector2(x, y)

func check_unlocks():
	if not is_visible_in_tree():
		return

	if "Spear" in unlocked_weapons: %Spear.show()
	else: %Spear.hide()
	if "Shuriken" in unlocked_weapons: %Shuriken.show()
	else: %Shuriken.hide()
	if "CrazyBird" in unlocked_weapons: %CrazyBird.show()
	else: %CrazyBird.hide()
	if "Hatchet" in unlocked_weapons: %Hatchet.show()
	else: %Hatchet.hide()
	if "Shield" in unlocked_weapons: %Shield.show()
	else: %Shield.hide()
	if "Dagger" in unlocked_weapons: %Dagger.show()
	else: %Dagger.hide()
	if "Spin" in unlocked_weapons: %Spin.show()
	else: %Spin.hide()

func ready_check():
	if spear_ready:
		%Spear.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Spear.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if shuriken_ready:
		%Shuriken.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Shuriken.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if crazy_bird_ready:
		%CrazyBird.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%CrazyBird.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if shield_ready:
		%Shield.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Shield.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if hatchet_ready:
		%Hatchet.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Hatchet.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if dagger_ready:
		%Dagger.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Dagger.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
	if spin_ready:
		%Spin.set_instance_shader_parameter("border_color", READY_BORDER_COLOR)
	else:
		%Spin.set_instance_shader_parameter("border_color", NOT_READY_BORDER_COLOR)
