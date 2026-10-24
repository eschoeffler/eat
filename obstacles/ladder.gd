@tool
class_name Ladder extends Area2D

@export var size: Vector2 = Vector2(16, 16):
    set(value):
        size = value
        if self.is_node_ready():
            _update_ladder()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
    _update_ladder()

    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    if not Engine.is_editor_hint():
        for body in get_overlapping_bodies():
            _on_body_entered(body)


func _update_ladder() -> void:
    var center_offset = Vector2(0, -size.y * 0.5)

    sprite_2d.region_rect = Rect2(0, 0, size.x, size.y)
    sprite_2d.position = center_offset

    if not collision_shape.shape:
        collision_shape.shape = RectangleShape2D.new()
    elif not collision_shape.shape.is_local_to_scene():
        collision_shape.shape = collision_shape.shape.duplicate()
    if collision_shape.shape is RectangleShape2D:
        collision_shape.shape.size = size
    collision_shape.position = center_offset


func _on_body_entered(body: Node2D) -> void:
    if body.has_method("enter_ladder"):
        body.enter_ladder(self)


func _on_body_exited(body: Node2D) -> void:
    if body.has_method("exit_ladder"):
        body.exit_ladder(self)
