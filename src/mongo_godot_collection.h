#ifndef MONGOGODOTCOLLECTION_H
#define MONGOGODOTCOLLECTION_H

// #include <Array.hpp>
#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_helpers.h>

#include <mongocxx/collection.hpp>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/options/find_one_and_update.hpp>

#define ENSURE_COLLECTION_SETUP()                                                                                           \
    if (!_collection)                                                                                                       \
        return ERR_DICT("Collection not setup");

using namespace godot;

/// Represents a server side document grouping within a MongoDB database.
class MongoGodotCollection : public Reference {
    GODOT_CLASS(MongoGodotCollection, Reference)
  private:
    mongocxx::collection _collection;

    void _parse_find_options(mongocxx::options::find& find_options, Dictionary options);

  public:
    void _init(){}; // Called by Godot
    static void _register_methods();

    MongoGodotCollection(){};
    ~MongoGodotCollection(){};

    // Actual methods
    void _set_collection(mongocxx::collection collection);

    /**
     * @brief Finds the documents in this collection which match the provided filter.
     *
     * @param filter Document view representing a document that should match the query
     * @param options Optional arguments
     * @return Array of documents or error Dictionary
     */
    Variant find(Dictionary filter, Dictionary options = Dictionary());
    Dictionary find_one(Dictionary filter, Dictionary options = Dictionary());
    Dictionary find_one_and_delete(Dictionary filter, Dictionary options = Dictionary());
    Dictionary find_one_and_replace(Dictionary filter, Dictionary doc);
    Dictionary find_one_and_update(Dictionary filter, Dictionary doc, Dictionary options = Dictionary());
    Dictionary insert_one(Dictionary doc);
    Dictionary insert_many(Array docs);
    Dictionary replace_one(Dictionary filter, Dictionary doc);
    Dictionary update_one(Dictionary filter, Dictionary doc);
    Dictionary update_many(Dictionary filter, Dictionary doc);
    Dictionary delete_one(Dictionary filter);
    Dictionary delete_many(Dictionary filter);
    bool rename(String name, bool drop_target_before_rename = false);
    Variant drop();
    int64_t count_documents(Dictionary filter);
    int64_t estimated_document_count();
};

#endif