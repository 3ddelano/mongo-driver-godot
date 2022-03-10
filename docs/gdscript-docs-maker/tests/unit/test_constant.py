from gdscript_docs_maker.gdscript.constant import Constant

constant_data = {
    "name": "Index",
    "value": "[GDScript:19168]",
    "data_type": "MongoIndex",
    "signature": 'const Index: MongoIndex = preload("")',
}


def test_from_dict():
    constant_data["description"] = " Wrapper\n"

    c: Constant = Constant.from_dict(constant_data)
    assert c.name == "Index"
    assert c.default_value == "[GDScript:19168]"
    assert c.type == "MongoIndex"
    assert c.description == "Wrapper"
    assert c.hidden is False


def test_from_dict_parses_hidden():
    constant_data["description"] = " @hidden\n"
    c: Constant = Constant.from_dict(constant_data)

    assert c.hidden is True
