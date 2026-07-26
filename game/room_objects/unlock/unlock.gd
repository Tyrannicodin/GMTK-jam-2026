extends Control


var unlock: UnlockResource

func set_unlock(new_unlock: UnlockResource) -> void:
	unlock = new_unlock
	%Name.text = unlock.name

	%Description.text = unlock.description
	%Keybind.text = unlock.keybind
	%Cooldown.text = "Cooldown: " + unlock.cooldown
	
	#var colorOverride = StyleBoxFlat.new()
	#colorOverride.bg_color = unlock.color
	#remove_theme_stylebox_override("panel")
	#add_theme_stylebox_override("panel", colorOverride)
