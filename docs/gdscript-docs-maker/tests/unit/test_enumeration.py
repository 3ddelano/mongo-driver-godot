from gdscript_docs_maker.gdscript.enumeration import Enumeration

enumeration_data = {
    "name": "ReturnDocument",
    "value": {"BEFORE": 0, "AFTER": 1},
    "data_type": "Dictionary",
    "signature": 'const ReturnDocument: Dictionary = {"AFTER":1,"BEFORE":0}',
    "description": " Docs for ReturnDocument\n",
}


def test_from_dict():
    enumeration_data["description"] = " Wrapper\n"

    e: Enumeration = Enumeration.from_dict(enumeration_data)
    assert e.name == "ReturnDocument"
    assert e.values == {"AFTER": 1, "BEFORE": 0}


def test_from_dict_parses_hidden():
    enumeration_data["description"] = " hey\n @hidden\n"
    e: Enumeration = Enumeration.from_dict(enumeration_data)

    assert e.hidden is True
