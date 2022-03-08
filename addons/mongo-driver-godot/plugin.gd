tool
extends EditorPlugin

"""
Mongo Driver Godot
MIT License (See LICENSE.md)

Copyright (c) 2022 Delano Lourenco
"""

func _enter_tree():
	# Ensure the addon in placed in res://addons/mongo-driver-godot
	var path: String = get_script().get_path()
	var base_dir = path.get_base_dir()

	if base_dir != "res://addons/mongo-driver-godot":
		var found_folder = base_dir.substr(0, base_dir.length() - "mongo-driver-godot".length())
		printerr("Error: mongo-driver-godot folder must be in res://addons/ but it was found in %s" % found_folder)
