extends Node2D


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Menu"):
        get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_died() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_win() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
