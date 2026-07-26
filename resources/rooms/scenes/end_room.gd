extends Node

@export var themes: Array[Theme]
signal input_done

class TextBox:
	var speaker: String
	var text: String
	var label: Theme
	var logic

	static func dog_text(c: String, theme = null, logic = null):
		var t = TextBox.new()
		t.text = c
		t.speaker = "dog"
		if theme != null:
			t.theme = theme
		t.logic = logic
		return t


var story = [
	TextBox.dog_text("My Focus! I need another 30 SECONDS to charge up my Fire Jitsu. Go back to the Dojo!"),
	TextBox.dog_text("ILLUSION JITSU", null, func():
		$"..".completed_stage.emit()
		)
]

func _ready():
	%DogGuyBox.hide()

func play_story():
	for t in story:
		%DogGuyText.text = t.text
		
		await input_done
		
		if t.logic != null:
			await t.logic.call()

		%DogGuyBox.show()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		input_done.emit()


func _on_rigid_body_2d_body_entered(body: Node) -> void:
	play_story()
	body.collision_layer = 1000
