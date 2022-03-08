# Represents the indexes on a MongoDB collection.
# @category - MongoIndex, Class
class_name MongoIndex
extends "res://addons/mongo-driver-godot/proxy.gd"

# Returns all the indexes.
# @returns Array of indexes or error Dictionary 
func list():
	return _call("list", [])

# Creates an index.
# @param index - Dictionary representing the 'keys' and 'options' of the new index
# @param options - Optional arguments
# @returns The result document or error Dictionary
func create_one(index: Dictionary, options := {}):
	return _call("create_one", [index, options])

# Creates mulitple indexes.
# @param indexes - Array of Dictionary representing the 'keys' and 'options' of the new indexes
# @param options - Optional arguments
# @returns The result document or error Dictionary
func create_many(indexes: Array, options := {}):
	return _call("create_many", [indexes, options])

# Attempts to drop a single index from the collection its the keys and options.
# @param name_or_index - Either a String representing the index name or a Dictionary representing the `keys` and `options` of the index to drop
# @param options - Optional arguments
# @returns True or error Dictionary
func drop_one(name_or_index, options := {}):
	return _call("drop_one", [name_or_index, options])

# Drops all indexes in the collection.
# @param options - Optional arguments
# @returns True or error Dictionary
func drop_all(options := {}):
	return _call("drop_all", [options])



# Wrapper
# @hidden
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[MongoIndex:%s]" % str(get_instance_id())
