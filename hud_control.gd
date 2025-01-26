extends Control

@onready var compassArrow = $CompassArrow

func _ready() -> void:
	SystemEvents.update_compass.connect(_update_compass_arrow)

func _update_compass_arrow(player: Node3D, dest_pos: Vector3):
	var direction = (dest_pos - player.global_transform.origin).normalized()
	var forward = -player.global_transform.basis.z.normalized()
	var angle = forward.angle_to(direction)
	var cross = forward.cross(direction).y
	if cross < 0:
		angle = -angle
	
	# var dest_angle = player.global_position.angle_to(dest_pos)
	# var final_angle = dest_angle + player.rotation.y - deg_to_rad(90)
	var tween = get_tree().create_tween()
	tween.tween_property(compassArrow, "rotation_degrees", -rad_to_deg(angle) - 90, 0.2)
