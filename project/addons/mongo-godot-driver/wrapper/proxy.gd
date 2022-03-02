# Proxy
# Modified from:
#  https://github.com/samsface/godot-steam-api/blob/35f57c87b858a7a7ac9a34eb376b574d5d958098/addons/steam_api/steam_i.gd#L28
extends Reference

var _object: Reference

func _init(obj) -> void:
	_object = obj

func _call(func_name: String, args := []):
	if not _object:
		return null

	return _object.callv(func_name, args)
