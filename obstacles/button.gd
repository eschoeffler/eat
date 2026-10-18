extends StaticBody2D

signal pressed(is_pressed: bool)

const BUTTON_PRESS_DEBOUNCE = 0.1

@export var weight_threshold: int = 1

var _is_pressed = false
var _unpress_timer: SceneTreeTimer = null
var _press_timer: SceneTreeTimer = null

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var top_area = $Top


func _physics_process(_delta: float) -> void:
    _update_pressed()


# Kept for .tscn signal connections (polling handles detection now)
func _add_weight(_body: Node2D):
    pass


func _remove_weight(_body: Node2D):
    pass


func _set_pressed(new_pressed: bool):
    if new_pressed == _is_pressed:
        return
    _is_pressed = new_pressed
    if new_pressed:
        animation_player.play("pressed")
    else:
        animation_player.play("not_pressed")
    pressed.emit(new_pressed)


func _update_pressed() -> void:
    var total_weight = _get_total_weight()
    if total_weight >= weight_threshold:
        # Debounce: wait 100ms before pressing
        _unpress_timer = null
        if _press_timer == null:
            _press_timer = get_tree().create_timer(BUTTON_PRESS_DEBOUNCE)
            _press_timer.timeout.connect(_on_press_timeout)
    elif _is_pressed:
        # Debounce: wait 100ms before unpressing
        _press_timer = null
        if _unpress_timer == null:
            _unpress_timer = get_tree().create_timer(BUTTON_PRESS_DEBOUNCE)
            _unpress_timer.timeout.connect(_on_unpress_timeout)


func _get_total_weight() -> int:
    var total_weight = 0
    for body in top_area.get_overlapping_bodies():
        if body.has_method("get_weight"):
            total_weight += body.get_weight()
        else:
            total_weight += 1
    return total_weight


func _on_press_timeout() -> void:
    _press_timer = null
    if _get_total_weight() >= weight_threshold:
        _set_pressed(true)


func _on_unpress_timeout() -> void:
    _unpress_timer = null
    if _get_total_weight() < weight_threshold:
        _set_pressed(false)
