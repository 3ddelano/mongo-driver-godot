class_name MongoDriver
extends "res://addons/mongo-godot-driver/wrapper/proxy.gd"

func connect_to_server(uri: String):
	var ret = _call("connect_to_server", [uri])
	if typeof(ret) != TYPE_DICTIONARY:
		# Return a Mongo.Connection wrapping a MongoGodotConnection
		return Connection.new(ret)
	return ret



# Wrapper
const Connection = preload("res://addons/mongo-godot-driver/wrapper/mongo_connection.gd")
const MongoGodotDriverImpl = preload("res://addons/mongo-godot-driver/native/mongo_godot_driver.gdns")

func _init(obj = null).(MongoGodotDriverImpl.new()):
	pass

func _to_string() -> String:
	return "[Mongo.Driver:%s]" % str(get_instance_id())
