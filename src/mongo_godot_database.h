#ifndef MONGO_GODOT_DATABASE_H
#define MONGO_GODOT_DATABASE_H

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

  public:
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
     * @brief Explicitly creates a collection in this database with the specified options.
     *
     * @param name Name of the new collection
     * @param options The options for the new collection
     * @return The newly created MongoGodotCollection or error Dictionary
     */
    Variant create_collection(String name, Dictionary options = Dictionary());

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

    void _set_database(mongocxx::database p_database);

    void _init(){}; // Called by Godot
    static void _register_methods();
    MongoGodotDatabase(){};
    ~MongoGodotDatabase(){};

  private:
    mongocxx::database _database;
};

#endif