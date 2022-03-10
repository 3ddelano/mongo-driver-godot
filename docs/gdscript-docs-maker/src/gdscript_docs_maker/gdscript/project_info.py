from dataclasses import dataclass


@dataclass
class ProjectInfo:
    name: str
    description: str
    version: str

    @staticmethod
    def from_dict(data: dict):
        return ProjectInfo(data["name"], data["description"], data["version"])
