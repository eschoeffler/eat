extends Area2D

signal win


func _on_body_entered(body: Node2D) -> void:
    print(body)
    if body is Character:
        win.emit()
