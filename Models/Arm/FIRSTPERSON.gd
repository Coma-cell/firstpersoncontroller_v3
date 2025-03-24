extends Node3D

var animator : AnimationTree
var walking : bool = false
var blend_amount : float = 0.0
var blend_speed : float = 5.0

func _ready() -> void:
	animator = $AnimationTree

func _process(delta: float) -> void:
	var target_blend : float = 0.0

	if Input.is_action_pressed("up"):
		if Input.is_action_pressed("sprint"):
			target_blend = 0.2
		else:
			target_blend = 0.1
		walking = true
	else:
		walking = false

	blend_amount = lerp(blend_amount, target_blend, blend_speed * delta)
	animator.set("parameters/idle_to_walk/blend_amount", blend_amount)
