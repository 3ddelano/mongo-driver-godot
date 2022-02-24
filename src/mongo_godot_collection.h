#ifndef MONGOGODOTCOLLECTION_H
#define MONGOGODOTCOLLECTION_H

#include <Godot.hpp>
#include <Reference.hpp>

#include <mongo_godot_helpers.h>

#include <mongocxx/collection.hpp>
#include <mongocxx/exception/exception.hpp>

#define ENSURE_SETUP()                                                                                                      \
    if (!_collection)                                                                                                       \
        return ERR_DICT("Collection not setup");

using namespace godot;

class MongoGodotCollection : public Reference {
    GODOT_CLASS(MongoGodotCollection, Reference)
  private:
    mongocxx::collection _collection;

  public:
    void _init(){}; // Called by Godot
    static void _register_methods();

    MongoGodotCollection(){};
    ~MongoGodotCollection(){};

    // Actual methods
    void _set_collection(mongocxx::collection p_collection);
    Variant find(Dictionary p_filter);
    Dictionary find_one(Dictionary p_filter);
    Dictionary find_one_and_delete(Dictionary p_filter);
    Dictionary find_one_and_replace(Dictionary p_filter, Dictionary p_doc);
    Dictionary find_one_and_update(Dictionary p_filter, Dictionary p_doc);
    Dictionary insert_one(Dictionary p_doc);
    Dictionary insert_many(Array p_docs);
    Dictionary replace_one(Dictionary p_filter, Dictionary p_doc);
    Dictionary update_one(Dictionary p_filter, Dictionary p_doc);
    Dictionary update_many(Dictionary p_filter, Dictionary p_doc);
    Dictionary delete_one(Dictionary p_filter);
    Dictionary delete_many(Dictionary p_filter);
    bool rename(String p_name, bool p_drop_target_before_rename = false);
    bool drop();
    int64_t count_documents(Dictionary p_filter);
    int64_t estimated_document_count();
};

#endif