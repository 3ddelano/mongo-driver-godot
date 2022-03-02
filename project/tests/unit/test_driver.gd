extends BaseTest

var driver: MongoDriver

func _init():
	driver = MongoDriver.new()

func get_connection(uri):
	return driver.connect_to_server(uri)

func run():
	describe("Driver")
	var connection
	var res


	test("connect_to_server", "empty uri")
	connection = get_connection("")
	assert_is_mongo_error(connection)


	test("connect_to_server", "invalid uri")
	connection = driver.connect_to_server("mong://blah")
	assert_is_mongo_error(connection)


	test("connect_to_server", "valid uri")
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI")) as MongoConnection
	assert_typeof(connection, TYPE_OBJECT)
	# Try method on connection object
	res = connection.get_database_names()
	assert_typeof(res, TYPE_ARRAY)
	assert_has(res, "local")
	assert_has(res, "admin")
