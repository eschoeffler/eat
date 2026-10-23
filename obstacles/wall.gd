extends StaticBody2D

var parent: Node2D

func _ready() -> void:
    parent = get_parent()

func _hide_wall(is_pressed: bool) -> void:
    if is_pressed:
        parent.remove_child(self)
    else:
        parent.add_child(self)
    
