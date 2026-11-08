class_name Bubble extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func pop_bubble() -> void:
	if animation_player.is_playing():
		return
	animation_player.play(&"pop")
