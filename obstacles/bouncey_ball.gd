class_name BounceyBall extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func bounce() -> void:
    animation_player.stop()
    animation_player.play(&"bounce")


func bounce_ball() -> void:
    bounce()

