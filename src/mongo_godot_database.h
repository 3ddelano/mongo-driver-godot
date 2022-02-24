#ifndef MONGOGODOTDATABASE_H
#define MONGOGODOTDATABASE_H

#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_collection.h>
#include <mongo_godot_helpers.h>

#include <mongocxx/client.hpp>
#include <mongocxx/exception/exception.hpp>

using namespace godot;

class MongoGodotDatabase : public Reference {
    GODOT_CLASS(MongoGodotDatabase, Reference)
  private:
    mongocxx::database _database;

  public:
    void _init(); // Called by Godot
    static void _register_methods();

    MongoGodotDatabase(){};
    ~MongoGodotDatabase(){};

    // Actual methods
    void _set_database(mongocxx::database p_database);
    Variant get_collection_names();
    Ref<MongoGodotCollection> get_collection(String p_collection_name);
};

#endif