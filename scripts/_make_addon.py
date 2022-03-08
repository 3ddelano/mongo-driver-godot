# Make a zip of addons/mongo-driver-godot

import shutil
import glob
import os

print("Deleting unneccesary files")
patterns = ["*.lib", "*.exp", "*.import"]
for pattern in patterns:
    for file in glob.glob("addons/**/" + pattern):
        os.remove(file)

version = input("Enter version: ")
shutil.make_archive(
    base_name ="mongo-driver-godot.v" + version,
    format = 'zip',
    root_dir = "addons/",
    base_dir = "mongo-driver-godot"
)
print("Done")
