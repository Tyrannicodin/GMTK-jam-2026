extends Button
class_name KeybindButton


signal set_action(key: InputEvent)
signal unbind()

var action: StringName

func _ready():
	set_process_unhandled_input(false)
	toggle_mode = true

func default_text():
	text = ", ".join(InputMap.action_get_events(action).map(func(act: InputEvent): return act.as_text()))

func changing_text():
	text = "Input key (Escape to cancel / Backspace to unbind)"

func _toggled(now_pressed):
	set_process_unhandled_input(now_pressed)
	if now_pressed:
		changing_text()
		release_focus()
	else:
		default_text()
		grab_focus()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		button_pressed = false
	elif event is InputEventMouseMotion:
		return
	elif event.is_action("pause"):
		button_pressed = false
	elif event.is_action("unbind"):
		unbind.emit()
		button_pressed = false
	elif event.pressed:
		set_action.emit(event)
		button_pressed = false
