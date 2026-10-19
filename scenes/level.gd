extends Node2D

@onready var water = $Water


func _on_died() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_button_pressed(is_pressed: bool) -> void:
    if is_pressed:
        if water and water.get_parent():
            remove_child(water)
    else:
        if water and not water.get_parent():
            add_child(water)


func _on_win() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
