extends StaticBody2D

var parent: Node2D


func _ready():
    parent = get_parent()


func _hide_wall(hide: bool) -> void:
    if not parent:
        return

    if hide and get_parent():
        parent.remove_child(self)
    elif not hide and not get_parent():
        parent.add_child(self)
