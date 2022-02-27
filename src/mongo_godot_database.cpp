#include <mongo_godot_database.h>

void MongoGodotDatabase::_register_methods() {
    register_method("get_collection_names", &MongoGodotDatabase::get_collection_names);
    register_method("get_collection", &MongoGodotDatabase::get_collection);
    register_method("run_command", &MongoGodotDatabase::run_command);
    register_method("drop", &MongoGodotDatabase::drop);
}

void MongoGodotDatabase::_init() {
}

void MongoGodotDatabase::_set_database(mongocxx::database p_database) {
    _database = p_database;
}

Variant MongoGodotDatabase::get_collection_names(Dictionary p_filter) {
    ENSURE_DATABASE_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        std::vector<std::string> collectionVector = _database.list_collection_names(filter_bson.view());
        Array collections = Array();
        for (auto& collection : collectionVector) {
            collections.push_back(String(collection.c_str()));
        }
        return collections;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotDatabase::get_collection(String p_collection_name) {
    ENSURE_DATABASE_SETUP();
    try {
        mongocxx::collection collection = _database.collection(p_collection_name.utf8().get_data());
        Ref<MongoGodotCollection> ref = (Ref<MongoGodotCollection>) MongoGodotCollection::_new();
        ref->_set_collection(collection);
        return ref;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotDatabase::run_command(Dictionary p_command) {
    ENSURE_DATABASE_SETUP();
    try {
        bsoncxx::document::value command_bson = DICT_TO_BSON(p_command);
        bsoncxx::document::value result_bson = _database.run_command(command_bson.view());
        return BSON_TO_DICT(result_bson);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotDatabase::drop() {
    ENSURE_DATABASE_SETUP();
    try {
        _database.drop();
        return true;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}