extends Node2D


func _on_button_pressed(level: int) -> void:
    get_tree().change_scene_to_file("res://scenes/level" + str(level) + ".tscn")
