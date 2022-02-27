Installation
######

There are mainly three ways in which you can install the plugin sorted from easiest to hardest.

Get it from the asset library
******

Coming soon.

Get it from Github releases
******

Coming soon.

Build locally from source
******

Get the source code
======

Download and extract the source code from the `Github repo <https://github.com/3ddelano/mongo-driver-godot>`_

Update git submodules
======

``git submodule update --init --recusive``

Compile ``godot-cpp`` and other dependencies
======

For windows, run ``setup.bat``

For linux / mac run ``setup.sh``

Compile the plugin
======

``scons target=release``

The addon will be saved to ``project/addons/`` folder