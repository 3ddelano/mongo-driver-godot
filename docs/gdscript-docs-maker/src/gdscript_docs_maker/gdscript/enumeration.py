from dataclasses import dataclass

from .element import Element


@dataclass
class Enumeration(Element):
    """
    Represents a GDScript enum with its constants
    """

    values: dict

    @staticmethod
    def from_dict(data: dict) -> "Enumeration":
        return Enumeration(
            data["signature"],
            data["name"],
            data["description"],
            data["value"],
        )
