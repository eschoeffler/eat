class_name Eatable extends CharacterBody2D

enum Type { NOTHING, ROCK, WATER }

const NOTHING = Type.NOTHING
const ROCK = Type.ROCK
const WATER = Type.WATER

var type = Eatable.ROCK


func eat() -> Dictionary:
    if get_parent():
        get_parent().remove_child(self)
    return {"type": type, "obj": self}
