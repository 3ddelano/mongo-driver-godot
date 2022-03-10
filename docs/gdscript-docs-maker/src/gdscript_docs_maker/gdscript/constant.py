from dataclasses import dataclass
from .element import Element


@dataclass
class Constant(Element):
    """Represents a constant"""

    type: str
    default_value: str

    # def summarize(self) -> List[str]:
    #     return [self.type, self.name]

    @staticmethod
    def from_dict(data: dict) -> "Constant":
        return Constant(
            data["signature"],
            data["name"],
            data["description"],
            data["data_type"],
            data["value"],
        )
