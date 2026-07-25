extends Node2D

func spawn():
	var spawned = self.duplicate()

	$Effect.emitting = true

	return spawned
