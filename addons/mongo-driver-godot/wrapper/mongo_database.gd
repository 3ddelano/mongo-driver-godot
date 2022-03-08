# Represents a server-side grouping of collections.
# @tags - MongoDatabase, Class
class_name MongoDatabase
extends "res://addons/mongo-driver-godot/proxy.gd"

# Gets the names of the collections in this database.
# @param filter - Optional query expression to filter the returned collection names.
# @returns Array of collection names or error Dictionary
func get_collection_names(filter := {}):
	return _call("get_collection_names", [filter])

# Obtains a collection which represents a logical grouping of documents within this database.
# @param name - Name of the collection to get
# @returns The [MongoCollection] or error Dictionary
func get_collection(name: String):
	var ret = _call("get_collection", [name])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a MongoCollection wrapping a MongoGodotCollection
		return Collection.new(ret)
	return ret

# Explicitly creates a collection in this database with the specified options.
# @param name - Name of the new collection
# @param options - Optional options for the new collection
# @returns The newly created [MongoCollection] or error Dictionary
func create_collection(name:String, options := {}):
	var ret = _call("create_collection", [name, options])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a MongoCollection wrapping a MongoGodotCollection
		return Collection.new(ret)
	return ret


# Runs a command against this database.
# @param command - Dictionary representing the command to be run
# @returns Result Dictionary or error Dictionary
func run_command(command: Dictionary):
	return _call("run_command", [command])


# Drops the database and all its collections.
# @returns True or error Dictionary
func drop():
	return _call("drop", [])



# Wrapper
# @hidden
const Collection = preload("res://addons/mongo-driver-godot/wrapper/mongo_collection.gd")

# @hidden
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[MongoDatabase:%s]" % str(get_instance_id())
