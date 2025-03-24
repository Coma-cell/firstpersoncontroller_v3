extends Node3D
var walking = false
var blend_amount := 0.0
@export var zoom_in : StringName = "zoom_in"
@export var zoom_out : StringName = "zoom_out"
@export var spotlight : StringName = "Shoulder_light"
@export var angle_step : float = 3
@export var power_step : float = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	walking = Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")

	if walking:
		var target_blend := 1.0
		if Input.is_action_pressed("sprint"):
			target_blend = 2.0
		blend_amount = lerp(blend_amount, target_blend, 0.1)  # Smoothly transition to target blend amount
	else:
		blend_amount = lerp(blend_amount, 0.0, 0.1)  # Smoothly transition to idle

	$Skeleton3D/AnimationTree.set("parameters/idle_to_walk/blend_amount", blend_amount)
	if Input.is_action_just_pressed("zoom_in"):
		adjust_spotlight_angle(-angle_step)
		adjust_spotlight_power(power_step)
	elif Input.is_action_just_pressed("zoom_out"):
		adjust_spotlight_angle(angle_step)
		adjust_spotlight_power(-power_step)

func adjust_spotlight_angle(step: float) -> void:
	var light = $Skeleton3D/flashlight_attachment/flashlight/Shoulder_light
	if light:
		light.spot_angle = clamp(light.spot_angle + step, 15, 30)  # Adjust the clamp values as needed
		
func adjust_spotlight_power(step: float) -> void:
	var light = $Skeleton3D/flashlight_attachment/flashlight/Shoulder_light
	if light:
		light.spot_range = clamp(light.spot_range + step, 15, 30)  # Adjust the clamp values as needed
