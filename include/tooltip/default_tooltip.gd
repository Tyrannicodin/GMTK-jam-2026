@tool

extends Control

@export var around: Node

func _ready() -> void:
	%Tooltip.show_when_hovering = around
	%Tooltip.around = around
	%Tooltip.avoid_overlap.push_back(around)
	%Hints.show_when_hovering = around
	%Hints.around = %MainTooltip
	%Hints.avoid_overlap.push_back(around)
