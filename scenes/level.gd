extends Node2D


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Menu"):
        get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_died() -> void:
    call_deferred("_go_to_menu")


func _on_win() -> void:
    call_deferred("_go_to_menu")

func _go_to_menu():
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
