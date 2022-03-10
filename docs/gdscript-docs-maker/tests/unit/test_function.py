from gdscript_docs_maker.gdscript.function import Function, FunctionTypes

func_data = {
    "name": "get_database_names",
    "return_type": "var",
    "rpc_mode": 0,
    "signature": "func get_database_names(filter: Dictionary)",
    "description": " Gets the names of the databases on the server.\n @param filter - Optional query\n @returns Array of database names or error Dictionary\n",
    "arguments": [{"name": "filter", "type": "Dictionary"}],
}


def test_from_dict():
    f: Function = Function.from_dict(func_data)

    assert f.name == "get_database_names"
    # assert f.return_type == "var"


def test_from_dict_parses_parameters():
    f: Function = Function.from_dict(func_data)

    assert len(f.metadata["parameters"]) == 1

    assert f.metadata["parameters"][0].name == "filter"
    assert f.metadata["parameters"][0].value == "Optional query"


def test_from_dict_parses_arguments():
    f: Function = Function.from_dict(func_data)

    assert len(f.arguments) == 1
    assert f.arguments[0].name == "filter"
    assert f.arguments[0].type == "Dictionary"


def test_from_dict_with_static_function():
    f: Function = Function.from_dict(
        {
            "name": "is_error",
            "return_type": "var",
            "rpc_mode": 0,
            "signature": "func is_error(obj)",
            "description": "",
            "arguments": [{"name": "obj", "type": "var"}],
        },
        True,
    )
    assert f.metadata["is_static"] is True
    assert f.metadata["is_virtual"] is False
    assert f.kind == FunctionTypes.STATIC


def test_from_dict_with_virtual_function():
    f: Function = Function.from_dict(
        {
            "name": "is_error",
            "return_type": "var",
            "rpc_mode": 0,
            "signature": "func is_error(obj)",
            "description": " This is a virtual method\n @virtual",
            "arguments": [{"name": "obj", "type": "var"}],
        },
        False,
    )
    assert f.metadata["is_virtual"] is True
    assert f.metadata["is_static"] is False
    assert f.kind == FunctionTypes.VIRTUAL


def test_from_dict_with_static_virtual_function():
    f: Function = Function.from_dict(
        {
            "name": "is_error",
            "return_type": "var",
            "rpc_mode": 0,
            "signature": "func is_error(obj)",
            "description": " This is a virtual method\n @virtual",
            "arguments": [{"name": "obj", "type": "var"}],
        },
        True,
    )
    assert f.metadata["is_virtual"] is False
    assert f.metadata["is_static"] is True
    assert f.kind == FunctionTypes.STATIC
