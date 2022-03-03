import logging
import os


def _get_mkdocs_templates() -> dict:
    templates: dict = {}
    this_file_path: str = os.path.dirname(__file__)
    template_path: str = os.path.join(this_file_path, "data/mkdocs_front_matter.toml")
    with open(template_path, "r") as file_toml:
        templates["toml"] = file_toml.read()
    return templates


LOGGER = logging.getLogger("GDScript docs maker")
LOG_LEVELS = [logging.INFO, logging.DEBUG]
LOG_LEVELS = [None] + sorted(LOG_LEVELS, reverse=True)

MKDOCS_FRONT_MATTER = _get_mkdocs_templates()
