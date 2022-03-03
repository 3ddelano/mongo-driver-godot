# Represents the indexes on a MongoDB collection.
# @tags - MongoConnection, Class
class_name MongoConnection
extends "res://addons/mongo-driver-godot/proxy.gd"

# Gets the names of the databases on the server.
# @param filter - Optional query expression to filter the returned database names
# @returns Array of database names or error Dictionary
func get_database_names(filter := {}):
	return _call("get_database_names", [filter])

# Obtains a database thats represents a logical grouping of collections on a MongoDB server
# @param name - Name of the database to get
# @returns The MongoGodotDatabase or error Dictionary
func get_database(name):
	var ret = _call("get_database", [name])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Database wrapping a MongoGodotDatabase
		return Database.new(ret)
	return ret



# Wrapper
# @hidden
const Database = preload("res://addons/mongo-driver-godot/wrapper/mongo_database.gd")

# @hidden
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[Mongo.Connection:%s]" % str(get_instance_id())
