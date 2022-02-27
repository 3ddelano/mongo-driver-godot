extends BaseTest

var TESTS_PATH = "res://tests"
var TEST_FILE_PREFIX = "test_"
var TEST_FILE_SUFFIX = ".gd"

var _dirs = [TESTS_PATH]
var _tests = []

func _ready() -> void:
	var dir = Directory.new()
	while _dirs.size() > 0:
		var dir_path = _dirs[0]
		if not dir_path.begins_with("res://"):
			dir_path = TESTS_PATH + "/" + dir_path

		if dir.open(dir_path) != OK:
			_dirs.pop_front()
			continue

		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name in [".", ".."]:
				file_name = dir.get_next()
				continue

			if dir.current_is_dir():
				_dirs.append(file_name)
			elif file_name.begins_with(TEST_FILE_PREFIX) and file_name.ends_with(TEST_FILE_SUFFIX):
				# Found test file
				_tests.append(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
		_dirs.pop_front()

	for test_path in _tests:
		var test_script = load(test_path).new()
		if not test_script.has_method("run"):
			test_script.free()
			print("[WARNING] %s doesn't have a run() method" % test_path)
			continue

		test_script.run()
		test_script.free()

	print("\nRan %s describes with %s tests" % [str(TestUtils.describe_count), str(TestUtils.test_count)])

	if OS.get_environment("QUIT_ON_TEST_COMPLETE"):
		get_tree().quit()

func test_driver():
	describe("driver")
	var driver = MongoGodotDriver.new()
	var connection


	test("empty_uri_provided")
	connection = driver.connect_to_server("")
	assert_is_mongo_error(connection)


	test("invalid_uri_provided")
	connection = driver.connect_to_server("mong:")
	assert_is_mongo_error(connection)


	test("valid_uri_provided")
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))

	assert_typeof(connection, TYPE_OBJECT)
	assert_not_null(connection)

	# Test if method returns proper result
	var res = connection.get_database_names()
	assert_typeof(res, TYPE_ARRAY)
	assert_gt(res.size(), 0)
	assert_has(res, "admin")
	assert_has(res, "local")
