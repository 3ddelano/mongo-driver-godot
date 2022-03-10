"""Merges JSON dumped by Godot's gdscript language server or converts it to a markdown
document.
"""
import json
import logging
import os
import sys
from argparse import Namespace
from itertools import repeat
from typing import List

import pkg_resources

from . import command_line
from .config import LOG_LEVELS, LOGGER
from .convert_to_markdown import convert_to_markdown
from .gdscript_objects import GDScriptClasses
from .gdscript.project_info import ProjectInfo
from .make_markdown import MarkdownDocument


def main():
    args: Namespace = command_line.parse()

    if args.version:
        print(pkg_resources.get_distribution("gdscript-docs-maker").version)
        sys.exit()

    logging.basicConfig(level=LOG_LEVELS[min(args.verbose, len(LOG_LEVELS) - 1)])
    LOGGER.debug("Output format: {}".format(args.format))

    json_files: List[str] = [f for f in args.files if f.lower().endswith(".json")]
    LOGGER.info("Processing JSON files: {}".format(json_files))
    # Load the json files and extract the data
    for f in json_files:
        with open(f, "r") as json_file:
            data: dict = json.loads(json_file.read())

            project_info: ProjectInfo = ProjectInfo.from_dict(data)
            classes: GDScriptClasses = GDScriptClasses.from_dict_list(data["classes"])
            classes_count: int = len(classes)

            LOGGER.info(
                "Project {}, version {}".format(project_info.name, project_info.version)
            )
            LOGGER.info(
                "Processing {} classes in {}".format(classes_count, os.path.basename(f))
            )

            # Convert all the classes to a list of markdown documents
            documents: List[MarkdownDocument] = convert_to_markdown(
                classes, args, project_info
            )
            if args.dry_run:
                LOGGER.debug("Generated {} markdown documents.".format(len(documents)))
                list(map(lambda doc: LOGGER.debug(doc), documents))
            else:
                if not os.path.exists(args.path):
                    LOGGER.info("Creating directory " + args.path)
                    os.mkdir(args.path)

                LOGGER.info(
                    "Saving {} markdown files to {}".format(len(documents), args.path)
                )
                list(map(save, documents, repeat(args.path)))


def save(
    document: MarkdownDocument,
    dirpath: str,
):
    path: str = os.path.join(dirpath, document.get_filename())
    with open(path, "w") as file_out:
        LOGGER.debug("Saving markdown file " + path)
        file_out.write(document.as_string())

        for sub_document in document.sub_documents:
            sub_class_dirpath = os.path.join(dirpath, document.title, "sub_classes")
            if not os.path.exists(sub_class_dirpath):
                LOGGER.info("Creating directory " + sub_class_dirpath)
                os.makedirs(sub_class_dirpath)
            save(sub_document, sub_class_dirpath)


if __name__ == "__main__":
    main()
