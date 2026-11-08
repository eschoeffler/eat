class_name Eatable extends CharacterBody2D

enum Type { NOTHING, ROCK, WATER, BUBBLE, BALLOON }

const NOTHING = Type.NOTHING
const ROCK = Type.ROCK
const WATER = Type.WATER
const BUBBLE = Type.BUBBLE
const BALLOON = Type.BALLOON

var type = Eatable.ROCK


func eat() -> Dictionary:
    if get_parent():
        get_parent().remove_child(self)
    return {"type": type, "obj": self}
