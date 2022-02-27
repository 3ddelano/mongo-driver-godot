#include <mongo_godot_driver.h>

void MongoGodotDriver::_register_methods() {
    register_method("connect_to_server", &MongoGodotDriver::connect_to_server);
}

mongocxx::instance* MongoGodotDriver::instance = 0;

void MongoGodotDriver::_init() {
    // Make only one instance of mongocxx::instance
    if (MongoGodotDriver::instance == 0) {
        MongoGodotDriver::instance = new mongocxx::instance();
    }
}

Variant MongoGodotDriver::connect_to_server(String p_uri) {
    if (p_uri.empty() || p_uri.length() == 0) {
        return ERR_DICT("Invalid URI provided.");
    }

    // Try to create a URI object from the given string
    try {
        Ref<MongoGodotConnection> ref = (Ref<MongoGodotConnection>) MongoGodotConnection::_new();
        mongocxx::uri _uri(p_uri.utf8().get_data());
        mongocxx::client* _client = new mongocxx::client(_uri);
        ref->_set_client(_client);
        return ref;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}