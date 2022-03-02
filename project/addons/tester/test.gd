extends BaseTest

enum TestMode {
	SINGLE_FILE,
	SINGLE_DIRECTORY,
	RECURSIVE_DIRECTORY
}

var TESTS_PATH = "res://tests/unit/test_index.gd"
var TEST_FILE_PREFIX = "test_"
var TEST_FILE_SUFFIX = ".gd"

var _dirs = [TESTS_PATH.get_base_dir()]
var _tests = []

var test_mode = TestMode.SINGLE_FILE

func _ready() -> void:
	TestUtils.start_epoch = OS.get_ticks_msec()

	if test_mode == TestMode.SINGLE_FILE:
		run_test(TESTS_PATH)
	else:
		run_tests()

	print("\nRan %s describes with %s tests" % [str(TestUtils.describe_count), str(TestUtils.test_count)])
	var end_epoch = OS.get_ticks_msec()
	var duration = end_epoch - TestUtils.start_epoch
	print("Took %s seconds" % str(duration * 0.001))

	if OS.get_environment("QUIT_ON_TEST_COMPLETE"):
		get_tree().quit()

func is_valid_test_filename(file_name: String) -> bool:
	return file_name.begins_with(TEST_FILE_PREFIX) and file_name.ends_with(TEST_FILE_SUFFIX)

func run_test(file_path: String) -> void:
	var test_script = load(file_path).new()

	if not test_script.has_method("run"):
		test_script.free()
		print("[WARNING] %s doesn't have a run() method" % file_path)
		return

	test_script.run()
	test_script.free()

func run_tests():
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
				if test_mode == TestMode.RECURSIVE_DIRECTORY:
					_dirs.append(file_name)
			elif is_valid_test_filename(file_name):
				# Found test file
				_tests.append(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
		_dirs.pop_front()

	for test_file_path in _tests:
		run_test(test_file_path)
