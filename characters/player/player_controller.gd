extends Node3D

enum Transitions {
	TRANS_BACK,
	TRANS_BOUNCE,
	TRANS_CIRC,
	TRANS_CUBIC,
	TRANS_ELASTIC,
	TRANS_EXPO,
	TRANS_LINEAR,
	TRANS_QUAD,
	TRANS_QUART,
	TRANS_QUINT,
	TRANS_SINE,
}

enum Easings {
	EASE_IN,
	EASE_IN_OUT,
	EASE_OUT,
	EASE_OUT_IN,
}


@export_range(0.0, 1.0, 0.1) var transition_time = 0.3
@export var tween_trans: Tween.TransitionType
@export var use_tween_easing: bool = true
@export var tween_ease: Tween.EaseType
@export var cam_headbob: bool = true

var tween

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var front_ray_cast: RayCast3D = $RaysMarker/FrontRayCast
@onready var back_ray_cast: RayCast3D = $RaysMarker/BackRayCast
@onready var left_ray_cast: RayCast3D = $RaysMarker/LeftRayCast
@onready var right_ray_cast: RayCast3D = $RaysMarker/RightRayCast


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if tween is Tween:
		if tween.is_running():
			return
	
	_handle_direction()
	_handle_rotation()


func _handle_direction() -> void:
	if Input.is_action_pressed("forward") and not front_ray_cast.is_colliding():
		_move_direction(Vector3.FORWARD)
	if Input.is_action_pressed("back") and not back_ray_cast.is_colliding():
		_move_direction(Vector3.BACK)
	if Input.is_action_pressed("left") and not left_ray_cast.is_colliding():
		_move_direction(Vector3.LEFT)
	if Input.is_action_pressed("right") and not right_ray_cast.is_colliding():
		_move_direction(Vector3.RIGHT)


func _handle_rotation() -> void:
	if Input.is_action_pressed("rotate_right"):
		tween = create_tween().set_trans(tween_trans).set_ease(tween_ease)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, -PI / 2), transition_time)
	if Input.is_action_pressed("rotate_left"):
		tween = create_tween().set_trans(tween_trans).set_ease(tween_ease)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI / 2), transition_time)


func _move_direction(local_direction: Vector3) -> void:
	var global_direction = transform.basis * local_direction
	tween = create_tween().set_trans(tween_trans)
	if use_tween_easing == true:
		tween.set_ease(tween_ease)
	tween.tween_property(self, "transform", transform.translated(global_direction * 1), transition_time)
	if cam_headbob:
		animation_player.play("headbob")
		
