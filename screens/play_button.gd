extends Button

@export var hud: Control

func _on_pressed() -> void:
	SystemEvents.game_new_run_start_requested.emit()
	get_owner().hide()
	
	hud.show()
	await SystemEvents.game_loading_finished
