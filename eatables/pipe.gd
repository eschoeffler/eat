class_name Pipe extends Eatable

# The delay in s after the scene loads at which the pipe will drip
@export var delay = 0.1

# The frequency in s that the pipe will drip.
@export var frequency = 2

var water_scene = preload("res://obstacles/water.tscn")
@onready var timer: Timer = $Timer


func _ready() -> void:
    # Configure the timer to be repeating
    timer.one_shot = false
    timer.wait_time = frequency

    # Connect the timeout signal if not already connected in the editor
    if not timer.timeout.is_connected(_drip):
        timer.timeout.connect(_drip)

    # 2. Wait for the initial delay after the scene loads
    await get_tree().create_timer(delay).timeout

    # 3. Start the repeating timer after the delay finishes
    timer.start()


func _drip() -> void:
    var water = water_scene.instantiate()
    get_parent().add_child(water)
    # Instantiate water just below the pipe
    water.global_position = global_position + Vector2(0, 16)
