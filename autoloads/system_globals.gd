extends Node


# Loading public variables
var current_scene_path: String
var current_scene: Node3D

var game_can_process: bool = false

var current_day_count: int = 0

# Loading private variables
var _load_time: float = 0.0
var _loading_started: bool = false
var _max_load_time: float = 10000.0
var _status_progress: Array = []

@onready var main: Node = get_tree().get_root().get_node_or_null("Main")
@onready var game_viewport: SubViewport = get_tree().get_root().get_node_or_null("Main/GameViewportContainer/GameViewport")

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _enter_tree() -> void:
	randomize()


func _ready() -> void:
	SystemEvents.game_new_run_start_requested.connect(_game_start_new_run)


func _game_start_new_run() -> void:
	current_day_count = 0
	
	_scene_load_from_path("res://testing/test_scene.tscn", null)


func _scene_load_from_path(scene_path: String, _cur_scene: Node = null) -> void:
	if _loading_started == true:
		print("A scene is already loading... coming back while the scene is loaded")
		return
	
	game_can_process = false
	
	var loader = ResourceLoader.load_threaded_request(scene_path)
	
	if loader != OK:
		print("ResourceLoader unable to load resource from path")
		return
	
	_load_time = Time.get_ticks_msec()
	
	_loading_started = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	get_tree().paused = true
	SystemEvents.game_loading_started.emit()
	
	while Time.get_ticks_msec() - _load_time < _max_load_time:
		var status = ResourceLoader.load_threaded_get_status(scene_path, _status_progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			# If loading completed
			var resource = ResourceLoader.load_threaded_get(scene_path)
			var instanced_scene = resource.instantiate()
			
			game_viewport.call_deferred("add_child", instanced_scene)
			if _cur_scene != null:
				_cur_scene.queue_free()
				_cur_scene = instanced_scene
				print("the new current scene is took from: ", _cur_scene.scene_file_path)
			if _cur_scene == null:
				if not game_viewport.get_children().is_empty():
					print("there's a child on main, but current scene was not set on load... deleting main child")
					game_viewport.get_child(0).queue_free()
					_cur_scene = instanced_scene
					print("the new current scene is took from: ", _cur_scene.scene_file_path)
				else:
					print("the current scene is null... assigning a new one once loading from the path is finished")
					_cur_scene = instanced_scene
					print("now it will be from: ", _cur_scene.scene_file_path)
			current_scene = _cur_scene
			current_scene_path = current_scene.scene_file_path
			
			_loading_started = false
			get_tree().paused = false
			_load_time = 0.0
			
			game_can_process = true
			
			animation_player.play_backwards("fade")
			await animation_player.animation_finished
			SystemEvents.game_loading_finished.emit()
			break
		
		elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Stills loading
			var _progress = ResourceLoader.load_threaded_get_status(scene_path, _status_progress)
			print("progress is... ", _status_progress[0])
		else:
			print("an error happened trying to load the desired scene :c")
			get_tree().quit()
			break
		
		await get_tree().process_frame
	
	if _load_time >= _max_load_time:
		print("an error happened trying to load the desired scene :c")
		get_tree().quit()
