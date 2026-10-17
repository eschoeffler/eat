extends Node2D


func _on_died() -> void:
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
