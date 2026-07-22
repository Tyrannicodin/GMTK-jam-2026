@tool
extends Control

@export var tooltip_name: String = "Name"
@export_multiline var tooltip_description: String = "Example tooltip description"

func _process(_delta) -> void:
	%TooltipName.text = tooltip_name
	%TooltipDescription.text = tooltip_description
