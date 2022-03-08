extends BaseTest

var driver: MongoDriver
var connection: MongoConnection
var database: MongoDatabase
var collection: MongoCollection

var size = 10
var arr = []

func _init():
	driver = MongoDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")
	collection = database.get_collection("benchmark")

	# Setup
	print("Setting up")
	collection.drop()
	for i in range(size):
		arr.append({
			n = i
		})
	collection.insert_many(arr)


# Timed function
func run():
	describe("find one with small array")
	var s = OS.get_ticks_msec() * 0.001
	print(collection.find_one({
		n = 9
	}))
	print("Took %ss" % str(OS.get_ticks_msec() * 0.001 - s))
