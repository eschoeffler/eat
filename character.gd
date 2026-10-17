class_name Character extends CharacterBody2D

const DIST = 16
const SPEED = 64
const JUMP = -200

var target_x = 0
var moving = true
var drag_pos = Vector2(0, 0)
var joystick = Vector2(0, 0)

@onready var ray_cast = $RayCast2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D


func _ready() -> void:
    target_x = position.x


func _physics_process(delta: float) -> void:
    if Input.is_action_pressed("Left") or joystick.x < -5:
        set_target(-1)
    elif Input.is_action_pressed("Right") or joystick.x > 5:
        set_target(1)
    else:
        set_target(0)

    if not is_on_floor():
        animation_player.play("jump")
    velocity += get_gravity() * delta
    move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            drag_pos = event.position
        else:
            joystick = Vector2.ZERO
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            drag_pos = event.position
        else:
            drag_pos = null
            joystick = Vector2.ZERO
    if (
        (event is InputEventScreenDrag or event is InputEventMouseMotion)
        and drag_pos
    ):
        joystick = event.position - drag_pos


func set_target(dir):
    if dir < 0:
        sprite_2d.flip_h = false
    if dir > 0:
        sprite_2d.flip_h = true
    if dir != 0:
        animation_player.play("walk")
    else:
        animation_player.play("idle")
    velocity.x = dir * SPEED
    if dir != 0:
        # If walking into a wall, jump
        ray_cast.target_position.x = abs(ray_cast.target_position.x) * dir
        ray_cast.force_raycast_update()
        if is_on_floor() and is_on_wall() and ray_cast.is_colliding():
            jump()


func jump() -> void:
    if is_on_floor():
        velocity.y += JUMP

