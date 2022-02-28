extends BaseTest

var driver
var connection

func _init():
	driver = MongoGodotDriver.new()
	connection = get_connection()

func get_connection():
	return driver.connect_to_server(Env.get_var("MONGODB_URI"))

func get_database(name):
	return connection.get_database(name)

func run():
	describe("Database")

	var database
	var collection
	var res
	var names
	var value
	var before
	var after

	test("default constructed database cannot call methods")
	database = MongoGodotDatabase.new()
	res = database.get_collection_names()
	assert_is_mongo_error(res)


	test("get_collection_names", "no filter")
	names = get_database("test").get_collection_names()
	assert_typeof(names, TYPE_ARRAY)


	test("get_collection_names", "empty filter")
	names = get_database("test").get_collection_names({})
	assert_typeof(names, TYPE_ARRAY)


	test("get_collection_names", "filter on name with regex")
	connection = get_connection()
	names = connection.get_database_names({
		name = MongoGodot.Regex("(admin|local)")
	})
	assert_typeof(names, TYPE_ARRAY)
	assert_eq(names.size(), 2)
	assert_has(names, "admin")
	assert_has(names, "local")


	test("get_collection", "get test collection and ensure only 1 document")
	get_database("test").get_collection("test_col").drop()
	collection = get_database("test").get_collection("test_col")
	assert_typeof(collection, TYPE_OBJECT)
	# Try method on collection object
	randomize()
	value = str(randi() % 1000)
	res = collection.insert_one({
		get_collection = value
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["inserted_count"], 1)
	assert_eq(res["inserted_id"].length(), 24)
	res = collection.find()
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 1)
	assert_eq(res[0]["get_collection"], value)


	test("create collection", "with options capped, validator")
	get_database("test").get_collection("test_col").drop()
	collection = get_database("test").create_collection("test_col", {
		capped = true,
		size = 10000,
		validationLevel = "strict",
		validationAction = "error",
		collation = {},
		writeConcern = {},
		comment = "hey testing comment",
		validator = {_id = {"$eq": "baz"}}
	})
	print(collection)
	
	test("create_collection", "with option timeseries, expireInSeconds")
	get_database("test").get_collection("test_col").drop()
	collection = get_database("test").create_collection("test_col", {
		timeseries = {
			timeField = "created_date",
			granularity = "seconds",
		},
		expireAfterSeconds = 10,
		# autoIndexId = false,
		# pipeline = [],
	})
	
	res = collection.insert_one({
		n = 2,
		created_date = MongoGodot.Date("2022-02-28T01:11:18.965Z")
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	print()

	return

	test("run_command", "run count command")
	res = get_database("test").run_command({
		count = "test_col"
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["ok"], 1)
	assert_eq(res["n"], 1)


	test("run_command", "run hello command")
	res = get_database("test").run_command({
		hello = 1
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "ok")
	assert_eq(res["ok"], 1)
	assert_has(res, "connectionId")


	test("drop", "drop test database")
	before = get_database("test").get_collection_names().size()
	res = get_database("test").drop()
	after = get_database("test").get_collection_names().size()
	assert_typeof(res, TYPE_BOOL)
	assert_eq(res, true)
	assert_ne(before, 0)
	assert_eq(after, 0)
