"""
Parses the JSON data from Godot as a dictionary and outputs markdown
documents
"""

import re
import json
from argparse import Namespace
from typing import List

from gdscript_docs_maker.gdscript.enumeration import Enumeration

from .command_line import OutputFormats
from .config import LOGGER
from .gdscript_objects import GDScriptClasses
from .gdscript.member import Member
from .gdscript.function import Function
from .gdscript.gdscript_class import GDScriptClass, BUILTIN_CLASSES

from .gdscript.project_info import ProjectInfo
from .mkdocs import MkDocsFrontMatter
from .make_markdown import (
    MarkdownDocument,
    MarkdownSection,
    make_bold,
    make_code_block,
    make_comment,
    make_heading,
    make_link,
    make_list,
    make_table_header,
    make_table_row,
    surround_with_html,
)

GODOT_DOCS_URL = "https://docs.godotengine.org/en/stable/classes/class_{}.html"


def convert_to_markdown(
    classes: GDScriptClasses, arguments: Namespace, info: ProjectInfo
) -> List[MarkdownDocument]:
    """
    Takes a list of dictionaries that each represent one GDScript class to
    convert to markdown and returns a list of markdown documents.
    """

    markdown: List[MarkdownDocument] = []
    # if arguments.make_index:
    #     markdown.append(_write_index_page(classes, info))
    for entry in classes:
        markdown.append(_as_markdown(classes, entry, arguments))
    return markdown


def _as_markdown(
    classes: GDScriptClasses, gdscript: GDScriptClass, arguments: Namespace
) -> MarkdownDocument:
    """
    Converts the data for a GDScript class to a markdown document,
    using the command line options.
    """

    content: List[str] = []
    output_format: OutputFormats = arguments.format

    name: str = gdscript.name
    if "abstract" in gdscript.metadata:
        name += " " + surround_with_html("(abstract)", "small")

    if output_format == OutputFormats.MKDOCS:
        front_matter: MkDocsFrontMatter = MkDocsFrontMatter.from_data(
            gdscript, arguments
        )
        content += front_matter.as_string_list()

    content += [
        make_comment(
            "Auto-generated from JSON by GDScript docs maker. "
            "Do not edit this document directly."
        )
        + "\n"
    ]

    # -----
    # ----- Title
    content += [*make_heading(name, 1)]

    if gdscript.extends:
        extends_list: List[str] = gdscript.get_extends_tree(classes)

        # Get the links to each extend in the extends_tree
        extends_links = []
        for entry in extends_list:
            link = make_link(entry, "../" + entry)
            if entry.lower() in BUILTIN_CLASSES:
                # Built-in reference
                link = make_link(entry, GODOT_DOCS_URL.format(entry.lower()))
            extends_links.append(link)

        content += [make_bold("Extends:") + " " + " < ".join(extends_links)]

    # -----
    # ----- Description
    description = _replace_references(classes, gdscript, gdscript.description)
    if description != "":
        content += [*MarkdownSection("Description", 2, [description]).as_text()]

    quick_links = []
    if gdscript.signals:
        quick_links.append(make_link("Signals", "#signals"))
    if gdscript.enums:
        quick_links.append(make_link("Enumerations", "#enumerations"))
    if gdscript.constants:
        quick_links.append(make_link("Constants", "#constants-descriptions"))
    if gdscript.members:
        quick_links.append(make_link("Properties", "#property-descriptions"))
    if gdscript.functions:
        quick_links.append(make_link("Methods", "#method-descriptions"))
    if gdscript.sub_classes:
        quick_links.append(make_link("Sub-classes", "#sub-classes"))

    if len(quick_links) > 0:
        content += [""] + make_list(quick_links)

    if gdscript.signals:
        content += MarkdownSection(
            "Signals", 2, _write_signals(classes, gdscript, output_format)
        ).as_text()

    content += _write_class(classes, gdscript, output_format)

    sub_documents: List[MarkdownDocument] = []
    if gdscript.sub_classes:
        content += MarkdownSection(
            "Sub-classes",
            2,
            make_list(
                [
                    make_link(sub_class.name, "./sub_classes/" + sub_class.name)
                    for sub_class in gdscript.sub_classes
                ]
            ),
        ).as_text()

        for cls in gdscript.sub_classes:
            sub_documents.append(_as_markdown(classes, cls, arguments))

    #     content += make_heading("Sub-classes", 2)
    #     content.append("")

    #     for cls in gdscript.sub_classes:
    #         content += _write_class(classes, cls, output_format, 3, True)

    return MarkdownDocument(gdscript.name, content, sub_documents)


def _write_class(
    classes: GDScriptClasses,
    gdscript: GDScriptClass,
    output_format: OutputFormats,
    heading_level=2,
) -> List[str]:
    markdown: List[str] = []
    # if is_inner_class:
    #     markdown += make_heading(gdscript.name, heading_level)
    for attribute, title in [
        ("enums", "Enumerations"),
        ("constants", "Constants Descriptions"),
        ("members", "Property Descriptions"),
        ("functions", "Method Descriptions"),
    ]:
        if not getattr(gdscript, attribute):
            continue
        markdown += MarkdownSection(
            title,
            heading_level,
            _write(attribute, classes, gdscript, output_format),
        ).as_text()
    return markdown


