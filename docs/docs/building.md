---
title: Building
tags:
  - Building
---

Following are the instructions to build the plugin from source.
The plugin can be built for Windows, Linux and OSX. But due to certain circumstances its only released for Windows x64.

## Prerequisites

1. Knowledge about building godot-cpp (See [C++ example](https://docs.godotengine.org/en/stable/tutorials/scripting/gdnative/gdnative_cpp_example.html))
2. Required tools like python, scons, c++ compiler, etc. 

## Windows

### Prerequisites
Visual Studio 16 2019

1. ### Clone the repo
   Clone the [Github repo](https://github.com/3ddelano/mongo-driver-godot)<br>
   ```
   git clone --recurse-submodules https://github.com/3ddelano/mongo-driver-godot.git
   ```

2. ### Run setup
   Open a x64 Native Tools Command Prompt for Visual Studio 2019 and navigate to the extracted repo      folder and run the command:
   ```
   setup.bat
   ```
   This will build the godot-cpp bindings and mongo-cxx-driver which are needed by the plugin.

3. ### Build the plugin
   To build the plugin itself run the command:
   ```
   scons target=release platform=windows -j8
   ```

4. ### Run test project
   Open the `project.godot` file in the `project/` folder using Godot to open the test project.

## Linux

Contribute instructions.

## OSX

Contribute instructions.
