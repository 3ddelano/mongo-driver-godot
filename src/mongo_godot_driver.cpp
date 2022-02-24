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

// Return a Dictionary on error, or a Ref<MongoGodotConnection> on success
Variant MongoGodotDriver::connect_to_server(String p_uri) {
    if (p_uri.length() == 0) {
        return ERR_DICT("Invalid uri provided.");
    }
    Ref<MongoGodotConnection> ref = (Ref<MongoGodotConnection>) MongoGodotConnection::_new();
    ref->_connect_to_server(p_uri);
    return ref;
}