extends Label
@export var color = Color(1.0,0.0,0.0,1.0)
@export var Font_Size = int(20)

func _process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second())
	set("theme_override_colors/font_color",color)
	$".".set("theme_override_font_sizes/font_size", Font_Size)
