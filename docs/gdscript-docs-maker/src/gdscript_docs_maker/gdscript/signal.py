from dataclasses import dataclass
from typing import List

from .element import Element


@dataclass
class Signal(Element):
    arguments: List[str]

    @staticmethod
    def from_dict(data: dict) -> "Signal":
        return Signal(
            data["signature"],
            data["name"],
            data["description"],
            data["arguments"],
        )
