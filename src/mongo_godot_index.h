#ifndef MONGO_GODOT_INDEX_H
#define MONGO_GODOT_INDEX_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

#include <mongo_godot_helpers.h>
#include <mongocxx/collection.hpp>
#include <mongocxx/exception/exception.hpp>

using namespace godot;

#define ENSURE_INDEX_SETUP()                                                                                                \
    if (!_collection) {                                                                                                     \
        return ERR_DICT("Index not setup");                                                                                 \
    }

/// Handles making connections to a MongoDB server.
class MongoGodotIndex : public Reference {
    GODOT_CLASS(MongoGodotIndex, Reference)
  public:
    /**
     * @brief Returns all the indexes.
     *
     * @return Array of indexes or error Dictionary
     */
    Variant list();

    /**
     * @brief Creates an index.
     *
     * @param index Dictionary representing the 'keys' and 'options' of the new index
     * @param options Optional arguments
     * @return The result document or error Dictionary
     */
    Variant create_one(Dictionary index, Dictionary options = Dictionary());

    /**
     * @brief Creates mulitple indexes.
     *
     * @param indexes Array of Dictionary representing the 'keys' and 'options' of the new indexes
     * @param options Optional arguments
     * @return The result document or error Dictionary
     */
    Variant create_many(Array indexes, Dictionary options = Dictionary());

    /**
     * @brief Attempts to drop a single index from the collection given the keys and options.
     *
     * @param name_or_index Either a String representing the index name or a Dictionary representing the 'keys' and 'options'
     * of the index to drop
     * @param options Optional arguments
     * @return True or error Dictionary
     */
    Variant drop_one(Variant name_or_index, Dictionary options = Dictionary());

    /**
     * @brief Drops all indexes in the collection.
     *
     * @param options Optional arguments
     * @return True or error Dictionary
     */
    Variant drop_all(Dictionary options = Dictionary());

    void _set_collection(mongocxx::collection p_collection) {
        _collection = p_collection;
    }

    void _init(){}; // Called by Godot
    static void _register_methods();
    MongoGodotIndex(){};
    ~MongoGodotIndex(){};

  private:
    mongocxx::collection _collection;
    void _parse_index_view_options(mongocxx::options::index_view& options, Dictionary p_options);
};

#endif