# Make a zip of addons/mongo-driver-godot

import shutil
import glob
import os

patterns = ["*.lib", "*.exp", "*.import"]
for pattern in patterns:
    print(pattern)
    for file in glob.glob("addons/**/" + pattern, recursive=True):
        print("Deleting " + file)
        os.remove(file)

version = input("Enter version: ")
shutil.make_archive(
    base_name="mongo-driver-godot.v" + version,
    format="zip",
    root_dir="addons/",
    base_dir="mongo-driver-godot",
)
print("Done")
