extends Control

@onready var compassArrow = $CompassArrow

func _ready() -> void:
	SystemEvents.update_compass.connect(_update_compass_arrow)

func _update_compass_arrow(player: Node3D, dest_pos: Vector3):
	var dest_angle = player.global_position.angle_to(dest_pos)
	var final_angle = dest_angle + player.rotation.y - deg_to_rad(90)
	var tween = get_tree().create_tween()
	tween.tween_property(compassArrow, "rotation", final_angle, 0.2)
