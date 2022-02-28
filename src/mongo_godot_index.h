#ifndef MONGO_GODOT_INDEX_H
#define MONGO_GODOT_INDEX_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

#include <mongo_godot_helpers.h>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/index_view.hpp>

using namespace godot;

#define ENSURE_INDEX_SETUP()                                                                                                \
    if (!index) {                                                                                                           \
        return ERR_DICT("Index not setup");                                                                                 \
    }

/// Handles making connections to a MongoDB server.
class MongoGodotIndex : public Reference {
    GODOT_CLASS(MongoGodotIndex, Reference)
  private:
    std::shared_ptr<mongocxx::index_view> index;

  public:
    void _init(){}; // Called by Godot
    static void _register_methods();

    MongoGodotIndex(){};
    ~MongoGodotIndex(){
        // delete index;
    };

    // Actual methods
    Variant list();
    Variant create_one(Dictionary index, Dictionary options = Dictionary());
    Variant create_many(Array indexes, Dictionary options = Dictionary());
    Dictionary drop_one(Variant name_or_keys, Dictionary options = Dictionary());
    Dictionary drop_all(Dictionary options = Dictionary());
};

#endif