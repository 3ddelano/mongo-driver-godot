Mongo Driver for Godot
=========================================
###### (Get it from Godot Asset Library - Coming Soon)

### [Documentation](https://3ddelano.github.io/mongo-driver-godot)

<img alt="logo" src="./mongo_driver_godot_logo.png" width="345"/>

### Unofficial MongoDB driver for Godot Engine 3.3.

> Should support Windows, Linux, OSX (Currently only built on Windows)


<br>
<img alt="Godot3" src="https://img.shields.io/badge/-Godot 3.3+-478CBF?style=for-the-badge&logo=godotengine&logoWidth=20&logoColor=white" />

Features
--------------

- CRUD operations on Database/Collection
- Document validation
- Pipeline / Aggregation operations
- Run commands on Database
- Operations on Collection Indexes


Installation
--------------

This is a regular plugin for Godot.
Copy the contents of `addons/mongo-driver-godot` into the `addons/` folder in the same directory as your project (There is **NO need** to activate the plugin in ProjectSettings).


> For in-depth installation instructions check the [Installation Wiki](https://3ddelano.github.io/mongo-driver-godot/installation)

> For **Linux / OSX** see [Building the plugin](https://3ddelano.github.io/mongo-driver-godot/building) 

Getting Started
----------

1. You may have to restart the Godot Editor to register the GDNative classes.
2. A basic example is given below:


```GDScript
extends Node

func _ready():
    var driver: MongoDriver = MongoDriver.new()
    var connection: MongoConnection = driver.connect_to_server("mongodb://localhost:27017")

    # Check for an error
    if Mongo.is_error(connection):
        print("Got error: ", connection)
        return

    # Print the names of the all the databases
    print(connection.get_database_names())
```

Benchmarks
----------

Tested on Windows 10 21H2 x64 (Godot 3.4.2)
To test locally run the scripts in `tests/benchmark` folder using the tester addon.
> See example script in scripts/run_tests.bat
> Click for [in-depth testing instructions](https://3ddelano.github.io/mongo-driver-godot/testing)

| Operation   | Number of Documents | Time (s) |
| ----------- | ------------------- | -------- |
| Insert one  | 10                  | 0.49     |
| Insert one  | 10,000              | 4.68     |
| Insert many | 10                  | 0.68     |
| Insert many | 10,000              | 0.90     |

Thirdparty Libraries
-----------

See [Thirdparty Libraries](https://github.com/3ddelano/mongo-driver-godot/blob/main/thirdparty/THIRDPARTY.md)

[Documentation](https://3ddelano.github.io/mongo-driver-godot)
-----------

Contributing
-----------

This plugin is a non-profit project developped by voluntary contributors.

### Supporters

```
None, you can be the first one!
```

Support the project development
-----------
<a href="https://www.buymeacoffee.com/3ddelano" target="_blank"><img height="41" width="174" src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" width="150" ></a>

Want to support in other ways? Contact me on Discord: `@3ddelano#6033`

For help / suggestions join: [3ddelano Cafe](https://discord.gg/FZY9TqW)

#### Disclaimer: This project is not affiliated nor endorsed by MongoDB Inc. nor Godot Engine