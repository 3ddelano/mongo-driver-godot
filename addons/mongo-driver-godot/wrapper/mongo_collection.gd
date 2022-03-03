# Represents a server side document grouping within a MongoDB database.
# @tags - MongoCollection, Class
class_name MongoCollection
extends "res://addons/mongo-driver-godot/proxy.gd"

func get_collection_names(filter := {}):
	return _call("get_collection_names", [filter])

func find(filter := {}, options = {}):
	return _call("find", [filter, options])

func find_one(filter := {}, options = {}):
	return _call("find_one", [filter, options])

func find_one_and_delete(filter := {}, options = {}):
	return _call("find_one_and_delete", [filter, options])

func find_one_and_replace(filter := {}, doc = {}, options = {}):
	return _call("find_one_and_replace", [filter, doc, options])

func find_one_and_update(filter := {}, doc = {}, options = {}):
	return _call("find_one_and_update", [filter, doc, options])

func insert_one(doc = {}, options = {}):
	return _call("insert_one", [doc, options])

func insert_many(docs: Array, options = {}):
	return _call("insert_many", [docs, options])

func replace_one(filter: Dictionary, doc = {}, options = {}):
	return _call("replace_one", [filter, doc, options])

func update_one(filter: Dictionary, doc_or_pipeline, options = {}):
	return _call("update_one", [filter, doc_or_pipeline, options])

func update_many(filter: Dictionary, doc_or_pipeline, options = {}):
	return _call("update_many", [filter, doc_or_pipeline, options])

func delete_one(filter: Dictionary, options = {}):
	return _call("delete_one", [filter, options])

func delete_many(filter: Dictionary, options = {}):
	return _call("delete_many", [filter, options])

func rename(name: String, drop_target_before_rename = false):
	return _call("rename", [name, drop_target_before_rename])

func get_name():
	return _call("get_name", [])

func drop():
	return _call("drop", [])

func count_documents(filter: Dictionary, options = []):
	return _call("count_documents", [filter, options])

func estimated_document_count(options = {}):
	return _call("estimated_document_count", [options])

func create_index(index: Dictionary, options = {}):
	return _call("create_index", [index, options])

func get_indexes():
	var ret = _call("get_indexes", [])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Index wrapping a MongoGodotIndex
		return Index.new(ret)
	return ret

func get_indexes_list():
	return _call("get_indexes_list", [])

func get_distinct(name: String, filter := {}, options = {}):
	return _call("get_distinct", [name, filter, options])




# Wrapper
# @hidden
const Index = preload("res://addons/mongo-driver-godot/wrapper/mongo_index.gd")

# @hidden
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[Mongo.Collection:%s]" % str(get_instance_id())
