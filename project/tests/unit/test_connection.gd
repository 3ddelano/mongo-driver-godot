extends BaseTest

var driver: MongoDriver

func _init():
	driver = MongoDriver.new()

func get_connection():
	return driver.connect_to_server(Env.get_var("MONGODB_URI"))

func run():
	describe("Connection")
	var connection: MongoConnection
	var names
	var res
	var test_db

	test("get_database_names", "no filter")
	connection = get_connection()
	names = connection.get_database_names()
	assert_typeof(names, TYPE_ARRAY)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database_names", "empty filter")
	connection = get_connection()
	names = connection.get_database_names({})
	assert_typeof(names, TYPE_ARRAY)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database_names", "filter on 'name' with regex")
	connection = get_connection()
	names = connection.get_database_names({
		name = Mongo.Regex("(admin|local)")
	})
	assert_typeof(names, TYPE_ARRAY)
	assert_size(names, 2)
	assert_has(names, "local")
	assert_has(names, "admin")


	test("get_database", "test database with insert one operation")
	connection = get_connection()
	test_db = connection.get_database("test")
	assert_typeof(test_db, TYPE_OBJECT)
	test_db.drop()
	# Try method on database object
	res = test_db.get_collection("test_col").insert_one({
		auto_test = 1
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"].length(), 24) # Valid ObjectId

