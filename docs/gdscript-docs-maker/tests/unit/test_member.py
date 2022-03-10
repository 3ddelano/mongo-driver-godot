from gdscript_docs_maker.gdscript.member import Member


member_data = {
    "name": "hey",
    "data_type": "var",
    "default_value": None,
    "setter": "",
    "getter": "",
    "export": False,
    "signature": "var hey",
    "description": "",
}


def test_from_dict_simple():

    m: Member = Member.from_dict(member_data)
    assert m.name == "hey"
    assert m.type == "var"
    assert m.default_value is None
    assert m.setter == ""
    assert m.getter == ""
    assert m.is_exported is False


def test_from_dict_parses_hidden():
    member_data["description"] = " @hidden\n"
    m: Member = Member.from_dict(member_data)

    assert m.hidden is True


def test_from_dict_with_type():
    m: Member = Member.from_dict(
        {
            "name": "test",
            "data_type": "String",
            "default_value": None,
            "setter": "",
            "getter": "",
            "export": False,
            "signature": "var test: String",
            "description": "",
        }
    )
    assert m.type == "String"


def test_from_dict_with_setter():
    m: Member = Member.from_dict(
        {
            "name": "myprop",
            "data_type": "String",
            "default_value": "",
            "setter": "set_myprop",
            "getter": "",
            "export": False,
            "signature": 'var myprop: String = ""',
            "description": "",
        }
    )
    assert m.setter == "set_myprop"


def test_from_dict_with_getter():
    m: Member = Member.from_dict(
        {
            "name": "myprop",
            "data_type": "String",
            "default_value": "",
            "setter": "",
            "getter": "get_myprop",
            "export": False,
            "signature": 'var myprop: String = ""',
            "description": "",
        }
    )
    assert m.getter == "get_myprop"


def test_from_dict_with_getter_setter():
    m: Member = Member.from_dict(
        {
            "name": "myprop",
            "data_type": "String",
            "default_value": "",
            "setter": "set_myprop",
            "getter": "get_myprop",
            "export": False,
            "signature": 'var myprop: String = ""',
            "description": "",
        }
    )
    assert m.getter == "get_myprop"
    assert m.setter == "set_myprop"
