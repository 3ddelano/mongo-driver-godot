from dataclasses import dataclass, field
from typing import List

from ..utils import extract_metadata

# from ..utils import extract_hidden


@dataclass
class Element:
    """
    Base type for all main GDScript symbol types. Contains properties common
    to Signals, Functions, Member variables, etc.
    """

    signature: str
    name: str
    description: str
    metadata: dict = field(init=False)
    hidden: bool = field(init=False)

    def __post_init__(self):
        _description, self.metadata = extract_metadata(self.description)

        if "hidden" in self.metadata:
            self.hidden = True
            del self.metadata["hidden"]
        else:
            self.hidden = False
        self.description = _description.strip("\n")

    def get_heading_as_string(self) -> str:
        """
        Returns an empty string. Virtual method to get a list of strings representing
        the element as a markdown heading.
        """
        return self.name

    def get_unique_attributes_as_markdown(self) -> List[str]:
        """
        Returns an empty list. Virtual method to get a list of strings describing the
        unique attributes of this element. hey this is another line of comment
        """
        return []

    @staticmethod
    def from_dict(data: dict) -> "Element":
        e = Element(data["signature"], data["name"], data["description"])
        return e
