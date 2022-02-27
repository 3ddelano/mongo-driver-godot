# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------
project = 'Mongo Godot Driver'
copyright = '2022, Delano Lourenco'
author = 'Delano Lourenco'


# -- General configuration ---------------------------------------------------
extensions = ["breathe"]
breathe_projects = {
    "MongoGodot": "./doxygen_build/xml"
}
breathe_default_project = "MongoGodot"

# Tell sphinx what the primary language being documented is.
primary_domain = 'cpp'

# Tell sphinx what the pygments highlight language should be.
highlight_language = 'cpp'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']

import re
register_class_regex = r'register_class<([A-Za-z_][A-Za-z_0-9]*)>'
gdlibrary_file = '../src/gdlibrary.cpp'

registered_classes = []

with open(gdlibrary_file, 'r', encoding="utf-8") as f:
    for line in f:
        matches = re.findall(register_class_regex, line)
        if len(matches) > 0:
            registered_classes.append(matches[0])

# Clear the classes dir
classes_dir = "./classes"

# Create the classes_dir if it doesn't exist
if not os.path.exists(classes_dir):
    os.makedirs(classes_dir)

# Delete all files in classes_dir
for file in os.listdir(classes_dir):
    file_path = os.path.join(classes_dir, file)
    if os.path.isfile(file_path):
        os.unlink(file_path)

for registered_class in registered_classes:
    # Make a .rst file for the registered class
    class_file = './classes/' + registered_class + '.rst'
    with open(class_file, 'w', encoding="utf-8") as f:
        f.write(
            f"{registered_class}\n######\n\n.. doxygenclass:: {registered_class}\n   :members:")


# Manually insert the classes into the toctree in the correct order
# instead of using :glob:
index_file_template = './index_template'
index_file = './index.rst'

with open(index_file_template, 'r', encoding="utf-8") as f:
    index_file_template_content = f.read()

    classes_insert = "\n    ".join(
        ["classes/" + c for c in registered_classes])

    with open(index_file, 'w', encoding="utf-8") as ff:
        ff.write(index_file_template_content.replace(
            "{{insert_classes}}", classes_insert))
