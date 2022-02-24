#include <mongo_godot_connection.h>

void MongoGodotConnection::_register_methods() {
    register_method("get_database_names", &MongoGodotConnection::get_database_names);
    register_method("get_database", &MongoGodotConnection::get_database);
}

void MongoGodotConnection::_connect_to_server(String p_uri) {
    // Try to create a URI object from the given string
    try {
        mongocxx::uri _uri(p_uri.utf8().get_data());
        _client = new mongocxx::client(_uri);
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
    }
}

Variant MongoGodotConnection::get_database_names(Dictionary filter) {
    if (!_client) {
        return ERR_DICT("Not connected to Mongo server");
    }
    try {
        bsoncxx::document::value filter_doc = bsoncxx::from_json(filter.to_json().utf8().get_data());
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

Ref<MongoGodotDatabase> MongoGodotConnection::get_database(String database_name) {
    if (database_name.length() == 0) {
        ERR_PRINT("Database name is empty.");
        return Ref<MongoGodotDatabase>();
    }
    if (!_client) {
        ERR_PRINT("Not connected to Mongo server.");
        return Ref<MongoGodotDatabase>();
    }
    try {
        mongocxx::database database = _client->database(database_name.utf8().get_data());
        Ref<MongoGodotDatabase> ref = (Ref<MongoGodotDatabase>) MongoGodotDatabase::_new();
        ref->_set_database(database);
        return ref;
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return Ref<MongoGodotDatabase>();
    }
}