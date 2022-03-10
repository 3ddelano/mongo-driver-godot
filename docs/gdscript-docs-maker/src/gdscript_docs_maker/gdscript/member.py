from dataclasses import dataclass
from typing import List

from ..make_markdown import make_bold, make_code_inline, make_list
from .element import Element


@dataclass
class Member(Element):
    """
    Represents a property or member variable
    """

    type: str
    default_value: str
    is_exported: bool
    setter: str
    getter: str

    # def summarize(self) -> List[str]:
    #     return [self.type, self.name]

    def get_unique_attributes_as_markdown(self) -> List[str]:
        setget: List[str] = []

        if self.setter and not self.setter.startswith("_"):
            setget.append(make_bold("Setter") + ": " + make_code_inline(self.setter))

        if self.getter and not self.getter.startswith("_"):
            setget.append(make_bold("Getter") + ": " + make_code_inline(self.getter))

        setget = make_list(setget)
        if len(setget) > 0:
            setget.append("")

        return setget

    @staticmethod
    def from_dict(data: dict) -> "Member":
        return Member(
            data["signature"],
            data["name"],
            data["description"],
            data["data_type"],
            data["default_value"],
            data["export"],
            data["setter"],
            data["getter"],
        )
