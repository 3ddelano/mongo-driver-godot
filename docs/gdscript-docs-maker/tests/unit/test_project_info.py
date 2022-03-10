from gdscript_docs_maker.gdscript.project_info import ProjectInfo


def test_from_dict():
    p: ProjectInfo = ProjectInfo("ABCDE", "DESC", "n/a")
    assert p.name == "ABCDE"
    assert p.description == "DESC"
    assert p.version == "n/a"
