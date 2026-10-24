class_name Character extends CharacterBody2D

signal died

const DIST = 16
const SPEED = 64
const JUMP = -250
const ROCK_SPEED_FACTOR = 0.5
# The amount of time the joystick must move in a horizontal
# direction before jumping off a ladder.
const LADDER_JUMP_OFF_TIME = 0.1
# The amount of time to wait before allowing the character
# to start climbing a ladder after they first press up on joystick
const CLIMB_DELAY = 0.1
# The amount of time after jumping off a ladder that it takes
# before gravity starts kicking in again.
const LADDER_GRAVITY_COOLDOWN = 0.1

var target_x = 0
var moving = true
var drag_pos = Vector2(0, 0)
var joystick: Vector2i = Vector2i(0, 0)
var joystick_finger_index: int = -1
var facing_direction = 1
var mouth_item = null

var overlapping_ladders: Array[Node2D] = []
var is_climbing: bool = false
var climb_exit_timer: float = 0.0
var climb_exit_dir: int = 0
var climb_cooldown: float = 0.0
var ladder_gravity_cooldown: float = 0.0

@onready var ray_cast = $RayCast2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D


func _ready() -> void:
    target_x = position.x
    animation_player.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
    var joystick_direction = _get_joystick_dir()

    if ladder_gravity_cooldown > 0.0:
        ladder_gravity_cooldown -= delta

    if (
        not is_climbing
        and not overlapping_ladders.is_empty()
    ):
        if abs(joystick_direction.y) > abs(joystick_direction.x):
            if climb_cooldown < CLIMB_DELAY:
                climb_cooldown += delta
            else:
                is_climbing = true
                climb_exit_timer = 0.0
                climb_exit_dir = 0
                var ladder = overlapping_ladders[-1]
                global_position.x = ladder.global_position.x
                velocity.x = 0
        else:
            climb_cooldown = 0
    else:
        climb_cooldown = 0
    
    if is_climbing:
        _process_climbing_physics(joystick_direction, delta)
    else:
        _process_normal_physics(joystick_direction, delta)


func _process_normal_physics(joystick_direction: Vector2, delta: float) -> void:
    set_target(joystick_direction.x)

    if not is_on_floor():
        play("jump")
    if ladder_gravity_cooldown <= 0.0:
        velocity += get_gravity() * delta
    move_and_slide()


func _process_climbing_physics(
    joystick_direction: Vector2i, delta: float
) -> void:
    if abs(joystick_direction.x) > abs(joystick_direction.y):
        if climb_exit_dir == joystick_direction.x:
            climb_exit_timer += delta
        else:
            climb_exit_dir = joystick_direction.x
            climb_exit_timer = delta

        if climb_exit_timer > LADDER_JUMP_OFF_TIME:
            is_climbing = false
            climb_exit_timer = 0.0
            climb_exit_dir = 0
            ladder_gravity_cooldown = LADDER_GRAVITY_COOLDOWN
            set_target(joystick_direction.x)
            move_and_slide()
            return
        velocity = Vector2.ZERO
        play("idle")
        move_and_slide()
        return

    climb_exit_timer = 0.0
    climb_exit_dir = 0

    velocity.y = joystick_direction.y * _get_speed()
    if velocity.y != 0:
        play("walk")
    else:
        play("idle")

    move_and_slide()


func enter_ladder(ladder: Node2D) -> void:
    if not overlapping_ladders.has(ladder):
        overlapping_ladders.append(ladder)


func exit_ladder(ladder: Node2D) -> void:
    overlapping_ladders.erase(ladder)
    if overlapping_ladders.is_empty() and is_climbing:
        is_climbing = false
        climb_exit_timer = 0.0
        climb_exit_dir = 0


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Jump") and not event.is_echo():
        jump()
    if event.is_action_pressed("Eat") and not event.is_echo():
        eat()
    
    if event is InputEventScreenTouch:
        if event.pressed:
            # Only start a new joystick track if we aren't already tracking a finger
            if joystick_finger_index == -1:
                joystick_finger_index = event.index
                drag_pos = event.position
        else:
            # Only clear the joystick if the finger lifting is the one WE are tracking
            if event.index == joystick_finger_index:
                joystick_finger_index = -1
                joystick = Vector2i.ZERO

    if event is InputEventScreenDrag:
        # Ignore any drag event that doesn't belong to our locked finger index
        if event.index == joystick_finger_index:
            joystick = Vector2i(event.position - drag_pos)


