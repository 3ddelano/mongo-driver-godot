# Base class with helper functions for MongoDB
# @tags - Mongo, Class, Helper
class_name Mongo
extends Reference

class FindOneOptions:
	enum ReturnDocument {
		BEFORE,
		AFTER
	}

class FindOptions:
	enum CursorType {
		NON_TAILABLE,
		TAILABLE,
		TAILABLE_AWAIT
	}

static func is_error(obj):
	return typeof(obj) == TYPE_DICTIONARY and obj.has("MongoGodotError")


# ----- Operators -----

static func ObjectId(id) -> Dictionary:
	assert(typeof(id) == TYPE_STRING, "id passed to ObjectId must be a String")
	assert(id.length() == 24, "ObjectId must be 24 characters")
	return {
		"$oid": id
	}

static func Date(date) -> Dictionary:
	return {
		"$date": date
	}

static func Set(dict) -> Dictionary:
	assert(typeof(dict) == TYPE_DICTIONARY, "Invalid Dictionary to set operator")
	return {
		"$set": dict
	}

static func Cmp(val) -> Dictionary:
	return {
		"$cmp": val
	}

static func Eq(val) -> Dictionary:
	return {
		"$eq": val
	}

static func Lt(val) -> Dictionary:
	assert(typeof(val) in [TYPE_INT, TYPE_REAL], "Invalid number to less than operator")
	return {
		"$lt": val
	}

static func Lte(val) -> Dictionary:
	assert(typeof(val) in [TYPE_INT, TYPE_REAL], "Invalid number to less than or equal to operator")
	return {
		"$lte": val
	}

static func Gt(val) -> Dictionary:
	assert(typeof(val) in [TYPE_INT, TYPE_REAL], "Invalid number to greater than operator")
	return {
		"$gt": val
	}

static func Gte(val) -> Dictionary:
	assert(typeof(val) in [TYPE_INT, TYPE_REAL], "Invalid number to greater than or equal to operator")
	return {
		"$gte": val
	}

static func In(val) -> Dictionary:
	return {
		"$in": val
	}

static func Nin(val) -> Dictionary:
	return {
		"$nin": val
	}

static func Ne(val) -> Dictionary:
	return {
		"$ne": val
	}


# ----- Logical -----
static func And(val) -> Dictionary:
	return {
		"$and": val
	}

static func Or(val) -> Dictionary:
	return {
		"$or": val
	}

static func Not(val) -> Dictionary:
	return {
		"$not": val
	}

static func Nor(val) -> Dictionary:
	return {
		"$nor": val
	}


# ----- Date -----
static func DateAdd(val):
	return {
		"$dateAdd": val
	}

static func DateDiff(val):
	return {
		"$dateDiff": val
	}

static func DateFromParts(val):
	return {
		"$dateFromParts": val
	}

static func DateFromString(val):
	return {
		"$dateFromString": val
	}

static func DateSubtract(val):
	return {
		"$dateSubtract": val
	}

static func DateToParts(val):
	return {
		"$dateToParts": val
	}

static func DateToString(val):
	return {
		"$dateToString": val
	}

static func DateTrunc(val):
	return {
		"$dateTrunc": val
	}

static func DayOfMonth(val):
	return {
		"$dayOfMonth": val
	}

static func DayOfWeek(val):
	return {
		"$dayOfWeek": val
	}

static func DayOfYear(val):
	return {
		"$dayOfYear": val
	}

static func Hour(val):
	return {
		"$hour": val
	}

static func IsoDayOfWeek(val):
	return {
		"$isoDayOfWeek": val
	}

static func IsoWeek(val):
	return {
		"$isoWeek": val
	}

static func IsoWeekYear(val):
	return {
		"$isoWeekYear": val
	}

static func Millisecond(val):
	return {
		"$millisecond": val
	}

static func Minute(val):
	return {
		"$minute": val
	}

static func Month(val):
	return {
		"$month": val
	}

static func Second(val):
	return {
		"$second": val
	}

static func ToDate(val):
	return {
		"$toDate": val
	}

static func Subtract(val):
	return {
		"$subtract": val
	}


# ----- Update -----
static func CurrentDate(val) -> Dictionary:
	return {
		"$currentDate": val
	}

static func Inc(val) -> Dictionary:
	return {
		"$inc": val
	}

static func Min(val) -> Dictionary:
	return {
		"$min": val
	}

static func Max(val) -> Dictionary:
	return {
		"$max": val
	}

