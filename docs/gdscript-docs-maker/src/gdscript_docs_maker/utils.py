"""Generic utility functions for GDScript docs maker."""
from dataclasses import dataclass
from typing import List, Tuple
import re


@dataclass
class Metadata:
    """
    Container for metadata extracted from some description.
    """

    name: str
    value: str


def build_re_pattern(tag_name: str) -> str:
    """
    Returns a string pattern to match for JSDoc-style tags,
    with the form @tag_name or @tag_name - value
    The match pattern has a match group for the value.
    """
    return "^@({}) ?-? ?(.+)?".format(tag_name)


def extract_metadata(description: str) -> Tuple[str, dict]:
    """
    Extracts the metadata in the provided description and returns the description
    without the corresponding lines, as well as the metadata. In the source text,
    Metadata tags should be of the form @tag or @tag - value or @tag value
    e.g. @returns String
    e.g. @tags - Class, Main
    e.g. @abstract
    """
    metadata: dict = {}

    lines: List[str] = description.split("\n")
    description_trimmed: List[str] = []

    pattern_regex = build_re_pattern("[A-Za-z_][0-9A-Za-z_]*")
    param_regex = r"([A-Za-z_][0-9A-Za-z_]*) ?-? ?(.+)"

    for _, line in enumerate(lines):
        line_stripped: str = line.strip()
        match_tags = re.match(pattern_regex, line_stripped)

        if match_tags:
            tag_name = match_tags.group(1)
            tag_value = match_tags.group(2)

            # Check if it was a param tag
            if tag_name == "param":
                param_data = re.match(param_regex, tag_value)
                if param_data:
                    if "parameters" not in metadata:
                        metadata["parameters"] = []
                    metadata["parameters"].append(
                        Metadata(param_data.group(1), param_data.group(2))
                    )
            elif tag_name == "tags":
                tags: List[str] = [tag.strip() for tag in tag_value.split(",")]
                metadata["tags"] = tags
            else:
                metadata[tag_name] = tag_value
        else:
            line = re.sub("^ ", "", line).rstrip()
            if not line.startswith("!"):
                description_trimmed.append(line)

    return "\n".join(description_trimmed), metadata
