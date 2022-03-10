"""
Converts the json representation of GDScript classes as dictionaries into objects
"""
import itertools
import operator
from typing import List

from .gdscript.gdscript_class import GDScriptClass


class GDScriptClasses(list):
    """
    Container for a list of GDScriptClass objects

    Provides methods for filtering and grouping GDScript classes
    """

    def __init__(self, *args):
        super(GDScriptClasses, self).__init__(args[0])
        self.class_index = {
            gdscript_class.name: gdscript_class.symbols for gdscript_class in self
        }

    def _get_grouped_by(self, attribute: str) -> List[List[GDScriptClass]]:
        if not self or attribute not in self[0].__dict__:
            return []

        groups = []
        get_attribute = operator.attrgetter(attribute)
        data = sorted(self, key=get_attribute)
        for key, group in itertools.groupby(data, get_attribute):
            groups.append(list(group))
        return groups

    def get_grouped_by_category(self) -> List[List[GDScriptClass]]:
        """
        Returns a list of lists of GDScriptClass objects, grouped by their `category`
        attribute
        """
        return self._get_grouped_by("category")

    @staticmethod
    def from_dict_list(data: List[dict]):
        ret_gdscript_classes = []
        for entry in data:
            if "name" not in entry:
                continue

            ret_gdscript_class = GDScriptClass.from_dict(entry)
            if ret_gdscript_class.hidden:
                continue

            ret_gdscript_classes.append(ret_gdscript_class)

        return GDScriptClasses(ret_gdscript_classes)
