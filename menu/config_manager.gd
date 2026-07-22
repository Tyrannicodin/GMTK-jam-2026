extends Node

signal on_value_set(param: String, value: Variant)

@onready var _file = ConfigFile.new()

func _ready():
	_file.load("user://options.cfg")

func set_value(param: String, value: Variant) -> void:
	_file.set_value("options", param, value)
	on_value_set.emit(param, value)

func get_value(param: String, default = null) -> Variant:
	return _file.get_value("options", param, default)

func on_quit() -> void:
	_file.save("user://options.cfg")
