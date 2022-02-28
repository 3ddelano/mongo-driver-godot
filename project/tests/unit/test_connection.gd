extends BaseTest

var driver

func _init():
	driver = MongoGodotDriver.new()

func get_connection():
	return driver.connect_to_server(Env.get_var("MONGODB_URI"))

func run():
	describe("Connection")
	var connection
	var names
	var res
	var test_db

	test("default constructed connection cannot call methods")
	connection = MongoGodotConnection.new()
	print("gd1")
	res = connection.get_database_names({})
	print("gd2")
	print(res)
	assert_is_mongo_error(res)

	test("get_database_names", "no filter")
	connection = get_connection()
	names = connection.get_database_names()
	assert_typeof(names, TYPE_ARRAY)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database_names", "empty filter")
	connection = get_connection()
	names = connection.get_database_names()
	assert_typeof(names, TYPE_ARRAY)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database_names", "filter on 'name' with regex")
	connection = get_connection()
	names = connection.get_database_names({
		name = MongoGodot.Regex("(admin|local)")
	})
	assert_typeof(names, TYPE_ARRAY)
	assert_size(names, 2)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database", "test database with insert one operation")
	connection = get_connection()
	test_db = connection.get_database("test")
	assert_typeof(test_db, TYPE_OBJECT)
	# Try method on database object
	res = test_db.get_collection("test_col").insert_one({
		auto_test = 1
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"].length(), 24) # Valid ObjectId

