extends StaticBody2D

signal pressed(is_pressed: bool)

var nodes_above: Array[Node2D] = []

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer


func _ready() -> void:
    _update_pressed()


func _set_pressed(is_pressed: bool):
    if is_pressed:
        animation_player.play("pressed")
    else:
        animation_player.play("not_pressed")
    pressed.emit(is_pressed)


func _add_weight(body: Node2D):
    nodes_above.append(body)
    _update_pressed()


func _remove_weight(body: Node2D):
    nodes_above.erase(body)
    _update_pressed()


func _update_pressed() -> void:
    _set_pressed(nodes_above.size() > 0)
