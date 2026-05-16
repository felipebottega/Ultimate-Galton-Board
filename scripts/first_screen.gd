extends Node2D


var time: float = 0.0

@onready var label := $CanvasLayer/Label


func _ready() -> void:
	$CanvasLayer/Label2.text = "v" + ProjectSettings.get_setting("application/config/version")

func _physics_process(delta: float) -> void:
	time += 2*delta
	label.modulate.a = sin(time)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		$CanvasLayer.hide()
		get_tree().change_scene_to_file("res://main.tscn")

func _on_full_screen_pressed() -> void:
	if DisplayServer.window_get_mode() != 4:
		DisplayServer.window_set_mode(4)
	else:
		DisplayServer.window_set_mode(0)
		
