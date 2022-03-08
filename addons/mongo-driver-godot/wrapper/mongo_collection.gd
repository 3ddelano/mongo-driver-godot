# Represents a server side document grouping within a MongoDB database.
# @tags - MongoCollection, Class
class_name MongoCollection
extends "res://addons/mongo-driver-godot/proxy.gd"

# Finds the documents in this collection which match the provided filter.
# @param filter - Dictionary representing a document that should match the query
# @param options - Optional arguments
# @returns Array of documents or error Dictionary
func find(filter := {}, options := {}):
	return _call("find", [filter, options])

# Finds a single document in this collection that match the provided filter.
# @param filter - Dictionary representing a document that should match the query
# @param options - Optional arguments
# @returns An optional document that matched the filter or error Dictionary
func find_one(filter := {}, options := {}):
	return _call("find_one", [filter, options])

# Finds a single document matching the filter, deletes it, and returns the original.
# @param filter - Dictionary representing a document that should be deleted
# @param options - Optional arguments
# @returns The document that was deleted or error Dictionary
func find_one_and_delete(filter := {}, options := {}):
	return _call("find_one_and_delete", [filter, options])

# Finds a single document matching the filter, replaces it, and returns either the original or the replacement document.
# @param filter - Dictionary representing a document that should be replaced
# @param doc - Dictionary representing the replacement for a matching document
# @param options - Optional arguments
# @returns The original or replaced document or error Dictionary
func find_one_and_replace(filter := {}, doc := {}, options := {}):
	return _call("find_one_and_replace", [filter, doc, options])

#  Finds a single document matching the filter, updates it, and returns either the original or the newly-updated document.
# @param filter - Dictionary representing a document that should be updated
# @param options - Optional arguments
# @returns The original or updated document or error Dictionary
func find_one_and_update(filter := {}, doc := {}, options := {}):
	return _call("find_one_and_update", [filter, doc, options])

# Inserts a single document into the collection.
# 
# If the document is missing an identifier (_id field) one will be generated for it.
# @param doc - The document to insert
# @param options - Optional arguments
# @returns The result of attempting to perform the insert or error Dictionary
func insert_one(doc := {}, options := {}):
	return _call("insert_one", [doc, options])

# Inserts multiple documents into the collection.
# 
# If the documents are missing identifiers then they will be generated for them.
# @param doc - Array of documents to insert
# @param options - Optional arguments
# @returns The result of attempting to performing the insert or error Dictionary
func insert_many(docs: Array, options := {}):
	return _call("insert_many", [docs, options])

# Replaces a single document matching the provided filter in this collection.
# @param filter -Document representing the match criteria
# @param doc - The replacement document
# @param options - Optional arguments
# @returns The result of attempting to replace a document or error Dictionary
func replace_one(filter: Dictionary, doc := {}, options := {}):
	return _call("replace_one", [filter, doc, options])

# Updates a single document matching the provided filter in this collection.
# @param filter - Document representing the match criteria
# @param doc - Document representing the update to be applied to a matching document
# @param options - Optional arguments
# @returns The result of attempting to update a document or error Dictionary
func update_one(filter: Dictionary, doc_or_pipeline, options := {}):
	return _call("update_one", [filter, doc_or_pipeline, options])

# Updates multiple documents matching the provided filter in this collection.
# @param filter - Document representing the match criteria
# @param doc - Document representing the update to be applied to the matching documents
# @param options - Optional arguments
# @returns The result of attempting to update multiple documents or error Dictionary
func update_many(filter: Dictionary, doc_or_pipeline, options := {}):
	return _call("update_many", [filter, doc_or_pipeline, options])

# Deletes a single matching document from the collection.
# @param filter -Dictionary representing the data to be deleted
# @param options - Optional arguments
# @returns The result of performing the deletion or error Dictionary
func delete_one(filter: Dictionary, options := {}):
	return _call("delete_one", [filter, options])

# Deletes all matching documents from the collection.
# @param filter - Dictionary representing the data to be deleted
# @param options - Optional arguments
# @returns The result of performing the deletion or error Dictionary
func delete_many(filter: Dictionary, options := {}):
	return _call("delete_many", [filter, options])

# Rename this collection.
# @param name - The new name to assign to the collection
# @param drop_target_before_rename - Whether to overwrite any existing collections called new_name. The default is false.
# @returns True if success or error Dictionary
func rename(name: String, drop_target_before_rename = false):
	return _call("rename", [name, drop_target_before_rename])

# Returns the name of this collection.
# @returns The name of this collection
func get_name():
	return _call("get_name", [])

#  Drops this collection and all its contained documents from the database.
# @returns True if success or error Dictionary
func drop():
	return _call("drop", [])

# Counts the number of documents matching the provided filter.
# @param filter - The filter that documents must match in order to be counted
# @param options - Optional arguments
# @returns The count of the documents that matched the filter or error Dictionary
func count_documents(filter: Dictionary, options = []):
	return _call("count_documents", [filter, options])

# Returns an estimate of the number of documents in the collection.
# @param options - Optional arguments
# @returns The count of the documents that matched the filter or error Dictionary
func estimated_document_count(options := {}):
	return _call("estimated_document_count", [options])

# Creates an index over the collection for the provided keys with the provided options.
# @param index - Dictionary representing the 'keys' and 'options' of the new index
# @param options - Optional arguments
# @returns Dictionary or error Dictionary
func create_index(index: Dictionary, options := {}):
	return _call("create_index", [index, options])

# Returns a MongoIndex for this collection
# @returns MongoIndex for this collection or error Dictionary
func get_indexes():
	var ret = _call("get_indexes", [])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a MongoIndex wrapping a MongoGodotIndex
		return Index.new(ret)
	return ret

# Returns a list of the indexes currently on this collection.
# @returns Array of indexes or error Dictionary
func get_indexes_list():
	return _call("get_indexes_list", [])

# Finds the distinct values for a specified field across the collection.
# @param name - The field for which the distinct values will be found
# @param filter - ictionary representing the documents for which the distinct operation will apply
# @param options - Optional arguments
# @returns Array of the distinct values or error Dictionary
func get_distinct(name: String, filter := {}, options := {}):
	return _call("get_distinct", [name, filter, options])




# Wrapper
# @hidden
const Index = preload("res://addons/mongo-driver-godot/wrapper/mongo_index.gd")

# @hidden
func _init(obj).(obj):
	pass

func _to_string() -> String:
	return "[MongoCollection:%s]" % str(get_instance_id())
