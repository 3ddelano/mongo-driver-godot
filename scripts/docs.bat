@echo off
title Generate docs for mongo-driver-godot

@REM needs godot to be available in PATH

set GDSCRIPT_DOCS_MAKER_PATH=%CD%\docs\gdscript-docs-maker
set DOCS_BUILD_PATH=%CD%\docs\docs\classes

set CUR_DIR=%CD%
pushd .
cd project
set PROJECT_PATH=%CD%
erase /Q reference.json > nul
robocopy %GDSCRIPT_DOCS_MAKER_PATH%\godot-scripts . Collector.gd /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT
robocopy %GDSCRIPT_DOCS_MAKER_PATH%\godot-scripts . ReferenceCollectorCLI.gd /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT

python replace_doc_dir.py

cmd.exe /q /c godot --quiet -q -d -e -s --no-window --path %PROJECT_PATH% ReferenceCollectorCLI.gd > nul
erase /Q Collector.gd > nul
erase /Q ReferenceCollectorCLI.gd > nul
if exist __pycache__ (rmdir __pycache__ /s /q > nul)
set GD_PROJECT_PATH=%CD%
cd %GDSCRIPT_DOCS_MAKER_PATH%\src\
if exist %DOCS_BUILD_PATH% (rmdir %DOCS_BUILD_PATH% /s /q > nul)
python -m gdscript_docs_maker %GD_PROJECT_PATH%\reference.json -p %DOCS_BUILD_PATH% -f mkdocs -d DD-MM-YYYY -a delano -v
@REM move /y %DOCS_BUILD_PATH%\index.md _index.md > nul
cd %CUR_DIR%