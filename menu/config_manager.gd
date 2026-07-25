extends Node

signal on_value_set(param: String, value: Variant)

var default_keybinds = {}

@onready var _file = ConfigFile.new()

func _ready():
	_file.load("user://options.cfg")
	for action in InputMap.get_actions():
		default_keybinds[action] = InputMap.action_get_events(action)
	
	load_keybinds()

func set_value(param: String, value: Variant) -> void:
	_file.set_value("options", param, value)
	on_value_set.emit(param, value)

func get_value(param: String, default = null) -> Variant:
	return _file.get_value("options", param, default)

func set_keybind(action: String, key: InputEvent) -> void:
	_file.set_value("keybinds", action, [key])
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
	on_value_set.emit("key_%s" % action, key)

func load_keybinds() -> void:
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var new_keybind = _file.get_value("keybinds", action, default_keybinds[action])
		InputMap.action_erase_events(action)
		for bind in new_keybind:
			InputMap.action_add_event(action, bind)

func reset_keybinds() -> void:
	_file.erase_section("keybinds")
	load_keybinds()

func on_quit() -> void:
	_file.save("user://options.cfg")
