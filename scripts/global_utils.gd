extends Node

func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("meta_screenshot"):
		_take_screenshot()
	if ev.is_action_pressed("meta_fullscreen"):
		_toggle_fullscreen()

	if OS.is_debug_build() and ev.is_action_pressed("dev_quit"):
		get_tree().quit()

func _take_screenshot():
	var capture = get_viewport().get_texture().get_image()
	var _time = Time.get_datetime_string_from_system()
	var filename = "user://screenshot_{0}.png".format({"0":_time.replace(":","-")})
	capture.save_png(filename)

func _toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
