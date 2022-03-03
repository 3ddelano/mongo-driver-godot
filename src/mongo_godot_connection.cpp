#include <mongo_godot_connection.h>

void MongoGodotConnection::_register_methods() {
    register_method("get_database_names", &MongoGodotConnection::get_database_names);
    register_method("get_database", &MongoGodotConnection::get_database);
}

void MongoGodotConnection::_set_client(mongocxx::client* p_client) {
    _client = p_client;
}

Variant MongoGodotConnection::get_database_names(const Dictionary& p_filter) {
    if (_client == nullptr || !_client) {
        return ERR_DICT("Connection not setup");
    }

    try {
        bsoncxx::document::value filter_doc = bsoncxx::builder::basic::make_document();
        if (!p_filter.empty()) {
            filter_doc = bsoncxx::from_json(p_filter.to_json().utf8().get_data());
        }
        std::vector<std::string> databaseVector = _client->list_database_names(filter_doc.view());
        Array databasesArr = Array();
        for (auto& database : databaseVector) {
            databasesArr.push_back(String(database.c_str()));
        }
        return databasesArr;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotConnection::get_database(const String& database_name) {
    if (database_name.length() == 0) {
        return ERR_DICT("Database name is empty.");
    }
    if (_client == nullptr || !_client) {
        return ERR_DICT("Not connected to Mongo server");
    }
    try {
        mongocxx::database database = _client->database(database_name.utf8().get_data());
        Ref<MongoGodotDatabase> ref = (Ref<MongoGodotDatabase>) MongoGodotDatabase::_new();
        ref->_set_database(database);
        return ref;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}