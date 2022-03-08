---
title: Testing
tags:
  - testing
---

The plugin has a separate plugin for testing which is present in the `addons/tester/` folder.

## Enable testing
Enable the `Mongo Godot Driver Tester` addon in the Plugins section of ProjectSettings.

This helper plugin supports 3 different testing modes:

- Single Script
- Single Folder
- Recursive Folders

## Configure
Open the `test.gd` script in `addons/tester/` folder and modify the variables:

- #### TESTS_PATH
    The path to a single script or folder to test
- #### TEST_FILE_PREFIX
    The prefix of the test file names
- #### TEST_FILE_SUFFIX
    The suffix of the test file names 
- #### TEST_MODE
    The test mode to use

## Run tests
- #### From Editor
    Run the `Test.tscn` scene which is in the `addons/tester/` folder.
- #### From Terminal
    !!! info "Quicker method"
        Simply run the `run_tests.bat` file in the `scripts/` folder instead of the below method.

    To run the tester from terminal, ensure you have `godot` on the environment path variable and run the below command. Replace `<PATH_TO_YOUR_GODOT_PROJECT>` with the path to your Godot project.
    ```
    godot --no-window --path <PATH_TO_YOUR_GODOT_PROJECT> addons/tester/Test.tscn
    ```