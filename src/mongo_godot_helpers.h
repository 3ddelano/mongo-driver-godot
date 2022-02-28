#ifndef MONGO_GODOT_HELPERS_H
#define MONGO_GODOT_HELPERS_H

#include <Dictionary.hpp>
#include <JSON.hpp>
#include <JSONParseResult.hpp>
#include <bsoncxx/json.hpp>

#include <mongocxx/options/index_view.hpp>

using namespace godot;

#define ERR_DICT(msg) (Dictionary::make("MongoGodotError", msg))

// bsoncxx::document::view_or_value -> Dictionary
#define BSON_DOCUMENT_TO_DICT(bson) (JSON::get_singleton()->parse(String(bsoncxx::to_json(bson).c_str()))->get_result())

// Dictionary -> bsoncxx::document::value
#define DICT_TO_BSON(dict) (bsoncxx::from_json(dict.to_json().utf8().get_data()))
// Variant -> bsoncxx::document::value
#define VARIANT_TO_BSON(variant) (bsoncxx::from_json(JSON::get_singleton()->print(variant).utf8().get_data()))
// bsoncxx::types::b_oid -> String
#define OID_TO_STRING(oid) (String(oid.value.to_string().c_str()))
// bsoncxx::types::bson_value::view -> Godot Variant
#define BSON_VALUE_TO_GODOT_VARIANT(bson_value, variant)                                                                    \
    switch (bson_value.type()) {                                                                                            \
        case bsoncxx::type::k_utf8:                                                                                         \
            variant = String(bson_value.get_utf8().value.data());                                                           \
            break;                                                                                                          \
        case bsoncxx::type::k_double:                                                                                       \
            variant = bson_value.get_double().value;                                                                        \
            break;                                                                                                          \
        case bsoncxx::type::k_document:                                                                                     \
            variant = BSON_DOCUMENT_TO_DICT(bson_value.get_document());                                                     \
            break;                                                                                                          \
        case bsoncxx::type::k_array: {                                                                                      \
            bsoncxx::document::view array = bsoncxx::document::view(bson_value.get_array().value);                          \
            variant = BSON_DOCUMENT_TO_DICT(array);                                                                         \
        } break;                                                                                                            \
        case bsoncxx::type::k_binary: {                                                                                     \
            WARN_PRINT("Binary data not yet supported.");                                                                   \
            variant = Variant();                                                                                            \
        } break;                                                                                                            \
        case bsoncxx::type::k_undefined:                                                                                    \
            variant = Variant();                                                                                            \
            break;                                                                                                          \
        case bsoncxx::type::k_oid:                                                                                          \
            variant = String(bson_value.get_oid().value.to_string().c_str());                                               \
            break;                                                                                                          \
        case bsoncxx::type::k_bool:                                                                                         \
            variant = bson_value.get_bool().value;                                                                          \
            break;                                                                                                          \
        case bsoncxx::type::k_date:                                                                                         \
            variant = (int64_t) bson_value.get_date().value.count();                                                        \
            break;                                                                                                          \
        case bsoncxx::type::k_null:                                                                                         \
            variant = Variant();                                                                                            \
            break;                                                                                                          \
        case bsoncxx::type::k_regex:                                                                                        \
            variant = Dictionary::make(                                                                                     \
                "regex",                                                                                                    \
                String(bson_value.get_regex().regex.data()),                                                                \
                "options",                                                                                                  \
                String(bson_value.get_regex().options.data()));                                                             \
            break;                                                                                                          \
        case bsoncxx::type::k_dbpointer:                                                                                    \
            variant = Dictionary::make(                                                                                     \
                "collection",                                                                                               \
                String(bson_value.get_dbpointer().collection.data()),                                                       \
                "value",                                                                                                    \
                String(bson_value.get_dbpointer().value.to_string().c_str()));                                              \
            break;                                                                                                          \
        case bsoncxx::type::k_code:                                                                                         \
            variant = String(bson_value.get_code().code.data());                                                            \
            break;                                                                                                          \
        case bsoncxx::type::k_symbol:                                                                                       \
            variant = String(bson_value.get_symbol().symbol.data());                                                        \
            break;                                                                                                          \
        case bsoncxx::type::k_codewscope:                                                                                   \
            variant = Dictionary::make(                                                                                     \
                "code",                                                                                                     \
                String(bson_value.get_codewscope().code.data()),                                                            \
                "scope",                                                                                                    \
                BSON_DOCUMENT_TO_DICT(bson_value.get_codewscope().scope));                                                  \
            break;                                                                                                          \
        case bsoncxx::type::k_int32:                                                                                        \
            variant = bson_value.get_int32().value;                                                                         \
            break;                                                                                                          \
        case bsoncxx::type::k_int64:                                                                                        \
            variant = bson_value.get_int64().value;                                                                         \
            break;                                                                                                          \
        case bsoncxx::type::k_timestamp: {                                                                                  \
            int increment = bson_value.get_timestamp().increment;                                                           \
            int timestamp = bson_value.get_timestamp().timestamp;                                                           \
            variant = Dictionary::make("increment", increment, "timestamp", timestamp);                                     \
        } break;                                                                                                            \
        case bsoncxx::type::k_decimal128:                                                                                   \
            variant = String(bson_value.get_decimal128().value.to_string().c_str());                                        \
            break;                                                                                                          \
        default:                                                                                                            \
            variant = ERR_DICT("Unsupported BSON value.");                                                                  \
            break;                                                                                                          \
    }

#define OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(from_dict, key, type, method)                                                \
    if (from_dict.has(key))                                                                                                 \
        method((type) from_dict[key]);

static void DICT_TO_INDEX_VIEW_OPTIONS(const Dictionary& options, mongocxx::options::index_view& index_options) {
    if (options.has("max_time")) {
        auto max_time = std::chrono::milliseconds((long long) options["max_time"]);
        index_options.max_time(max_time);
    }

    // TODO: support write_concern
    if (options.has("write_concern"))
        WARN_PRINT("write_concern is not yet supported.");

    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(options, "commit_quorum", int, index_options.commit_quorum);
}

#endif
