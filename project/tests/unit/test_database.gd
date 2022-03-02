extends BaseTest

var driver: MongoDriver
var connection: MongoConnection
var database: MongoDatabase

func _init():
	driver = MongoDriver.new()
	connection = get_connection()
	database = get_database("test")

func get_connection():
	return driver.connect_to_server(Env.get_var("MONGODB_URI"))

func get_database(name):
	return connection.get_database(name)

func run():
	describe("Database")

	var collection
	var res
	var names
	var value
	var before
	var after

	collection = database.get_collection("test_col")


	test("get_collection_names", "no filter")
	database.drop()
	database.create_collection("hello")
	database.create_collection("world")
	names = database.get_collection_names()
	assert_typeof(names, TYPE_ARRAY)
	assert_size(names, 2)
	assert_has(names, "hello")
	assert_has(names, "world")


	test("get_collection_names", "empty filter")
	database.drop()
	database.create_collection("hi")
	database.create_collection("hi2")
	database.create_collection("hi3")
	names = database.get_collection_names({})
	assert_typeof(names, TYPE_ARRAY)
	assert_size(names, 3)


	test("get_collection_names", "filter on name with regex")
	names = connection.get_database_names({
		name = Mongo.Regex("(admin|local)")
	})
	assert_typeof(names, TYPE_ARRAY)
	assert_eq(names.size(), 2)
	assert_has(names, "admin")
	assert_has(names, "local")


	test("get_collection", "get collection and ensure only 1 document")
	database.drop()
	collection = database.get_collection("test_col")
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
	database.drop()
	collection = database.create_collection("test_col", {
		capped = true,
		size = 10000,
		validationLevel = "strict",
		validationAction = "error",
		collation = {},
		writeConcern = {},
		comment = "hey testing comment",
		validator = {_id = {"$eq": "baz"}}
	})
	assert_typeof(collection, TYPE_OBJECT)
	res = database.get_collection_names()
	assert_eq(res[0], "test_col")


	test("create collection", "with option timeseries, expireInSeconds")
	database.drop()
	collection = database.create_collection("test_col", {
		timeseries = {
			timeField = "created_date",
			granularity = "seconds",
		},
		expireAfterSeconds = 10,
	})
	res = collection.insert_one({
		n = 2,
		created_date = Mongo.Date("2022-02-28T01:11:18.965Z")
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")


	test("run_command", "run count command")
	database.drop()
	collection.insert_many([{a = 1}, {a = 2}, {a = 3}])
	res = database.run_command({
		count = "test_col"
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["ok"], 1)
	assert_eq(res["n"], 3)


	test("run_command", "run hello command")
	res = database.run_command({
		hello = 1
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "ok")
	assert_eq(res["ok"], 1)
	assert_has(res, "connectionId")


	test("drop", "drop test database")
	before = database.get_collection_names().size()
	res = database.drop()
	after = database.get_collection_names().size()
	assert_typeof(res, TYPE_BOOL)
	assert_eq(res, true)
	assert_ne(before, 0)
	assert_eq(after, 0)
