class_name Water extends CharacterBody2D

const MAX_SPEED = 100


func _physics_process(delta: float) -> void:
    velocity += get_gravity() * delta
    velocity.y = min(velocity.y, MAX_SPEED)
    var collision = move_and_collide(velocity * delta)
    if collision and collision.get_collider():
        print(collision.get_collider())
        if not collision.get_collider() is Pipe:
            queue_free()


func eat() -> Dictionary:
    if get_parent():
        get_parent().remove_child(self)
    return {"type": Eatable.WATER, "obj": self}
