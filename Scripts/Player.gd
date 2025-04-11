extends CharacterBody3D

# Weapon sway
@export var weapon_holder: Node3D
@export var weapon_sway_amount: float = 5
@export var weapon_rotation_amount: float = 1
@export var invert_weapon_sway: bool = false

# Stamina
@export var stamina = 10
@export var stamina_regen = 1
@export var stamina_use = 1

var speed
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 10.0
@export var CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 5.0
const SENSITIVITY = 0.002
var lerp_speed = 10

const mouse_sens = 0.25
var direction = Vector3.ZERO
var crouching_depth = -0.5
var feeelook_tilt = 5
var last_velocity = Vector3.ZERO

# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1

# States
var walking = false
var sprinting = false
var crouching = false
var freelooking = false
var sliding = true

var slidetimer = 0.0
var slidetimer_max = 1
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05
var head_bobbing_current_intensity = 0.0
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $neck/Head
@onready var eyes: Node3D = $neck/Head/eyes
@onready var camera = $neck/Head/eyes/Camera3D
@onready var neck: Node3D = $neck
@onready var standing_collison: CollisionShape3D = $standing_collison
@onready var crouching_collisons: CollisionShape3D = $crouching_collisons
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if freelooking:
			neck.rotate_y(-event.relative.x * SENSITIVITY)
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		sliding = false
		crouching = false


	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and !crouching and !sliding:
		velocity.y = JUMP_VELOCITY
		sliding = false
		crouching = false

	# Handle crouch and slide
	if Input.is_action_pressed("crouch") or sliding:
		speed = lerp(speed, CROUCH_SPEED, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * 15)
		standing_collison.disabled = true
		crouching_collisons.disabled = false

		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			crouching = true
			slidetimer = slidetimer_max
			slide_vector = input_dir
			freelooking = true

		walking = false
		sprinting = false
		crouching = true

	elif !ray_cast_3d.is_colliding():
		standing_collison.disabled = false
		crouching_collisons.disabled = true
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)

		# Sprint if stamina allows
		if Input.is_action_pressed("sprint") and stamina > 0:
			speed = lerp(speed, SPRINT_SPEED, delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			speed = WALK_SPEED
			walking = true
			sprinting = false
			crouching = false

	# Update freelook state
	if Input.is_action_pressed("free_look"):
		freelooking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
	else:
		freelooking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)

	# Head-bobbing logic
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta

	if is_on_floor() and !sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5

		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

	# Movement direction logic
	if is_on_floor():
		direction = lerp(direction, (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 3.0)

	if sliding:
		slidetimer -= delta
		if slidetimer <= 0:
			sliding = false
			freelooking = false

	# Update velocity based on movement direction
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# FOV logic
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

	# Stamina handling
	if sprinting and stamina > 0:
		stamina -= stamina_use * delta  # Decrease stamina while sprinting

	elif !sprinting and stamina < 10:
		stamina += stamina_regen * delta # Regenerate stamina when not sprinting

	# Prevent sprinting when stamina reaches 0
	if stamina <= 0:
		sprinting = false
		walking = true

	last_velocity = velocity
