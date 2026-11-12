extends Sprite2D

var time: float = 0.0

func _process(delta: float) -> void:
    time += delta * 3.0
    scale = Vector2.ONE * (1.5 + 0.5 * sin(time))
