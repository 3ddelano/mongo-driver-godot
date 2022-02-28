#include <mongo_godot_index.h>

void MongoGodotIndex::_register_methods() {
    register_method("list", &MongoGodotIndex::list);
    register_method("create_one", &MongoGodotIndex::create_one);
    register_method("create_many", &MongoGodotIndex::create_many);
    register_method("drop_one", &MongoGodotIndex::drop_one);
    register_method("drop_all", &MongoGodotIndex::drop_all);
}

Variant MongoGodotIndex::list() {
    // try {
    //     mongocxx::cursor cursor = index.list();
    //     Array arr;
    //     for (auto doc : cursor) {
    //         // arr.push_back();
    //     }
    // } catch (mongocxx::exception& e) {
    // }
    return Variant();
}

Variant MongoGodotIndex::create_one(Dictionary p_index, Dictionary p_options) {
    ENSURE_INDEX_SETUP();
    if (p_index.empty()) {
        return ERR_DICT("index cannot be empty.");
    }
    if (!p_index.has("keys")) {
        return ERR_DICT("index must have a keys Dictionary.");
    }
    if (!p_index.has("options")) {
        return ERR_DICT("index must have a options Dictionary.");
    }
    try {
        Dictionary keys = p_index["keys"];
        Dictionary index_options = p_index["options"];

        bsoncxx::document::view_or_value keys_bson = DICT_TO_BSON(keys);
        bsoncxx::document::view_or_value index_options_bson = DICT_TO_BSON(index_options);
        mongocxx::options::index_view options;

        if (!p_options.empty()) {
            // DICT_TO_INDEX_VIEW_OPTIONS(p_options, options);
        }

        auto result = index->create_one(keys_bson, index_options_bson, options);
        if (!result) {
            return ERR_DICT("index creation failed.");
        }
        return String(result.value().c_str());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotIndex::create_many(Array p_indexes, Dictionary p_options) {
    return Variant();
}

Dictionary MongoGodotIndex::drop_one(Variant p_name_or_keys, Dictionary p_options) {
    return Dictionary();
}

Dictionary MongoGodotIndex::drop_all(Dictionary p_options) {
    return Dictionary();
}