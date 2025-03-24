extends CenterContainer
@export var Dot_Radius : float = 1.0
@export var Dot_Color : Color =Color.WHITE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	draw_circle(Vector2(0,0),Dot_Radius,Dot_Color)
