extends BaseTest

var driver: MongoDriver
var connection: MongoConnection
var database: MongoDatabase
var collection: MongoCollection

var size = 5

func _init():
	driver = MongoDriver.new()
	connection = driver.connect_to_server(Env.get_var("MONGODB_URI"))
	database = connection.get_database("test")
	collection = database.get_collection("benchmark")

	# Setup
	print("Setting up")
	collection.drop()


# Timed function
func run():
	describe("insert one with small array")

	var s = OS.get_ticks_msec() * 0.001
	for i in range(size):
		collection.insert_one({
			n = i
		})

	print("Took %ss" % str(OS.get_ticks_msec() * 0.001 - s))
