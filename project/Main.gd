extends Control

onready var mongo = MongoGodotDriver.new()


func _ready() -> void:
	print("MAIN>Ready")

	var connection = mongo.connect_to_server(Env.get_var("MONGODB_URI"))
#	print(connection.get_database_names({
#		name = "local"
#	}))
#	print(connection.get_database("admin").run_command({
#		listDatabases = 1,
#		filter = {
#			sizeOnDisk = MongoGodot.Lt(40960)
#		}
#	}))
	var firstDatabase = connection.get_database("firstDatabase")
	var hello = connection.get_database("hello")
	var cakes = hello.get_collection("Cakes")
	var bikes = hello.get_collection("bikes")
	var users = firstDatabase.get_collection("Users")

#	randomize()
#	print(users.find_one_and_update({}, {
#		reg = MongoGodot.Regex("^(a|b)"),
#		val = rand_range(-1000,1000)
#	}, {
#		collation = { locale = "fr", strength = 1 },
#		bypass_document_valiation = true,
#		projection = {},
#		return_document = MongoGodot.FindOneOptions.ReturnDocument.AFTER,
#		sort = {},
#		upsert = true,
#		array_filters = []
#	}))
	print("running")
	print(connection.get_database("big").get_collection("items").find({}, {
		allow_disk_use = true,
		allow_partial_results = true,
		batch_size = 50,
		collation = {},
		cursor_type = MongoGodot.FindOptions.CursorType.NON_TAILABLE,
		hint = "ahe",
		limit = 2,
		max = {},
		max_await_time = 1000,
		max_time = 1000,
		min = {},
		no_cursor_timeout = true,
		projection = {},
		return_key = true,
		show_record_id = true,
		skip = 0,
		sort = {},
	}))
	print(connection.get_database("big").get_collection("items").find({}, {
		allow_disk_use = false,
		allow_partial_results = true,
		batch_size = 15,
		collation = {},
		cursor_type = MongoGodot.FindOptions.CursorType.NON_TAILABLE,
		hint = "ahaaaaaaae",
		limit = 10,
		max = {},
		max_await_time = 500,
		max_time = 410,
		min = {},
		no_cursor_timeout = false,
		projection = {},
		return_key = false,
		show_record_id = false,
		skip = 15,
		sort = {},
	}))
	print("ran")
	return


	# -----
	# ----- Database -----
	# -----

	# Get Collection names
#	print(firstDatabase.get_collection_names())


	# Get Collection
#	var collection = mongo.get_collection("firstDatabase", "Users", {
#		_id = MongoGodot.ObjectId("621322cfd00700000a003bc2")
#	})
#	print(collection.size())
#	print(collection)


	# Run Command
#	print(JSON.print(hello.run_command({ hello = 1 }), "\t", true))
#	print(hello.run_command({
#		count = "Cakes"
#	}))


	# Drop
#	var test_db = connection.get_database("test_db")
#	test_db.get_collection("test_coll").insert_one({h = 1})
#	print(test_db.drop())



	# -----
	# ----- Collection -----
	# -----

	# Find
#	print(cakes.find())


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


	# Replace one
#	print(bikes.replace_one({
#		zzzc = "55"
#	}, {
#		ac = 22156
#	}))


	# Update one
#	print(bikes.update_one({
#		"$lt": {
#			n = 5
#		}
#	}, MongoGodot.Set({
#		bc = "151515151"
#	})))


	# Update many
#	var arr = []
#	for i in range(100):
#		arr.append({n = i})
#	bikes.insert_many(arr)

#	print("-")
#	print(bikes.update_many({
#		n = MongoGodot.Lt(5)
#	}, MongoGodot.Set({
#		n = -5
#	})))


	# Delete one
#	print(cakes.delete_one())


	# Delete many
#	print(cakes.delete_many({
#		e = 1
#	}))


	# Rename
#	print(cakes.rename("bikes"))
#	print(cakes.rename("bikes", true))


	# Drop
#	print(hello.get_collection("droppeeee").drop())


	# Count documents
#	print(cakes.count_documents())


	# Estimated document count
#	print(cakes.estimated_document_count())



