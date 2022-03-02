extends BaseTest

var driver
var connection
var database
var collection
var indexes

func _init():
	driver = MongoDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")
	collection = database.get_collection("test_col")

func _setup():
	collection.drop()
	collection.insert_one({ n = 1})

func run():
	describe("Index")
	var res
	var index_models

	test("collection.create index")
	_setup()
	res = collection.create_index({
		keys = {
			score = 1
		}
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "name")
	assert_eq(res["name"], "score_1")


	test("get indexes")
	_setup()
	indexes = collection.get_indexes()
	res = collection.create_index({
		keys = {
			score = 1
		}
	})
	assert_is_not_mongo_error(res)
	res = indexes.list()
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 2)
	assert_eq(res[0]["name"], "_id_")
	assert_eq(res[1]["name"], "score_1")


	test("create one", "with document and options")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			name = 1
		},
		options = {
			name = "custom_name123",
		}
	}, {})
	assert_eq(res, "custom_name123")


	test("create one", "with document and no options")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			cuisine = -1
		}
	}, {})
	assert_eq(res, "cuisine_-1")


	test("create one", "with max_time option")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			aaa = 1
		}
	}, {
		max_time = 1
	})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("operation exceeded time limit"), -1)


	test("create one", "with same keys and options")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			a = 1
		},
	}, {})
	assert_eq(res, "a_1")
	res = indexes.create_one({
		keys = {
			a = 1
		},
	}, {})
	assert_is_mongo_error(res)


	test("create one", "with same name")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			a = 1
		},
		options = {
			name = "hello"
		}
	}, {})
	assert_eq(res, "hello")
	res = indexes.create_one({
		keys = {
			a = 1
		},
		options = {
			name = "hello"
		}
	}, {})
	assert_is_mongo_error(res)


	## Only works if server supports replica set
	# test("create one", "with commit_quorum option")
	# _setup()
	# indexes = collection.get_indexes()
	# res = indexes.create_one({
	# 	keys = {
	# 		a = 1
	# 	}
	# }, {
	# 	commit_quorum = 1
	# })
	# print(res)


	index_models = [
		{
			keys = {
				a = 1
			}
		},
		{
			keys = {
				b = 1,
				c = -1
			}
		},
		{
			keys = {
				c = -1
			}
		}
	]


	test("create many")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_many(index_models, {})
	assert_eq(res["ok"], 1)
	assert_eq(res["numIndexesBefore"], 1)
	assert_eq(res["numIndexesAfter"], 4)


	test("create many", "with max_time option")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_many(index_models, {
		max_time = 1
	})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("operation exceeded time limit"), -1)


	test("drop one", "by name")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {a = 1}
	}, {})
	assert_eq(res, "a_1")
	assert_size(indexes.list(), 2)
	res = indexes.drop_one("a_1")
	assert_true(res)
	assert_size(indexes.list(), 1)


	test("drop one", "by key")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {a = 1}
	}, {})
	assert_eq(res, "a_1")
	assert_size(indexes.list(), 2)
	res = indexes.drop_one({
		keys = {
			a = 1
		}
	})
	assert_true(res)
	assert_size(indexes.list(), 1)


	test("drop one", "with name = *")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.drop_one("*")
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("out-of-bounds"), -1)


	test("drop one", "for index which doesnt exist")
	_setup()
	indexes = collection.get_indexes()
	res = indexes.drop_one("a_1")
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("index not found with name"), -1)


	test("drop all")
	_setup()
	indexes = collection.get_indexes()
	indexes.create_many([
		{
			keys = {a = 1}
		},
		{
			keys = {b = 1}
		}
	], {})
	assert_size(indexes.list(), 3)
	res = indexes.drop_all()
	assert_size(indexes.list(), 1)


	test("drop all", "with max_time")
	indexes = collection.get_indexes()
	indexes.drop_all()
	indexes.create_many([
		{
			keys = {a = 1}
		},
		{
			keys = {b = 1}
		}
	])
	assert_size(indexes.list(), 3)
	res = indexes.drop_all({
		max_time = -1,
	})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("value for maxTimeMS is out of range"), -1)


	test("create and delete index with collation")
	_setup()
	indexes = collection.get_indexes()
	indexes.create_one({
		keys = {
			a = 1,
			bcd = -1,
			d = 1
		},
		options = {
			collation = {locale = "en_US"}
		}
	}, {})
	indexes.create_one({
		keys = {
			a = 1,
			bcd = -1,
			d = 1
		},
		options = {
			name = "custom_index11",
			collation = {locale = "ko"}
		}
	}, {})
	assert_size(indexes.list(), 3)
	res = indexes.drop_one("a_1_bcd_-1_d_1")
	assert_true(res)
	res = indexes.list()
	assert_size(res, 2)
	assert_eq(res[1]["name"], "custom_index11")


