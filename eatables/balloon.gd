class_name Balloon extends Eatable

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    type = Eatable.BALLOON
    animation_player.play(&"idle")


func _enter_tree() -> void:
    if is_node_ready() and animation_player:
        animation_player.play(&"idle")
