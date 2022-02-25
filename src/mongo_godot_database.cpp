#include <mongo_godot_database.h>

void MongoGodotDatabase::_register_methods() {
    register_method("get_collection_names", &MongoGodotDatabase::get_collection_names);
    register_method("get_collection", &MongoGodotDatabase::get_collection);
}

void MongoGodotDatabase::_init() {
}

void MongoGodotDatabase::_set_database(mongocxx::database p_database) {
    _database = p_database;
}

Variant MongoGodotDatabase::get_collection_names(Dictionary p_filter) {
    if (!_database) {
        return ERR_DICT("Datbase not setup");
    }
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        std::vector<std::string> collectionVector = _database.list_collection_names(filter_bson.view());
        Array collections = Array();

        std::ofstream outdata;
        outdata.open("D:/Projects/Cpp/log.txt");
        outdata << "size is " << collectionVector.size() << std::endl;
        for (auto& collection : collectionVector) {
            outdata << collection.c_str() << std::endl;
            collections.push_back(String(collection.c_str()));
        }
        outdata.close();
        return collections;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Ref<MongoGodotCollection> MongoGodotDatabase::get_collection(String p_collection_name) {
    try {
        mongocxx::collection collection = _database.collection(p_collection_name.utf8().get_data());
        Ref<MongoGodotCollection> ref = (Ref<MongoGodotCollection>) MongoGodotCollection::_new();
        ref->_set_collection(collection);
        return ref;
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return Ref<MongoGodotCollection>();
    }
}