# Make a zip of project/addons/mongo-godot-driver

import shutil

ADDON_DIR = "project/addons/mongo-godot-driver"
version = input("Enter version: ")
shutil.make_archive("mongo-godot-driver.v" + version, 'zip', ADDON_DIR)
print("Done")
