#include <mongo_godot_collection.h>

void MongoGodotCollection::_register_methods() {
    register_method("find", &MongoGodotCollection::find);
    register_method("find_one", &MongoGodotCollection::find_one);
    register_method("find_one_and_delete", &MongoGodotCollection::find_one_and_delete);
    register_method("find_one_and_replace", &MongoGodotCollection::find_one_and_replace);
    register_method("find_one_and_update", &MongoGodotCollection::find_one_and_update);
    register_method("insert_one", &MongoGodotCollection::insert_one);
    register_method("insert_many", &MongoGodotCollection::insert_many);
    register_method("replace_one", &MongoGodotCollection::replace_one);
    register_method("update_one", &MongoGodotCollection::update_one);
    register_method("update_many", &MongoGodotCollection::update_many);
    register_method("delete_one", &MongoGodotCollection::delete_one);
    register_method("delete_many", &MongoGodotCollection::delete_many);
    register_method("rename", &MongoGodotCollection::rename);
    register_method("drop", &MongoGodotCollection::drop);
    register_method("count_documents", &MongoGodotCollection::count_documents);
    register_method("estimated_document_count", &MongoGodotCollection::estimated_document_count);
}

void MongoGodotCollection::_set_collection(mongocxx::collection p_collection) {
    _collection = p_collection;
}

Dictionary MongoGodotCollection::find_one(Dictionary p_filter) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        auto doc = _collection.find_one(filter_bson.view());
        if (!doc) {
            return ERR_DICT("Collection not found.");
        }
        return BSON_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::find(Dictionary p_filter) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        auto docs = _collection.find(filter_bson.view());
        Array result = Array();
        for (auto doc : docs) {
            result.push_back(BSON_TO_DICT(doc));
        }
        return result;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_delete(Dictionary p_filter) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        auto doc = _collection.find_one_and_delete(filter_bson.view());
        if (!doc) {
            return ERR_DICT("Error in find one and delete.");
        }
        return BSON_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_replace(Dictionary p_filter, Dictionary p_doc) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto doc = _collection.find_one_and_replace(filter_bson.view(), doc_bson.view());
        if (!doc) {
            return ERR_DICT("Error in find one and replace.");
        }
        return BSON_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_update(Dictionary p_filter, Dictionary p_doc) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto doc = _collection.find_one_and_update(filter_bson.view(), doc_bson.view());
        if (!doc) {
            return ERR_DICT("Error in find one and update.");
        }
        return BSON_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::insert_one(Dictionary p_doc) {
    ENSURE_SETUP();

    if (p_doc.empty()) {
        return ERR_DICT("Collection is empty.");
    }
    try {
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto result = _collection.insert_one(doc_bson.view());
        if (!result) {
            return ERR_DICT("Error in insert one.");
        }

        return Dictionary::make("inserted_id", OID_TO_STRING(result->inserted_id().get_oid()), "inserted_count", 1);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::insert_many(Array p_docs) {
    ENSURE_SETUP();

    try {
        std::vector<bsoncxx::document::value> docs;
        for (int i = 0; i < p_docs.size(); i++) {
            bsoncxx::document::value doc_bson = VARIANT_TO_BSON(p_docs[i]);
            docs.push_back(doc_bson);
        }
        auto result = _collection.insert_many(docs);
        if (!result) {
            return ERR_DICT("Error in insert many.");
        }

        auto inserted_ids = result->inserted_ids();
        auto inserted_count = result->inserted_count();
        Array inserted_idsArr = Array();
        for (auto inserted_id : inserted_ids) {
            inserted_idsArr.append(inserted_id.second.get_oid().value.to_string().c_str());
        }

        return Dictionary::make("inserted_ids", inserted_idsArr, "inserted_count", inserted_count);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::replace_one(Dictionary p_filter, Dictionary p_doc) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto result = _collection.replace_one(filter_bson.view(), doc_bson.view());
        if (!result) {
            return ERR_DICT("Error in replace one.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            OID_TO_STRING(upserted_id->get_oid()));
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::update_one(Dictionary p_filter, Dictionary p_doc) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto result = _collection.update_one(filter_bson.view(), doc_bson.view());
        if (!result) {
            return ERR_DICT("Error in update one.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            OID_TO_STRING(upserted_id->get_oid()));
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::update_many(Dictionary p_filter, Dictionary p_doc) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto result = _collection.update_many(filter_bson.view(), doc_bson.view());
        if (!result) {
            return ERR_DICT("Error in update many.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            OID_TO_STRING(upserted_id->get_oid()));
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::delete_one(Dictionary p_filter) {
    ENSURE_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        auto result = _collection.delete_one(filter_bson.view());
        if (!result) {
            return Dictionary();
        }
        return Dictionary::make("deleted_count", result->deleted_count());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::delete_many(Dictionary p_filter) {
    ENSURE_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        auto result = _collection.delete_many(filter_bson.view());
        if (!result) {
            return Dictionary();
        }
        return Dictionary::make("deleted_count", result->deleted_count());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

bool MongoGodotCollection::rename(String p_name, bool p_drop_target_before_rename) {
    try {
        _collection.rename(p_name.utf8().get_data(), p_drop_target_before_rename);
        return true;
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return false;
    }
}

bool MongoGodotCollection::drop() {
    try {
        _collection.drop();
        return true;
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return false;
    }
}

int64_t MongoGodotCollection::count_documents(Dictionary p_filter) {
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        return _collection.count_documents(filter_bson.view());
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return -1;
    }
}

int64_t MongoGodotCollection::estimated_document_count() {
    try {
        return _collection.estimated_document_count();
    } catch (mongocxx::exception& e) {
        ERR_PRINT(e.what());
        return -1;
    }
}