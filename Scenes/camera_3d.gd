extends Camera3D

# Set the zoom step and limits
var zoom_step := 0.5
var min_zoom := 5.0
var max_zoom := 20.0

func _input(event):
	if Input.is_action_pressed("hold_zoom"):
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("zoom_in"):
				if fov > min_zoom:
					fov -= zoom_step
			elif Input.is_action_pressed("zoom_out"):
				if fov < max_zoom:
					fov += zoom_step

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	InputMap.add_action("hold_zoom")
	InputMap.action_add_event("hold_zoom", InputEventMouseButton.new())
	InputMap.action_get_event("hold_zoom").button_index = MOUSE_BUTTON_RIGHT

	InputMap.add_action("zoom_in")
	InputMap.action_add_event("zoom_in", InputEventMouseButton.new())
	InputMap.action_get_event("zoom_in").button_index = BUTTON_WHEEL_UP
	
	InputMap.add_action("zoom_out")
	InputMap.action_add_event("zoom_out", InputEventMouseButton.new())
	InputMap.action_get_event("zoom_out").button_index = BUTTON_WHEEL_DOWN
