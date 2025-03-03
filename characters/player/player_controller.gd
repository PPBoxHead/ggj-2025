extends Node3D

@export_range(0.0, 1.0, 0.1) var transition_time = 0.3
@export var tween_trans: Tween.TransitionType
@export var use_tween_easing: bool = true
@export var tween_ease: Tween.EaseType
@export var cam_headbob: bool = true

var tween
var lock_input: bool = false
var can_interact: bool = false
var interactable_npc: Node3D = null

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var head_marker: Marker3D = $HeadMarker

@onready var front_ray_cast: RayCast3D = $RaysMarker/FrontRayCast
@onready var back_ray_cast: RayCast3D = $RaysMarker/BackRayCast
@onready var left_ray_cast: RayCast3D = $RaysMarker/LeftRayCast
@onready var right_ray_cast: RayCast3D = $RaysMarker/RightRayCast

@export var steps_sfx: Array[AudioStream]

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()


func _physics_process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact") and interactable_npc != null:
		if Dialogic.current_timeline != null:
			return
		var npc_timeline = interactable_npc.name.to_lower() + "_timeline" as Variant
		Dialogic.start(npc_timeline)
	
	if tween is Tween:
		if tween.is_running():
			return
	
	if lock_input: return
	
	if !head_marker.lock_view:
		_handle_direction()
		_handle_rotation()


func _handle_direction() -> void:
	if Input.is_action_pressed("forward") and not front_ray_cast.is_colliding():
		_move_direction(Vector3.FORWARD)
	if Input.is_action_pressed("back") and not back_ray_cast.is_colliding():
		_move_direction(Vector3.BACK)
	#if Input.is_action_pressed("left") and not left_ray_cast.is_colliding():
		#_move_direction(Vector3.LEFT)
	#if Input.is_action_pressed("right") and not right_ray_cast.is_colliding():
		#_move_direction(Vector3.RIGHT)


func _handle_rotation() -> void:
	if Input.is_action_pressed("right"):
		tween = create_tween().set_trans(tween_trans).set_ease(tween_ease)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, -PI / 2), transition_time)
	if Input.is_action_pressed("left"):
		tween = create_tween().set_trans(tween_trans).set_ease(tween_ease)
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI / 2), transition_time)
	_get_closest_enemy()
	_get_closest_npc()


func _move_direction(local_direction: Vector3) -> void:
	var global_direction = transform.basis * local_direction
	tween = create_tween().set_trans(tween_trans)
	if use_tween_easing == true:
		tween.set_ease(tween_ease)
	tween.tween_property(self, "transform", transform.translated(global_direction * 1), transition_time)
	if cam_headbob:
		animation_player.play("headbob")
		
	var rand_num = rng.randi_range(0, steps_sfx.size() - 1)
	audio_player.stream = steps_sfx[rand_num]
	audio_player.play()
	_get_closest_enemy()
	_get_closest_npc()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("target"):
		lock_input = true
		SystemEvents.start_combat.emit(area.get_parent())
	if area.get_parent().is_in_group("npc"):
		can_interact = true
		interactable_npc = area.get_parent()


func _get_closest_enemy() -> void:
	var closest_distance: float = INF
	var closest_node: Node3D = null
	
	var enemies_list = get_parent().get_node("Enemies").get_children()
	
	if enemies_list.size() == 0:
		closest_node = get_parent().get_node("ThisNodeIsTheEnd")
	else:
		for enemy: Node3D in enemies_list:
			var dist: float = self.global_position.distance_to(enemy.global_position)
			if dist <= closest_distance:
				closest_distance = dist
				closest_node = enemy
			
	SystemEvents.update_compass.emit(self, closest_node.global_position)

func _get_closest_npc() -> void:
	var closest_distance: float = INF
	var closest_node: Node3D = null
	
	var npc_list = get_parent().get_node("NPCs").get_children()
	
	if npc_list.size() == 0:
		return
	
	for npc: Node3D in npc_list:
		var dist: float = self.global_position.distance_to(npc.global_position)
		if dist <= closest_distance:
			closest_distance = dist
			closest_node = npc
			
	SystemEvents.update_npc_compass.emit(self, closest_node.global_position)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("target"):
		lock_input = false
	if area.get_parent().is_in_group("npc"):
		can_interact = false
		interactable_npc = null
	if area.get_parent().is_in_group("final_weapon") and SystemGlobals.soap_value == SystemGlobals.MAX_SOAP_VALUE:
		SystemEvents.game_run_finished.emit()
		
