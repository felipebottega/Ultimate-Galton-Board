extends CanvasLayer


var reading_about: bool = false

signal pins(value: int)
signal sticks(value: int)
signal about(value: Color)
signal bounce(value: float)
signal gravity(value: float)
signal background(value: int)


func _unhandled_input(event: InputEvent) -> void:
	if reading_about and event.is_pressed():
		reading_about = false
		$FoldableContainer.show()
		$FoldableContainer2.show()
		$AboutContent.hide()
		get_tree().paused = false
		about.emit(Color(1.0, 1.0, 1.0))

func _on_gravity_value_changed(value: float) -> void:
	gravity.emit(value)

func _on_bounce_value_changed(value: float) -> void:
	bounce.emit(value)

func _on_pins_value_changed(value: float) -> void:
	pins.emit(value)

func _on_sticks_value_changed(value: float) -> void:
	sticks.emit(value)

func _on_reset_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_pause_pressed() -> void:
	if get_tree().paused:
		$FoldableContainer2/Options/Pause.text = "Pause"
		get_tree().paused = false
	else:
		$FoldableContainer2/Options/Pause.text = "Play"
		get_tree().paused = true

func _on_background_item_selected(index: int) -> void:
	background.emit(index + 1)

func _on_about_pressed() -> void:
	reading_about = true
	$FoldableContainer.hide()
	$FoldableContainer2.hide()
	$AboutContent.show()
	about.emit(Color(0.2, 0.2, 0.2))
	get_tree().paused = true

func _on_about_content_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_full_screen_pressed() -> void:
	if DisplayServer.window_get_mode() != 4:
		DisplayServer.window_set_mode(4)
	else:
		DisplayServer.window_set_mode(0)
		
