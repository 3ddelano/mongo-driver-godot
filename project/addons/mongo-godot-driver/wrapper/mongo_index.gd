class_name MongoIndex
extends "res://addons/mongo-godot-driver/wrapper/proxy.gd"

func get_database_names(filter := {}):
	return _call("get_database_names", [filter])

func list():
	return _call("list", [])

func create_one(index: Dictionary, options = {}):
	return _call("create_one", [index, options])

func create_many(indexes: Array, options = {}):
	return _call("create_many", [indexes, options])

func drop_one(name_or_index, options = {}):
	return _call("drop_one", [name_or_index, options])

func drop_all(options = {}):
	return _call("drop_all", [options])



# Wrapper
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[Mongo.Index:%s]" % str(get_instance_id())
