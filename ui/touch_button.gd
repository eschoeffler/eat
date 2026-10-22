@tool
class_name MobileTouchButton extends TouchScreenButton

const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 0.4)
const PRESSED_COLOR = Color(0.2, 0.55, 1.0, 0.85)

# Use explicit export vectors since we lose Control Node layout settings
@export var target_radius: float = 16.0:
    set(value):
        target_radius = value
        queue_redraw()

@export var hide_background = false
@export var icon: Texture2D:
    set(value):
        icon = value
        var s = sprite_2d if sprite_2d else get_node_or_null("Sprite2D")
        if s:
            s.texture = value
            _center_icon()

@onready var sprite_2d = $Sprite2D


func _ready() -> void:
    pressed.connect(queue_redraw)
    released.connect(queue_redraw)

    if icon and sprite_2d:
        sprite_2d.texture = icon
        _center_icon()


func _draw() -> void:
    if not is_pressed() and hide_background:
        return

    # Since Node2D doesn't have a dynamic 'size', we use our target_radius instead
    var center = Vector2.ZERO  # (0,0) is now natively the center of our Node2D spatial coordinate
    var color = PRESSED_COLOR if is_pressed() else NORMAL_COLOR

    draw_circle(center, target_radius, color)
    var border_color = Color(color.r, color.g, color.b, min(1.0, color.a + 0.2))
    draw_arc(center, target_radius - 0.5, 0.0, TAU, 32, border_color, 1.0)


func _center_icon() -> void:
    if sprite_2d:
        # 1. Reset the sprite position to Vector2.ZERO so it aligns perfectly over our circle center
        sprite_2d.position = Vector2.ZERO
        # 2. Make sure the sprite's internal layout flag centers the texture pivot point
        sprite_2d.centered = true
