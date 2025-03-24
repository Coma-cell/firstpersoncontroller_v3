extends MeshInstance3D

var time_passed  = 0.0
onready var shader_material : ShaderMaterial = $Material

func _process(delta: float) -> void:
	time_passed += delta
	shader_material.set_shader_param("time", time_passed)
	shader_material.set_shader_param("impact_point", get_viewport().get_mouse_position())
	shader_material.set_shader_param("impact_radius", 1.0)
	shader_material.set_shader_param("wind_direction", Vector3(1.0, 0.0, 0.0))
	shader_material.set_shader_param("wind_strength", 0.5)
