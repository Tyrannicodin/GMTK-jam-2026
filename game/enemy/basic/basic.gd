extends CharacterBody2D


@onready var ray: RayCast2D = $RayCast2D

@export var damage: int = 1
@export var avoid_falls: bool = true

@export var speed = 200.0

var right := true
var turned = false

var player: Player

func set_player(object: Player):
	player = object

func attack_left(_body):
	pass

func attack_right(_body):
	pass

func can_move():
	return true

func _physics_process(delta):
	turned = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not ray.is_colliding() and avoid_falls:
		if not turned:
			right = not right
			turned = true

	for idx in get_slide_collision_count():
		# Swap on wall collision
		if abs(get_slide_collision(idx).get_normal().x) == 1:
			right = not right

	velocity.x = speed * (1 if right else -1) * (1 if can_move() else 0)

	move_and_slide()


func _on_barrier_collider_area_entered(area: Area2D) -> void:
	if not turned:
		right = not right
		turned = true
