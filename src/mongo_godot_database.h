#ifndef MONGOGODOTDATABASE_H
#define MONGOGODOTDATABASE_H

#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_collection.h>
#include <mongo_godot_helpers.h>

#include <mongocxx/client.hpp>

using namespace godot;

#define ENSURE_DATABASE_SETUP()                                                                                             \
    if (!_database)                                                                                                         \
        return ERR_DICT("Datbase not setup");

/// Represents a MongoDB database
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

    /**
     * @brief Gets the names of the collections in this database.
     *
     * @param filter Optional query expression to filter the returned collection names.
     * @return Array of collection names or error Dictionary
     */
    Variant get_collection_names(Dictionary filter = Dictionary());

    /**
     * @brief Obtains a collection which represents a logical grouping of documents within this database.
     *
     * @param name Name of the collection to get
     * @return The MongoGodotCollection or error Dictionary
     */
    Variant get_collection(String name);

    /**
     * @brief Runs a command against this database.
     *
     * @param command Dictionary representing the command to be run
     * @return The result Dictionary or error Dictionary
     */
    Dictionary run_command(Dictionary command);

    /**
     * @brief Drops the database and all its collections.
     *
     * @return True or error Dictionary
     */
    Variant drop();
};

#endif