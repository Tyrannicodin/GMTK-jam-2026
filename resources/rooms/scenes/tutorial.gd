extends Node

@export var themes: Array[Theme]
signal input_done


class TextBox:
	var speaker: String
	var text: String
	var label: Theme
	var logic
	
	static func crab_text(c: String, theme = null, logic = null):
		var t = TextBox.new()
		t.text = c
		t.speaker = "crab"
		if theme != null:
			t.theme = theme
		t.logic = logic
		return t

	static func dog_text(c: String, theme = null, logic = null):
		var t = TextBox.new()
		t.text = c
		t.speaker = "dog"
		if theme != null:
			t.theme = theme
		t.logic = logic
		return t


var story = [
	TextBox.crab_text("Dogstorm! I thought you would have given up after I ousted your seagull army. [z]"),
	TextBox.dog_text("I won't relent until I find the Bombjitsu Scroll. WHERE IS IT!? [z]"),
	TextBox.crab_text("You Fool! I don't have it here. [z]"),
	TextBox.dog_text("Then tonight, I will raid the village and find the secret of Bombjitsu. [z]"),
	TextBox.dog_text("ESCAPE JITSU: SMOKING VIPER [z]", null, func():
		%DogDude.hide()
		%SnakeEnemy.process_mode = Node.PROCESS_MODE_INHERIT
		%SnakeEnemy.show()
		),
	TextBox.crab_text("Quick, go attack the snake! Use Shuriken by pressing X."),
	TextBox.crab_text("He must be using Illusion Jitsu to hide. I'll try to break the spell. Try to find Dogstorm!"),
]

func _ready():
	%CrabGuyBox.hide()
	%DogGuyBox.hide()

	for t in story:
		if t.speaker == "crab":
			%CrabGuyBox.show()
		else:
			%DogGuyBox.show()
		
		%CrabGuyText.text = t.text
		%DogGuyText.text = t.text
		
		await input_done
		
		if t.logic != null:
			await t.logic.call()

		%CrabGuyBox.hide()
		%DogGuyBox.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		input_done.emit()
