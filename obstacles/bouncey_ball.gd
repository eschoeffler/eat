class_name BounceyBall extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var timer = 0

func _process(delta: float) -> void:
    if timer > 0:
        timer -= delta
    if timer < 0:
        timer = 0
        collision_shape_2d.disabled = false
        animation_player.play(&"RESET")
    
func bounce() -> void:
    animation_player.stop()
    animation_player.play(&"bounce")


func bounce_ball() -> void:
    bounce()


func eat() -> Dictionary:
    collision_shape_2d.disabled = true
    timer = 1
    animation_player.play(&"disable")
    return {}

