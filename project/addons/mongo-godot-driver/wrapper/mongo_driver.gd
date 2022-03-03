# Handles making connections to a MongoDB server.
# @tags - MongoDriver, Class
class_name MongoDriver
extends "res://addons/mongo-godot-driver/proxy.gd"

# Attempts to create a client connection to a MongoDB server.
# @param uri - A MongoDB URI representing the connection parameters
# @returns MongoConnection | error Dictionary
func connect_to_server(uri: String):
	var ret = _call("connect_to_server", [uri])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Connection wrapping a MongoGodotConnection
		return Connection.new(ret)
	return ret



# Wrapper
# @hidden
const Connection = preload("res://addons/mongo-godot-driver/wrapper/mongo_connection.gd")

# @hidden
const MongoGodotDriverImpl = preload("res://addons/mongo-godot-driver/native/mongo_godot_driver.gdns")

# @hidden
func _init(obj = null).(MongoGodotDriverImpl.new()):
	pass

func _to_string() -> String:
	return "[Mongo.Driver:%s]" % str(get_instance_id())
