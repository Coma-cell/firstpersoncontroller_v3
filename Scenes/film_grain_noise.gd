extends TextureRect
@onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture.noise.seed=rng.randi()
	texture.noise.seed=rng.randi()
