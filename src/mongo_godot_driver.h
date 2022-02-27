#ifndef MONGOGODOTDRIVER_H
#define MONGOGODOTDRIVER_H

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
  private:
    static mongocxx::instance* instance;

  public:
    void _init(); // Called by Godot
    static void _register_methods();

    MongoGodotDriver(){};
    ~MongoGodotDriver(){};

    // Actual methods
    /**
     * @brief Attempts to create a client connection to a MongoDB server.
     *
     * Example:
     *
     *     var driver = MongoGodotDriver.new()
     *     var connection = driver.connect_to_server("mongodb://localhost:27017/myapp")
     *
     * @param uri A MongoDB URI representing the connection parameters
     * @returns Returns a MongoGodotConnection or an error Dictionary.
     */
    Variant connect_to_server(String uri);
};

#endif