def _write_summary(gdscript: GDScriptClass, key: str) -> List[str]:
    element_list = getattr(gdscript, key)
    if not element_list:
        return []
    markdown: List[str] = make_table_header(["Type", "Name"])
    return markdown + [make_table_row(item.summarize()) for item in element_list]


def _write(
    attribute: str,
    classes: GDScriptClasses,
    gdscript: GDScriptClass,
    output_format: OutputFormats,
    heading_level: int = 3,
) -> List[str]:
    assert hasattr(gdscript, attribute)

    markdown: List[str] = []
    for element in getattr(gdscript, attribute):
        # assert element is Element

        # -----
        # ----- Heading
        heading = element.get_heading_as_string()
        if isinstance(element, Member):
            if element.is_exported:
                heading += " " + surround_with_html("(export)", "small")
        markdown.extend(make_heading(heading, heading_level))

        # -----
        # ----- Signature
        if isinstance(element, Enumeration):
            markdown.extend(
                [
                    make_code_block(
                        f"enum {element.name} {json.dumps(element.values, indent = 4)}\n"
                    ),
                    "",
                ]
            )
        else:
            markdown.extend(
                [
                    make_code_block(element.signature),
                    "",
                ]
            )

        # -----
        # ----- Description
        description_first = False
        if isinstance(element, Function):
            description_first = True

        unique_attributes = element.get_unique_attributes_as_markdown()
        unique_attributes = [
            _replace_references(classes, gdscript, x) for x in unique_attributes
        ]
        description: str = _replace_references(classes, gdscript, element.description)

        if description_first:
            markdown.append(description)
            markdown.append("")
            markdown.extend(unique_attributes)
        else:
            markdown.extend(unique_attributes)
            markdown.append("")
            markdown.append(description)

    return markdown


def _write_signals(
    classes: GDScriptClasses, gdscript: GDScriptClass, output_format: OutputFormats
) -> List[str]:

    ret_signals = []
    for s in gdscript.signals:
        signal = "{}\n{}\n{}".format(
            "".join(make_heading(s.name, 3)),
            make_code_block(s.signature),
            _replace_references(classes, gdscript, s.description),
        )
        ret_signals.append(signal)
    return ret_signals


# def _write_index_page(classes: GDScriptClasses, info: ProjectInfo) -> MarkdownDocument:
#     title: str = "{} ({})".format(info.name, surround_with_html(info.version, "small"))
#     content: List[str] = [
#         *MarkdownSection(title, 1, info.description).as_text(),
#         *MarkdownSection("Contents", 2, _write_table_of_contents(classes)).as_text(),
#     ]
#     return MarkdownDocument("index", content)


# def _write_table_of_contents(classes: GDScriptClasses) -> List[str]:
#     toc: List[str] = []

#     by_category = classes.get_grouped_by_category()

#     for group in by_category:
#         indent: str = ""
#         first_class: GDScriptClass = group[0]
#         category: str = first_class.category
#         if category:
#             toc.append("- {}".format(make_bold(category)))
#             indent = "  "

#         for gdscript_class in group:
#             link: str = (
#                 indent + "- " + make_link(gdscript_class.name, gdscript_class.name)
#             )
#             toc.append(link)

#     return toc


def _replace_references(
    classes: GDScriptClasses, gdscript: GDScriptClass, description: str
) -> str:
    """Finds and replaces references to other classes or methods in the
    `description`."""
    ERROR_MESSAGES = {
        "class": "Class {} not found in the class index.",
        "member": "Symbol {} not found in {}. The name might be incorrect.",
    }
    ERROR_TAIL = "The name might be incorrect."

    references: list = re.findall(r"\[.+\]", description)

    for reference in references:
        # Matches [ClassName], [symbol], and [ClassName.symbol]
        match: re.Match | None = re.match(
            r"\[([A-Z][a-zA-Z0-9]*)?\.?([a-z0-9_]+)?\]", reference
        )
        if not match:
            continue

        class_name, member = match[1], match[2]
        is_builtin_class = False
        if class_name and class_name not in classes.class_index:
            if class_name.lower() in BUILTIN_CLASSES:
                is_builtin_class = True
            else:
                LOGGER.warning(ERROR_MESSAGES["class"].format(class_name) + ERROR_TAIL)
                continue

        if member and class_name:
            if member not in classes.class_index[class_name]:
                LOGGER.warning(
                    ERROR_MESSAGES["member"].format(member, class_name) + ERROR_TAIL
                )
                continue
        elif member and member not in classes.class_index[gdscript.name]:
            LOGGER.warning(
                ERROR_MESSAGES["member"].format(member, gdscript.name) + ERROR_TAIL
            )
            continue

        display_text, path = "", "../"
        if class_name:
            display_text, path = class_name, class_name
        if class_name and member:
            display_text += "."
            path += "/"
        if member:
            display_text += member
            path += "#" + member.replace("_", "-")

        if is_builtin_class:
            display_text = class_name
            path = GODOT_DOCS_URL.format(class_name.lower())

        link: str = make_link(display_text, path)
        description = description.replace(reference, link, 1)
    return description
