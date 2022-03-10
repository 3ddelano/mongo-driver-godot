extends BaseTest

var driver
var connection
var database

func _init():
	driver = MongoDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")

func get_database(name):
	return connection.get_database(name)

func run():
	describe("Collection")

	var collection: MongoCollection
	var collection2: MongoCollection
	var res
	var docs
	var doc

	var case_insensitive_collation = {
		locale = "en_US",
		strength = 2
	}

	test("get name")
	database.drop()
	collection = database.get_collection("test123")
	assert_eq(collection.get_name(), "test123")
	collection = database.get_collection("hello312")
	assert_eq(collection.get_name(), "hello312")


	test("rename")
	database.drop()
	collection = database.get_collection("test_col")
	collection2 = database.get_collection("test2_col")
	assert_true(collection.drop())
	assert_true(collection2.drop())
	res = collection.insert_one({
		n = "test_doc"
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["inserted_count"], 1)
	assert_eq(res["inserted_id"].length(), 24)
	res = collection2.insert_one({n = "test2_doc"})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["inserted_count"], 1)
	assert_eq(res["inserted_id"].length(), 24)
	res = collection.rename("test2_col")
	assert_gt(res["MongoGodotError"].find("target namespace exists"), -1)
	res = collection.rename("test2_col")
	assert_gt(res["MongoGodotError"].find("target namespace exists"), -1)
	assert_true(collection.rename("valid_col1"))
	assert_true(collection2.rename("valid_col2"))
	assert_eq(collection.get_name(), "valid_col1")
	assert_eq(collection2.get_name(), "valid_col2")
	assert_true(collection2.rename("valid_col3"))
	assert_eq(collection2.get_name(), "valid_col3")


	test("drop")
	collection = database.get_collection("test_col")
	collection.drop()
	res = collection.insert_one({ n = 1})
	assert_eq(collection.find({}).size(), 1)
	collection.drop()
	assert_eq(collection.find({}).size(), 0)


	test("CRUD", "insert and read single document")
	collection = database.get_collection("test_col")
	res = collection.insert_one({ _id = Mongo.ObjectId("123456789012345678901245")})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["inserted_count"], 1)
	assert_eq(res["inserted_id"].length(), 24)
	res = collection.find_one({ _id = Mongo.ObjectId("123456789012345678901245")})
	assert_eq(res["_id"]["$oid"], "123456789012345678901245")


	test("CRUD", "insert with bypass_document_validation")
	database.get_collection("test_col").drop()
	collection = database.create_collection("test_col", {
		validator = {
			_id = Mongo.Eq("baz")
		}
	})

	res = collection.insert_one({ _id = "foo"}, {
		bypass_document_validation = true
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["inserted_count"], 1)
	assert_eq(res["inserted_id"], "foo")
	collection.drop()


	test("CRUD", "insert and read multiple documents")
	collection = database.get_collection("test_col")
	collection.drop()
	docs = [
		{
			_id = Mongo.ObjectId("123456789012345678901423"),
			n = 1
		},
		{ n = 2 },
		{ n = 3 },
		{
			_id = Mongo.ObjectId("123456789012345678901424"),
			n = 4
		}
	]
	res = collection.insert_many(docs)
	assert_eq(res["inserted_count"], 4)
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
			n = Mongo.Eq("3ddelano")
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


	test("CRUD", "find returns an error for invalid max_await_time")
	collection.drop()
	res = collection.find({}, {
		max_await_time = -1
	})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("out-of-bounds parameter was provided"), -1)


	test("CRUD", "find with collation (case insensitive)")
	collection.drop()
	res = collection.insert_one({n = "foo"})
	assert_is_not_mongo_error(res)
	res = collection.find({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_typeof(res, TYPE_ARRAY)
	assert_eq(res[0]["n"], "foo")


	test("CRUD", "find with return_key")
	collection.drop()
	res = collection.insert_one({a = 3})
	assert_is_not_mongo_error(res)
	var indexes = collection.get_indexes()
	res = indexes.create_one({
		keys = {
			a = 1
		}
	})
	assert_typeof(res, TYPE_STRING)
	assert_eq(res, "a_1")
	res = collection.find({a = 3}, {
		return_key = true
	})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 1)
	assert_not_has(res[0], "_id")
	assert_eq(res[0]["a"], 3)


	test("CRUD", "find one with show_record_id")
	collection.drop()
	res = collection.insert_one({a = 3})
	assert_is_not_mongo_error(res)
	res = collection.find_one({}, {
		show_record_id = true
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["$recordId"], 1)
	assert_eq(res["a"], 3)


	test("CRUD", "find one with collation")
	collection.drop()
	res = collection.insert_one({n = "foo"})
	assert_is_not_mongo_error(res)
	res = collection.find_one({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["n"], "foo")


	test("CRUD", "insert and update single document")
	collection.drop()
	doc = {_id = 1}
	res = collection.insert_one(doc)
	assert_is_not_mongo_error(res)
	res = collection.find_one({})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["_id"], 1)
	res = collection.update_one(doc,
		Mongo.Set({
			changed = true
		})
	)
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)
	res = collection.find_one({})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["_id"], 1)
	assert_true(res["changed"])


	test("CRUD", "update_one can take a pipeline")
	collection.drop()
	doc = {_id = 1}
	res = collection.insert_one(doc)
	assert_is_not_mongo_error(res)
	res = collection.find_one({})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["_id"], 1)
	res = collection.update_one(doc, {})
	res = collection.update_one(doc, [
		{
			"$set": {
				first_name = "Charlotte"
			},
		},
		{
			"$set": {
				last_name = "Doe"
			}
		}
	])
	res = collection.find({})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 1)
	assert_eq(res[0]["_id"], 1)
	assert_eq(res[0]["first_name"], "Charlotte")
	assert_eq(res[0]["last_name"], "Doe")


	test("CRUD", "update_one with bypass_document_validation")
	collection.drop()
	collection = database.create_collection("test_col", {
		validator = {
			changed = Mongo.Eq(false)
		}
	})
	doc = {_id = 1, changed = false}
	res = collection.insert_one(doc, {
		bypass_document_validation = true
	})
	assert_is_not_mongo_error(res)
	res = collection.update_one(doc,
		Mongo.Set({
			changed = true
		}),
		{
			bypass_document_validation = true
		}
	)
	assert_is_not_mongo_error(res)
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)


	test("CRUD", "update_one with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.update_one({n = "FOO"},
		Mongo.Set({
			changed = true
		})
	, {
		collation = case_insensitive_collation
	})
	assert_is_not_mongo_error(res)
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)


	test("CRUD", "insert and update multiple documents")
	collection.drop()
	collection.insert_one({n = 1})
	collection.insert_one({n = 1})
	collection.insert_one({n = 2})
	assert_eq(collection.count_documents({
		n = 1
	}), 2)
	res = collection.update_many({n = 1},
		Mongo.Set({changed = true})
	)
	assert_eq(collection.count_documents({
		changed = true
	}), 2)


	test("CRUD", "update_many with bypass_document_validation")
	collection.drop()
	collection = database.create_collection("test_col", {
		validator = {
			changed = Mongo.Eq(false)
		}
	})
	doc = {n = 1, changed = false}
	collection.insert_one(doc)
	collection.insert_one(doc)

	res = collection.update_many(doc,
		Mongo.Set({
			changed = true
		})
	, {
		bypass_document_validation = true
	})
	assert_is_not_mongo_error(res)
	assert_eq(res["matched_count"], 2)
	assert_eq(res["modified_count"], 2)


	test("CRUD", "update_many with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	collection.insert_one({n = "foo"})
	res = collection.update_many({n = "FOO"},
		Mongo.Set({n = "bar"}),
	{
		collation = case_insensitive_collation
	})
	assert_is_not_mongo_error(res)
	assert_eq(res["matched_count"], 2)
	assert_eq(res["modified_count"], 2)


	test("CRUD", "replace_one replaces only one document")
	collection.drop()
	collection.insert_one({n = 1})
	collection.insert_one({n = 1})
	assert_eq(collection.count_documents({}), 2)
	res = collection.replace_one({n = 1}, {n = 2})
	assert_eq(collection.count_documents({n = 1}), 1)
	assert_eq(collection.count_documents({n = 2}), 1)


	test("CRUD", "non matching upsert creates document")
	collection.drop()
	res = collection.update_one({_id = 1},
		Mongo.Set({changed = true}),
	{
		upsert = true
	})
	assert_is_not_mongo_error(res)
	res = collection.find({})
	assert_size(res, 1)
	assert_eq(res[0]["_id"], 1)
	assert_eq(res[0]["changed"], true)


	test("CRUD", "matching upsert updates document")
	collection.drop()
	collection.insert_one({_id = 1})
	res = collection.update_one({_id = 1},
		Mongo.Set({changed = true}),
	{
		upsert = true
	})
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)
	assert_not_has(res, "upserted_id")


	test("CRUD", "count with hint")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.count_documents({}, {hint = "non_existing_index"})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("does not correspond to an existing index"), 0)


	test("CRUD", "count with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.count_documents({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_eq(res, 1)


	test("CRUD", "replace_one with bypass_document_validation")
	collection.drop()
	collection = database.create_collection("test_col", {
		validator = {
			foo = Mongo.Eq("bar")
		}
	})
	collection.insert_one({foo = "bar"})
	res = collection.replace_one({foo = "bar"}, {foo = "buzz"}, {
		bypass_document_validation = true
	})
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)


	test("CRUD", "replace_one with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.replace_one({n = "FOO"}, {n = "bar"}, {
		collation = case_insensitive_collation
	})
	assert_eq(res["matched_count"], 1)
	assert_eq(res["modified_count"], 1)


	test("CRUD", "delete_one with filtered document works")
	collection.drop()
	doc = {n = 1}
	collection.insert_one(doc)
	collection.insert_one(doc)
	collection.insert_one(doc)
	assert_eq(collection.count_documents({}), 3)
	res = collection.delete_one(doc)
	assert_eq(res["deleted_count"], 1)
	assert_eq(collection.count_documents({}), 2)


	test("CRUD", "delete_one with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.delete_one({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_eq(res["deleted_count"], 1)


	test("CRUD", "delete_many")
	collection.drop()
	collection.insert_many([{n = 1}, {n = 1}, {n = 1}, {n = 1}])
	collection.insert_many([{n = 2}, {n = 2}])
	res = collection.delete_many({n = 1})
	assert_eq(res["deleted_count"], 4)
	res = collection.delete_many({n = 2})
	assert_eq(res["deleted_count"], 2)


	test("CRUD", "delete_many with collation")
	collection.drop()
	collection.insert_many([
		{n = "foO"}, {n = "fOo"}, {n = "Foo"}, {n = "Foo"}
	])
	res = collection.delete_many({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_eq(res["deleted_count"], 4)


	test("CRUD", "find with sort")
	collection.drop()
	collection.insert_many([
		{n = 1},  {n = 3}, {n = 2}
	])
	res = collection.find({}, {sort = {n = 1}})
	assert_eq(res[0]["n"], 1)
	assert_eq(res[1]["n"], 2)
	assert_eq(res[2]["n"], 3)
	res = collection.find({}, {sort = {n = -1}})
	assert_eq(res[0]["n"], 3)
	assert_eq(res[1]["n"], 2)
	assert_eq(res[2]["n"], 1)


	test("CRUD", "find one and replace without return document returns original")
	collection.drop()
	collection.insert_one({n = "original"})
	collection.insert_one({n = "replacement"})
	res = collection.find_one_and_replace({n = "original"}, {n = "replacement"}, {})
	assert_eq(res["n"], "original")


	test("CRUD", "find one and replace with return document returns new version")
	collection.drop()
	collection.insert_one({n = "original"})
	collection.insert_one({n = "replacement"})
	res = collection.find_one_and_replace({n = "original"}, {n = "replacement"}, {
		return_document = Mongo.FindOneOptions.ReturnDocument.AFTER
	})
	assert_eq(res["n"], "replacement")


	test("CRUD", "find one and replace with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.find_one_and_replace({n = "FOO"}, {n = "bar"}, {
		collation = case_insensitive_collation,
		return_document = Mongo.FindOneOptions.ReturnDocument.AFTER
	})
	assert_eq(res["n"], "bar")


	test("CRUD", "find one and replace with bad filter")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.find_one_and_replace({n = "xyz"}, {n = "bar"}, {})
	assert_is_mongo_error(res)


	test("CRUD", "find one and replace with bypass document validation")
	collection.drop()
	collection = database.create_collection("test_col", {
		validator = {
			n = Mongo.Eq(1452)
		}
	})
	collection.insert_one({n = 1452})
	res = collection.find_one_and_replace({n = 1452}, {n = "fizz"}, {
		bypass_document_validation = true,
		return_document = Mongo.FindOneOptions.ReturnDocument.AFTER
	})
	assert_eq(res["n"], "fizz")


	test("CRUD", "find one and delete")
	collection.drop()
	collection.insert_one({n = 1})
	collection.insert_one({n = 1})
	assert_eq(collection.count_documents({}), 2)
	res = collection.find_one_and_delete({n = 1}, {})
	assert_eq(res["n"], 1)
	assert_eq(collection.count_documents({}), 1)


	test("CRUD", "find one and delete with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.find_one_and_delete({n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_eq(res["n"], "foo")
	assert_eq(collection.count_documents({}), 0)


	# TODO: aggregation testing


	test("CRUD", "distinct")
	collection.drop()
	collection.insert_many([
		{foo = "baz", abc = 1},
		{foo = "bar", abc = 2},
		{foo = "baz", abc = 3},
		{foo = "quiz", abc = 4},
	])
	res = collection.get_distinct("foo", {})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 1)
	res = res[0]
	assert_eq(res["ok"], 1)
	assert_size(res["values"], 3)
	assert_has(res["values"], "bar")
	assert_has(res["values"], "baz")
	assert_has(res["values"], "quiz")


	test("CRUD", "distinct with collation")
	collection.drop()
	collection.insert_one({n = "foo"})
	res = collection.get_distinct("n", {n = "FOO"}, {
		collation = case_insensitive_collation
	})
	assert_typeof(res, TYPE_ARRAY)
	assert_size(res, 1)
	res = res[0]
	assert_eq(res["ok"], 1)
	assert_size(res["values"], 1)
	assert_has(res["values"], "foo")


	test("create an index")
	collection = database.get_collection("test_col")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			score = 1
		}
	}, {})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["name"], "score_1")


	test("create an index", "with collation")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			cuisine = 1,
			name = 1
		},
		options = {
			name = "custom_name123",
			collation = case_insensitive_collation,
		}
	}, {})
	assert_typeof(res, TYPE_DICTIONARY)
	assert_eq(res["name"], "custom_name123")
	res = collection.get_indexes_list()[1]
	assert_eq(res["name"], "custom_name123")
	assert_has(res, "collation")


	test("create and index", "with invalid keys")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			a = 1
		},
		options = {
			name = "a"
		}
	}, {})
	assert_is_not_mongo_error(res)
	res = collection.create_index({
		keys = {
			a = -1
		},
		options = {
			name = "a"
		}
	}, {})
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("existing index has the same name"), 0)


	test("create index", "with index_view options")
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
	# 1ms is too less to create the index so it should return an error
	assert_is_mongo_error(res)
	assert_gt(res["MongoGodotError"].find("operation exceeded time limit"), -1)


	test("create index", "with storage_engine options")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			rating = -1,
		},
		options = {
			storageEngine = {
				wiredTiger = {
					configString = "block_allocation=first"
				}
			}
		}
	}, {})
	assert_eq(res["name"], "rating_-1")

	test("get indexes list")
	collection.drop()
	collection.insert_one({n = 1})
	res = collection.create_index({
		keys = {
			score = 1
		}
	}, {})
	assert_is_not_mongo_error(res)
	res = collection.create_index({
		keys = {
			n = 1
		},
		options = {
			name = "custom_name123"
		}
	}, {})
	assert_is_not_mongo_error(res)
	res = collection.get_indexes_list()
	assert_typeof(res, TYPE_ARRAY)
	assert_eq(res.size(), 3)
	assert_eq(res[0]["name"], "_id_")
	assert_eq(res[1]["name"], "score_1")
	assert_eq(res[2]["name"], "custom_name123")
