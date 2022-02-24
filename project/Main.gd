extends Control

onready var mongo = MongoGodotDriver.new()

func load_env(path = "res://.env"):
	var file = File.new()
	if(!file.file_exists(path)):
		return {}

	file.open(path, File.READ)
	var ret = {}
	while !file.eof_reached():
		var line = file.get_line()
		var tokens = line.split("=", false, 1)
		if tokens.size() == 2:
			ret[tokens[0]] = tokens[1].lstrip("\"").rstrip("\"");
	return ret

func _ready() -> void:
	var env = load_env()
	print("MAIN>Ready")

	var connection = mongo.connect_to_server(env["MONGODB_URI"])
#	print(connection.get_database_names())

	var firstDatabase = connection.get_database("firstDatabase")
#	print(firstDatabase.get_collection_names())
	var hello = connection.get_database("hello")
	var cakes = hello.get_collection("Cakes")
	var bikes = hello.get_collection("bikes")
	var users = firstDatabase.get_collection("Users")

	var bot = connection.get_data
	return

	# Find one
#	var item = users.find_one({
#		"_id": "11111"
#	})

	# Find one and delete
#	print(users.find_one_and_delete({
#		"_id": "11111"
#	}))

	# Find one and replace
#	print(users.find_one_and_replace({
#		"_id": MongoGodot.ObjectId("6213c5f01a7a000051006492")
#	}, {
#		abde = "feggggg"
#	}))

	# Find one and update
#	print(users.find_one_and_update({
#		"_id": MongoGodot.ObjectId("6213c5f01a7a000051006492")
#	},
#		MongoGodot.Set({
#			abde = "1234"
#		})
#	))

	# Insert one
#	print(cakes.insert_one({
#		a = "a",
#		b = "b",
#		c = "c"
#	}))

	# Insert many
#	print(cakes.insert_many([
#		{a = 1},
#		{b = 1},
#		{c = 1},
#		{d = 1},
#	]))

	# Count documents
#	print(cakes.count_documents({
#		e = 1
#	}))

	# Estimated document count
#	print(cakes.estimated_document_count())

	# Delete one
#	print(cakes.delete_one())

	# Delete many
#	print(cakes.delete_many({
#		e = 1
#	}))

	# Replace one
#	print(bikes.replace_one({
#		zzzc = "55"
#	}, {
#		ac = 22156
#	}))

#	var arr = []
#	for i in range(10000):
#		arr.append({n = i})
#	bikes.insert_many(arr)

#	print("-")
	print(bikes.update_many({
		n = MongoGodot.Lt(5)
	}, MongoGodot.Set({
		n = -5
	})))

	# Update one
#	print(bikes.update_one({
#		"$lt": {
#			n = 5
#		}
#	}, MongoGodot.Set({
#		bc = "151515151"
#	})))

	# Drop collection
#	print(hello.get_collection("droppeeee").drop())

	# Rename
#	print(cakes.rename("bikes"))
#	print(cakes.rename("bikes", true))

#	yield(get_tree().create_timer(5), "timeout")
#	get_tree().quit()


#	print(users.find())
#	print(users.find_one({
#		"_id": MongoGodot.ObjectId("6213c5ce45e32f5dcf6ad6b3")
#	}))
#	var hello = connection.get_database("hello")
#	print(hello.get_collection_names())


#	print("MAIN> database names", mongo.get_database_names())
#	for database_name in mongo.get_database_names():
#		print("MAIN> collections in " + database_name)
#		print(mongo.get_collection_names(database_name))
#	print("----")
#
#
#	var collection = mongo.get_collection("firstDatabase", "Users", {
#		_id = MongoGodot.ObjectId("621322cfd00700000a003bc2")
#	})
#	print(collection.size())
#	print(collection)
#
#	collection = mongo.get_collection("firstDatabase", "Users", {
#		_id = MongoGodot.ObjectId("621322cfd00700000a0031c2")
#	})
#	print(collection.size())
#
#	collection = mongo.get_collection("firstDatabase", "Users", {
#		_id = MongoGodot.ObjectId("621322cfd1c2")
#	})
#	print(collection.size())
#	print("inserted", mongo.insert_one("firstDatabase", "Users", {
#		hey = "yoo",
#		date = MongoGodot.Date()
#	}))


#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.pressed and event.button_index == BUTTON_LEFT:
#			pass
