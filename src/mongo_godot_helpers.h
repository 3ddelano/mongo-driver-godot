#ifndef MONGOGODOTHELPERS_H
#define MONGOGODOTHELPERS_H

#include <Dictionary.hpp>
#include <JSON.hpp>
#include <JSONParseResult.hpp>
#include <bsoncxx/json.hpp>

using namespace godot;
// bsoncxx::document::view_or_value -> Dictionary
#define BSON_TO_DICT(bson) (JSON::get_singleton()->parse(String(bsoncxx::to_json(bson).c_str()))->get_result())
// Dictionary -> bsoncxx::document::value
#define DICT_TO_BSON(dict) (bsoncxx::from_json(dict.to_json().utf8().get_data()))
// Variant -> bsoncxx::document::value
#define VARIANT_TO_BSON(variant) (bsoncxx::from_json(JSON::get_singleton()->print(variant).utf8().get_data()))
// bsoncxx::types::b_oid -> String
#define OID_TO_STRING(oid) (String(oid.value.to_string().c_str()))

#define ERR_DICT(msg) (Dictionary::make("MongoGodotError", msg))

#endif