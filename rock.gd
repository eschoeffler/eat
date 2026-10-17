class_name Rock extends CharacterBody2D

const MAX_SPEED = 100


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity.y = min(velocity.y, MAX_SPEED)
	move_and_slide()


func eat() -> Dictionary:
	if get_parent():
		get_parent().remove_child(self)
	return {"type": Eatable.ROCK, "obj": self}
