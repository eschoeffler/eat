class_name EatEffect extends Node2D

const MAX_RADIUS = 8.0
const MIN_RADIUS = 1.0
const DURATION = 0.10
const CIRCLE_COLOR = Color(1.0, 1.0, 1.0, 0.45)
const OUTLINE_COLOR = Color(0.85, 0.95, 1.0, 0.9)

var is_expand = false
var radius = 1.0:
	set(value):
		radius = value
		queue_redraw()


func _ready() -> void:
	var tween = create_tween()
	if is_expand:
		radius = MIN_RADIUS
		(
			tween
			. tween_property(self, "radius", MAX_RADIUS, DURATION)
			. set_trans(Tween.TRANS_QUAD)
			. set_ease(Tween.EASE_OUT)
		)
	else:
		radius = MAX_RADIUS
		(
			tween
			. tween_property(self, "radius", MIN_RADIUS, DURATION)
			. set_trans(Tween.TRANS_QUAD)
			. set_ease(Tween.EASE_IN)
		)
	tween.tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, CIRCLE_COLOR)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, OUTLINE_COLOR, 1.0)
