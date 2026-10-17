class_name Character extends CharacterBody2D

const DIST = 16
const SPEED = 64
const JUMP = -200
const ROCK_SPEED_FACTOR = 0.5

var target_x = 0
var moving = true
var drag_pos = Vector2(0, 0)
var joystick = Vector2(0, 0)
var facing_direction = 1
var mouth_item = null

@onready var ray_cast = $RayCast2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D


func _ready() -> void:
	target_x = position.x
	animation_player.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Left") or joystick.x < -5:
		set_target(-1)
	elif Input.is_action_pressed("Right") or joystick.x > 5:
		set_target(1)
	else:
		set_target(0)

	if not is_on_floor():
		play("jump")
	velocity += get_gravity() * delta
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump") and not event.is_echo():
		jump()
	if event.is_action_pressed("Eat") and not event.is_echo():
		eat()
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
		facing_direction = -1
	elif dir > 0:
		sprite_2d.flip_h = true
		facing_direction = 1

	if dir != 0:
		play("walk")
	else:
		play("idle")

	var current_speed = SPEED
	if mouth_item and mouth_item.get("type") == Eatable.ROCK:
		current_speed = SPEED * ROCK_SPEED_FACTOR
	velocity.x = dir * current_speed

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
