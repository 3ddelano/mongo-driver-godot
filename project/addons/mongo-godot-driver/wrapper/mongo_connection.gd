# Represents the indexes on a MongoDB collection.
# @category - Classes
class_name MongoConnection
extends "res://addons/mongo-godot-driver/proxy.gd"

func get_database_names(filter := {}):
	return _call("get_database_names", [filter])

func get_database(name):
	var ret = _call("get_database", [name])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Database wrapping a MongoGodotDatabase
		return Database.new(ret)
	return ret



# Wrapper
const Database = preload("res://addons/mongo-godot-driver/wrapper/mongo_database.gd")
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[Mongo.Connection:%s]" % str(get_instance_id())
