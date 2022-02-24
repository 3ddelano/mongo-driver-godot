#include <mongo_godot_collection.h>
#include <mongo_godot_connection.h>
#include <mongo_godot_database.h>
#include <mongo_godot_driver.h>

using namespace godot;

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* o) {
    Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* o) {
    Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT godot_nativescript_init(void* handle) {
    Godot::nativescript_init(handle);

    register_class<MongoGodotDriver>();
    register_class<MongoGodotConnection>();
    register_class<MongoGodotDatabase>();
    register_class<MongoGodotCollection>();
}