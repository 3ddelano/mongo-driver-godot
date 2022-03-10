extends Control

# Nothing here
# Testing some stuff

func _ready() -> void:
	var driver = MongoDriver.new()
	var connection: MongoConnection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	var test_db: MongoDatabase = connection.get_database("test")
	var test_col: MongoCollection = test_db.get_collection("test-col")

	randomize()
	print(test_col.find_one_and_update({}, {
		reg = Mongo.Regex("^(a|b)"),
		val = rand_range(-1000,1000)
	}, {
		collation = { locale = "fr", strength = 1 },
		bypass_document_valiation = true,
		projection = {},
		return_document = Mongo.FindOneOptions.ReturnDocument.AFTER,
		sort = {},
		upsert = true,
		array_filters = []
	}))


	var database = connection.get_database("test")
	var collection = database.get_collection("test_col")
	collection.drop()
	collection.insert_one({_id = 1})
	var res = collection.update_one({_id = 1},
		Mongo.Set({changed = true}),
	{
		upsert = true
	})
	print(res)


	print(connection.get_database("big").get_collection("items").find({}, {
		allow_disk_use = true,
		allow_partial_results = true,
		batch_size = 50,
		collation = {},
		cursor_type = Mongo.FindOptions.CursorType.NON_TAILABLE,
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
		cursor_type = Mongo.FindOptions.CursorType.NON_TAILABLE,
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
