extends Node2D


var wait: float = 0.1
var screen_size: Vector2

@export var nrows: int = 16
@export var nballs: int = 500
@export var nsticks: int = 12
@export var bounce: float = 0.0
@export var gravity: float = 0.1
@onready var pin_scene: PackedScene = preload("res://scenes/pin.tscn")
@onready var ball_scene: PackedScene = preload("res://scenes/ball.tscn")
@onready var stick_scene: PackedScene = preload("res://scenes/stick.tscn")


func _ready() -> void:
	screen_size = get_viewport_rect().size
	add_pins()
	add_sticks()
	add_balls()

func add_pins():
	# Region for pins.
	var row_start := 0.3 * screen_size.y
	var row_end := 0.7 * screen_size.y
	
	# Pin spacing.
	var row_space: float = 2.0 * (row_end - row_start)/(nrows - 1)
	var col_space: float = row_space
	var ncols: int = int(screen_size.x/col_space)
	var initial_space := screen_size.x/30.0
	
	# Adjustment so the set of pins are centered.
	var last_col_space: float = screen_size.x - (initial_space + ncols * col_space)
	var adjust: float = (initial_space - last_col_space)/2.0
	
	# Add pins in their positions.
	for i in nrows:
		var row_pos = row_start + i * row_space/2.0
		
		for j in ncols + 1:
			var col_pos: float
			if i % 2 == 0:
				col_pos = initial_space + j * col_space - adjust
			else:
				col_pos = initial_space + (j + 0.5) * col_space - adjust
			var pin_instance = pin_scene.instantiate()
			pin_instance.position = Vector2(col_pos, row_pos)
			add_child(pin_instance)
			
func remove_pins():
	get_tree().call_group("pin", "queue_free")
			
func add_sticks():
	# Stick spacing.
	var col_space: float = screen_size.x/nsticks
	var y_pos := 0.875 * screen_size.y
	var initial_space := screen_size.x/10.0
	
	# Adjustment so the set of sticks are centered.
	var last_col_space: float = screen_size.x - (initial_space + (nsticks - 1) * col_space)
	var adjust: float = (initial_space - last_col_space)/2.0
	
	# Add sticks in their positions.
	for j in nsticks:
		var col_pos = initial_space + j * col_space - adjust
		var stick_instance = stick_scene.instantiate()
		stick_instance.position = Vector2(col_pos, y_pos)
		add_child(stick_instance)
		move_child(stick_instance, 1)
		
func remove_sticks():
	get_tree().call_group("stick", "queue_free")
		
func add_balls():
	for i in nballs:
		await get_tree().create_timer(wait, false).timeout
		var ball_instance = ball_scene.instantiate()
		ball_instance.position = Vector2(randf_range(0, screen_size.x), -250.0)
		ball_instance.gravity_scale = gravity
		ball_instance.physics_material_override.bounce = bounce
		add_child(ball_instance)

func _on_hud_gravity(value: float) -> void:
	gravity = value
	get_tree().set_group("ball", "gravity_scale", value)
	$HUD/FoldableContainer/Parameters/Gravity/Label.text = "Gravity = " + str(value)

func _on_hud_bounce(value: float) -> void:
	bounce = value
	get_tree().set_group("ball", "bounce", value)
	$HUD/FoldableContainer/Parameters/Bounce/Label.text = "Bounce = " + str(value)

func _on_hud_pins(value: int) -> void:
	nrows = value
	remove_pins()
	add_pins()
	$HUD/FoldableContainer/Parameters/Pins/Label.text = "Pins = " + str(value) + " rows"

func _on_hud_sticks(value: int) -> void:
	nsticks = value
	remove_sticks()
	add_sticks()
	$HUD/FoldableContainer/Parameters/Sticks/Label.text = "Sticks = " + str(value)

func _on_hud_background(value: int) -> void:
	for i in [1, 2, 3, 4, 5, 6]:
		get_node("Background/SubViewportContainer/SubViewport/BG%d" % i).visible = (i == value)

func _on_hud_about(value: Color) -> void:
	modulate = value
