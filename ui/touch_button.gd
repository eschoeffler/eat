@tool
class_name TouchButton extends Control

signal pressed
signal button_down
signal button_up

const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 0.4)
const PRESSED_COLOR = Color(0.2, 0.55, 1.0, 0.85)

@export var action = ""
@export var hide_background = false
@export var icon: Texture2D:
    set(value):
        icon = value
        var s = sprite_2d if sprite_2d else get_node_or_null("Sprite2D")
        if s:
            s.texture = value

var is_pressed = false
var touch_index = -1

@onready var sprite_2d = $Sprite2D


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    sprite_2d.texture = icon
    sprite_2d.position = size / 2.0


func _draw() -> void:
    if not is_pressed and hide_background:
        return
    var center = size / 2.0
    var radius = min(size.x, size.y) / 2.0
    var color = PRESSED_COLOR if is_pressed else NORMAL_COLOR
    draw_circle(center, radius, color)
    var border_color = Color(color.r, color.g, color.b, min(1.0, color.a + 0.2))
    draw_arc(center, radius - 0.5, 0.0, TAU, 32, border_color, 1.0)


func _gui_input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return
    if (
        event is InputEventMouseButton
        and event.button_index == MOUSE_BUTTON_LEFT
    ):
        if event.pressed:
            if not is_pressed:
                _set_pressed(true)
                button_down.emit()
                pressed.emit()
                _trigger_action()
        else:
            if is_pressed:
                _set_pressed(false)
                button_up.emit()
        accept_event()
    elif event is InputEventScreenTouch:
        if event.pressed:
            if not is_pressed:
                touch_index = event.index
                _set_pressed(true)
                button_down.emit()
                pressed.emit()
                _trigger_action()
        else:
            if is_pressed and (touch_index == -1 or event.index == touch_index):
                touch_index = -1
                _set_pressed(false)
                button_up.emit()
        accept_event()
    elif event is InputEventScreenDrag and is_pressed:
        if touch_index == -1 or event.index == touch_index:
            var center = size / 2.0
            var radius = min(size.x, size.y) / 2.0
            if (event.position - center).length() > radius + 8.0:
                touch_index = -1
                _set_pressed(false)
                button_up.emit()
        accept_event()
    elif event is InputEventMouseMotion and is_pressed:
        var center = size / 2.0
        var radius = min(size.x, size.y) / 2.0
        if (event.position - center).length() > radius + 8.0:
            _set_pressed(false)
            button_up.emit()


func _set_pressed(value: bool) -> void:
    if is_pressed != value:
        is_pressed = value
        queue_redraw()


func _trigger_action() -> void:
    var ev = InputEventAction.new()
    ev.action = action
    ev.pressed = true
    Input.parse_input_event(ev)
