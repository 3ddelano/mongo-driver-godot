#ifndef MONGOGODOTCONNECTION_H
#define MONGOGODOTCONNECTION_H

#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_database.h>
#include <mongo_godot_helpers.h>

#include <mongocxx/client.hpp>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/uri.hpp>

using namespace godot;

class MongoGodotConnection : public Reference {
    GODOT_CLASS(MongoGodotConnection, Reference)
  private:
    mongocxx::client* _client;

  public:
    void _init(){}; // Called by Godot
    static void _register_methods();

    MongoGodotConnection(){};
    ~MongoGodotConnection() {
        delete _client;
    };

    // Actual methods
    void _connect_to_server(String p_uri);
    Variant MongoGodotConnection::get_database_names(Dictionary filter = Dictionary());
    Ref<MongoGodotDatabase> get_database(String database_name = "");
};

#endif