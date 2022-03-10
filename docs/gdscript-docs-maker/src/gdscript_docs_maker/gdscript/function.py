from dataclasses import dataclass
from typing import List
from enum import Enum

from ..make_markdown import make_bold, surround_with_html
from .element import Element


class FunctionTypes(Enum):
    METHOD = 1
    VIRTUAL = 2
    STATIC = 3


@dataclass
class FunctionArgument:
    """
    Container for function arguments.
    """

    name: str
    type: str


@dataclass
class Function(Element):
    """
    Container for a GDScript function.
    """

    kind: FunctionTypes
    return_type: str
    arguments: List[FunctionArgument]
    rpc_mode: int

    def __post_init__(self):
        super().__post_init__()
        self.signature = self.signature.replace("-> null", "-> void", 1)
        self.return_type = self.return_type.replace("null", "void", 1)

    # def summarize(self) -> List[str]:
    #     return [self.return_type, self.signature]

    def get_unique_attributes_as_markdown(self) -> List[str]:
        unique_attributes: List[str] = []
        if "parameters" in self.metadata and len(self.metadata["parameters"]) > 0:
            params_list = []
            for param in self.metadata["parameters"]:
                params_list.append(make_bold(param.name) + ": " + param.value)
            unique_attributes.append(make_bold("Parameters") + "\n")
            unique_attributes.append(
                "\n".join(["  - " + param for param in params_list])
            )

            if "returns" in self.metadata and len(self.metadata["returns"]) > 0:
                unique_attributes.append("\n")

        if "returns" in self.metadata and len(self.metadata["returns"]) > 0:
            unique_attributes.append(
                make_bold("Returns:") + " " + self.metadata["returns"]
            )

        if len(unique_attributes) > 0:
            unique_attributes.append("")

        return unique_attributes

    def get_heading_as_string(self) -> str:
        """Returns an empty list. Virtual method to get a list of strings representing
        the element as a markdown heading."""
        heading: str = self.name
        if self.kind == FunctionTypes.VIRTUAL:
            heading += " " + surround_with_html("(virtual)", "small")
        if self.kind == FunctionTypes.STATIC:
            heading += " " + surround_with_html("(static)", "small")
        return heading

    @staticmethod
    def from_dict(data: dict, is_static=False) -> "Function":
        f: Function = Function(
            data["signature"],
            data["name"],
            data["description"],
            FunctionTypes.METHOD,
            data["return_type"],
            Function._get_arguments(data["arguments"]),
            data["rpc_mode"] if "rpc_mode" in data else 0,
        )

        is_virtual: bool = "virtual" in f.metadata and not is_static
        f.metadata["is_virtual"] = is_virtual
        f.metadata["is_static"] = is_static

        if is_static:
            f.kind = FunctionTypes.STATIC
        elif is_virtual:
            f.kind = FunctionTypes.VIRTUAL

        return f

    @staticmethod
    def _get_arguments(data: List[dict]) -> List[FunctionArgument]:
        return [
            FunctionArgument(
                entry["name"],
                entry["type"],
            )
            for entry in data
        ]
