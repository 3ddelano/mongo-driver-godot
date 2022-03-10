from gdscript_docs_maker.gdscript.signal import Signal

signal_data = {
    "name": "test_with_args",
    "arguments": ["arg1", "arg2", "arg3", "arg4"],
    "signature": "signal test_with_args(arg1, arg2, arg3, arg4)",
}


def test_from_dict():
    signal_data["description"] = " Desc for signal test_with_args()\n"

    s: Signal = Signal.from_dict(signal_data)
    assert s.name == "test_with_args"
    assert len(s.arguments) == 4
    assert s.arguments == ["arg1", "arg2", "arg3", "arg4"]
    assert s.hidden is False


def test_from_dict_parses_hidden():
    signal_data["description"] = " @hidden\n"
    s: Signal = Signal.from_dict(signal_data)

    assert s.hidden is True
