#ifndef MONGOGODOTDRIVER_H
#define MONGOGODOTDRIVER_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

#include <mongo_godot_connection.h>
#include <mongocxx/instance.hpp>

using namespace godot;

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
    Variant connect_to_server(String p_uri = "");
};

#endif