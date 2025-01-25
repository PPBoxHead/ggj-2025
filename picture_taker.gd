extends Node

enum FileTags {
	DATETIME,
	UNIX_TIMESTAMP
}

@export var shortcut_action = "ui_focus_next":
	set = set_shortcut_action
@export var file_prefix = "test_pic"
@export var file_tag: FileTags = FileTags.UNIX_TIMESTAMP
@export_dir var output_path = "res://debug_pics":
	set = set_output_path

var _tag = ""
var _index = 0


func _ready():
	if !OS.is_debug_build():
		print("This is a full executable build, the tools for debug will be deleted.")
		self.queue_free()
	
	_check_actions([shortcut_action])
	_check_path(output_path)
	
	if not output_path[-1] == "/":
		output_path += "/"
	if not file_prefix.is_empty():
		file_prefix += "_"
	set_process_input(true)


func _input(event):
	if event.is_action_pressed(shortcut_action):
		make_screenshot()


func make_screenshot():
	var frame_viewport = RenderingServer.viewport_create()
	RenderingServer.viewport_set_clear_mode(frame_viewport, RenderingServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	RenderingServer.free_rid(frame_viewport)
	var image = get_viewport().get_texture().get_image()
#	image.flip_y()
	
	_update_tags()
	
	
	image.save_png("%s%s%s_%s.png" % [output_path, file_prefix, _tag, _index])
	print("image taken and saved at: %s%s%s_%s.png" % [output_path, file_prefix, _tag, _index])


func _check_actions(actions=[]):
	if OS.is_debug_build():
		var message = 'WARNING: No action "%s"'
		for action in actions:
			if not InputMap.has_action(action):
				print(message % action)
				#breakpoint


func _check_path(path):
	if OS.is_debug_build():
		var message = 'WARNING: No directory "%s"'
		var dir = DirAccess.open("res://")
		dir.make_dir("debug_pics")
		DirAccess.open(path)
		if not dir.dir_exists(path):
			print(message % path)
			#breakpoint


func _update_tags():
	var time
	var time_dic: Dictionary = {
		"year": "",
		"month": "",
		"day": "",
		"hour": "",
		"minute": "",
		"second": "",
	}
	if (file_tag == 1): time = str(Time.get_unix_time_from_system())
	else:
		time = Time.get_datetime_string_from_datetime_dict(time_dic, false)
		time = "%s_%02d_%02d_%02d%02d%02d" % [time['year'], time['month'], time['day'], 
											time['hour'], time['minute'], time['second']]
	if (_tag == time): _index += 1
	else:
		_index = 0
	_tag = time


func set_shortcut_action(action):
	_check_actions([action])
	shortcut_action = action


func set_output_path(path):
	_check_path(path)
	output_path = path
