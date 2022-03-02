#ifndef MONGO_GODOT_DRIVER_H
#define MONGO_GODOT_DRIVER_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

#include <mongo_godot_connection.h>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/instance.hpp>

using namespace godot;

/// Handles making connections to a MongoDB server.
class MongoGodotDriver : public Reference {
    GODOT_CLASS(MongoGodotDriver, Reference)

  public:
    /**
     * @brief Attempts to create a client connection to a MongoDB server.
     *
     * @param uri A MongoDB URI representing the connection parameters
     * @returns Returns a MongoGodotConnection or an error Dictionary.
     */
    Variant connect_to_server(String uri);

    void _init(); // Called by Godot
    static void _register_methods();
    MongoGodotDriver(){};
    ~MongoGodotDriver(){};

  private:
    static mongocxx::instance* instance;
};

#endif