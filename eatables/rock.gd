class_name Rock extends Eatable

const MAX_SPEED = 100

var top_area = Area2D.new()

@onready var col_shape = $CollisionShape2D


func _ready() -> void:
    _create_sensor_areas()


func _physics_process(delta: float) -> void:
    velocity += get_gravity() * delta
    velocity.y = min(velocity.y, MAX_SPEED)
    move_and_slide()


func _create_sensor_areas() -> void:
    if not col_shape.shape is RectangleShape2D:
        return

    var rect: RectangleShape2D = col_shape.shape
    var sensor_width = rect.size.x
    var col_top_y = col_shape.position.y - rect.size.y / 2.0

    # Top sensor — detects things landing on the rock
    var top_shape = RectangleShape2D.new()
    top_shape.size = Vector2(sensor_width, 1.0)

    top_area.collision_layer = 0
    top_area.collision_mask = 14  # layers 2, 3, 4 (rocks + character)
    top_area.monitoring = true

    var top_col = CollisionShape2D.new()
    top_col.shape = top_shape
    top_col.position = Vector2(col_shape.position.x, col_top_y - 0.5)

    top_area.add_child(top_col)
    add_child(top_area)


func get_weight() -> int:
    var weight = 1
    for body in top_area.get_overlapping_bodies():
        if body == self:
            continue
        if body.has_method("get_weight"):
            weight += body.get_weight()
        else:
            weight += 1
    return weight