func set_target(dir):
    if dir < 0:
        sprite_2d.flip_h = false
        facing_direction = -1
    elif dir > 0:
        sprite_2d.flip_h = true
        facing_direction = 1

    if dir != 0:
        play("walk")
    else:
        play("idle")

    velocity.x = dir * _get_speed()

    if dir != 0:
        # If walking into a wall, jump
        ray_cast.target_position.x = abs(ray_cast.target_position.x) * dir
        ray_cast.force_raycast_update()
        if is_on_floor() and is_on_wall() and ray_cast.is_colliding():
            jump()


func jump() -> void:
    if is_on_floor():
        velocity.y += JUMP


func eat() -> void:
    var eat_pos = global_position + Vector2(facing_direction * 16.0, 0.0)

    # Already ate, spit it out
    if mouth_item and mouth_item.get("obj") != null:
        var obj = mouth_item.get("obj")
        if obj is Node2D:
            obj.global_position = eat_pos
            if obj.get_parent() == null:
                get_parent().add_child(obj)
        mouth_item = null
        _spawn_eat_circle(eat_pos, true)
        return

    # Attempting to eat
    _spawn_eat_circle(eat_pos, false)

    # Checking if there's anything to eat
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsPointQueryParameters2D.new()
    query.position = eat_pos
    query.collision_mask = 2
    query.collide_with_areas = true
    query.collide_with_bodies = true

    var results = space_state.intersect_point(query, 1)
    if not results.is_empty():
        var collider = results[0].collider
        if collider and collider.has_method("eat"):
            # Found an eatable, eating it
            var eaten_data = collider.eat()
            if (
                eaten_data is Dictionary
                and eaten_data.get("type", Eatable.NOTHING) != Eatable.NOTHING
            ):
                mouth_item = eaten_data
                return

    # Didn't find anything, play nothing to eat animation
    play("nothing_to_eat")


func _spawn_eat_circle(pos: Vector2, is_expand = false) -> void:
    var effect = EatEffect.new()
    effect.is_expand = is_expand
    effect.global_position = pos
    get_parent().add_child(effect)


func play(anim_name: StringName) -> void:
    if (
        (
            anim_name == &"idle"
            and animation_player.current_animation == &"nothing_to_eat"
        )
        or anim_name == animation_player.current_animation
    ):
        return
    animation_player.play("RESET")
    animation_player.advance(0)
    animation_player.play(anim_name)


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == &"nothing_to_eat":
        play("idle")


func _on_area_entered(_area: Area2D) -> void:
    died.emit()


func _on_body_entered(_body: Node2D) -> void:
    died.emit()


func _get_speed() -> float:
    if mouth_item and mouth_item.get("type") == Eatable.ROCK:
        return SPEED * ROCK_SPEED_FACTOR
    return SPEED

func _get_joystick_dir() -> Vector2i:
    var combined_joystick = joystick
    if Input.is_action_pressed("Left"):
        combined_joystick = Vector2i(-5, 0)
    elif Input.is_action_pressed("Right"):
        combined_joystick = Vector2i(5, 0)
    elif Input.is_action_pressed("Up"):
        combined_joystick = Vector2i(0, -5)
    elif Input.is_action_pressed("Down"):
        combined_joystick = Vector2i(0, 5)
        
    var horiz = combined_joystick.x
    var vert = combined_joystick.y
    var use_horiz = abs(horiz) >= abs(vert)
    return Vector2i(
        sign(horiz) if use_horiz else 0,
        sign(vert) if not use_horiz else 0,
    )
