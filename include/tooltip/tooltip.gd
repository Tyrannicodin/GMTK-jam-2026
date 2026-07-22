@tool
extends Control
class_name Tooltip

# Offset the y height of the hints. This can be
# used to properly center the hints panel for a graphic.
const HINTS_Y_OFFSET = 0

enum Direction {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

@export var show_when_hovering: Node
@export var around: Node = null
@export var direction_0: Direction = Direction.LEFT
@export var direction_1: Direction = Direction.LEFT
@export var direction_2: Direction = Direction.LEFT
@export var direction_3: Direction = Direction.LEFT
@export var tooltip: Control
@export var avoid_overlap: Array[Node] = []

var displayed_hints: Array[Node] = []

func _ready() -> void:
	tooltip.size.y = 0

func _process(_delta: float):
	# If I don't do this, the tooltip becomes really tall
	# I do not know why
	tooltip.size.y = 0

	if around == null:
		return
	if show_when_hovering == null:
		show()
		return

	position_main_tooltip()

	if show_when_hovering != null:
		if get_node_global_bounding_box(show_when_hovering).has_point(get_global_mouse_position()):
			show()
		else:
			hide()


func position_main_tooltip():
	var around_rect = get_node_global_bounding_box(around)

	var direction_priority_list: Array[Direction] = [direction_0, direction_1, direction_2, direction_3]

	if tooltip == null:
		return

	tooltip.global_position = position_single_tooltip(get_tooltip_size(), around_rect, direction_priority_list)

func position_single_tooltip(tooltip_size, around_node, direction_priority: Array[Direction]) -> Vector2:
	for d in direction_priority:
		var location = null
		if d == Direction.LEFT:
			location = try_place_left(tooltip_size, around_node)
		if d == Direction.RIGHT:
			location = try_place_right(tooltip_size, around_node)
		if d == Direction.UP:
			location = try_place_up(tooltip_size, around_node)
		if d == Direction.DOWN:
			location = try_place_down(tooltip_size, around_node)

		if location != null:
			var tooltip_global_bounding_box = Rect2(location, tooltip_size)
			for do_not_overlap in avoid_overlap:
				if get_node_global_bounding_box(do_not_overlap).intersects(tooltip_global_bounding_box):
					location = null
					break

		if location != null:
			return location
			
	return Vector2(0, 0)


func try_place_left(tooltip_size: Vector2, around: Rect2):
	var top_left_x = around.position.x - tooltip_size.x
	var top_left_y = around.position.y + around.size.y / 2 - tooltip_size.y / 2

	if top_left_x < 0:
		return null
	if top_left_y < 0:
		top_left_y = 0
	if top_left_y + tooltip_size.y >= get_viewport_size().size.y:
		top_left_y = get_viewport_size().size.y - tooltip_size.y

	return Vector2(top_left_x, top_left_y)

func try_place_right(tooltip_size: Vector2, around: Rect2):
	var top_left_x = around.position.x + around.size.x
	var top_left_y = around.position.y + around.size.y / 2 - tooltip_size.y / 2

	if top_left_x + tooltip_size.x > get_viewport_size().size.x:
		return null
	if top_left_y < 0:
		top_left_y = 0
	if top_left_y + tooltip_size.y >= get_viewport_size().size.y:
		top_left_y = get_viewport_size().size.y - tooltip_size.y

	return Vector2(top_left_x, top_left_y)

func try_place_up(tooltip_size: Vector2, around: Rect2):
	var top_left_x = around.position.x + around.size.x / 2 - tooltip_size.x / 2
	var top_left_y = around.position.y - tooltip_size.y

	if top_left_y < 0:
		return null
	if top_left_x < 0:
		top_left_x = 0
	if top_left_x + tooltip_size.x >= get_viewport_size().size.x:
		top_left_x = get_viewport_size().size.x - tooltip_size.x

	return Vector2(top_left_x, top_left_y)

func try_place_down(tooltip_size: Vector2, around: Rect2):
	var top_left_x = around.position.x + around.size.x / 2 - tooltip_size.x / 2
	var top_left_y = around.position.y + around.size.y 

	if top_left_y + tooltip_size.y > get_viewport_size().size.y:
		return null
	if top_left_x < 0:
		top_left_x = 0
	if top_left_x + tooltip_size.x >= get_viewport_size().size.x:
		top_left_x = get_viewport_size().size.x - tooltip_size.x

	return Vector2(top_left_x, top_left_y)

func get_node_global_bounding_box(node: Node):
	if node == null:
		return Rect2()
	var node_position: Vector2 = node.position

	var node_size: Rect2
	var node_top_left

	if node is Node2D:
		node_size = node.get_rect()
		node_top_left = node_position + node_size.position
	if node is Control:
		node_size = node.get_global_rect()
		node_top_left = node_size.position

	return Rect2(node_top_left, node_size.size)


func get_viewport_size():
	# When editing, the viewport size is the size of view that we edit the level in.
	# I use 1920x1080 instead because we hardcode that for our project and it looks correct.
	if Engine.is_editor_hint():
		return Rect2(Vector2(0, 0), Vector2(1920, 1080))
	return get_viewport().get_visible_rect()

func get_tooltip_size():
	if tooltip:
		return tooltip.size
	return Vector2(0.,0.)
