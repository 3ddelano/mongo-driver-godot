tool
extends EditorPlugin

"""
Mongo Driver Godot Tester
MIT License (See LICENSE.md)

Copyright (c) 2022 Delano Lourenco
"""

func _enter_tree():
	# Ensure the addon in placed in res://addons/tester
	var path: String = get_script().get_path()
	var base_dir = path.get_base_dir()

	if base_dir != "res://addons/tester":
		var found_folder = base_dir.substr(0, base_dir.length() - "tester".length())
		printerr("Error: tester folder must be in res://addons/ but it was found in %s" % found_folder)

	add_autoload_singleton("TestUtils", "res://addons/tester/test_utils.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("TestUtils")
