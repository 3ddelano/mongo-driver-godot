extends BaseTest

var driver

func _init():
	driver = MongoGodotDriver.new()

func get_connection(uri):
	return driver.connect_to_server(uri)

func run():
	describe("Driver")
	var connection
	var res

	# # Crashes since godot-cpp doesn't support no arg handling
	# test("connect_to_server", "no uri")
	# connection = driver.connect_to_server()
	# assert_is_mongo_error(connection)


	test("connect_to_server", "empty uri")
	connection = get_connection("")
	assert_is_mongo_error(connection)


	test("connect_to_server", "invalid uri")
	connection = driver.connect_to_server("mong://blah")
	assert_is_mongo_error(connection)

	test("connect_to_server", "valid uri")
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	assert_typeof(connection, TYPE_OBJECT)
	# Try method on connection object
	res = connection.get_database_names({}) # must pass empty Dictionary
	assert_typeof(res, TYPE_ARRAY)
	assert_has(res, "local")
	assert_has(res, "admin")
