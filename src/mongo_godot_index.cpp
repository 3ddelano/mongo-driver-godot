#include <mongo_godot_index.h>

void MongoGodotIndex::_register_methods() {
    register_method("list", &MongoGodotIndex::list);
    register_method("create_one", &MongoGodotIndex::create_one);
    register_method("create_many", &MongoGodotIndex::create_many);
    register_method("drop_one", &MongoGodotIndex::drop_one);
    register_method("drop_all", &MongoGodotIndex::drop_all);
}

Variant MongoGodotIndex::list() {
    ENSURE_INDEX_SETUP();
    try {
        mongocxx::cursor cursor = _collection.indexes().list();
        Array arr;
        for (auto doc : cursor) {
            arr.push_back(BSON_DOCUMENT_TO_DICT(doc));
        }
        return arr;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotIndex::create_one(Dictionary p_index, Dictionary p_options) {
    ENSURE_INDEX_SETUP();
    if (p_index.empty()) {
        return ERR_DICT("index cannot be empty.");
    }
    if (!p_index.has("keys")) {
        return ERR_DICT("index must have a keys Dictionary.");
    }

    try {
        Dictionary keys = p_index["keys"];
        bsoncxx::document::view_or_value keys_bson = DICT_TO_BSON(keys);
        bsoncxx::document::view_or_value index_options_bson;

        if (p_index.has("options")) {
            Dictionary index_options = p_index["options"];
            index_options_bson = DICT_TO_BSON(index_options);
        }
        mongocxx::options::index_view options;

        if (!p_options.empty()) {
            _parse_index_view_options(options, p_options);
        }

        auto result = _collection.indexes().create_one(keys_bson, index_options_bson, options);
        if (!result) {
            return ERR_DICT("index creation failed.");
        }
        return String(result.value().c_str());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotIndex::create_many(Array p_indexes, Dictionary p_options) {
    ENSURE_INDEX_SETUP();
    try {
        std::vector<mongocxx::index_model> indexes;
        mongocxx::options::index_view options;

        for (int i = 0; i < p_indexes.size(); i++) {
            Dictionary index = p_indexes[i];
            Dictionary keys = index["keys"];

            bsoncxx::document::view_or_value keys_bson = DICT_TO_BSON(keys);
            bsoncxx::document::view_or_value index_options_bson;

            if (index.has("options")) {
                Dictionary options = index["options"];
                index_options_bson = DICT_TO_BSON(options);
            }

            mongocxx::index_model index_model = mongocxx::index_model(keys_bson, index_options_bson);
            indexes.push_back(index_model);
        }

        if (!p_options.empty()) {
            _parse_index_view_options(options, p_options);
        }

        auto result = _collection.indexes().create_many(indexes, options);
        return BSON_DOCUMENT_TO_DICT(result);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotIndex::drop_one(Variant p_name_or_index, Dictionary p_options) {
    ENSURE_INDEX_SETUP();
    try {
        mongocxx::options::index_view options;
        if (!p_options.empty()) {
            _parse_index_view_options(options, p_options);
        }

        if (p_name_or_index.get_type() == Variant::DICTIONARY) {
            Dictionary index = p_name_or_index;
            if (!index.has("keys")) {
                return ERR_DICT("index must have a keys Dictionary.");
            }

            Dictionary keys = index["keys"];
            bsoncxx::document::view_or_value keys_bson = DICT_TO_BSON(keys);
            bsoncxx::document::view_or_value options_bson;

            if (index.has("options")) {
                Dictionary options = index["options"];
                options_bson = DICT_TO_BSON(options);
            }

            _collection.indexes().drop_one(keys_bson, options_bson, options);
            return true;
        } else if (p_name_or_index.get_type() == Variant::STRING) {
            String keys = p_name_or_index;
            _collection.indexes().drop_one(keys.utf8().get_data(), options);
            return true;
        }
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotIndex::drop_all(Dictionary p_options) {
    ENSURE_INDEX_SETUP();
    try {
        mongocxx::options::index_view options;
        if (!p_options.empty()) {
            _parse_index_view_options(options, p_options);
        }
        _collection.indexes().drop_all(options);
        return true;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

void MongoGodotIndex::_parse_index_view_options(mongocxx::options::index_view& options, Dictionary p_options) {
    if (p_options.has("max_time")) {
        int max_time = p_options["max_time"];
        options.max_time(std::chrono::milliseconds(max_time));
    }
    // TODO: support write_concern
    if (p_options.has("write_concern"))
        WARN_PRINT("write_concern is not yet supported.");

    if (p_options.has("commit_quorum")) {
        if (p_options["commit_quorum"].get_type() == Variant::INT) {
            options.commit_quorum((int) p_options["commit_quorum"]);
        }

        if (p_options["commit_quorum"].get_type() == Variant::STRING) {
            String commit_quorum = p_options["commit_quorum"];
            options.commit_quorum(commit_quorum.utf8().get_data());
        }
    }
}