extends StaticBody2D


func _ready() -> void:
	add_to_group("stick")
	$Body.material = $Body.material.duplicate()
	$Body.material.set_shader_parameter("seed", randf_range(1.0, 2.0) * float(abs(name.hash()) % 10000))
