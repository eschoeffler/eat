class_name Character extends CharacterBody2D

@onready var rayCast = $RayCast2D
@onready var animationPlayer = $AnimationPlayer
@onready var sprite2D = $Sprite2D

var target_x = 0
var moving = true
var DIST = 16
var SPEED = 64
var JUMP = -200
var drag_pos = Vector2(0,0)
var joystick = Vector2(0,0)

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
		animationPlayer.play("jump")
	velocity += get_gravity() * delta
	#if moving:
		#if abs(target_x - position.x) > 0.2:
			#velocity.x = SPEED * sign(target_x - position.x)
		#else:
			#velocity.x = 0
			#position.x = target_x
			#moving = false
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			drag_pos = event.position
		else:
			joystick = Vector2.ZERO
	if event is InputEventScreenDrag:
		joystick = event.position - drag_pos

#func set_target(dir):
	#dir = sign(dir)
	#rayCast.target_position.x = dir * abs(rayCast.target_position.x)
	#rayCast.force_raycast_update()
	#if (rayCast.is_colliding()):
		#velocity.y += JUMP
#
	#var current = position.x / DIST
	#target_x = (current + dir) * DIST
	#moving = true

func set_target(dir):
	if dir < 0:
		sprite2D.flip_h = false
	if dir > 0:
		sprite2D.flip_h = true
	if dir != 0:
		animationPlayer.play("walk")
	else:
		animationPlayer.play("idle")
	velocity.x = dir * SPEED
	if dir != 0:
		rayCast.target_position.x = abs(rayCast.target_position.x) * dir
		rayCast.force_raycast_update()
		if is_on_floor() and is_on_wall() and rayCast.is_colliding():
			velocity.y += JUMP
	