static func Mul(val) -> Dictionary:
	return {
		"$mul": val
	}

static func Rename(val) -> Dictionary:
	return {
		"$rename": val
	}

static func SetOnInsert(val) -> Dictionary:
	return {
		"$setOnInsert": val
	}


# ----- Array -----
static func All(val) -> Dictionary:
	return {
		"$all": val
	}

static func ElemMatch(val) -> Dictionary:
	return {
		"$elemMatch": val
	}

static func Size(val) -> Dictionary:
	return {
		"$size": val
	}

static func AddToSet(val) -> Dictionary:
	return {
		"$addToSet": val
	}

static func Pop(val) -> Dictionary:
	return {
		"$pop": val
	}

static func Pull(val) -> Dictionary:
	return {
		"$pull": val
	}

static func Push(val) -> Dictionary:
	return {
		"$push": val
	}

static func PullAll(val) -> Dictionary:
	return {
		"$pullAll": val
	}


# ----- Array Expression -----
static func ArrayElemAt(val):
	return {
		"$arrayElemAt": val
	}

static func ArrayToObject(val):
	return {
		"$arrayToObject": val
	}

static func ConcatArrays(val):
	return {
		"$concatArrays": val
	}

static func Filter(val):
	return {
		"$filter": val
	}

static func First(val):
	return {
		"$first": val
	}

static func IndexOfArray(val):
	return {
		"$indexOfArray": val
	}

static func IsArray(val):
	return {
		"$isArray": val
	}

static func Last(val):
	return {
		"$last": val
	}

static func Map(val):
	return {
		"$map": val
	}

static func ObjectToArray(val):
	return {
		"$objectToArray": val
	}

static func Range(val):
	return {
		"$range": val
	}

static func Reduce(val):
	return {
		"$reduce": val
	}

static func ReverseArray(val):
	return {
		"$reverseArray": val
	}

static func Slice(val):
	return {
		"$slice": val
	}

static func Zip(val):
	return {
		"$zip": val
	}


# ----- Modifiers -----
static func Each(val) -> Dictionary:
	return {
		"$each": val
	}

static func Position(val) -> Dictionary:
	return {
		"$position": val
	}

static func Sort(val) -> Dictionary:
	return {
		"$sort": val
	}


# ----- Element -----
static func Exists(val) -> Dictionary:
	return {
		"$exists": val
	}

static func Type(val) -> Dictionary:
	return {
		"$type": val
	}


# ----- Evaluation -----
static func Expr(val) -> Dictionary:
	return {
		"$expr": val
	}

static func JsonSchema(val) -> Dictionary:
	return {
		"$jsonSchema": val
	}

static func Regex(val, options := "") -> Dictionary:
	return {
		"$regex": val,
		"$options": options
	}

static func Text(val) -> Dictionary:
	return {
		"$text": val
	}

static func Where(val) -> Dictionary:
	return {
		"$where": val
	}


# ----- Misc -----
static func Comment(val) -> Dictionary:
	return {
		"$comment": val
	}

static func Rand(val) -> Dictionary:
	return {
		"$rand": val
	}

static func GetField(val) -> Dictionary:
	return {
		"$getField": val
	}

static func SampleRate(val) -> Dictionary:
	return {
		"$sampleRate": val
	}


# ----- Custom -----
static func Accumulator(val) -> Dictionary:
	return {
		"$accumulator": val
	}

static func Function(val) -> Dictionary:
	return {
		"$function": val
	}


# ----- Literal -----
static func MergeObjects(val) -> Dictionary:
	return {
		"$mergeObjects": val
	}

static func SetField(val) -> Dictionary:
	return {
		"$setField": val
	}


#static func Date(unixtime = OS.get_unix_time()):
#	var datetime = OS.get_datetime_from_unix_time(unixtime)
#	var timezone = OS.get_time_zone_info()
#	var zone_sign = "+" if timezone.bias >= 0 else "-"
#
#	var zone_minute = abs(timezone.bias)
#	var zone_hour = int(zone_minute / 60)
#	zone_minute -= zone_hour * 60
#
#	return {
#		"$date": "%s-%s-%sT%s:%s:%s+00:00" % [str(datetime.year).pad_zeros(4), str(datetime.month).pad_zeros(2), str(datetime.day).pad_zeros(2), str(datetime.hour).pad_zeros(2), str(datetime.minute).pad_zeros(2), str(datetime.second).pad_zeros(2)]
#	}
