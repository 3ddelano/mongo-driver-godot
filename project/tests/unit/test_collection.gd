extends BaseTest

var driver
var connection
var database

func _init():
	driver = MongoGodotDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")

func get_database(name):
	return connection.get_database(name)

func run():
	describe("Collection")

	var collection
	var collection2
	var res
	var docs
	var doc

	test("default constructed collection cannot call methods")
	collection = MongoGodotCollection.new()
	res = collection.find({}) # Must pass in empty Dictionary
	assert_is_mongo_error(res)


	test("rename")
	collection = database.get_collection("test_col")
	collection2 = database.get_collection("test2_col")
	assert_is_not_mongo_error(collection.drop())
	assert_is_not_mongo_error(collection2.drop())
	res = collection.insert_one({
		n = "test_doc"
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"].length(), 24)
	res = collection2.insert_one({n = "test2_doc"})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"].length(), 24)
	assert_true(collection.rename("test2_col"))
	assert_eq(collection.get_name(), "test2_col")
	assert_true(collection2.rename("test3_col"))
	assert_eq(collection2.get_name(), "test3_col")

	test("drop")
	collection = database.get_collection("test_col")
	collection.drop()
	res = collection.insert_one({ n = 1})
	assert_eq(collection.find({}).size(), 1)
	collection.drop()
	assert_eq(collection.find({}).size(), 0)


	test("CRUD", "insert and read single document")
	collection = database.get_collection("test_col")
	res = collection.insert_one({ _id = MongoGodot.ObjectId("123456789012345678901245")})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"].length(), 24)
	res = collection.find_one({ _id = MongoGodot.ObjectId("123456789012345678901245")})
	assert_eq(res["_id"]["$oid"], "123456789012345678901245")


	test("CRUD", "insert with bypass_document_validation")
	database.get_collection("test_col").drop()
	collection = database.create_collection("test_col", {
		validator = {
			_id = MongoGodot.Eq("baz")
		}
	})

	res = collection.insert_one({ _id = "foo"}, {
		bypass_document_validation = true
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_has(res, "inserted_count")
	assert_eq(res["inserted_count"], 1)
	assert_has(res, "inserted_id")
	assert_eq(res["inserted_id"], "foo")
	collection.drop()


	test("CRUD", "insert and read multiple documents")
	collection = database.get_collection("test_col")
	collection.drop()
	docs = [
		{
			_id = MongoGodot.ObjectId("123456789012345678901423"),
			n = 1
		},
		{
			n = 2
		},
		{
			n = 3
		},
		{
			_id = MongoGodot.ObjectId("123456789012345678901424"),
			n = 4
		},
	]
	res = collection.insert_many(docs)
	assert_eq(res["inserted_count"], 4)
	assert_has(res, "inserted_ids")
	assert_size(res["inserted_ids"], 4)
	assert_has(res["inserted_ids"], "123456789012345678901423")
	assert_has(res["inserted_ids"], "123456789012345678901424")
	res = collection.find({})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 4)
	assert_eq(res[0]["_id"]["$oid"], "123456789012345678901423")
	assert_eq(res[0]["n"], 1)
	assert_eq(res[1]["n"], 2)
	assert_eq(res[2]["n"], 3)
	assert_eq(res[3]["_id"]["$oid"], "123456789012345678901424")
	assert_eq(res[3]["n"], 4)


	test("CRUD", "insert many with bypass document validation")
	collection.drop()
	collection = database.create_collection("test_col", {
		validator = {
			n = MongoGodot.Eq("3ddelano")
		}
	})
	res = collection.insert_many(docs, {
		bypass_document_validation = true
	})
	assert_eq(res["inserted_count"], 4)
	assert_eq(res["inserted_ids"].size(), 4)
	assert_has(res["inserted_ids"], "123456789012345678901423")
	assert_has(res["inserted_ids"], "123456789012345678901424")
	res = collection.find({})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 4)
	assert_eq(res[0]["_id"]["$oid"], "123456789012345678901423")
	assert_eq(res[0]["n"], 1)
	assert_eq(res[1]["n"], 2)
	assert_eq(res[2]["n"], 3)
	assert_eq(res[3]["_id"]["$oid"], "123456789012345678901424")
	assert_eq(res[3]["n"], 4)


	test("CRUD", "find does not leak on error")
	collection.drop()
	res = collection.find({}, {
		max_await_time = -1
	})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("out-of-bounds parameter was provided"), -1)


	test("CRUD", "find with collation (case insensitive)")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.find({n = "FOO"}, {
		collation = {
			locale = "en_US",
			strength = 2
		}
	})
	assert_typeof(res, TYPE_ARRAY)
	assert_eq(res[0]["n"], "foo")

	
	test("CRUD", "find with return key")
	collection.drop()
	collection.insert_one({a = 3})

	var key = {a = 1}
	# var indexes = collection.get_indexes()
	# print(indexes.create_one({a = 1}))
	res = collection.find({a = 3}, {
		return_key = true
	})
	print(res)












