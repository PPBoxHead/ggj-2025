extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func die() -> void:
	$Area3D/CollisionShape3D.disabled = true
	$AnimationPlayer.play("die")
	await $GPUParticles3D.finished
	queue_free()
