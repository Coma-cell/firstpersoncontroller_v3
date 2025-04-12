extends Label


var elapsed_time: float = 0

func _process(delta: float) -> void:
	elapsed_time += delta
	text = "REC : "+ str(round(elapsed_time)) 
