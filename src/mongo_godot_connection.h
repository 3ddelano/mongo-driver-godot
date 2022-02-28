#ifndef MONGO_GODOT_CONNECTION_H
#define MONGO_GODOT_CONNECTION_H

#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_database.h>
#include <mongo_godot_helpers.h>

#include <mongocxx/exception/exception.hpp>

using namespace godot;

/// Represents a connection to a MongoDB server.
class MongoGodotConnection : public Reference {
    GODOT_CLASS(MongoGodotConnection, Reference)
  private:
    mongocxx::client* _client = nullptr;

  public:
    void _init(){}; // Called by Godot
    static void _register_methods();

    MongoGodotConnection(){};
    ~MongoGodotConnection() {
        delete _client;
    };

    // Actual methods
    void _set_client(mongocxx::client* client);

    /**
     * @brief Gets the names of the databases on the server.
     *
     * @param filter Optional query expression to filter the returned database names.
     * @return Array of database names or error Dictionary
     */
    Variant MongoGodotConnection::get_database_names(const Dictionary& filter = Dictionary());

    /**
     * @brief Obtains a database thats represents a logical grouping of collections on a MongoDB server
     *
     * @param name Name of the database to get
     * @return The MongoGodotDatabase or error Dictionary
     */
    Variant get_database(String name = "");
};

#endif