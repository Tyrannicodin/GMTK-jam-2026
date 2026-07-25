class_name RoomResource
extends Resource

## The room scene, must contain EntryMarker and ExitMarker
@export var scene: PackedScene
## Multiply the value from curve by this value
@export var max_probability: float = 1
## 0 is the first room probability, 1 is the 25th room
@export var probability: Curve
