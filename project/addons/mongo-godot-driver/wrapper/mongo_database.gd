# Represents a server-side grouping of collections.
# @category - Classes
class_name MongoDatabase
extends "res://addons/mongo-godot-driver/proxy.gd"

func get_collection_names(filter = {}):
	return _call("get_collection_names", [filter])

func get_collection(name: String):
	var ret = _call("get_collection", [name])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Collection wrapping a MongoGodotCollection
		return Collection.new(ret)
	return ret

func run_command(command: Dictionary):
	return _call("run_command", [command])

func drop():
	return _call("drop", [])

func create_collection(name:String, options = {}):
	var ret = _call("create_collection", [name, options])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Collection wrapping a MongoGodotCollection
		return Collection.new(ret)
	return ret



# Wrapper
const Collection = preload("res://addons/mongo-godot-driver/wrapper/mongo_collection.gd")
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[Mongo.Database:%s]" % str(get_instance_id())
