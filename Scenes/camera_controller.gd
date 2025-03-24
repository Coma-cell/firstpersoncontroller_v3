extends Camera3D

# Set the zoom step and limits
var zoom_step := 5
var min_zoom := 5.0
var max_zoom := 20.0

func _input(event):
	if Input.is_action_pressed("zoom"):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and fov > min_zoom:
				fov -= zoom_step
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and fov < max_zoom:
				fov += zoom_step

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	InputMap.add_action("zoom")
	var hold_zoom_event = InputEventMouseButton.new()
	hold_zoom_event.button_index = MOUSE_BUTTON_RIGHT
	InputMap.action_add_event("zoom", hold_zoom_event)
