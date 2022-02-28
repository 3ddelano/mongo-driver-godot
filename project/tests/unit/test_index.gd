extends BaseTest

var driver
var connection
var database

func _init():
	driver = MongoGodotDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")

func run():
	describe("Index")
	var collection
	var res

	test("create an index")
	collection = database.get_collection("test_col")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			score = 1
		}
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "name")
	assert_eq(res["name"], "score_1")


	test("create an index", "with index options")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			cuisine = 1,
			name = 1
		},
		options = {
			name = "custom_name123"
		}
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "name")
	assert_eq(res["name"], "custom_name123")

	test("create index", "with options")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			rating = -1,
			wins = -1
		}
	}, {
		max_time = 1
	})
	print(res)