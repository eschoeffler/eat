extends Node2D

var _transitioning: bool = false


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Menu"):
        _go_to_menu()


func _on_died() -> void:
    if _transitioning:
        return
    _transitioning = true
    call_deferred("_go_to_menu")


func _on_win() -> void:
    if _transitioning:
        return
    _transitioning = true
    call_deferred("_go_to_menu")


func _go_to_menu() -> void:
    if not is_inside_tree() or get_tree() == null:
        return
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
