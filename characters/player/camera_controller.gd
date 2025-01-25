extends Marker3D


@export_group("Look Smoothing")
@export var smooth_look: bool = true
@export var look_smoothing: float = 20.0
@export var look_sensitivity: float = 0.005
@export var look_multiplier: float = 0.5

var input_look: Vector2 = Vector2.ZERO

var lock_view: bool = false

@onready var horizontal_marker: Marker3D = $HorizontalMarker
@onready var vertical_marker: Marker3D = $HorizontalMarker/VerticalMarker
@onready var camera: Camera3D = $HorizontalMarker/VerticalMarker/Camera


#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if lock_view:
		_handle_head_rotation(event)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("trigger_first_person_look"):
		lock_view = !lock_view
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	if lock_view:
		horizontal_marker.rotate_y(input_look.x)
		vertical_marker.rotate_x(input_look.y)
		
		vertical_marker.rotation.x = clamp(vertical_marker.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		camera.rotation.z = -input_look.x * 0.5
		
		horizontal_marker.rotation.y = wrapf(horizontal_marker.rotation.y, 0.0, TAU)
		
		if smooth_look:
			input_look = lerp(input_look, Vector2.ZERO, look_smoothing * delta)
		else:
			input_look = Vector2.ZERO
	if !lock_view:
		# Smoothly return all rotations to 0 when lock_view is false
		horizontal_marker.rotation.y = lerp_angle(horizontal_marker.rotation.y, 0.0, look_smoothing * delta)
		vertical_marker.rotation.x = lerp(vertical_marker.rotation.x, 0.0, look_smoothing * delta)
		camera.rotation.z = lerp(camera.rotation.z, 0.0, look_smoothing * delta)


func _handle_head_rotation(event: InputEvent):
	if event is InputEventMouseMotion:
		var relative = -event.relative
		if smooth_look:
			relative *= 0.5
			
		input_look += relative * look_sensitivity * look_multiplier
