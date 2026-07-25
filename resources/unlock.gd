extends Resource
class_name UnlockResource

## The property on game to set to true
@export var id: StringName
## Chance of it showing up
@export var probability: float = 1.0

@export_category("Unlock Details")
## Name displayed on upgrade card
@export var name: String
## Short description of the unlock
@export_multiline() var description: String
## Upgrade card background
@export var color: Color
