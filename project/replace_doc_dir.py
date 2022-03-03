# Small script with replaces the doc directory for gdscript-doc-maker
n = "ReferenceCollectorCLI.gd"
f = open(n, "r")
s = f.read().replace(
    "var directories := [\"res://\"]",
    "var directories := [\"res://addons/mongo-driver-godot/wrapper\"]")
f.close()
f = open(n, "w")
f.write(s)
f.close()
