class_name InputBuffer
extends Node

class ButtonInput:
	var frames_since: int = 0
	var action: String
	var consumed: bool = false
	var just_pressed: bool = false

	func _to_string() -> String:
		return action

	static func create(action: String):
		var b = ButtonInput.new()
		b.action = action
		b.just_pressed = Input.is_action_just_pressed(action)
		return b

var input_list: Array[ButtonInput] = []

func check_inputs() -> void:
	for b in input_list:
		b.frames_since += 1
	
	for input in [
		"up",
		"down",
		"left",
		"right",
		"special",
		"jump",
		"dash",
	]:
		if Input.is_action_pressed(input):
			input_list.push_front(ButtonInput.create(input))

	if len(input_list) > 15:
		input_list = input_list.slice(0, 15)

var allow_after_frames = 0
# If inputs are unused for this amount of frames, they are thrown out.
var max_fames_after = 8

func is_pressed(action_name: String):
	for input in input_list:
		if (
			input.action == action_name
			and not input.consumed
			and input.frames_since >= allow_after_frames
			and input.frames_since <= max_fames_after
		):
			input.consumed = true
			return true
	return false


func is_just_pressed(action_name: String):
	for input in input_list:
		if (
			input.action == action_name
			and input.just_pressed == true
			and not input.consumed
			and input.frames_since >= allow_after_frames
			and input.frames_since <= max_fames_after
		):
			input.consumed = true
			return true
	return false

func is_combo_pressed(keys: Array):
	var found_inputs: Array[ButtonInput] = []
	var found_keys: Array[String] = []

	for input in input_list:
		for key in keys:
			if key in found_keys:
				continue
			if (
				input.action == key
				and not input.consumed
				and input.frames_since >= allow_after_frames
				and input.frames_since <= max_fames_after
			):
				found_inputs.push_back(input)
				found_keys.push_back(key)

	if len(found_inputs) == len(keys):
		for i in found_inputs:
			i.consumed = true
		return true

	return false


func is_combo_just_pressed(keys: Array, final_key: String):
	var found_inputs: Array[ButtonInput] = []
	var found_keys: Array[String] = []

	for input in input_list:
		for key in keys:
			if key in found_keys:
				continue
			if key == final_key:
				if not input.just_pressed:
					continue
			if (
				input.action == key
				and not input.consumed
				and input.frames_since >= allow_after_frames
				and input.frames_since <= max_fames_after
			):
				found_inputs.push_back(input)
				found_keys.push_back(key)

	if len(found_inputs) == len(keys):
		for i in found_inputs:
			i.consumed = true
		return true

	return false


func get_axis(a, b):
	var aa = is_pressed(a)
	var bb = is_pressed(b)
	
	if aa and bb:
		return 0
	if aa:
		return -1
	if bb:
		return 1

	return 0
