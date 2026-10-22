# @tool
class_name MobileTouchButton extends TouchScreenButton

# const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 0.4)
# const PRESSED_COLOR = Color(0.2, 0.55, 1.0, 0.85)

# @export var target_radius: float = 32.0:
#     set(value):
#         target_radius = value
#         _update_button_bounds()
#         queue_redraw()

# @export var hide_background = false
# @export var icon: Texture2D:
#     set(value):
#         icon = value
#         var s = sprite_2d if sprite_2d else get_node_or_null("Sprite2D")
#         if s:
#             s.texture = value
#             _center_icon()

# @onready var sprite_2d = $Sprite2D

# func _ready() -> void:
#     pressed.connect(queue_redraw)
#     released.connect(queue_redraw)
#     _update_button_bounds()

#     if icon and sprite_2d:
#         sprite_2d.texture = icon
#         _center_icon()

# func _draw() -> void:
#     if not is_pressed() and hide_background:
#         return

#     # Spatial center is now Vector2.ZERO
#     var center = Vector2.ZERO
#     var color = PRESSED_COLOR if is_pressed() else NORMAL_COLOR

#     draw_circle(center, target_radius, color)
#     var border_color = Color(color.r, color.g, color.b, min(1.0, color.a + 0.2))
#     draw_arc(center, target_radius - 0.5, 0.0, TAU, 32, border_color, 1.0)

# func _update_button_bounds() -> void:
#     # 1. Create a virtual texture to activate the button's input grid
#     var diameter = target_radius * 2.0
#     var placeholder = PlaceholderTexture2D.new()
#     placeholder.size = Vector2(diameter, diameter)
#     texture_normal = placeholder

#     # 2. Let Godot natively center our shape directly over the placeholder
#     shape_centered = true

#     # 3. Create the shape zone matching your radius
#     var circle_shape = CircleShape2D.new()
#     circle_shape.radius = target_radius
#     shape = circle_shape

# func _center_icon() -> void:
#     if sprite_2d:
#         sprite_2d.position = Vector2.ZERO
#         sprite_2d.centered = true
