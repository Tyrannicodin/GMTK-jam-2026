class_name InputBuffer
extends Node

class ButtonInput:
	var frames_since: int = 0
	var input_event: InputEvent
	var consumed: bool = false

var input_list: Array[ButtonInput] = []

func _process(_delta: float) -> void:
	for b in input_list:
		b.frames_since += 1

func _input(event: InputEvent) -> void:
	var b = ButtonInput.new()
	b.frames_since = 0
	b.input_event = event
	input_list.push_front(b)
	
	if len(input_list) >= 8:
		input_list = input_list.slice(0, 7)

# Only process inputs after 3 frames to make combos feel more consistent.
var allow_after_frames = 3
# If inputs are unused for this amount of frames, they are thrown out. (About 150ms)
var max_fames_after = 10

func is_pressed(action_name: String):
	for input in input_list:
		if (
			input.input_event.is_action_pressed(action_name)
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
				input.input_event.is_action_pressed(key)
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
