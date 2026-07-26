extends CenterContainer


const SCENE_PATH = "res://game/game.tscn"

var loading := false

@onready var menu = $MainMenu
@onready var options = $Options

@onready var title = $MainMenu/HBoxContainer/Label

func _ready() -> void:
	title.text = ProjectSettings.get_setting("application/config/name")
	menu.show()
	options.hide()

func start_pressed() -> void:
	print("Starting the game")
	ResourceLoader.load_threaded_request(SCENE_PATH)
	loading = true

func options_pressed() -> void:
	options.show()
	menu.hide()

func options_back_pressed() -> void:
	menu.show()
	options.hide()

func quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	if not loading:
		return
	else:
		%Progress.show()
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(SCENE_PATH, progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(SCENE_PATH))
	
	%Progress.value = progress[0]
