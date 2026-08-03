extends GridContainer

signal set_show_tutorial(show: bool)

@export var buses: Array[StringName] = ["Master", "SFX", "Music"]

func _ready():
	tree_exited.connect(ConfigManager.on_quit)

	set_show_tutorial.emit(ConfigManager.get_value("show_tutorial", true))
	ConfigManager.on_value_set.connect(func(param, value): if param == "show_tutorial": set_show_tutorial.emit(value))

	var volume: float
	var bus_label: Label
	var bus_slider: HSlider
	buses.reverse()
	for bus in buses:
		bus_label = Label.new()
		bus_label.text = bus + " volume"
		bus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bus_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		bus_slider = HSlider.new()
		bus_slider.min_value = 0
		bus_slider.max_value = 1
		bus_slider.step = 0.001
		bus_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bus_slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bus_slider.value_changed.connect(
			func(value): update_audio_volume(bus, value)
		)

		volume = ConfigManager.get_value(
			"volume_" + bus,
			AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(bus))
		)
		volume = clamp(volume, 0, 1)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), volume)
		bus_slider.value = volume
		add_child(bus_label)
		add_child(bus_slider)
		move_child(bus_slider, 0)
		move_child(bus_label, 0)
	
	var action_label: Label
	var action_button: KeybindButton
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		
		action_label = Label.new()
		action_label.text = action
		action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		action_button = KeybindButton.new()
		action_button.disabled = action == "pause" or action == "unbind"
		action_button.action = action
		action_button.text = ", ".join(InputMap.action_get_events(action).map(func(act: InputEvent): return act.as_text()))
		action_button.set_action.connect(func(event): ConfigManager.set_keybind(action, event))
		action_button.unbind.connect(func(): ConfigManager.unbind(action))

		add_child(action_label)
		add_child(action_button)

func update_audio_volume(bus: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus)
	ConfigManager.set_value("volume_" + bus, volume)
	AudioServer.set_bus_volume_linear(bus_index, volume)

func show_tutorial_changed(value: bool) -> void:
	ConfigManager.set_value("show_tutorial", value)

func reset_keybidns() -> void:
	ConfigManager.reset_keybinds()
	for child in get_children():
		if child.has_method("default_text"):
			child.call("default_text")
