extends Node3D

@export var swayLeft : Vector3
@export var swayRight : Vector3
@export var swayUp : Vector3
@export var swayDown : Vector3
@export var swayNormal : Vector3
@export var defaultRotation : Vector3 # New variable to store the default rotation
@export var maxHorizontalSway : float = 0.1 # Limiter for the maximum horizontal sway amount
@export var maxVerticalSway : float = 0.1 # Limiter for the maximum vertical sway amount

var mouseMovementY := 0
var mouseMovementX := 0
var swayThreshold := 7 # Adjust this value for more or less sensitivity
@export var swayLerp := 0.5  # Adjust this value for a smoother transition
@export var returnLerp := 1.0  # Higher value to return to default position faster

func _ready():
	defaultRotation = rotation # Store the initial rotation as the default

func _input(event):
	if event is InputEventMouseMotion:
		mouseMovementY = event.relative.y
		mouseMovementX = event.relative.x

func _physics_process(delta: float) -> void:
	if Global.input:
		var target_rotation = rotation
		
		if abs(mouseMovementY) > swayThreshold:
			if mouseMovementY > 0:
				target_rotation += swayLeft
			else:
				target_rotation += swayRight
				
		elif abs(mouseMovementX) > swayThreshold:
			if mouseMovementX > 0:
				target_rotation += swayUp
			else:
				target_rotation += swayDown
				
		else:
			target_rotation = defaultRotation # Reset to default when no significant movement
			rotation = rotation.lerp(target_rotation, returnLerp * delta)
			return

		# Apply the limiter to the target rotation
		target_rotation = clamp_rotation(target_rotation)
		
		# Lerp to the new rotation value
		rotation = rotation.lerp(target_rotation, swayLerp * delta)

func clamp_rotation(target_rotation: Vector3) -> Vector3:
	var limited_rotation = target_rotation
	
	# Limit the horizontal sway to the maximum horizontal sway amount
	limited_rotation.x = clamp(limited_rotation.x, defaultRotation.x - maxHorizontalSway, defaultRotation.x + maxHorizontalSway)
	limited_rotation.y = clamp(limited_rotation.y, defaultRotation.y - maxVerticalSway, defaultRotation.y + maxVerticalSway)
	limited_rotation.z = clamp(limited_rotation.z, defaultRotation.z - maxHorizontalSway, defaultRotation.z + maxHorizontalSway)
	
	return limited_rotation
