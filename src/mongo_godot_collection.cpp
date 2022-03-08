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
    register_method("get_name", &MongoGodotCollection::get_name);

    register_method("drop", &MongoGodotCollection::drop);
    register_method("count_documents", &MongoGodotCollection::count_documents);
    register_method("estimated_document_count", &MongoGodotCollection::estimated_document_count);

    register_method("create_index", &MongoGodotCollection::create_index);
    register_method("get_indexes", &MongoGodotCollection::get_indexes);
    register_method("get_indexes_list", &MongoGodotCollection::get_indexes_list);
    register_method("get_distinct", &MongoGodotCollection::get_distinct);
}

Variant MongoGodotCollection::find(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::find options;

        if (!p_options.empty()) {
            _parse_find_options(options, p_options);
        }

        auto docs = _collection.find(filter_bson.view(), options);
        Array result = Array();
        for (auto doc : docs) {
            result.push_back(BSON_DOCUMENT_TO_DICT(doc));
        }
        return result;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::find options;

        if (!p_options.empty()) {
            _parse_find_options(options, p_options);
        }
        auto doc = _collection.find_one(filter_bson.view(), options);
        if (!doc) {
            return Dictionary();
        }
        return BSON_DOCUMENT_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_delete(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::find_one_and_delete options;

        if (!p_options.empty()) {
            if (p_options.has("collation")) {
                Dictionary collation = p_options["collation"];
                options.collation(DICT_TO_BSON(collation));
            }

            if (p_options.has("max_time")) {
                int max_time = p_options["max_time"];
                options.max_time(std::chrono::milliseconds(max_time));
            }

            if (p_options.has("projection")) {
                Dictionary projection = p_options["projection"];
                options.projection(DICT_TO_BSON(projection));
            }

            if (p_options.has("sort")) {
                Dictionary sort = p_options["sort"];
                options.sort(DICT_TO_BSON(sort));
            }

            // TODO: support write_concern
            if (p_options.has("write_concern"))
                WARN_PRINT("write_concern is not yet supported.");

            if (p_options.has("hint")) {
                if (p_options["hint"].get_type() == Variant::DICTIONARY) {
                    Dictionary hint_dict = p_options["hint"];
                    auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
                    options.hint(hint);
                } else if (p_options["hint"].get_type() == Variant::STRING) {
                    String hint_str = p_options["hint"];
                    auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
                    options.hint(hint);
                }
            }
        }

        auto doc = _collection.find_one_and_delete(filter_bson.view(), options);
        if (!doc) {
            return ERR_DICT("Error in find one and delete.");
        }
        return BSON_DOCUMENT_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_replace(Dictionary p_filter, Dictionary p_doc, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        mongocxx::options::find_one_and_replace options;

        if (!p_options.empty()) {
            OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(
                p_options, "bypass_document_validation", bool, options.bypass_document_validation);

            if (p_options.has("collation")) {
                Dictionary collation = p_options["collation"];
                options.collation(DICT_TO_BSON(collation));
            }
            if (p_options.has("hint")) {
                if (p_options["hint"].get_type() == Variant::DICTIONARY) {
                    Dictionary hint_dict = p_options["hint"];
                    auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
                    options.hint(hint);
                } else if (p_options["hint"].get_type() == Variant::STRING) {
                    String hint_str = p_options["hint"];
                    auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
                    options.hint(hint);
                }
            }
            if (p_options.has("max_time")) {
                int max_time = p_options["max_time"];
                options.max_time(std::chrono::milliseconds(max_time));
            }
            if (p_options.has("projection")) {
                Dictionary projection = p_options["projection"];
                options.projection(DICT_TO_BSON(projection));
            }
            if (p_options.has("return_document")) {
                int return_document = p_options["return_document"];
                options.return_document(static_cast<mongocxx::options::return_document>(return_document));
            }
            if (p_options.has("sort")) {
                Dictionary sort = p_options["sort"];
                options.sort(DICT_TO_BSON(sort));
            }
            if (p_options.has("upsert")) {
                bool upsert = p_options["upsert"];
                options.upsert(upsert);
            }
            // TODO: support write_concern
            if (p_options.has("write_concern"))
                WARN_PRINT("write_concern is not yet supported.");
        }

        auto doc = _collection.find_one_and_replace(filter_bson.view(), doc_bson.view(), options);
        if (!doc) {
            return ERR_DICT("Error in find one and replace.");
        }
        return BSON_DOCUMENT_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::find_one_and_update(Dictionary p_filter, Dictionary p_doc, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();

    mongocxx::options::find_one_and_update options;
    if (!p_options.empty()) {
        OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(
            p_options, "bypass_document_validation", bool, options.bypass_document_validation);

        if (p_options.has("collation")) {
            Dictionary collation = p_options["collation"];
            options.collation(DICT_TO_BSON(collation));
        }
        if (p_options.has("hint")) {
            if (p_options["hint"].get_type() == Variant::DICTIONARY) {
                Dictionary hint_dict = p_options["hint"];
                auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
                options.hint(hint);
            } else if (p_options["hint"].get_type() == Variant::STRING) {
                String hint_str = p_options["hint"];
                auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
                options.hint(hint);
            }
        }
        if (p_options.has("max_time")) {
            int max_time = p_options["max_time"];
            options.max_time(std::chrono::milliseconds(max_time));
        }
        if (p_options.has("projection")) {
            Dictionary projection = p_options["projection"];
            options.projection(DICT_TO_BSON(projection));
        }
        if (p_options.has("return_document")) {
            int return_document = p_options["return_document"];
            options.return_document(static_cast<mongocxx::options::return_document>(return_document));
        }
        if (p_options.has("sort")) {
            Dictionary sort = p_options["sort"];
            options.sort(DICT_TO_BSON(sort));
        }
        if (p_options.has("upsert")) {
            bool upsert = p_options["upsert"];
            options.upsert(upsert);
        }
        // TODO: support write_concern
        if (p_options.has("write_concern"))
            WARN_PRINT("write_concern is not yet supported.");

        if (p_options.has("array_filters")) {
            bsoncxx::document::view options_bson = DICT_TO_BSON(p_options).view();
            bsoncxx::array::view array_filters = options_bson["array_filters"].get_array().value;
            options.array_filters(array_filters);
        }
    }

    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        auto doc = _collection.find_one_and_update(filter_bson.view(), doc_bson.view(), options);
        if (!doc) {
            return ERR_DICT("Error in find one and update.");
        }
        return BSON_DOCUMENT_TO_DICT(doc.value());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::insert_one(Dictionary p_doc, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();

    try {
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);
        mongocxx::options::insert options;
        if (!p_options.empty()) {
            _parse_insert_options(options, p_options);
        }
        auto result = _collection.insert_one(doc_bson.view(), options);
        if (!result) {
            return ERR_DICT("Error in insert one.");
        }
        bsoncxx::types::bson_value::view res = result->inserted_id();
        Variant id;
        BSON_VALUE_TO_GODOT_VARIANT(res, id);

        return Dictionary::make("inserted_id", id, "inserted_count", 1);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::insert_many(Array p_docs, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        std::vector<bsoncxx::document::value> docs;
        mongocxx::options::insert options;
        if (!p_options.empty()) {
            _parse_insert_options(options, p_options);
        }
        for (int i = 0; i < p_docs.size(); i++) {
            bsoncxx::document::value doc_bson = VARIANT_TO_BSON(p_docs[i]);
            docs.push_back(doc_bson);
        }
        auto result = _collection.insert_many(docs, options);
        if (!result) {
            return ERR_DICT("Error in insert many.");
        }

        auto inserted_ids = result->inserted_ids();
        auto inserted_count = result->inserted_count();
        Array inserted_idsArr = Array();
        for (auto inserted_id : inserted_ids) {
            Variant inserted_id_variant;
            BSON_VALUE_TO_GODOT_VARIANT(inserted_id.second, inserted_id_variant);
            inserted_idsArr.append(inserted_id_variant);
        }

        return Dictionary::make("inserted_ids", inserted_idsArr, "inserted_count", inserted_count);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::replace_one(Dictionary p_filter, Dictionary p_doc, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = DICT_TO_BSON(p_doc);

        mongocxx::options::replace options;
        if (!p_options.empty()) {
            OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(
                p_options, "bypass_document_validation", bool, options.bypass_document_validation);

            if (p_options.has("collation")) {
                Dictionary collation = p_options["collation"];
                options.collation(DICT_TO_BSON(collation));
            }
            if (p_options.has("upsert")) {
                bool upsert = p_options["upsert"];
                options.upsert(upsert);
            }
            // TODO: support write_concern
            if (p_options.has("write_concern"))
                WARN_PRINT("write_concern is not yet supported.");

            if (p_options.has("hint")) {
                if (p_options["hint"].get_type() == Variant::DICTIONARY) {
                    Dictionary hint_dict = p_options["hint"];
                    auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
                    options.hint(hint);
                } else if (p_options["hint"].get_type() == Variant::STRING) {
                    String hint_str = p_options["hint"];
                    auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
                    options.hint(hint);
                }
            }
        }
        auto result = _collection.replace_one(filter_bson.view(), doc_bson.view(), options);
        if (!result) {
            return ERR_DICT("Error in replace one.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        Variant upserted_id_variant;
        BSON_VALUE_TO_GODOT_VARIANT(upserted_id.value(), upserted_id_variant);

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            upserted_id_variant);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::update_one(Dictionary p_filter, Variant p_doc_or_pipeline, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = VARIANT_TO_BSON(p_doc_or_pipeline);
        mongocxx::options::update options;
        if (!p_options.empty()) {
            _parse_update_options(options, p_options);
        }

        auto result = _collection.update_one(filter_bson.view(), doc_bson.view(), options);
        if (!result) {
            return ERR_DICT("Error in update one.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        Variant upserted_id_variant;
        BSON_VALUE_TO_GODOT_VARIANT(upserted_id.value(), upserted_id_variant);

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            upserted_id_variant);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::update_many(Dictionary p_filter, Variant p_doc_or_array, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        bsoncxx::document::value doc_bson = VARIANT_TO_BSON(p_doc_or_array);
        mongocxx::options::update options;
        if (!p_options.empty()) {
            _parse_update_options(options, p_options);
        }
        auto result = _collection.update_many(filter_bson.view(), doc_bson.view(), options);
        if (!result) {
            return ERR_DICT("Error in update many.");
        }

        auto upserted_id = result->upserted_id();
        if (!upserted_id) {
            return Dictionary::make("matched_count", result->matched_count(), "modified_count", result->modified_count());
        }

        Variant upserted_id_variant;
        BSON_VALUE_TO_GODOT_VARIANT(upserted_id.value(), upserted_id_variant);

        return Dictionary::make(
            "matched_count",
            result->matched_count(),
            "modified_count",
            result->modified_count(),
            "upserted_id",
            upserted_id_variant);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::delete_one(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::delete_options options;
        if (!p_options.empty()) {
            _parse_delete_options(options, p_options);
        }

        auto result = _collection.delete_one(filter_bson.view(), options);
        if (!result) {
            return Dictionary();
        }
        return Dictionary::make("deleted_count", result->deleted_count());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::delete_many(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::delete_options options;
        if (!p_options.empty()) {
            _parse_delete_options(options, p_options);
        }
        auto result = _collection.delete_many(filter_bson.view(), options);
        if (!result) {
            return Dictionary();
        }
        return Dictionary::make("deleted_count", result->deleted_count());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::rename(String p_name, bool p_drop_target_before_rename) {
    ENSURE_COLLECTION_SETUP();
    try {
        _collection.rename(p_name.utf8().get_data(), p_drop_target_before_rename);
        return true;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::get_name() {
    ENSURE_COLLECTION_SETUP();
    try {
        return String(_collection.name().data());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::drop() {
    ENSURE_COLLECTION_SETUP();
    try {
        _collection.drop();
        return true;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::count_documents(Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::count options;
        if (!p_options.empty()) {
            OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "limit", int, options.limit);
            OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "skip", int, options.skip);

            if (p_options.has("collation")) {
                Dictionary collation = p_options["collation"];
                options.collation(DICT_TO_BSON(collation));
            }
            if (p_options.has("hint")) {
                if (p_options["hint"].get_type() == Variant::DICTIONARY) {
                    Dictionary hint_dict = p_options["hint"];
                    auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
                    options.hint(hint);
                } else if (p_options["hint"].get_type() == Variant::STRING) {
                    String hint_str = p_options["hint"];
                    auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
                    options.hint(hint);
                }
            }
            if (p_options.has("max_time")) {
                auto max_time = std::chrono::milliseconds((uint64_t) p_options["max_time"]);
                options.max_time(max_time);
            }
            // TODO: support read_preference
            if (p_options.has("read_preference"))
                WARN_PRINT("read_preference is not yet supported.");
        }
        return _collection.count_documents(filter_bson.view(), options);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::estimated_document_count(Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        mongocxx::options::estimated_document_count options;
        if (!p_options.empty()) {
            if (p_options.has("max_time")) {
                int max_time = p_options["max_time"];
                options.max_time(std::chrono::milliseconds(max_time));
            }
            // TODO:: support read_preference
            if (p_options.has("read_preference"))
                WARN_PRINT("read_preference is not yet supported.");
        }
        return _collection.estimated_document_count(options);
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Dictionary MongoGodotCollection::create_index(Dictionary p_index, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        if (!p_index.has("keys")) {
            return ERR_DICT("index must have a keys key.");
        }
        Dictionary keys = p_index["keys"];
        bsoncxx::document::view_or_value keys_bson = DICT_TO_BSON(keys);
        bsoncxx::document::view_or_value index_options_bson;
        mongocxx::options::index_view options = mongocxx::options::index_view{};

        if (p_index.has("options")) {
            Dictionary index_options = p_index["options"];
            index_options_bson = DICT_TO_BSON(index_options);
        }

        if (!p_options.empty()) {
            OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "commit_quorum", int, options.commit_quorum);

            if (p_options.has("max_time")) {
                auto max_time = std::chrono::milliseconds((uint64_t) p_options["max_time"]);
                options.max_time(max_time);
            }

            // TODO: support write_concern
            if (p_options.has("write_concern"))
                WARN_PRINT("write_concern is not yet supported.");
        }

        bsoncxx::document::value result = _collection.create_index(keys_bson, index_options_bson, options);
        return BSON_DOCUMENT_TO_DICT(result.view());
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::get_indexes() {
    ENSURE_COLLECTION_SETUP();
    try {
        Ref<MongoGodotIndex> index = (Ref<MongoGodotIndex>) MongoGodotIndex::_new();
        index->_set_collection(_collection);
        return index;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::get_indexes_list() {
    ENSURE_COLLECTION_SETUP();
    try {
        auto indexes = _collection.list_indexes();
        Array indexes_array;
        for (auto&& doc : indexes) {
            indexes_array.append(BSON_DOCUMENT_TO_DICT(doc));
        }
        return indexes_array;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

Variant MongoGodotCollection::get_distinct(String p_name, Dictionary p_filter, Dictionary p_options) {
    ENSURE_COLLECTION_SETUP();
    try {
        bsoncxx::document::value filter_bson = DICT_TO_BSON(p_filter);
        mongocxx::options::distinct options;

        if (!p_options.empty()) {
            if (p_options.has("collation"))
                options.collation(DICT_TO_BSON(((Dictionary) p_options["collation"])));

            if (p_options.has("max_time")) {
                int max_time = p_options["max_time"];
                options.max_time(std::chrono::milliseconds(max_time));
            }

            // TODO:: support read_preference
            if (p_options.has("read_preference"))
                WARN_PRINT("read_preference is not yet supported.");
        }

        auto result = _collection.distinct(p_name.utf8().get_data(), filter_bson.view(), options);
        Array result_array;
        for (auto&& doc : result) {
            result_array.append(BSON_DOCUMENT_TO_DICT(doc));
        }
        return result_array;
    } catch (mongocxx::exception& e) {
        return ERR_DICT(e.what());
    }
}

void MongoGodotCollection::_parse_find_options(mongocxx::options::find& options, Dictionary p_options) {
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "allow_disk_use", bool, options.allow_disk_use);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "allow_partial_results", bool, options.allow_partial_results);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "batch_size", int, options.batch_size);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "limit", int, options.limit);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "no_cursor_timeout", bool, options.no_cursor_timeout);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "return_key", bool, options.return_key);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "show_record_id", bool, options.show_record_id);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "skip", int, options.skip);

    if (p_options.has("max"))
        options.max(DICT_TO_BSON(((Dictionary) p_options["max"])));

    if (p_options.has("min"))
        options.min(DICT_TO_BSON(((Dictionary) p_options["min"])));

    if (p_options.has("projection"))
        options.projection(DICT_TO_BSON(((Dictionary) p_options["projection"])));

    if (p_options.has("collation"))
        options.collation(DICT_TO_BSON(((Dictionary) p_options["collation"])));

    if (p_options.has("cursor_type")) {
        int cursor_type = p_options["cursor_type"];
        options.cursor_type(static_cast<mongocxx::cursor::type>(cursor_type));
    }

    if (p_options.has("max_await_time")) {
        int max_await_time = p_options["max_await_time"];
        options.max_await_time(std::chrono::milliseconds(max_await_time));
    }

    if (p_options.has("max_time")) {
        int max_time = p_options["max_time"];
        options.max_time(std::chrono::milliseconds(max_time));
    }

    if (p_options.has("hint")) {
        if (p_options["hint"].get_type() == Variant::DICTIONARY) {
            Dictionary hint_dict = p_options["hint"];
            auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
            options.hint(hint);
        } else if (p_options["hint"].get_type() == Variant::STRING) {
            String hint_str = p_options["hint"];
            auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
            options.hint(hint);
        }
    }

    if (p_options.has("comment")) {
        String comment = p_options["comment"];
        options.comment(bsoncxx::string::view_or_value(comment.utf8().get_data()));
    }

    if (p_options.has("sort"))
        options.sort(DICT_TO_BSON(((Dictionary) p_options["sort"])));

    // TODO:: support read_preference
    if (p_options.has("read_preference"))
        WARN_PRINT("read_preference is not yet supported.");
}

void MongoGodotCollection::_parse_insert_options(mongocxx::options::insert& options, Dictionary p_options) {
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(
        p_options, "bypass_document_validation", bool, options.bypass_document_validation);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "ordered", bool, options.ordered);
    // TODO:: support write_concern
    if (p_options.has("write_concern"))
        WARN_PRINT("write_concern is not yet supported.");
}

void MongoGodotCollection::_parse_update_options(mongocxx::options::update& options, Dictionary p_options) {
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(
        p_options, "bypass_document_validation", bool, options.bypass_document_validation);
    OPTIONAL_KEY_FROM_DICT_AND_CALL_METHOD(p_options, "upsert", bool, options.upsert);

    if (p_options.has("collation")) {
        Dictionary collation = p_options["collation"];
        options.collation(DICT_TO_BSON(collation));
    }
    if (p_options.has("hint")) {
        if (p_options["hint"].get_type() == Variant::DICTIONARY) {
            Dictionary hint_dict = p_options["hint"];
            auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
            options.hint(hint);
        } else if (p_options["hint"].get_type() == Variant::STRING) {
            String hint_str = p_options["hint"];
            auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
            options.hint(hint);
        }
    }

    // TODO: support write_concern
    if (p_options.has("write_concern"))
        WARN_PRINT("write_concern is not yet supported.");

    if (p_options.has("array_filters")) {
        bsoncxx::document::view options_bson = DICT_TO_BSON(p_options).view();
        bsoncxx::array::view array_filters = options_bson["array_filters"].get_array().value;
        options.array_filters(array_filters);
    }
}

void MongoGodotCollection::_parse_delete_options(mongocxx::options::delete_options& options, Dictionary p_options) {
    if (p_options.has("collation")) {
        Dictionary collation = p_options["collation"];
        options.collation(DICT_TO_BSON(collation));
    }
    if (p_options.has("hint")) {
        if (p_options["hint"].get_type() == Variant::DICTIONARY) {
            Dictionary hint_dict = p_options["hint"];
            auto hint = mongocxx::hint(DICT_TO_BSON(hint_dict));
            options.hint(hint);
        } else if (p_options["hint"].get_type() == Variant::STRING) {
            String hint_str = p_options["hint"];
            auto hint = mongocxx::hint(bsoncxx::string::view_or_value(hint_str.utf8().get_data()));
            options.hint(hint);
        }
    }

    // TODO: support write_concern
    if (p_options.has("write_concern"))
        WARN_PRINT("write_concern is not yet supported.");
}
