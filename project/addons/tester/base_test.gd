class_name BaseTest
extends Node2D

var _randx123xyz = {}

var type_to_str = {
	0: "NIL",
	1: "BOOL",
	2: "INT",
	3: "REAL",
	4: "STRING",
	5: "VECTOR2",
	6: "RECT2",
	7: "VECTOR3",
	8: "TRANSFORM2D",
	9: "PLANE",
	10: "QUAT",
	11: "AABB",
	12: "BASIS",
	13: "TRANSFORM",
	14: "COLOR",
	15: "NODE_PATH",
	16: "RID",
	17: "OBJECT",
	18: "DICTIONARY",
	19: "ARRAY",
	20: "RAW_ARRAY",
	21: "INT_ARRAY",
	22: "REAL_ARRAY",
	23: "STRING_ARRAY",
	24: "VECTOR2_ARRAY",
	25: "VECTOR3_ARRAY",
	26: "COLOR_ARRAY",
	27: "MAX",
}

func describe(text):
	TestUtils.describe_count += 1
	print("\n-----Testing: %s (%s)" % [str(text), get_script().get_path()])

func test(text, sub_text= ""):
	TestUtils.test_count += 1
	print("Test %s: %s \t %s" % [str(TestUtils.test_count), str(text), str(sub_text)])

func t(text):
	print("\t" + str(text))


func assert_has(thing, what):
	if thing.has(what):
		return

	t("Expected %s to have %s" % [str(thing), str(what)])
	return _randx123xyz[""]

func assert_size(thing, size):
	if thing.size() == size:
		return

	t("Expected %s.size() to equal %s" % [str(thing), str(size)])
	return _randx123xyz[""]


func assert_gt(thing, value):
	if thing > value:
		return

	t("Expected %s to be greater than %s" % [str(thing), str(value)])
	return _randx123xyz[""]

func assert_lt(thing, value):
	if thing < value:
		return

	t("Expected %s to be less than %s" % [str(thing), str(value)])
	return _randx123xyz[""]

func assert_eq(thing, value):
	if thing == value:
		return

	t("Expected %s to equal %s" % [str(thing), str(value)])
	return _randx123xyz[""]

func assert_ne(thing, value):
	if thing != value:
		return

	t("Expected %s to not equal %s" % [str(thing), str(value)])
	return _randx123xyz[""]


func assert_typeof(thing, type):
	if typeof(thing) == type:
		return

	t("Expected %s to equal %s" % [str(thing), type_to_str[type]])
	return _randx123xyz[""]

func assert_not_null(thing):
	if thing != null:
		return

	t("Expected %s to not be null" % str(thing))
	return _randx123xyz[""]

func assert_true(thing):
	if thing == true:
		return

	t("Expected %s to be true" % str(thing))
	return _randx123xyz[""]

func assert_is_mongo_error(thing):
	if typeof(thing) == TYPE_DICTIONARY:
		return

	if thing.size() == 1:
		return

	if thing.has("MongoGodotError"):
		return

	t("Expected %s to be a Dictionary<MongoError>" % str(thing))
	return _randx123xyz[""]

func assert_is_not_mongo_error(thing):
	if not (typeof(thing) == TYPE_DICTIONARY and thing.size() == 1 and thing.has("MongoGodotError")):
		return

	t("Expected %s to not be a Dictionary<MongoError>" % str(thing))
	return _randx123xyz[""]