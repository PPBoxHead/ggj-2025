extends Control

@onready var compassArrow = $CompassArrow

@onready var soap_1: TextureRect = $CanisterRect/Soap1
@onready var soap_2: TextureRect = $"CanisterRect-2/Soap2"
@onready var soap_3: TextureRect = $"CanisterRect-3/Soap3"
@onready var soap_4: TextureRect = $"CanisterRect-4/Soap4"


func _ready() -> void:
	SystemEvents.update_compass.connect(_update_compass_arrow)
	SystemEvents.bubble_soap_collected.connect(_update_soap_ui)

func _update_compass_arrow(player: Node3D, dest_pos: Vector3):
	var direction = (dest_pos - player.global_transform.origin).normalized()
	var forward = -player.global_transform.basis.z.normalized()
	var angle = forward.angle_to(direction)
	var cross = forward.cross(direction).y
	if cross < 0:
		angle = -angle
	
	var tween = get_tree().create_tween()
	tween.tween_property(compassArrow, "rotation_degrees", -rad_to_deg(angle) - 90, 0.2)
	
	
func _update_soap_ui(soap_value: int) -> void:
	match SystemGlobals.soap_value:
		1:
			soap_1.visible = true
		2:
			soap_2.visible = true
		3:
			soap_3.visible = true
		4:
			soap_4.visible = true
		_:
			print("Impossible soap level wtf")
