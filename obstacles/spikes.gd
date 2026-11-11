@tool
extends StaticBody2D

@export var size: int = 1:
    set(value):
        size = value
        if self.is_node_ready():
            _update_size()
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
    _update_size()


func _update_size() -> void:
    var center_offset = Vector2(-size * 16 * 0.5, 0)

    sprite_2d.region_rect = Rect2(0, 0, size * 16, 1 * 16)
    sprite_2d.position = center_offset

    if not collision_shape.shape:
        collision_shape.shape = RectangleShape2D.new()
    elif not collision_shape.shape.is_local_to_scene():
        collision_shape.shape = collision_shape.shape.duplicate()
    if collision_shape.shape is RectangleShape2D:
        collision_shape.shape.size = Vector2(size * 16, 16)
    collision_shape.position = center_offset
