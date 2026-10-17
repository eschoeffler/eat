class_name Water extends CharacterBody2D

const MAX_SPEED = 100

var spawn_position = Vector2.ZERO
func _ready() -> void:
	spawn_position = position

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity.y = min(velocity.y, MAX_SPEED)
	var collision = move_and_collide(velocity * delta)
	if (collision and collision.get_collider()):
		position = spawn_position
		velocity = Vector2.ZERO
		print(collision.get_collider())
