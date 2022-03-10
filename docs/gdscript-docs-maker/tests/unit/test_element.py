from gdscript_docs_maker.gdscript.element import Element


def test_from_dict_removes_leading_whitespace():
    e: Element = Element.from_dict(
        {
            "signature": "class Mongo",
            "name": "Mongo",
            "description": " abcd",
        }
    )
    assert e.description == "abcd"
    assert e.hidden is False


def test_from_dict_finds_hidden():
    e: Element = Element.from_dict(
        {
            "signature": "class Mongo",
            "name": "Mongo",
            "description": " Wrapper\n @hidden\n",
        }
    )
    assert e.hidden is True


def test_get_heading_as_string():
    e: Element = Element.from_dict(
        {
            "signature": "class Mongo",
            "name": "Mongo",
            "description": " Wrapper\n @hidden\n",
        }
    )
    assert e.get_heading_as_string() == "Mongo"


def test_from_dict_parses_tags():
    element_data = {
        "signature": "class Mongo",
        "name": "Mongo",
        "description": " Wrapper\n @hidden\n @tags class, hello, test123",
    }

    e: Element = Element.from_dict(element_data)
    assert len(e.metadata["tags"]) == 3
    assert e.metadata["tags"] == ["class", "hello", "test123"]

    # Tags in alternate syntax
    element_data["description"] = " @tags - class, hello, test123"
    e = Element.from_dict(element_data)
    assert len(e.metadata["tags"]) == 3
    assert e.metadata["tags"] == ["class", "hello", "test123"]


def test_from_dict_parses_escape():
    e: Element = Element.from_dict(
        {
            "signature": "class Mongo",
            "name": "Mongo",
            "description": " Wrapper\n !This is is not to be parsed in docs\n !   Same for this line too\n This is visible",
        }
    )

    assert e.description == "Wrapper\nThis is visible"
