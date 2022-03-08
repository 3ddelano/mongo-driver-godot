#ifndef MONGO_GODOT_COLLECTION_H
#define MONGO_GODOT_COLLECTION_H

// #include <Array.hpp>
#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_helpers.h>
#include <mongo_godot_index.h>

#include <mongocxx/collection.hpp>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/instance.hpp>

#define ENSURE_COLLECTION_SETUP()                                                                                           \
    if (!_collection) {                                                                                                     \
        return ERR_DICT("Collection not setup");                                                                            \
    }

using namespace godot;

/// Represents a server side document grouping within a MongoDB database.
class MongoGodotCollection : public Reference {
    GODOT_CLASS(MongoGodotCollection, Reference)
  public:
    /**
     * @brief Finds the documents in this collection which match the provided filter.
     *
     * @param filter Dictionary representing a document that should match the query
     * @param options Optional arguments
     * @return Array of documents or error Dictionary
     */
    Variant find(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Finds a single document in this collection that match the provided filter.
     *
     * @param filter Dictionary representing a document that should match the query
     * @param options Optional arguments
     * @return An optional document that matched the filter or error Dictionary
     */
    Dictionary find_one(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Finds a single document matching the filter, deletes it, and returns the original.
     *
     * @param filter Dictionary representing a document that should be deleted
     * @param options Optional arguments
     * @return The document that was deleted or error Dictionary
     */
    Dictionary find_one_and_delete(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Finds a single document matching the filter, replaces it, and returns either the original or the replacement
     * document.
     *
     * @param filter Dictionary representing a document that should be replaced
     * @param doc Dictionary representing the replacement for a matching document
     * @param options Optional arguments
     * @return The original or replaced document or error Dictionary
     */
    Dictionary find_one_and_replace(Dictionary filter, Dictionary doc, Dictionary options = Dictionary());

    /**
     * @brief Finds a single document matching the filter, updates it, and returns either the original or the newly-updated
     * document.
     *
     * @param filter Dictionary representing a document that should be updated
     * @param doc Dictionary representing the update to apply to a matching document
     * @param options Optional arguments
     * @return The original or updated document or error Dictionary
     */
    Dictionary find_one_and_update(Dictionary filter, Dictionary doc, Dictionary options = Dictionary());

    /**
     * @brief Inserts a single document into the collection.
     *
     * If the document is missing an identifier (_id field) one will be generated for it.
     *
     * @param doc The document to insert
     * @param options Optional arguments
     * @return The result of attempting to perform the insert or error Dictionary
     */
    Dictionary insert_one(Dictionary doc, Dictionary options = Dictionary());

    /**
     * @brief Inserts multiple documents into the collection.
     *
     * If any of the documents are missing identifiers then they will be generated for them.
     *
     * @param doc Array of documents to insert
     * @param options Optional arguments
     * @return The result of attempting to performing the insert or error Dictionary
     */
    Dictionary insert_many(Array docs, Dictionary options = Dictionary());

    /**
     * @brief Replaces a single document matching the provided filter in this collection.
     *
     * @param filter Document representing the match criteria
     * @param doc The replacement document
     * @param options Optional arguments
     * @return The result of attempting to replace a document or error Dictionary
     */
    Dictionary replace_one(Dictionary filter, Dictionary doc, Dictionary options = Dictionary());

    /**
     * @brief Updates a single document matching the provided filter in this collection.
     *
     * @param filter Document representing the match criteria
     * @param doc Document representing the update to be applied to a matching document
     * @param options Optional arguments
     * @return The result of attempting to update a document or error Dictionary
     */
    Dictionary update_one(Dictionary filter, Variant doc_or_pipeline, Dictionary options = Dictionary());

    /**
     * @brief Updates multiple documents matching the provided filter in this collection.
     *
     * @param filter Document representing the match criteria
     * @param doc Document representing the update to be applied to the matching documents
     * @param options Optional arguments
     * @return The result of attempting to update multiple documents or error Dictionary
     */
    Dictionary update_many(Dictionary filter, Variant doc_or_pipeline, Dictionary options = Dictionary());

    /**
     * @brief Deletes a single matching document from the collection.
     *
     * @param filter Dictionary representing the data to be deleted
     * @param options Optional arguments
     * @return The result of performing the deletion or error Dictionary
     */
    Dictionary delete_one(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Deletes all matching documents from the collection.
     *
     * @param filter Dictionary representing the data to be deleted
     * @param options Optional arguments
     * @return The result of performing the deletion or error Dictionary
     */
    Dictionary delete_many(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Rename this collection.
     *
     * @param name The new name to assign to the collection
     * @param drop_target_before_rename Whether to overwrite any existing collections called new_name. The default is false.
     * @return True if success or error Dictionary
     */
    Variant rename(String name, bool drop_target_before_rename = false);

    /**
     * @brief Returns the name of this collection.
     *
     * @return The name of this collection
     */
    Variant get_name();

    /**
     * @brief Drops this collection and all its contained documents from the database.
     *
     * @return True if success or error Dictionary
     */
    Variant drop();

    /**
     * @brief Counts the number of documents matching the provided filter.
     *
     * @param filter The filter that documents must match in order to be counted
     * @param options Optional arguments
     * @return The count of the documents that matched the filter or error Dictionary
     */
    Variant count_documents(Dictionary filter, Dictionary options = Dictionary());

    /**
     * @brief Returns an estimate of the number of documents in the collection.
     *
     * @param options Optional arguments
     * @return The count of the documents that matched the filter or error Dictionary
     */
    Variant estimated_document_count(Dictionary options = Dictionary());

    /**
     * @brief Creates an index over the collection for the provided keys with the provided options.
     *
     * @param index Dictionary representing the 'keys' and 'options' of the new index
     * @param options Optional arguments
     * @return Dictionary or error Dictionary
     */
    Dictionary create_index(Dictionary index, Dictionary options = Dictionary());

    /**
     * @brief Returns a MongoGodotIndex for this collection
     *
     * @return MongoGodotIndex or error Dictionary
     */
    Variant get_indexes();

    /**
     * @brief Returns a list of the indexes currently on this collection.
     *
     * @return Array of indexes or error Dictionary
     */
    Variant get_indexes_list();

    /**
     * @brief Finds the distinct values for a specified field across the collection.
     *
     * @param name The field for which the distinct values will be found
     * @param filter Dictionary representing the documents for which the distinct operation will apply
     * @param options Optional arguments
     * @return Array of the distinct values or error Dictionary
     */
    Variant get_distinct(String name, Dictionary filter = Dictionary(), Dictionary options = Dictionary());

    void _set_collection(mongocxx::collection p_collection) {
        _collection = p_collection;
    }

    void _init(){}; // Called by Godot
    static void _register_methods();
    MongoGodotCollection(){};
    ~MongoGodotCollection(){};

  private:
    mongocxx::collection _collection;

    void _parse_find_options(mongocxx::options::find& find_options, Dictionary options);
    void _parse_insert_options(mongocxx::options::insert& find_options, Dictionary options);
    void _parse_update_options(mongocxx::options::update& find_options, Dictionary options);
    void _parse_delete_options(mongocxx::options::delete_options& find_options, Dictionary options);
};

#endif