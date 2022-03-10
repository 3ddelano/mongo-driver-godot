extends Reference

var hey
var test := "testing"

export (String) var hello = "hi"

# this contains a non-valid reference [Mongo.is_error] [AbcXYZ.hey]
var myprop: String = "" setget set_myprop, get_myprop

func set_myprop(p_val: String):
    myprop = p_val

func get_myprop():
    return myprop


# Desc for signal1
signal signal1(hey, a123)

# Desc for signal2
signal signal2

enum TestEnum {
    HELLO,
    ABC,
    WORLD
}

var public_var_hello
var _private_var_hello

onready var testing_onready_var

const CONST_1 = "hey"

func _process(delta):
    pass

# Desc for subclass
class SubTesting:

    # desc for hello
    func hello():
        return "hi"

    class ThirdLevel:
        var hello
        var hi = "hey"
