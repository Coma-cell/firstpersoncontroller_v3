extends Node3D

var idle_to_walk_blend_amount: float = 0.0
var idleorwalk_to_shooting_blend_amount: float = 0.0
var is_shooting: bool = false
var is_reloading: bool = false
var reload_time: float = 2.0
var reload_timer: float = 0.0
var is_moving: bool = false
var shooting_duration: float = 1.0333  # Duration of the shooting animation
var shooting_timer: float = 0.0
var shoot_key_pressed: bool = false

func _ready():
	$AnimationTree.active = true
	print("Ready")

func _process(delta):
	update_movement(delta)
	update_shooting(delta)

func update_movement(delta):
	if not is_shooting and not is_reloading:
		is_moving = Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")
		idle_to_walk_blend_amount = lerp(idle_to_walk_blend_amount, 1.1 if Input.is_action_pressed("sprint") else 0.6 if is_moving else 0.0, delta * 5.0)
		$AnimationTree.set("parameters/idle_to_walk/blend_amount", idle_to_walk_blend_amount)

func update_shooting(delta):
	if Input.is_action_just_pressed("shoot") and not shoot_key_pressed and not is_reloading and not is_shooting:
		print("Shoot action detected")
		is_shooting = true
		shoot_key_pressed = true
		shooting_timer = shooting_duration
		idleorwalk_to_shooting_blend_amount = 1.0
		$AnimationTree.set("parameters/idleorwalk_to_shoot/blend_amount", idleorwalk_to_shooting_blend_amount)
		$AnimationPlayer.play("shooting")  # Play the shooting animation from the beginning
	elif not Input.is_action_pressed("shoot"):
		shoot_key_pressed = false

	if is_shooting:
		shooting_timer -= delta
		if shooting_timer <= 0:
			is_shooting = false
			shooting_timer = shooting_duration
			idleorwalk_to_shooting_blend_amount = 0.0
		idleorwalk_to_shooting_blend_amount = lerp(idleorwalk_to_shooting_blend_amount, 0.0 if not is_shooting else 1.0, delta * 5.0)
		$AnimationTree.set("parameters/idleorwalk_to_shoot/blend_amount", idleorwalk_to_shooting_blend_amount)
	else:
		idleorwalk_to_shooting_blend_amount = lerp(idleorwalk_to_shooting_blend_amount, 0.0, delta * 5.0)
		$AnimationTree.set("parameters/idleorwalk_to_shoot/blend_amount", idleorwalk_to_shooting_blend_amount)
